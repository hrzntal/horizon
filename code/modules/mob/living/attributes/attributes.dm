/datum/attribute_holder
	var/raw_attributes = list()
	var/total_attributes = list()

	var/attribute_buffs = list()

	var/raw_skills = list()
	var/total_skills = list()

	var/skill_buffs = list()

/datum/attribute_holder/New()
	for(var/attribute in GLOB.all_attributes)
		raw_attributes[attribute] = BASE_ATTRIBUTE_AMOUNT
	for(var/skill in GLOB.all_skills)
		raw_skills[skill] = BASE_SKILL_AMOUNT
	update_attributes()

/datum/attribute_holder/Destroy()
	//This is eerie, but it should clean everything properly
	raw_attributes = null
	total_attributes = null
	attribute_buffs = null
	raw_skills = null
	total_skills = null
	skill_buffs = null
	return ..()

/datum/attribute_holder/proc/apply_sheet(sheet_type)
	var/datum/attribute_sheet/sheet = new sheet_type()
	for(var/att in sheet.attributes)
		raw_attributes[att] += sheet.attributes[att]
	for(var/skill in sheet.skills)
		raw_skills[skill] += sheet.skills[skill]
	qdel(sheet)
	update_attributes()

/datum/attribute_holder/proc/update_attributes()
	for(var/attribute in raw_attributes)
		total_attributes[attribute] = raw_attributes[attribute]
	for(var/buff in attribute_buffs)
		var/list/buff_list = attribute_buffs[buff]
		for(var/att in buff_list)
			total_attributes[att] += buff_list[att]
	update_skills()

/datum/attribute_holder/proc/update_skills()
	for(var/skill in raw_skills)
		total_skills[skill] = raw_skills[skill]
		//Handling affinities
		var/datum/nice_skill/SKL = GLOB.all_skills[skill]
		if(SKL.attribute_affinity)
			var/affinity_delta = 0
			for(var/attribute in SKL.attribute_affinity)
				var/amt = round((total_attributes[attribute] - ATTRIBUTE_EQUILIBRIUM) * SKL.attribute_affinity[attribute])
				affinity_delta += amt
			total_skills[skill] += affinity_delta
	for(var/buff in skill_buffs)
		var/list/buff_list = skill_buffs[buff]
		for(var/skill in skill_buffs)
			total_skills[skill] += buff_list[skill]

//Optimized targeted procs for updates, which only target related stats/skills and affinities
/datum/attribute_holder/proc/update_attributes_from(list/passed_list)
	if(!passed_list) //Can be null
		return
	var/list/skill_updates = list()
	for(var/att in passed_list)
		total_attributes[att] = raw_attributes[att]
		for(var/buff in attribute_buffs)
			var/list/buff_list = attribute_buffs[buff]
			if(buff_list[att])
				total_attributes[att] += buff_list[att]
		for(var/skill in raw_skills)
			var/datum/nice_skill/SKL = GLOB.all_skills[skill]
			if(SKL.attribute_affinity && SKL.attribute_affinity[att])
				skill_updates[skill] = TRUE
	update_skills_from(skill_updates)

/datum/attribute_holder/proc/update_skills_from(list/passed_list)
	if(!passed_list) //Can be null
		return
	for(var/skill in passed_list)
		total_skills[skill] = raw_skills[skill]
		//Handling affinities
		var/datum/nice_skill/SKL = GLOB.all_skills[skill]
		if(SKL.attribute_affinity)
			var/affinity_delta = 0
			for(var/attribute in SKL.attribute_affinity)
				var/amt = round((total_attributes[attribute] - ATTRIBUTE_EQUILIBRIUM) * SKL.attribute_affinity[attribute])
				affinity_delta += amt
			total_skills[skill] += affinity_delta
		for(var/buff in skill_buffs)
			var/list/buff_list = skill_buffs[buff]
			if(buff_list[skill])
				total_skills[skill] += buff_list[skill]

//GLOBAL DATUMS
/datum/attribute
	var/name = "Attribute"
	var/desc = "Description."

/datum/attribute/strength
	name = "Strength"

/datum/attribute/dexterity
	name = "Dexterity"

/datum/attribute/endurance
	name = "Endurance"

/datum/attribute/intelligence
	name = "Intelligence"

/datum/nice_skill
	var/name = "Skill"
	var/desc = "Description."
	var/attribute_affinity

//nice_skill because skill is taken by TG skills
/datum/nice_skill/cqc
	name = "Close Quarter Combat"
	attribute_affinity = list(/datum/attribute/strength = 0.5)

/datum/nice_skill/guns
	name = "Guns"
	attribute_affinity = list(/datum/attribute/dexterity = 0.5)

/datum/nice_skill/cooking
	name = "Cooking"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/medicine
	name = "Medicine"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/eva
	name = "EVA Operations"
	attribute_affinity = list(/datum/attribute/dexterity = 0.5)

/datum/nice_skill/construction
	name = "Construction"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/electrician
	name = "Electrician"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/crafting
	name = "Crafting"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)
