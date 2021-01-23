#define ATTRIBUTE_EQUILIBRIUM 10
#define BASE_ATTRIBUTE_AMOUNT 10

#define BASE_SKILL_AMOUNT 5

#define ADD_ATTRIBUTES(target, source, attributes) \
	target.attributes.attribute_buffs[source] = attributes; \
	target.attributes.update_attributes(); \

#define REMOVE_ATTRIBUTES(target, source) \
	target.attributes.attribute_buffs -= source; \
	target.attributes.update_attributes(); \

#define HAS_ATTRIBUTES_FROM(target, source) target.attributes.attribute_buffs[source]

#define ADD_SKILLS(target, skills, source) \
	target.attributes.skill_buffs[source] = skills; \
	target.attributes.update_attributes(); \

#define REMOVE_SKILLS(target, source) \
	target.attributes.skill_buffs -= source; \
	target.attributes.update_attributes(); \

#define HAS_SKILLS_FROM(target, source) target.attributes.skill_buffs[source]
