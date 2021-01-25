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

//JOB RELATED SHEETS

/datum/attribute_sheet/cook
	skills = list(/datum/nice_skill/cooking = 5)

/datum/attribute_sheet/engineer
	skills = list(/datum/nice_skill/engineering = 4, /datum/nice_skill/eva = 4)

/datum/attribute_sheet/ce
	skills = list(/datum/nice_skill/guns = 2, /datum/nice_skill/engineering = 6, /datum/nice_skill/eva = 6)

/datum/attribute_sheet/bartender
	skills = list(/datum/nice_skill/guns = 3, /datum/nice_skill/cooking = 2)

/datum/attribute_sheet/botanist
	skills = list(/datum/nice_skill/botany = 5, /datum/nice_skill/cooking = 2)

/datum/attribute_sheet/captain
	all_skills = 2

/datum/attribute_sheet/detective
	skills = list(/datum/nice_skill/forensics = 5, /datum/nice_skill/guns = 3, /datum/nice_skill/cqc = 2)

/datum/attribute_sheet/officer
	skills = list(/datum/nice_skill/guns = 4, /datum/nice_skill/cqc = 4, /datum/nice_skill/eva = 2)

/datum/attribute_sheet/hos
	skills = list(/datum/nice_skill/guns = 4, /datum/nice_skill/cqc = 4, /datum/nice_skill/eva = 2, /datum/nice_skill/forensics = 2)

/datum/attribute_sheet/doctor
	skills = list(/datum/nice_skill/medical = 4, /datum/nice_skill/anatomy = 4)

/datum/attribute_sheet/chemist
	skills = list(/datum/nice_skill/medical = 6, /datum/nice_skill/anatomy = 2)

/datum/attribute_sheet/cmo
	skills = list(/datum/nice_skill/guns = 2, /datum/nice_skill/medical = 6, /datum/nice_skill/anatomy = 6, /datum/nice_skill/eva = 2)

/datum/attribute_sheet/paramedic
	skills = list(/datum/nice_skill/medical = 4, /datum/nice_skill/anatomy = 3, /datum/nice_skill/eva = 2)

/datum/attribute_sheet/psychologist
	skills = list(/datum/nice_skill/medical = 3)

/datum/attribute_sheet/qm
	skills = list(/datum/nice_skill/guns = 2, /datum/nice_skill/eva = 2)

/datum/attribute_sheet/hop
	skills = list(/datum/nice_skill/guns = 2, /datum/nice_skill/botany = 2, /datum/nice_skill/cooking = 2, /datum/nice_skill/eva = 2)

/datum/attribute_sheet/scientist
	skills = list(/datum/nice_skill/research = 4, /datum/nice_skill/computers = 4)

/datum/attribute_sheet/roboticist
	skills = list(/datum/nice_skill/research = 2, /datum/nice_skill/engineering = 4, /datum/nice_skill/anatomy = 4)

/datum/attribute_sheet/shaft_miner
	skills = list(/datum/nice_skill/mining = 4, /datum/nice_skill/guns = 2)

/datum/attribute_sheet/rd
	skills = list(/datum/nice_skill/guns = 2, /datum/nice_skill/research = 6, /datum/nice_skill/computers = 6, /datum/nice_skill/eva = 2)

//SHEETS RELATED TO OCCUPATIONS

/datum/attribute_sheet/physical_worker
	attributes = list(/datum/attribute/strength = 2)

/datum/attribute_sheet/ship_engineer
	skills = list(/datum/nice_skill/engineering = 2,
					/datum/nice_skill/eva = 2)

/datum/attribute_sheet/construction_engineer
	skills = list(/datum/nice_skill/engineering = 2, /datum/nice_skill/craft = 2)

/datum/attribute_sheet/law_enforcer
	skills = list(/datum/nice_skill/guns = 2, /datum/nice_skill/cqc = 2)

/datum/attribute_sheet/low_wage_worker
	skills = list(/datum/nice_skill/cooking = 2, /datum/nice_skill/botany = 2)

/datum/attribute_sheet/artist
	skills = list(/datum/nice_skill/art = 4, /datum/nice_skill/craft = 2, /datum/nice_skill/engineering = -2)

/datum/attribute_sheet/deep_space_miner
	skills = list(/datum/nice_skill/mining = 2, /datum/nice_skill/eva = 2)

/datum/attribute_sheet/hermit
	skills = list(/datum/nice_skill/botany = 2, /datum/nice_skill/craft = 2)

/datum/attribute_sheet/nurse
	skills = list(/datum/nice_skill/anatomy = 2, /datum/nice_skill/medical = 2)

/datum/attribute_sheet/herbalist
	skills = list(/datum/nice_skill/botany = 3)

/datum/attribute_sheet/cook_occup
	skills = list(/datum/nice_skill/cooking = 3)

/datum/attribute_sheet/castaway
	skills = list(/datum/nice_skill/craft = 2, /datum/nice_skill/cqc = 2)
