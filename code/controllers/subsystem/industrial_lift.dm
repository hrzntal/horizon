SUBSYSTEM_DEF(industrial_lift)
	name = "Industrial Lifts"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 0.5 SECONDS
	var/list/lift_controllers = list()
	var/list/lift_routes = list()
	var/list/lift_waypoints = list()

/datum/controller/subsystem/industrial_lift/Initialize()
	for(var/i in lift_controllers)
		var/datum/lift_controller/controller = lift_controllers[i]
		controller.InitializeLift()
	for(var/i in lift_waypoints)
		var/datum/lift_waypoint/waypoint = lift_waypoints[i]
		waypoint.InitializeWaypoint()
	return ..()

/datum/controller/subsystem/industrial_lift/fire(resumed = FALSE)
	for(var/i in lift_controllers)
		var/datum/lift_controller/controller = lift_controllers[i]
		controller.process()
