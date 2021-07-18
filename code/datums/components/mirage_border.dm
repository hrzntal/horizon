/datum/component/mirage_border
	can_transfer = TRUE
	var/turf/target_turf
	var/obj/effect/abstract/mirage_holder/holder

/datum/component/mirage_border/Initialize(turf/target, direction, range=world.view)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	if(!target || !istype(target) || !direction)
		. = COMPONENT_INCOMPATIBLE
		CRASH("[type] improperly instanced with the following args: target=\[[target]\], direction=\[[direction]\], range=\[[range]\]")

	holder = new(parent)

	target_turf = target
	var/x = target.x
	var/y = target.y
	var/z = target.z
	var/turf/southwest = locate(clamp(x - (direction & WEST ? range : 0), 1, world.maxx), clamp(y - (direction & SOUTH ? range : 0), 1, world.maxy), clamp(z, 1, world.maxz))
	var/turf/northeast = locate(clamp(x + (direction & EAST ? range : 0), 1, world.maxx), clamp(y + (direction & NORTH ? range : 0), 1, world.maxy), clamp(z, 1, world.maxz))
	//holder.vis_contents += block(southwest, northeast) // This doesnt work because of beta bug memes
	for(var/i in block(southwest, northeast))
		holder.vis_contents += i
	if(direction & SOUTH)
		holder.pixel_y -= world.icon_size * range
	if(direction & WEST)
		holder.pixel_x -= world.icon_size * range

	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/on_entered)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/on_attack_ghost)

/datum/component/mirage_border/Destroy()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_GHOST, COMSIG_ATOM_ENTERED))
	QDEL_NULL(holder)
	return ..()

/datum/component/mirage_border/PreTransfer()
	holder.moveToNullspace()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_GHOST, COMSIG_ATOM_ENTERED))

/datum/component/mirage_border/PostTransfer()
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE
	target_turf = parent
	holder.forceMove(parent)
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/on_entered)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, .proc/on_attack_ghost)

/datum/component/mirage_border/proc/on_entered(atom/source, atom/movable/AM)
	SIGNAL_HANDLER
	var/turf/desired_turf = target_turf
	var/tx = desired_turf.x
	var/ty = desired_turf.y
	var/itercount = 0
	while(desired_turf.density || istype(desired_turf.loc,/area/shuttle)) // Extend towards the center of the map, trying to look for a better place to arrive
		if (itercount++ >= 100)
			log_game("SPACE Z-TRANSIT ERROR: Could not find a safe place to land [AM] within 100 iterations.")
			break
		if (tx < 128)
			tx++
		else
			tx--
		if (ty < 128)
			ty++
		else
			ty--
		desired_turf = locate(tx, ty, desired_turf.z)

	AM.forceMove(desired_turf)
	var/atom/movable/pulling = AM.pulling
	var/atom/movable/puller = AM

	while(pulling != null)
		var/next_pulling = pulling.pulling

		var/turf/T = get_step(puller.loc, turn(puller.dir, 180))
		pulling.can_be_z_moved = FALSE
		pulling.forceMove(T)
		puller.start_pulling(pulling)
		pulling.can_be_z_moved = TRUE

		puller = pulling
		pulling = next_pulling

	AM.newtonian_move(AM.inertia_dir)
	AM.inertia_moving = TRUE

/datum/component/mirage_border/proc/on_attack_ghost(datum/source, mob/dead/observer/ghost)
	SIGNAL_HANDLER
	ghost.forceMove(target_turf)

/obj/effect/abstract/mirage_holder
	name = "Mirage holder"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
