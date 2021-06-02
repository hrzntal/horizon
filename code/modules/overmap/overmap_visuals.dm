/obj/effect/abstract/overmap
	glide_size = 3
	layer = OVERMAP_LAYER_LOWEST
	icon = 'icons/overmap/overmap.dmi'
	icon_state = "event"
	/// The overmap object this visual effect is representing
	var/datum/overmap_object/my_overmap_object

/obj/effect/abstract/overmap/ruins
	icon_state = "event"
	layer = OVERMAP_LAYER_PLANET

/obj/effect/abstract/overmap/shuttle
	icon_state = "shuttle"
	animate_movement = NO_STEPS
	color = LIGHT_COLOR_CYAN
	layer = OVERMAP_LAYER_SHUTTLE
	var/shuttle_idle_state = "shuttle"
	var/shuttle_forward_state = "shuttle_forward"
	var/shuttle_backward_state = "shuttle_backwards"

/obj/effect/abstract/overmap/relaymove(mob/living/user, direction)
	my_overmap_object.relaymove(user, direction)

/obj/effect/abstract/overmap/shuttle/station
	color = COLOR_VERY_LIGHT_GRAY
	layer = OVERMAP_LAYER_STATION
	icon_state = "station"
	shuttle_idle_state = "station"
	shuttle_forward_state = "station"
	shuttle_backward_state = "station"

/obj/effect/abstract/overmap/shuttle/ship
	color = LIGHT_COLOR_ELECTRIC_CYAN
	layer = OVERMAP_LAYER_SHIP
	icon_state = "ship"
	shuttle_idle_state = "ship"
	shuttle_forward_state = "ship_forward"
	shuttle_backward_state = "ship_backwards"

/obj/effect/abstract/overmap/shuttle/planet
	icon_state = "globe"
	layer = OVERMAP_LAYER_PLANET
	shuttle_idle_state = "globe"
	shuttle_forward_state = "globe"
	shuttle_backward_state = "globe"

/obj/effect/abstract/overmap/shuttle/planet/lavaland
	color = LIGHT_COLOR_BLOOD_MAGIC

/obj/effect/abstract/overmap/shuttle/planet/jungle_planet
	color = COLOR_VERY_PALE_LIME_GREEN

/obj/effect/abstract/overmap/shuttle/planet/icebox
	color = COLOR_TEAL
