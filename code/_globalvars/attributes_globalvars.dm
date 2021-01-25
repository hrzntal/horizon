GLOBAL_LIST_INIT(all_attributes, setup_attributes())
GLOBAL_LIST_INIT(all_skills, setup_skills())
GLOBAL_LIST_INIT(tool_to_skill, TOOL_BEHAVIOUR_TO_SKILL)

/proc/setup_attributes()
	var/list/LI = list()
	for(var/path in subtypesof(/datum/attribute))
		var/datum/attribute/AT = new path()
		LI[path] = AT
	return LI

/proc/setup_skills()
	var/list/LI = list()
	for(var/path in subtypesof(/datum/nice_skill))
		var/datum/nice_skill/SKL = new path()
		LI[path] = SKL
	return LI
