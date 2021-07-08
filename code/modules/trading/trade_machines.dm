/obj/machinery/computer/trade_console
	name = "trade console"
	icon_screen = "supply"
	desc = "Used for communication between the trade networks and for conducting trades."
	circuit = /obj/item/circuitboard/computer/trade_console
	light_color = COLOR_BRIGHT_ORANGE
	var/obj/machinery/trade_pad/linked_pad
	var/credits_held = 0

	var/last_transmission = ""
	var/denied_hail_transmission

	var/datum/trade_hub/connected_hub
	var/datum/trader/connected_trader
	var/trader_screen_state = TRADER_SCREEN_NOTHING

/obj/machinery/computer/trade_console/proc/connect_hub(datum/trade_hub/passed_hub)
	if(connected_hub)
		disconnect_hub()
	connected_hub = passed_hub
	connected_hub.connected_consoles += src

/obj/machinery/computer/trade_console/proc/connect_trader(datum/trader/passed_trader)
	if(connected_trader)
		disconnect_trader()
	connected_trader = passed_trader
	connected_trader.connected_consoles += src
	denied_hail_transmission = null

/obj/machinery/computer/trade_console/proc/disconnect_hub()
	if(!connected_hub)
		return
	if(connected_trader)
		disconnect_trader()
	connected_hub.connected_consoles -= src
	connected_hub = null
	denied_hail_transmission = null
	
/obj/machinery/computer/trade_console/proc/disconnect_trader()
	if(!connected_trader)
		return
	connected_trader.connected_consoles -= src
	connected_trader = null
	trader_screen_state = TRADER_SCREEN_NOTHING

/obj/machinery/computer/trade_console/proc/withdraw_credits(amount, mob/user)
	if(!amount || !credits_held)
		return
	if(amount > credits_held)
		amount = credits_held
	credits_held -= amount
	var/obj/item/holochip/holochip = new(loc, amount)
	if(user)
		to_chat(user, "<span class='notice'>You withdraw [amount] credits.</span>")
		user.put_in_hands(holochip)

/obj/machinery/computer/trade_console/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holochip) || istype(I, /obj/item/stack/spacecash) || istype(I, /obj/item/coin))
		var/worth = I.get_item_credit_value()
		if(!worth)
			to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		credits_held += worth
		to_chat(user, "<span class='notice'>You slot [I] into [src] and it reports a total of [credits_held] credits inserted.</span>")
		qdel(I)
		return
	. = ..()

/obj/machinery/computer/trade_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	if(!isliving(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	if(!linked_pad)
		try_link_pad()
	var/list/dat = list()
	//Header
	dat += "Pad: [linked_pad ? "Connected" : "NOT CONNECTED!"] | Balance: [credits_held] credits"
	dat += "<BR>Connected network: [connected_hub ? "[connected_hub.name] <a href='?src=[REF(src)];task=main_task;pref=disconnect_hub'>Disconnect</a>" : "None"]<HR>"
	//Body
	if(connected_trader)
		//Trader menu

		//Name, orgin, disconnect button and transmission text
		dat += "<a href='?src=[REF(src)];task=hub_task;pref=disconnect_trader'>Return to hub</a><BR><center><b>[connected_trader.name]</b><BR>Origin: [connected_trader.origin]<BR><table align='center'; width='100%'; height='60px'; style='background-color:#13171C'><tr width='100%'><td width='100%'><center>[last_transmission]</center></td></tr></table></center><HR>"

		//Buttons
		dat += "<center><a href='?src=[REF(src)];task=trader_task;pref=button_show_goods'>Show me your goods</a>"
		dat += "<BR><a href='?src=[REF(src)];task=trader_task;pref=button_show_purchasables'>Any goods you're interested in?</a>"
		dat += "<BR><a href='?src=[REF(src)];task=trader_task;pref=button_appraise'>Appraise item(s) on the pad</a>"
		dat += "<BR><a href='?src=[REF(src)];task=trader_task;pref=button_sell_item'>Sell all items on the pad</a>"
		dat += "<BR><a href='?src=[REF(src)];task=trader_task;pref=button_compliment'>Compliment</a>"
		dat += " <a href='?src=[REF(src)];task=trader_task;pref=button_insult'>Insult</a></center>"

		//Item menus, if applicable
		if(trader_screen_state)
			dat += "<HR>"
			switch(trader_screen_state)
				if(TRADER_SCREEN_SOLD_GOODS)
					dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
					dat += "<tr style='vertical-align:top'>"
					dat += "<td width=45%>Name:</td>"
					dat += "<td width=10%>Stock:</td>"
					dat += "<td width=10%>Price:</td>"
					dat += "<td width=35%>Actions:</td>"
					dat += "</tr>"
					var/even = TRUE
					var/goodie_index = 0
					for(var/i in connected_trader.sold_goods)
						even = !even
						goodie_index++
						var/datum/sold_goods/goodie = connected_trader.sold_goods[i]
						dat += "<tr style='background-color: [even ? "#17191C" : "#23273C"];'>"
						dat += "<td>[goodie.name]</td>"
						dat += "<td>[goodie.current_stock ? goodie.current_stock : "OUT!"]</td>"
						dat += "<td>[goodie.cost]</td>"
						dat += "<td><a href='?src=[REF(src)];task=trader_task;pref=interact_with_sold;sold_type=buy;index=[goodie_index]'>Buy</a><a href='?src=[REF(src)];task=trader_task;pref=interact_with_sold;sold_type=haggle;index=[goodie_index]'>Haggle</a><a href='?src=[REF(src)];task=trader_task;pref=interact_with_sold;sold_type=barter;index=[goodie_index]'>Barter</a></td>"
						dat += "</tr>"
				if(TRADER_SCREEN_BOUGHT_GOODS)
					dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
					dat += "<tr style='vertical-align:top'>"
					dat += "<td width=35%>Name:</td>"
					dat += "<td width=20%>Price:</td>"
					dat += "<td width=10%>Amount:</td>"
					dat += "<td width=35%>Actions:</td>"
					dat += "</tr>"
					var/even = TRUE
					var/goodie_index = 0
					for(var/i in connected_trader.bought_goods)
						even = !even
						goodie_index++
						var/datum/bought_goods/goodie = connected_trader.bought_goods[i]
						dat += "<tr style='background-color: [even ? "#17191C" : "#23273C"];'>"
						dat += "<td>[goodie.name]</td>"
						dat += "<td>[goodie.cost_label]</td>"
						dat += "<td>[isnull(goodie.amount) ? "-" : "[goodie.amount]"]</td>"
						dat += "<td><a href='?src=[REF(src)];task=trader_task;pref=interact_with_bought;bought_type=sell;index=[goodie_index]'>Sell</a><a href='?src=[REF(src)];task=trader_task;pref=interact_with_bought;bought_type=haggle;index=[goodie_index]'>Haggle</a></td>"
						dat += "</tr>"

	else if (connected_hub)
		dat += "<b>Welcome to [connected_hub.name]!</b><HR>"
		//If we were denied access, let the user know
		if(denied_hail_transmission)
			dat += "<b>HAIL DENIED:</b> [denied_hail_transmission]<HR>"
		//Hub menu
		//List all merchants in the hub
		for(var/i in connected_hub.traders)
			var/datum/trader/trader = i
			dat += "<b>[trader.name]</b> - <a href='?src=[REF(src)];task=hub_task;pref=hail_merchant;id=[trader.id]'>Hail</a><BR>Origin: [trader.origin]<HR>"
	else
		//Main menu
		//List available trade hubs
		dat += "<b>Trade networks available:</b>"
		var/list/trade_hubs = SStrading.get_available_trade_hubs(get_turf(src))
		for(var/i in trade_hubs)
			var/datum/trade_hub/trade_hub = i
			dat += "<BR><a href='?src=[REF(src)];task=main_task;pref=choose_hub;id=[trade_hub.id]'>[trade_hub.name]</a>"
		dat += "<HR><a href='?src=[REF(src)];task=main_task;pref=withdraw_money'>Withdraw credits</a>"

	var/datum/browser/popup = new(user, "trade_console", "Trade Console", 450, 600)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/computer/trade_console/Topic(href, href_list)
	. = ..()
	var/mob/living/living_user = usr
	if(!istype(living_user) || !living_user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	switch(href_list["task"])
		if("trader_task")
			if(!connected_trader)
				return
			if(!linked_pad)
				say("Please connect a trade tele-pad before conducting in trade.")
				return
			switch(href_list["pref"])
				if("interact_with_sold")
					var/index = text2num(href_list["index"])
					if(connected_trader.sold_goods.len < index)
						return
					var/datum/sold_goods/goodie = connected_trader.sold_goods[connected_trader.sold_goods[index]]
					switch(href_list["sold_type"])
						if("buy")
							last_transmission = connected_trader.requested_buy(living_user, src, goodie)
						if("barter")
							last_transmission = connected_trader.requested_barter(living_user, src, goodie)
						if("haggle")
							var/proposed_value = input(living_user, "How much credits do you offer?", "Trade Console") as num|null
							if(!proposed_value || QDELETED(connected_trader) || QDELETED(goodie))
								return
							last_transmission = connected_trader.requested_buy(living_user, src, goodie, proposed_value)
				if("interact_with_bought")
					var/index = text2num(href_list["index"])
					if(connected_trader.bought_goods.len < index)
						return
					var/datum/bought_goods/goodie = connected_trader.bought_goods[connected_trader.bought_goods[index]]
					switch(href_list["bought_type"])
						if("sell")
							last_transmission = connected_trader.requested_sell(living_user, src, goodie)
						if("haggle")
							var/proposed_value = input(living_user, "How much credits do you demand?", "Trade Console") as num|null
							if(!proposed_value || QDELETED(connected_trader) || QDELETED(goodie))
								return
							last_transmission = connected_trader.requested_sell(living_user, src, goodie, proposed_value)
				if("button_show_goods")
					if(connected_trader.trade_flags & TRADER_SELLS_GOODS)
						trader_screen_state = TRADER_SCREEN_SOLD_GOODS
						last_transmission = connected_trader.get_response("trade_show_goods", "This is what I've got to offer!", living_user)
					else
						last_transmission = connected_trader.get_response("trade_no_sell_goods", "I don't sell any goods.", living_user)
						
				if("button_show_purchasables")
					if(connected_trader.trade_flags & TRADER_BUYS_GOODS)
						trader_screen_state = TRADER_SCREEN_BOUGHT_GOODS
						last_transmission = connected_trader.get_response("what_want", "Hm, I want.. those..", living_user)
					else
						last_transmission = connected_trader.get_response("trade_no_goods", "I don't deal in goods!", living_user)

				if("button_compliment")
					if(prob(50))
						last_transmission = connected_trader.get_response("compliment_deny", "Ehhh.. thanks?", living_user)
					else
						last_transmission = connected_trader.get_response("compliment_accept", "Thank you!", living_user)

				if("button_insult")
					if(prob(50))
						last_transmission = connected_trader.get_response("insult_bad", "What? I thought we were cool!", living_user)
					else
						last_transmission = connected_trader.get_response("insult_good", "Right back at you asshole!", living_user)
				if("button_appraise")
					if(connected_trader.trade_flags & TRADER_BUYS_GOODS)
						last_transmission = connected_trader.get_appraisal(living_user, src)
					else
						last_transmission = connected_trader.get_response("trade_no_goods", "I don't deal in goods!", living_user)
				
				if("button_sell_item")
					if(!(connected_trader.trade_flags & TRADER_BUYS_GOODS))
						last_transmission = connected_trader.get_response("trade_no_goods", "I don't deal in goods!", living_user)
					else if (!(connected_trader.trade_flags & TRADER_MONEY))
						last_transmission = connected_trader.get_response("doesnt_use_cash", "I don't deal in cash!", living_user)
					else
						last_transmission = connected_trader.sell_all_on_pad(living_user, src)
			if(!connected_trader.get_hailed(living_user, src))
				denied_hail_transmission = last_transmission
				disconnect_trader()
		if("hub_task")
			if(!connected_hub)
				return
			switch(href_list["pref"])
				if("disconnect_trader")
					disconnect_trader()
				if("hail_merchant")
					var/id = text2num(href_list["id"])
					var/datum/trader/trader = SStrading.get_trader_by_id(id)
					if(!trader)
						return
					var/is_hail_success = trader.get_hailed(living_user, src)
					var/hail_msg = trader.hail_msg(is_hail_success, living_user)
					if(is_hail_success)
						connect_trader(trader)
						last_transmission = hail_msg
					else
						denied_hail_transmission = hail_msg

		if("main_task")
			switch(href_list["pref"])
				if("choose_hub")
					var/id = text2num(href_list["id"])
					var/trade_hub = SStrading.get_trade_hub_by_id(id)
					if(trade_hub)
						connect_hub(trade_hub)
				if("withdraw_money")
					var/amount = input(living_user, "How much credits would you like to withdraw?", "Trade Console") as num|null
					if(amount && amount > 0)
						withdraw_credits(amount, living_user)
				if("disconnect_hub")
					disconnect_hub()
	ui_interact(living_user)

/obj/machinery/computer/trade_console/proc/try_link_pad()
	if(linked_pad)
		return
	for(var/direction in GLOB.cardinals)
		linked_pad = locate(/obj/machinery/trade_pad, get_step(src, direction))
		if(linked_pad && !linked_pad.linked_console)
			linked_pad.linked_console = src
			break
	return linked_pad

/obj/machinery/computer/trade_console/proc/unlink_pad()
	linked_pad.linked_console = null
	linked_pad = null

/obj/machinery/computer/trade_console/Destroy()
	if(linked_pad)
		unlink_pad()
	withdraw_credits(credits_held)
	return ..()

/obj/item/circuitboard/computer/trade_console
	name = "Trade Console (Computer Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/computer/trade_console

/obj/machinery/trade_pad
	name = "trade tele-pad"
	desc = "It's the hub of a teleporting machine."
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "tele0"
	base_icon_state = "tele"
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 2000
	circuit = /obj/item/circuitboard/machine/trade_pad
	density = FALSE
	var/obj/machinery/computer/trade_console/linked_console
	var/list/ignore_typecache = list(/atom/movable/lighting_object = TRUE,
									/obj/machinery/trade_pad = TRUE,
									/obj/machinery/navbeacon  = TRUE)
	var/list/types_of_to_add_to_ignore = list(/obj/structure/cable, /obj/structure/disposalpipe, /obj/machinery/atmospherics/pipe, /obj/effect)

/obj/machinery/trade_pad/proc/get_valid_items()
	var/turf/my_turf = get_turf(src)
	var/list/valid_items = my_turf.contents.Copy()
	for(var/item in valid_items)
		var/atom/movable/AM = item
		if(ignore_typecache[AM.type])
			valid_items -= item
	return valid_items

/obj/machinery/trade_pad/proc/do_teleport_effect()
	do_sparks(3, TRUE, src)

/obj/machinery/trade_pad/Initialize()
	. = ..()
	for(var/type in types_of_to_add_to_ignore)
		for(var/typeof in typesof(type))
			ignore_typecache[typeof] = TRUE
	types_of_to_add_to_ignore = null

/obj/machinery/trade_pad/Destroy()
	if(linked_console)
		linked_console.unlink_pad()
	ignore_typecache = null
	return ..()

/obj/item/circuitboard/machine/trade_pad
	name = "Trade Tele-Pad (Machine Board)"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/trade_pad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 2)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)
