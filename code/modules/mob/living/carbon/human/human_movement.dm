/mob/living/carbon/human/movement_delay()
	. = 0
	. += ..()
	. += config.human_delay
	. += species.movement_delay(src)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)

	if(..())
		return 1

	//Do we have a working jetpack?
	var/obj/item/weapon/tank/jetpack/thrust
	if(istype(back,/obj/item/weapon/tank/jetpack))
		thrust = back
	else if(istype(back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/rig = back
		for(var/obj/item/rig_module/maneuvering_jets/module in rig.installed_modules)
			thrust = module.jets
			break

	if(thrust)
		if((movement_dir || thrust.stabilizers) && thrust.allow_thrust(0.01, src))
			return 1
	return 0

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(shoes && .) // did we actually move?
		if(!lying && !buckled)
			if(!has_gravity(loc))
				return
			var/obj/item/clothing/shoes/S = shoes
			S.step_action(src)

/mob/living/carbon/human/handle_footstep(turf/T)
	if(..())
		if(T.footstep_sounds["human"])
			var/S = pick(T.footstep_sounds["human"])
			if(S)
				if(m_intent == MOVE_INTENT_RUN)
					if(!(step_count % 2)) //every other turf makes a sound
						return 0

				var/range = -(world.view - 2)
				if(m_intent == MOVE_INTENT_WALK)
					range -= 0.333
				if(!shoes)
					range -= 0.333

				//shoes + running
					//-(7 - 2) = -(5) = -5 | -5 - 0           = -5     | (7 + -5)     = 2     | 2     * 3 = 6     | range(6)     = range(6)
				//running OR shoes
					//-(7 - 2) = (-5) = -5 | -5 - 0.333       = -5.333 | (7 + -5.333) = 1.667 | 1.667 * 3 = 5.001 | range(5.001) = range(5)
				//walking AND no shoes
					//-(7 - 2) = (-5) = -5 | -5 - (0.333 * 2) = -5.666 | (7 + -5.666) = 1.334 | 1.334 * 3 = 4.002 | range(4.002) = range(4)

				var/volume = 13
				if(m_intent == MOVE_INTENT_WALK)
					volume -= 4
				if(!shoes)
					volume -= 4

				if(istype(shoes, /obj/item/clothing/shoes))
					var/obj/item/clothing/shoes/shooess = shoes
					if(shooess.silence_steps)
						return 0 //silent

				if(!has_organ("l_foot") && !has_organ("r_foot"))
					return 0 //no feet no footsteps

				if(buckled || lying || throwing)
					return 0 //people flying, lying down or sitting do not step

				if(!has_gravity(src))
					if(step_count % 3) //this basically says, every three moves make a noise
						return 0       //1st - none, 1%3==1, 2nd - none, 2%3==2, 3rd - noise, 3%3==0

				if(species.silent_steps)
					return 0 //species is silent

				playsound(T, S, volume, 1, range)
				return 1

	return 0