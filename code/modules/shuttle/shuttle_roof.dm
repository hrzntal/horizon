/obj/effect/abstract/shuttle_roof
	name = "shuttle roof"
	desc = "A roof of a shuttle."
	icon = 'icons/turf/floors.dmi'
	icon_state = "regular_hull"
	obj_flags = FULL_BLOCK_Z_BELOW
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = ABOVE_NORMAL_TURF_LAYER
	CanAtmosPassVertical = ATMOS_PASS_PROC

/obj/effect/abstract/shuttle_roof/Initialize()
	. = ..()
	air_update_turf(TRUE, TRUE)
	update_turf_for_appearance()
	var/turf/my_turf = loc
	var/static/list/loc_connections = list(
		COMSIG_TURF_CHANGE = .proc/turf_updated,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)
	SEND_SIGNAL(my_turf, COMSIG_TURF_UPDATE_TRANSPARENCY)

/obj/effect/abstract/shuttle_roof/Destroy()
	var/turf/my_turf = loc
	. = ..()
	SEND_SIGNAL(my_turf, COMSIG_TURF_UPDATE_TRANSPARENCY)

/obj/effect/abstract/shuttle_roof/proc/turf_updated(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, .proc/attached_to_new_turf) //Because there isn't an AFTER_CHANGE signal

/obj/effect/abstract/shuttle_roof/proc/attached_to_new_turf()
	update_turf_for_appearance()

/obj/effect/abstract/shuttle_roof/proc/update_turf_for_appearance()
	var/turf/my_turf = loc
	if(isopenspaceturf(my_turf))
		layer = ABOVE_NORMAL_TURF_LAYER
		mouse_opacity = MOUSE_OPACITY_ICON
	else
		layer = ROOF_LAYER
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT

//Pass the attackby to the turf "above" it. This is for ease of building on openspace while a shuttle is under it
/obj/effect/abstract/shuttle_roof/attackby(obj/item/I, mob/user, params)
	var/turf/my_turf = loc
	my_turf.attackby(I, user, params)

/obj/effect/abstract/shuttle_roof/CanAtmosPass(turf/T)
	var/turf/below_turf = SSmapping.get_turf_below(src)
	if(T == below_turf)
		return FALSE
	return TRUE
