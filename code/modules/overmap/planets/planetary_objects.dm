/area/planet
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = VALID_TERRITORY | UNIQUE_AREA | CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | MEGAFAUNA_SPAWN_ALLOWED | NO_ALERTS
	ambience_index = AMBIENCE_AWAY
	outdoors = TRUE

/datum/biome/mountain
	turf_type = /turf/closed/mineral/random/jungle

/datum/biome/water
	turf_type = /turf/open/floor/plating/planetary/water

/turf/open/floor/plating/planetary
	icon = 'icons/planet/planet_floors.dmi'
	initial_gas_mix = PLANETARY_ATMOS
	tiled_dirt = FALSE

/turf/open/floor/plating/planetary/water
	gender = PLURAL
	name = "water"
	desc = "A pool of water, very wet."
	baseturfs = /turf/open/floor/plating/planetary/water
	icon_state = "water"
	base_icon_state = "water"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER
	slowdown = 2

/turf/open/floor/plating/planetary/water/tar
	gender = PLURAL
	name = "tar"
	desc = "A pool of viscous and sticky tar."
	slowdown = 10

/turf/open/floor/plating/planetary/water/Initialize()
	. = ..()
	if(!color)
		var/datum/space_level/level = SSmapping.z_list[z]
		color = level.water_color

/turf/open/floor/plating/planetary/grass
	name = "grass"
	desc = "A patch of grass."
	icon = 'icons/planet/planet_grass.dmi'
	icon_state = "grass0"
	base_icon_state = "grass"
	baseturfs = /turf/open/floor/plating/planetary/dirt
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_FLOOR_GRASS)
	layer = HIGH_TURF_LAYER

/turf/open/floor/plating/planetary/grass/setup_broken_states()
	return list("damaged")

/turf/open/floor/plating/planetary/grass/Initialize()
	. = ..()
	var/matrix/translation = new
	translation.Translate(-9, -9)
	transform = translation
	var/datum/space_level/level = SSmapping.z_list[z]
	color = level.grass_color

/turf/open/floor/plating/planetary/dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon_state = "cracked_dirt"
	base_icon_state = "cracked_dirt"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY


/turf/open/floor/plating/planetary/rock
	name = "rock"
	icon_state = "rock_floor"
	base_icon_state = "rock_floor"
	footstep = FOOTSTEP_GENERIC_HEAVY
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_GENERIC_HEAVY
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/planetary/rock/Initialize()
	. = ..()
	var/datum/space_level/level = SSmapping.z_list[z]
	color = level.rock_color

/turf/open/floor/plating/planetary/mud
	gender = PLURAL
	name = "mud"
	desc = "Thick, claggy and waterlogged."
	icon_state = "dark_mud"
	base_icon_state = "dark_mud"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/planetary/sand
	gender = PLURAL
	name = "sand"
	desc = "It's coarse and gets everywhere."
	baseturfs = /turf/open/floor/plating/planetary/sand
	icon_state = "sand"
	base_icon_state = "sand"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_SAND

/turf/open/floor/plating/planetary/sand/Initialize()
	. = ..()
	if(prob(10))
		icon_state = "[base_icon_state][rand(1,5)]"

/turf/open/floor/plating/planetary/dry_seafloor
	gender = PLURAL
	name = "dry seafloor"
	desc = "Should have stayed hydrated."
	baseturfs = /turf/open/floor/plating/planetary/dry_seafloor
	icon_state = "dry"
	base_icon_state = "dry"
	footstep = FOOTSTEP_GENERIC_HEAVY
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_GENERIC_HEAVY
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/planetary/wasteland
	name = "cracked earth"
	desc = "Looks a bit dry."
	icon = 'icons/turf/floors.dmi'
	icon_state = "wasteland"
	base_icon_state = "wasteland"
	slowdown = 1

/turf/open/floor/plating/planetary/wasteland/setup_broken_states()
	return list("[initial(icon_state)]0")

/turf/open/floor/plating/planetary/wasteland/Initialize()
	.=..()
	if(prob(15))
		icon_state = "[initial(icon_state)][rand(0,12)]"

/obj/structure/flora/planetary
	name = "bush"
	desc = "Some kind of plant."
	icon = 'icons/planet/grayscale_flora.dmi'
	var/variants = 0

/obj/structure/flora/planetary/Initialize()
	. = ..()
	if(!color)
		var/datum/space_level/level = SSmapping.z_list[z]
		color = level.plant_color
	icon_state = "[icon_state]_[rand(1,variants)]"

/obj/structure/flora/planetary/firstbush
	icon_state = "firstbush"
	variants = 4

/obj/structure/flora/planetary/leafybush
	icon_state = "leafybush"
	variants = 3

/obj/structure/flora/planetary/palebush
	icon_state = "palebush"
	variants = 4

/obj/structure/flora/planetary/grassybush
	icon_state = "grassybush"
	variants = 4

/obj/structure/flora/planetary/fernybush
	icon_state = "fernybush"
	variants = 3

/obj/structure/flora/planetary/sunnybush
	icon_state = "sunnybush"
	variants = 3

/obj/structure/flora/planetary/genericbush
	icon_state = "genericbush"
	variants = 4

/obj/structure/flora/planetary/pointybush
	icon_state = "pointybush"
	variants = 4

/obj/structure/flora/planetary/lavendergrass
	name = "grass"
	icon_state = "lavendergrass"
	variants = 4

/obj/structure/flora/planetary_grass
	name = "grass"
	desc = "Some kind of plant."
	icon = 'icons/planet/grayscale_flora.dmi'
	var/variants = 0

/obj/structure/flora/planetary_grass/Initialize()
	. = ..()
	if(!color)
		var/datum/space_level/level = SSmapping.z_list[z]
		color = level.grass_color
	icon_state = "[icon_state]_[rand(1,variants)]"

/obj/structure/flora/planetary_grass/sparsegrass
	icon_state = "sparsegrass"
	variants = 3

/obj/structure/flora/planetary_grass/fullgrass
	icon_state = "fullgrass"
	variants = 3
