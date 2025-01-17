//nutrition
/datum/mood_event/nutrition/fat
	description = "<span class='warning'><B>I'm so fat...</B></span>\n" //muh fatshaming
	mood_change = -4

/datum/mood_event/nutrition/wellfed
	description = "<span class='nicegreen'>My belly feels round and full.</span>\n"
	mood_change = 6

/datum/mood_event/nutrition/fed
	description = "<span class='nicegreen'>I have recently had some food.</span>\n"
	mood_change = 3

/datum/mood_event/nutrition/hungry
	description = "<span class='warning'>I'm getting a bit hungry.</span>\n"
	mood_change = -8

/datum/mood_event/nutrition/starving
	description = "<span class='boldwarning'>I'm starving!</span>\n"
	mood_change = -15

//water
/datum/mood_event/nutrition/slaked
	description = "<span class='nicegreen'>I'm topped up!</span>\n"
	mood_change = 4

/datum/mood_event/nutrition/thirsty
	description = "<span class='warning'>I'm slightly thirsty.</span>\n"
	mood_change = 6

/datum/mood_event/nutrition/thirsty2
	description = "<span class='warning'>I'm very thirsty!</span>\n"
	mood_change = -4

/datum/mood_event/nutrition/thirsty3
	description = "<span class='boldwarning'>I'm going to die of thirst!</span>\n"
	mood_change = -6

/datum/mood_event/nutrition/thirsty4
	description = "<span class='boldwarning'>This is how I die...</span>\n"
	mood_change = -12

/datum/mood_event/nutrition/pissself
	description = "<span class='boldwarning'>I just pissed myself...</span>\n"
	mood_change = -12
	timeout = 4000

/datum/mood_event/nutrition/piss
	description = "<span class='warning'>I really need to take a piss!</span>\n"
	mood_change = -4

/datum/mood_event/nutrition/shitself
	description = "<span class='boldwarning'>I just shat myself...</span>\n"
	mood_change = -12
	timeout = 4000

/datum/mood_event/nutrition/shit
	description = "<span class='warning'>I really need to take a shit!</span>\n"
	mood_change = -4

//Disgust
/datum/mood_event/disgust/gross
	description = "<span class='warning'>I saw something gross.</span>\n"
	mood_change = -2

/datum/mood_event/disgust/verygross
	description = "<span class='warning'>I think I'm going to puke...</span>\n"
	mood_change = -5

/datum/mood_event/disgust/disgusted
	description = "<span class='boldwarning'>Oh god that's disgusting...</span>\n"
	mood_change = -8

//Generic needs events
/datum/mood_event/favorite_food
	description = "<span class='nicegreen'>I really enjoyed eating that.</span>\n"
	mood_change = 3
	timeout = 2400

/datum/mood_event/gross_food
	description = "<span class='nicegreen'>I really didn't like that food.</span>\n"
	mood_change = -2
	timeout = 2400

/datum/mood_event/disgusting_food
	description = "<span class='nicegreen'>That food was disgusting!</span>\n"
	mood_change = -4
	timeout = 2400

/datum/mood_event/nice_shower
	description = "<span class='nicegreen'>I have recently had a nice shower.</span>\n"
	mood_change = 2
	timeout = 1800
