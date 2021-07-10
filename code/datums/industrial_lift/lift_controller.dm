/datum/lift_controller
	var/id
	var/list/lift_platforms
	var/turf/current_position
	var/x_len
	var/y_len
	var/travel_progress = 0
	var/safeties = FALSE
	var/halted = FALSE
	var/datum/lift_waypoint/current_wp
	var/datum/lift_waypoint/prev_wp
	var/datum/lift_waypoint/next_wp

	var/datum/lift_route/route

	var/datum/lift_waypoint/destination_wp

/datum/lift_controller/New(id_arg, arg_position, arg_platforms)
	id = id_arg
	position = arg_position
	lift_platforms = arg_platforms
	return ..()

/datum/lift_controller/Destroy()
	return ..()

/datum/lift_controller/process(delta_time)
	return

//Called from SSindustrial_lift
/datum/lift_controller/proc/InitializeLift()
	route = SSindustrial_lift[id]
	if(!route)
		CRASH("Lift controller of id [id] could not find a route.")
	current_wp = route.GetWaypointInPosition(position)
	if(!current_wp)
		CRASH("Lift controller of id [id] could not find current waypoint.")
