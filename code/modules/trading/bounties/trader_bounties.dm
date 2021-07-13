/datum/trader_bounty/gun_celebration_day
	bounty_name = "Gun Celebration Day"
	amount = 5
	possible_paths = list(
		/obj/item/food/burger/baconburger,
		/obj/item/food/burger/cheese,
		/obj/item/food/burger/plain,
		/obj/item/food/burger/rib
		)
	bounty_text = "We're celebrating the galaxy wide gun day today, and we require burgers for the party! It'd be real nice if you could procure some for us."
	bounty_complete_text = "HELL YEAH! Now we can party for real."

/datum/trader_bounty/reagent/ammo_requisition
	bounty_name = "Ammunition Requisition"
	amount = 90 //3 bottles
	reagent_type = /datum/reagent/gunpowder
	reward_cash = 2000
	bounty_text = "We're running out of ammunition stock and require more gunpowder to produce more! Please fetch us some."
	bounty_complete_text = "With this, we're sure to make a bang."

/datum/trader_bounty/reagent/explosive_ammo
	bounty_name = "Explosive Bullets"
	amount = 90 //3 bottles
	reagent_type = /datum/reagent/rdx
	reward_cash = 2000
	bounty_text = "We are experimenting with making our bullets explode and require some chemicals that can give us the right type of bang."
	bounty_complete_text = "With this, we're sure to make a bang."

/datum/trader_bounty/anomalous_energy_sources
	bounty_name = "Anomalous Energy Sources"
	amount = 3
	path = /obj/item/anomalous_sliver/crystal
	reward_cash = 3000
	bounty_text = "We are looking into acquiring new and more effective energy sources for our weapons and found interest in those new crystals the rumors been spreading around."
	bounty_complete_text = "This will surely be useful for our research."

/datum/trader_bounty/unlimited_power
	bounty_name = "Unlimited Power?"
	amount = 1
	path = /obj/item/stock_parts/cell/high/slime_hypercharged
	reward_cash = 3000
	bounty_text = "Our electricity bill is getting way too steep, we need to switch to renewable energy, and by that I mean a supercharged slime core."
	bounty_complete_text = "You won't catch us with our lights off now."
