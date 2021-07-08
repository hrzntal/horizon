/obj/machinery/atmospherics/pipe
	damage_deflection = 12
	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/volume = 0

	use_power = NO_POWER_USE
	can_unwrench = 1
	var/datum/pipeline/parent = null

	paintable = TRUE

	//Buckling
	can_buckle = TRUE
	buckle_requires_restraints = TRUE
	buckle_lying = NO_BUCKLE_LYING

	vis_flags = VIS_INHERIT_PLANE

/obj/machinery/atmospherics/pipe/New(loc, process = TRUE, setdir, init_dir = ALL_CARDINALS, arg_pipe_layer, arg_pipe_color, arg_hide)
	if(!isnull(arg_pipe_layer))
		piping_layer = arg_pipe_layer

	if(!isnull(arg_pipe_color))
		pipe_color = arg_pipe_color

	if(!isnull(arg_hide))
		hide = arg_hide
	add_atom_colour(pipe_color, FIXED_COLOUR_PRIORITY)
	volume = 35 * device_type
	..()

///I have no idea why there's a new and at this point I'm too afraid to ask
/obj/machinery/atmospherics/pipe/Initialize()
	. = ..()
	if(hide)
		AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE) //if changing this, change the subtypes RemoveElements too, because thats how bespoke works

/obj/machinery/atmospherics/pipe/nullifyNode(i)
	var/obj/machinery/atmospherics/oldN = nodes[i]
	..()
	if(oldN)
		SSair.add_to_rebuild_queue(oldN)

/obj/machinery/atmospherics/pipe/destroy_network()
	QDEL_NULL(parent)

/obj/machinery/atmospherics/pipe/get_rebuild_targets()
	if(!QDELETED(parent))
		return
	parent = new
	return list(parent)

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)

/obj/machinery/atmospherics/pipe/return_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/return_analyzable_air()
	if(air_temporary)
		return air_temporary
	return parent.air

/obj/machinery/atmospherics/pipe/remove_air(amount)
	if(air_temporary)
		return air_temporary.remove(amount)
	return parent.air.remove(amount)

/obj/machinery/atmospherics/pipe/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe_meter))
		var/obj/item/pipe_meter/meter = W
		user.dropItemToGround(meter)
		meter.setAttachLayer(piping_layer)
	else
		return ..()

/obj/machinery/atmospherics/pipe/returnPipenet()
	return parent

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/obj/machinery/atmospherics/pipe/Destroy()
	QDEL_NULL(parent)

	releaseAirToTurf()
	QDEL_NULL(air_temporary)

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)
	. = ..()

/obj/machinery/atmospherics/pipe/proc/update_pipe_icon()
	icon = 'icons/obj/atmospherics/pipes/pipes_bitmask.dmi'
	var/bitfield = NONE
	for(var/i in 1 to device_type)
		if(!nodes[i])
			continue
		var/obj/machinery/atmospherics/node = nodes[i]
		var/connected_dir = get_dir(src, node)
		switch(connected_dir)
			if(NORTH)
				bitfield |= NORTH_FULLPIPE
			if(SOUTH)
				bitfield |= SOUTH_FULLPIPE
			if(EAST)
				bitfield |= EAST_FULLPIPE
			if(WEST)
				bitfield |= WEST_FULLPIPE
	for(var/cardinal in GLOB.cardinals)
		if(initialize_directions & cardinal && !(bitfield & cardinal))
			switch(cardinal)
				if(NORTH)
					bitfield |= NORTH_SHORTPIPE
				if(SOUTH)
					bitfield |= SOUTH_SHORTPIPE
				if(EAST)
					bitfield |= EAST_SHORTPIPE
				if(WEST)
					bitfield |= WEST_SHORTPIPE
	icon_state = "[bitfield]_[piping_layer]"

/obj/machinery/atmospherics/pipe/update_icon()
	. = ..()
	update_pipe_icon()
	update_layer()
	
/obj/machinery/atmospherics/proc/update_node_icon()
	for(var/i in 1 to device_type)
		if(nodes[i])
			var/obj/machinery/atmospherics/N = nodes[i]
			N.update_icon()

/obj/machinery/atmospherics/pipe/returnPipenets()
	. = list(parent)

/obj/machinery/atmospherics/pipe/paint(paint_color)
	if(paintable)
		add_atom_colour(paint_color, FIXED_COLOUR_PRIORITY)
		pipe_color = paint_color
		update_node_icon()
	return paintable

/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	dir = SOUTH
	initialize_directions = SOUTH|NORTH
	pipe_flags = PIPING_CARDINAL_AUTONORMALIZE

	device_type = BINARY

	construction_type = /obj/item/pipe/binary/bendable
	pipe_state = "simple"

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(ISDIAGONALDIR(dir))
		initialize_directions = dir
		return
	switch(dir)
		if(NORTH, SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST, WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-3"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."

	dir = SOUTH
	initialize_directions = EAST|NORTH|WEST

	device_type = TRINARY

	construction_type = /obj/item/pipe/trinary
	pipe_state = "manifold"

/obj/machinery/atmospherics/pipe/manifold/SetInitDirections()
	initialize_directions = ALL_CARDINALS
	initialize_directions &= ~dir

/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"

	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes."

	initialize_directions = ALL_CARDINALS

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = ALL_CARDINALS
