/mob
	///Whether the mob is pixel shifted or not
	var/is_shifted
	var/shifting //If we are in the shifting setting.

/mob/proc/unpixel_shift()
	return

/mob/living/unpixel_shift()
	if(is_shifted)
		is_shifted = FALSE
		pixel_x = body_position_pixel_x_offset
		pixel_y = body_position_pixel_y_offset

/mob/proc/pixel_shift(direction)
	return

/mob/living/pixel_shift(direction)
	if(!canface())
		return FALSE
	switch(direction)
		if(NORTH)
			if(pixel_y <= 16)
				pixel_y++
				is_shifted = TRUE
		if(NORTHEAST)
			if((pixel_y <= 16) && (pixel_x <= 16))
				pixel_x++
				pixel_y++
				is_shifted = TRUE
		if(EAST)
			if(pixel_x <= 16)
				pixel_x++
				is_shifted = TRUE
		if(SOUTHEAST)
			if((pixel_x <= 16) && (pixel_y >= -16))
				pixel_x++
				pixel_y--
				is_shifted = TRUE
		if(SOUTH)
			if(pixel_y >= -16)
				pixel_y--
				is_shifted = TRUE
		if(SOUTHWEST)
			if((pixel_y >= -16) && (pixel_x >= -16))
				pixel_x--
				pixel_y--
				is_shifted = TRUE
		if(WEST)
			if(pixel_x >= -16)
				pixel_x--
				is_shifted = TRUE
		if(NORTHWEST)
			if((pixel_x >= -16) && (pixel_y <= 16))
				pixel_x--
				pixel_y++
				is_shifted = TRUE
