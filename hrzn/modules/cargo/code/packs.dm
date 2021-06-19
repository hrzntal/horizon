/// Cost of the crate. DO NOT GO ANY LOWER THAN X1.4 the "CARGO_CRATE_VALUE" value if using regular crates, or infinite profit will be possible!

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Livestock ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/critter/doublecrab
	name = "Crab Crate"
	desc = "Contains two crabs. Get your crab on!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/mob/living/simple_animal/crab,
                    /mob/living/simple_animal/crab)
	crate_name = "look sir free crabs"

/datum/supply_pack/critter/mouse
	name = "Mouse Crate"
	desc = "Good for snakes and lizards of all ages. Contains four feeder mice." // Puts it out of range of a single-crate bounty completion.
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/mob/living/simple_animal/mouse)
	crate_name = "mouse crate"

/datum/supply_pack/critter/mouse/generate()
	. = ..()
	for(var/i in 1 to 3)
		new /mob/living/simple_animal/mouse(.)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Medical /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/medical/anesthetics
	name = "Anesthetics Crate"
	desc = "Contains two of the following: Morphine bottles, syringes, breath masks, and anesthetic tanks. Requires Medical Access to open."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/reagent_containers/glass/bottle/morphine,
                    /obj/item/reagent_containers/glass/bottle/morphine,
                    /obj/item/reagent_containers/syringe,
                    /obj/item/reagent_containers/syringe,
                    /obj/item/clothing/mask/breath,
                    /obj/item/clothing/mask/breath,
                    /obj/item/tank/internals/anesthetic,
                    /obj/item/tank/internals/anesthetic,)
	crate_name = "anesthetics crate"

/datum/supply_pack/medical/firstaidmixed
	name = "Mixed Medical Kits"
	desc = "Contains one of each medical kits for dealing with a variety of injured crewmembers."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/brute,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/regular)
	crate_name = "medical kit crate"

/datum/supply_pack/medical/medipens
	name = "Epinephrine Medipens"
	desc = "Contains two boxes of epinephrine medipens. Each box contains seven pens."
	cost = CARGO_CRATE_VALUE * 4.5
	contains = list(/obj/item/storage/box/medipens,
                    /obj/item/storage/box/medipens)
	crate_name = "medipen crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Misc Crates /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/misc/painting
	name = "Advanced Art Supplies"
	desc = "Bring out your artistic spirit with these advanced art supplies. Contains coloring supplies, cloth for canvas, and two easels to work with!"
	cost = CARGO_CRATE_VALUE * 2.2
	contains = list(/obj/structure/easel,
					/obj/structure/easel,
					/obj/item/toy/crayon/spraycan,
					/obj/item/toy/crayon/spraycan,
					/obj/item/storage/crayons,
					/obj/item/storage/crayons,
					/obj/item/toy/crayon/white,
					/obj/item/toy/crayon/white,
					/obj/item/toy/crayon/rainbow,
					/obj/item/toy/crayon/rainbow,
					/obj/item/stack/sheet/cloth/ten,
					/obj/item/stack/sheet/cloth/ten)
	crate_name = "advanced art supplies"

/datum/supply_pack/misc/paintcan
	name = "Adaptive Paintcan"
	desc = "Give things a splash of color with this experimental color-changing can of paint! Sellers note: We are not responsible for lynchings carried out by angry janitors, security officers, or any other crewmembers as a result of you using this."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/paint/anycolor)

/datum/supply_pack/misc/coloredsheets
	name = "Bedsheet Crate"
	desc = "Give your night life a splash of color with this crate filled with bedsheets! Contains a total of nine different-colored sheets."
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/bedsheet/blue,
					/obj/item/bedsheet/green,
					/obj/item/bedsheet/orange,
					/obj/item/bedsheet/purple,
					/obj/item/bedsheet/red,
					/obj/item/bedsheet/yellow,
					/obj/item/bedsheet/brown,
					/obj/item/bedsheet/black,
					/obj/item/bedsheet/rainbow)
	crate_name = "colored bedsheet crate"

/datum/supply_pack/misc/lamplight
	name = "Lamp Light Crate"
	desc = "Dealing with brownouts? Lights out across the station? Brighten things up with a pack of four lamps and flashlights."
	cost = CARGO_CRATE_VALUE * 1.75
	contains = list(/obj/item/flashlight/lamp,
					/obj/item/flashlight/lamp,
					/obj/item/flashlight/lamp/green,
                    /obj/item/flashlight/lamp/green,
                    /obj/item/flashlight,
                    /obj/item/flashlight,
                    /obj/item/flashlight,
                    /obj/item/flashlight,)
	crate_name = "lamp light crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Food Stuff //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/organic/combomeal
	name = "Burger Combo Crate"
	desc = "We value our customers at the Greasy Griddle, so much so that we're willing to deliver -just for you.- Contains two combo meals, consisting of a Burger, Fries, and pack of chicken nuggets!"
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/food/burger/cheese,
                    /obj/item/food/burger/cheese,
					/obj/item/food/fries,
                    /obj/item/food/fries,
                    /obj/item/storage/fancy/nugget_box,
                    /obj/item/storage/fancy/nugget_box)
	crate_name = "burger n nuggs combo meal"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/organic/fiestatortilla
	name = "Fiesta Crate"
	desc = "Spice up the kitchen with this fiesta themed food order! Contains 8 tortilla based food items and some hot-sauce."
	cost = CARGO_CRATE_VALUE * 4.5
	contains = list(/obj/item/food/taco,
					/obj/item/food/taco,
					/obj/item/food/taco/plain,
					/obj/item/food/taco/plain,
					/obj/item/food/enchiladas,
					/obj/item/food/enchiladas,
					/obj/item/food/carneburrito,
					/obj/item/food/cheesyburrito,
					/obj/item/reagent_containers/glass/bottle/capsaicin)
	crate_name = "fiesta crate"

/datum/supply_pack/organic/fakemeat
	name = "Biomass Meat Crate"
	desc = "Keep the carnivores on station content with this freezer filled with cruelty-free and chemically compounded meat! Contains 9 slabs of meat product, and 3 slabs of *carp*."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/meat/slab/meatproduct,
                    /obj/item/food/fishmeat/carp/imitation,
                    /obj/item/food/fishmeat/carp/imitation,
                    /obj/item/food/fishmeat/carp/imitation)
	crate_name = "meaty crate"
	crate_type = /obj/structure/closet/crate/freezer

/datum/supply_pack/organic/mixedboxes
	name = "Mixed Ingredient Boxes"
	desc = "Get overwhelmed with inspiration by ordering these boxes of surprise ingredients! Get four boxes filled with an assortment of products!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/box/ingredients/wildcard,
					/obj/item/storage/box/ingredients/wildcard,
					/obj/item/storage/box/ingredients/wildcard,
					/obj/item/storage/box/ingredients/wildcard)
	crate_name = "wildcard food crate"
	crate_type = /obj/structure/closet/crate/freezer

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Pack Type ///////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/service/buildabar
	name = "Build a Bar Crate"
	desc = "Looking to set up your own little safe haven? Get a jump-start on it with this handy kit. Contains circuitboards for bar equipment, some parts, and some basic bartending supplies. (Glass not included)"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/storage/box/drinkingglasses,
					/obj/item/storage/box/drinkingglasses,
                    /obj/item/storage/part_replacer/cargo,
					/obj/item/stack/sheet/iron/ten,
					/obj/item/stack/sheet/iron/five,
                    /obj/item/stock_parts/cell/high,
                    /obj/item/stock_parts/cell/high,
					/obj/item/stack/cable_coil,
					/obj/item/book/manual/wiki/barman_recipes,
					/obj/item/reagent_containers/food/drinks/shaker,
					/obj/item/circuitboard/machine/chem_dispenser/drinks/beer,
					/obj/item/circuitboard/machine/chem_dispenser/drinks,
					/obj/item/circuitboard/machine/dish_drive)
	crate_name = "build a bar crate"

/datum/supply_pack/service/janitor/janpimp
	name = "Custodial Cruiser"
	desc = "Clown steal your ride? Assistant lock it in the dorms? Order a new one and get back to cleaning in style!"
	cost = CARGO_CRATE_VALUE * 4
	access = ACCESS_JANITOR
	contains = list(/obj/vehicle/ridden/janicart,
					/obj/item/key/janitor)
	crate_name = "janitor ride crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/janitor/janpimpkey
	name = "Custodial Cruiser Keys"
	desc = "Replacement Keys for the Custodial Cruiser."
	cost = CARGO_CRATE_VALUE * 1.5
	access = ACCESS_JANITOR
	contains = list(/obj/item/key/janitor)
	crate_name = "key crate"
	crate_type = /obj/structure/closet/crate/wooden

/datum/supply_pack/service/janitor/janpremium
	name = "Janitorial Supplies (Premium)"
	desc = "For when the mess is too big for a mop to handle. Contains, several cleaning grenades, some spare bottles of ammonia, two bars of soap, and an MCE (or Massive Cleaning Explosive)."
	cost = CARGO_CRATE_VALUE * 6
	contains = list(/obj/item/soap/nanotrasen,
					/obj/item/soap/nanotrasen,
					/obj/item/grenade/clusterbuster/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/grenade/chem_grenade/cleaner,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia,
					/obj/item/reagent_containers/glass/bottle/ammonia)
	crate_name = "premium janitorial crate"

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Materials & Sheets //////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/materials/rawlumber
	name = "20 Towercap Logs"
	desc = "Set up a cookout or a classy beachside bonfire with these terrific towercaps!"
	cost = CARGO_CRATE_VALUE * 3.5
	contains = list(/obj/item/grown/log)
	crate_name = "lumber crate"

/datum/supply_pack/materials/rawlumber/generate()
	. = ..()
	for(var/i in 1 to 19)
		new /obj/item/grown/log(.)
