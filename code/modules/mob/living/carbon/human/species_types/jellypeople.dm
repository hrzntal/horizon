/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Jellyperson"
	id = "jelly"
	default_color = "0F9"
	say_mod = "chirps"
	species_traits = list(
		MUTCOLORS,
		EYECOLOR,
		NOBLOOD,
		HAIR,
		FACEHAIR,
	)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_TOXINLOVER,
	)
	mutantlungs = /obj/item/organ/lungs/slime
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	damage_overlay_type = ""
	var/datum/action/innate/regenerate_limbs/regenerate_limbs
	var/datum/action/innate/slime_change/slime_change
	liked_food = MEAT
	toxic_food = NONE
	coldmod = 6   // = 3x cold damage
	heatmod = 0.5 // = 1/4x heat damage
	burnmod = 0.5 // = 1/2x generic burn damage
	payday_modifier = 0.75
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_factions = list("slime")
	species_language_holder = /datum/language_holder/jelly
	ass_image = 'icons/ass/assslime.png'
	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "ears" = "None", "taur" = "None", "wings" = "None", "legs" = "Normal Legs")
	hair_alpha = 160 //a notch brighter so it blends better.

/datum/species/jelly/on_species_loss(mob/living/carbon/C)
	if(regenerate_limbs)
		regenerate_limbs.Remove(C)
	if(slime_change)
		slime_change.Remove(C)
	..()

/datum/species/jelly/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		regenerate_limbs = new
		regenerate_limbs.Grant(C)
		slime_change = new
		slime_change.Grant(C)

/datum/species/jelly/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.stat == DEAD) //can't farm slime jelly from a dead slime/jelly person indefinitely
		return

	if(!H.blood_volume)
		H.blood_volume += 2.5 * delta_time
		H.adjustBruteLoss(2.5 * delta_time)
		to_chat(H, SPAN_DANGER("You feel empty!"))

	if(H.blood_volume < BLOOD_VOLUME_NORMAL)
		if(H.nutrition >= NUTRITION_LEVEL_STARVING)
			H.blood_volume += 1.5 * delta_time
			H.adjust_nutrition(-1.25 * delta_time)

	if(H.blood_volume < BLOOD_VOLUME_OKAY)
		if(DT_PROB(2.5, delta_time))
			to_chat(H, SPAN_DANGER("You feel drained!"))

	if(H.blood_volume < BLOOD_VOLUME_BAD)
		Cannibalize_Body(H)

	if(regenerate_limbs)
		regenerate_limbs.UpdateButtonIcon()

/datum/species/jelly/proc/Cannibalize_Body(mob/living/carbon/human/H)
	var/list/limbs_to_consume = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG) - H.get_missing_limbs()
	var/obj/item/bodypart/consumed_limb
	if(!limbs_to_consume.len)
		H.losebreath++
		return
	if(H.num_legs) //Legs go before arms
		limbs_to_consume -= list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	consumed_limb = H.get_bodypart(pick(limbs_to_consume))
	consumed_limb.drop_limb()
	to_chat(H, SPAN_USERDANGER("Your [consumed_limb] is drawn back into your body, unable to maintain its shape!"))
	qdel(consumed_limb)
	H.blood_volume += 20

/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/regenerate_limbs/IsAvailable()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(limbs_to_heal.len < 1)
		return FALSE
	if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
		return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(limbs_to_heal.len < 1)
		to_chat(H, SPAN_NOTICE("You feel intact enough as it is."))
		return
	to_chat(H, SPAN_NOTICE("You focus intently on your missing [limbs_to_heal.len >= 2 ? "limbs" : "limb"]..."))
	if(H.blood_volume >= 40*limbs_to_heal.len+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		H.blood_volume -= 40*limbs_to_heal.len
		to_chat(H, SPAN_NOTICE("...and after a moment you finish reforming!"))
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		to_chat(H, SPAN_WARNING("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, SPAN_WARNING("...but there is not enough of you to go around! You must attain more mass to heal!"))

////////////////////////////////////////////////////////SLIMEPEOPLE///////////////////////////////////////////////////////////////////

//Slime people are able to split like slimes, retaining a single mind that can swap between bodies at will, even after death.

/datum/species/jelly/slime
	name = "Slimeperson"
	id = "slime"
	default_color = "0FF"
	species_traits = list(MUTCOLORS,EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	say_mod = "says"
	hair_color = "mutcolor"
	hair_alpha = 150
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	var/datum/action/innate/split_body/slime_split
	var/list/mob/living/carbon/bodies
	var/datum/action/innate/swap_body/swap_body

/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	if(slime_split)
		slime_split.Remove(C)
	if(swap_body)
		swap_body.Remove(C)
	bodies -= C // This means that the other bodies maintain a link
	// so if someone mindswapped into them, they'd still be shared.
	bodies = null
	C.blood_volume = min(C.blood_volume, BLOOD_VOLUME_NORMAL)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		slime_split = new
		slime_split.Grant(C)
		swap_body = new
		swap_body.Grant(C)

		if(!bodies || !bodies.len)
			bodies = list(C)
		else
			bodies |= C

/datum/species/jelly/slime/spec_death(gibbed, mob/living/carbon/human/H)
	if(slime_split)
		if(!H.mind || !H.mind.active)
			return

		var/list/available_bodies = (bodies - H)
		for(var/mob/living/L in available_bodies)
			if(!swap_body.can_swap(L))
				available_bodies -= L

		if(!LAZYLEN(available_bodies))
			return

		swap_body.swap_to_dupe(H.mind, pick(available_bodies))

//If you're cloned you get your body pool back
/datum/species/jelly/slime/copy_properties_from(datum/species/jelly/slime/old_species)
	bodies = old_species.bodies

/datum/species/jelly/slime/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		if(DT_PROB(2.5, delta_time))
			to_chat(H, SPAN_NOTICE("You feel very bloated!"))

	else if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
		H.blood_volume += 1.5 * delta_time
		H.adjust_nutrition(-1.25 * delta_time)

	..()

/datum/action/innate/split_body
	name = "Split Body"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimesplit"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/split_body/IsAvailable()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
		return TRUE
	return FALSE

/datum/action/innate/split_body/Activate()
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return
	CHECK_DNA_AND_SPECIES(H)
	H.visible_message("<span class='notice'>[owner] gains a look of \
		concentration while standing perfectly still.</span>",
		"<span class='notice'>You focus intently on moving your body while \
		standing perfectly still...</span>")

	H.notransform = TRUE

	if(do_after(owner, delay = 6 SECONDS, target = owner, timed_action_flags = IGNORE_HELD_ITEM))
		if(H.blood_volume >= BLOOD_VOLUME_SLIME_SPLIT)
			make_dupe()
		else
			to_chat(H, SPAN_WARNING("...but there is not enough of you to go around! You must attain more mass to split!"))
	else
		to_chat(H, SPAN_WARNING("...but fail to stand perfectly still!"))

	H.notransform = FALSE

/datum/action/innate/split_body/proc/make_dupe()
	var/mob/living/carbon/human/H = owner
	CHECK_DNA_AND_SPECIES(H)

	var/mob/living/carbon/human/spare = new /mob/living/carbon/human(H.loc)

	spare.underwear = "Nude"
	H.dna.transfer_identity(spare, transfer_SE=1)
	spare.dna.features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	spare.real_name = spare.dna.real_name
	spare.name = spare.dna.real_name
	spare.updateappearance(mutcolor_update=1)
	spare.domutcheck()
	spare.Move(get_step(H.loc, pick(NORTH,SOUTH,EAST,WEST)))


	var/datum/component/nanites/owner_nanites = H.GetComponent(/datum/component/nanites)
	if(owner_nanites)
		//copying over nanite programs/cloud sync with 50% saturation in host and spare
		owner_nanites.nanite_volume *= 0.5
		spare.AddComponent(/datum/component/nanites, owner_nanites.nanite_volume)
		SEND_SIGNAL(spare, COMSIG_NANITE_SYNC, owner_nanites, TRUE, TRUE) //The trues are to copy activation as well

	H.blood_volume *= 0.45
	H.notransform = 0

	var/datum/species/jelly/slime/origin_datum = H.dna.species
	origin_datum.bodies |= spare

	var/datum/species/jelly/slime/spare_datum = spare.dna.species
	spare_datum.bodies = origin_datum.bodies

	H.transfer_trait_datums(spare)
	H.mind.transfer_to(spare)
	spare.visible_message("<span class='warning'>[H] distorts as a new body \
		\"steps out\" of [H.p_them()].</span>",
		"<span class='notice'>...and after a moment of disorentation, \
		you're besides yourself!</span>")


/datum/action/innate/swap_body
	name = "Swap Body"
	check_flags = NONE
	button_icon_state = "slimeswap"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/swap_body/Activate()
	if(!isslimeperson(owner))
		to_chat(owner, SPAN_WARNING("You are not a slimeperson."))
		Remove(owner)
	else
		ui_interact(owner)

/datum/action/innate/swap_body/ui_host(mob/user)
	return owner

/datum/action/innate/swap_body/ui_state(mob/user)
	return GLOB.always_state

/datum/action/innate/swap_body/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimeBodySwapper", name)
		ui.open()

/datum/action/innate/swap_body/ui_data(mob/user)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return

	var/datum/species/jelly/slime/SS = H.dna.species

	var/list/data = list()
	data["bodies"] = list()
	for(var/b in SS.bodies)
		var/mob/living/carbon/human/body = b
		if(!body || QDELETED(body) || !isslimeperson(body))
			SS.bodies -= b
			continue

		var/list/L = list()
		// HTML colors need a # prefix
		L["htmlcolor"] = "#[body.dna.features["mcolor"]]"
		L["area"] = get_area_name(body, TRUE)
		var/stat = "error"
		switch(body.stat)
			if(CONSCIOUS)
				stat = "Conscious"
			if(UNCONSCIOUS)
				stat = "Unconscious"
			if(DEAD)
				stat = "Dead"
		var/occupied
		if(body == H)
			occupied = "owner"
		else if(body.mind && body.mind.active)
			occupied = "stranger"
		else
			occupied = "available"

		L["status"] = stat
		L["exoticblood"] = body.blood_volume
		L["name"] = body.name
		L["ref"] = "[REF(body)]"
		L["occupied"] = occupied
		var/button
		if(occupied == "owner")
			button = "selected"
		else if(occupied == "stranger")
			button = "danger"
		else if(can_swap(body))
			button = null
		else
			button = "disabled"

		L["swap_button_state"] = button
		L["swappable"] = (occupied == "available") && can_swap(body)

		data["bodies"] += list(L)

	return data

/datum/action/innate/swap_body/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(owner))
		return
	if(!H.mind || !H.mind.active)
		return
	switch(action)
		if("swap")
			var/datum/species/jelly/slime/SS = H.dna.species
			var/mob/living/carbon/human/selected = locate(params["ref"]) in SS.bodies
			if(!can_swap(selected))
				return
			SStgui.close_uis(src)
			swap_to_dupe(H.mind, selected)

/datum/action/innate/swap_body/proc/can_swap(mob/living/carbon/human/dupe)
	var/mob/living/carbon/human/H = owner
	if(!isslimeperson(H))
		return FALSE
	var/datum/species/jelly/slime/SS = H.dna.species

	if(QDELETED(dupe)) //Is there a body?
		SS.bodies -= dupe
		return FALSE

	if(!isslimeperson(dupe)) //Is it a slimeperson?
		SS.bodies -= dupe
		return FALSE

	if(dupe.stat == DEAD) //Is it alive?
		return FALSE

	if(dupe.stat != CONSCIOUS) //Is it awake?
		return FALSE

	if(dupe.mind && dupe.mind.active) //Is it unoccupied?
		return FALSE

	if(!(dupe in SS.bodies)) //Do we actually own it?
		return FALSE

	return TRUE

/datum/action/innate/swap_body/proc/swap_to_dupe(datum/mind/M, mob/living/carbon/human/dupe)
	if(!can_swap(dupe)) //sanity check
		return
	if(M.current.stat == CONSCIOUS)
		M.current.visible_message("<span class='notice'>[M.current] \
			stops moving and starts staring vacantly into space.</span>",
			SPAN_NOTICE("You stop moving this body..."))
	else
		to_chat(M.current, SPAN_NOTICE("You abandon this body..."))
	M.current.transfer_trait_datums(dupe)
	M.transfer_to(dupe)
	dupe.visible_message("<span class='notice'>[dupe] blinks and looks \
		around.</span>",
		SPAN_NOTICE("...and move this one instead."))


///////////////////////////////////LUMINESCENTS//////////////////////////////////////////

//Luminescents are able to consume and use slime extracts, without them decaying.

/datum/species/jelly/luminescent
	name = "Luminescent"
	id = "lum"
	say_mod = "says"
	var/glow_intensity = LUMINESCENT_DEFAULT_GLOW
	var/obj/effect/dummy/luminescent_glow/glow
	var/obj/item/slime_extract/current_extract
	var/datum/action/innate/integrate_extract/integrate_extract
	var/datum/action/innate/use_extract/extract_minor
	var/datum/action/innate/use_extract/major/extract_major
	var/extract_cooldown = 0

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/luminescent/Destroy(force, ...)
	current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)
	return ..()


/datum/species/jelly/luminescent/on_species_loss(mob/living/carbon/C)
	..()
	if(current_extract)
		current_extract.forceMove(C.drop_location())
		current_extract = null
	QDEL_NULL(glow)
	QDEL_NULL(integrate_extract)
	QDEL_NULL(extract_major)
	QDEL_NULL(extract_minor)

/datum/species/jelly/luminescent/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	glow = new(C)
	update_glow(C)
	integrate_extract = new(src)
	integrate_extract.Grant(C)
	extract_minor = new(src)
	extract_minor.Grant(C)
	extract_major = new(src)
	extract_major.Grant(C)

/datum/species/jelly/luminescent/proc/update_slime_actions()
	integrate_extract.update_name()
	integrate_extract.UpdateButtonIcon()
	extract_minor.UpdateButtonIcon()
	extract_major.UpdateButtonIcon()

/datum/species/jelly/luminescent/proc/update_glow(mob/living/carbon/C, intensity)
	if(intensity)
		glow_intensity = intensity
	glow.set_light(glow_intensity, glow_intensity, C.dna.features["mcolor"])

/obj/effect/dummy/luminescent_glow
	name = "luminescent glow"
	desc = "Tell a coder if you're seeing this."
	icon_state = "nothing"
	light_system = MOVABLE_LIGHT
	light_range = LUMINESCENT_DEFAULT_GLOW
	light_power = 2.5
	light_color = COLOR_WHITE

/obj/effect/dummy/luminescent_glow/Initialize()
	. = ..()
	if(!isliving(loc))
		return INITIALIZE_HINT_QDEL


/datum/action/innate/integrate_extract
	name = "Integrate Extract"
	desc = "Eat a slime extract to use its properties."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeconsume"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/integrate_extract/proc/update_name()
	var/datum/species/jelly/luminescent/species = target
	if(!species || !species.current_extract)
		name = "Integrate Extract"
		desc = "Eat a slime extract to use its properties."
	else
		name = "Eject Extract"
		desc = "Eject your current slime extract."

/datum/action/innate/integrate_extract/UpdateButtonIcon(status_only, force)
	var/datum/species/jelly/luminescent/species = target
	if(!species || !species.current_extract)
		button_icon_state = "slimeconsume"
	else
		button_icon_state = "slimeeject"
	..()

/datum/action/innate/integrate_extract/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)
	var/datum/species/jelly/luminescent/species = target
	if(species?.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/integrate_extract/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/jelly/luminescent/species = target
	if(!is_species(H, /datum/species/jelly/luminescent) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		var/obj/item/slime_extract/S = species.current_extract
		if(!H.put_in_active_hand(S))
			S.forceMove(H.drop_location())
		species.current_extract = null
		to_chat(H, SPAN_NOTICE("You eject [S]."))
		species.update_slime_actions()
	else
		var/obj/item/I = H.get_active_held_item()
		if(istype(I, /obj/item/slime_extract))
			var/obj/item/slime_extract/S = I
			if(!S.Uses)
				to_chat(H, SPAN_WARNING("[I] is spent! You cannot integrate it."))
				return
			if(!H.temporarilyRemoveItemFromInventory(S))
				return
			S.forceMove(H)
			species.current_extract = S
			to_chat(H, SPAN_NOTICE("You consume [I], and you feel it pulse within you..."))
			species.update_slime_actions()
		else
			to_chat(H, SPAN_WARNING("You need to hold an unused slime extract in your active hand!"))

/datum/action/innate/use_extract
	name = "Extract Minor Activation"
	desc = "Pulse the slime extract with energized jelly to activate it."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeuse1"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	var/activation_type = SLIME_ACTIVATE_MINOR

/datum/action/innate/use_extract/IsAvailable()
	if(..())
		var/datum/species/jelly/luminescent/species = target
		if(species && species.current_extract && (world.time > species.extract_cooldown))
			return TRUE
		return FALSE

/datum/action/innate/use_extract/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	..(current_button, TRUE)
	var/datum/species/jelly/luminescent/species = owner
	if(species?.current_extract)
		current_button.add_overlay(mutable_appearance(species.current_extract.icon, species.current_extract.icon_state))

/datum/action/innate/use_extract/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/jelly/luminescent/species = owner
	if(!is_species(H, /datum/species/jelly/luminescent) || !species)
		return
	CHECK_DNA_AND_SPECIES(H)

	if(species.current_extract)
		species.extract_cooldown = world.time + 100
		var/cooldown = species.current_extract.activate(H, species, activation_type)
		species.extract_cooldown = world.time + cooldown

/datum/action/innate/use_extract/major
	name = "Extract Major Activation"
	desc = "Pulse the slime extract with plasma jelly to activate it."
	button_icon_state = "slimeuse2"
	activation_type = SLIME_ACTIVATE_MAJOR

///////////////////////////////////STARGAZERS//////////////////////////////////////////

//Stargazers are the telepathic branch of jellypeople, able to project psychic messages and to link minds with willing participants.

/datum/species/jelly/stargazer
	name = "Stargazer"
	id = "stargazer"
	var/datum/action/innate/project_thought/project_thought
	var/datum/action/innate/link_minds/link_minds
	var/list/mob/living/linked_mobs = list()
	var/list/datum/action/innate/linked_speech/linked_actions = list()
	var/datum/weakref/slimelink_owner
	var/current_link_id = 0

//Species datums don't normally implement destroy, but JELLIES SUCK ASS OUT OF A STEEL STRAW
/datum/species/jelly/stargazer/Destroy()
	for(var/mob/living/link_to_clear as anything in linked_mobs)
		unlink_mob(link_to_clear)
	linked_mobs.Cut()
	QDEL_NULL(project_thought)
	QDEL_NULL(link_minds)
	slimelink_owner = null
	return ..()

/datum/species/jelly/stargazer/on_species_loss(mob/living/carbon/C)
	..()
	for(var/mob/living/link_to_clear as anything in linked_mobs)
		unlink_mob(link_to_clear)
	if(project_thought)
		QDEL_NULL(project_thought)
	if(link_minds)
		QDEL_NULL(link_minds)
	slimelink_owner = null

/datum/species/jelly/stargazer/spec_death(gibbed, mob/living/carbon/human/H)
	..()
	for(var/mob/living/link_to_clear as anything in linked_mobs)
		unlink_mob(link_to_clear)

/datum/species/jelly/stargazer/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	project_thought = new(src)
	project_thought.Grant(C)
	link_minds = new(src)
	link_minds.Grant(C)
	slimelink_owner = WEAKREF(C)
	link_mob(C)

/datum/species/jelly/stargazer/proc/link_mob(mob/living/M)
	if(QDELETED(M) || M.stat == DEAD)
		return FALSE
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD)) //mindshield implant, no dice
		return FALSE
	if(M.anti_magic_check(FALSE, FALSE, TRUE, 0))
		return FALSE
	if(M in linked_mobs)
		return FALSE
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	if(!owner)
		return FALSE
	linked_mobs.Add(M)
	to_chat(M, SPAN_NOTICE("You are now connected to [owner.real_name]'s Slime Link."))
	var/datum/action/innate/linked_speech/action = new(src)
	linked_actions.Add(action)
	action.Grant(M)
	RegisterSignal(M, COMSIG_LIVING_DEATH , .proc/unlink_mob)
	RegisterSignal(M, COMSIG_PARENT_QDELETING, .proc/unlink_mob)
	return TRUE

/datum/species/jelly/stargazer/proc/unlink_mob(mob/living/M)
	SIGNAL_HANDLER
	var/link_id = linked_mobs.Find(M)
	if(!(link_id))
		return
	UnregisterSignal(M, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
	var/datum/action/innate/linked_speech/action = linked_actions[link_id]
	action.Remove(M)
	var/mob/living/carbon/human/owner = slimelink_owner.resolve()
	if(owner)
		to_chat(M, SPAN_NOTICE("You are no longer connected to [owner.real_name]'s Slime Link."))
	linked_mobs -= M
	linked_actions -= action
	qdel(action)

/datum/action/innate/linked_speech
	name = "Slimelink"
	desc = "Send a psychic message to everyone connected to your slime link."
	button_icon_state = "link_speech"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/linked_speech/Activate()
	var/mob/living/carbon/human/H = owner
	if(H.stat == DEAD)
		return
	var/datum/species/jelly/stargazer/species = target
	if(!species || !(H in species.linked_mobs))
		to_chat(H, SPAN_WARNING("The link seems to have been severed..."))
		Remove(H)
		return

	var/message = sanitize(input("Message:", "Slime Telepathy") as text|null)

	if(!species || !(H in species.linked_mobs))
		to_chat(H, SPAN_WARNING("The link seems to have been severed..."))
		Remove(H)
		return

	var/mob/living/carbon/human/star_owner = species.slimelink_owner.resolve()

	if(message && star_owner)
		var/msg = "<i><font color=#008CA2>\[[star_owner.real_name]'s Slime Link\] <b>[H]:</b> [message]</font></i>"
		log_directed_talk(H, star_owner, msg, LOG_SAY, "slime link")
		for(var/X in species.linked_mobs)
			var/mob/living/M = X
			to_chat(M, msg)

		for(var/X in GLOB.dead_mob_list)
			var/mob/M = X
			var/link = FOLLOW_LINK(M, H)
			to_chat(M, "[link] [msg]")

/datum/action/innate/project_thought
	name = "Send Thought"
	desc = "Send a private psychic message to someone you can see."
	button_icon_state = "send_mind"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/project_thought/Activate()
	var/mob/living/carbon/human/H = owner
	if(H.stat == DEAD)
		return
	if(!is_species(H, /datum/species/jelly/stargazer))
		return
	CHECK_DNA_AND_SPECIES(H)

	var/list/options = list()
	for(var/mob/living/Ms in oview(H))
		options += Ms
	var/mob/living/M = input("Select who to send your message to:","Send thought to?",null) as null|mob in sortNames(options)
	if(!M)
		return
	if(M.anti_magic_check(FALSE, FALSE, TRUE, 0))
		to_chat(H, SPAN_NOTICE("As you try to communicate with [M], you're suddenly stopped by a vision of a massive tinfoil wall that streches beyond visible range. It seems you've been foiled."))
		return
	var/msg = sanitize(input("Message:", "Telepathy") as text|null)
	if(msg)
		if(M.anti_magic_check(FALSE, FALSE, TRUE, 0))
			to_chat(H, SPAN_NOTICE("As you try to communicate with [M], you're suddenly stopped by a vision of a massive tinfoil wall that streches beyond visible range. It seems you've been foiled."))
			return
		log_directed_talk(H, M, msg, LOG_SAY, "slime telepathy")
		to_chat(M, "[SPAN_NOTICE("You hear an alien voice in your head... ")]<font color=#008CA2>[msg]</font>")
		to_chat(H, SPAN_NOTICE("You telepathically said: \"[msg]\" to [M]"))
		for(var/dead in GLOB.dead_mob_list)
			if(!isobserver(dead))
				continue
			var/follow_link_user = FOLLOW_LINK(dead, H)
			var/follow_link_target = FOLLOW_LINK(dead, M)
			to_chat(dead, "[follow_link_user] [SPAN_NAME("[H]")] [SPAN_ALERTALIEN("Slime Telepathy --> ")] [follow_link_target] [SPAN_NAME("[M]")] [SPAN_NOTICEALIEN("[msg]")]")

/datum/action/innate/link_minds
	name = "Link Minds"
	desc = "Link someone's mind to your Slime Link, allowing them to communicate telepathically with other linked minds."
	button_icon_state = "mindlink"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/link_minds/Activate()
	var/mob/living/carbon/human/H = owner
	if(!is_species(H, /datum/species/jelly/stargazer))
		return
	CHECK_DNA_AND_SPECIES(H)

	if(!H.pulling || !isliving(H.pulling) || H.grab_state < GRAB_AGGRESSIVE)
		to_chat(H, SPAN_WARNING("You need to aggressively grab someone to link minds!"))
		return

	var/mob/living/target = H.pulling
	var/datum/species/jelly/stargazer/species = target

	to_chat(H, SPAN_NOTICE("You begin linking [target]'s mind to yours..."))
	to_chat(target, SPAN_WARNING("You feel a foreign presence within your mind..."))
	if(do_after(H, 60, target = target))
		if(H.pulling != target || H.grab_state < GRAB_AGGRESSIVE)
			return
		if(species.link_mob(target))
			to_chat(H, SPAN_NOTICE("You connect [target]'s mind to your slime link!"))
		else
			to_chat(H, SPAN_WARNING("You can't seem to link [target]'s mind..."))
			to_chat(target, SPAN_WARNING("The foreign presence leaves your mind."))

/datum/species/jelly/roundstartslime
	name = "Xenobiological Slime Hybrid"
	id = "slimeperson"
	flavor_text = "A slime-based lifeform with the ability to regenerate. Eating will slowly build up more mass, but anti-toxin based medicine will result in a purge. Highly vulnerable to the cold, but resistant to heat and burns. This variant has body-morphic capabilities."
	limbs_id = "slime"
	limbs_icon = 'icons/mob/species/slime_parts_greyscale.dmi'
	default_color = "0FF"
	say_mod = "says"
	coldmod = 3
	heatmod = 1
	burnmod = 1
	specific_alpha = 155
	markings_alpha = 130 //This is set lower than the other so that the alpha values don't stack on top of each other so much


/datum/action/innate/slime_change
	name = "Alter Form"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alter_form"
	icon_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	var/slime_restricted = TRUE

/datum/action/innate/slime_change/admin
	slime_restricted = FALSE

/datum/action/innate/slime_change/Activate()
	var/mob/living/carbon/human/H = owner
	if(slime_restricted && !isjellyperson(H))
		return
	if(slime_restricted)
		H.visible_message(
			SPAN_NOTICE("[owner] gains a look of \
				concentration while standing perfectly still.\
				Their body seems to shift and starts getting more goo-like."),
			SPAN_NOTICE("You focus intently on altering your body while \
				standing perfectly still...")
		)
	change_form()

/datum/action/innate/slime_change/proc/change_form()
	var/mob/living/carbon/human/H = owner
	var/select_alteration = input(H, "Select what part of your form to alter", "Form Alteration", "cancel") in list("Body Colors","Hair Style", "Facial Hair Style", "Mutant Body Parts", "Markings", "DNA Specifics", "Cancel")
	if(!select_alteration || select_alteration == "Cancel" || QDELETED(H))
		return
	var/datum/dna/DNA = H.dna
	switch(select_alteration)
		if("Body Colors")
			var/color_choice = input(H, "What color would you like to change?", "Form Alteration", "cancel") in list("Primary", "Secondary", "Tertiary", "All", "Cancel")
			if(!color_choice || color_choice == "Cancel" || QDELETED(H))
				return
			var/color_target
			switch(color_choice)
				if("Primary", "All")
					color_target = "mcolor"
				if("Secondary")
					color_target = "mcolor2"
				if("Tertiary")
					color_target = "mcolor3"
			var/new_mutantcolor = input(H, "Choose your character's new [lowertext(color_choice)] color:", "Form Alteration","#"+DNA.features[color_target]) as color|null
			if(!new_mutantcolor)
				return
			var/marking_reset = tgui_alert(
				H,
				"Would you like to reset your markings to match your new colors?",
				null,
				list("Yes", "No")
			)
			var/mutantpart_reset = tgui_alert(
				H,
				"Would you like to reset your mutant body parts (not limbs) to match your new colors?",
				null,
				list("Yes", "No")
			)
			if(color_choice == "All")
				DNA.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
				DNA.features["mcolor2"] = sanitize_hexcolor(new_mutantcolor)
				DNA.features["mcolor3"] = sanitize_hexcolor(new_mutantcolor)
			else
				DNA.features[color_target] = sanitize_hexcolor(new_mutantcolor)
			if(marking_reset && marking_reset == "Yes")
				for(var/zone in DNA.body_markings)
					for(var/key in DNA.body_markings[zone])
						var/datum/body_marking/BD = GLOB.body_markings[key]
						if(BD.always_color_customizable)
							continue
						DNA.body_markings[zone][key] = BD.get_default_color(DNA.features, DNA.species)
				H.icon_render_key = "" //Currently the render key doesnt recognize the markings colors
			if(mutantpart_reset && mutantpart_reset == "Yes")
				H.mutant_renderkey = "" //Just in case
				for(var/mutant_key in DNA.species.mutant_bodyparts)
					var/mutant_list = DNA.species.mutant_bodyparts[mutant_key]
					var/datum/sprite_accessory/SP = GLOB.sprite_accessories[mutant_key][mutant_list[MUTANT_INDEX_NAME]]
					mutant_list[MUTANT_INDEX_COLOR_LIST] = SP.get_default_color(DNA.features, DNA.species)

			H.update_body()
			H.update_hair()
		if("Hair Style")
			var/new_style = input(owner, "Select a hair style", "Hair Alterations")  as null|anything in GLOB.hairstyles_list
			if(new_style)
				H.hairstyle = new_style
				H.update_hair()
		if("Facial Hair Style")
			var/new_style = input(H, "Select a facial hair style", "Hair Alterations")  as null|anything in GLOB.facial_hairstyles_list
			if(new_style)
				H.facial_hairstyle = new_style
				H.update_hair()
		if("Mutant Body Parts")
			var/list/key_list = DNA.mutant_bodyparts
			var/chosen_key = input(H, "Select the part you want to alter", "Body Part Alterations")  as null|anything in key_list + "Cancel"
			if(!chosen_key || chosen_key == "Cancel")
				return
			var/choice_list = GLOB.sprite_accessories[chosen_key]
			var/chosen_name_key = input(H, "What do you want the part to become?", "Body Part Alterations")  as null|anything in choice_list + "Cancel"
			if(!chosen_name_key || chosen_name_key == "Cancel")
				return
			var/datum/sprite_accessory/SA = GLOB.sprite_accessories[chosen_key][chosen_name_key]
			H.mutant_renderkey = "" //Just in case
			if(!SA.factual)
				if(SA.organ_type)
					var/obj/item/organ/path = SA.organ_type
					var/slot = initial(path.slot)
					var/obj/item/organ/got_organ = H.getorganslot(slot)
					if(got_organ)
						got_organ.Remove(H)
						qdel(got_organ)
				else
					DNA.species.mutant_bodyparts -= chosen_key
			else
				if(SA.organ_type)
					var/obj/item/organ/path = SA.organ_type
					var/slot = initial(path.slot)
					var/obj/item/organ/got_organ = H.getorganslot(slot)
					if(got_organ)
						got_organ.Remove(H)
						qdel(got_organ)
					path = new SA.organ_type
					var/list/new_acc_list = list()
					new_acc_list[MUTANT_INDEX_NAME] = SA.name
					new_acc_list[MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(DNA.features, DNA.species)
					DNA.mutant_bodyparts[chosen_key] = new_acc_list.Copy()
					if(ROBOTIC_DNA_ORGANS in DNA.species.species_traits)
						path.status = ORGAN_ROBOTIC
						path.organ_flags |= ORGAN_SYNTHETIC
					path.build_from_dna(DNA, chosen_key)
					path.Insert(H, 0, FALSE)

				else
					var/list/new_acc_list = list()
					new_acc_list[MUTANT_INDEX_NAME] = SA.name
					new_acc_list[MUTANT_INDEX_COLOR_LIST] = SA.get_default_color(DNA.features, DNA.species)
					DNA.species.mutant_bodyparts[chosen_key] = new_acc_list
					DNA.mutant_bodyparts[chosen_key] = new_acc_list.Copy()
			H.update_mutant_bodyparts()
		if("Markings")
			var/list/candidates = GLOB.body_marking_sets
			var/chosen_name = input(H, "Select which set of markings would you like to change into", "Marking Alterations")  as null|anything in candidates + "Cancel"
			if(!chosen_name || chosen_name == "Cancel")
				return
			var/datum/body_marking_set/BMS = GLOB.body_marking_sets[chosen_name]
			DNA.species.body_markings = assemble_body_markings_from_set(BMS, DNA.features, DNA.species)
			H.icon_render_key = "" //Just in case
			H.update_body()
		if("DNA Specifics")
			var/dna_alteration = input(H, "Select what part of your DNA you'd like to alter", "DNA Alteration", "cancel") in list("Penis Size","Penis Girth", "Penis Sheath", "Penis Taur Mode", "Balls Size", "Breasts Size", "Breasts Lactation", "Body Size", "Cancel")
			if(!dna_alteration || dna_alteration == "Cancel")
				return
			switch(dna_alteration)
				if("Breasts Size")
					var/new_size = input(H, "Choose your character's breasts size:", "DNA Alteration") as null|anything in GLOB.preference_breast_sizes
					if(new_size)
						DNA.features["breasts_size"] = breasts_cup_to_size(new_size)
						var/obj/item/organ/genital/breasts/melons = H.getorganslot(ORGAN_SLOT_BREASTS)
						if(melons)
							melons.set_size(DNA.features["breasts_size"])
				if("Breasts Lactation")
					DNA.features["breasts_lactation"] = !DNA.features["breasts_lactation"]
					var/obj/item/organ/genital/breasts/melons = H.getorganslot(ORGAN_SLOT_BREASTS)
					if(melons)
						melons.lactates = DNA.features["breasts_lactation"]
					to_chat(H, SPAN_NOTICE("Your breasts [DNA.features["breasts_lactation"] ? "will now lactate" : "will not lactate anymore"]."))
				if("Penis Taur Mode")
					DNA.features["penis_taur_mode"] = !DNA.features["penis_taur_mode"]
					to_chat(H, SPAN_NOTICE("Your penis [DNA.features["penis_taur_mode"] ? "will be at your taur part" : "will not be at your taur part anymore"]."))
				if("Penis Size")
					var/new_length = input(H, "Choose your penis length:\n([PENIS_MIN_LENGTH]-[PENIS_MAX_LENGTH] in inches)", "DNA Alteration") as num|null
					if(new_length)
						DNA.features["penis_size"] = clamp(round(new_length, 1), PENIS_MIN_LENGTH, PENIS_MAX_LENGTH)
						var/obj/item/organ/genital/penis/PP = H.getorganslot(ORGAN_SLOT_PENIS)
						if(DNA.features["penis_girth"] >= new_length)
							DNA.features["penis_girth"] = new_length - 1
							if(PP)
								PP.girth = DNA.features["penis_girth"]
						if(PP)
							PP.set_size(DNA.features["penis_size"])
				if("Penis Sheath")
					var/new_sheath = input(H, "Choose your penis sheath", "DNA Alteration") as null|anything in SHEATH_MODES
					if(new_sheath)
						DNA.features["penis_sheath"] = new_sheath
						var/obj/item/organ/genital/penis/PP = H.getorganslot(ORGAN_SLOT_PENIS)
						if(PP)
							PP.sheath = new_sheath
				if("Penis Girth")
					var/max_girth = PENIS_MAX_GIRTH
					if(DNA.features["penis_size"] >= max_girth)
						max_girth = DNA.features["penis_size"]
					var/new_girth = input(H, "Choose your penis girth:\n(1-[max_girth] (based on length) in inches)", "Character Preference") as num|null
					if(new_girth)
						DNA.features["penis_girth"] = clamp(round(new_girth, 1), 1, max_girth)
						var/obj/item/organ/genital/penis/PP = H.getorganslot(ORGAN_SLOT_PENIS)
						if(PP)
							PP.girth = DNA.features["penis_girth"]
				if("Balls Size")
					var/new_size = input(H, "Choose your character's balls size:", "Character Preference") as null|anything in GLOB.preference_balls_sizes
					if(new_size)
						DNA.features["balls_size"] = balls_description_to_size(new_size)
						var/obj/item/organ/genital/testicles/avocados = H.getorganslot(ORGAN_SLOT_TESTICLES)
						if(avocados)
							avocados.set_size(DNA.features["balls_size"])
				if("Body Size")
					var/new_body_size = input(H, "Choose your desired sprite size:\n([BODY_SIZE_MIN*100]%-[BODY_SIZE_MAX*100]%), Warning: May make your character look distorted", "Character Preference", DNA.features["body_size"]*100) as num|null
					if(new_body_size)
						new_body_size = clamp(new_body_size * 0.01, BODY_SIZE_MIN, BODY_SIZE_MAX)
						DNA.features["body_size"] = new_body_size
						DNA.update_body_size()
			H.mutant_renderkey = "" //Just in case
			H.update_mutant_bodyparts()
