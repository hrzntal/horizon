/datum/species/insect
	name = "Anthromorphic Insect"
	id = "insect"
	default_color = "444"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	inherent_traits = list(TRAIT_ADVANCEDTOOLUSER)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "horns" = "None", "ears" = "None", "legs" = "Normal Legs", "taur" = "None", "wings" = "Bee", "moth_antennae" = ACC_RANDOM)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'icons/mob/species/insect_parts_greyscale.dmi'
