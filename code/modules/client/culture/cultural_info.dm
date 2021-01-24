/datum/cultural_info
	/// Name of the cultural thing, be it place, faction, or culture
	var/name
	/// It's description
	var/description
	/// Economic power, this impacts the initial paychecks by a bit
	var/economic_power = 1
	/// It'll force people to know this language if they've picked this cultural thing
	var/required_lang
	/// This will allow people to pick extra languages
	var/list/additional_langs
	/// Having this picked will grant you the following sheet
	var/attribute_sheet

/datum/cultural_info/proc/get_extra_desc(more = FALSE)
	. += "<BR>Economic power: [economic_power*100]%"
	if(required_lang)
		var/datum/language/lang_datum = required_lang
		. += "<BR>Language: [initial(lang_datum.name)]"
	if(!more)
		return
	if(attribute_sheet)
		. += "<BR>Attribute & Skill changes:"
		var/datum/attribute_sheet/sheet = new attribute_sheet()
		if(sheet.all_attributes)
			. += "<BR>-All attributes: [sheet.all_attributes]"
		if(sheet.all_skills)
			. += "<BR>-All skill: [sheet.all_attributes]"
		for(var/att in sheet.attributes)
			var/datum/attribute/ATT = GLOB.all_attributes[att]
			. += "<BR>-[ATT.name]: [sheet.attributes[att]]"

		for(var/skl in sheet.skills)
			var/datum/nice_skill/SKL = GLOB.all_skills[skl]
			. += "<BR>-[SKL.name]: [sheet.skills[skl]]"

		qdel(sheet)
	if(additional_langs)
		. += "<BR>Optional Languages: "
		var/not_first_iteration = FALSE
		for(var/langkey in additional_langs)
			var/datum/language/lang_datum = langkey
			if(not_first_iteration)
				. += ", "
			else
				not_first_iteration = TRUE
			. += "[initial(lang_datum.name)]"
