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
	var/cost = 3000
	/// How much left in stock
	var/stock = 1
	/// What type of the shuttle it is. Consoles may have limited purchase range
	var/shuttle_type = SHUTTLE_CIV
	/// Associative to TRUE list of dock id's that this template can fit into
	var/allowed_docks = list()

/datum/sold_shuttle/crow
	name = "ESS Crow"
	shuttle_id = "exploration_crow"
	allowed_docks = list(DOCKS_MEDIUM_UPWARDS)
