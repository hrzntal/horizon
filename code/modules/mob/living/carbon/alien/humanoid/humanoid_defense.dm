

/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(15)
	var/hitverb = "hit"
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = "slam"
	playsound(loc, "punch", 25, TRUE, -1)
	visible_message(SPAN_DANGER("[user] [hitverb]s [src]!"), \
					SPAN_USERDANGER("[user] [hitverb]s you!"), SPAN_HEAR("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, SPAN_DANGER("You [hitverb] [src]!"))

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!..() || !user.combat_mode)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if (body_position == STANDING_UP)
			if (prob(5))
				Unconscious(40)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				log_combat(user, src, "pushed")
				visible_message(SPAN_DANGER("[user] pushes [src] down!"), \
								SPAN_USERDANGER("[user] pushes you down!"), SPAN_HEAR("You hear aggressive shuffling followed by a loud thud!"), null, user)
				to_chat(user, SPAN_DANGER("You push [src] down!"))
		return TRUE
	var/damage = rand(1, 9)
	if (prob(90))
		playsound(loc, "punch", 25, TRUE, -1)
		visible_message(SPAN_DANGER("[user] punches [src]!"), \
						SPAN_USERDANGER("[user] punches you!"), SPAN_HEAR("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, SPAN_DANGER("You punch [src]!"))
		if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
			Unconscious(40)
			visible_message(SPAN_DANGER("[user] knocks [src] down!"), \
							SPAN_USERDANGER("[user] knocks you down!"), SPAN_HEAR("You hear a sickening sound of flesh hitting flesh!"), null, user)
			to_chat(user, SPAN_DANGER("You knock [src] down!"))
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
		apply_damage(damage, BRUTE, affecting)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		visible_message(SPAN_DANGER("[user]'s punch misses [src]!"), \
						SPAN_DANGER("You avoid [user]'s punch!"), SPAN_HEAR("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, SPAN_WARNING("Your punch misses [src]!"))


/mob/living/carbon/alien/humanoid/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
