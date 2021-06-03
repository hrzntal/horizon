/datum/map_config/tramstation
	map_name = "Tramstation"
	map_path = "map_files/tramstation"
	map_file = "tramstation.dmm"

	traits = list(list("Up" = 1,
						"Baseturf" = "/turf/open/floor/plating/asteroid/airless",
						"Linkage" = "Cross"),
						list("Down" = -1,
						"Baseturf" = "/turf/open/openspace",
						"Linkage" = "Cross"))
	space_ruin_levels = 7
	space_empty_levels = 1

	minetype = "lavaland"

	allow_custom_shuttles = TRUE
	shuttles = list(
		"cargo" = "cargo_tram",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_tram",
		"emergency" = "emergency_tram")

	job_changes = list("cook" = list("additional_cqc_areas" = list("/area/service/kitchen/diner")),
						"captain" = list("special_charter" = "asteroid"))

	overmap_object_type = /datum/overmap_object/shuttle/station
