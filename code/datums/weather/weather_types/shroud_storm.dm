/datum/weather/shroud_storm
	name = "shroudstorm"
	desc = "Zap."

	telegraph_message = SPAN_WARNING("You hear thunder in the distance, static electricity rising in the air, wind starts to pickup..")
	telegraph_duration = 300
	telegraph_overlay = "electric_ash"
	telegraph_skyblock = 0.2

	weather_message = SPAN_USERDANGER("<i>An electric storm is upon you! Seek shelter!</i>")
	weather_overlay = "electric_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_skyblock = 0.4

	end_duration = 100
	end_message = SPAN_BOLDANNOUNCE("The storm dissipates.")
	end_overlay = "electric_ash"
	end_skyblock = 0.2

	area_type = /area
	protect_indoors = TRUE

	immunity_type = "ash"

	barometer_predictable = TRUE
	affects_underground = FALSE
	thunder_chance = 14

	sound_active_outside = /datum/looping_sound/weather/wind/indoors
	sound_active_inside = /datum/looping_sound/weather/wind
	sound_weak_outside = /datum/looping_sound/weather/wind/indoors
	sound_weak_inside = /datum/looping_sound/weather/wind

	multiply_blend_on_main_stage = TRUE

/datum/weather/shroud_storm/weather_act(mob/living/L)
	if(prob(10))
		L.electrocute_act(rand(5, 20), "weather", TRUE)
	if(prob(10))
		empulse(L, 0, 3)
