/datum/disease/cordyceps
	form = "Disease"
	name = "Cordyceps omniteralis"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin & Convermol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/c2/convermol)
	agent = "Fungal Cordycep bacillus"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 30
	desc = "Fungal virus that attacks patient's muscles and brain in an attempt to hijack them. Causes fever, headaches, muscle spasms, and fatigue."
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE

/datum/disease/cordyceps/stage_act()
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("twitch")
				to_chat(affected_mob, SPAN_DANGER("You twitch."))
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("Your feel tired"))
			if(prob(5))
				to_chat(affected_mob, SPAN_DANGER("You head hurts."))
		if(3,4)
			if(prob(2))
				to_chat(affected_mob, SPAN_USERDANGER("You see four of everything!"))
				affected_mob.Dizzy(5)
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("You suddenly feel exhausted."))
				affected_mob.adjustStaminaLoss(30, FALSE)
			if(prob(2))
				to_chat(affected_mob, SPAN_DANGER("You feel hot."))
				affected_mob.adjust_bodytemperature(20)
		if(5)
			if(prob(5))
				to_chat(affected_mob, SPAN_USERDANGER("[pick("Your muscles seize!", "You collapse!")]"))
				affected_mob.adjustStaminaLoss(50, FALSE)
				affected_mob.Paralyze(40, FALSE)
				affected_mob.adjustBruteLoss(5) //It's damaging the muscles
			if(prob(2))
				affected_mob.adjustStaminaLoss(100, FALSE)
				affected_mob.visible_message(SPAN_WARNING("[affected_mob] faints!"), SPAN_USERDANGER("You surrender yourself and feel at peace..."))
				affected_mob.AdjustSleeping(100)
			if(prob(5))
				to_chat(affected_mob, SPAN_USERDANGER("You feel your mind relax and your thoughts drift!"))
				affected_mob.set_confusion(min(100, affected_mob.get_confusion() + 8))
				affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
			if(prob(10))
				to_chat(affected_mob, SPAN_DANGER("[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]"))
				affected_mob.adjust_bodytemperature(30)

/datum/reagent/cordycepsspores
	name = "Cordycep bacillus microbes"
	description = "Active fungal spores."
	color = "#92D17D"
	chemical_flags = NONE
	taste_description = "slime"
	penetrates_skin = NONE

/datum/reagent/cordycepsspores/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/cordyceps(), FALSE, TRUE)
