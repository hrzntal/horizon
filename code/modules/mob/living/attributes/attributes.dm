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

/datum/attribute_holder/proc/add_sheet(sheet_type)
	var/datum/attribute_sheet/sheet = new sheet_type()
	for(var/att in sheet.attributes)
		raw_attributes[att] += sheet.attributes[att]
	for(var/skill in sheet.skills)
		raw_skills[skill] += sheet.skills[skill]
	if(sheet.all_attributes)
		for(var/stat in raw_attributes)
			raw_attributes[stat] += sheet.all_attributes
	if(sheet.all_skills)
		for(var/skill in raw_skills)
			raw_skills[skill] += sheet.all_skills
	qdel(sheet)
	update_attributes()

/datum/attribute_holder/proc/subtract_sheet(sheet_type)
	var/datum/attribute_sheet/sheet = new sheet_type()
	for(var/att in sheet.attributes)
		raw_attributes[att] -= sheet.attributes[att]
	for(var/skill in sheet.skills)
		raw_skills[skill] -= sheet.skills[skill]
	if(sheet.all_attributes)
		for(var/stat in raw_attributes)
			raw_attributes[stat] -= sheet.all_attributes
	if(sheet.all_skills)
		for(var/skill in raw_skills)
			raw_skills[skill] -= sheet.all_skills
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
				var/amt = (total_attributes[attribute] - ATTRIBUTE_EQUILIBRIUM) * SKL.attribute_affinity[attribute]
				affinity_delta += amt
			total_skills[skill] += round(affinity_delta)
	for(var/buff in skill_buffs)
		var/list/buff_list = skill_buffs[buff]
		for(var/skill in skill_buffs)
			total_skills[skill] += buff_list[skill]

/datum/attribute_holder/proc/get_affinity_values()
	var/list/returned = list()
	for(var/skill in raw_skills)
		//Handling affinities
		var/datum/nice_skill/SKL = GLOB.all_skills[skill]
		if(SKL.attribute_affinity)
			var/affinity_delta = 0
			for(var/attribute in SKL.attribute_affinity)
				var/amt = (total_attributes[attribute] - ATTRIBUTE_EQUILIBRIUM) * SKL.attribute_affinity[attribute]
				affinity_delta += amt
			returned[skill] += round(affinity_delta)
	return returned

/datum/attribute_holder/proc/ShowEditPanel(mob/user)
	if(!user || !user.client || !user.client.holder)
		return
	var/list/dat = list()
	dat += "<h3>Raw Attributes Editing:</h3>"
	for(var/attribute in raw_attributes)
		var/datum/attribute/AT = GLOB.all_attributes[attribute]
		dat += "[AT.name] - <a href='?src=[REF(src)];edit=attributes;type=[attribute]'>[raw_attributes[attribute]]</a> | [AT.desc]<BR>"
	dat += "<h3>Raw Skills Editing:</h3>"
	var/list/affinity_skills = get_affinity_values()
	for(var/skill in raw_skills)
		var/datum/nice_skill/SKL = GLOB.all_skills[skill]
		var/raw = raw_skills[skill]
		var/with_affinity = raw
		if(affinity_skills[skill])
			with_affinity += affinity_skills[skill]
		dat += "[SKL.name] - <a href='?src=[REF(src)];edit=skills;type=[skill]'>[raw]</a> ([with_affinity] /w affinity) | [SKL.desc]<BR>"
	winshow(user, "attribute_edit_window", TRUE)
	var/datum/browser/popup = new(user, "attribute_edit_window", "<div align='center'>Attributes & Skills Edit</div>", 400, 600)
	popup.set_content(dat.Join())
	popup.open(FALSE)
	onclose(user, "attribute_edit_window", user)

/datum/attribute_holder/Topic(href, href_list)
	if(!usr.client?.holder)
		return
	if(href_list["edit"])
		switch(href_list["edit"])
			if("attributes")
				var/desired_type = text2path(href_list["type"])
				var/new_number = input(usr, "Choose new value", "Attribute Editing") as num|null
				if(!new_number || QDELETED(src))
					return
				raw_attributes[desired_type] = new_number
			if("skills")
				var/desired_type = text2path(href_list["type"])
				var/new_number = input(usr, "Choose new value", "Skills Editing") as num|null
				if(!new_number || QDELETED(src))
					return
				raw_skills[desired_type] = new_number
		update_attributes()
		ShowEditPanel(usr)

//GLOBAL DATUMS
/datum/attribute
	var/name = "Attribute"
	var/desc = "Description."

/datum/attribute/proc/level_description(level)
	return "Level description of [level]"

/datum/attribute/strength
	name = "Strength"

/datum/attribute/dexterity
	name = "Dexterity"

/datum/attribute/endurance
	name = "Endurance"

/datum/attribute/intelligence
	name = "Intelligence"

//nice_skill because skill is taken by TG skills
/datum/nice_skill
	var/name = "Skill"
	var/desc = "Description."
	var/attribute_affinity

/datum/nice_skill/proc/level_description(level)
	return "Level description of [level]"

/datum/nice_skill/cqc
	name = "Melee"
	attribute_affinity = list(/datum/attribute/strength = 0.5)

/datum/nice_skill/guns
	name = "Guns"
	attribute_affinity = list(/datum/attribute/dexterity = 0.5)

/datum/nice_skill/forensics
	name = "Forensics"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/medical
	name = "Medicine"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/anatomy
	name = "Anatomy"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/eva
	name = "Extra-Vehicular Activity"
	attribute_affinity = list(/datum/attribute/dexterity = 0.5)

/datum/nice_skill/engineering
	name = "Engineering"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/mining
	name = "Mining"
	attribute_affinity = list(/datum/attribute/strength = 0.5)

/datum/nice_skill/computers
	name = "Computer Science"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/research
	name = "Technology Research"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/cooking
	name = "Cooking"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/cooking/level_description(level)
	return "You can steam a good ham."

/datum/nice_skill/botany
	name = "Botany"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/craft
	name = "Craft"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

/datum/nice_skill/art
	name = "Art"
	attribute_affinity = list(/datum/attribute/intelligence = 0.5)

//For jumping, climbing and swimming. Which I do want to eventually implement
/datum/nice_skill/athletics
	name = "Athletics"
	attribute_affinity = list(/datum/attribute/strength = 0.25, /datum/attribute/endurance = 0.25)
