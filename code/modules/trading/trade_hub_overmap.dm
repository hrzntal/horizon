/datum/overmap_object/trade_hub
	name = "Trading Hub"
	visual_type = /obj/effect/abstract/overmap/trade_hub
	clears_hazards_on_spawn = TRUE
	var/datum/trade_hub/hub

/datum/overmap_object/trade_hub/New()
	. = ..()
	hub = new()

/datum/overmap_object/trade_hub/Destroy()
	QDEL_NULL(hub)
	return ..()

/obj/effect/abstract/overmap/trade_hub
	icon_state = "trade"
	color = COLOR_GREEN
	layer = OVERMAP_LAYER_STATION
