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
	var/obj/structure/industrial_lift/roof/managed_roof
	var/static/list/type_blacklist

/obj/structure/industrial_lift/Initialize()
	if(!type_blacklist)
		InitializeBlacklist()
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

/obj/structure/industrial_lift/proc/InitializeBlacklist()
	type_blacklist = list()
	for(var/mastertype in INDUSTRIAL_LIFT_BLACKLISTED_TYPESOF)
		for(var/undertype in typesof(mastertype))
			type_blacklist[undertype] = TRUE

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
	if(AM == src || type_blacklist[AM.type] || AM.invisibility == INVISIBILITY_ABSTRACT)
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
	if(lift_controller.InLiftBounds(step_turf)) //Dont check collisions inside the lift bounds
		return
	if(move_dir == UP && !isopenspaceturf(step_turf))
		return LIFT_HIT_BLOCK
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
	icon_state = "titanium_blue"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	armor = list(MELEE = 80, BULLET = 80, LASER = 80, ENERGY = 80, BOMB = 100, BIO = 80, RAD = 80, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	lift_controller_type = /datum/lift_controller/elevator

/obj/structure/industrial_lift/roof
	name = "industrial lift roof"
	desc = "A roof of an industrial lift"
	lift_controller_type = null

/obj/structure/industrial_lift/roof/PreLiftMove(move_dir, safeties)
	if(move_dir == DOWN)
		return
	//Note: lift floors check blocked ways in the UP direction, and it should stay that way

