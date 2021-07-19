
/mob/living/silicon/robot_old/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	regenerate_icons()
	show_laws(0)
