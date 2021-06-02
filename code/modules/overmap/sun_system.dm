/datum/overmap_sun_system
	/// Name of the sun system
	var/name = "Alpha"
	/// It's x coordinate in the galaxy
	var/x = 0
	/// It's y coordinate in the galaxy
	var/y = 0
	/// All overmap objects that are inside the sunsystem
	var/list/overmap_objects = list()
	/// The simulated Z level
	var/datum/space_level/my_space_level
	/// The z value of the simulated space level, for easier lookup
	var/z_level = 0

	/// The levels are initialised in reserved blocks on the overmap level. Those offsets are this level's starting point
	var/x_offset = 0
	var/y_offset = 0
	/// The furthest x and y in the sun system
	var/maxx = 50
	var/maxy = 50

/datum/overmap_sun_system/proc/GetVisualX(passed_x)
	return x_offset + passed_x

/datum/overmap_sun_system/proc/GetVisualY(passed_y)
	return y_offset + passed_y

/datum/overmap_sun_system/proc/GetObjectsInRadius(_x,_y,rad)
	. = list()
	for(var/i in overmap_objects)
		var/datum/overmap_object/OO = i
		if(OO.x <= _x + rad && OO.x >= _x - rad && OO.y <= _y + rad && OO.y >= _y - rad)
			. += OO

/datum/overmap_sun_system/proc/ObjectsAdjacent(datum/overmap_object/object_one, datum/overmap_object/object_two)
	if(object_one.x <= object_two.x + 1 && object_one.x >= object_two.x - 1 && object_one.y <= object_two.y + 1 && object_one.y >= object_two.y - 1)
		return TRUE
	return FALSE

/datum/overmap_sun_system/New(datum/space_level/passed_level)
	my_space_level = passed_level
	z_level = my_space_level.z_value
	//Initialize the turfs
	for(var/iterated_x in 1 to maxx+1)
		for(var/iterated_y in 1 to maxy+1)
			var/turf/located = locate(iterated_x + x_offset, iterated_y + y_offset, z_level)
			if(!located)
				WARNING("Sun system generation could not find a turf")
			//Place a corner turf
			if(iterated_x == maxx+1 || iterated_y == maxy+1)
				located.ChangeTurf(/turf/open/overmap/border, flags = CHANGETURF_IGNORE_AIR)
			//Plase a map turf and name it
			else
				located.ChangeTurf(/turf/open/overmap/map, flags = CHANGETURF_IGNORE_AIR)
				var/turf/open/overmap/map/map_turf = located
				map_turf.name = "[iterated_x]-[iterated_y]"
				//Handle their number overlays
				var/lowx
				var/lowy
				var/highx
				var/highy
				if(iterated_x == 1)
					lowy = iterated_y
				else if (iterated_x == maxx)
					highy = iterated_y
				if(iterated_y == 1)
					lowx = iterated_x
				else if (iterated_y == maxy)
					highx = iterated_x
				map_turf.set_coords_overlays(lowx, lowy, highx, highy)
