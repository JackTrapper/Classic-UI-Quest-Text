local cuufv = 1
local qtv = 1
local qfv = 1
local cuuf = function()
	local data = {GetAddOnInfo("Primal_QuestFrame")}
	local loadable = data[4]
	--print(loadable )
	local enabled = loadable
	local clui_loaded_qf = enabled 
	data = {GetAddOnInfo("QuestText")}
	loadable = data[4]
	enabled = loadable
	local clui_loaded_qt = enabled 
	local needsupdate = false
	if clui_loaded_qt and CUI_qt then
		--[[print("loaded")
		print(CUI_qt)
		for k, v in pairs(CUI_qt) do
			print(k, v)
		end]]
		--[[if CUI_qt == nil then
			CUI_qt = {lv = 0}
		end      ]]
		if CUI_qt.lv < qtv then needsupdate = true end
		CUI_qt.lv = qtv
	end
	if clui_loaded_qf and CUI_qf then
		--[[print("loaded")
		print(CUI_qf)
		for k, v in pairs(CUI_qf) do
			print(k, v)
		end]]--[[
		if CUI_qf == nil then
			print("nil")
			CUI_qf = {lv = 0}
		end]]
		if CUI_qf.lv < qfv then needsupdate = true end
		CUI_qf.lv = qfv
		--print(CUI_qf.lv)
	end
	
	local texty = "Classic UI modules installed:\n"
	if clui_loaded_qt then
		texty = texty .. "Scrolling Quest Text\n"
	end
	if clui_loaded_qf then
		texty = texty .. "Quest Frame\n"
	end
	texty = texty .. "\nClassic UI modules available:\n"
	
	if not clui_loaded_qt then
		texty = texty .. "Scrolling Quest Text\n"
	end
	if not clui_loaded_qf then
		texty = texty .. "Quest Frame\n"
	end
	
	if needsupdate then
		StaticPopupDialogs["QUESTTEXT_HELP"] = {
			text = texty,
			button1 = "Ok",
			OnAccept = function()
				local l = 1
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = false,
			preferredIndex = 3
		}
		StaticPopup_Show("QUESTTEXT_HELP")
	end
		
end

if ClassicUIUpdateCheckVersion == nil or ClassicUIUpdateCheckVersion < cuufv then
	ClassicUIUpdateCheck = cuuf
	ClassicUIUpdateCheckVersion = cuufv
end