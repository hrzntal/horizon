/datum/weather/snowfall
	name = "snowfall"
	desc = "Harmless snow particles showering the surface."

	telegraph_message = SPAN_NOTICE("Drifting particles of snow begin to dust the surrounding area..")
	telegraph_duration = 300
	telegraph_overlay = "snowfall_light"
	telegraph_skyblock = 0.1

	weather_message = SPAN_NOTICE("Soft and puffy snow falls down on the surface, creating a layer of snow..")
	weather_overlay = "snowfall_med"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_skyblock = 0.2

	end_duration = 100
	end_message = SPAN_NOTICE("The snowfall stops...")
	end_skyblock = 0.1

	area_type = /area
	protect_indoors = TRUE
	barometer_predictable = TRUE
	affects_underground = FALSE
	aesthetic = TRUE

/datum/weather/snowfall/heavy
	name = "heavy snowfall"
	desc = "Heavy amounts of snow raining down."

	telegraph_message = SPAN_NOTICE("Rather suddenly, snow starts raining down..")
	telegraph_overlay = "snowfall_med"
	telegraph_skyblock = 0.2

	weather_message = SPAN_DANGER("The snowfall turns into a blizzard..")
	weather_overlay = "snowfall_heavy"
	weather_skyblock = 0.4

	end_overlay = "light_snow"
	end_message = SPAN_NOTICE("The blizzard dies down...")
	end_skyblock = 0.2

	sound_active_outside = /datum/looping_sound/weather/wind/indoors
	sound_active_inside = /datum/looping_sound/weather/wind
	sound_weak_outside = /datum/looping_sound/weather/wind/indoors
	sound_weak_inside = /datum/looping_sound/weather/wind

	immunity_type = "snow"
	aesthetic = FALSE
	thunder_chance = 2

/datum/weather/snowfall/heavy/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(2,4))
