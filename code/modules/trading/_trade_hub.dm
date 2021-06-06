/datum/trade_hub
	/// Name of the trading hub
	var/name = "Trading Hub"
	/// Maximum number of traders it can house
	var/max_traders = 4
	/// A list of all the current traders inside
	var/list/traders = list()
	/// A list of all possible types of traders that can spawn in here
	var/list/possible_trader_types
	/// A list of connected trade consoles, in case the hub is destroyed we want to disconnect the consoles
	var/list/connected_consoles = list()
	var/id

#define TRADE_HUB_SPAWN_TRIES 10

/datum/trade_hub/New()
	..()
	id = SStrading.get_next_trade_hub_id()
	SStrading.trade_hubs["[id]"] = src
	if(!possible_trader_types)
		possible_trader_types = subtypesof(/datum/trader)

	var/already_picked_list = SStrading.trader_types_spawned
	for(var/i in 1 to max_traders)
		if(!length(possible_trader_types))
			break
		for(var/b in 1 to TRADE_HUB_SPAWN_TRIES)
			var/picked_type = pick_n_take(possible_trader_types)
			if(!already_picked_list[picked_type])
				already_picked_list[picked_type] = TRUE
				new picked_type(src)
				break
	possible_trader_types = null

#undef TRADE_HUB_SPAWN_TRIES

/datum/trade_hub/Destroy(force)
	SStrading.trade_hubs -= "[id]"
	QDEL_LIST(traders)
	traders = null
	for(var/i in connected_consoles)
		var/obj/machinery/computer/trade_console/console = i
		console.disconnect_hub()
	connected_consoles = null
	return ..()

/datum/trade_hub/proc/Tick()
	for(var/i in traders)
		var/datum/trader/trader = i
		trader.Tick()

/datum/trade_hub/default
	name = "Global Trade Network"
