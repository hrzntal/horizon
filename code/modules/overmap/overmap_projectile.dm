/datum/overmap_object/projectile
	visual_type = /obj/effect/abstract/overmap
	overmap_process = TRUE
	overmap_flags = NONE
	/// Parent of the projectile, used for avoiding it
	var/datum/overmap_object/parent
	/// Target of the projectile, used for homing
	var/datum/overmap_object/target
	/// Whether it does avoid the parent
	var/avoids_parent = TRUE
	/// Whether it is homing on the target
	var/homing_on_target = TRUE
	/// Whether it only hits the target, or can hit things that get inbetween
	var/only_hits_target = TRUE
	/// Vector velocity of the projectile
	var/speed = 3
	/// Maximum distance in pixels (32 per tile)
	var/max_distance = 96
	var/distance_so_far = 0

	var/absolute_dest_x = 0
	var/absolute_dest_y = 0

	var/last_angle

/datum/overmap_object/projectile/New(datum/overmap_sun_system/passed_system, x_coord, y_coord, part_x, part_y, passed_parent, passed_target)
	. = ..()
	partial_x = part_x
	partial_y = part_y
	UpdateVisualOffsets()
	if(passed_parent)
		parent = passed_parent
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/LoseParent)
	//Target currently needs to be passed
	target = passed_target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/LoseTarget)

	absolute_dest_x = (target.x * 32) + target.partial_x
	absolute_dest_y = (target.y * 32) + target.partial_y

/datum/overmap_object/projectile/process()
	var/new_angle = FALSE
	if(homing_on_target && target)
		new_angle = TRUE
		absolute_dest_x = (target.x * 32) + target.partial_x
		absolute_dest_y = (target.y * 32) + target.partial_y
	if(!last_angle)
		new_angle = TRUE

	if(new_angle)
		var/absolute_pos_x = (x*32)+partial_x
		var/aboslute_pos_y = (y*32)+partial_y
		var/target_angle = ATAN2((absolute_dest_x-aboslute_pos_y,absolute_dest_x-absolute_pos_x)
		if(target_angle < 0)
			target_angle = 360 + target_angle
		if(target_angle > 180)
			target_angle -= 360
		last_angle = new_angle

	var/x_to_add = sin(last_angle) * speed
	var/y_to_add = cos(last_angle) * speed
	partial_x += x_to_add
	partial_y += y_to_add
	distance_so_far += speed

	return

/datum/overmap_object/projectile/proc/LoseParent()
	parent = null
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)

/datum/overmap_object/projectile/proc/LoseTarget()
	target = null
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)

/datum/overmap_object/projectile/Destroy()
	if(parent)
		LoseParent()
	if(target)
		LoseTarget()
	return ..()

/datum/overmap_object/projectile/proc/HitObject(datum/overmap_object/hit_object)
	return

/datum/overmap_object/projectile/damaging
	var/damage_type = NONE
	var/damage_amount = 20
