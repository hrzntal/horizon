/datum/lift_controller
	/// Name of the thing we're operating on, be it lift, tram or elevator
	var/name = "industrial lift"
	/// Id of the lift controller
	var/id
	/// Associative list of all the lift platforms
	var/list/lift_platforms
	/// The current turf of the lift controller (most bottom left one)
	var/turf/current_position
	/// X length of the platform. FROM the position a lift of 4x4 will have 3 length in both dimensions
	var/x_len
	/// Y length of the platform
	var/y_len
	/// How fast we progress to the next tile movement, per process of the subsystem (in %s)
	var/speed = 0.5
	/// Keeping track of our progress towards the next turf
	var/travel_progress = 0
	/// Whether it has safeties on. Safeties will cause the lift to halt when attempting to crush something (still will heavy deal damage)
	var/safeties = TRUE
	/// Whether the lift is currently halted
	var/halted = TRUE
	/// Whether the lift is intentionally halted through an emergency button
	var/intentionally_halted = FALSE
	/// Current waypoint, will be null if we're in mid-transit
	var/datum/lift_waypoint/current_wp
	/// Previous waypoint, will be null if we're not in mid-transit
	var/datum/lift_waypoint/prev_wp
	/// Next waypoint, will be null if we're not in mid-transit
	var/datum/lift_waypoint/next_wp
	/// Direction to the next waypoint, so we dont need to keep getting it
	var/next_wp_dir = SOUTH

	/// Reference to the lift's route, for easy getting
	var/datum/lift_route/route

	var/datum/lift_waypoint/last_stop_wp
	/// The current destination of the lift
	var/datum/lift_waypoint/destination_wp
	/// Associative list of all the waypoints that have been queued for destination (FIFU)
	var/list/called_waypoints = list()

	/// Cooldown for actions
	var/next_action_time = 0
	/// Whether we have been requested to open doors by an arrival to destination
	var/needs_to_open_doors = FALSE
	/// Whether interior doors are closed
	var/interior_closed = FALSE
	/// Whether exterior doors are closed
	var/exterior_closed = FALSE
	/// The travel speed we calculated to the next waypoint
	var/calculated_travel_speed = 1
	/// The glide size we calculated to the next waypoint
	var/calculated_glide_size = 8

	/// Type of our sound loop
	var/sound_loop_type = /datum/looping_sound/industrial_lift
	/// Our sound loop
	var/datum/looping_sound/loop_sound

	/// Our roof type, if any it'll manifest whenever possible
	var/roof_type
	/// Whether we are currently managing a roof
	var/managing_roof = FALSE

/datum/lift_controller/process(delta_time)
	if(next_action_time > world.time)
		return
	CheckNextDestination()
	//implement: CheckPower() return; here if you want to even check for power
	if(ProcessActions())
		return
	if(!destination_wp)
		return
	if(halted && ProcessHalted())
		return
	if(!next_wp)
		SetNextWaypoint(route.GetEnrouteWaypoint(current_wp, destination_wp))
	
	travel_progress += calculated_travel_speed
	if(travel_progress < 1)
		return
	//Move
	var/move_dir = next_wp_dir
	travel_progress = 0
	var/premove_collisions = NONE
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		premove_collisions |= platform.PreLiftMove(move_dir, safeties)

	if(managing_roof)
		for(var/i in lift_platforms)
			var/obj/structure/industrial_lift/platform = i
			var/obj/structure/industrial_lift/roof = platform.managed_roof
			premove_collisions |= roof.PreLiftMove(move_dir, safeties)

	if(premove_collisions & LIFT_HIT_BLOCK)
		DoImpactEffects()
		ToggleIntentionalHalt()
		return
	if(premove_collisions & LIFT_HIT_MOB)
		DoImpactEffects()
	if(premove_collisions & LIFT_CRUSH_MOB && safeties)
		ToggleIntentionalHalt()
		return

	//Move the position and manage roof if any
	current_position = get_step_multiz(current_position, move_dir)

	//Current position changes, manage the roof
	var/do_manifest_roof = FALSE
	if(roof_type)
		var/can_roof = CanHaveRoof()
		if(can_roof != managing_roof)
			if(can_roof)
				do_manifest_roof = TRUE
			else
				UnmanifestRoof()

	//Here we move the ALL the platforms, and then after doing that we move ALL their contents back on their rightful platforms
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		if(platform.glide_size != calculated_glide_size)
			platform.glide_size = calculated_glide_size
		var/turf/step_turf = get_step_multiz(platform.loc, move_dir)
		platform.forceMove(step_turf)
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		for(var/b in platform.lift_load)
			var/atom/movable/movable_atom = b
			if(movable_atom.glide_size != calculated_glide_size)
				movable_atom.glide_size = calculated_glide_size
			movable_atom.forceMove(platform.loc)

	//And here we move ALL the roofs of the platforms, and then ALL their contents
	if(managing_roof)
		for(var/i in lift_platforms)
			var/obj/structure/industrial_lift/platform = i
			var/obj/structure/industrial_lift/roof = platform.managed_roof
			if(!isopenspaceturf(roof.loc)) //Dont snag people from turfs as we drive under them
				roof.RemoveAllItemsFromLift()
			if(roof.glide_size != calculated_glide_size)
				roof.glide_size = calculated_glide_size
			var/turf/step_turf = get_step_multiz(roof.loc, move_dir)
			roof.forceMove(step_turf)
		for(var/i in lift_platforms)
			var/obj/structure/industrial_lift/platform = i
			var/obj/structure/industrial_lift/roof = platform.managed_roof
			for(var/b in roof.lift_load)
				var/atom/movable/movable_atom = b
				if(movable_atom.glide_size != calculated_glide_size)
					movable_atom.glide_size = calculated_glide_size
				movable_atom.forceMove(roof.loc)

	//All the checks and sets regaring the new position
	loop_sound.output_atoms = list(GetSoundTurf())
	if(current_position == next_wp.position)
		current_wp = next_wp
		if(current_wp.is_stop)
			last_stop_wp = current_wp
		prev_wp = null
		next_wp = null
	else if (current_wp)
		prev_wp = current_wp
		current_wp = null
	CheckMyDestination()

	if(do_manifest_roof)
		ManifestRoof()


// This proc will reverse the route of the lift to the last stop and clear it's FIFO queue
/datum/lift_controller/proc/EmergencyRouteReversal()
	if(!halted || !prev_wp || !next_wp || !destination_wp)
		return
	var/prev_wp_cache = prev_wp
	var/destination_wp_cache = destination_wp
	called_waypoints.Cut()
	prev_wp = next_wp
	SetNextWaypoint(prev_wp_cache)
	SetDestination(last_stop_wp)
	last_stop_wp = destination_wp_cache

/datum/lift_controller/proc/GetStatusInfo()
	if(halted && current_wp == last_stop_wp)
		return SPAN_NOTICE("The <b>[name]</b> is currently at <b>[current_wp.name]</b>.")
	else
		return SPAN_NOTICE("The <b>[name]</b> is currently in transit from <b>[last_stop_wp.name]</b> to <b>[destination_wp.name]</b>.")

#define VERTICAL_TRAVEL_SPEED 0.2

/datum/lift_controller/proc/SetNextWaypoint(datum/lift_waypoint/setted_wp)
	next_wp = setted_wp
	var/connection_wp = current_wp || prev_wp
	var/waypoint_speed_multiplier = next_wp.connected[connection_wp]
	calculated_travel_speed = speed * waypoint_speed_multiplier
	next_wp_dir = get_dir_multiz(current_position, next_wp.position)
	if(next_wp_dir == UP || next_wp_dir == DOWN)
		calculated_travel_speed *= VERTICAL_TRAVEL_SPEED
	calculated_glide_size = (1/SS_LIFTS_TICK_RATE) * calculated_travel_speed * INDUSTRIAL_LIFT_GLIDE_SIZE_MULTIPLIER * GLOB.glide_size_multiplier

#undef VERTICAL_TRAVEL_SPEED

/datum/lift_controller/proc/DoImpactEffects()
	var/turf/action_turf = GetSoundTurf()
	playsound(action_turf, 'sound/effects/meteorimpact.ogg', 60, TRUE)
	for(var/mob/M in urange(CEILING(x_len/2,1), action_turf))
		if(!M.stat)
			shake_camera(M, 3, 1)

//Called on process() when halted is TRUE, check all conditions to determine whether we un-halt
/datum/lift_controller/proc/ProcessHalted()
	if(intentionally_halted)
		return TRUE
	SetHalted(FALSE)
	return FALSE

/datum/lift_controller/proc/ProcessActions()
	if(needs_to_open_doors)
		if(interior_closed)
			//Put code to open interiors here
			interior_closed = FALSE
			next_action_time = world.time + 0.5 SECONDS
			return TRUE
		if(exterior_closed)
			playsound(GetSoundTurf(), 'sound/lifts/elevator_ding.ogg', 100)
			//Put code to open exteriors here
			exterior_closed = FALSE
			next_action_time = world.time + 0.5 SECONDS
			return TRUE
		needs_to_open_doors = FALSE
		next_action_time = world.time + 3 SECONDS
		return TRUE
	if(destination_wp)
		if(!exterior_closed)
			//Put code to close exteriors here
			exterior_closed = TRUE
			next_action_time = world.time + 0.5 SECONDS
			return TRUE
		if(!interior_closed)
			//Put code to close interiors here
			interior_closed = TRUE
			next_action_time = world.time + 0.5 SECONDS
			return TRUE
	return FALSE

/datum/lift_controller/proc/CheckNextDestination()
	if(destination_wp)
		return
	if(called_waypoints.len)
		var/datum/lift_waypoint/called_waypoint = called_waypoints[1]
		if(current_wp == called_waypoint)
			called_waypoints -= called_waypoint
		else
			SetDestination(called_waypoint)

/datum/lift_controller/proc/CheckMyDestination()
	if(current_wp == destination_wp)
		ArrivedDestination()

/datum/lift_controller/proc/ArrivedDestination()
	needs_to_open_doors = TRUE
	last_stop_wp = destination_wp
	called_waypoints -= destination_wp
	destination_wp = null
	SetHalted(TRUE)

//Someone pressed stop button
/datum/lift_controller/proc/ToggleIntentionalHalt()
	intentionally_halted = !intentionally_halted
	if(intentionally_halted)
		SetHalted(TRUE)
	else
		next_action_time = world.time + 1 SECONDS

/datum/lift_controller/proc/InLiftBounds(atom/checked)
	var/turf/my_turf = current_position
	if(checked.z != my_turf.z)
		return FALSE
	if((checked.x >= my_turf.x && checked.x <= my_turf.x + x_len) && (checked.y >= my_turf.y && checked.y <= my_turf.y + x_len))
		return TRUE
	return FALSE

//Gets the turf sounds are supposed to be played on
/datum/lift_controller/proc/GetSoundTurf()
	var/turf/passed_turf = locate(current_position.x + FLOOR(x_len/2,1), current_position.y + FLOOR(y_len/2,1), current_position.z)
	return passed_turf

/datum/lift_controller/New(obj/structure/industrial_lift/master_lift)
	id = master_lift.id
	var/list/lifts_to_group = list()
	var/list/lifts_to_check = list()
	lifts_to_group[master_lift] = TRUE
	lifts_to_check[master_lift] = TRUE
	while(lifts_to_check.len)
		var/obj/structure/industrial_lift/checked = lifts_to_check[lifts_to_check.len]
		lifts_to_check -= checked
		var/turf/checked_turf = checked.loc
		for(var/cardinal in GLOB.cardinals)
			var/turf/step_turf = get_step(checked_turf, cardinal)
			if(step_turf == checked_turf)
				continue
			var/obj/structure/industrial_lift/other_lift = locate() in step_turf
			if(other_lift && !lifts_to_group[other_lift] && !other_lift.lift_controller && (!other_lift.id || other_lift.id == id))
				other_lift.id = id
				lifts_to_group[other_lift] = TRUE
				lifts_to_check[other_lift] = TRUE
	lift_platforms = lifts_to_group

	SSindustrial_lift.lift_controllers[id] = src

	var/obj/structure/industrial_lift/closest_platform
	var/obj/structure/industrial_lift/furthest_platform
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		platform.lift_controller = src
		if(!closest_platform || (platform.x <= closest_platform.x && platform.y <= closest_platform.y))
			closest_platform = platform
		if(!furthest_platform || (platform.x >= furthest_platform.x && platform.y >= furthest_platform.y))
			furthest_platform = platform
	current_position = closest_platform.loc
	x_len = furthest_platform.x - current_position.x
	y_len = furthest_platform.y - current_position.y

	loop_sound = new sound_loop_type(list(GetSoundTurf()))
	SSindustrial_lift.AddControllerToInit(src)
	return ..()

/datum/lift_controller/proc/CallWaypoint(datum/lift_waypoint/called)
	called_waypoints[called] = TRUE

/datum/lift_controller/proc/SetDestination(datum/lift_waypoint/called)
	destination_wp = called

//Call SetHalted(TRUE) freely, but only call SetHalted(FALSE) from ProcessHalted(), making sure all conditions allow the lift to go back on track
/datum/lift_controller/proc/SetHalted(bool)
	if(halted == bool)
		return
	halted = bool
	if(halted)
		travel_progress = 0
		loop_sound.stop()
	else
		loop_sound.start()
	if(!current_wp)
		current_wp = route.GetWaypointInPosition(current_position)
		if(current_wp)
			prev_wp = null
			next_wp = null

//If we dont have a mapped in route, then we'll try to create the usual industrial lift vertical route
/datum/lift_controller/proc/TryCreateRoute()
	//Find the lowest accessible turf from our position
	var/reached_lowest = FALSE
	var/turf/lowest_turf = current_position
	while(!reached_lowest)
		var/turf/lower_step = get_step_multiz(lowest_turf, DOWN)
		if(!lower_step)
			reached_lowest = TRUE
			break
		if(!isopenspaceturf(lowest_turf))
			reached_lowest = TRUE
			break
		lowest_turf = lower_step
	var/reached_highest = FALSE
	var/turf/highest_turf = current_position
	while(!reached_highest)
		var/turf/higher_step = get_step_multiz(highest_turf, UP)
		if(!higher_step)
			reached_highest = TRUE
			break
		if(!isopenspaceturf(higher_step))
			reached_highest = TRUE
			break
		highest_turf = higher_step
	var/waypoint_counter = 0
	var/made_waypoints = FALSE
	var/turf/waypoint_turf = lowest_turf
	var/previous_waypoint_id
	while(!made_waypoints)
		//Create waypoint
		waypoint_counter++
		var/wp_id = "[id]_[waypoint_counter]"
		var/list/connectibles
		if(previous_waypoint_id)
			connectibles = list()
			connectibles[previous_waypoint_id] = 1
		new /datum/lift_waypoint(
			"Floor [waypoint_counter]",
			"A stop for the floor [waypoint_counter]",
			id,
			wp_id,
			waypoint_turf,
			connectibles,
			TRUE
			)
		previous_waypoint_id = wp_id
		if(waypoint_turf == highest_turf)
			made_waypoints = TRUE
			break
		//Step up
		var/turf/higher_step = get_step_multiz(waypoint_turf, UP)
		waypoint_turf = higher_step

//Called from SSindustrial_lift
/datum/lift_controller/proc/InitializeLift()
	route = SSindustrial_lift.lift_routes[id]
	if(!route)
		TryCreateRoute()
		route = SSindustrial_lift.lift_routes[id]
		if(!route)
			CRASH("Lift controller of id [id] could not create a route.")
	current_wp = route.GetWaypointInPosition(current_position)
	last_stop_wp = current_wp
	if(!current_wp)
		CRASH("Lift controller of id [id] could not find current waypoint.")
	//Initialize roof, if possible
	if(roof_type && CanHaveRoof())
		ManifestRoof()

/datum/lift_controller/proc/CanHaveRoof()
	var/turf/up_step = get_step_multiz(current_position, UP)
	if(!up_step)
		return FALSE
	return TRUE

/datum/lift_controller/proc/ManifestRoof()
	managing_roof = TRUE
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		var/turf/up_step = get_step_multiz(platform.loc, UP)
		platform.managed_roof = new roof_type(up_step)

/datum/lift_controller/proc/UnmanifestRoof()
	managing_roof = FALSE
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		QDEL_NULL(platform.managed_roof)

/datum/lift_controller/tram
	name = "tram"
	speed = 1

/datum/lift_controller/elevator
	name = "elevator"
	roof_type = /obj/structure/industrial_lift/roof
