GLOBAL_VAR_INIT(ssd_indicator_overlay, mutable_appearance('icons/horizon/mob/ssd_indicator.dmi', "default0", FLY_LAYER))

/mob/living/proc/set_ssd_indicator(state)
	if(state == ssd_indicator)
		return
	ssd_indicator = state
	if(ssd_indicator)
		add_overlay(GLOB.ssd_indicator_overlay)
		log_message("<font color='green'>has went SSD and got their indicator!</font>", INDIVIDUAL_ATTACK_LOG)
	else
		cut_overlay(GLOB.ssd_indicator_overlay)
		log_message("<font color='green'>is no longer SSD and lost their indicator!</font>", INDIVIDUAL_ATTACK_LOG)
