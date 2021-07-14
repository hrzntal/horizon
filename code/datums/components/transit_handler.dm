/datum/component/transit_handler
	/// Our transit instance
	var/datum/transit_instance/transit_instance

/datum/component/transit_handler/Initialize(datum/transit_instance/transit_instance_)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	transit_instance = transit_instance_
	transit_instance.affected_movables[parent] = TRUE

/datum/component/transit_handler/Destroy()
	transit_instance.affected_movables -= parent
	return ..()
