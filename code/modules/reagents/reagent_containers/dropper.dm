/obj/item/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Holds up to 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	worn_icon_state = "pen"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	reagent_flags = TRANSPARENT
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/dropper/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!target.reagents)
		return

	if(reagents.total_volume > 0)
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, SPAN_NOTICE("[target] is full."))
			return

		if(!target.is_injectable(user))
			to_chat(user, SPAN_WARNING("You cannot transfer reagents to [target]!"))
			return

		var/trans = 0
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)

		if(ismob(target))
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = victim.is_eyes_covered()

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)

					trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this, transfered_by = user, methods = TOUCH)

					target.visible_message(SPAN_DANGER("[user] tries to squirt something into [target]'s eyes, but fails!"), \
											SPAN_USERDANGER("[user] tries to squirt something into your eyes, but fails!"))

					to_chat(user, SPAN_NOTICE("You transfer [trans] unit\s of the solution."))
					update_appearance()
					return
			else if(isalien(target)) //hiss-hiss has no eyes!
				to_chat(target, SPAN_DANGER("[target] does not seem to have any eyes!"))
				return

			target.visible_message(SPAN_DANGER("[user] squirts something into [target]'s eyes!"), \
									SPAN_USERDANGER("[user] squirts something into your eyes!"))

			reagents.expose(target, TOUCH, fraction)
			var/mob/M = target
			var/R
			if(reagents)
				for(var/datum/reagent/A in src.reagents.reagent_list)
					R += "[A] ([num2text(A.volume)]),"

			log_combat(user, M, "squirted", R)

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, SPAN_NOTICE("You transfer [trans] unit\s of the solution."))
		update_appearance()

	else

		if(!target.is_drawable(user, FALSE)) //No drawing from mobs here
			to_chat(user, SPAN_WARNING("You cannot directly remove reagents from [target]!"))
			return

		if(!target.reagents.total_volume)
			to_chat(user, SPAN_WARNING("[target] is empty!"))
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)

		to_chat(user, SPAN_NOTICE("You fill [src] with [trans] unit\s of the solution."))

		update_appearance()

/obj/item/reagent_containers/dropper/update_overlays()
	. = ..()
	if(!reagents.total_volume)
		return
	var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "dropper")
	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling
