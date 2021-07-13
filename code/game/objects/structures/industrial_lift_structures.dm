/obj/machinery/lift_status_display
	name = "status display"
	desc = "A status display."
	icon = 'icons/obj/machines/lift_status_display.dmi'
	icon_state = "frame"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	layer = ABOVE_WINDOW_LAYER
	/// Id of the lift controller we connect to
	var/id
	/// Our text display icon, "display_blue" and "display_red" exist
	var/display_icon = "display_blue"

/obj/machinery/lift_status_display/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/lift_status_display/examine()
	. = ..()
	var/datum/lift_controller/controller = SSindustrial_lift.lift_controllers[id]
	if(!controller)
		. += SPAN_WARNING("The display is showing an error")
		return
	. += controller.GetStatusInfo()

/obj/machinery/lift_status_display/LateInitialize()
	var/datum/lift_controller/controller = SSindustrial_lift.lift_controllers[id]
	if(!controller)
		return
	name = "[controller.name] status display"
	desc = "A status display for the [controller.name]."
	update_icon()

/obj/machinery/lift_status_display/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return
	. += mutable_appearance(icon, display_icon)
	. += emissive_appearance(icon, display_icon)


/obj/item/assembly/control/elevator
	name = "elevator controller"
	desc = "A small device used to call elevators to the current floor."
	var/has_speaker = FALSE

/obj/item/assembly/control/elevator/activate()
	if(cooldown)
		return
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 2 SECONDS)
	if(!id)
		return
	var/datum/lift_controller/controller = SSindustrial_lift.lift_controllers[id]
	if(!controller)
		return
	var/turf/my_turf = get_turf(src)
	var/datum/lift_waypoint/stop_wp = controller.route.GetNearbyStop(my_turf)
	if(!stop_wp)
		return
	if(controller.called_waypoints[stop_wp])
		if(has_speaker)
			say("The [controller.name] is already called to this location.")
		return
	if(!controller.destination_wp && controller.current_wp == stop_wp)
		if(has_speaker)
			say("The [controller.name] is already here. Please board the [controller.name] and select a destination.")
		return
	playsound(my_turf, 'sound/lifts/elevator_ding.ogg', 60)
	if(has_speaker)
		say("The [controller.name] has been called to [stop_wp.name]. Please wait for its arrival.")
	controller.CallWaypoint(stop_wp)

/obj/item/assembly/control/elevator/speaker
	has_speaker = TRUE

/obj/machinery/button/elevator
	name = "elevator button"
	desc = "Go back. Go back. Go back. Can you operate the elevator."
	icon_state = "launcher"
	skin = "launcher"
	device_type = /obj/item/assembly/control/elevator

/obj/machinery/button/elevator/speaker
	device_type = /obj/item/assembly/control/elevator/speaker

/obj/structure/lift_control_panel
	icon = 'icons/obj/structures/elevator_control.dmi'
	icon_state = "elevator_control"
	name = "control panel"
	density = FALSE
	anchored = TRUE
	move_resist = INFINITY
	layer = ABOVE_WINDOW_LAYER
	/// Linked lift, we automatically link to this on LateInit, no need to input ID
	var/datum/lift_controller/linked_controller
	/// In any case of wanting an external controller (it being outside of the lift), you can input the ID
	var/id

/obj/structure/lift_control_panel/non_directional
	icon_state = "elevator_control_nondir"

/obj/structure/lift_control_panel/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/lift_control_panel/LateInitialize()
	TryLink()

/obj/structure/lift_control_panel/proc/TryLink()
	if(id)
		linked_controller = SSindustrial_lift.lift_controllers[id]
	else
		var/obj/structure/industrial_lift/lift = locate() in loc
		if(lift)
			linked_controller = lift.lift_controller
	if(linked_controller)
		name = "[linked_controller.name] control panel"
		desc = "A panel which interfaces with \the [linked_controller.name] controls."

/obj/structure/lift_control_panel/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!linked_controller)
		TryLink()
	var/list/stop_waypoints = linked_controller.route.stops
	var/list/queued_stops = linked_controller.called_waypoints
	var/list/dat = list()
	dat += "<center>"
	for(var/i in stop_waypoints)
		var/datum/lift_waypoint/stop_wp = i
		dat += "<a href='?src=[REF(src)];task=click_waypoint;wp_id=[stop_wp.waypoint_id]' [queued_stops[stop_wp] ? "class='linkOn'" : ""]>[stop_wp.name]</a><BR>"
	dat += "<a href='?src=[REF(src)];task=click_stop' [linked_controller.intentionally_halted ? "class='linkOn'" : ""]>STOP</a>"
	dat += "<BR><BR><a href='?src=[REF(src)];task=click_reverse' >EMERGENCY REVERSE</a>"
	dat += "</center>"
	var/datum/browser/popup = new(user, "lift_control_panel", "control panel", 180, 200)
	popup.set_content(dat.Join())
	popup.open()

/obj/structure/lift_control_panel/Topic(href, href_list)
	var/mob/user = usr
	if(!linked_controller || !isliving(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(!href_list["task"])
		return
	switch(href_list["task"])
		if("click_waypoint")
			var/datum/lift_waypoint/clicked_wp = SSindustrial_lift.lift_waypoints[href_list["wp_id"]]
			if(clicked_wp)
				linked_controller.CallWaypoint(clicked_wp)
				user.visible_message(SPAN_NOTICE("[user] presses on \the [src] button."), SPAN_NOTICE("You press on the [clicked_wp.name] button."))
		if("click_stop")
			linked_controller.ToggleIntentionalHalt()
			user.visible_message(SPAN_NOTICE("[user] presses on \the [src] button."), SPAN_WARNING("You press on STOP button!"))
		if("click_reverse")
			linked_controller.EmergencyRouteReversal()
			user.visible_message(SPAN_NOTICE("[user] presses on \the [src] button."), SPAN_WARNING("You press on EMERGENCY REVERSE button!"))
	playsound(src, get_sfx("terminal_type"), 50)
	ui_interact(usr)
