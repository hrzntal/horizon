/obj/item/towel // TODO: better description and name
	name = "towel"
	desc = "towel"
	slot_flags = ITEM_SLOT_BACKPACK|ITEM_SLOT_BELT|ITEM_SLOT_HEAD|ITEM_SLOT_NECK|ITEM_SLOT_ICLOTHING
	icon = 'icons/obj/items/towel.dmi'
	icon_state = "towel"
	w_class = WEIGHT_CLASS_NORMAL
	worn_icon = 'icons/obj/items/towel.dmi'
	worn_icon_state = "towel_worn"
	/// Are we ready to assert dominance?
	var/ready_to_strike = FALSE
	/// If we are on harm mode, how much damage do we do
	var/harmy_force = 5

/obj/structure/towel
	name = "unfurled towel"
	density = FALSE
	icon = 'icons/obj/items/towel.dmi'
	icon_state = "towel_unfurl"
	var/obj/item/towel/actual

/obj/structure/towel/Initialize(mapload, towel)
	. = ..()
	actual = towel

/obj/structure/towel/Destroy()
	actual = null
	. = ..()

/obj/structure/towel/attack_hand_secondary(mob/user, modifiers)
	to_chat(user, SPAN_NOTICE("You pick up \the [src]"))
	user.put_in_active_hand(actual)
	qdel(src)

/obj/item/towel/update_icon_state()
	. = ..()

	if(!ishuman(loc))
		return

	icon_state = initial(icon_state) + ready_to_strike ? "_strike" : ""

	var/mob/living/carbon/human/holder = loc
	var/state_append = "_err"

	if(holder.backpack == src)
		state_append = "_back"

	if(holder.belt == src)
		state_append = "_belt"

	if(holder.head == src)
		state_append = "_head"

	if(holder.wear_neck == src)
		state_append = "_neck"

	if(holder.w_uniform == src)
		state_append = "_suit"

	worn_icon_state = initial(worn_icon_state) + state_append

/obj/item/towel/attack_self(mob/living/carbon/human/user, modifiers)
	if(ready_to_strike)
		ready_to_strike = FALSE
		to_chat(user, SPAN_NOTICE("You unfurl and untwist [src]"))
		return

	if(user.get_active_held_item() == src)
		if(!user.combat_mode)
			to_chat(user, SPAN_NOTICE("You lay [src] out on the ground."))
			new /obj/structure/towel(drop_location(), src)
			return

		if(user.get_inactive_held_item())
			to_chat(user, SPAN_NOTICE("You need both hands to do that!"))
			return

		user.visible_message(SPAN_NOTICE("[user] begins to twirl and twist [src] in their hands!"))
		icon_state = "twirling"
		if(!do_after(user, 2 SECONDS, src))
			user.visible_message(SPAN_NOTICE("[user] stops."))
			update_icon_state()
			return

		ready_to_strike = TRUE
		update_icon_state()
		return

	if(user.get_active_held_item())
		to_chat(user, SPAN_NOTICE("Your hand is full!"))
		return

	if(user.wear_neck == src || user.backpack == src)
		to_chat(user, SPAN_NOTICE("You deftly grab [src]."))
		user.wear_neck = null
		user.put_in_active_hand(src)
		return

	if(user.belt == src)
		user.visible_message(SPAN_NOTICE("[user] lets \the [src] around their waist drop to the ground."))
		user.dropItemToGround(src)
		return

	if(user.head == src)
		user.visible_message(SPAN_NOTICE("[user] messes with \the [src] on their head."))
		return

/obj/item/towel/attack(mob/living/victim, mob/living/user, params)
	. = ..()

	if(ready_to_strike)
		ready_to_strike = FALSE

		if(user.combat_mode && user.zone_selected == BODY_ZONE_HEAD) // uh oh
			user.visible_message(SPAN_DANGER("[user] strikes [victim] in the neck with [src]!"))
			var/obj/item/bodypart/bodypart = victim.get_bodypart(BODY_ZONE_HEAD)
			bodypart?.take_damage(harmy_force)
			return

		if(user.zone_selected == BODY_ZONE_PRECISE_GROIN)
			user.visible_message(SPAN_WARNING("[user] strikes [victim] in the groin with [src]!"))
			victim.Knockdown(0.5 SECONDS)
			return

		user.visible_message(SPAN_WARNING("[user] strikes [victim] with [src]!"))
