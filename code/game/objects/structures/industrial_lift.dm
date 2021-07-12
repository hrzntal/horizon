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
	/// ID of the lift controller this will create
	var/id
	/// Type of the lift controller this will create
	var/lift_controller_type = /datum/lift_controller
	/// Reference to our lift controller
	var/datum/lift_controller/lift_controller
	/// All the atoms this lift is managing
	var/list/lift_load
	/// The turf of this lift platform, managed by the controller
	var/obj/structure/industrial_lift/roof/managed_roof
	/// List of all blacklisted types, to prevent unwanted stuff from moved
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
	if(potential_rider.loc == loc) //We move the lift, THEN the things back on the lift, don't remove our items
		return
	if(!lift_load || !lift_load[potential_rider])
		return
	lift_load -= potential_rider
	UnregisterSignal(potential_rider, COMSIG_PARENT_QDELETING)
	UNSETEMPTY(lift_load)

/obj/structure/industrial_lift/proc/AddItemOnLift(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(lift_load && lift_load[AM])
		return
	if(type_blacklist[AM.type] || AM.invisibility == INVISIBILITY_ABSTRACT)
		return
	LAZYINITLIST(lift_load)
	lift_load[AM] = TRUE
	RegisterSignal(AM, COMSIG_PARENT_QDELETING, .proc/RemoveItemFromLift)

/obj/structure/industrial_lift/proc/RemoveAllItemsFromLift()
	if(!lift_load)
		return
	for(var/i in lift_load)
		var/atom/movable/movable_atom = i
		UnregisterSignal(movable_atom, COMSIG_PARENT_QDELETING)
	lift_load = null

/obj/structure/industrial_lift/proc/CrushMob(mob/living/crushed, safeties)
	if(safeties && crushed.getBruteLoss() <= 200)
		crushed.Paralyze(10 SECONDS)
		crushed.adjustBruteLoss(80)
	else
		crushed.gib(FALSE,FALSE,FALSE)//the nicest kind of gibbing, keeping everything intact.

//ACTUAL movement happens in the controller
//Collisions happen here, before the lift is moved (because it may not be moved, depending on collisions / safeties)
/obj/structure/industrial_lift/proc/PreLiftMove(move_dir, safeties)
	var/turf/step_turf = get_step_multiz(loc, move_dir)
	if(lift_controller.InLiftBounds(step_turf)) //Dont check collisions inside the lift bounds
		return
	if(move_dir == DOWN && !isopenspaceturf(loc))
		return LIFT_HIT_BLOCK
	if(isclosedturf(step_turf))
		return LIFT_HIT_BLOCK
	var/returned_bitfield = NONE
	//Collision UP movements are an odd case, because it both crushes and blocks the lift
	var/collision_up_movement = FALSE
	if(!managed_roof && move_dir == UP && !isopenspaceturf(step_turf))
		collision_up_movement = TRUE
		returned_bitfield |= LIFT_HIT_BLOCK
	for(var/mob/living/collided in step_turf)
		returned_bitfield |= LIFT_HIT_MOB
		shake_camera(collided, 3, 1)
		if(collision_up_movement)
			returned_bitfield |= LIFT_CRUSH_MOB
			to_chat(collided, SPAN_USERDANGER("You are crushed by \the [src] against the ceiling!"))
			CrushMob(collided, safeties)
		else if(move_dir == DOWN)
			returned_bitfield |= LIFT_CRUSH_MOB
			to_chat(collided, SPAN_USERDANGER("You are crushed by \the [src]!"))
			CrushMob(collided, safeties)
		else if(move_dir != UP)
			var/turf/two_step_turf = get_step(step_turf, move_dir) //We know its not multi-z now
			var/crushing = isclosedturf(two_step_turf) ? TRUE : FALSE
			if(crushing)
				returned_bitfield |= LIFT_CRUSH_MOB
				to_chat(collided, SPAN_USERDANGER("\The [src] crushes you against \the [two_step_turf]!"))
				CrushMob(collided, safeties)
			else
				to_chat(collided, SPAN_USERDANGER("[src] slams into you and sends you flying!"))
				collided.Paralyze(5 SECONDS)
				collided.adjustBruteLoss(40)
				var/atom/throw_target = get_edge_target_turf(collided, turn(move_dir, pick(45, -45)))
				collided.throw_at(throw_target, 100, 3)

	return returned_bitfield

/obj/structure/industrial_lift/Destroy()
	if(managed_roof)
		QDEL_NULL(managed_roof)
	if(lift_controller)
		lift_controller.lift_platforms -= src
	RemoveAllItemsFromLift()
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

//DO NOT MAP THOSE IN ABOVE YOUR LIFT, USE THE PROPER CONTROLLER TYPE WITH THE ROOFS(make new one if you need to), IT HANDLES THAT
/obj/structure/industrial_lift/roof
	name = "industrial lift roof"
	desc = "A roof of an industrial lift"
	lift_controller_type = null
	plane = FLOOR_PLANE
	layer = ROOF_LAYER

/obj/structure/industrial_lift/roof/PreLiftMove(move_dir, safeties)
	if(move_dir == DOWN)
		return
	if(!isopenspaceturf(loc)) //Lift roof going under a turf
		return
	var/turf/step_turf = get_step_multiz(loc, move_dir)
	var/returned_bitfield = NONE
	for(var/mob/living/collided in loc)
		if(move_dir == UP && (!step_turf || !isopenspaceturf(step_turf))) //Step turf could not exist if going up, we treat it as ceiling
			returned_bitfield |= LIFT_HIT_MOB
			returned_bitfield |= LIFT_CRUSH_MOB
			to_chat(collided, SPAN_USERDANGER("You are crushed by \the [src] against the ceiling!"))
			CrushMob(collided, safeties)
		else if(move_dir != UP && isclosedturf(step_turf)) //Just cardinal directions here
			returned_bitfield |= LIFT_HIT_MOB
			to_chat(collided, SPAN_USERDANGER("[step_turf] slams into you and sends you flying!"))
			collided.Paralyze(5 SECONDS)
			collided.adjustBruteLoss(40)
			var/atom/throw_target = get_edge_target_turf(collided, turn(REVERSE_DIR(move_dir), pick(45, -45)))
			collided.throw_at(throw_target, 100, 3)
	return returned_bitfield
