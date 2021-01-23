/datum/attribute_sheet
	var/list/attributes = list()
	var/list/skills = list()

/datum/attribute_sheet/antagonist
	attributes = list(/datum/attribute/strength = 2, \
					/datum/attribute/dexterity = 2, \
					/datum/attribute/endurance = 2, \
					/datum/attribute/intelligence = 2)

/datum/attribute_sheet/cook
	skills = list(/datum/nice_skill/cooking = 3)
