/datum/element/footstep_override
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/footstep
	var/barefootstep
	var/clawfootstep
	var/heavyfootstep
	var/static/list/connection_signal = list(
		COMSIG_MOB_PLAYS_FOOTSTEP = .proc/on_footstep,
	)

/datum/element/footstep_override/Attach(datum/target, _footstep, _barefootstep, _clawfootstep, _heavyfootstep)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.footstep = _footstep
	src.barefootstep = _barefootstep
	src.clawfootstep = _clawfootstep
	src.heavyfootstep = _heavyfootstep

	AddElement(/datum/element/connect_loc, target, connection_signal)

/datum/element/footstep_override/proc/on_footstep(datum/source, footstep_type, volume, e_range, sound_vary)
	var/played_step
	var/sound_ref
	switch(footstep_type)
		if(FOOTSTEP_MOB_CLAW)
			played_step = clawfootstep
			sound_ref = GLOB.clawfootstep
		if(FOOTSTEP_MOB_BAREFOOT)
			played_step = barefootstep
			sound_ref = GLOB.barefootstep
		if(FOOTSTEP_MOB_HEAVY)
			played_step = heavyfootstep
			sound_ref = GLOB.heavyfootstep
		if(FOOTSTEP_MOB_SHOE)
			played_step = footstep
			sound_ref = GLOB.footstep
	if(!played_step)
		return
	playsound(source, pick(sound_ref[played_step][1]), sound_ref[played_step][2] * volume, TRUE, sound_ref[played_step][3] + e_range, falloff_distance = 1, vary = sound_vary)
	return COMPONENT_CANCEL_PLAY_FOOTSTEP

/datum/element/footstep_override/Detach(datum/target)
	. = ..()
	if(ismovable(target))
		RemoveElement(/datum/element/connect_loc, target, connection_signal)
