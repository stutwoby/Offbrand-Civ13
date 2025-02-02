/obj/map_metadata/drug_bust
	ID = MAP_DRUG_BUST
	title = "The Rednikov Drug Bust"
	lobby_icon = "icons/lobby/bank_robbery.png"
	no_winner ="The drug bust is still underway."
	caribbean_blocking_area_types = list(
		/area/caribbean/no_mans_land/invisible_wall,
		/area/caribbean/no_mans_land/invisible_wall/inside)
	respawn_delay = 0

	faction_organization = list(
		CIVILIAN,
		RUSSIAN,)

	age = "1986"
	ordinal_age = 7
	faction_distribution_coeffs = list(CIVILIAN = 0.7, RUSSIAN = 0.3)
	battle_name = "Rednikov Drug Bust"
	mission_start_message = "<font size=4>The Russians have <b>5 minutes</b> to prepare SWAT raid the building!<br>The police will win if they <b>confiscate 20 stacks of cocaine!</b>. The Russians will win if they manage to hold off the police for <b>20 minutes!</b></font>"
	faction1 = CIVILIAN
	faction2 = RUSSIAN
	grace_wall_timer = 3000
	gamemode = "Drug Bust"
	songs = list(
		"D.A.V.E. The Drummer - Amphetamine or Cocaine:1" = "sound/music/amphetamine_cocaine.ogg",)
		
obj/map_metadata/drug_bust/job_enabled_specialcheck(var/datum/job/J)
	..()
	if (J.is_heist == TRUE)
		. = TRUE
		if (J.title == "Police Officer")
			J.max_positions = 4
			J.total_positions = 4
		if (J.title == "SWAT Officer")
			J.whitelisted = FALSE
			J.max_positions = 30
			J.total_positions = 30
		if (J.title == "Bank Robber")
			. = FALSE
	else
		. = FALSE

/obj/map_metadata/drug_bust/faction1_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 2400 || admin_ended_all_grace_periods)

/obj/map_metadata/drug_bust/faction2_can_cross_blocks()
	return (processes.ticker.playtime_elapsed >= 2400 || admin_ended_all_grace_periods)
	
/obj/map_metadata/drug_bust/cross_message(faction)
	return "<font size = 4>SWAT has started the raid!</font>"

/obj/map_metadata/drug_bust/reverse_cross_message(faction)
	return ""

/obj/map_metadata/drug_bust/update_win_condition()
	if (win_condition_spam_check)
		return FALSE
	for(var/obj/structure/money_bag/C in world)
		if (C.storedvalue >= 10000) // total value stored = 12400+. So roughly 3/4th
			var/message = "The Police have sucessfully stolen over 10.000 dollars! The robbery was successful!"
			world << "<font size = 4><span class = 'notice'>[message]</span></font>"
			show_global_battle_report(null)
			win_condition_spam_check = TRUE
			ticker.finished = TRUE
			return TRUE
	if (processes.ticker.playtime_elapsed >= 20000)
		ticker.finished = TRUE
		var/message = "The Police have suffered enough casualties and have retreated! The Russains win!"
		world << "<font size = 4><span class = 'notice'>[message]</span></font>"
		show_global_battle_report(null)
		win_condition_spam_check = TRUE
		return TRUE

/obj/map_metadata/drug_bust/check_caribbean_block(var/mob/living/human/H, var/turf/T)
	if (!istype(H) || !istype(T))
		return FALSE
	var/area/A = get_area(T)
	if (istype(A, /area/caribbean/no_mans_land/invisible_wall))
		if (istype(A, /area/caribbean/no_mans_land/invisible_wall/one))
			if (H.original_job.is_outlaw == TRUE && !H.original_job.is_law == TRUE)
				return TRUE
		else if (istype(A, /area/caribbean/no_mans_land/invisible_wall/two))
			if (H.original_job.is_law == TRUE && !H.original_job.is_outlaw == TRUE)
				return TRUE
		else
			return !faction1_can_cross_blocks()
	return FALSE



////////////////////////////////Jobs and stuff//////////////////////////////////////////////////

/datum/job/civilian/policeofficer/equip(var/mob/living/human/H)
	H.equip_to_slot_or_del(new /obj/item/weapon/paper/police/searchwarrant/drug(H), slot_r_hand)

/obj/item/weapon/paper/police/searchwarrant/drug
	icon_state = "police_warrant"
	base_icon = "police_warrant"
	name = "Search Warrant"
	New()
		..()
		arn = rand(100,999)
		icon_state = "police_warrant"
		spawn(10)
			info = "<center>DEPARTMENT OF JUSTICE<hr><large><b>Search Warrant No. [arn]</b></large><hr><br>Law Enforcement Agencies are hereby authorized and directed to search all and every property owned by <b>Vyacheslav 'Tatarin' Grigoriev</b>. They will disregard any claims of immunity or privilege by the Suspect or agents acting on the Suspect's behalf.<br><br><small><center><i>Form Model 13-C1</i></center></small><hr>"

/obj/item/weapon/reagent_containers/cocaineblock
	icon = 'icons/obj/drugs.dmi'
	name = "block of cocaine"
	desc = "A block of very pure cocaine."
	icon_state = "single_brick"
	pixel_y = 6
	var/vol = 500
	value = 100
	New()
		..()
		reagents.add_reagent("cocaine", 500)
		desc = "A block of very pure cocaine. Contains [vol] grams."

/obj/item/weapon/reagent_containers/cocaineblock/attackby(var/obj/item/I, var/mob/user)
	if (istype(I, /obj/item/weapon/material/kitchen/utensil/knife))
		if (reagents.get_reagent_amount("cocaine") >= 10)
			user << "You cut a line from the [src]."
			reagents.remove_reagent("cocaine",5)
			var/obj/item/weapon/reagent_containers/pill/cocaine_line/coca = new/obj/item/weapon/reagent_containers/pill/cocaine_line(user)
			user.put_in_hands(coca)
			vol = reagents.get_reagent_amount("cocaine")/25
			desc = "A block of very pure cocaine. Contains [vol] grams."
			if (reagents.get_reagent_amount("cocaine") >= 500)
				name = "block of cocaine"
				desc = "A block of very pure cocaine."
				icon_state = "single_brick"
			else
				name = "torn block of cocaine"
				desc = "A block of very pure cocaine that's been cut or torn from the outside."
				icon_state = "single_brick_torn"
	else
		user << "You need a knife to cut the [src]."

/obj/item/weapon/reagent_containers/cocaineblock/attackby(var/obj/item/I, var/mob/user)
	if (istype(I, /obj/item/weapon/reagent_containers/pill/cocaine_line))
		user << "You put \the [I] into \the [src]."
		reagents.add_reagent("cocaine",I.reagents.get_reagent_amount("cocaine"))
		vol = reagents.get_reagent_amount("cocaine")/25
		desc = "A pile of very pure cocaine. Contains [vol] grams."
		if (reagents.get_reagent_amount("cocaine") >= 500)
			name = "block of cocaine"
			desc = "A block of very pure cocaine."
			icon_state = "single_brick"
		else
			name = "torn block of cocaine"
			desc = "A block of very pure cocaine that's been cut or torn from the outside."
			icon_state = "single_brick_torn"
		qdel(I)
	else
		..()

/obj/item/weapon/reagent_containers/cocaineblock/torn
	icon_state = "single_brick_torn"
	vol = 400
	value = 100
	New()
		..()
		reagents.add_reagent("cocaine", 400)
		desc = "A block of very pure cocaine. Contains [vol] grams."

/obj/item/weapon/reagent_containers/cocaineblocks
	name = "blocks of cocaine"
	desc = "2 block of very pure cocaine, packed together for shipping."
	icon = 'icons/obj/drugs.dmi'
	icon_state = "brick_stack2"
	pixel_y = 6
	value = 200

/obj/item/weapon/reagent_containers/cocaineblocks/three
	name = "blocks of cocaine"
	desc = "3 block of very pure cocaine, packed together for shipping."
	icon = 'icons/obj/drugs.dmi'
	icon_state = "brick_stack3"
	pixel_y = 6
	value = 300

/obj/item/weapon/reagent_containers/cocaineblocks/four
	name = "blocks of cocaine"
	desc = "4 block of very pure cocaine, packed together for shipping."
	icon = 'icons/obj/drugs.dmi'
	icon_state = "brick_stack4"
	pixel_y = 6
	value = 400

/obj/item/weapon/reagent_containers/cocaineblocks/five
	name = "blocks of cocaine"
	desc = "5 block of very pure cocaine, packed together for shipping."
	icon = 'icons/obj/drugs.dmi'
	icon_state = "brick_stack5"
	pixel_y = 6
	value = 500

/obj/item/weapon/reagent_containers/cocaineblocks/six
	name = "blocks of cocaine"
	desc = "6 block of very pure cocaine, packed together for shipping."
	icon = 'icons/obj/drugs.dmi'
	icon_state = "brick_stack6"
	pixel_y = 6
	value = 600

/obj/item/weapon/reagent_containers/cocaineblocks/attack_hand(mob/living/user)
	if (src == user.l_hand || src == user.r_hand)
		user << "You split a from the [src] apart."
		var/obj/item/weapon/reagent_containers/cocaineblock/block = new/obj/item/weapon/reagent_containers/cocaineblock(user)
		user.put_in_hands(block)
	else
		..()