/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	id = "lizard"
	say_mod = "hisses"
	default_color = "0F0"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_REPTILE
	default_mutant_bodyparts = list("tail" = ACC_RANDOM, "snout" = ACC_RANDOM, "spines" = ACC_RANDOM, "frills" = ACC_RANDOM, "horns" = ACC_RANDOM, "body_markings" = ACC_RANDOM, "legs" = "Digitigrade Legs", "taur" = "None", "wings" = "None")
	mutanttongue = /obj/item/organ/tongue/lizard
	coldmod = 1.5
	heatmod = 0.67
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/food/meat/slab/human/mutant/lizard
	skinned_type = /obj/item/stack/sheet/animalhide/lizard
	exotic_bloodtype = "L"
	disliked_food = GRAIN | DAIRY
	liked_food = GROSS | MEAT
	inert_mutation = FIREBREATH
	deathsound = 'sound/voice/lizard/deathsound.ogg'
	wings_icon = "Dragon"
	species_language_holder = /datum/language_holder/lizard
	// Lizards are coldblooded and can stand a greater temperature range than humans
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT + 20) // This puts lizards 10 above lavaland max heat for ash lizards.
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 10)

	ass_image = 'icons/ass/asslizard.png'
	limbs_icon = 'icons/mob/species/lizard_parts_greyscale.dmi'

/// Lizards are cold blooded and do not stabilize body temperature naturally
/datum/species/lizard/body_temperature_core(mob/living/carbon/human/humi)
	return

/datum/species/lizard/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_lizard_name(gender)

	var/randname = lizard_name(gender)

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/lizard/get_random_features()
	var/list/returned = MANDATORY_FEATURE_LIST
	var/main_color = random_short_color()
	var/second_color
	var/third_color
	var/random = rand(1,3)
	switch(random)
		if(1) //First random case - all is the same
			second_color = main_color
			third_color = main_color
		if(2) //Second case, derrivatory shades, except there's no helpers for that and I dont feel like writing them
			second_color = main_color
			third_color = main_color
		if(3) //Third case, more randomisation
			second_color = random_short_color()
			third_color = random_short_color()
	returned["mcolor"] = main_color
	returned["mcolor2"] = second_color
	returned["mcolor3"] = third_color
	return returned

/*
Lizard subspecies: ASHWALKERS
*/
/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "ashlizard"
	limbs_id = "lizard"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER,TRAIT_CHUNKYFINGERS,TRAIT_NOBREATH)
	species_language_holder = /datum/language_holder/lizard/ash
	always_customizable = TRUE
