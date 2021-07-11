/obj/item/organ/brain/ipc_positron
	name = "positronic brain carcass"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "posibrain-ipc"

/obj/item/organ/brain/ipc_positron/Insert(mob/living/carbon/C, special = 0, drop_if_replaced = TRUE)
	..()
	if(C.stat == DEAD && ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H?.dna?.species && (REVIVES_BY_HEALING in H.dna.species.species_traits))
			if(H.health > 50)
				H.revive(FALSE)

/obj/item/organ/brain/ipc_positron/emp_act(severity)
	switch(severity)
		if(1)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 75, 150)
			to_chat(owner, SPAN_WARNING("Alert: Posibrain heavily damaged."))
		if(2)
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25, 150)
			to_chat(owner, SPAN_WARNING("Alert: Posibrain damaged."))

/obj/item/organ/stomach/robot_ipc
	name = "IPC micro cell"
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "stomach-ipc"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "stomach"
	desc = "A specialised cell, for IPC use only. Do not swallow."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/stomach/robot_ipc/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			owner.nutrition = 50
			to_chat(owner, SPAN_WARNING("Alert: Detected severe battery discharge!"))
		if(2)
			owner.nutrition = 250
			to_chat(owner, SPAN_WARNING("Alert: Minor battery discharge!"))

/obj/item/organ/ears/robot_ipc
	name = "auditory sensors"
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "ears-ipc"
	desc = "A pair of microphones intended to be installed in an IPC head, that grant the ability to hear."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/ears/robot_ipc/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			owner.Jitter(30)
			owner.Dizzy(30)
			owner.Knockdown(80)
			deaf = 30
			to_chat(owner, SPAN_WARNING("Your robotic ears are ringing, uselessly."))
		if(2)
			owner.Jitter(15)
			owner.Dizzy(15)
			owner.Knockdown(40)
			to_chat(owner, SPAN_WARNING("Your robotic ears buzz."))

/obj/item/organ/tongue/robot_ipc
	name = "robotic voicebox"
	desc = "A voice synthesizer that can interface with organic lifeforms."
	status = ORGAN_ROBOTIC
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "tongue-ipc"
	say_mod = "beeps"
	modifies_speech = TRUE
	taste_sensitivity = 25 // not as good as an organic tongue
	maxHealth = 100 //RoboTongue!
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/tongue/robot_ipc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPEECH_SPAN_ROBOT

/obj/item/organ/eyes/robot_ipc
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "A very basic set of optical sensors with no extra vision modes or functions."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/eyes/robot_ipc/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, SPAN_WARNING("Static obfuscates your vision!"))
	owner.flash_act(visual = 1)
	if(severity == EMP_HEAVY)
		owner.adjustOrganLoss(ORGAN_SLOT_EYES, 20)

/obj/item/organ/lungs/robot_ipc
	name = "heat sink"
	desc = "A device that transfers generated heat to a fluid medium to cool it down. Required to keep your synthetics cool-headed. It's shape resembles lungs." //Purposefully left the 'fluid medium' ambigious for interpretation of the character, whether it be air or fluid cooling
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "lungs-ipc"
	safe_nitro_min = 0
	safe_nitro_max = 0
	safe_co2_min = 0
	safe_co2_max = 0
	safe_toxins_min = 0
	safe_toxins_max = 0
	safe_oxygen_min = 0	//What are you doing man, dont breathe with those!
	safe_oxygen_max = 0
	cold_level_1_damage = 0
	cold_level_2_damage = 0
	cold_level_3_damage = 0
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/lungs/robot_ipc/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			to_chat(owner, SPAN_WARNING("Alert: Critical cooling system failure!"))
			owner.adjust_bodytemperature(100*TEMPERATURE_DAMAGE_COEFFICIENT)
		if(2)
			owner.adjust_bodytemperature(30*TEMPERATURE_DAMAGE_COEFFICIENT)

/obj/item/organ/heart/robot_ipc
	name = "hydraulic pump engine"
	desc = "An electronic device that handles the hydraulic pumps, powering one's robotic limbs."
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "heart-ipc"

/obj/item/organ/liver/robot_ipc
	name = "reagent processing unit"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	icon = 'icons/obj/ipc_surgery.dmi'
	icon_state = "liver-ipc"
	filterToxins = FALSE //We dont filter them, we're immune ot them

/obj/item/organ/cyberimp/arm/power_cord
	name = "power cord implant"
	desc = "An internal power cord hooked up to a battery. Useful if you run on volts."
	contents = newlist(/obj/item/apc_powercord)
	zone = "l_arm"

/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord hooked up to a battery. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/machinery/power/apc) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/machinery/power/apc/A = target
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/stomach/robot_ipc/cell = locate(/obj/item/organ/stomach/robot_ipc) in H.internal_organs
	if(!cell)
		to_chat(H, SPAN_WARNING("You try to siphon energy from the [A], but your power cell is gone!"))
		return

	if(A.cell && A.cell.charge > 0)
		if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
			to_chat(user, SPAN_WARNING("You are already fully charged!"))
			return
		else
			powerdraw_loop(A, H)
			return

	to_chat(user, SPAN_WARNING("There is no charge to draw from that APC."))

/obj/item/apc_powercord/proc/powerdraw_loop(obj/machinery/power/apc/A, mob/living/carbon/human/H)
	H.visible_message(SPAN_NOTICE("[H] inserts a power connector into the [A]."), SPAN_NOTICE("You begin to draw power from the [A]."))
	while(do_after(H, 10, target = A))
		if(loc != H)
			to_chat(H, SPAN_WARNING("You must keep your connector out while charging!"))
			break
		if(A.cell.charge == 0)
			to_chat(H, SPAN_WARNING("The [A] doesn't have enough charge to spare."))
			break
		A.charging = 1
		if(A.cell.charge >= 500)
			do_sparks(1, FALSE, A)
			H.nutrition += 50
			A.cell.charge -= 150
			to_chat(H, SPAN_NOTICE("You siphon off some of the stored charge for your own use."))
		else
			H.nutrition += A.cell.charge/10
			A.cell.charge = 0
			to_chat(H, SPAN_NOTICE("You siphon off as much as the [A] can spare."))
			break
		if(H.nutrition > NUTRITION_LEVEL_WELL_FED)
			to_chat(H, SPAN_NOTICE("You are now fully charged."))
			break
	H.visible_message(SPAN_NOTICE("[H] unplugs from the [A]."), SPAN_NOTICE("You unplug from the [A]."))
