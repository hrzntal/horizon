/obj/effect/mapping_helpers/smart_pipe
	var/pipe_color = COLOR_VERY_LIGHT_GRAY
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/hide = FALSE

/obj/effect/mapping_helpers/smart_pipe/Initialize()
	var/directions = get_node_directions()
	var/passed_directions = NONE
	var/dir_count = 0
	var/turf/my_turf = loc
	for(var/cardinal in directions)
		var/turf/step_turf = get_step(my_turf, cardinal)
		var/obj/effect/mapping_helpers/smart_pipe/other_smart_pipe = locate() in step_turf
		if(other_smart_pipe)
			var/opp = REVERSE_DIR(cardinal)
			if(other_smart_pipe.get_node_directions() & opp && connect_smart_pipe_check(other_smart_pipe))
				passed_directions |= cardinal
				dir_count++
				continue
		var/obj/machinery/atmospherics/atmosmachine = locate() in step_turf
		if(atmosmachine && connect_atmos_machinery_check(atmosmachine, cardinal))
			passed_directions |= cardinal
			dir_count++
			continue
	if(dir_count <= 0)
		WARNING("Smart pipe mapping helper failed to spawn, connected to [dir_count] directions, at [loc.x],[loc.y],[loc.z]")
	else
		switch(dir_count)
			if(1) //Simple pipe with exposed rear
				message_admins("simple exposed")
				spawn_pipe(passed_directions,/obj/machinery/atmospherics/pipe/simple)
			if(2) //Simple pipe
				message_admins("simple")
				var/pipe_dir = passed_directions
				//Prune non/diagonal directions
				if(passed_directions & NORTH && passed_directions & SOUTH)
					pipe_dir = NORTH
				if(passed_directions & EAST && passed_directions & WEST)
					pipe_dir = EAST
				spawn_pipe(pipe_dir, /obj/machinery/atmospherics/pipe/simple)
			if(3) //Manifold
				message_admins("mani")
				for(var/cardinal in GLOB.cardinals)
					if(!(passed_directions & cardinal))
						spawn_pipe(cardinal, /obj/machinery/atmospherics/pipe/manifold4w-3)
						break
			if(4) //4 way manifold
				message_admins("4way mani")
				spawn_pipe(NORTH, /obj/machinery/atmospherics/pipe/manifold)

	message_admins("[passed_directions]")

	return ..()

/obj/effect/mapping_helpers/smart_pipe/proc/spawn_pipe(direction, type)
	var/obj/machinery/atmospherics/pipe/built_pipe = new type(loc)
	built_pipe.setDir(direction)
	built_pipe.on_construction(pipe_color, piping_layer)

//Whether we can connect to another smart pipe helper, doesn't care about directions
/obj/effect/mapping_helpers/smart_pipe/proc/connect_smart_pipe_check(obj/effect/mapping_helpers/smart_pipe/other_pipe)
	if(piping_layer == other_pipe.piping_layer && (pipe_color == COLOR_VERY_LIGHT_GRAY || other_pipe.pipe_color == COLOR_VERY_LIGHT_GRAY || lowertext(pipe_color) == lowertext(other_pipe.pipe_color)))
		return TRUE
	return FALSE

/obj/effect/mapping_helpers/smart_pipe/proc/connect_atmos_machinery_check(obj/machinery/atmospherics/atmosmachine, passed_dir)
	//Check direction
	var/opp = REVERSE_DIR(passed_dir)
	if(!(atmosmachine.initialize_directions & opp))
		return FALSE
	//Check layer
	if(piping_layer != atmosmachine && !(atmosmachine.pipe_flags & PIPING_ALL_LAYER))
		return FALSE
	//Check color
	if(pipe_color != COLOR_VERY_LIGHT_GRAY && atmosmachine.pipe_color != COLOR_VERY_LIGHT_GRAY && lowertext(pipe_color) != lowertext(atmosmachine.pipe_color))
		return FALSE
	return TRUE

/obj/effect/mapping_helpers/smart_pipe/proc/get_node_directions()
	return NONE

/obj/effect/mapping_helpers/smart_pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "pipe11-3"

/obj/effect/mapping_helpers/smart_pipe/simple/get_node_directions()
	if(ISDIAGONALDIR(dir))
		return dir
	switch(dir)
		if(NORTH, SOUTH)
			return SOUTH|NORTH
		if(EAST, WEST)
			return EAST|WEST

/obj/effect/mapping_helpers/smart_pipe/manifold
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold-3"

/obj/effect/mapping_helpers/smart_pipe/manifold/get_node_directions()
	var/directions = ALL_CARDINALS
	directions &= ~dir
	return directions

/obj/effect/mapping_helpers/smart_pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = "manifold4w-3"

/obj/effect/mapping_helpers/smart_pipe/manifold4w/get_node_directions()
	return ALL_CARDINALS
