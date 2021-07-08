/obj/item/pipe_casing
	desc = "A crudely assembled casing that resembles a pipe."
	icon = 'icons/obj/items/pipe_casing.dmi'
	/// Type of our pipe fitting to spawn
	var/pipe_fitting
	/// When deconstructed with a wrench, how much metal does it drop
	var/metal_dropped = 1

/obj/item/pipe_casing/ComponentInitialize()
	///Can be rotated, and that rotation will affect the spawned fitting, yay
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE)

/obj/item/pipe_casing/Move()
	var/old_dir = dir
	..()
	setDir(old_dir) //Prevent direction changes on moving

/obj/item/pipe_casing/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return
	. = TRUE
	if(!tool.tool_start_check(user, amount = 0))
		return
	to_chat(user, "<span class='notice'>You start shaping \the [src] into a fitting...</span>")
	if(tool.use_tool(src, user, 20))
		to_chat(user, "<span class='notice'>You shape \the [src] into a fitting.</span>")
		validate_direction()
		new pipe_fitting(get_turf(src), null, dir)
		qdel(src)

/obj/item/pipe_casing/proc/validate_direction()
	return

/obj/item/pipe_casing/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(.)
		return
	. = TRUE
	to_chat(user, "<span class='notice'>You disassemble \the [src].</span>")
	tool.play_tool_sound(src)
	new /obj/item/stack/sheet/iron(get_turf(src), metal_dropped)
	qdel(src)

/obj/item/pipe_casing/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It can be <b>welded</b> into a fitting.</span>"
	. += "<span class='notice'>It can be disassembled with a <b>wrench</b>.</span>"

/obj/item/pipe_casing/straight_pipe
	name = "straight pipe casing"
	icon_state = "straight_pipe"
	pipe_fitting = /obj/item/pipe/binary/pipe_simple

/obj/item/pipe_casing/bent_pipe
	name = "bent pipe casing"
	icon_state = "bent_pipe"
	pipe_fitting = /obj/item/pipe/binary/bendable/pipe_bent

//The crafting systems sets our direction after initialize so we cant have diagonals easily, so we just adjust it before building the pipe
/obj/item/pipe_casing/bent_pipe/validate_direction()
	switch(dir)
		if(NORTH)
			dir |= EAST
		if(SOUTH)
			dir |= WEST
		if(EAST)
			dir |= SOUTH
		if(WEST)
			dir |= NORTH

/obj/item/pipe_casing/manifold
	name = "manifold casing"
	icon_state = "manifold"
	pipe_fitting = /obj/item/pipe/trinary/pipe_manifold

/obj/item/pipe_casing/manifold4w
	name = "4-way manifold casing"
	icon_state = "manifold4w"
	pipe_fitting = /obj/item/pipe/quaternary/pipe_manifold4w

/obj/item/pipe_casing/connector
	name = "portable connector casing"
	icon_state = "connector"
	pipe_fitting = /obj/item/pipe/directional/connector

/obj/item/pipe_casing/layer_manifold
	name = "layer adapter casing"
	icon_state = "layer_manifold"
	pipe_fitting = /obj/item/pipe/binary/layer_manifold
