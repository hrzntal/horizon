/datum/mainmenu

/datum/mainmenu/ui_state(mob/user)
	return GLOB.always_state

/datum/mainmenu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "MainMenu")
		ui.open()

/datum/mainmenu/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/dead/new_player/user = usr

	if(!istype(user))
		SStgui.force_close_window(usr, GLOB.mainmenu_tgui)
		return

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hpc = CONFIG_GET(number/hard_popcap)
	var/epc = CONFIG_GET(number/extreme_popcap)
	if(hpc && epc)
		relevant_cap = min(hpc, epc)
	else
		relevant_cap = max(hpc, epc)

	// This is more or less just injecting the old href-based system into this
	// There should be and is a much better way to do this
	// But I am short on time, so this will do for now.
	// <TODO> Improve this spaghetti
	switch(action)
		if("setup")
			// Show setup panel
			usr.client.prefs.needs_update = TRUE
			usr.client.prefs.ShowChoices(usr)

		if("crew_manifest")
			// Show the crew manifest
			user.ViewManifest()

		if("ready")
			// Make user ready
			if(SSticker.current_state <= GAME_STATE_PREGAME)
				user.ready = PLAYER_READY_TO_PLAY

		if("unready")
			// Make user not ready
			if(SSticker.current_state <= GAME_STATE_PREGAME)
				user.ready = PLAYER_NOT_READY

		if("latejoin")
			// Let the user join
			if(!SSticker?.IsRoundInProgress())
				to_chat(usr, "<span class='boldwarning'>The round is either not ready, or has already finished...</span>")
				return

			if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(usr.key) in GLOB.admin_datums)))
				to_chat(usr, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

				var/queue_position = SSticker.queued_players.Find(usr)
				if(queue_position == 1)
					to_chat(usr, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
				else if(queue_position)
					to_chat(usr, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
				else
					SSticker.queued_players += usr
					to_chat(usr, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
				return

			user.LateChoices()

		if("observe")
			// Let the user observe
			if(SSticker.current_state < GAME_STATE_PREGAME)
				user.ready = PLAYER_READY_TO_OBSERVE

			user.make_me_an_observer()

		if("polls")
			// Show polls
			// <TODO> add polls. Maybe.
			return


/datum/mainmenu/ui_data(mob/user)
	var/mob/dead/new_player/new_user = user
	if(!istype(new_user))
		SStgui.force_close_window(user, GLOB.mainmenu_tgui)
		return
	var/greeting_title = "New Player Options"
	var/map_description = null

	if(SSmapping && SSmapping.config)
		map_description = SSmapping.config.get_map_info()
		greeting_title = "Welcome to [SSmapping.config.map_name]"

	return list(
		"title" = greeting_title,
		"mapdesc" = map_description,
		"player_ready" = new_user?.ready,
		"game_state" = SSticker.current_state,
	)
