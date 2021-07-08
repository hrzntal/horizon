/// Gives the target fake scars
/datum/smite/scarify
	name = "Scarify"

/datum/smite/scarify/effect(client/user, mob/living/target)
	. = ..()
	if(!iscarbon(target))
		to_chat(user, SPAN_WARNING("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/dude = target
	dude.generate_fake_scars(rand(1, 4))
	to_chat(dude, SPAN_WARNING("You feel your body grow jaded and torn..."))
