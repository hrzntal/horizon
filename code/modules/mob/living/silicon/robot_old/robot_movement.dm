/mob/living/silicon/robot_old/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return TRUE
	if(ionpulse())
		return TRUE
	return FALSE

/mob/living/silicon/robot_old/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot_old/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot_old/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
