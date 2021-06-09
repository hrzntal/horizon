/datum/planet_template
	var/name = "Planet Template"
	/// Map path to file to supply for the planet to be loaded from
	var/map_path
	var/map_file
	/// ALTERNATIVELY you can supply an area and a map generator
	var/area_type
	var/generator_type

	var/default_traits_input

	var/datum/overmap_object/overmap_type

	var/atmosphere_type

	var/weather_controller_type = /datum/weather_controller

/datum/planet_template/proc/LoadTemplate(datum/overmap_sun_system/system, coordinate_x, coordinate_y)
	var/old_z = world.maxz
	var/datum/overmap_object/linked_overmap_object = new overmap_type(system, coordinate_x, coordinate_y)
	if(map_path)
		if(!map_file)
			WARNING("No map file passed on planet generation")
		SSmapping.LoadGroup(null, name, map_path, map_file, default_traits = default_traits_input,  ov_obj = linked_overmap_object, weather_controller_type = weather_controller_type, atmosphere_type = atmosphere_type)
	else
		if(!area_type)
			WARNING("No area type passed on planet generation")
		if(!generator_type)
			WARNING("No generator type passed on planet generation")
		var/datum/space_level/new_level = SSmapping.add_new_zlevel(name, default_traits_input, overmap_obj = linked_overmap_object)
		if(atmosphere_type)
			var/datum/atmosphere/atmos = new atmosphere_type()
			SSair.register_planetary_atmos(atmos, new_level.z_value)
			qdel(atmos)
		var/area/new_area = new area_type()
		var/list/turfs = block(locate(1,1,new_level.z_value),locate(world.maxx,world.maxy,new_level.z_value))
		new_area.contents.Add(turfs)
		var/datum/map_generator/my_generator = new generator_type()
		my_generator.generate_terrain(turfs)
		qdel(my_generator)
		//Create weather controller
		var/datum/weather_controller/weather_controller = new weather_controller_type(list(new_level))
		weather_controller.LinkOvermapObject(linked_overmap_object)

	var/new_z = world.maxz

	//Remember all the levels that we've added
	var/list/z_levels = list()
	for(var/i = old_z + 1 to new_z)
		z_levels += i

	//Pass them to the ruin seeder
	SeedRuins(z_levels)

//Due to the particular way ruins are seeded right now this will be handled through a proc, rather than data-driven as of now
/datum/planet_template/proc/SeedRuins(list/z_levels)
	return

/datum/planet_template/lavaland
	name = "Lavaland"
	map_path = "map_files/Mining"
	map_file = "Lavaland.dmm"
	default_traits_input = ZTRAITS_LAVALAND

	overmap_type = /datum/overmap_object/shuttle/planet/lavaland
	weather_controller_type = /datum/weather_controller/lavaland
	atmosphere_type = /datum/atmosphere/lavaland

/datum/planet_template/lavaland/SeedRuins(list/z_levels)
	var/list/lava_ruins = SSmapping.levels_by_trait(ZTRAIT_LAVA_RUINS)
	//Only account for the levels we loaded, in case we load 2 lavalands
	for(var/i in lava_ruins)
		if(!(i in z_levels))
			lava_ruins -= i

	if (z_levels.len)
		seedRuins(z_levels, CONFIG_GET(number/lavaland_budget), list(/area/lavaland/surface/outdoors/unexplored), SSmapping.lava_ruins_templates)
		for (var/lava_z in z_levels)
			spawn_rivers(lava_z)

/datum/planet_template/jungle_planet
	name = "Jungle Planet"
	area_type = /area/jungle_planet
	generator_type = /datum/map_generator/planet_gen/jungle

	default_traits_input = ZTRAITS_JUNGLE_PLANET
	overmap_type = /datum/overmap_object/shuttle/planet/jungle_planet
