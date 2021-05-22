/datum/overmap_object/shuttle
	name = "Shuttle"
	icon = 'icons/overmap/shuttle.dmi'
	icon_state = "shuttle"
	var/obj/docking_port/mobile/my_shuttle = null
	var/angle = 0
	var/last_relayed_direction

	var/partial_x = 0
	var/partial_y = 0

	var/velocity_x = 0
	var/velocity_y = 0

	var/target_speed = 5
	var/max_engine_speed = 10

	var/helm_command = HELM_IDLE
	var/destination_x = 0
	var/destination_y = 0

	/// Otherwise it's abstract and it doesnt have a physical shuttle in transit, or people in it. Maintain this for the purposes of AI raid ships
	var/is_physical = TRUE

	/// If true then it doesn't have a "shuttle" and is not alocated in transit and cannot dock anywhere, but things may dock into it
	var/is_seperate_z_level = FALSE //(This can mean it's several z levels too)

	/// For sensors lock follow
	var/follow_range = 1

	var/shuttle_ui_tab = SHUTTLE_TAB_GENERAL

	/// At which offset range the helm pad will apply at
	var/helm_pad_range = 3
	/// If true, then the applied offsets will be relative to the ship position, instead of direction position
	var/helm_pad_relative_destination = TRUE

	var/helm_pad_engage_immediately = TRUE

	var/open_comms_channel = FALSE

	var/datum/overmap_lock/lock

	var/target_command = TARGET_IDLE

	var/datum/overmap_shuttle_controller/shuttle_controller

/datum/overmap_object/shuttle/proc/GetSensorTargets()
	var/list/targets = list()
	for(var/overmap_object in current_system.GetObjectsInRadius(x,y,SENSOR_RADIUS))
		if(overmap_object != src)
			targets += overmap_object
	return targets

/datum/overmap_object/shuttle/proc/DisplayUI(mob/user)
	var/list/dat = list()

	dat += "<center><a href='?src=[REF(src)];task=tab;tab=0' [shuttle_ui_tab == 0 ? "class='linkOn'" : ""]>General</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=1' [shuttle_ui_tab == 1 ? "class='linkOn'" : ""]>Engines</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=2' [shuttle_ui_tab == 2 ? "class='linkOn'" : ""]>Helm</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=3' [shuttle_ui_tab == 3 ? "class='linkOn'" : ""]>Sensors</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=4' [shuttle_ui_tab == 4 ? "class='linkOn'" : ""]>Target</a>"
	dat += "<a href='?src=[REF(src)];task=tab;tab=5' [shuttle_ui_tab == 5 ? "class='linkOn'" : ""]>Dock</a>"
	dat += " <a href='?src=[REF(src)];task=refresh'>Refresh</a></center><HR>"

	switch(shuttle_ui_tab)
		if(SHUTTLE_TAB_GENERAL)
			dat += "Hull: 100% integrity"
			dat += "<BR>Shields: Not engaged"
			dat += "<BR>Position: X: [x] , Y: [y]"
			dat += "<BR>Overmap View: <a href='?src=[REF(src)];task=general;general_control=overmap'>Open</a>"
			dat += "<BR>Send a Hail: <a href='?src=[REF(src)];task=general;general_control=hail'>Send...</a>"
			dat += "<BR>Communications Channel: <a href='?src=[REF(src)];task=general;general_control=comms' [open_comms_channel ? "class='linkOn'" : ""]>[open_comms_channel ? "Open" : "Closed"]</a>"

		if(SHUTTLE_TAB_ENGINES)
			dat += "Emginmes"

		if(SHUTTLE_TAB_HELM)
			dat += "<B>Command: "
			switch(helm_command)
				if(HELM_IDLE)
					dat += "Idle.</B>"
				if(HELM_FULL_STOP)
					dat += "Full stop.</B>"
				if(HELM_MOVE_TO_DESTINATION)
					dat += "Move to destination.</B>"
				if(HELM_TURN_TO_DESTINATION)
					dat += "Turn to destination.</B>"
				if(HELM_FOLLOW_SENSOR_LOCK)
					dat += "Follow sensor lock.</B>"
				if(HELM_TURN_TO_SENSOR_LOCK)
					dat += "Turn to sensor lock.</B>"

			dat += "<BR>Position: X: [x] , Y: [y]"
			dat += "<BR>Destination: "
			dat += "X: <a href='?src=[REF(src)];task=helm;helm_control=change_x'>[destination_x]</a>"
			dat += " , Y: <a href='?src=[REF(src)];task=helm;helm_control=change_y'>[destination_y]</a>"
			var/cur_speed = VECTOR_LENGTH(velocity_x, velocity_y)
			dat += "<BR>Current speed: [cur_speed]"
			dat += "<BR> - Target: <a href='?src=[REF(src)];task=helm;helm_control=change_target_speed'>[target_speed]</a>"
			dat += "<BR> - Maximum: [max_engine_speed]"
			dat += "<BR>Commands:"
			dat += "<BR> - <a href='?src=[REF(src)];task=helm;helm_control=command_stop'>Full Stop</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=helm;helm_control=command_move_dest'>Move to Destination</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=helm;helm_control=command_turn_dest'>Turn to Destination</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=helm;helm_control=command_follow_sensor'>Follow Sensor Lock</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=helm;helm_control=command_turn_sensor'>Turn to Sensor Lock</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=helm;helm_control=command_idle'>Idle</a>"
			dat += "<BR>Pad Control: <a href='?src=[REF(src)];task=helm;helm_control=pad'>Open</a>"

		if(SHUTTLE_TAB_SENSORS)
			var/list/targets = GetSensorTargets()
			dat += "<table align='center'; width='100%'; height='100%'; style='background-color:#13171C'>"
			dat += "<tr style='vertical-align:top'>"
			dat += "<td width=30%>Name:</td>"
			dat += "<td width=10%>X:</td>"
			dat += "<td width=10%>Y:</td>"
			dat += "<td width=10%>Dist:</td>"
			dat += "<td width=40%>Actions:</td>"
			dat += "</tr>"
			var/even = TRUE
			for(var/ov_obj in targets)
				even = !even
				var/datum/overmap_object/overmap_obj = ov_obj
				var/dist = FLOOR(TWO_POINT_DISTANCE(x,y,overmap_obj.x,overmap_obj.y),1)
				var/is_destination = (destination_x == overmap_obj.x && destination_y == overmap_obj.y)
				var/is_target = (lock && lock.target == overmap_obj)
				dat += "<tr style='background-color: [even ? "#17191C" : "#23273C"];'>"
				dat += "<td>[overmap_obj.name]</td>"
				dat += "<td>[overmap_obj.x]</td>"
				dat += "<td>[overmap_obj.y]</td>"
				dat += "<td>[dist]</td>"
				dat += "<td><a href='?src=[REF(src)];task=sensor;sensor_task=target;target_id=[overmap_obj.id]'[is_target ? "class='linkOn'" : ""]>Target</a><a href='?src=[REF(src)];task=sensor;sensor_task=destination;target_id=[overmap_obj.id]' [is_destination ? "class='linkOn'" : ""]>As Dest.</a></td>"
				dat += "</tr>"
			dat += "</table>"

		if(SHUTTLE_TAB_TARGET)
			if(lock)
				lock.Resolve()
			var/locked_thing_name = lock ? lock.target.name : "NONE"
			var/locked_status = "NOT ENGAGED"
			var/locked_and_calibrated = FALSE
			if(lock)
				if(lock.is_calibrated)
					locked_and_calibrated = TRUE
					locked_status = "LOCKED"
				else
					locked_status = "CALIBRATING"

			dat += "Target: [locked_thing_name]"
			dat	+= "<BR>Lock status: [locked_status] [lock ? "<a href='?src=[REF(src)];task=target;target_control=disengage_lock'>Disengage</a>" : ""]"
			dat	+= "<BR><B>Current Command:</B> "
			switch(target_command)
				if(TARGET_IDLE)
					dat	+= "Idle."
				if(TARGET_FIRE_ONCE)
					dat	+= "Fire Once!"
				if(TARGET_KEEP_FIRING)
					dat	+= "Keep Firing!"
				if(TARGET_SCAN)
					dat	+= "Scan."
				if(TARGET_BEAM_ON_BOARD)
					dat	+= "Beam on board."
			dat += "<BR>Commands:"
			dat += "<BR> - <a href='?src=[REF(src)];task=target;target_control=command_idle' [locked_and_calibrated ? "" : "class='linkOff'"]>Idle</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=target;target_control=command_fire_once' [locked_and_calibrated ? "" : "class='linkOff'"]>Fire Once!</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=target;target_control=command_keep_firing' [locked_and_calibrated ? "" : "class='linkOff'"]>Keep Firing!</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=target;target_control=command_scan' [locked_and_calibrated ? "" : "class='linkOff'"]>Scan</a>"
			dat += "<BR> - <a href='?src=[REF(src)];task=target;target_control=command_beam_on_board' [locked_and_calibrated ? "" : "class='linkOff'"]>Beam on Board</a>"

		if(SHUTTLE_TAB_DOCKING)
			dat += "Emginmes"

	var/datum/browser/popup = new(user, "overmap_shuttle_control", "Shuttle Control", 400, 440)
	popup.set_content(dat.Join())
	popup.open()

/datum/overmap_object/shuttle/proc/DisplayHelmPad(mob/user)
	var/list/dat = list("<center>")
	dat += "<a href='?src=[REF(src)];pad_topic=nw'>O</a><a href='?src=[REF(src)];pad_topic=n'>O</a><a href='?src=[REF(src)];pad_topic=ne'>O</a>"
	dat += "<BR><a href='?src=[REF(src)];pad_topic=w'>O</a><a href='?src=[REF(src)];pad_topic=stop'>O</a><a href='?src=[REF(src)];pad_topic=e'>O</a>"
	dat += "<BR><a href='?src=[REF(src)];pad_topic=sw'>O</a><a href='?src=[REF(src)];pad_topic=s'>O</a><a href='?src=[REF(src)];pad_topic=se'>O</a></center>"
	dat += "<BR>Pad Range: <a href='?src=[REF(src)];pad_topic=range'>[helm_pad_range]</a>"
	dat += "<BR>Relative Destination: <a href='?src=[REF(src)];pad_topic=relative_dir'>[helm_pad_relative_destination ? "Yes" : "No"]</a>"
	dat += "<BR>Engage Immediately: <a href='?src=[REF(src)];pad_topic=engage_immediately'>[helm_pad_engage_immediately ? "Yes" : "No"]</a>"
	dat += "<BR>Pos.: X: [x] , Y: [y]"
	dat += " | Dest.: X: [destination_x] , Y: [destination_y]"
	dat += "<BR><center><a href='?src=[REF(src)];pad_topic=engage'>Engage</a></center>"
	var/datum/browser/popup = new(user, "overmap_helm_pad", "Helm Pad Control", 250, 250)
	popup.set_content(dat.Join())
	popup.open()

/datum/overmap_object/shuttle/proc/InputHelmPadDirection(input_x = 0, input_y = 0)
	if(!input_x && !input_y)
		StopMove()
		return
	if(helm_pad_relative_destination)
		destination_x = x
		destination_y = y
	if(input_x)
		destination_x += input_x * helm_pad_range
		destination_x = clamp(destination_x, 1, world.maxx)
	if(input_y)
		destination_y += input_y * helm_pad_range
		destination_y = clamp(destination_y, 1, world.maxy)
	if(helm_pad_engage_immediately)
		helm_command = HELM_MOVE_TO_DESTINATION
	return

/datum/overmap_object/shuttle/proc/LockLost()
	target_command = TARGET_IDLE

/datum/overmap_object/shuttle/proc/SetLockTo(datum/overmap_object/ov_obj)
	if(lock)
		if(ov_obj == lock.target)
			return
		else
			QDEL_NULL(lock)
	if(ov_obj)
		lock = new(src, ov_obj)

/datum/overmap_object/shuttle/Topic(href, href_list)
	if(href_list["pad_topic"])
		switch(href_list["pad_topic"])
			if("nw")
				InputHelmPadDirection(-1, 1)
			if("n")
				InputHelmPadDirection(0, 1)
			if("ne")
				InputHelmPadDirection(1, 1)
			if("w")
				InputHelmPadDirection(-1, 0)
			if("e")
				InputHelmPadDirection(1, 0)
			if("sw")
				InputHelmPadDirection(-1, -1)
			if("s")
				InputHelmPadDirection(0, -1)
			if("se")
				InputHelmPadDirection(1, -1)
			if("stop")
				InputHelmPadDirection()
			if("engage")
				helm_command = HELM_MOVE_TO_DESTINATION
			if("range")
				var/new_range = input(usr, "Choose new pad range", "Helm Pad Control", helm_pad_range) as num|null
				if(new_range)
					helm_pad_range = new_range
			if("relative_dir")
				helm_pad_relative_destination = !helm_pad_relative_destination
			if("engage_immediately")
				helm_pad_engage_immediately = !helm_pad_engage_immediately
		DisplayHelmPad(usr)
		return
	switch(href_list["task"])
		if("tab")
			shuttle_ui_tab = text2num(href_list["tab"])
		if("target")
			if(!lock)
				return
			switch(href_list["target_control"])
				if("disengage_lock")
					SetLockTo(null)
				if("command_idle")
					target_command = TARGET_IDLE
				if("command_fire_once")
					target_command = TARGET_FIRE_ONCE
				if("command_keep_firing")
					target_command = TARGET_KEEP_FIRING
				if("command_scan")
					target_command = TARGET_SCAN
				if("command_beam_on_board")
					target_command = TARGET_BEAM_ON_BOARD
		if("sensor")
			var/id = text2num(href_list["target_id"])
			if(!id)
				return
			var/datum/overmap_object/ov_obj = SSovermap.GetObjectByID(id)
			if(!ov_obj)
				return
			switch(href_list["sensor_task"])
				if("target")
					SetLockTo(ov_obj)
				if("destination")
					destination_x = ov_obj.x
					destination_y = ov_obj.y
		if("general")
			switch(href_list["general_control"])
				if("overmap")
					GrantOvermapView(usr)
				if("comms")
					open_comms_channel = !open_comms_channel
				if("hail")
					var/hail_msg = input(usr, "Compose a hail message:", "Hail Message")  as text|null
					if(hail_msg)
						hail_msg = strip_html_simple(hail_msg, MAX_BROADCAST_LEN, TRUE)
		if("helm")
			switch(href_list["helm_control"])
				if("pad")
					DisplayHelmPad(usr)
					return
				if("command_stop")
					helm_command = HELM_FULL_STOP
				if("command_move_dest")
					helm_command = HELM_MOVE_TO_DESTINATION
				if("command_turn_dest")
					helm_command = HELM_TURN_TO_DESTINATION
				if("command_follow_sensor")
					helm_command = HELM_FOLLOW_SENSOR_LOCK
				if("command_turn_sensor")
					helm_command = HELM_TURN_TO_SENSOR_LOCK
				if("command_idle")
					helm_command = HELM_IDLE
				if("change_x")
					var/new_x = input(usr, "Choose new X destination", "Helm Control", destination_x) as num|null
					if(new_x)
						destination_x = clamp(new_x, 1, world.maxx)
				if("change_y")
					var/new_y = input(usr, "Choose new Y destination", "Helm Control", destination_y) as num|null
					if(new_y)
						destination_y = clamp(new_y, 1, world.maxy)
				if("change_target_speed")
					var/new_speed = input(usr, "Choose new target speed", "Helm Control", target_speed) as num|null
					if(new_speed)
						target_speed = clamp(new_speed, SHUTTLE_MINIMUM_TARGET_SPEED, max_engine_speed)
	DisplayUI(usr)

/datum/overmap_object/shuttle/New()
	. = ..()
	destination_x = x
	destination_y = y
	START_PROCESSING(SSfastprocess, src)
	shuttle_controller = new(src)

/datum/overmap_object/shuttle/Destroy()
	QDEL_NULL(shuttle_controller)
	my_shuttle = null
	return ..()

/datum/overmap_object/shuttle/process(delta_time)
	var/icon_state_to_update_to = "shuttle"
	switch(helm_command)
		if(HELM_MOVE_TO_DESTINATION)
			if(x == destination_x && y == destination_y)
				StopMove()
			else
				var/target_angle = ATAN2(((destination_y*32)-((y*32)+partial_y)),((destination_x*32)-((x*32)+partial_x)))
	
				if(target_angle < 0)
					target_angle = 360 + target_angle
	
				var/my_angle = angle
				if(my_angle < 0)
					my_angle = 360 + my_angle
	
				var/diff = target_angle - my_angle
	
				var/left_turn = FALSE
				if(diff < 0)
					diff += 360
				if(diff > 180)
					diff = 360 - diff
					left_turn = TRUE
	
	
				if(!(diff < 3))
					if(left_turn)
						angle -= min(diff,10)
					else
						angle += min(diff,10)
	
				if(angle > 180)
					angle -= 360
				else if (angle < -180)
					angle += 360
	
				var/target_angle_in_byond_rad = target_angle
				if(target_angle > 180)
					target_angle_in_byond_rad -= 360
	
				var/vector_len = VECTOR_LENGTH(velocity_x, velocity_y)
				if(diff < 180 && vector_len < target_speed)
					var/added_velocity_x = TEMPLATE_SHIP_VELOCITY * sin(target_angle_in_byond_rad)
					var/added_velocity_y = TEMPLATE_SHIP_VELOCITY * cos(target_angle_in_byond_rad)
	
					if(diff > 10)
						var/angle_multiplier = 1-(diff/360)
						added_velocity_x *= angle_multiplier
						added_velocity_y *= angle_multiplier
		
					velocity_x += added_velocity_x
					velocity_y += added_velocity_y
		
					icon_state_to_update_to = "shuttle_forward"
				else if (vector_len > target_speed + SHUTTLE_SLOWDOWN_MARGIN)
					if(velocity_y)
						velocity_y *= 0.8
						icon_state_to_update_to = "shuttle_backwards"
					if(velocity_x)
						velocity_x *= 0.8
						icon_state_to_update_to = "shuttle_backwards"

		if(HELM_FULL_STOP)
			if(!velocity_x && !velocity_y)
				helm_command = HELM_IDLE
			else //Lazy
				if(velocity_y)
					velocity_y *= 0.7
					icon_state_to_update_to = "shuttle_backwards"
				if(velocity_x)
					velocity_x *= 0.7
					icon_state_to_update_to = "shuttle_backwards"



	switch(last_relayed_direction)
		if(NORTH)
			if(target_speed < max_engine_speed)
				target_speed++
		if(SOUTH)
			if(target_speed > SHUTTLE_MINIMUM_TARGET_SPEED)
				target_speed--
			else
				StopMove()

	last_relayed_direction = null

	my_visual.icon_state = icon_state_to_update_to

	//"FRICTION"
	var/velocity_length = VECTOR_LENGTH(velocity_x, velocity_y)
	if(velocity_length < SHUTTLE_MINIMUM_VELOCITY)
		velocity_x = 0
		velocity_y = 0
	else
		velocity_x *= 0.95
		velocity_y *= 0.95

		var/add_partial_x = round(velocity_x)
		var/add_partial_y = round(velocity_y)
	
		partial_x += add_partial_x
		partial_y += add_partial_y
		var/did_move = FALSE
		if(partial_y > 16)
			did_move = TRUE
			partial_y -= 32
			y = min(y+1,world.maxy)
		else if(partial_y < -16)
			did_move = TRUE
			partial_y += 32
			y = max(y-1,1)
		if(partial_x > 16)
			did_move = TRUE
			partial_x -= 32
			x = min(x+1,world.maxx)
		else if(partial_x < -16)
			did_move = TRUE
			partial_x += 32
			x = max(x-1,1)
	
		if(did_move)
			update_visual_position()
			if(shuttle_controller)
				shuttle_controller.ShuttleMovedOnOvermap()

	var/matrix/M = new
	M.Turn(angle)
	my_visual.transform = M

/datum/overmap_object/shuttle/proc/GrantOvermapView(mob/user)
	//Camera control
	if(user.client && !shuttle_controller.busy)
		shuttle_controller.SetController(user)
		return TRUE

/datum/overmap_object/shuttle/proc/CommandMove(dest_x, dest_y)
	destination_y = dest_y
	destination_x = dest_x
	helm_command = HELM_MOVE_TO_DESTINATION

/datum/overmap_object/shuttle/proc/StopMove()
	helm_command = HELM_FULL_STOP

/datum/overmap_object/shuttle/relaymove(mob/living/user, direction)
	last_relayed_direction = direction

/datum/overmap_object/shuttle/station
	is_seperate_z_level = TRUE
