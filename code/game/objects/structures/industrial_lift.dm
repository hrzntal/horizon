/obj/structure/industrial_lift
	name = "lift platform"
	desc = "A lightweight lift platform. It moves up and down."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	move_resist = INFINITY
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 50)
	max_integrity = 100
	layer = CATWALK_LAYER
	plane = FLOOR_PLANE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	canSmoothWith = list(SMOOTH_GROUP_INDUSTRIAL_LIFT)
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN
	var/id
	var/lift_controller_type = /datum/lift_controller
	var/datum/lift_controller/lift_controller

/obj/structure/industrial_lift/Initialize()
	AddElement(/datum/element/footstep_override, FOOTSTEP_LATTICE, FOOTSTEP_HARD_BAREFOOT, FOOTSTEP_LATTICE, FOOTSTEP_LATTICE)
	if(!id || lift_controller)
		return ..()
	new lift_controller_type(src)
	return ..()

/obj/structure/industrial_lift/proc/PreLiftMove(move_dir)
	return FALSE

/obj/structure/industrial_lift/proc/LiftMove(move_dir)
	var/turf/step_turf = get_step_multiz(loc, move_dir)
	forceMove(step_turf)

/obj/structure/industrial_lift/Destroy()
	if(lift_controller)
		lift_controller.lift_platforms -= src
	return ..()

/obj/item/assembly/control/elevator
	name = "elevator controller"
	desc = "A small device used to call elevators to the current floor."

/obj/machinery/button/elevator
	name = "elevator button"
	desc = "Go back. Go back. Go back. Can you operate the elevator."
	icon_state = "launcher"
	skin = "launcher"

/obj/structure/lift_control_panel
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	base_icon_state = "access_button"
	name = "lift control panel"
	density = FALSE
	anchored = TRUE
	move_resist = INFINITY
	var/datum/lift_controller/linked_controller

/obj/structure/lift_control_panel/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/lift_control_panel/LateInitialize()
	TryLink()

/obj/structure/lift_control_panel/proc/TryLink()
	var/obj/structure/industrial_lift/lift = locate() in loc
	if(lift)
		linked_controller = lift.lift_controller

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
		dat += "<BR><a href='?src=[REF(src)];task=click_waypoint;wp_id=[stop_wp.waypoint_id]' [queued_stops[stop_wp] ? "class='linkOn'" : ""]>[stop_wp.name]</a>"
	dat += "<BR><a href='?src=[REF(src)];task=click_stop' [linked_controller.intentionally_halted ? "class='linkOn'" : ""]>STOP</a>"
	dat += "</center>"
	var/datum/browser/popup = new(user, "lift_control_panel", name, 300, 200)
	popup.set_content(dat.Join())
	popup.open()

/obj/structure/lift_control_panel/Topic(href, href_list)
	var/mob/user = usr
	if(!linked_controller || !isliving(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	switch(href_list["task"])
		if("click_waypoint")
			var/datum/lift_waypoint/clicked_wp = SSindustrial_lift.lift_waypoints[href_list["wp_id"]]
			if(clicked_wp)
				linked_controller.CallWaypoint(clicked_wp)
		if("click_stop")
			linked_controller.ToggleIntentionalHalt()
	ui_interact(usr)
