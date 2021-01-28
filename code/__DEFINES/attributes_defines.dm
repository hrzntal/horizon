//Defines relating to prefs
#define ATTRIBUTES_FREE_POINTS 0
#define ATTRIBUTES_PREF_MINIMUM -3
#define ATTRIBUTES_PREF_MAXIMUM 6

#define ATTRIBUTE_EQUILIBRIUM 10
#define BASE_ATTRIBUTE_AMOUNT 10

#define SKILL_EQUILIBRIUM 5
#define BASE_SKILL_AMOUNT 5

#define ADD_ATTRIBUTES(target, source, added_attributes) \
	target.attributes.attribute_buffs[source] = added_attributes; \
	target.attributes.update_attributes(); \

#define REMOVE_ATTRIBUTES(target, source) \
	target.attributes.attribute_buffs -= source; \
	target.attributes.update_attributes(); \

#define HAS_ATTRIBUTES_FROM(target, source) target.attributes.attribute_buffs[source]

#define ADD_SKILLS(target, source, skills) \
	target.attributes.skill_buffs[source] = skills; \
	target.attributes.update_skills(); \

#define REMOVE_SKILLS(target, source) \
	target.attributes.skill_buffs -= source; \
	target.attributes.update_skills(); \

#define HAS_SKILLS_FROM(target, source) target.attributes.skill_buffs[source]

///CHECKS, ROLLS AND SUCH
//Lots of sad duplicate code, but it's not that big of a deal, it's just cause you treat those 2 for checks similarly
/******************ATTRIBUTE RELATED STUFF*************/
#define GET_ATTRIBUTE(target, attribute) target.attributes.total_attributes[attribute]
#define GET_ATTRIBUTE_DELTA(target, attribute) (GET_ATTRIBUTE(target, attribute) - ATTRIBUTE_EQUILIBRIUM)

#define ATTRIBUTE_CHECK(target, attribute, check) GET_ATTRIBUTE(target, attribute) >= check

#define ATTRIBUTE_CHECK_FAIL(target, attribute, check) GET_ATTRIBUTE(target, attribute) < check

#define ATTRIBUTE_CHECK_FAIL_AND_ROLL(target, attribute, check, roll) (ATTRIBUTE_CHECK_FAIL(target, attribute, check)) && prob(roll)

#define ATTRIBUTE_VALUE(target, attribute, base, increment) base + GET_ATTRIBUTE_DELTA(target, attribute) * increment
#define NEGATIVE_ATTRIBUTE_VALUE(target, attribute, base, increment) base - GET_ATTRIBUTE_DELTA(target, attribute) * increment
#define ATTRIBUTE_VALUE_POSITIVE(target, attribute, base, increment) base + max(0,GET_ATTRIBUTE_DELTA(target, attribute)) * increment
#define ATTRIBUTE_VALUE_NEGATIVE(target, attribute, base, increment) base + min(0,GET_ATTRIBUTE_DELTA(target, attribute)) * increment

#define ATTRIBUTE_PERCENTAGE(target, attribute, base, increment) (ATTRIBUTE_VALUE(target, attribute, base, increment))/100
#define NEGATIVE_ATTRIBUTE_PERCENTAGE(target, attribute, base, increment) (NEGATIVE_ATTRIBUTE_VALUE(target, attribute, base, increment))/100
#define ATTRIBUTE_PERCENTAGE_POSITIVE(target, attribute, base, increment) (ATTRIBUTE_VALUE_POSITIVE(target, attribute, base, increment))/100
#define ATTRIBUTE_PERCENTAGE_NEGATIVE(target, attribute, base, increment) (ATTRIBUTE_VALUE_NEGATIVE(target, attribute, base, increment))/100

#define ATTRIBUTE_ROLL(target, attribute, base, increment) prob(ATTRIBUTE_VALUE(target, attribute, base, increment))
#define ATTRIBUTE_ROLL_POSITIVE(target, attribute, base, increment) prob(ATTRIBUTE_VALUE_POSITIVE(target, attribute, base, increment))
#define ATTRIBUTE_ROLL_NEGATIVE(target, attribute, base, increment) prob(ATTRIBUTE_VALUE_NEGATIVE(target, attribute, base, increment))

/******************SKILL RELATED STUFF*************/
#define GET_SKILL(target, skill) target.attributes.total_skills[skill]
#define GET_SKILL_DELTA(target, skill) (GET_SKILL(target, skill) - SKILL_EQUILIBRIUM)

//Binary TRUE/FALSE check on a threshold. If a target has matching value as the check, it'll be TRUE
#define SKILL_CHECK(target, skill, check) GET_SKILL(target, skill) >= check

#define SKILL_CHECK_FAIL(target, skill, check) GET_SKILL(target, skill) < check

#define SKILL_CHECK_FAIL_AND_ROLL(target, skill, check, roll) (SKILL_CHECK_FAIL(target, skill, check)) && prob(roll)

#define SKILL_VALUE(target, skill, base, increment) base + GET_SKILL_DELTA(target, skill) * increment
#define NEGATIVE_SKILL_VALUE(target, skill, base, increment) base - GET_SKILL_DELTA(target, skill) * increment
#define SKILL_VALUE_POSITIVE(target, skill, base, increment) base + max(0,GET_SKILL_DELTA(target, skill)) * increment
#define SKILL_VALUE_NEGATIVE(target, skill, base, increment) base + min(0,GET_SKILL_DELTA(target, skill)) * increment

#define SKILL_PERCENTAGE(target, skill, base, increment) (SKILL_VALUE(target, skill, base, increment))/100
#define SKILL_PERCENTAGE_POSITIVE(target, skill, base, increment) (SKILL_VALUE_POSITIVE(target, skill, base, increment))/100
#define SKILL_PERCENTAGE_NEGATIVE(target, skill, base, increment) (SKILL_VALUE_NEGATIVE(target, skill, base, increment))/100

//It rolls a prob on a skill delta, that is equal to 'base' + the skill delta multiplied by the increment
//For example: Someone has a skill of 7 in medicine and we roll this
//SKILL_ROLL(target, /datum/nice_skill/medical, 10, 20)
//The delta is 2, so we get 10% base chance and then 40% extra (20 * 2 from delta), resulting in a prob(50)
#define SKILL_ROLL(target, skill, base, increment) prob(SKILL_VALUE(target, skill, base, increment))
#define NEGATIVE_SKILL_ROLL(target, skill, base, increment) prob(NEGATIVE_SKILL_VALUE(target, skill, base, increment))

//Same as above, but only positive deltas matter
#define SKILL_ROLL_POSITIVE(target, skill, base, increment) prob(SKILL_VALUE_POSITIVE)
//Same, but negative deltas
#define SKILL_ROLL_NEGATIVE(target, skill, base, increment) prob(SKILL_VALUE_NEGATIVE)

#define MAXIMUM_SKILL_TIME_MULTIPLIER 3

//The bigger the base/increments the higher the reduction
#define SKILL_TIME_MULTIPLIER(target, skill, base, increment) min(MAXIMUM_SKILL_TIME_MULTIPLIER,(100/(SKILL_VALUE(target, skill, base, increment))))

#define SKILL_TOOL_SPEED_BASE 85
#define SKILL_TOOL_SPEED_INCREMENT 5

#define SURGERY_SKILL_BASE 60
#define SURGERY_SKILL_INCREMENT 10

#define EVA_GRAV_FUMBLE_RECOVER_BASE 40
#define EVA_GRAV_FUMBLE_RECOVER_INCREMENT 20

#define EVA_SPACE_WALK_SLIP_BASE 2
#define EVA_SPACE_WALK_SLIP_INCREMENT 1

#define DISLOCATION_CHIROPRACTICE_BASE 40
#define DISLOCATION_CHIROPRACTICE_INCREMENT 5

#define MEDICINE_APPLICATION_FAIL_BASE 30
#define MEDICINE_APPLICATION_FAIL_INCREMENT 10

#define STRENGTH_PUNCH_BASE_MULTIPLIER 100
#define STRENGTH_PUNCH_INCREMENT_MULTIPLIER 10

#define STRENGTH_GRAB_BASE 100
#define STRENGTH_GRAB_INCREMENT 10
#define STRENGTH_GRAB_COEFFICIENT 40 //Higher - less favor to the stronger person in grabs

#define ENDURANCE_DAMAGE_REDUCTION_BASE 100
#define ENDURANCE_DAMAGE_REDUCTION_INCREMENT 5

#define SKILL_BUFF_COFFEE "coffee"
#define COFFEE_SKILL_LIST list(/datum/attribute/intelligence = 2)

#define SKILL_BUFF_BOOZE "booze"
#define BOOZE_SKILL_TIPSY list(/datum/attribute/dexterity = -2, /datum/attribute/intelligence = -2, /datum/attribute/endurance = 2)
#define BOOZE_SKILL_DRUNK list(/datum/attribute/dexterity = -4, /datum/attribute/intelligence = -4, /datum/attribute/endurance = 4, /datum/attribute/strength = 2)
#define BOOZE_SKILL_VERY_DRUNK list(/datum/attribute/dexterity = -5, /datum/attribute/intelligence = -5, /datum/attribute/endurance = 1, /datum/attribute/strength = 1)
#define BOOZE_SKILL_WASTED list(/datum/attribute/dexterity = -4, /datum/attribute/intelligence = -4, /datum/attribute/endurance = -2)

//Lazy but efficient way to apply speed modifiers to all tools with the associated skill, probably implement more fine tuned control later (object oriented probably)
#define TOOL_BEHAVIOUR_TO_SKILL list(TOOL_CROWBAR = /datum/nice_skill/engineering, \
									TOOL_SCREWDRIVER = /datum/nice_skill/engineering, \
									TOOL_WIRECUTTER = /datum/nice_skill/engineering, \
									TOOL_WRENCH = /datum/nice_skill/engineering, \
									TOOL_WELDER = /datum/nice_skill/engineering, \
									TOOL_ANALYZER = /datum/nice_skill/engineering, \
									TOOL_MINING = /datum/nice_skill/mining, \
									TOOL_SHOVEL = /datum/nice_skill/mining, \
									TOOL_RETRACTOR = /datum/nice_skill/medical, \
									TOOL_HEMOSTAT = /datum/nice_skill/medical, \
									TOOL_CAUTERY = /datum/nice_skill/medical, \
									TOOL_DRILL = /datum/nice_skill/medical, \
									TOOL_SCALPEL = /datum/nice_skill/medical, \
									TOOL_SAW = /datum/nice_skill/medical, \
									TOOL_BONESET = /datum/nice_skill/medical, \
									TOOL_KNIFE = /datum/nice_skill/cooking, \
									TOOL_BLOODFILTER = /datum/nice_skill/medical, \
									TOOL_ROLLINGPIN = /datum/nice_skill/cooking)
