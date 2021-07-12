#define LIFT_HIT_MOB (1<<0)
#define LIFT_CRUSH_MOB (1<<1)
#define LIFT_HIT_OBJ (1<<2)
#define LIFT_HIT_BLOCK (1<<3)

#define SS_LIFTS_TICK_RATE 0.2 SECONDS
#define INDUSTRIAL_LIFT_GLIDE_SIZE_MULTIPLIER 1.6 / 10
///Because typecacheof is ass and doesn't include base types
#define INDUSTRIAL_LIFT_BLACKLISTED_TYPESOF list(\
	/obj/structure/industrial_lift, \
	/obj/structure/fluff/tram_rail, \
	/obj/machinery/atmospherics/pipe, \
	/obj/structure/disposalpipe\
	)
