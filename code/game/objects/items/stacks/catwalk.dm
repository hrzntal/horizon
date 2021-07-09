/obj/item/stack/catwalk
	name = "catwalk rods"
	singular_name = "catwalk rod"
	desc = "Rods that could be used to make a construction catwalk."
	icon = 'icons/obj/items/catwalk_item.dmi'
	icon_state = "catwalk"
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 3
	throw_range = 7
	max_amount = 60
	novariants = TRUE
	merge_type = /obj/item/stack/catwalk
	var/catwalk_type = /obj/structure/lattice/catwalk

/obj/item/stack/catwalk/plated
	name = "plated catwalk rods"
	singular_name = "plated catwalk rod"
	desc = "Rods that could be used to make a plated catwalk."
	icon_state = "catwalk_plated"
	merge_type = /obj/item/stack/catwalk/plated
	catwalk_type = /obj/structure/lattice/catwalk/plated

/obj/item/stack/catwalk/plated/dark
	name = "dark plated catwalk rods"
	singular_name = "dark plated catwalk rod"
	desc = "Rods that could be used to make a plated catwalk, with style."
	icon_state = "catwalk_plated_dark"
	merge_type = /obj/item/stack/catwalk/plated/dark
	catwalk_type = /obj/structure/lattice/catwalk/plated/dark

/obj/item/stack/catwalk/plated/smooth
	name = "smooth plated catwalk rods"
	singular_name = "smooth plated catwalk rod"
	desc = "Rods that could be used to make a plated catwalk, with style."
	icon_state = "catwalk_plated_smooth"
	merge_type = /obj/item/stack/catwalk/plated/smooth
	catwalk_type = /obj/structure/lattice/catwalk/plated/smooth

/obj/item/stack/catwalk/swarmer
	name = "swarmer catwalk rods"
	singular_name = "swarmer catwalk rod"
	desc = "Rods that could be used to make a quite peculiar catwalk."
	icon_state = "catwalk_swarmer"
	merge_type = /obj/item/stack/catwalk/swarmer
	catwalk_type = /obj/structure/lattice/catwalk/swarmer_catwalk
