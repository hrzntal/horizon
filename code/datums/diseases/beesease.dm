/datum/disease/beesease
	name = "Beesease"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Sugar"
	cures = list(/datum/reagent/consumable/sugar)
	agent = "Apidae Infection"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "If left untreated subject will regurgitate bees."
	severity = DISEASE_SEVERITY_MEDIUM
	infectable_biotypes = MOB_ORGANIC|MOB_UNDEAD //bees nesting in corpses


/datum/disease/beesease/stage_act(delta_time, times_fired)
	. = ..()
	if(!.)
		return

	switch(stage)
		if(2) //also changes say, see say.dm
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, SPAN_NOTICE("You taste honey in your mouth."))
		if(3)
			if(DT_PROB(5, delta_time))
				to_chat(affected_mob, SPAN_NOTICE("Your stomach rumbles."))
			if(DT_PROB(1, delta_time))
				to_chat(affected_mob, SPAN_DANGER("Your stomach stings painfully."))
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(DT_PROB(5, delta_time))
				affected_mob.visible_message(SPAN_DANGER("[affected_mob] buzzes."), \
												SPAN_USERDANGER("Your stomach buzzes violently!"))
			if(DT_PROB(2.5, delta_time))
				to_chat(affected_mob, SPAN_DANGER("You feel something moving in your throat."))
			if(DT_PROB(0.5, delta_time))
				affected_mob.visible_message(SPAN_DANGER("[affected_mob] coughs up a swarm of bees!"), \
													SPAN_USERDANGER("You cough up a swarm of bees!"))
				new /mob/living/simple_animal/hostile/bee(affected_mob.loc)
