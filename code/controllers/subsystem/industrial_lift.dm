SUBSYSTEM_DEF(industrial_lift)
	name = "Industrial Lifts"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = SS_LIFTS_TICK_RATE
	/// All lift controllers associative by ID
	var/list/lift_controllers = list()
	/// All lift routes associative by ID
	var/list/lift_routes = list()
	/// All lift waypoints associative by waypoint ID
	var/list/lift_waypoints = list()

	/// Lift controllers to initialize
	var/list/lift_controllers_to_init
	/// Lift waypoints to initialize
	var/list/lift_waypoints_to_init
	/// Whether do we need to call initializations
	var/needs_init = TRUE

/datum/controller/subsystem/industrial_lift/Initialize()
	InitializeLiftObjects()
	return ..()

/datum/controller/subsystem/industrial_lift/fire(resumed = FALSE)
	if(needs_init)
		InitializeLiftObjects()
	for(var/i in lift_controllers)
		var/datum/lift_controller/controller = lift_controllers[i]
		controller.process()

/datum/controller/subsystem/industrial_lift/proc/InitializeLiftObjects()
	for(var/i in lift_controllers_to_init)
		var/datum/lift_controller/controller = i
		controller.InitializeLift()
	lift_controllers_to_init = null
	for(var/i in lift_waypoints_to_init)
		var/datum/lift_waypoint/waypoint = i
		waypoint.InitializeWaypoint()
	lift_waypoints_to_init = null
	needs_init = FALSE

/datum/controller/subsystem/industrial_lift/proc/AddControllerToInit(datum/lift_controller/passed_controller)
	LAZYINITLIST(lift_controllers_to_init)
	lift_controllers_to_init += passed_controller
	needs_init = TRUE

/datum/controller/subsystem/industrial_lift/proc/AddWaypointToInit(datum/lift_waypoint/passed_waypoint)
	LAZYINITLIST(lift_waypoints_to_init)
	lift_waypoints_to_init += passed_waypoint
	needs_init = TRUE
