/datum/transit_instance
	var/datum/turf_reservation/reservation
	var/obj/docking_port/stationary/transit/dock
	var/datum/overmap_object/shuttle/overmap_shuttle
	//Associative for easy lookup
	var/list/affected_movables = list()

/datum/transit_instance/New(datum/turf_reservation/arg_reservation, obj/docking_port/stationary/transit/arg_dock)
	. = ..()
	reservation = arg_reservation
	dock = arg_dock
	dock.transit_instance = src
	SSshuttle.transit_instances += src

/datum/transit_instance/Destroy()
	SSshuttle.transit_instances -= src
	reservation = null
	dock = null
	overmap_shuttle = null
	return ..()
