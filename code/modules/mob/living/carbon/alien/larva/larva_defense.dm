

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(..())
		var/damage = rand(1, 9)
		if (prob(90))
			playsound(loc, "punch", 25, TRUE, -1)
			log_combat(user, src, "attacked")
			visible_message(SPAN_DANGER("[user] kicks [src]!"), \
							SPAN_USERDANGER("[user] kicks you!"), SPAN_HEAR("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, SPAN_DANGER("You kick [src]!"))
			if ((stat != DEAD) && (damage > 4.9))
				Unconscious(rand(100,200))

			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
			apply_damage(damage, BRUTE, affecting)
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			visible_message(SPAN_DANGER("[user]'s kick misses [src]!"), \
							SPAN_DANGER("You avoid [user]'s kick!"), SPAN_HEAR("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
			to_chat(user, SPAN_WARNING("Your kick misses [src]!"))

/mob/living/carbon/alien/larva/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(5 + rand(1,9))
	new /datum/forced_movement(src, get_step_away(user,src, 30), 1)

/mob/living/carbon/alien/larva/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_BITE
	..()
