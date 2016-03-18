/datum/projectile/pickpocket
	name = "strange claw thing you shouldn't be able to see"
	icon = null
	icon_state = null
//How much of a punch this has, tends to be seconds/damage before any resist
	power = 10
//How much ammo this costs
	cost = 30
//How fast the power goes away
	dissipation_rate = 1
//How many tiles till it starts to lose power
	dissipation_delay = 10
//Kill/Stun ratio
	ks_ratio = 0.0
//name of the projectile setting, used when you change a guns setting
	sname = "pickpocket"
//file location for the sound you want it to play
	shot_sound = null
//How many projectiles should be fired, each will cost the full cost
	shot_number = 1
//What is our damage type
	damage_type = 0
	//With what % do we hit mobs laying down
	hit_ground_chance = 10
	//Can we pass windows
	window_pass = 0
	silentshot = 1

	var/obj/item/gun/energy/pickpocket/linkedGun = null
	var/targetZone = null

/datum/projectile/pickpocket/steal
	sname = "steal"
	on_hit(atom/hit)
		if(ishuman(hit) && !linkedGun.heldItem) // Stupidity check in case they insert an item into the gun while projectile is in flight
			var/mob/living/carbon/human/M = hit
			var/obj/item/stolenItem = null
			switch (targetZone)
				if ("chest")
					if (M.wear_id) stolenItem = M.wear_id
				if ("head")
					if (M.wear_mask) stolenItem = M.wear_mask
				if ("r_arm")
					stolenItem = M.r_hand ? M.r_hand : M.l_hand ? M.l_hand : null
				if ("l_arm")
					stolenItem = M.l_hand ? M.l_hand : M.r_hand ? M.r_hand : null
				if ("r_leg")
					stolenItem = M.r_store ? M.r_store : M.l_store ? M.l_store : null
				if ("l_leg")
					stolenItem = M.l_store ? M.l_store : M.r_store ? M.r_store : null
			if (stolenItem) // Found a thing to steal, hurrah
				logTheThing("combat", linkedGun, null, " successfully steals \a [stolenItem]")
				M.u_equip(stolenItem)
				linkedGun.heldItem = stolenItem
				stolenItem.set_loc(linkedGun)


/datum/projectile/pickpocket/plant
	sname = "plant"
	var/strikeFlavor = list("How strange.", "Huh.", "That's weird!", "Don't see that every day.", "", "Gosh!", "What will they think up next?")
	on_hit(atom/hit)
		if (linkedGun.heldItem) // Stupidity check for stripping item out of gun while projectile was in flight
			if(ishuman(hit))
				var/mob/living/carbon/human/M = hit
				logTheThing("combat", linkedGun, M, " attempts to plant [linkedGun.heldItem] on %target%")
				switch (targetZone)
					if ("chest")
						if (M.wear_id || !M.equip_if_possible(linkedGun.heldItem, M.slot_wear_id)) // If already wearing ID or attempt to equip failed
							linkedGun.heldItem.set_loc(get_turf(M))
							linkedGun.heldItem.layer = initial(linkedGun.heldItem.layer)
							boutput(M, "\A [linkedGun.heldItem] suddenly thwacks into your chest! [pick(strikeFlavor)]")
					if ("head")
						if (M.wear_mask || !M.equip_if_possible(linkedGun.heldItem, M.slot_wear_mask)) // Masks have more inherent grif potential than glasses/hat
							linkedGun.heldItem.set_loc(get_turf(M))
							linkedGun.heldItem.layer = initial(linkedGun.heldItem.layer)
							boutput(M, "\A [linkedGun.heldItem] suddenly thwacks into your head! [pick(strikeFlavor)]")
					if ("r_arm", "l_arm") // TODO: Maybe switch arm-targetting to try to put things into backpack. Less sensical but more useful
						if (!M.put_in_hand_or_drop(linkedGun.heldItem))
							boutput(M, "\A [linkedGun.heldItem] brushes insistently at your hands! [pick(strikeFlavor)]")
					if ("r_leg")
						if (!M.r_store && M.equip_if_possible(linkedGun.heldItem, M.slot_r_store))
							return
						if (!M.l_store && M.equip_if_possible(linkedGun.heldItem, M.slot_l_store))
							return
						// Couldn't go into a pocket, dump on ground
						linkedGun.heldItem.set_loc(get_turf(M))
						linkedGun.heldItem.layer = initial(linkedGun.heldItem.layer)
						boutput(M, "\A [linkedGun.heldItem] tries to cram itself into your pockets! [pick(strikeFlavor)]")
					if ("l_leg")
						if (!M.l_store && M.equip_if_possible(linkedGun.heldItem, M.slot_l_store))
							return
						if (!M.r_store && M.equip_if_possible(linkedGun.heldItem, M.slot_r_store))
							return
						// Couldn't go into a pocket, dump on ground
						linkedGun.heldItem.set_loc(get_turf(M))
						linkedGun.heldItem.layer = initial(linkedGun.heldItem.layer)
						boutput(M, "\A [linkedGun.heldItem] tries to cram itself into your pockets! [pick(strikeFlavor)]")
			else
				logTheThing("combat", linkedGun, null, " plants [linkedGun.heldItem] at [showCoords(hit.x, hit.y, hit.z)]")
				linkedGun.heldItem.set_loc(get_turf(hit))
			linkedGun.heldItem = null // One wayor another it's somewhere else now

/datum/projectile/pickpocket/harass
	sname = "harass"
	on_hit(atom/hit)
		if(ishuman(hit))
			var/mob/living/carbon/human/M = hit
			switch (targetZone)
				if ("chest")
					boutput(M, "Out of nowhere, you suddenly receive a huge wedgie!") // TODO: Add kick-me signs?
					M.weakened = max(rand(2,4), M.weakened)
					M.reagents.add_reagent("helium", 30)
					M.emote("scream")
				if ("head")
					if (M.head && ((M.head.c_flags & COVERSEYES) || !M.glasses)) // Dislodge eye-blocking hats, or other hats if target is not wearing eyewear
						var/obj/item/clothing/head/hat = M.head
						boutput(M, "Your [hat] is dislodged and sent flying by a sudden force!")
						M.u_equip(hat)
						hat.set_loc(M.loc)
						hat.dropped(M)
						hat.layer = initial(hat.layer)
						spawn(0) hat.throw_at(get_edge_target_turf(hat, pick(alldirs)), 50, 1) // Using gravitor accelerator figures because why not
					else if (M.glasses) // Smash eyewear
						var/obj/item/clothing/glasses/broke = M.glasses
						boutput(M, "Your [broke] is ripped from your face and crushed into pieces! What the hell!")
						M.u_equip(broke)
						qdel(broke)
					else // Eye gouge
						boutput(M, "<span style=\"color:red\">Something suddenly gouges you in the eyes! JESUS FUCK OW</span>")
						M.take_eye_damage(10)
				if ("r_arm") // Stop hitting yourself, stop hitting yourself
					if (M.r_hand && istype(M.r_hand, /obj/item/))
						var/obj/item/stopHittingYourself = M.r_hand
						boutput(M, "You suddenly take a swing at yourself with \the [stopHittingYourself]!")
						stopHittingYourself.attack(hit, M)
					else
						boutput(M, "You suddenly take a swing at yourself!")
						M.melee_attack(M)
				if ("l_arm")
					if (M.l_hand && istype(M.l_hand, /obj/item/))
						var/obj/item/stopHittingYourself = M.l_hand
						boutput(M, "You suddenly take a swing at yourself with \the [stopHittingYourself]!")
						stopHittingYourself.attack(hit, M)
					else
						boutput(M, "You suddenly take a swing at yourself!")
						M.melee_attack(M)
				if ("r_leg", "l_leg") // Tie shoelaces
					if (M.shoes && M.shoes.laces == 0)
						M.shoes.laces = 1
						if (istype(M.shoes, /obj/item/clothing/shoes/clown_shoes))
							boutput(M, "Your shoes give out one sad, final squeak. Oh no.")
							M.shoes.step_sound = null
		return
