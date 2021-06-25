#define TURF_FIRE_REQUIRED_TEMP (T20C-10)
#define TURF_FIRE_TEMP_BASE (T20C+80)
#define TURF_FIRE_POWER_LOSS_ON_LOW_TEMP 7
#define TURF_FIRE_TEMP_INCREMENT_PER_POWER 3
#define TURF_FIRE_VOLUME 150
#define TURF_FIRE_MAX_POWER 50

/obj/effect/abstract/turf_fire
	icon = 'icons/effects/turf_fire.dmi'
	icon_state = "fire_small"
	anchored = TRUE
	move_resist = INFINITY
	light_range = 1.5
	light_power = 1.5
	light_color = LIGHT_COLOR_FIRE
	mouse_opacity = FALSE
	var/fire_power = 5

/obj/effect/abstract/turf_fire/Initialize(mapload, power)
	. = ..()
	var/turf/open/open_turf = loc
	if(open_turf.turf_fire)
		return INITIALIZE_HINT_QDEL
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, src, loc_connections)
	open_turf.turf_fire = src
	SSturf_fire.fires[src] = TRUE
	fire_power = min(TURF_FIRE_MAX_POWER, power)
	UpdateFireState()

/obj/effect/abstract/turf_fire/Destroy()
	var/turf/open/open_turf = loc
	open_turf.turf_fire = null
	SSturf_fire.fires -= src
	return ..()

/obj/effect/abstract/turf_fire/process()
	var/turf/open/open_turf = loc
	if(open_turf.active_hotspot) //If we have an active hotspot, let it do the damage instead and lets not loose power
		return
	var/list/air_gases = open_turf.air?.gases
	if(!air_gases)
		qdel(src)
		return
	var/oxy = air_gases[/datum/gas/oxygen] ? air_gases[/datum/gas/oxygen][MOLES] : 0
	if (oxy < 0.5)
		qdel(src)
		return
	if(open_turf.air.temperature < TURF_FIRE_REQUIRED_TEMP)
		fire_power -= TURF_FIRE_POWER_LOSS_ON_LOW_TEMP
	fire_power--
	if(fire_power <= 0)
		qdel(src)
		return
	open_turf.hotspot_expose(TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power), TURF_FIRE_VOLUME)
	for(var/A in open_turf)
		var/atom/AT = A
		AT.fire_act(TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power), TURF_FIRE_VOLUME)
	if(prob(fire_power))
		open_turf.burn_tile()
	UpdateFireState()

/obj/effect/abstract/turf_fire/proc/on_entered(datum/source, atom/movable/AM)
	var/turf/open/open_turf = loc
	if(open_turf.active_hotspot) //If we have an active hotspot, let it do the damage instead 
		return
	AM.fire_act(TURF_FIRE_TEMP_BASE + (TURF_FIRE_TEMP_INCREMENT_PER_POWER*fire_power), TURF_FIRE_VOLUME)
	return

/obj/effect/abstract/turf_fire/extinguish()
	qdel(src)

/obj/effect/abstract/turf_fire/proc/AddPower(power)
	fire_power = min(TURF_FIRE_MAX_POWER, fire_power + power)
	UpdateFireState()

/obj/effect/abstract/turf_fire/proc/UpdateFireState()
	switch(fire_power)
		if(0 to 10)
			icon_state = "fire_small"
			set_light_range(1.5)
		if(11 to 24)
			icon_state = "fire_medium"
			set_light_range(2.5)
		if(25 to INFINITY)
			icon_state = "fire_big"
			set_light_range(3)
