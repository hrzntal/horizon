/datum/attribute_sheet
	var/all_attributes
	var/all_skills
	var/list/attributes = list()
	var/list/skills = list()

//Attribute sheets get instantiated for a moment to lookup their variables, have this to clean up properly
/datum/attribute_sheet/Destroy()
	attributes = null
	skills = null
	return ..()

/datum/attribute_sheet/antagonist
	all_attributes = 2
	all_skills = 2

/datum/attribute_sheet/cook
	skills = list(/datum/nice_skill/cooking = 5)
