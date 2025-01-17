/datum/job
	//The name of the job
	var/title = "NOPE"

	//Job access. The use of minimal_access or access is determined by a config setting: config.jobs_have_minimal_access
	var/list/minimal_access = list()		//Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()				//Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)

	//Determines who can demote this position
	var/department_head = list()

	//Tells the given channels that the given mob is the new department head. See communications.dm for valid channels.
	var/list/head_announce = null

	//Bitflags for the job
	var/flag = 0
	var/department_flag = 0

	//Players will be allowed to spawn in as jobs that are set to "Station"
	var/faction = "None"

	//Special faction system
	var/social_faction = null

	//How many players can be this job
	var/total_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	//Description, short text about the job
	var/description = ""

	//Against the faction rules, for imporant things that you SHOULDNT do.
	var/forbids = ""

	//For things that faction Enforces.
	var/enforces = ""

	//Sellection screen color
	var/selection_color = "#ffffff"


	//If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	//If you have the use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 6 // Sets minimum default account age to six days to prevent angry people from account-spamming.

	//Role whitelisting, if USE_ROLE_WHITELIST is enabled in config.txt, these values will be considered for job selection.
	var/whitelisted = 0 // Whether this job is whitelisted or not.
	var/whitelist_group = "" // Which term is needed in the whitelist file for this job to be available

	var/outfit = null

	var/exp_requirements = 0

	var/exp_type = ""
	var/exp_type_department = ""

	//The amount of good boy points playing this role will earn you towards a higher chance to roll antagonist next round
	//can be overriden by antag_rep.txt config
	var/antag_rep = 10

	var/display_order = JOB_DISPLAY_ORDER_DEFAULT

	//List of outfit datums that can be selected by this job - after spawning - as additional equipment.
	//This is ontop of the base job outfit
	var/list/datum/outfit/loadout_options = list()

//Only override this proc
//H is usually a human unless an /equip override transformed it
/datum/job/proc/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	//do actions on H but send messages to M as the key may not have been transferred_yet
	if(M.ckey)
		var/list/custom_items = load_custom_items_from_db(M.ckey)
		if (islist(custom_items))
			load_custom_items_to_mob_from_db(H, custom_items)
		if (!islist(custom_items))
			to_chat(M, SPAN_NOTICE("Non list returned from load_custom_items_from_db"))
	if(!M.ckey)
		to_chat(M, SPAN_NOTICE("You had no ckey while trying to load your custom items, please tell an admin."))


/datum/job/proc/announce(mob/living/carbon/human/H)
	if(head_announce)
		announce_head(H, head_announce)

/datum/job/proc/override_latejoin_spawn(mob/living/carbon/human/H)		//Return TRUE to force latejoining to not automatically place the person in latejoin shuttle/whatever.
	return FALSE

//Used for a special check of whether to allow a client to latejoin as this job.
/datum/job/proc/special_check_latejoin(client/C)
	return TRUE

/datum/job/proc/GetAntagRep()
	. = CONFIG_GET(keyed_number_list/antag_rep)[lowertext(title)]
	if(. == null)
		return antag_rep

//Don't override this unless the job transforms into a non-human (Silicons do this for example)
/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE)
	if(!H)
		return FALSE

	if(CONFIG_GET(flag/enforce_human_authority) && (title in GLOB.command_positions))
		if(H.dna.species.id != "human")
			H.set_species(/datum/species/human)
			H.apply_pref_name("human", H.client)
		purrbation_remove(H, silent=TRUE)
	// F13 EDIT: GHOULS CANNOT BE LEGION
	if((title in GLOB.legion_positions) || (title in GLOB.vault_positions) || (title in GLOB.brotherhood_positions))
		if(H.dna.species.id == "ghoul")
			H.set_species(/datum/species/human)
			H.apply_pref_name("human", H.client)

	//Equip the rest of the gear
	H.dna.species.before_equip_job(src, H, visualsOnly)

	if(outfit)
		H.equipOutfit(outfit, visualsOnly)

	//If we have any additional loadouts, notify the player
	if (!visualsOnly && loadout_options.len)
		enable_loadout_select(H)

	H.dna.species.after_equip_job(src, H, visualsOnly)

	if(!visualsOnly && announce)
		announce(H)

	//TGCLAW Change: Adds faction according to the job datum and is sanity checked because of nightmares from before -ma44
	if(faction)
		if(islist(faction))
			H.faction |= faction
		else
			H.faction += faction

	if(social_faction)
		H.social_faction = social_faction

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return src.minimal_access.Copy()

	. = list()

	if(CONFIG_GET(flag/jobs_have_minimal_access))
		. = src.minimal_access.Copy()
	else
		. = src.access.Copy()

	if(CONFIG_GET(flag/everyone_has_maint_access)) //Config has global maint access set
		. |= list(ACCESS_MAINT_TUNNELS)

/datum/job/proc/announce_head(var/mob/living/carbon/human/H, var/channels) //tells the given channel that the given mob is the new department head. See communications.dm for valid channels.
	if(H && GLOB.announcement_systems.len)
		//timer because these should come after the captain announcement
		SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/addtimer, CALLBACK(pick(GLOB.announcement_systems), /obj/machinery/announcement_system/proc/announce, "NEWHEAD", H.real_name, H.job, channels), 1))

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return TRUE	//Available in 0 days = available right now = player is old enough to play.
	return FALSE


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/config_check()
	return TRUE

/datum/job/proc/map_check()
	return TRUE

/datum/outfit/job
	name = "Standard Gear"

	var/jobtype = null

	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
//	ears = /obj/item/radio/headset//No, thanks.
	belt = /obj/item/pda
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black

	var/backpack = /obj/item/storage/backpack
	var/satchel  = /obj/item/storage/backpack/satchel
	var/duffelbag = /obj/item/storage/backpack/duffelbag
	var/box = /obj/item/storage/box/survival

	var/pda_slot = SLOT_BELT

	var/chemwhiz = FALSE //F13 Chemwhiz, for chemistry machines
	var/pa_wear = FALSE //F13 pa_wear, ability to wear PA
	var/gunsmith_one = FALSE //F13 gunsmith perk, ability to craft Tier 2 guns and ammo
	var/gunsmith_two = FALSE //F13 gunsmith perk, ability to craft Tier 3 guns and ammo
	var/gunsmith_three = FALSE //F13 gunsmith perk, ability to craft Tier 4 guns and ammo
	var/gunsmith_four = FALSE //F13 gunsmith perk, ability to craft Tier 5 guns and ammo
	var/vb_pilot = FALSE //F13 vb_pilot. Allows someone to fly the Vertibird.

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	switch(H.backbag)
		if(GBACKPACK)
			back = /obj/item/storage/backpack //Grey backpack
		if(GSATCHEL)
			back = /obj/item/storage/backpack/satchel //Grey satchel
		if(GDUFFELBAG)
			back = /obj/item/storage/backpack/duffelbag //Grey Duffel bag
		if(LSATCHEL)
			back = /obj/item/storage/backpack/satchel/leather //Leather Satchel
		if(DSATCHEL)
			back = satchel //Department satchel
		if(DDUFFELBAG)
			back = duffelbag //Department duffel bag
		else
			back = backpack //Department backpack

	if(box)
		if(!backpack_contents)
			backpack_contents = list()
		backpack_contents.Insert(1, box) // Box always takes a first slot in backpack
		backpack_contents[box] = 1

	if(chemwhiz == TRUE)
		H.add_trait(TRAIT_CHEMWHIZ)

	if(pa_wear == TRUE)
		H.add_trait(TRAIT_PA_WEAR)

	if(gunsmith_one == TRUE)
		H.add_trait(TRAIT_GUNSMITH_ONE)

	if(gunsmith_two == TRUE)
		H.add_trait(TRAIT_GUNSMITH_TWO)

	if(gunsmith_three == TRUE)
		H.add_trait(TRAIT_GUNSMITH_THREE)

	if(gunsmith_four == TRUE)
		H.add_trait(TRAIT_GUNSMITH_FOUR)

	if(vb_pilot == TRUE)
		H.add_trait(TRAIT_PILOT)

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/datum/job/J = SSjob.GetJobType(jobtype)
	if(!J)
		J = SSjob.GetJob(H.job)

	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		if(J)
			C.access = J.get_access()
		shuffle_inplace(C.access) // Shuffle access list to make NTNet passkeys less predictable
		C.registered_name = H.real_name
		if(J)
			C.assignment = J.title
		C.update_label()
		H.sec_hud_set_ID()

	var/obj/item/pda/PDA = H.get_item_by_slot(pda_slot)
	if(istype(PDA))
		PDA.owner = H.real_name
		PDA.ownjob = J.title
		PDA.update_label()

	if(chemwhiz == TRUE)
		H.add_trait(TRAIT_CHEMWHIZ)

	if(pa_wear == TRUE)
		H.add_trait(TRAIT_PA_WEAR)

	if(vb_pilot == TRUE)
		H.add_trait(TRAIT_PILOT)

/datum/outfit/job/get_chameleon_disguise_info()
	var/list/types = ..()
	types -= /obj/item/storage/backpack //otherwise this will override the actual backpacks
	types += backpack
	types += satchel
	types += duffelbag
	return types
