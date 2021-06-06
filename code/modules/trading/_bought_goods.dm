/datum/bought_goods
	///Name of the goods that will be displayed that the trader is interested in
	var/name = "goods"
	var/list/trading_types = list()
	var/list/compiled_typecache
	///The price label, if null then it'll initialize as correct price + variance
	var/cost_label
	var/cost = 100
	var/trader_price_multiplier = 1

/datum/bought_goods/New(price_multiplier)
	. = ..()
	trader_price_multiplier = price_multiplier
	cost *= price_multiplier
	cost = round(cost)
	if(!cost_label)
		cost_label = "[cost]"

	compiled_typecache = compile_typelist_for_trading(trading_types)
	trading_types = null

/datum/bought_goods/Destroy()
	compiled_typecache = null
	return ..()

/datum/bought_goods/proc/Validate(atom/movable/movable_atom_to_validate)
	if(compiled_typecache[movable_atom_to_validate.type] && IsValid(movable_atom_to_validate))
		return TRUE
	return FALSE

/// This proc is used to verify items past their typecheck verification
/datum/bought_goods/proc/IsValid(atom/movable/movable_atom_to_verify)
	return TRUE

/// This proc is used to dynamically appraise the items, changing their price based off variables, make sure the price label reflects such a possibility if used
/datum/bought_goods/proc/GetCost(atom/movable/movable_atom_to_appraise)
	return cost

/datum/bought_goods/stack
	name = "a stack"

/datum/bought_goods/stack/GetCost(atom/movable/movable_atom_to_appraise)
	var/obj/item/stack/our_stack = movable_atom_to_appraise
	return cost*our_stack.amount

/datum/bought_goods/stack/New(price_multiplier)
	. = ..()
	cost_label += " each"
