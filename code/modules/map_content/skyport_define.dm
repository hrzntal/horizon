/datum/map_config/skyport
	map_name = "SkyPort"
	map_path = "map_files/skyport"
	map_file = list("skyport.dmm")

	traits = list(	list("Up" = 1,
						 "Baseturf" = "/turf/open/floor/planetary/wasteland",
						 "Mining" = TRUE,
						 "Gravity" = TRUE),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/openspace",
						"Mining" = TRUE,
						"Gravity" = TRUE),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/space",
						"Mining" = FALSE,
						"Gravity" = TRUE),
					list("Down" = -1,
						"Baseturf" = "/turf/open/space",
						"Mining" = FALSE,
						"Gravity" = TRUE))
	space_ruin_levels = 3

	minetype = "none"

	allow_custom_shuttles = TRUE

	day_night_controller_type = /datum/day_night_controller

/datum/map_config/skyport/get_map_info()
	return "You have arrived at <b>[map_name],</b> a research outpost, with a tethered space docking ring for trading ships"
