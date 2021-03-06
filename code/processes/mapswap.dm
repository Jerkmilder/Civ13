/process/epochswap
	// epoch = required players

	var/list/epochs = list(
//		"5000 B.C." = 0,
		"313 B.C." = 0,
		"1013" = 0,
		"1713" = 0,
		"1873" = 0,
//		"1904" = 0,
		"Civilization 13" = 0,
	)
	var/ready = TRUE
	var/admin_triggered = FALSE
	var/finished_at = -1

/process/epochswap/setup()
	name = "epochswap"
	schedule_interval = 5 SECONDS
	start_delay = 5 SECONDS
	fires_at_gamestates = list(GAME_STATE_PLAYING, GAME_STATE_FINISHED)
	priority = PROCESS_PRIORITY_IRRELEVANT
	processes.epochswap = src

/process/epochswap/fire()
	// no SCHECK here
	if (is_ready())
		if (config.allowedgamemodes == "TDM")
			epochs = list(
				"313 B.C." = 0,
				"1013" = 0,
				"1713" = 0,
				"1873" = 0,
//				"1904" = 0,
			)
		else if (config.allowedgamemodes == "RP")
			epochs = list("Civilization 13" = 0,)
		ready = FALSE
		vote.initiate_vote("epoch", "EpochSwap Process", TRUE, list(src, "swap"))

/process/epochswap/proc/is_ready()
	. = FALSE

	if (ready)
		if (admin_triggered)
			. = TRUE
		// round will end soon (tm)
		else if (map && map.admins_triggered_roundend)
			. = TRUE
		else if (ticker.finished)
			. = TRUE
	return .

/process/epochswap/proc/swap(var/winner = "1713")
	vote.voted_epoch = winner


/process/mapswap
	// map = required players
	var/list/maps = list(MAP_CURSED_ISLAND = 0,)
	var/epoch = "1713"
	var/ready = TRUE
	var/admin_triggered = FALSE
	var/finished_at = -1
	var/next_map_title = "TBD"

/process/mapswap/setup()
	name = "mapswap"
	schedule_interval = 5 SECONDS
	start_delay = 5 SECONDS
	fires_at_gamestates = list(GAME_STATE_PLAYING, GAME_STATE_FINISHED)
	priority = PROCESS_PRIORITY_IRRELEVANT
	processes.mapswap = src

/process/mapswap/fire()
	// no SCHECK here
	if (is_ready())
		ready = FALSE
		epoch = vote.voted_epoch

		if (epoch == "1904")
	// 1903 - TDM
			maps = list(
				MAP_HILL203 = 0,
			)

		if (epoch == "1873")
	// 1873 - TDM
			maps = list(
				MAP_LITTLE_CREEK = 10,
				MAP_LITTLE_CREEK_TDM = 0,
			)
		if (epoch == "1713")
		//1713 - TDM
			maps = list(
//				MAP_CURSED_ISLAND = 0,
				MAP_NAVAL = 0,
				MAP_ISLAND = 0,
		//		MAP_VOYAGE = 10,
		//		MAP_BATTLEROYALE = 20,
				MAP_SUPPLY_RAID = 8,
				MAP_RECIFE = 10,
//				MAP_FIELDS = 10,
				MAP_ROBUSTA = 15,

			// 1713 - RP
//				MAP_COLONY = 0,
				MAP_HUNT = 0,
//				MAP_FOUR_COLONIES = 35,
			)
		if (epoch == "313 B.C.")
	// 313bc - TDM
			maps = list(
				MAP_HERACLEA = 0,
				MAP_SIEGE = 0,
			)
		if (epoch == "1013")
	//	1013 - TDM
			maps = list(
				MAP_CAMP = 0,
				MAP_KARAK = 0,
			)
		if (epoch == "5000 B.C.")
			maps = list(
				MAP_TRIBES = 0,
			)
		if (epoch == "Civilization 13")
			maps = list(
//				MAP_CIVILIZATIONS = 0,
				MAP_NOMADS = 0,
				MAP_NOMADS_DESERT = 0,
				MAP_NOMADS_ICE_AGE = 0,
				MAP_NOMADS_JUNGLE = 0,
				MAP_NOMADS_DIVIDE = 0,
				MAP_NOMADS_CONTINENTAL = 0,
				MAP_NOMADS_PANGEA = 0,
			)

		spawn(10)
			vote.initiate_vote("map", "MapSwap Process", TRUE, list(src, "swap"))


/process/mapswap/proc/is_ready()
	. = FALSE

	if (ready)
		if (admin_triggered)
			. = TRUE
		// round will end soon (tm)
		else if (map && map.admins_triggered_roundend)
			. = TRUE
		else if (ticker.finished)
			. = TRUE
	return .

/process/mapswap/proc/swap(var/winner = "Naval")
	next_map_title = winner
	winner = uppertext(winner)
	if (!maps.Find(winner))
		winner = maps[1]
	// there used to be messages here about success and failure but they lie so they're gone - Kachnov
	processes.python.execute("mapswap.py", list(winner))

/process/gamemode
	var/ready = TRUE
	var/admin_triggered = FALSE
	var/finished_at = -1

/process/gamemode/setup()
	name = "gamemode"
	schedule_interval = 5 SECONDS
	start_delay = 5 SECONDS
	fires_at_gamestates = list()
	priority = PROCESS_PRIORITY_IRRELEVANT
	processes.gamemode = src
/process/gamemode/fire()
	// no SCHECK here
	if (is_ready())
		ready = FALSE
		vote.initiate_vote("gamemode", "Gamemode Process", TRUE, list(src, "swap"))

/process/gamemode/proc/is_ready()
	. = FALSE

	if (ready)
		if (admin_triggered)
			. = TRUE
		// round will end soon (tm)
		else if (map && map.admins_triggered_roundend)
			. = TRUE
		else if (ticker.finished)
			. = FALSE
	return .

/process/gamemode/proc/swap(var/winner = "Classic (Stone Age Start)")
	vote.voted_gamemode = winner
	round_progressing = TRUE
	ticker.delay_end = FALSE
	ticker.pregame_timeleft = 10
	if (vote.voted_gamemode == "Random")
		vote.voted_gamemode = pick("Classic (Stone Age Start)", "Auto-Research Mode", "Resource-Based Research", "Chad Mode", "Bronze Age (No Research)","Medieval (No Research)","Imperial Age (No Research)", "Industrial Age (No Research)", "Modern Age (No Research)")

	map.gamemode = vote.voted_gamemode
	if (vote.voted_gamemode == "Classic (Stone Age Start)")
		world << "<big>Starting <b>Classic</b> mode. Starting epoch is the Stone Age, research active.</big>"
		return

	if (vote.voted_gamemode == "Chad Mode")
		world << "<font color=#CECE00><big>Starting <b>Chad Mode</b>. Game epoch is the Stone Age, research inactive. Reduced starting items and more hostile conditions.</big></font>"
		map.research_active = FALSE
		map.chad_mode = TRUE
		for (var/obj/effect/spawner/mobspawner/MS)
			MS.buff()
		for (var/obj/structure/wild/tree/T)
			T.amount *= 0.5
			T.amount = round(T.amount)
		for (var/obj/structure/wild/jungle/J)
			J.amount *= 0.5
			J.amount = round(J.amount)
		for (var/obj/structure/wild/palm/P)
			P.amount *= 0.5
			P.amount = round(P.amount)
		for (var/obj/structure/wild/junglebush/V)
			if (prob(75) && !istype(V,/obj/structure/wild/junglebush/chinchona))
				qdel(V)
		spawn(10)
			if (map.ID == MAP_NOMADS_ICE_AGE)
				for (var/turf/floor/dirt/winter/W)
					if (prob(40))
						W.ChangeTurf(/turf/floor/winter)
				for (var/turf/floor/winter/grass/WW)
					if (prob(40))
						WW.ChangeTurf(/turf/floor/winter)
			else if (map.ID == MAP_NOMADS_JUNGLE)
				for (var/turf/floor/dirt/winter/W)
					if (prob(40))
						W.ChangeTurf(/turf/floor/winter)
				for (var/turf/floor/winter/grass/WW)
					if (prob(40))
						WW.ChangeTurf(/turf/floor/winter)
		return

	else if (vote.voted_gamemode == "Bronze Age (No Research)")
		world << "<big>Starting <b>Bronze Age</b> mode. Game epoch is the Bronze Age, research inactive.</big>"
		map.ordinal_age = 1
		map.age = "313 B.C."
		map.age1_done = TRUE
		map.research_active = FALSE
		var/customresearch = 35
		map.default_research = customresearch
		map.civa_research = list(customresearch,customresearch,customresearch,null)
		map.civb_research = list(customresearch,customresearch,customresearch,null)
		map.civc_research = list(customresearch,customresearch,customresearch,null)
		map.civd_research = list(customresearch,customresearch,customresearch,null)
		map.cive_research = list(customresearch,customresearch,customresearch,null)
		map.civf_research = list(customresearch,customresearch,customresearch,null)
		return

	else if (vote.voted_gamemode == "Auto-Research Mode")
		world << "<big>Starting <b>Auto-Research mode</b>. Starting epoch is the Stone Age, research active but automatic.</big>"
		map.research_active = FALSE //well, it is, but we dont get research kits.
		map.autoresearch = TRUE
		spawn(100)
			map.autoresearch_proc()
		return

	else if (vote.voted_gamemode == "Resource-Based Research")
		world << "<big>Starting <b>Resource-Based Research</b>. Starting epoch is the Stone Age, research active and requires the sale of items through <b>Research Desks</b>.</big>"
		map.research_active = FALSE //well, it is, but we dont get research kits.
		map.resourceresearch = TRUE
		return

	else if (vote.voted_gamemode == "Bronze Age Start")
		world << "<big>Starting Classic mode with <b>Bronze Age</b> start. Starting epoch is the Bronze Age, research active.</big>"
		map.ordinal_age = 1
		map.age = "313 B.C."
		map.age1_done = TRUE
		map.research_active = TRUE
		var/customresearch = 35
		map.default_research = customresearch
		map.civa_research = list(customresearch,customresearch,customresearch,null)
		map.civb_research = list(customresearch,customresearch,customresearch,null)
		map.civc_research = list(customresearch,customresearch,customresearch,null)
		map.civd_research = list(customresearch,customresearch,customresearch,null)
		map.cive_research = list(customresearch,customresearch,customresearch,null)
		map.civf_research = list(customresearch,customresearch,customresearch,null)
		return
	else if (vote.voted_gamemode == "Medieval (No Research)")
		world << "<big>Starting <b>Medieval Age</b> mode. Game Epoch is the Medieval Age, research inactive.</big>"
		map.ordinal_age = 2
		map.age = "1013"
		map.age1_done = TRUE
		map.age2_done = TRUE
		map.research_active = FALSE
		var/customresearch = 50
		map.default_research = customresearch
		map.civa_research = list(customresearch,customresearch,customresearch,null)
		map.civb_research = list(customresearch,customresearch,customresearch,null)
		map.civc_research = list(customresearch,customresearch,customresearch,null)
		map.civd_research = list(customresearch,customresearch,customresearch,null)
		map.cive_research = list(customresearch,customresearch,customresearch,null)
		map.civf_research = list(customresearch,customresearch,customresearch,null)
		return
	else if (vote.voted_gamemode == "Imperial Age (No Research)")
		world << "<big>Starting <b>Imperial Age</b> mode. Game Epoch is the Imperial Age, research inactive.</big>"
		map.ordinal_age = 3
		map.age = "1713"
		map.age1_done = TRUE
		map.age2_done = TRUE
		map.age3_done = TRUE
		map.research_active = FALSE
		var/customresearch = 90
		map.default_research = customresearch
		map.civa_research = list(customresearch,customresearch,customresearch,null)
		map.civb_research = list(customresearch,customresearch,customresearch,null)
		map.civc_research = list(customresearch,customresearch,customresearch,null)
		map.civd_research = list(customresearch,customresearch,customresearch,null)
		map.cive_research = list(customresearch,customresearch,customresearch,null)
		map.civf_research = list(customresearch,customresearch,customresearch,null)
		return
	else if (vote.voted_gamemode == "Industrial Age (No Research)")
		world << "<big>Starting <b>Industrial Age</b> mode. Game Epoch is the Industrial Age, research inactive.</big>"
		map.ordinal_age = 4
		map.age = "1873"
		map.age1_done = TRUE
		map.age2_done = TRUE
		map.age3_done = TRUE
		map.age4_done = TRUE
		map.research_active = FALSE
		var/customresearch = 104
		map.default_research = customresearch
		map.civa_research = list(customresearch,customresearch,customresearch,null)
		map.civb_research = list(customresearch,customresearch,customresearch,null)
		map.civc_research = list(customresearch,customresearch,customresearch,null)
		map.civd_research = list(customresearch,customresearch,customresearch,null)
		map.cive_research = list(customresearch,customresearch,customresearch,null)
		map.civf_research = list(customresearch,customresearch,customresearch,null)
		return

	else if (vote.voted_gamemode == "Modern Age (No Research)")
		world << "<big>Starting <b>Modern Age</b> mode. Game Epoch is the Modern Age, research inactive.</big>"
		map.ordinal_age = 5
		map.age = "1903"
		map.age1_done = TRUE
		map.age2_done = TRUE
		map.age3_done = TRUE
		map.age4_done = TRUE
		map.age5_done = TRUE
		map.research_active = FALSE
		var/customresearch = 135
		map.default_research = customresearch
		map.civa_research = list(customresearch,customresearch,customresearch,null)
		map.civb_research = list(customresearch,customresearch,customresearch,null)
		map.civc_research = list(customresearch,customresearch,customresearch,null)
		map.civd_research = list(customresearch,customresearch,customresearch,null)
		map.cive_research = list(customresearch,customresearch,customresearch,null)
		map.civf_research = list(customresearch,customresearch,customresearch,null)
		return
