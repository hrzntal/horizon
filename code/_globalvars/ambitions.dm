GLOBAL_LIST_EMPTY(ambitions_to_review)
GLOBAL_VAR_INIT(total_intensity, 0)
GLOBAL_LIST_INIT(intensity_counts, setup_intensity_count_list())
GLOBAL_LIST_INIT(ambitions_templates, setup_ambition_templates())

/proc/setup_intensity_count_list()
	var/list/LI = list()
	LI["[AMBITION_INTENSITY_STEALTH]"] = 0
	LI["[AMBITION_INTENSITY_MILD]"] = 0
	LI["[AMBITION_INTENSITY_MEDIUM]"] = 0
	LI["[AMBITION_INTENSITY_SEVERE]"] = 0
	LI["[AMBITION_INTENSITY_EXTREME]"] = 0
	return LI

/proc/setup_ambition_templates()
	var/list/LI = list()
	for(var/path in subtypesof(/datum/ambition_template))
		var/datum/ambition_template/P = path
		if(initial(P.name))
			P = new path()
			LI[P.name] = P
	return LI
