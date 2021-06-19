//////////////////////////////////////////////////////////////////////////////
//////////////////////// Emergency Race Stuff ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/airsuppliesnitrogen
	name = "Emergency Air Supplies (Nitrogen)"
	desc = "A vox breathing mask and nitrogen tank."
	cost = PAYCHECK_MEDIUM
	contains = list(/obj/item/tank/internals/nitrogen/belt,
                    /obj/item/clothing/mask/breath/vox)

/datum/supply_pack/goody/airsuppliesoxygen
	name = "Emergency Air Supplies (Oxygen)"
	desc = "A breathing mask and emergency oxygen tank."
	cost = PAYCHECK_MEDIUM
	contains = list(/obj/item/tank/internals/emergency_oxygen,
                    /obj/item/clothing/mask/breath)

/datum/supply_pack/goody/airsuppliesplasma
	name = "Emergency Air Supplies (Plasma)"
	desc = "A breathing mask and plasmaman plasma tank."
	cost = PAYCHECK_MEDIUM
	contains = list(/obj/item/tank/internals/plasmaman/belt,
                    /obj/item/clothing/mask/breath)

//////////////////////////////////////////////////////////////////////////////
///////////////////////////// Misc Stuff /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/crayons
	name = "Box of Crayons"
	desc = "Colorful!"
	cost = PAYCHECK_MEDIUM * 2
	contains = list(/obj/item/storage/crayons)

/datum/supply_pack/goody/candles
	name = "Candles"
	desc = "Low-tech lighting, perfect for a romantic dinner!"
	cost = PAYCHECK_MEDIUM * 2
	contains = list(/obj/item/storage/fancy/candle_box,
					/obj/item/storage/box/matches)

/datum/supply_pack/goody/diamondring
	name = "Diamond Ring"
	desc = "Show them your love is like a diamond: unbreakable and everlasting. No refunds."
	cost = PAYCHECK_MEDIUM * 50
	contains = list(/obj/item/storage/fancy/ringbox/diamond)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Carpet Packs ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/carpet
	name = "Classic Carpet Pack"
	desc = "Contains a single 50 pack of `Classic` carpet. Reddish-brown in appearance."
	cost = PAYCHECK_MEDIUM * 1.5
	contains = list(/obj/item/stack/tile/carpet/fifty)

/datum/supply_pack/goody/carpet/blue
    name = "Blue Carpet Pack"
    desc = "Contains three different hues of carpet. Blue, Royal Blue, and Cyan. Comes in stacks of 50."
    cost = PAYCHECK_MEDIUM * 3
    contains = list(/obj/item/stack/tile/carpet/blue/fifty,
                    /obj/item/stack/tile/carpet/royalblue/fifty,
                    /obj/item/stack/tile/carpet/cyan/fifty)

/datum/supply_pack/goody/carpet/dark
	name = "Dark Carpet Pack"
	desc = "Contains three different hues of carpet. Black, Royal Black, and Purple. Comes in stacks of 50."
	cost = PAYCHECK_MEDIUM * 3
	contains = list(/obj/item/stack/tile/carpet/black/fifty,
                    /obj/item/stack/tile/carpet/royalblack/fifty,
                    /obj/item/stack/tile/carpet/purple/fifty)

/datum/supply_pack/goody/carpet/light
	name = "Light Carpet Pack"
	cost = PAYCHECK_MEDIUM * 3
	desc = "Contains three different hues of carpet. Red, Green, and Orange. Comes in stacks of 50."
	contains = list(/obj/item/stack/tile/carpet/red/fifty,
                    /obj/item/stack/tile/carpet/orange/fifty,
                    /obj/item/stack/tile/carpet/green/fifty)
