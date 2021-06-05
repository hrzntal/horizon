//Bitflags for overmap_flags
#define OV_SHOWS_ON_SENSORS		(1<<0)
#define OV_CAN_BE_TARGETED		(1<<1)
#define OV_CAN_BE_SCANNED		(1<<2)

//Defines for helm command types
#define HELM_IDLE 0
#define HELM_FULL_STOP 1
#define HELM_MOVE_TO_DESTINATION 2
#define HELM_TURN_TO_DESTINATION 3
#define HELM_FOLLOW_SENSOR_LOCK 4
#define HELM_TURN_TO_SENSOR_LOCK 5

#define TARGET_IDLE 0
#define TARGET_FIRE_ONCE 1
#define TARGET_KEEP_FIRING 2
#define TARGET_SCAN 3
#define TARGET_BEAM_ON_BOARD 4

#define SHUTTLE_TAB_GENERAL 0
#define SHUTTLE_TAB_ENGINES 1
#define SHUTTLE_TAB_HELM 2
#define SHUTTLE_TAB_SENSORS 3
#define SHUTTLE_TAB_TARGET 4
#define SHUTTLE_TAB_DOCKING 5

#define SHUTTLE_SLOWDOWN_MARGIN 1
#define SHUTTLE_MINIMUM_VELOCITY 0.1
#define SHUTTLE_MAXIMUM_DOCKING_SPEED 0.2
#define VECTOR_LENGTH(x,y) sqrt(x**2+y**2)
#define TWO_POINT_DISTANCE(xa,ya,xb,yb) sqrt(((yb-ya)**2) + ((xa-xb)**2))
#define SENSOR_RADIUS 6
#define OVERMAP_LOCK_RANGE 3

#define SHUTTLE_ICON_IDLE 1
#define SHUTTLE_ICON_FORWARD 2
#define SHUTTLE_ICON_BACKWARD 3

#define SHUTTLE_CAN_USE_DOCK		(1<<0)
#define SHUTTLE_CAN_USE_ENGINES		(1<<1)
#define SHUTTLE_CAN_USE_SENSORS		(1<<2)
#define SHUTTLE_CAN_USE_TARGET		(1<<3)
#define ALL_SHUTTLE_CAPABILITY (SHUTTLE_CAN_USE_DOCK|SHUTTLE_CAN_USE_ENGINES|SHUTTLE_CAN_USE_SENSORS|SHUTTLE_CAN_USE_TARGET)
#define STATION_SHUTTLE_CAPABILITY (SHUTTLE_CAN_USE_ENGINES|SHUTTLE_CAN_USE_SENSORS|SHUTTLE_CAN_USE_TARGET)
#define PLANET_SHUTTLE_CAPABILITY (SHUTTLE_CAN_USE_SENSORS|SHUTTLE_CAN_USE_TARGET)

//Generaton stuff
//Amount of hazard clusters being spawned
#define DEFAULT_HAZARD_CLUSTER_AMOUNT 42
//Their "dropoff", which is a value which will be subtracted every time a node spreads, into a chance to continue spreading. Higher dropoff = smaller nodes
#define DEFAULT_HAZARD_CLUSTER_DROPOFF 4
//All overmap hazards to be seeded randomly by default
#define DEFAULT_OVERMAP_HAZARDS list(/datum/overmap_object/hazard/asteroid, \
									/datum/overmap_object/hazard/dust, \
									/datum/overmap_object/hazard/electrical_storm,\
									/datum/overmap_object/hazard/ion_storm,\
									/datum/overmap_object/hazard/carp_school)

//OVERMAP LAYERS

#define OVERMAP_LAYER_LOWEST 3
#define OVERMAP_LAYER_HAZARD 3.1
#define OVERMAP_LAYER_PLANET 3.2
#define OVERMAP_LAYER_STATION 3.3
#define OVERMAP_LAYER_SHIP 3.4
#define OVERMAP_LAYER_SHUTTLE 3.5
