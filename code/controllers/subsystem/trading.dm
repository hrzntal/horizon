SUBSYSTEM_DEF(trading)
	name = "Trading"
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = 5 MINUTES
	///List of all trade hubs
	var/list/trade_hubs = list()
	///List of all traders
	var/list/all_traders = list()
	///A dedicated global trade hub
	var/datum/trade_hub/global_trade_hub

	var/next_trade_hub_id = 0

	var/next_trader_id = 0

/datum/controller/subsystem/trading/proc/get_trade_hub_by_id(id)
	return trade_hubs["[id]"]

/datum/controller/subsystem/trading/proc/get_trader_by_id(id)
	return all_traders["[id]"]

/datum/controller/subsystem/trading/proc/get_next_trade_hub_id()
	next_trade_hub_id++
	return next_trade_hub_id

/datum/controller/subsystem/trading/proc/get_next_trader_id()
	next_trader_id++
	return next_trader_id

//Gets all available trade hubs from a turf position
/datum/controller/subsystem/trading/proc/get_available_trade_hubs(var/turf/position)
	var/list/passed_trade_hubs = list()
	if(global_trade_hub)
		passed_trade_hubs += global_trade_hub
	return passed_trade_hubs

/datum/controller/subsystem/trading/Initialize(timeofday)
	global_trade_hub = new /datum/trade_hub/default()
	return ..()

/datum/controller/subsystem/trading/fire(resumed = FALSE)
	for(var/i in trade_hubs)
		var/datum/trade_hub/hub = trade_hubs[i]
		hub.Tick()
