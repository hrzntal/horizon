GLOBAL_LIST_EMPTY(command_positions)


GLOBAL_LIST_EMPTY(engineering_positions)


GLOBAL_LIST_EMPTY(medical_positions)


GLOBAL_LIST_EMPTY(science_positions)


GLOBAL_LIST_EMPTY(supply_positions)


GLOBAL_LIST_EMPTY(service_positions)


GLOBAL_LIST_EMPTY(civillian_positions)


GLOBAL_LIST_EMPTY(misc_positions)


GLOBAL_LIST_EMPTY(security_positions)

/// These aren't defacto jobs, but are the special departmental variants for sec officers.
GLOBAL_LIST_INIT(security_sub_positions, list(
	"Security Officer (Cargo)" = TRUE,
	"Security Officer (Engineering)" = TRUE,
	"Security Officer (Medical)" = TRUE,
	"Security Officer (Science)" = TRUE,
))

GLOBAL_LIST_INIT(nonhuman_positions, list(ROLE_PAI = TRUE))

// job categories for rendering the late join menu
GLOBAL_LIST_INIT(position_categories, list(
	EXP_TYPE_COMMAND = list("jobs" = command_positions, "color" = "#ccccff"),
	EXP_TYPE_ENGINEERING = list("jobs" = engineering_positions, "color" = "#ffeeaa"),
	EXP_TYPE_SUPPLY = list("jobs" = supply_positions, "color" = "#ddddff"),
	EXP_TYPE_SILICON = list("jobs" = nonhuman_positions - "pAI", "color" = "#ccffcc"),
	EXP_TYPE_MISC = list("jobs" = misc_positions, "color" = "#eeeeee"),
	EXP_TYPE_MEDICAL = list("jobs" = medical_positions, "color" = "#ffddf0"),
	EXP_TYPE_SCIENCE = list("jobs" = science_positions, "color" = "#ffddff"),
	EXP_TYPE_SECURITY = list("jobs" = security_positions, "color" = "#ffdddd"),
	EXP_TYPE_CIVILLIAN = list("jobs" = civillian_positions, "color" = "#dddddd"),
	EXP_TYPE_SERVICE = list("jobs" = service_positions, "color" = "#bbe291")
))

GLOBAL_LIST_INIT(exp_jobsmap, list(
	EXP_TYPE_CREW = list("titles" = command_positions | engineering_positions | medical_positions | science_positions | supply_positions | security_positions | service_positions | list("AI","Cyborg")), // crew positions
	EXP_TYPE_COMMAND = list("titles" = command_positions),
	EXP_TYPE_ENGINEERING = list("titles" = engineering_positions),
	EXP_TYPE_MEDICAL = list("titles" = medical_positions),
	EXP_TYPE_SCIENCE = list("titles" = science_positions),
	EXP_TYPE_SUPPLY = list("titles" = supply_positions),
	EXP_TYPE_SECURITY = list("titles" = security_positions),
	EXP_TYPE_CIVILLIAN = list("titles" = civillian_positions),
	EXP_TYPE_MISC = list("titles" = misc_positions),
	EXP_TYPE_SILICON = list("titles" = list("AI","Cyborg")),
	EXP_TYPE_SERVICE = list("titles" = service_positions)
))

GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_SPECIAL = list("Lifebringer","Ash Walker","Exile","Servant Golem","Free Golem","Hermit","Translocated Vet","Escaped Prisoner","Hotel Staff","SuperFriend","Space Syndicate","Ancient Crew","Space Doctor","Space Bartender","Beach Bum","Skeleton","Zombie","Space Bar Patron","Lavaland Syndicate","Maintenance Drone","Ghost Role"), // Ghost roles
	EXP_TYPE_GHOST = list() // dead people, observers
))
GLOBAL_PROTECT(exp_jobsmap)
GLOBAL_PROTECT(exp_specialmap)

//this is necessary because antags happen before job datums are handed out, but NOT before they come into existence
//so I can't simply use job datum.department_head straight from the mind datum, laaaaame.
/proc/get_department_heads(job_title)
	if(!job_title)
		return list()

	for(var/datum/job/J in SSjob.occupations)
		if(J.title == job_title)
			return J.department_head //this is a list

/proc/get_full_job_name(job)
	var/static/regex/cap_expand = new("cap(?!tain)")
	var/static/regex/cmo_expand = new("cmo")
	var/static/regex/hos_expand = new("hos")
	var/static/regex/hop_expand = new("hop")
	var/static/regex/rd_expand = new("rd")
	var/static/regex/ce_expand = new("ce")
	var/static/regex/qm_expand = new("qm")
	var/static/regex/sec_expand = new("(?<!security )officer")
	var/static/regex/engi_expand = new("(?<!station )engineer")
	var/static/regex/atmos_expand = new("atmos tech")
	var/static/regex/doc_expand = new("(?<!medical )doctor|medic(?!al)")
	var/static/regex/mine_expand = new("(?<!shaft )miner")
	var/static/regex/chef_expand = new("chef")
	var/static/regex/borg_expand = new("(?<!cy)borg")

	job = lowertext(job)
	job = cap_expand.Replace(job, "captain")
	job = cmo_expand.Replace(job, "chief medical officer")
	job = hos_expand.Replace(job, "head of security")
	job = hop_expand.Replace(job, "head of personnel")
	job = rd_expand.Replace(job, "research director")
	job = ce_expand.Replace(job, "chief engineer")
	job = qm_expand.Replace(job, "quartermaster")
	job = sec_expand.Replace(job, "security officer")
	job = engi_expand.Replace(job, "station engineer")
	job = atmos_expand.Replace(job, "atmospheric technician")
	job = doc_expand.Replace(job, "medical doctor")
	job = mine_expand.Replace(job, "shaft miner")
	job = chef_expand.Replace(job, "cook")
	job = borg_expand.Replace(job, "cyborg")
	return job
