//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Opens the Wiki in your browser."
	set hidden = 1
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		if(alert("This will open the Wiki in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(wikiurl)
	else
		to_chat(src, "<span class='danger'>The Wiki URL is not set in the server configuration.</span>")
	return

/client/verb/discord()
	set name = "discord"
	set desc = "Visit the Discord."
	set hidden = 1
	var/discordurl = CONFIG_GET(string/discordurl)
	if(discordurl)
		if(alert("This will open the Discord in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(discordurl)
	else
		to_chat(src, "<span class='danger'>The discord URL is not set in the server configuration.</span>")
	return

/client/verb/rules()
	set name = "rules"
	set desc = "Show Server Rules."
	set hidden = 1
//	var/rulesurl = CONFIG_GET(string/rulesurl)
	switch(alert("Would you like to see the rules?", null, "View here", "Cancel"))
/*		if("Discord (external link)")
			if(!rulesurl)
				to_chat(src, "<span class='danger'>The rules URL is not set in the server configuration.</span>")
				return
			src << link(rulesurl)*/
		if("View here")
			src << browse('html/rules.html', "window=changes")

/client/verb/lore()
	set name = "lore"
	set desc = "Show Server Lore."
	set hidden = 1
	switch(alert("Would you like to see the Lore?", null, "View here", "Cancel"))
		if("View here")
			src << browse('html/lore.html', "window=changes")

/client/verb/github()
	set name = "github"
	set desc = "Visit Github"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		if(alert("This will open the Github repository in your browser. Are you sure?",,"Yes","No")!="Yes")
			return
		src << link(githuburl)
	else
		to_chat(src, "<span class='danger'>The Github URL is not set in the server configuration.</span>")
	return

/client/verb/reportissue()
	set name = "report-issue"
	set desc = "Report an issue"
	set hidden = 1
	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		var/message = "This will open the Github issue reporter in your browser. Are you sure?"
		if(GLOB.revdata.testmerge.len)
			message += "<br>The following experimental changes are active and are probably the cause of any new or sudden issues you may experience. If possible, please try to find a specific thread for your issue instead of posting to the general issue tracker:<br>"
			message += GLOB.revdata.GetTestMergeInfo(FALSE)
		if(tgalert(src, message, "Report Issue","Yes","No")!="Yes")
			return
		var/static/issue_template = file2text(".github/ISSUE_TEMPLATE.md")
		var/servername = CONFIG_GET(string/servername)
		var/url_params = "Reporting client version: [byond_version]\n\n[issue_template]"
		if(GLOB.round_id || servername)
			url_params = "Issue reported from [GLOB.round_id ? " Round ID: [GLOB.round_id][servername ? " ([servername])" : ""]" : servername]\n\n[url_params]"
		DIRECT_OUTPUT(src, link("[githuburl]/issues/new?body=[url_encode(url_params)]"))
	else
		to_chat(src, "<span class='danger'>The Github URL is not set in the server configuration.</span>")
	return

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/adminhotkeys = {"<font color='purple'>
Admin:
\tF3 = asay
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel
\tF7 = Buildmode
\tF8 = Invisimin
\tCtrl+F8 = Stealthmin
</font>"}

	mob.hotkey_help()

	if(holder)
		to_chat(src, adminhotkeys)

/client/verb/changelog()
	set name = "Changelog"
	set category = "OOC"
	var/datum/asset/changelog = get_asset_datum(/datum/asset/simple/changelog)
	changelog.send(src)
	src << browse('html/changelog.html', "window=changes;size=675x650")
	if(prefs.lastchangelog != GLOB.changelog_hash)
		prefs.lastchangelog = GLOB.changelog_hash
		prefs.save_preferences()
		winset(src, "infowindow.changelog", "font-style=;")


/mob/proc/hotkey_help()
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tm = me
\tt = say
\ty = whisper
\to = OOC
\tl = LOOC
\tb = resist
\tu = rest
\t<B></B>h = stop pulling
\tx = swap-hand
\tz = activate held object
\tShift+e = Put held item into belt or take out most recent item added to belt.
\tShift+b = Put held item into backpack or take out most recent item added to backpack.
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
\tNumpad = Body target selection (Press 8 repeatedly for Head->Eyes->Mouth)
\tAlt(HOLD) = Alter movement intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+b = resist
\tCtrl+u = rest
\tCtrl+h = stop pulling
\tCtrl+y = whisper
\tCtrl+o = OOC
\tCtrl+l = LOOC
\tCtrl+x = swap-hand
\tCtrl+z = activate held object
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tCtrl+'+/-' OR
\tShift+Mousewheel = Ghost zoom in/out
\tDEL = stop pulling
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
\tCtrl+Numpad = Body target selection (Press 8 repeatedly for Head->Eyes->Mouth)
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)

/mob/living/silicon/robot/hotkey_help()
	//h = talk-wheel has a nonsense tag in it because \th is an escape sequence in BYOND.
	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = unequip active module
\t<B></B>h = stop pulling
\tm = me
\tt = say
\ty = whisper
\to = OOC
\tl = LOOC
\tx = cycle active modules
\tb = resist
\tz = activate held object
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = activate module 1
\t2 = activate module 2
\t3 = activate module 3
\t4 = toggle intents
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = unequip active module
\tCtrl+x = cycle active modules
\tCtrl+b = resist
\tCtrl+h = stop pulling
\tCtrl+y = whisper
\tCtrl+o = OOC
\tCtrl+l = LOOC
\tCtrl+z = activate held object
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = activate module 1
\tCtrl+2 = activate module 2
\tCtrl+3 = activate module 3
\tCtrl+4 = toggle intents
\tDEL = stop pulling
\tINS = toggle intents
\tPGUP = cycle active modules
\tPGDN = activate held object
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)
