// AVALI BUT FOR SS13 - NOW ON /TG/ CODE - https://avali.fandom.com
/datum/species/teshari
	id = "teshari"
	name = "Teshari"
	flavor_text = "Warning: WIP Race. May not work correctly. ::: A small feathered species, often compared to both birds, and raptors."
	default_color = "0F0"
	liked_food = GROSS | MEAT | FRIED
	say_mod = "chirps"
	species_language_holder = /datum/language_holder/teshari
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_RESISTCOLD, TRAIT_ADVANCEDTOOLUSER)
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon = 'hrzn/modules/teshari/icons/mob/species/teshari_parts_greyscale.dmi'
	eyes_icon = 'hrzn/modules/teshari/icons/mob/species/teshari_eyes.dmi'
	default_mutant_bodyparts = list("tail" = "Teshari Tail")
	bodytype = BODYTYPE_TESHARI

/datum/language_holder/teshari
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/vox = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/vox = list(LANGUAGE_ATOM))

/mob/living/carbon/human/species/teshari
	race = /datum/species/teshari

/datum/sprite_accessory/tails/teshari
	icon = 'hrzn/modules/teshari/icons/mob/sprite_accessory/teshari_tails.dmi'
	name = "Teshari Tail"
	icon_state = "teshari"
	recommended_species = list("teshari")
