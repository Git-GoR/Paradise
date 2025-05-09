/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_transfer = 0.6
	range = 13
	playstyle_string = "As an <b>Explosive</b> type, you have only moderate close combat abilities, but are capable of converting any adjacent item into a disguised bomb via alt click even when not manifested."
	magic_fluff_string = "..And draw the Scientist, master of explosive death."
	tech_fluff_string = "Boot sequence complete. Explosive modules active. Holoparasite swarm online."
	bio_fluff_string = "Your scarab swarm finishes mutating and stirs to life, capable of stealthily booby trapping items."
	var/bomb_cooldown = 0
	var/default_bomb_cooldown = 20 SECONDS

/mob/living/simple_animal/hostile/guardian/bomb/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(bomb_cooldown >= world.time)
		status_tab_data[++status_tab_data.len] = list("Bomb Cooldown Remaining:", "[max(round((bomb_cooldown - world.time) * 0.1, 0.1), 0)] seconds")

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(get_dist(get_turf(src), get_turf(A)) > 1)
		to_chat(src, "<span class='danger'>You're too far from [A] to disguise it as a bomb.</span>")
		return
	if(isobj(A) && can_plant(A))
		if(bomb_cooldown <= world.time && stat == CONSCIOUS)
			var/obj/item/guardian_bomb/B = new /obj/item/guardian_bomb(get_turf(A))
			add_attack_logs(src, A, "booby trapped (summoner: [summoner])")
			to_chat(src, "<span class='danger'>Success! Bomb on [A] armed!</span>")
			if(summoner)
				to_chat(summoner, "<span class='warning'>Your guardian has primed [A] to explode!</span>")
			bomb_cooldown = world.time + default_bomb_cooldown
			B.spawner = src
			B.disguise (A)
		else
			to_chat(src, "<span class='danger'>Your power is on cooldown! You must wait another [max(round((bomb_cooldown - world.time)*0.1, 0.1), 0)] seconds before you can place next bomb.</span>")

/mob/living/simple_animal/hostile/guardian/bomb/proc/can_plant(atom/movable/A)
	if(ismecha(A))
		var/obj/mecha/target = A
		if(target.occupant)
			to_chat(src, "<span class='warning'>You can't disguise piloted mechs as a bomb!</span>")
			return FALSE
	if(istype(A, /obj/machinery/disposal)) // Have no idea why they just destroy themselves
		to_chat(src, "<span class='warning'>You can't disguise disposal units as a bomb!</span>")
		return FALSE
	return TRUE

/obj/item/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/spawner

/obj/item/guardian_bomb/proc/disguise(obj/A)
	A.forceMove(src)
	stored_obj = A
	opacity = A.opacity
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	dir = A.dir
	move_resist = A.move_resist
	addtimer(CALLBACK(src, PROC_REF(disable)), 600)

/obj/item/guardian_bomb/CanPass(atom/movable/mover, border_dir)
	return stored_obj.CanPass(mover, border_dir)

/obj/item/guardian_bomb/proc/disable()
	add_attack_logs(null, stored_obj, "booby trap expired")
	stored_obj.forceMove(get_turf(src))
	if(spawner)
		to_chat(spawner, "<span class='danger'>Failure! Your trap on [stored_obj] didn't catch anyone this time.</span>")
	qdel(src)

/obj/item/guardian_bomb/proc/detonate(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='danger'>[src] was boobytrapped!</span>")
	if(isguardian(spawner))
		var/mob/living/simple_animal/hostile/guardian/G = spawner
		if(user == G.summoner)
			add_attack_logs(user, stored_obj, "booby trap defused")
			to_chat(user, "<span class='danger'>You knew this because of your link with your guardian, so you smartly defuse the bomb.</span>")
			stored_obj.forceMove(get_turf(loc))
			qdel(src)
			return
	add_attack_logs(user, stored_obj, "booby trap TRIGGERED (spawner: [spawner])")
	to_chat(spawner, "<span class='danger'>Success! Your trap on [src] caught [user]!</span>")
	stored_obj.forceMove(get_turf(loc))
	playsound(get_turf(src),'sound/effects/explosion2.ogg', 200, 1)
	user.ex_act(EXPLODE_HEAVY)
	user.Stun(3 SECONDS)//A bomb went off in your hands. Actually lets people follow up with it if they bait someone, right now it is unreliable.
	qdel(src)

/obj/item/guardian_bomb/attackby__legacy__attackchain(obj/item/W, mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/attack_hand(mob/user)
	detonate(user)

/obj/item/guardian_bomb/MouseDrop_T(obj/item/I, mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/AltClick(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/MouseDrop(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/Bumped(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/can_be_pulled(mob/living/user)
	detonate(user)

/obj/item/guardian_bomb/examine(mob/user)
	. = stored_obj.examine(user)
	if(get_dist(user, src) <= 2)
		. += "<span class='notice'>Looks odd!</span>"
