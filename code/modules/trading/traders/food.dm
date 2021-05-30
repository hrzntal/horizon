/datum/trader/pizzaria
	name = "Pizza Shop Employee"
	possible_origins = list("Papa Joe's", "Pizza Ship", "Dominator Pizza", "Little Kaezars", "Pizza Planet", "Cheese Louise", "Little Taste o' Neo-Italy", "Pizza Gestapo")
	trade_flags = TRADER_MONEY|TRADER_SELLS_GOODS
	speech = list("hail"    = "Hello! Welcome to ORIGIN, may I take your order?",
				"hail_deny"         = "Beeeep... I'm sorry, your connection has been severed.",

				"trade_complete"    = "Thank you for choosing ORIGIN!",
				"trade_no_goods"    = "I'm sorry but we only take cash.",
				"trade_not_enough"  = "Uhh... that's not enough money for pizza.",
				"how_much"          = "That pizza will cost you VALUE credits.",

				"compliment_deny"   = "That's a bit forward, don't you think?",
				"compliment_accept" = "Thanks, sir! You're very nice!",
				"insult_good"       = "Please stop that, sir.",
				"insult_bad"        = "Sir, just because I'm contractually obligated to keep you on the line for a minute doesn't mean I have to take this.")
	possible_sold_goods = list(/datum/sold_goods/pizzabox = 100,
								/datum/sold_goods/pizzabox/two = 100,
								/datum/sold_goods/pizzabox/three = 100,
								/datum/sold_goods/pizzabox/four = 100)
	target_sold_goods_amount = 4

/datum/trader/chinese
	name = "Chinese Restaurant"
	possible_origins = list("Captain Panda Bistro", "888 Shanghai Kitchen", "Mr. Lee's Greater Hong Kong", "The House of the Venerable and Inscrutable Colonel", "Lucky Dragon")
	trade_flags = TRADER_MONEY|TRADER_SELLS_GOODS
	speech = list("hail"     = "There are two things constant in life, death and Chinese food. How may I help you?",
				"hail_deny"          = "We do not take orders from rude customers.",

				"trade_complete"     = "Thank you, sir, for your patronage.",
				"trade_no_goods"     = "I only accept money transfers.",
				"trade_not_enough"   = "No, I am sorry, that is not possible. I need to make a living.",
				"how_much"           = "I give you ITEM, for VALUE CURRENCY. No more, no less.",

				"compliment_deny"    = "That was an odd thing to say. You are very odd.",
				"compliment_accept"  = "Good philosophy, see good in bad, I like.",
				"insult_good"        = "As a man said long ago, \"When anger rises, think of the consequences.\" Think on that.",
				"insult_bad"         = "I do not need to take this from you.")
	possible_sold_goods = list(/datum/sold_goods/meatkebab = 100,
								/datum/sold_goods/monkeysoup = 100,
								/datum/sold_goods/ricepudding = 100,
								/datum/sold_goods/cupramen = 100)
	target_sold_goods_amount = 5
	var/list/fortunes = list("Today it's up to you to create the peacefulness you long for.",
							"If you refuse to accept anything but the best, you very often get it.",
							"A smile is your passport into the hearts of others.",
							"Hard work pays off in the future, laziness pays off now.",
							"Change can hurt, but it leads a path to something better.",
							"Hidden in a valley beside an open stream- This will be the type of place where you will find your dream.",
							"Never give up. You're not a failure if you don't give up.",
							"Love can last a lifetime, if you want it to.",
							"The love of your life is stepping into your planet this summer.",
							"Your ability for accomplishment will follow with success.",
							"Please help me, I'm trapped in a fortune cookie factory!")

/datum/trader/chinese/AfterTrade(mob/user, obj/machinery/computer/trade_console/console)
	var/turf/spawn_turf = get_turf(console.linked_pad)
	new /obj/item/food/fortunecookie(spawn_turf)
	var/obj/item/paper/fortune = new(spawn_turf)
	fortune.name = "Fortune"
	fortune.info = pick(fortunes)
