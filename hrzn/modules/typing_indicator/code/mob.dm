GLOBAL_VAR_INIT(typing_indicator_overlay, mutable_appearance('hrzn/modules/typing_indicator/icons/typing_indicator.dmi', "default0", FLY_LAYER))

/mob
	var/typing_indicator = FALSE

/mob/proc/set_typing_indicator(var/state)
	typing_indicator = state
	if(typing_indicator)
		add_overlay(GLOB.typing_indicator_overlay)
	else
		cut_overlay(GLOB.typing_indicator_overlay)

/mob/living/key_down(_key, client/user)
	if(!typing_indicator && stat == CONSCIOUS)
		for(var/kb_name in user.prefs.key_bindings[_key])
			switch(kb_name)
				if("Say")
					set_typing_indicator(TRUE)
					break
				if("Me")
					set_typing_indicator(TRUE)
					break
	return ..()
