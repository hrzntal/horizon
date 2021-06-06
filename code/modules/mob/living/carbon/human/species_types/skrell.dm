/datum/species/skrell
	name = "Skrell"
	id = "skrell"
	default_color = "444"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("skrell_hair" = ACC_RANDOM)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'icons/mob/species/skrell_parts_greyscale.dmi'
	eyes_icon = 'icons/mob/species/skrell_eyes.dmi'

/datum/species/skrell/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color
	var/random = rand(1,6)
	//Choose from a range of green-blue colors
	switch(random)
		if(1)
			main_color = "44FF77"
		if(2)
			main_color = "22FF88"
		if(3)
			main_color = "22FFBB"
		if(4)
			main_color = "22FFFF"
		if(5)
			main_color = "22BBFF"
		if(6)
			main_color = "2266FF"
	returned["mcolor"] = main_color
	returned["mcolor2"] = main_color
	returned["mcolor3"] = main_color
	return returned
