/datum/surgery/plastic_surgery
	name = "Plastic surgery"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/reshape_face,
		/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_HEAD)

//reshape_face
/datum/surgery_step/reshape_face
	name = "reshape face"
	implements = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 50,
		TOOL_WIRECUTTER = 35)
	time = 64

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(SPAN_NOTICE("[user] begins to alter [target]'s appearance."), SPAN_NOTICE("You begin to alter [target]'s appearance..."))
	display_results(user, target, SPAN_NOTICE("You begin to alter [target]'s appearance..."),
		SPAN_NOTICE("[user] begins to alter [target]'s appearance."),
		SPAN_NOTICE("[user] begins to make an incision in [target]'s face."))

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(HAS_TRAIT_FROM(target, TRAIT_DISFIGURED, TRAIT_GENERIC))
		REMOVE_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
		display_results(user, target, SPAN_NOTICE("You successfully restore [target]'s appearance."),
			SPAN_NOTICE("[user] successfully restores [target]'s appearance!"),
			SPAN_NOTICE("[user] finishes the operation on [target]'s face."))
	else
		var/list/names = list()
		if(!isabductor(user))
			for(var/i in 1 to 10)
				names += target.dna.species.random_name(target.gender, TRUE)
		else
			for(var/_i in 1 to 9)
				names += "Subject [target.gender == MALE ? "i" : "o"]-[pick("a", "b", "c", "d", "e")]-[rand(10000, 99999)]"
			names += target.dna.species.random_name(target.gender, TRUE) //give one normal name in case they want to do regular plastic surgery
		var/chosen_name = input(user, "Choose a new name to assign.", "Plastic Surgery") as null|anything in names
		if(!chosen_name)
			return
		var/oldname = target.real_name
		target.real_name = chosen_name
		var/newname = target.real_name //something about how the code handles names required that I use this instead of target.real_name
		display_results(user, target, SPAN_NOTICE("You alter [oldname]'s appearance completely, [target.p_they()] is now [newname]."),
			SPAN_NOTICE("[user] alters [oldname]'s appearance completely, [target.p_they()] is now [newname]!"),
			SPAN_NOTICE("[user] finishes the operation on [target]'s face."))
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		human_target.sec_hud_set_ID()
	return ..()

/datum/surgery_step/reshape_face/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, SPAN_WARNING("You screw up, leaving [target]'s appearance disfigured!"),
		SPAN_NOTICE("[user] screws up, disfiguring [target]'s appearance!"),
		SPAN_NOTICE("[user] finishes the operation on [target]'s face."))
	ADD_TRAIT(target, TRAIT_DISFIGURED, TRAIT_GENERIC)
	return FALSE
