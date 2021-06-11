/datum/planet_template/volcanic_planet
	name = "Volcanic Planet"
	area_type = /area/planet/volcanic
	generator_type = /datum/map_generator/planet_gen/volcanic

	default_traits_input = list(ZTRAIT_MINING = TRUE, ZTRAIT_BASETURF = /turf/open/lava/smooth/lava_land_surface)
	overmap_type = /datum/overmap_object/shuttle/planet/volcanic
	atmosphere_type = /datum/atmosphere/volcanic

	rock_color = list(COLOR_DARK_GRAY)
	plant_color = list("#a23c05","#3f1f0d","#662929","#ba6222","#7a5b3a","#471429")
	plant_color_as_grass = TRUE

/datum/overmap_object/shuttle/planet/volcanic
	name = "Volcanic Planet"
	planet_color = COLOR_RED

/area/planet/volcanic
	name = "Volcanic Planet Surface"
	ambientsounds = list('sound/ambience/magma.ogg')
	min_ambience_cooldown = 2 MINUTES
	max_ambience_cooldown = 4 MINUTES

/datum/map_generator/planet_gen/volcanic
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/mountain,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/mountain,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/basalt,
		BIOME_HIGH_HUMIDITY = /datum/biome/basalt
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/basalt,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/basalt,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/basalt,
		BIOME_HIGH_HUMIDITY = /datum/biome/basalt
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/basalt,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/basalt,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/basalt,
		BIOME_HIGH_HUMIDITY = /datum/biome/lava
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/basalt,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/basalt,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/lava,
		BIOME_HIGH_HUMIDITY = /datum/biome/lava
		)
	)
	high_height_biome = /datum/biome/mountain
	perlin_zoom = 65

/datum/biome/basalt
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface

/datum/biome/lava
	turf_type = /turf/open/lava/smooth/lava_land_surface

/datum/atmosphere/volcanic
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

	minimum_pressure = ONE_ATMOSPHERE + 30
	maximum_pressure = ONE_ATMOSPHERE + 80

	minimum_temp = T20C + 100
	maximum_temp = T20C + 200
