/obj/effect/abstract/shuttle_roof
	name = "shuttle roof"
	desc = "A roof of a shuttle."
	icon = 'icons/turf/floors.dmi'
	icon_state = "regular_hull"
	obj_flags = FULL_BLOCK_Z_BELOW
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = ROOF_LAYER
	CanAtmosPassVertical = ATMOS_PASS_PROC

/obj/effect/abstract/shuttle_roof/Initialized()
	. = ..()
	air_update_turf(TRUE, TRUE)

/obj/effect/abstract/shuttle_roof/CanAtmosPass(turf/T)
	var/turf/below_turf = SSmapping.get_turf_below(src)
	if(T == below_turf)
		return FALSE
	return TRUE
