/datum/overmap_shuttle_controller
	var/mob/living/mob_controller

	var/datum/overmap_object/shuttle/overmap_obj

	var/datum/action/innate/quit_control/quit_control_button
	var/datum/action/innate/stop_shuttle/stop_shuttle_button
	var/datum/action/innate/try_dock/try_dock_button
	var/datum/action/innate/open_shuttle_control/shuttle_control_button
	var/busy = FALSE

	var/datum/shuttle_freeform_docker/freeform_docker

/datum/overmap_shuttle_controller/proc/ShuttleMovedOnOvermap()
	if(mob_controller)
		mob_controller.update_parallax_contents()

/datum/overmap_shuttle_controller/New(datum/overmap_object/shuttle/passed_ov_obj)
	overmap_obj = passed_ov_obj
	quit_control_button = new
	quit_control_button.target = src
	stop_shuttle_button = new
	stop_shuttle_button.target = src
	try_dock_button = new
	try_dock_button.target = src
	shuttle_control_button = new
	shuttle_control_button.target = src

/datum/overmap_shuttle_controller/proc/SetController(mob/living/our_guy)
	if(mob_controller)
		RemoveCurrentControl()
	AddControl(our_guy)

/datum/overmap_shuttle_controller/proc/AddControl(mob/living/our_guy)
	mob_controller = our_guy
	RegisterSignal(mob_controller, COMSIG_CLICKON, .proc/ControllerClick)
	mob_controller.client.perspective = EYE_PERSPECTIVE
	mob_controller.client.eye = overmap_obj.my_visual
	mob_controller.client.show_popup_menus = FALSE
	mob_controller.remote_control = overmap_obj.my_visual
	mob_controller.update_parallax_contents()
	quit_control_button.Grant(mob_controller)
	try_dock_button.Grant(mob_controller)
	stop_shuttle_button.Grant(mob_controller)
	shuttle_control_button.Grant(mob_controller)


/datum/overmap_shuttle_controller/proc/RemoveCurrentControl(removing_overmap = FALSE)
	if(freeform_docker)
		AbortFreeform(removing_overmap)
	UnregisterSignal(mob_controller, COMSIG_CLICKON)
	mob_controller.client.perspective = MOB_PERSPECTIVE
	mob_controller.client.eye = mob_controller
	mob_controller.client.show_popup_menus = TRUE
	quit_control_button.Remove(mob_controller)
	try_dock_button.Remove(mob_controller)
	stop_shuttle_button.Remove(mob_controller)
	shuttle_control_button.Remove(mob_controller)
	playsound(mob_controller, 'sound/machines/terminal_off.ogg', 25, FALSE)
	mob_controller.remote_control = null
	mob_controller.update_parallax_contents()
	mob_controller = null
	if(removing_overmap)
		QDEL_NULL(overmap_obj)

/datum/overmap_shuttle_controller/proc/AbortFreeform(removing_overmap)
	if(!freeform_docker)
		return
	freeform_docker.remove_eye_control()
	qdel(freeform_docker)
	if(!removing_overmap)
		mob_controller.client.perspective = EYE_PERSPECTIVE
		mob_controller.client.eye = overmap_obj.my_visual
		mob_controller.update_parallax_contents()
		mob_controller.remote_control = overmap_obj.my_visual

/datum/overmap_shuttle_controller/proc/ControllerClick(datum/source, atom/A, params)
	SIGNAL_HANDLER
	if(A.z != overmap_obj.current_system.z_level)
		return
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(source)
		return COMSIG_CANCEL_CLICKON
	if(modifiers["right"])
		overmap_obj.CommandMove(A.x,A.y)
		return COMSIG_CANCEL_CLICKON
	/*
	//shuttle.overmap_obj.CommandMove(A.x,A.y)
	if(istype(A,/obj/effect/abstract/overmap))
		var/obj/effect/abstract/overmap/vis_obj = A
		var/datum/overmap_object/OM = vis_obj.overmap_obj
		if(OM == shuttle.overmap_obj)
			shuttle.overmap_obj.AbortLock()
		else if (OM.interact_flags & OMI_LOCKABLE)
			shuttle.overmap_obj.SetLockTo(OM)
		return COMSIG_CANCEL_CLICKON
	*/
	return COMSIG_CANCEL_CLICKON

/datum/action/innate/try_dock
	name = "Try Dock"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/try_dock/Trigger()
	var/datum/overmap_shuttle_controller/OSC = target
	if(OSC.freeform_docker) //We're in the middle of freeform docking
		return
	var/datum/overmap_object/shuttle/OO = OSC.overmap_obj
	if(OO.is_seperate_z_level)
		return
	var/list/z_levels = list()
	var/list/nearby_objects = OO.current_system.GetObjectsInRadius(OO.x,OO.y,1)
	var/list/freeform_z_levels = list()
	for(var/i in nearby_objects)
		var/datum/overmap_object/IO = i
		for(var/level in IO.related_levels)
			var/datum/space_level/iterated_space_level = level
			z_levels["[iterated_space_level.z_value]"] = TRUE
			freeform_z_levels["[iterated_space_level.name] - Freeform"] = iterated_space_level.z_value

	var/list/docks = list()
	var/list/options = params2list(OSC.overmap_obj.my_shuttle.possible_destinations)
	for(var/i in SSshuttle.stationary)
		var/obj/docking_port/stationary/iterated_dock = i
		if(z_levels["[iterated_dock.z]"] && (iterated_dock.id in options))
			docks[iterated_dock.name] = iterated_dock

	var/choice = input(usr, "Where shall you dock?", "Shuttle Docking") as null|anything in docks+freeform_z_levels
	if(!choice)
		return
	if(freeform_z_levels[choice])
		var/z_level = freeform_z_levels[choice]
		OSC.freeform_docker = new /datum/shuttle_freeform_docker(OSC, usr, z_level)
		return
	var/obj/docking_port/stationary/chosen_dock = docks[choice]

	switch(SSshuttle.moveShuttle(OSC.overmap_obj.my_shuttle.id, chosen_dock.id, 1))
		if(0)
			OSC.busy = TRUE
			OSC.RemoveCurrentControl(TRUE)
			return TRUE
		/*
		if(1)
			message_admins("we didnt do it")
		else
			message_admins("error")
		*/

/datum/action/innate/quit_control
	name = "Quit Control"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/quit_control/Trigger()
	var/datum/overmap_shuttle_controller/OSC = target
	OSC.RemoveCurrentControl()

/datum/action/innate/stop_shuttle
	name = "Stop Shuttle"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/stop_shuttle/Trigger()
	var/datum/overmap_shuttle_controller/OSC = target
	OSC.overmap_obj.StopMove()

/datum/action/innate/open_shuttle_control
	name = "Shuttle Controls"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/open_shuttle_control/Trigger()
	var/datum/overmap_shuttle_controller/OSC = target
	OSC.overmap_obj.DisplayUI(OSC.mob_controller)
