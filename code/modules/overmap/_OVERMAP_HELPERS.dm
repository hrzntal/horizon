/proc/GetLandmarksInZLevel(landmark_type, datum/space_level/z_level)
	var/list/compiled_list = list()
	for(var/i in GLOB.landmarks_list)
		var/obj/effect/landmark/landmark = i
		if(z_level.z_value == landmark.z && istype(landmark, landmark_type))
			compiled_list += landmark
	return compiled_list

/proc/GetRandomTurfInZLevelWithMargin(margin, datum/space_level/z_level)
	var/low_x = 1 + margin
	var/high_x = world.maxx - margin
	var/low_y = 1 + margin
	var/high_y = world.maxy - margin
	var/turf/located = locate(rand(low_x, high_x), rand(low_y, high_y), z_level.z_value)
	return located
