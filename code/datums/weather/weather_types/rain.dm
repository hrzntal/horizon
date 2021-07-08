/datum/weather/rain
	name = "rain"
	desc = "Rain falling down the surface."

	telegraph_message = SPAN_NOTICE("Dark clouds hover above and you feel humidity in the air..")
	telegraph_duration = 300
	telegraph_skyblock = 0.2

	weather_message = SPAN_NOTICE("Rain starts to fall down..")
	weather_overlay = "rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_skyblock = 0.4

	end_duration = 100
	end_message = SPAN_NOTICE("The rain stops...")
	end_skyblock = 0.2

	area_type = /area
	protect_indoors = TRUE
	barometer_predictable = TRUE
	affects_underground = FALSE
	aesthetic = TRUE

	sound_active_outside = /datum/looping_sound/weather/rain/indoors
	sound_active_inside = /datum/looping_sound/weather/rain

/datum/weather/rain/heavy
	name = "heavy rain"
	desc = "Downpour of rain."

	telegraph_message = SPAN_NOTICE("Rather suddenly, clouds converge and tear into rain..")
	telegraph_overlay = "rain"
	telegraph_skyblock = 0.4

	weather_message = SPAN_NOTICE("The rain turns into a downpour..")
	weather_overlay = "storm"
	weather_skyblock = 0.6

	end_message = SPAN_NOTICE("The downpour dies down...")
	end_overlay = "rain"
	end_skyblock = 0.4

	sound_active_outside = /datum/looping_sound/weather/rain/indoors
	sound_active_inside = /datum/looping_sound/weather/rain
	sound_weak_outside = /datum/looping_sound/weather/rain/indoors
	sound_weak_inside = /datum/looping_sound/weather/rain

	thunder_chance = 2

/datum/weather/rain/heavy/storm
	name = "storm"
	desc = "Storm with rain and lightning."
	weather_message = SPAN_WARNING("The clouds blacken and the sky starts to flash as thunder strikes down!")
	thunder_chance = 10
