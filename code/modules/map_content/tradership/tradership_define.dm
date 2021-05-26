/datum/map_config/tradership
	map_name = "FTV Bearcat"
	map_path = "map_files/tradership"
	map_file = list("tradership1.dmm",
					"tradership2.dmm",
					"tradership3.dmm",
					"tradership4.dmm")

	traits = list(list("Up" = 1),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/openspace"),
					list("Up" = 1,
						"Down" = -1,
						"Baseturf" = "/turf/open/openspace"),
					list("Down" = -1,
						"Baseturf" = "/turf/open/openspace"))
	space_ruin_levels = 7
	space_empty_levels = 1

	minetype = "lavaland"

	allow_custom_shuttles = TRUE

	job_faction = "Tradership"

	overflow_job = "Deckhand"

	overmap_object_type = /datum/overmap_object/shuttle/station
