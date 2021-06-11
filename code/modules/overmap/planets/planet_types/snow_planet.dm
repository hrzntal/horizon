/datum/planet_template/snow_planet
	name = "Snow Planet"
	area_type = /area/planet/snow
	generator_type = /datum/map_generator/planet_gen/snow

	default_traits_input = list(ZTRAIT_MINING = TRUE, ZTRAIT_BASETURF = /turf/open/floor/plating/planetary/dirt)
	overmap_type = /datum/overmap_object/shuttle/planet/snow
	atmosphere_type = /datum/atmosphere/snow

	rock_color = list(COLOR_DARK_BLUE_GRAY, COLOR_GUNMETAL, COLOR_GRAY, COLOR_DARK_GRAY)
	plant_color = list("#d0fef5","#93e1d8","#93e1d8", "#b2abbf", "#3590f3", "#4b4e6d")
	plant_color_as_grass = TRUE

/datum/overmap_object/shuttle/planet/snow
	name = "Snow Planet"
	planet_color = COLOR_WHITE

/area/planet/snow
	name = "Snow Planet Surface"
	ambientsounds = list('sound/effects/wind/tundra0.ogg','sound/effects/wind/tundra1.ogg','sound/effects/wind/tundra2.ogg','sound/effects/wind/spooky0.ogg','sound/effects/wind/spooky1.ogg')

/datum/map_generator/planet_gen/snow
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/snowy_mountainside,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGH_HUMIDITY = /datum/biome/frozen_lake
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/snow,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGH_HUMIDITY = /datum/biome/frozen_lake
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/grass_tundra,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGH_HUMIDITY = /datum/biome/snow
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/grass_tundra,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/snow,
		BIOME_HIGH_HUMIDITY = /datum/biome/snow
		)
	)
	high_height_biome = /datum/biome/mountain
	perlin_zoom = 65

/datum/biome/grass_tundra
	turf_type = /turf/open/floor/plating/planetary/grass

/datum/biome/snow
	turf_type = /turf/open/floor/plating/planetary/snow

/datum/biome/frozen_lake
	turf_type = /turf/open/floor/plating/planetary/ice

/datum/biome/snowy_mountainside
	turf_type = /turf/closed/mineral/random/snow

/turf/open/floor/plating/planetary/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/planet/snow/snow_floor.dmi'
	baseturfs = /turf/open/floor/plating/planetary/snow
	icon_state = "snow"
	base_icon_state = "snow"
	slowdown = 2
	bullet_sizzle = TRUE
	bullet_bounce_sound = null

/turf/open/floor/plating/planetary/snow/Initialize()
	. = ..()
	if(prob(15))
		icon_state = "[base_icon_state][rand(1,13)]"

/turf/open/floor/plating/planetary/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	base_icon_state = "ice_turf-0"
	baseturfs = /turf/open/floor/plating/planetary/ice
	slowdown = 1
	attachment_holes = FALSE
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/planetary/ice/Initialize()
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/floor/plating/planetary/ice/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/datum/atmosphere/snow
	base_gases = list(
		/datum/gas/nitrogen=80,
		/datum/gas/oxygen=20
	)
	normal_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=5,
		/datum/gas/carbon_dioxide=2
	)
	restricted_chance = 0

	minimum_pressure = ONE_ATMOSPHERE - 30
	maximum_pressure = ONE_ATMOSPHERE

	minimum_temp = T20C - 100
	maximum_temp = T20C - 10
