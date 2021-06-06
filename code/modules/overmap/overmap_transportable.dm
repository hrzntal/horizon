/datum/overmap_object/transportable
	name = "transportable"
	overmap_flags = OV_SHOWS_ON_SENSORS|OV_CAN_BE_TARGETED|OV_CAN_BE_SCANNED|OV_CAN_BE_TRANSPORTED
	var/randomized_offsets = TRUE
	var/transports_remaining
	var/transports_remaining_low = 1
	var/transports_remaining_high = 1
	var/items_per_transport_low = 1
	var/items_per_transport_high = 1

/datum/overmap_object/transportable/New()
	. = ..()
	transports_remaining = rand(transports_remaining_low,transports_remaining_high)
	if(randomized_offsets)
		partial_y = rand(-13,13)
		partial_x = rand(-13,13)
		UpdateVisualOffsets()

/datum/overmap_object/transportable/proc/GetLootTable()
	return list(/obj/item/trash/boritos = 100)

/datum/overmap_object/transportable/DoTransport(turf/destination)
	var/list/loot_list = GetLootTable()
	var/items_per_transport = rand(items_per_transport_low,items_per_transport_high)
	for(var/i in 1 to items_per_transport)
		if(!length(loot_list))
			break
		var/picked_type = pickweight(loot_list)
		while(islist(picked_type))
			picked_type = pickweight(picked_type)
		new picked_type(destination)
	transports_remaining--
	if(!transports_remaining)
		qdel(src)

/datum/overmap_object/transportable/debris
	name = "debris"
	visual_type = /obj/effect/abstract/overmap/debris
	transports_remaining_low = 2
	transports_remaining_high = 4
	items_per_transport_low = 2
	items_per_transport_high = 4

/obj/effect/abstract/overmap/debris
	icon_state = "smallobject"
	layer = OVERMAP_LAYER_LOOT
	color = COLOR_GRAY

/datum/overmap_object/transportable/wreckage
	name = "wreckage"
	visual_type = /obj/effect/abstract/overmap/wreckage
	randomized_offsets = FALSE
	transports_remaining_low = 2
	transports_remaining_high = 4
	items_per_transport_low = 2
	items_per_transport_high = 4

//For wreckages in storms and such
/datum/overmap_object/transportable/wreckage/high_value

/obj/effect/abstract/overmap/wreckage
	icon_state = "mediumobject"
	layer = OVERMAP_LAYER_LOOT
	color = COLOR_VERY_LIGHT_GRAY

/datum/overmap_object/transportable/trash
	name = "clump of trash"
	visual_type = /obj/effect/abstract/overmap/trash
	transports_remaining_low = 2
	transports_remaining_high = 4
	items_per_transport_low = 1
	items_per_transport_high = 5

/datum/overmap_object/transportable/trash/GetLootTable()
	return GLOB.maintenance_loot

/obj/effect/abstract/overmap/trash
	icon_state = "smallobject"
	layer = OVERMAP_LAYER_LOOT
	color = COLOR_LIME
