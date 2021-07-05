GLOBAL_LIST_INIT(atmos_components, typecacheof(list(/obj/machinery/atmospherics)))
//Smart pipes... or are they?
/obj/machinery/atmospherics/pipe/smart
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

	name = "pipe"
	desc = "A one meter section of regular pipe."

	device_type = QUATERNARY
	construction_type = /obj/item/pipe/quaternary
	pipe_state = "manifold4w"
	connection_num = 0

/* We use New() instead of Initialize() because these values are used in update_icon()
 * in the mapping subsystem init before Initialize() is called in the atoms subsystem init.
 */
/obj/machinery/atmospherics/pipe/smart/Initialize()
	. = ..()

/obj/machinery/atmospherics/pipe/smart/update_icon_state()
	. = ..() //Compiles state from parent and then ignores it, unfortunately
	var/bitfield = NONE
	//This can actually compile an incorrect icon, because a correct one needs atleast 2 bits. I am meaning to rework smart pipes later so this wont be the case
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
	icon_state = "[bitfield]_[piping_layer]"

/obj/machinery/atmospherics/pipe/smart/SetInitDirections(init_dir)
	if(init_dir)
		initialize_directions =	init_dir
	else
		initialize_directions = ALL_CARDINALS

/obj/machinery/atmospherics/pipe/smart/proc/check_binary_direction(direction)
	switch(direction)
		if(EAST|WEST)
			return EAST
		if(SOUTH|NORTH)
			return SOUTH
		else
			return direction

/obj/machinery/atmospherics/pipe/smart/proc/check_manifold_direction(direction)
	switch(direction)
		if(NORTH|SOUTH|EAST)
			return WEST
		if(NORTH|SOUTH|WEST)
			return EAST
		if(NORTH|WEST|EAST)
			return SOUTH
		if(SOUTH|WEST|EAST)
			return NORTH
		else
			return null

//mapping helpers
/obj/machinery/atmospherics/pipe/smart/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

/obj/machinery/atmospherics/pipe/smart/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-3"

/obj/machinery/atmospherics/pipe/smart/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"
