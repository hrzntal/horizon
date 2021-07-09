//Subtype of human
/datum/species/human/felinid
	name = "Felinid"
	id = "felinid"
	say_mod = "meows"
	limbs_id = "human"

	default_mutant_bodyparts = list("tail" = "Cat", "ears" = "Cat")

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/felinid
	disliked_food = GROSS | RAW | CLOTH
	var/original_felinid = TRUE //set to false for felinids created by mass-purrbation
	payday_modifier = 0.75
	ass_image = 'icons/ass/asscat.png'
	family_heirlooms = list(/obj/item/toy/cattoy)

/proc/mass_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_apply(M)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishuman(M))
			purrbation_remove(M)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/H, silent = FALSE)
	if(!ishumanbasic(H))
		return
	if(!isfelinid(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || isfelinid(H))
		return
	if(ishumanbasic(H))
		H.set_species(/datum/species/human/felinid)
		var/datum/species/human/felinid/cat_species = H.dna.species
		cat_species.original_felinid = FALSE
	else
		var/obj/item/organ/ears/cat/kitty_ears = new
		var/obj/item/organ/tail/cat/kitty_tail = new
		kitty_ears.Insert(H, TRUE, FALSE) //Gives nonhumans cat tail and ears
		kitty_tail.Insert(H, TRUE, FALSE)
	if(!silent)
		to_chat(H, SPAN_BOLDNOTICE("Something is nya~t right."))
		playsound(get_turf(H), 'sound/effects/meow1.ogg', 50, TRUE, -1)

/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	if(isfelinid(H))
		var/datum/species/human/felinid/cat_species = H.dna.species
		if(!cat_species.original_felinid)
			H.set_species(/datum/species/human)
	else if(ishuman(H) && !ishumanbasic(H))
		var/datum/species/target_species = H.dna.species
		var/organs = H.internal_organs
		for(var/obj/item/organ/current_organ in organs)
			if(istype(current_organ, /obj/item/organ/tail/cat))
				current_organ.Remove(H, TRUE)
				var/obj/item/organ/tail/new_tail = locate(/obj/item/organ/tail) in target_species.mutant_organs
				if(new_tail)
					new_tail = new new_tail()
					new_tail.Insert(H, TRUE, FALSE)
			if(istype(current_organ, /obj/item/organ/ears/cat))
				var/obj/item/organ/new_ears = new target_species.mutantears
				new_ears.Insert(H, TRUE, FALSE)
	if(!silent)
		to_chat(H, SPAN_BOLDNOTICE("You are no longer a cat."))
