/datum/map_config/skyport
	map_name = "SkyPort"
	map_path = "map_files/skyport"
	map_file = list("skyport.dmm")

	traits = list(	list("Up" = 1,
						 "Baseturf" = "/turf/closed/mineral/random/jungle"),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/openspace"),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/space"),
					list("Down" = -1,
						"Baseturf" = "/turf/open/space"))
	space_ruin_levels = 3

	minetype = "none"

	allow_custom_shuttles = TRUE

/datum/map_config/skyport/get_map_info()
	return "You have arrived at <b>[map_name],</b> a research outpost, with a tethered space docking ring for trading ships"
