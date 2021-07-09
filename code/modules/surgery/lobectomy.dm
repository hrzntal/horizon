/datum/surgery/lobectomy
	name = "Lobectomy" //not to be confused with lobotomy
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/lobectomy,
		/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery/lobectomy/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/lungs/target_lungs = target.getorganslot(ORGAN_SLOT_LUNGS)
	if(target_lungs)
		if(target_lungs.damage > 60 && !target_lungs.operated)
			return TRUE
	return FALSE


//lobectomy, removes the most damaged lung lobe with a 95% base success chance
/datum/surgery_step/lobectomy
	name = "excise damaged lung node"
	implements = list(
		TOOL_SCALPEL = 95,
		/obj/item/melee/transforming/energy/sword = 65,
		/obj/item/kitchen/knife = 45,
		/obj/item/shard = 35)
	time = 42

/datum/surgery_step/lobectomy/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, SPAN_NOTICE("You begin to make an incision in [target]'s lungs..."),
		SPAN_NOTICE("[user] begins to make an incision in [target]."),
		SPAN_NOTICE("[user] begins to make an incision in [target]."))

/datum/surgery_step/lobectomy/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/organ/lungs/target_lungs = human_target.getorganslot(ORGAN_SLOT_LUNGS)
		target_lungs.operated = TRUE
		human_target.setOrganLoss(ORGAN_SLOT_LUNGS, 60)
		display_results(user, target, SPAN_NOTICE("You successfully excise [human_target]'s most damaged lobe."),
			SPAN_NOTICE("Successfully removes a piece of [human_target]'s lungs."),
			"")
	return ..()

/datum/surgery_step/lobectomy/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		display_results(user, target, SPAN_WARNING("You screw up, failing to excise [human_target]'s damaged lobe!"),
			SPAN_WARNING("[user] screws up!"),
			SPAN_WARNING("[user] screws up!"))
		human_target.losebreath += 4
		human_target.adjustOrganLoss(ORGAN_SLOT_LUNGS, 10)
	return FALSE
