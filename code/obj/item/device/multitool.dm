/obj/item/device/multitool
	name = "multitool"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20
	mats = 6
	module_research = list("tools" = 5, "devices" = 2)

	/obj/item/device/multitool/suicide(var/mob/user as mob)
		user.visible_message("<span style=\"color:red\"><b>[user] connects the wires from the multitool onto [him_or_her(user)]self's tongue and presses pulse. It's pretty shocking to look at.</b></span>")
		user.TakeDamage("head", 0,160)
		user.updatehealth()
		spawn(100)
			if (user)
				user.suiciding = 0
		return 1
