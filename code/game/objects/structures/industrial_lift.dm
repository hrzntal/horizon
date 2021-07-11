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
	var/list/lift_load

/obj/structure/industrial_lift/Initialize()
	AddElement(/datum/element/footstep_override, FOOTSTEP_LATTICE, FOOTSTEP_HARD_BAREFOOT, FOOTSTEP_LATTICE, FOOTSTEP_LATTICE)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED =.proc/UncrossedRemoveItemFromLift,
		COMSIG_ATOM_ENTERED = .proc/AddItemOnLift,
		COMSIG_ATOM_CREATED = .proc/AddItemOnLift,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)
	if(!id || lift_controller)
		return ..()
	new lift_controller_type(src)
	return ..()

/obj/structure/industrial_lift/proc/UncrossedRemoveItemFromLift(datum/source, atom/movable/potential_rider)
	SIGNAL_HANDLER
	RemoveItemFromLift(potential_rider)

/obj/structure/industrial_lift/proc/RemoveItemFromLift(atom/movable/potential_rider)
	SIGNAL_HANDLER
	if(!lift_load || !lift_load[potential_rider])
		return
	lift_load -= potential_rider
	UnregisterSignal(potential_rider, COMSIG_PARENT_QDELETING)
	UNSETEMPTY(lift_load)

/obj/structure/industrial_lift/proc/AddItemOnLift(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	//TODO: Add a static typelist cache / or on subsystem level
	if(AM == src || istype(AM, /obj/structure/industrial_lift) || istype(AM, /obj/structure/fluff/tram_rail) || AM.invisibility == INVISIBILITY_ABSTRACT)
		return
	LAZYINITLIST(lift_load)
	if(lift_load[AM])
		return
	lift_load[AM] = TRUE
	RegisterSignal(AM, COMSIG_PARENT_QDELETING, .proc/RemoveItemFromLift)

//ACTUAL movement happens in the controller
//Collisions happen here, before the lift is moved (because it may not be moved, depending on collisions / safeties)
/obj/structure/industrial_lift/proc/PreLiftMove(move_dir, safeties)
	var/turf/step_turf = get_step_multiz(loc, move_dir)
	if(move_dir == UP || lift_controller.InLiftBounds(step_turf)) //Dont check collisions inside the lift bounds
		return
	if(move_dir == DOWN && !isopenspaceturf(loc))
		return LIFT_HIT_BLOCK
	if(isclosedturf(step_turf))
		return LIFT_HIT_BLOCK
	var/returned_bitfield = NONE
	for(var/mob/living/collided in step_turf)
		returned_bitfield |= LIFT_HIT_MOB
		shake_camera(collided, 3, 1)
		if(move_dir == DOWN)
			returned_bitfield |= LIFT_CRUSH_MOB
			to_chat(collided, SPAN_USERDANGER("You are crushed by \the [src]!"))
			if(safeties)
				collided.Paralyze(10 SECONDS)
				collided.adjustBruteLoss(80)
			else
				collided.gib(FALSE,FALSE,FALSE)//the nicest kind of gibbing, keeping everything intact.
		else
			var/turf/two_step_turf = get_step(step_turf, move_dir) //We know its not multi-z now
			var/crushing = isclosedturf(two_step_turf) ? TRUE : FALSE
			if(crushing)
				returned_bitfield |= LIFT_CRUSH_MOB
				to_chat(collided, SPAN_USERDANGER("\The [src] crushes you against \the [two_step_turf]!"))
				if(safeties)
					collided.Paralyze(10 SECONDS)
					collided.adjustBruteLoss(80)
				else
					collided.gib(FALSE,FALSE,FALSE)//the nicest kind of gibbing, keeping everything intact.
			else
				to_chat(collided, SPAN_USERDANGER("[src] slams into you and sends you flying!"))
				collided.Paralyze(5 SECONDS)
				collided.adjustBruteLoss(40)
				var/atom/throw_target = get_edge_target_turf(collided, turn(move_dir, pick(45, -45)))
				collided.throw_at(throw_target, 200, 4)

	return returned_bitfield

/obj/structure/industrial_lift/Destroy()
	if(lift_controller)
		lift_controller.lift_platforms -= src
	return ..()

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
	playsound(my_turf, 'sound/lifts/elevator_ding.ogg', 100)
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

/obj/structure/industrial_lift/tram
	name = "tram"
	desc = "A tram for traversing the station."
	icon = 'icons/turf/floors.dmi'
	icon_state = "titanium_yellow"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	//kind of a centerpiece of the station, so pretty tough to destroy
	armor = list(MELEE = 80, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 100, BIO = 80, RAD = 80, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	lift_controller_type = /datum/lift_controller/tram

//Unless I get more specifications it's just almost cardboard copy of the tram floor
/obj/structure/industrial_lift/elevator
	name = "elevator floor"
	desc = "Floor of an elevator."
	icon = 'icons/turf/floors.dmi'
	icon_state = "titanium_yellow"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	armor = list(MELEE = 80, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 100, BIO = 80, RAD = 80, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	lift_controller_type = /datum/lift_controller/elevator

/obj/machinery/lift_status_display
	name = "status display"
	desc = "A status display."
	icon = 'icons/obj/machines/lift_status_display.dmi'
	icon_state = "frame"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	layer = ABOVE_WINDOW_LAYER
	var/id
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
