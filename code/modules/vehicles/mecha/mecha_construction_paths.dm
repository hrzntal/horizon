////////////////////////////////
///// Construction datums //////
////////////////////////////////
/datum/component/construction/mecha
	var/base_icon

	// Component typepaths.
	// most must be defined unless
	// get_steps is overriden.

	// Circuit board typepaths.
	// circuit_control and circuit_periph must be defined
	// unless get_circuit_steps is overriden.
	var/circuit_control
	var/circuit_periph
	var/circuit_weapon

	// Armor plating typepaths. both must be defined
	// unless relevant step procs are overriden. amounts
	// must be defined if using /obj/item/stack/sheet types
	var/inner_plating
	var/inner_plating_amount

	var/outer_plating
	var/outer_plating_amount

/datum/component/construction/mecha/spawn_result()
	if(!result)
		return
	// Remove default mech power cell, as we replace it with a new one.
	var/obj/vehicle/sealed/mecha/M = new result(drop_location())
	QDEL_NULL(M.cell)
	QDEL_NULL(M.scanmod)
	QDEL_NULL(M.capacitor)

	var/obj/item/mecha_parts/chassis/parent_chassis = parent
	M.CheckParts(parent_chassis.contents)

	SSblackbox.record_feedback("tally", "mechas_created", 1, M.name)
	QDEL_NULL(parent)

// Default proc to generate mech steps.
// Override if the mech needs an entirely custom process (See HONK mech)
// Otherwise override specific steps as needed (Ripley, Clarke, Phazon)
/datum/component/construction/mecha/proc/get_steps()
	return get_frame_steps() + get_circuit_steps() + (circuit_weapon ? get_circuit_weapon_steps() : list()) + get_stockpart_steps() + get_inner_plating_steps() + get_outer_plating_steps()

/datum/component/construction/mecha/update_parent(step_index)
	steps = get_steps()
	..()
	// By default, each step in mech construction has a single icon_state:
	// "[base_icon][index - 1]"
	// For example, Ripley's step 1 icon_state is "ripley0".
	var/atom/parent_atom = parent
	if(!steps[index]["icon_state"] && base_icon)
		parent_atom.icon_state = "[base_icon][index - 1]"

/datum/component/construction/unordered/mecha_chassis/custom_action(obj/item/I, mob/living/user, typepath)
	. = user.transferItemToLoc(I, parent)
	if(.)
		var/atom/parent_atom = parent
		user.visible_message(SPAN_NOTICE("[user] connects [I] to [parent]."), SPAN_NOTICE("You connect [I] to [parent]."))
		parent_atom.add_overlay(I.icon_state+"+o")
		qdel(I)

/datum/component/construction/unordered/mecha_chassis/spawn_result()
	var/atom/parent_atom = parent
	parent_atom.icon = 'icons/mecha/mech_construction.dmi'
	parent_atom.density = TRUE
	parent_atom.cut_overlays()
	..()

// Default proc for the first steps of mech construction.
/datum/component/construction/mecha/proc/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		)
	)

// Default proc for the circuit board steps of a mech.
// Second set of steps by default.
/datum/component/construction/mecha/proc/get_circuit_steps()
	return list(
		list(
			"key" = circuit_control,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),
		list(
			"key" = circuit_periph,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		)
	)

// Default proc for weapon circuitboard steps
// Used by combat mechs
/datum/component/construction/mecha/proc/get_circuit_weapon_steps()
	return list(
		list(
			"key" = circuit_weapon,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapons control module is installed."
		)
	)

// Default proc for stock part installation
// Third set of steps by default
/datum/component/construction/mecha/proc/get_stockpart_steps()
	var/prevstep_text = circuit_weapon ? "Weapons control module is secured." : "Peripherals control module is secured."
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = prevstep_text
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		)
	)

// Default proc for inner armor plating
// Fourth set of steps by default
/datum/component/construction/mecha/proc/get_inner_plating_steps()
	var/list/first_step
	if(ispath(inner_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = inner_plating,
				"amount" = inner_plating_amount,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured."
			)
		)
	else
		first_step = list(
			list(
				"key" = inner_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured."
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Inner plating is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Inner Plating is wrenched."
		)
	)

// Default proc for outer armor plating
// Fifth set of steps by default
/datum/component/construction/mecha/proc/get_outer_plating_steps()
	var/list/first_step
	if(ispath(outer_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = outer_plating,
				"amount" = outer_plating_amount,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded."
			)
		)
	else
		first_step = list(
			list(
				"key" = outer_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded."
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		)
	)


/datum/component/construction/unordered/mecha_chassis/ripley
	result = /datum/component/construction/mecha/ripley
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg
	)

/datum/component/construction/mecha/ripley
	result = /obj/vehicle/sealed/mecha/working/ripley
	base_icon = "ripley"

	circuit_control = /obj/item/circuitboard/mecha/ripley/main
	circuit_periph = /obj/item/circuitboard/mecha/ripley/peripherals

	inner_plating=/obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/stack/rods
	outer_plating_amount = 10

/datum/component/construction/mecha/ripley/get_outer_plating_steps()
	return list(
		list(
			"key" = /obj/item/stack/rods,
			"amount" = 10,
			"back_key" = TOOL_WELDER,
			"desc" = "Outer Plating is welded."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "Cockpit wire screen is installed."
		),
	)

/datum/component/construction/mecha/ripley/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message(SPAN_NOTICE("[user] connects [parent] hydraulic systems."), SPAN_NOTICE("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] activates [parent] hydraulic systems."), SPAN_NOTICE("You activate [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects [parent] hydraulic systems."), SPAN_NOTICE("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adds the wiring to [parent]."), SPAN_NOTICE("You add the wiring to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] deactivates [parent] hydraulic systems."), SPAN_NOTICE("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adjusts the wiring of [parent]."), SPAN_NOTICE("You adjust the wiring of [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the wiring from [parent]."), SPAN_NOTICE("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the wiring of [parent]."), SPAN_NOTICE("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the mainboard."), SPAN_NOTICE("You secure the mainboard."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the central control module from [parent]."), SPAN_NOTICE("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the mainboard."), SPAN_NOTICE("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the peripherals control module."), SPAN_NOTICE("You secure the peripherals control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the peripherals control module from [parent]."), SPAN_NOTICE("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the peripherals control module."), SPAN_NOTICE("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the scanner module."), SPAN_NOTICE("You secure the scanner module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the scanner module from [parent]."), SPAN_NOTICE("You remove the scanner module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the scanner module."), SPAN_NOTICE("You unfasten the scanner module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures [I]."), SPAN_NOTICE("You secure [I]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the capacitor from [parent]."), SPAN_NOTICE("You remove the capacitor from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I]."), SPAN_NOTICE("You install [I]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unsecures the capacitor from [parent]."), SPAN_NOTICE("You unsecure the capacitor from [parent]."))
		if(14)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the power cell."), SPAN_NOTICE("You secure the power cell."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the power cell from [parent]."), SPAN_NOTICE("You pry the power cell from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the internal armor layer to [parent]."), SPAN_NOTICE("You install the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the power cell."), SPAN_NOTICE("You unfasten the power cell."))
		if(16)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the internal armor layer."), SPAN_NOTICE("You secure the internal armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries internal armor layer from [parent]."), SPAN_NOTICE("You pry internal armor layer from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the internal armor layer to [parent]."), SPAN_NOTICE("You weld the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the internal armor layer."), SPAN_NOTICE("You unfasten the internal armor layer."))
		if(18)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the external reinforced armor layer to [parent]."), SPAN_NOTICE("You install the external reinforced armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] cuts the internal armor layer from [parent]."), SPAN_NOTICE("You cut the internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the external armor layer."), SPAN_NOTICE("You secure the external reinforced armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries external armor layer from [parent]."), SPAN_NOTICE("You pry external armor layer from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the external armor layer to [parent]."), SPAN_NOTICE("You weld the external armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the external armor layer."), SPAN_NOTICE("You unfasten the external armor layer."))
	return TRUE

/datum/component/construction/unordered/mecha_chassis/gygax
	result = /datum/component/construction/mecha/gygax
	steps = list(
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_head
	)

/datum/component/construction/mecha/gygax
	result = /obj/vehicle/sealed/mecha/combat/gygax
	base_icon = "gygax"

	circuit_control = /obj/item/circuitboard/mecha/gygax/main
	circuit_periph = /obj/item/circuitboard/mecha/gygax/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/gygax/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/mecha_parts/part/gygax_armor
	outer_plating_amount=1

/datum/component/construction/mecha/gygax/action(datum/source, atom/used_atom, mob/user)
	return INVOKE_ASYNC(src, .proc/check_step, used_atom,user)

/datum/component/construction/mecha/gygax/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message(SPAN_NOTICE("[user] connects [parent] hydraulic systems."), SPAN_NOTICE("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] activates [parent] hydraulic systems."), SPAN_NOTICE("You activate [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects [parent] hydraulic systems."), SPAN_NOTICE("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adds the wiring to [parent]."), SPAN_NOTICE("You add the wiring to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] deactivates [parent] hydraulic systems."), SPAN_NOTICE("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adjusts the wiring of [parent]."), SPAN_NOTICE("You adjust the wiring of [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the wiring from [parent]."), SPAN_NOTICE("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the wiring of [parent]."), SPAN_NOTICE("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the mainboard."), SPAN_NOTICE("You secure the mainboard."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the central control module from [parent]."), SPAN_NOTICE("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the mainboard."), SPAN_NOTICE("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the peripherals control module."), SPAN_NOTICE("You secure the peripherals control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the peripherals control module from [parent]."), SPAN_NOTICE("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the peripherals control module."), SPAN_NOTICE("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the weapon control module."), SPAN_NOTICE("You secure the weapon control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the weapon control module from [parent]."), SPAN_NOTICE("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the weapon control module."), SPAN_NOTICE("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the scanner module."), SPAN_NOTICE("You secure the scanner module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the scanner module from [parent]."), SPAN_NOTICE("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the scanner module."), SPAN_NOTICE("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the capacitor."), SPAN_NOTICE("You secure the capacitor."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the capacitor from [parent]."), SPAN_NOTICE("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the capacitor."), SPAN_NOTICE("You unfasten the capacitor."))
		if(16)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the power cell."), SPAN_NOTICE("You secure the power cell."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the power cell from [parent]."), SPAN_NOTICE("You pry the power cell from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the internal armor layer to [parent]."), SPAN_NOTICE("You install the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the power cell."), SPAN_NOTICE("You unfasten the power cell."))
		if(18)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the internal armor layer."), SPAN_NOTICE("You secure the internal armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries internal armor layer from [parent]."), SPAN_NOTICE("You pry internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the internal armor layer to [parent]."), SPAN_NOTICE("You weld the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the internal armor layer."), SPAN_NOTICE("You unfasten the internal armor layer."))
		if(20)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] cuts the internal armor layer from [parent]."), SPAN_NOTICE("You cut the internal armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures Gygax Armor Plates."), SPAN_NOTICE("You secure Gygax Armor Plates."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries Gygax Armor Plates from [parent]."), SPAN_NOTICE("You pry Gygax Armor Plates from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds Gygax Armor Plates to [parent]."), SPAN_NOTICE("You weld Gygax Armor Plates to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens Gygax Armor Plates."), SPAN_NOTICE("You unfasten Gygax Armor Plates."))
	return TRUE

/datum/component/construction/unordered/mecha_chassis/clarke
	result = /datum/component/construction/mecha/clarke
	steps = list(
		/obj/item/mecha_parts/part/clarke_torso,
		/obj/item/mecha_parts/part/clarke_left_arm,
		/obj/item/mecha_parts/part/clarke_right_arm,
		/obj/item/mecha_parts/part/clarke_head
	)

/datum/component/construction/mecha/clarke
	result = /obj/vehicle/sealed/mecha/working/clarke
	base_icon = "clarke"

	circuit_control = /obj/item/circuitboard/mecha/clarke/main
	circuit_periph = /obj/item/circuitboard/mecha/clarke/peripherals

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/mineral/gold
	outer_plating_amount = 5

/datum/component/construction/mecha/clarke/get_frame_steps()
	return list(
		list(
			"key" = /obj/item/stack/conveyor,
			"amount" = 4,
			"desc" = "The treads are added."
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The hydraulic systems are disconnected."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		)
	)



/datum/component/construction/mecha/clarke/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message(SPAN_NOTICE("[user] adds the tread systems."), SPAN_NOTICE("You add the tread systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] connects [parent] hydraulic systems."), SPAN_NOTICE("You connect [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the tread systems."), SPAN_NOTICE("You remove the tread systems."))

		if(3)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] activates [parent] hydraulic systems."), SPAN_NOTICE("You activate [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects [parent] hydraulic systems."), SPAN_NOTICE("You disconnect [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adds the wiring to [parent]."), SPAN_NOTICE("You add the wiring to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] deactivates [parent] hydraulic systems."), SPAN_NOTICE("You deactivate [parent] hydraulic systems."))
		if(5)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adjusts the wiring of [parent]."), SPAN_NOTICE("You adjust the wiring of [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the wiring from [parent]."), SPAN_NOTICE("You remove the wiring from [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the wiring of [parent]."), SPAN_NOTICE("You disconnect the wiring of [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the mainboard."), SPAN_NOTICE("You secure the mainboard."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the central control module from [parent]."), SPAN_NOTICE("You remove the central computer mainboard from [parent]."))
		if(8)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the mainboard."), SPAN_NOTICE("You unfasten the mainboard."))
		if(9)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the peripherals control module."), SPAN_NOTICE("You secure the peripherals control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the peripherals control module from [parent]."), SPAN_NOTICE("You remove the peripherals control module from [parent]."))
		if(10)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the peripherals control module."), SPAN_NOTICE("You unfasten the peripherals control module."))
		if(11)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the scanner module."), SPAN_NOTICE("You secure the scanner module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the scanner module from [parent]."), SPAN_NOTICE("You remove the scanner module from [parent]."))
		if(12)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the scanner module."), SPAN_NOTICE("You unfasten the scanner module."))
		if(13)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the capacitor."), SPAN_NOTICE("You secure the capacitor."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the capacitor from [parent]."), SPAN_NOTICE("You remove the capacitor from [parent]."))
		if(14)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the capacitor."), SPAN_NOTICE("You unfasten the capacitor."))
		if(15)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the power cell."), SPAN_NOTICE("You secure the power cell."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the power cell from [parent]."), SPAN_NOTICE("You pry the power cell from [parent]."))
		if(16)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the internal armor layer to [parent]."), SPAN_NOTICE("You install the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the power cell."), SPAN_NOTICE("You unfasten the power cell."))
		if(17)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the internal armor layer."), SPAN_NOTICE("You secure the internal armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries internal armor layer from [parent]."), SPAN_NOTICE("You pry internal armor layer from [parent]."))
		if(18)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the internal armor layer to [parent]."), SPAN_NOTICE("You weld the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the internal armor layer."), SPAN_NOTICE("You unfasten the internal armor layer."))
		if(19)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the external armor layer to [parent]."), SPAN_NOTICE("You install the external reinforced armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] cuts the internal armor layer from [parent]."), SPAN_NOTICE("You cut the internal armor layer from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the external armor layer."), SPAN_NOTICE("You secure the external reinforced armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the external armor layer from [parent]."), SPAN_NOTICE("You pry the external armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the external armor layer to [parent]."), SPAN_NOTICE("You weld the external armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the external armor layer."), SPAN_NOTICE("You unfasten the external armor layer."))
	return TRUE


/datum/component/construction/unordered/mecha_chassis/honker
	result = /datum/component/construction/mecha/honker
	steps = list(
		/obj/item/mecha_parts/part/honker_torso,
		/obj/item/mecha_parts/part/honker_left_arm,
		/obj/item/mecha_parts/part/honker_right_arm,
		/obj/item/mecha_parts/part/honker_left_leg,
		/obj/item/mecha_parts/part/honker_right_leg,
		/obj/item/mecha_parts/part/honker_head
	)

/datum/component/construction/mecha/honker
	result = /obj/vehicle/sealed/mecha/combat/honker
	steps = list(
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/main,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/peripherals,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/targeting,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/clothing/mask/gas/clown_hat,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
		list(
			"key" = /obj/item/clothing/shoes/clown_shoes,
			"action" = ITEM_DELETE
		),
		list(
			"key" = /obj/item/bikehorn
		),
	)

/datum/component/construction/mecha/honker/get_steps()
	return steps

// HONK doesn't have any construction step icons, so we just set an icon once.
/datum/component/construction/mecha/honker/update_parent(step_index)
	if(step_index == 1)
		var/atom/parent_atom = parent
		parent_atom.icon = 'icons/mecha/mech_construct.dmi'
		parent_atom.icon_state = "honker_chassis"
	..()

/datum/component/construction/mecha/honker/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	if(istype(I, /obj/item/bikehorn))
		playsound(parent, 'sound/items/bikehorn.ogg', 50, TRUE)
		user.visible_message(SPAN_DANGER("HONK!"))

	//TODO: better messages.
	switch(index)
		if(2)
			user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
		if(4)
			user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
		if(6)
			user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
		if(8)
			user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
		if(10)
			user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
		if(12)
			user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
		if(14)
			user.visible_message(SPAN_NOTICE("[user] puts [I] on [parent]."), SPAN_NOTICE("You put [I] on [parent]."))
		if(16)
			user.visible_message(SPAN_NOTICE("[user] puts [I] on [parent]."), SPAN_NOTICE("You put [I] on [parent]."))
	return TRUE

/datum/component/construction/unordered/mecha_chassis/durand
	result = /datum/component/construction/mecha/durand
	steps = list(
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_head
	)

/datum/component/construction/mecha/durand
	result = /obj/vehicle/sealed/mecha/combat/durand
	base_icon = "durand"

	circuit_control = /obj/item/circuitboard/mecha/durand/main
	circuit_periph = /obj/item/circuitboard/mecha/durand/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/durand/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/durand_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/durand/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message(SPAN_NOTICE("[user] connects [parent] hydraulic systems."), SPAN_NOTICE("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] activates [parent] hydraulic systems."), SPAN_NOTICE("You activate [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects [parent] hydraulic systems."), SPAN_NOTICE("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adds the wiring to [parent]."), SPAN_NOTICE("You add the wiring to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] deactivates [parent] hydraulic systems."), SPAN_NOTICE("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adjusts the wiring of [parent]."), SPAN_NOTICE("You adjust the wiring of [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the wiring from [parent]."), SPAN_NOTICE("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the wiring of [parent]."), SPAN_NOTICE("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the mainboard."), SPAN_NOTICE("You secure the mainboard."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the central control module from [parent]."), SPAN_NOTICE("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the mainboard."), SPAN_NOTICE("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the peripherals control module."), SPAN_NOTICE("You secure the peripherals control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the peripherals control module from [parent]."), SPAN_NOTICE("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the peripherals control module."), SPAN_NOTICE("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the weapon control module."), SPAN_NOTICE("You secure the weapon control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the weapon control module from [parent]."), SPAN_NOTICE("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the weapon control module."), SPAN_NOTICE("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the scanner module."), SPAN_NOTICE("You secure the scanner module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the scanner module from [parent]."), SPAN_NOTICE("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the scanner module."), SPAN_NOTICE("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the capacitor."), SPAN_NOTICE("You secure the capacitor."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the capacitor from [parent]."), SPAN_NOTICE("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the capacitor."), SPAN_NOTICE("You unfasten the capacitor."))
		if(16)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the power cell."), SPAN_NOTICE("You secure the power cell."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the power cell from [parent]."), SPAN_NOTICE("You pry the power cell from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the internal armor layer to [parent]."), SPAN_NOTICE("You install the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the power cell."), SPAN_NOTICE("You unfasten the power cell."))
		if(18)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the internal armor layer."), SPAN_NOTICE("You secure the internal armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries internal armor layer from [parent]."), SPAN_NOTICE("You pry internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the internal armor layer to [parent]."), SPAN_NOTICE("You weld the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the internal armor layer."), SPAN_NOTICE("You unfasten the internal armor layer."))
		if(20)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] cuts the internal armor layer from [parent]."), SPAN_NOTICE("You cut the internal armor layer from [parent]."))
		if(21)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures Durand Armor Plates."), SPAN_NOTICE("You secure Durand Armor Plates."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries Durand Armor Plates from [parent]."), SPAN_NOTICE("You pry Durand Armor Plates from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds Durand Armor Plates to [parent]."), SPAN_NOTICE("You weld Durand Armor Plates to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens Durand Armor Plates."), SPAN_NOTICE("You unfasten Durand Armor Plates."))
	return TRUE

//PHAZON

/datum/component/construction/unordered/mecha_chassis/phazon
	result = /datum/component/construction/mecha/phazon
	steps = list(
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg,
		/obj/item/mecha_parts/part/phazon_head
	)

/datum/component/construction/mecha/phazon
	result = /obj/vehicle/sealed/mecha/combat/phazon
	base_icon = "phazon"

	circuit_control = /obj/item/circuitboard/mecha/phazon/main
	circuit_periph = /obj/item/circuitboard/mecha/phazon/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/phazon/targeting

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/phazon_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/phazon/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanner module is installed."
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanner module is secured."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed."
		),
		list(
			"key" = /obj/item/stack/ore/bluespace_crystal,
			"amount" = 1,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured."
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The bluespace crystal is installed."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "The bluespace crystal is connected."
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The bluespace crystal is engaged."
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed.",
			"icon_state" = "phazon17"
			// This is the point where a step icon is skipped, so "icon_state" had to be set manually starting from here.
		)
	)

/datum/component/construction/mecha/phazon/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = 1,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
		list(
			"key" = /obj/item/assembly/signaler/anomaly/bluespace,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Bluespace anomaly core socket is open.",
			"icon_state" = "phazon24"
		)
	)

/datum/component/construction/mecha/phazon/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message(SPAN_NOTICE("[user] connects [parent] hydraulic systems."), SPAN_NOTICE("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] activates [parent] hydraulic systems."), SPAN_NOTICE("You activate [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects [parent] hydraulic systems."), SPAN_NOTICE("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adds the wiring to [parent]."), SPAN_NOTICE("You add the wiring to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] deactivates [parent] hydraulic systems."), SPAN_NOTICE("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adjusts the wiring of [parent]."), SPAN_NOTICE("You adjust the wiring of [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the wiring from [parent]."), SPAN_NOTICE("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the wiring of [parent]."), SPAN_NOTICE("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the mainboard."), SPAN_NOTICE("You secure the mainboard."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the central control module from [parent]."), SPAN_NOTICE("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the mainboard."), SPAN_NOTICE("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the peripherals control module."), SPAN_NOTICE("You secure the peripherals control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the peripherals control module from [parent]."), SPAN_NOTICE("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the peripherals control module."), SPAN_NOTICE("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the weapon control module."), SPAN_NOTICE("You secure the weapon control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the weapon control module from [parent]."), SPAN_NOTICE("You remove the weapon control module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the weapon control module."), SPAN_NOTICE("You unfasten the weapon control module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the scanner module."), SPAN_NOTICE("You secure the scanner module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the scanner module from [parent]."), SPAN_NOTICE("You remove the scanner module from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the scanner module."), SPAN_NOTICE("You unfasten the scanner module."))
		if(14)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the capacitor."), SPAN_NOTICE("You secure the capacitor."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the capacitor from [parent]."), SPAN_NOTICE("You remove the capacitor from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I]."), SPAN_NOTICE("You install [I]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unsecures the capacitor from [parent]."), SPAN_NOTICE("You unsecure the capacitor from [parent]."))
		if(16)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] connects the bluespace crystal."), SPAN_NOTICE("You connect the bluespace crystal."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the bluespace crystal from [parent]."), SPAN_NOTICE("You remove the bluespace crystal from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] engages the bluespace crystal."), SPAN_NOTICE("You engage the bluespace crystal."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the bluespace crystal from [parent]."), SPAN_NOTICE("You disconnect the bluespace crystal from [parent]."))
		if(18)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disengages the bluespace crystal."), SPAN_NOTICE("You disengage the bluespace crystal."))
		if(19)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the power cell."), SPAN_NOTICE("You secure the power cell."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the power cell from [parent]."), SPAN_NOTICE("You pry the power cell from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the phase armor layer to [parent]."), SPAN_NOTICE("You install the phase armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the power cell."), SPAN_NOTICE("You unfasten the power cell."))
		if(21)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the phase armor layer."), SPAN_NOTICE("You secure the phase armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the phase armor layer from [parent]."), SPAN_NOTICE("You pry the phase armor layer from [parent]."))
		if(22)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the phase armor layer to [parent]."), SPAN_NOTICE("You weld the phase armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the phase armor layer."), SPAN_NOTICE("You unfasten the phase armor layer."))
		if(23)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] cuts phase armor layer from [parent]."), SPAN_NOTICE("You cut the phase armor layer from [parent]."))
		if(24)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures Phazon Armor Plates."), SPAN_NOTICE("You secure Phazon Armor Plates."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries Phazon Armor Plates from [parent]."), SPAN_NOTICE("You pry Phazon Armor Plates from [parent]."))
		if(25)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds Phazon Armor Plates to [parent]."), SPAN_NOTICE("You weld Phazon Armor Plates to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens Phazon Armor Plates."), SPAN_NOTICE("You unfasten Phazon Armor Plates."))
		if(26)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] carefully inserts the bluespace anomaly core into [parent] and secures it."),
					SPAN_NOTICE("You slowly place the bluespace anomaly core into its socket and close its chamber."))
	return TRUE

//ODYSSEUS

/datum/component/construction/unordered/mecha_chassis/odysseus
	result = /datum/component/construction/mecha/odysseus
	steps = list(
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
	)

/datum/component/construction/mecha/odysseus
	result = /obj/vehicle/sealed/mecha/medical/odysseus
	base_icon = "odysseus"

	circuit_control = /obj/item/circuitboard/mecha/odysseus/main
	circuit_periph = /obj/item/circuitboard/mecha/odysseus/peripherals

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/plasteel
	outer_plating_amount = 5

/datum/component/construction/mecha/odysseus/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message(SPAN_NOTICE("[user] connects [parent] hydraulic systems."), SPAN_NOTICE("You connect [parent] hydraulic systems."))
		if(2)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] activates [parent] hydraulic systems."), SPAN_NOTICE("You activate [parent] hydraulic systems."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects [parent] hydraulic systems."), SPAN_NOTICE("You disconnect [parent] hydraulic systems."))
		if(3)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adds the wiring to [parent]."), SPAN_NOTICE("You add the wiring to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] deactivates [parent] hydraulic systems."), SPAN_NOTICE("You deactivate [parent] hydraulic systems."))
		if(4)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] adjusts the wiring of [parent]."), SPAN_NOTICE("You adjust the wiring of [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the wiring from [parent]."), SPAN_NOTICE("You remove the wiring from [parent]."))
		if(5)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] disconnects the wiring of [parent]."), SPAN_NOTICE("You disconnect the wiring of [parent]."))
		if(6)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the mainboard."), SPAN_NOTICE("You secure the mainboard."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the central control module from [parent]."), SPAN_NOTICE("You remove the central computer mainboard from [parent]."))
		if(7)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the mainboard."), SPAN_NOTICE("You unfasten the mainboard."))
		if(8)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the peripherals control module."), SPAN_NOTICE("You secure the peripherals control module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the peripherals control module from [parent]."), SPAN_NOTICE("You remove the peripherals control module from [parent]."))
		if(9)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the peripherals control module."), SPAN_NOTICE("You unfasten the peripherals control module."))
		if(10)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the scanner module."), SPAN_NOTICE("You secure the scanner module."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the scanner module from [parent]."), SPAN_NOTICE("You remove the scanner module from [parent]."))
		if(11)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] to [parent]."), SPAN_NOTICE("You install [I] to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the scanner module."), SPAN_NOTICE("You unfasten the scanner module."))
		if(12)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the capacitor."), SPAN_NOTICE("You secure the capacitor."))
			else
				user.visible_message(SPAN_NOTICE("[user] removes the capacitor from [parent]."), SPAN_NOTICE("You remove the capacitor from [parent]."))
		if(13)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs [I] into [parent]."), SPAN_NOTICE("You install [I] into [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the capacitor."), SPAN_NOTICE("You unfasten the capacitor."))
		if(14)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the power cell."), SPAN_NOTICE("You secure the power cell."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the power cell from [parent]."), SPAN_NOTICE("You pry the power cell from [parent]."))
		if(15)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the internal armor layer to [parent]."), SPAN_NOTICE("You install the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the power cell."), SPAN_NOTICE("You unfasten the power cell."))
		if(16)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the internal armor layer."), SPAN_NOTICE("You secure the internal armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries internal armor layer from [parent]."), SPAN_NOTICE("You pry internal armor layer from [parent]."))
		if(17)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the internal armor layer to [parent]."), SPAN_NOTICE("You weld the internal armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the internal armor layer."), SPAN_NOTICE("You unfasten the internal armor layer."))
		if(18)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] installs the external armor layer to [parent]."), SPAN_NOTICE("You install the external reinforced armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] cuts the internal armor layer from [parent]."), SPAN_NOTICE("You cut the internal armor layer from [parent]."))
		if(19)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] secures the external armor layer."), SPAN_NOTICE("You secure the external reinforced armor layer."))
			else
				user.visible_message(SPAN_NOTICE("[user] pries the external armor layer from [parent]."), SPAN_NOTICE("You pry the external armor layer from [parent]."))
		if(20)
			if(diff==FORWARD)
				user.visible_message(SPAN_NOTICE("[user] welds the external armor layer to [parent]."), SPAN_NOTICE("You weld the external armor layer to [parent]."))
			else
				user.visible_message(SPAN_NOTICE("[user] unfastens the external armor layer."), SPAN_NOTICE("You unfasten the external armor layer."))
	return TRUE
