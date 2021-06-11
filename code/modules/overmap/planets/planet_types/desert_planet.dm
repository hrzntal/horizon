/datum/planet_template/desert_planet
	name = "Desert Planet"
	area_type = /area/planet/desert
	generator_type = /datum/map_generator/planet_gen/desert

	default_traits_input = list(ZTRAIT_MINING = TRUE, ZTRAIT_BASETURF = /turf/open/floor/plating/planetary/dry_seafloor)
	overmap_type = /datum/overmap_object/shuttle/planet/desert
	atmosphere_type = /datum/atmosphere/desert

	rock_color = list(COLOR_BEIGE, COLOR_PALE_YELLOW, COLOR_GRAY, COLOR_BROWN)
	plant_color = list("#efdd6f","#7b4a12","#e49135","#ba6222","#5c755e","#701732")
	grass_color = list("#b8701f")

/datum/overmap_object/shuttle/planet/desert
	name = "Desert Planet"
	planet_color = COLOR_BEIGE

/area/planet/desert
	name = "Desert Planet Surface"
	ambientsounds = list('sound/effects/wind/desert0.ogg','sound/effects/wind/desert1.ogg','sound/effects/wind/desert2.ogg','sound/effects/wind/desert3.ogg','sound/effects/wind/desert4.ogg','sound/effects/wind/desert5.ogg')

/datum/map_generator/planet_gen/desert
	possible_biomes = list(
	BIOME_LOW_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/desert,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGH_HUMIDITY = /datum/biome/desert
		),
	BIOME_LOWMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/desert,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGH_HUMIDITY = /datum/biome/desert
		),
	BIOME_HIGHMEDIUM_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/dry_seafloor,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/dry_seafloor,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/desert,
		BIOME_HIGH_HUMIDITY = /datum/biome/desert
		),
	BIOME_HIGH_HEAT = list(
		BIOME_LOW_HUMIDITY = /datum/biome/dry_seafloor,
		BIOME_LOWMEDIUM_HUMIDITY = /datum/biome/dry_seafloor,
		BIOME_HIGHMEDIUM_HUMIDITY = /datum/biome/dry_seafloor,
		BIOME_HIGH_HUMIDITY = /datum/biome/desert
		)
	)
	high_height_biome = /datum/biome/mountain
	perlin_zoom = 65

/datum/biome/desert
	turf_type = /turf/open/floor/plating/planetary/sand/desert

/datum/biome/dry_seafloor
	turf_type = /turf/open/floor/plating/planetary/dry_seafloor

/datum/atmosphere/desert
	base_gases = list(
		/datum/gas/nitrogen=80,
		/datum/gas/oxygen=20
	)
	normal_gases = list(
		/datum/gas/oxygen=5,
		/datum/gas/nitrogen=5
	)
	restricted_chance = 0

	minimum_pressure = ONE_ATMOSPHERE 
	maximum_pressure = ONE_ATMOSPHERE  + 50

	minimum_temp = T20C + 20
	maximum_temp = T20C + 80

/turf/open/floor/plating/planetary/sand/desert
	gender = PLURAL
	name = "desert sand"
	baseturfs = /turf/open/floor/plating/planetary/sand/desert
