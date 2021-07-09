/mob/living/silicon/robot/examine(mob/user)
	. = list("<span class='info'>*---------*\nThis is [icon2html(src, user)] \a <EM>[src]</EM>!")
	if(desc)
		. += "[desc]"

	var/obj/act_module = get_active_held_item()
	if(act_module)
		. += "It is holding [icon2html(act_module, user)] \a [act_module]."
	. += status_effect_examines()
	if (getBruteLoss())
		if (getBruteLoss() < maxHealth*0.5)
			. += SPAN_WARNING("It looks slightly dented.")
		else
			. += SPAN_WARNING("<B>It looks severely dented!</B>")
	if (getFireLoss() || getToxLoss())
		var/overall_fireloss = getFireLoss() + getToxLoss()
		if (overall_fireloss < maxHealth * 0.5)
			. += SPAN_WARNING("It looks slightly charred.")
		else
			. += SPAN_WARNING("<B>It looks severely burnt and heat-warped!</B>")
	if (health < -maxHealth*0.5)
		. += SPAN_WARNING("It looks barely operational.")
	if (fire_stacks < 0)
		. += SPAN_WARNING("It's covered in water.")
	else if (fire_stacks > 0)
		. += SPAN_WARNING("It's coated in something flammable.")

	if(opened)
		. += SPAN_WARNING("Its cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		. += "Its cover is closed[locked ? "" : ", and looks unlocked"]."

	if(cell && cell.charge <= 0)
		. += SPAN_WARNING("Its battery indicator is blinking red!")

	switch(stat)
		if(CONSCIOUS)
			if(shell)
				. += "It appears to be an [deployed ? "active" : "empty"] AI shell."
			else if(!client)
				. += "It appears to be in stand-by mode." //afk
		if(SOFT_CRIT, UNCONSCIOUS, HARD_CRIT)
			. += SPAN_WARNING("It doesn't seem to be responding.")
		if(DEAD)
			. += SPAN_DEADSAY("It looks like its system is corrupted and requires a reset.")
	if(temporary_flavor_text)
		if(length_char(temporary_flavor_text) <= 40)
			. += SPAN_NOTICE("[temporary_flavor_text]")
		else
			. += SPAN_NOTICE("[copytext_char(temporary_flavor_text, 1, 37)]... <a href='?src=[REF(src)];temporary_flavor=1'>More...</a>")
	. += "*---------*</span>"

	. += ..()
