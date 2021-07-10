/datum/lift_controller
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
	var/speed = 1
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

	/// Reference to the lift's route, for easy getting
	var/datum/lift_route/route

	/// The current destination of the lift
	var/datum/lift_waypoint/destination_wp
	/// Associative list of all the waypoints that have been queued for destination (FIFU)
	var/list/called_waypoints = list()

	var/next_action_time = 0
	var/needs_to_open_doors = FALSE
	var/interior_closed = FALSE
	var/exterior_closed = FALSE
	var/waypoint_speed_multiplier = 1

#define VERTICAL_TRAVEL_SPEED 0.2

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
		next_wp = route.GetEnrouteWaypoint(current_wp, destination_wp)
		waypoint_speed_multiplier = next_wp.connected[current_wp]
	var/move_dir = get_dir_multiz(current_position, next_wp.position)
	var/travel_speed = speed
	if(move_dir == UP || move_dir == DOWN)
		travel_speed *= VERTICAL_TRAVEL_SPEED
	travel_progress += travel_speed * waypoint_speed_multiplier
	if(travel_progress < 1)
		return
	//Move
	travel_progress = 0
	var/premove_collision = FALSE
	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		var/collision = platform.PreLiftMove(move_dir)
		if(collision)
			premove_collision = TRUE

	for(var/i in lift_platforms)
		var/obj/structure/industrial_lift/platform = i
		platform.LiftMove(move_dir)

	current_position = get_step_multiz(current_position, move_dir)
	if(current_position == next_wp.position)
		current_wp = next_wp
		prev_wp = null
		next_wp = null
	else if (current_wp)
		prev_wp = current_wp
		current_wp = null
	CheckMyDestination()

#undef VERTICAL_TRAVEL_SPEED

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
			//Put code to open exteriors here
			exterior_closed = FALSE
			next_action_time = world.time + 0.5 SECONDS
			return TRUE
		needs_to_open_doors = FALSE
		next_action_time = world.time + 3 SECONDS
		return TRUE
	if(destination_wp)
		if(!exterior_closed)
			exterior_closed = TRUE
			next_action_time = world.time + 0.5 SECONDS
			return TRUE
		if(!interior_closed)
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
			called_waypoints -= destination_wp
		else
			SetDestination(called_waypoint)

/datum/lift_controller/proc/CheckMyDestination()
	if(current_wp == destination_wp)
		ArrivedDestination()

/datum/lift_controller/proc/ArrivedDestination()
	needs_to_open_doors = TRUE
	called_waypoints -= destination_wp
	destination_wp = null
	SetHalted(TRUE)

//Someone pressed stop button
/datum/lift_controller/proc/ToggleIntentionalHalt()
	intentionally_halted = !intentionally_halted
	if(intentionally_halted)
		SetHalted(TRUE)

/datum/lift_controller/proc/InLiftBounds(atom/checked)
	var/turf/my_turf = current_position
	if(checked.z != my_turf.z)
		return FALSE
	if((checked.x >= my_turf.x && checked.x <= my_turf.x + x_len) && (checked.y >= my_turf.y && checked.y <= my_turf.y + x_len))
		return TRUE
	return FALSE

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
	travel_progress = 0
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
		var/connectibles = previous_waypoint_id ? list(previous_waypoint_id = 1) : null
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
	if(!current_wp)
		CRASH("Lift controller of id [id] could not find current waypoint.")
