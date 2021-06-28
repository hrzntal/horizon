/datum/sold_shuttle
	/// Name of the shuttle
	var/name = "Shuttle Name"
	/// Description of the shuttle
	var/desc = "Description."
	/// Detailed description of the ship
	var/detailed_desc = "Detailed specifications."
	/// ID of the shuttle
	var/shuttle_id
	/// How much does it cost
	var/cost = 5000
	/// How much left in stock
	var/stock = 1
	/// What type of the shuttle it is. Consoles may have limited purchase range
	var/shuttle_type = SHUTTLE_CIV
	/// Associative to TRUE list of dock id's that this template can fit into
	var/allowed_docks = list()

/datum/sold_shuttle/mining_common
	name = "Small Travel Shuttle"
	desc = "Small shuttle fitted for up to 4 people. Perfect for travel, but not much else"
	detailed_desc = "It's small sized and it's equipped with 1 burst engine"
	cost = 5000
	shuttle_id = "mining_common_meta"
	allowed_docks = list(DOCKS_SMALL_UPWARDS)

/datum/sold_shuttle/vulture
	name = "MS Vulture"
	desc = "A medium sized mining shuttle, equipped with living quarters."
	detailed_desc = "It's medium sized and is equipped with three propulsion engines, canisters of co2 and oxygen, a portable generator, two mining lasers, a transporter and some emergency supplies. It has quarters and a restroom"
	shuttle_id = "common_vulture"
	cost = 7500
	allowed_docks = list(DOCKS_MEDIUM_UPWARDS)
	shuttle_type = SHUTTLE_MINING

/datum/sold_shuttle/crow
	name = "ESS Crow - sister"
	desc = "A medium sized exploration shuttle, sister to the ESS Crow, named the same oddly."
	detailed_desc = "It's medium sized and is equipped with four propulsion engines, canisters of co2 and oxygen, a portable generator, excavation gear and some emergency supplies."
	shuttle_id = "exploration_crow"
	cost = 10000
	allowed_docks = list(DOCKS_MEDIUM_UPWARDS)
	shuttle_type = SHUTTLE_EXPLORATION
