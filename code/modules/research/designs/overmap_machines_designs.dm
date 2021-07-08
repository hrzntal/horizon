/datum/design/board/tradeconsole
	name = "Computer Design (Trade Console)"
	desc = "Allows for the construction of circuit boards used to build a Trade Console."
	id = "tradeconsole"
	build_path = /obj/item/circuitboard/computer/trade_console
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/tradepad
	name = "Machine Design (Trade Pad)"
	desc = "The circuit board for a Trade Pad."
	id = "tradepad"
	build_path = /obj/item/circuitboard/machine/trade_pad
	category = list ("Cargo Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/mininglaser
	name = "Machine Design (Mining Laser)"
	desc = "The circuit board for a Mining Laser."
	id = "mininglaser"
	build_path = /obj/machinery/mining_laser
	category = list ("Cargo Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/shielgen
	name = "Machine Design (Shield Generator)"
	desc = "The circuit board for a Shield Generator."
	id = "shieldgen"
	build_path = /obj/item/circuitboard/machine/shield_generator
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/transporter
	name = "Machine Design (Transporter Pad)"
	desc = "The circuit board for a Transporter Pad."
	id = "transporter"
	build_path = /obj/item/circuitboard/machine/transporter
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
