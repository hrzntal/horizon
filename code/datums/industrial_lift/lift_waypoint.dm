// Mapping helper and not a landmark because landmarks are terrible
/obj/effect/mapping_helpers/lift_waypoint
	name = "Lift Waypoint"
	desc = "A waypoint of the lift"
	/// Id of the lift this will belong to
	var/id
	/// Id of the waypoint
	var/waypoint_id
	/// Associative list of connected waypoint ID's to speed multiplier to getting to them ("waypoint_id" = 0.5) for example
	var/connects_to = list()
	/// Whether this will spawn a stop waypoint
	var/is_stop = TRUE

/obj/effect/mapping_helpers/lift_waypoint/Initialize()
	new /datum/lift_waypoint(name, desc, id, waypoint_id, loc, connects_to, is_stop)
	return ..()

/datum/lift_waypoint
	/// Name of the waypoint
	var/name
	/// Description of the waypoint
	var/desc
	/// Id of the lift this belongs to
	var/id
	/// Id of the waypoint
	var/waypoint_id
	/// Position of the waypoint
	var/turf/position
	/// Associative list of connected waypoints to speed multiplier to getting to them ("waypoint_id" = 0.5) for example
	var/list/connect_to
	/// Whether the waypoint is a stop
	var/is_stop = TRUE
	/// Associative list of connected waypoints to speed multiplier to getting to them (waypoint_ref = 0.5) for example
	var/list/connected = list()

/datum/lift_waypoint/New(arg_name, arg_desc, arg_id, arg_wp_id, arg_position, arg_connect_to, arg_is_stop)
	name = arg_name
	desc = arg_desc
	id = arg_id
	waypoint_id = arg_wp_id
	position = arg_position
	connect_to = arg_connect_to
	is_stop = arg_is_stop

	if(!SSindustrial_lift.lift_routes[id])
		SSindustrial_lift.lift_routes[id] = new /datum/lift_route(id)

	var/datum/lift_route/route = SSindustrial_lift.lift_routes[id]
	route.waypoints += src
	if(is_stop)
		route.stops += src

	SSindustrial_lift.lift_waypoints[waypoint_id] = src
	SSindustrial_lift.AddWaypointToInit(src)
	. = ..()

//Called by SSindustrial_lift. Connect to other waypoints here
/datum/lift_waypoint/proc/InitializeWaypoint()
	if(connect_to)
		for(var/other_id in connect_to)
			var/datum/lift_waypoint/waypoint = SSindustrial_lift.lift_waypoints[other_id]
			if(!waypoint)
				WARNING("Lift waypoint of id [id] and waypoint id of [waypoint_id] couldn't connect find a waypoint of id [other_id]")
				continue
			var/speed_multiplier = connect_to[other_id]
			connected[waypoint] = speed_multiplier
			waypoint.connected[src] = speed_multiplier
	connect_to = null

/datum/lift_route
	/// Id of the lift
	var/id
	/// All waypoints of our lift
	var/list/waypoints = list()
	/// All waypoints that are stops
	var/list/stops = list()

/datum/lift_route/New(arg_id)
	id = arg_id
	SSindustrial_lift.lift_routes[id] = src
	. = ..()

/datum/lift_route/proc/GetWaypointInPosition(turf/position)
	for(var/i in waypoints)
		var/datum/lift_waypoint/wp = i
		if(wp.position == position)
			return wp

#define LIFT_PATHFINDING_MAX_STEPS 20

/datum/lift_route/proc/GetEnrouteWaypoint(datum/lift_waypoint/origin, datum/lift_waypoint/destination)
	var/datum/lift_waypoint/found_next
	var/list/possible_waypoints = list()
	for(var/wp in origin.connected)
		var/datum/lift_waypoint/iterated_waypoint = wp
		if(iterated_waypoint == destination)
			return iterated_waypoint
		var/steps = 0
		var/connects = FALSE
		var/list/already_checked_waypoints = list()
		already_checked_waypoints[origin] = TRUE
		var/list/waypoints_to_check = list()
		waypoints_to_check[iterated_waypoint] = TRUE
		while(steps <= LIFT_PATHFINDING_MAX_STEPS)
			steps++
			if(connects)
				break
			for(var/b in waypoints_to_check)
				var/datum/lift_waypoint/waypoint_in_loop = b
				waypoints_to_check -= b
				if(waypoint_in_loop.connected[destination])
					connects = TRUE
					break
				for(var/wp2 in waypoint_in_loop.connected)
					if(!already_checked_waypoints[wp2])
						already_checked_waypoints[wp2] = TRUE
						waypoints_to_check[wp2] = TRUE
		if(connects)
			possible_waypoints[iterated_waypoint] = steps
	var/last_steps = 0
	for(var/wp in possible_waypoints)
		if(!found_next || last_steps > possible_waypoints[wp])
			found_next = wp
			last_steps = possible_waypoints[wp]

	return found_next

/datum/lift_route/proc/GetNearbyStop(turf/near_turf)
	var/datum/lift_waypoint/found
	var/last_dist
	for(var/i in stops)
		var/datum/lift_waypoint/iterated_stop = i
		if(iterated_stop.position.z != near_turf.z)
			continue
		if(!found || (get_dist(iterated_stop.position, near_turf) < last_dist))
			found = iterated_stop
			last_dist = get_dist(iterated_stop.position, near_turf)
	return found

#undef LIFT_PATHFINDING_MAX_STEPS
