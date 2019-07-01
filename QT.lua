local frame = CreateFrame("FRAME")
frame:Show()
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("GOSSIP_SHOW")
local qf_prog = 0
local qf_width = 0
local qf_doprog
local qf_prog_old = 0
local qf_prog2 = 1
local qf_doprog2 = 0
local qf_done = 1
local sounds = {"Sound/Interface/WriteQuestA.ogg", "Sound/Interface/WriteQuestB.ogg", "Sound/Interface/WriteQuestC.ogg"}
local currentqid = 0
local currentqm = 0
local current_mode = 0
local config_frame = CreateFrame("FRAME")

config_frame.texture = config_frame:CreateTexture()
config_frame.texture:SetAllPoints(config_frame)
config_frame.texture:SetColorTexture(0, 0, 0, 0.5)
config_frame.SetBackgroundColor = function(...) end

config_frame:SetPoint("CENTER", QuestFrame, "CENTER")
config_frame:SetSize(180, 80)
config_frame:SetFrameStrata("DIALOG")
config_frame.text0 = CreateFrame("SIMPLEHTML", nil, config_frame)
config_frame.text0:SetPoint("TOPLEFT", config_frame, "TOPLEFT", 4, -6)
config_frame.text0:SetSize(100, 10)
config_frame.text0:SetFont("Fonts\\FRIZQT__.TTF", 8)
config_frame.text0:SetText("Quest text fading mode")

config_frame["btn" .. 0] = CreateFrame("BUTTON", nil, config_frame)
config_frame["btn" .. 0]:SetPoint("TOPLEFT", config_frame, "TOPLEFT", 142, 0)
config_frame["btn0"]:SetText("|cffff0000X|r")
config_frame.btn0:SetScript("OnClick", function(...)
	config_frame:Hide()
end)
config_frame["btn" .. 0]:SetSize(58, 19)
config_frame["font" .. 0] = CreateFont("QuestTextButtonFont" .. 0)
config_frame["font" .. 0]:SetFont("\Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
--config_frame["font" .. i]:CopyFontObject("GameFontNormal")
config_frame["btn" .. 0]:SetNormalFontObject("QuestTextButtonFont" .. 0)

config_frame.text1 = CreateFrame("SIMPLEHTML", nil, config_frame)
config_frame.text1:SetPoint("TOPLEFT", config_frame.text0, "TOPLEFT", -4, -14)
config_frame.text1:SetSize(58, 10)
config_frame.text1:SetFont("Fonts\\FRIZQT__.TTF", 8)
config_frame.text1:SetText("Legendary")

config_frame.text2 = CreateFrame("SIMPLEHTML", nil, config_frame)
config_frame.text2:SetPoint("TOPLEFT", config_frame.text0, "TOPLEFT", 56, -14)
config_frame.text2:SetSize(58, 10)
config_frame.text2:SetFont("Fonts\\FRIZQT__.TTF", 8)
config_frame.text2:SetText("Normal")

config_frame.text3 = CreateFrame("SIMPLEHTML", nil, config_frame)
config_frame.text3:SetPoint("TOPLEFT", config_frame.text0, "TOPLEFT", 116, -14)
config_frame.text3:SetSize(58, 10)
config_frame.text3:SetFont("Fonts\\FRIZQT__.TTF", 8)
config_frame.text3:SetText("Repeatable")
for i = 1, 12 do
	config_frame["btn" .. i] = CreateFrame("BUTTON", nil, config_frame)
	config_frame["btn" .. i]:SetPoint("TOPLEFT", config_frame, "TOPLEFT", 60 * ((i-1) - ((i-1) % 4)) / 4,  -12 * ((i-1) % 4 + 1) - 13)
	config_frame["btn" .. i]:SetSize(58, 19)
	config_frame["font" .. i] = CreateFont("QuestTextButtonFont" .. i)
	config_frame["font" .. i]:SetFont("\Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
	--config_frame["font" .. i]:CopyFontObject("GameFontNormal")
	config_frame["btn" .. i]:SetNormalFontObject("QuestTextButtonFont" .. i)
	config_frame["btn" .. i]:SetHighlightFontObject("QuestTextButtonFont" .. i)
	local btnid = i
	config_frame["btn" .. i].SetTextColor = function(self, r, g, b, a)
		local font = config_frame["font" .. btnid]
		font:SetTextColor(r, g, b, a)
		self:SetNormalFontObject(font)
	end
	local btnmode
	local btngroup
	if i % 4 == 1 then
		btnmode = 0
		config_frame["btn" .. i]:SetText("Instant")
	elseif i % 4 == 2 then
		btnmode = 2
		config_frame["btn" .. i]:SetText("Fading")
	elseif i % 4 == 3 then
		btnmode = 1
		config_frame["btn" .. i]:SetText("Scrolling")
	elseif i % 4 == 0 then
		btnmode = 3
		config_frame["btn" .. i]:SetText("Immersive")
	end
	config_frame["btn" .. i]:SetTextColor(1, 1, 1, 1)
	if (((i-1) - ((i-1) % 4)) / 4) == 0 then
		btngroup = "legendary"
	elseif (((i-1) - ((i-1) % 4)) / 4) == 1 then
		btngroup = "normal"
	else
		btngroup = "daily"
	end
	config_frame["btn" .. i]:SetScript("OnClick", function(self)
		for i = (((btnid - 1) - ((btnid - 1) % 4)) / 4 + 1) * 4 - 3, (((btnid - 1) - ((btnid - 1) % 4)) / 4 + 1) * 4 do
			if i ~= btnid then
			config_frame["btn" .. i]:SetTextColor(1, 1, 1, 1)
			end
		end
		self:SetTextColor(1, 0.8, 0, 1)
		glob_sqt[btngroup].mode = btnmode
	end)
end
		
			
	
local GetCurrentMode = function()
	--print("GETMODE")
	if currentqid == -2 then
		current_mode = glob_sqt.daily.mode
		return
	elseif currentqid == -3 then
		current_mode = glob_sqt.normal.mode
		return
	end
		
	if currentqm == -1 then
		if GetNumAvailableQuests() > 0 then
			currentqm = 0
		elseif GetNumActiveQuests() > 0 then
			currentqm = 1
		else
			return
		end
	end
	local index = currentqid
	local questNum = GetNumAvailableQuests()
	local isTrivial, frequency, isRepeatable, isLegendary
	if currentqm == 0 then
		isTrivial, frequency, isRepeatable, isLegendary = GetAvailableQuestInfo(currentqid)
	elseif currentqm == 1 then
		isTrivial, frequency, isRepeatable, isLegendary = GetAvailableQuestInfo(questNum + currentqid)
	elseif currentqm == 3 then
		local qs = {GetGossipActiveQuests()}
		--print(unpack(qs))
		isTrivial = qs[(index-1) * 5 + 3]
		frequency = glob_sqt.repeatable[qs[(index-1) * 5 + 1]]
		--isRepeatable = qs[(index-1) * 5 + 1]
		isLegendary = qs[(index-1) * 5 + 5]
		if frequency ~= 1 then
			isRepeatable = true
		end
		if frequency == 1 then
			isRepeatable = false
		end
		if frequency == nil then
			frequency = 1
			isRepeatable = false
		end
	elseif currentqm == 2 then
		local qs = {GetGossipAvailableQuests()}
	--	print(unpack(qs))
		isTrivial = qs[(index-1) * 6 + 3]
		frequency = qs[(index-1) * 6 + 4]
		isRepeatable = qs[(index-1) * 6 + 5]
		isLegendary = qs[(index-1) * 6 + 6]
		glob_sqt.repeatable[qs[(index-1) * 6 + 1]] = frequency
	end
	if isLegendary then
		current_mode = glob_sqt.legendary.mode
	else
		if isRepeatable or frequency ~= 1 then
			current_mode = glob_sqt.daily.mode
		else
			current_mode = glob_sqt.normal.mode
		end
	end
	current_mode_w = 1
end

InjectPrint = function(name)
	local n = name
	local oldf = _G[name]
	local injf = function(...)
		print(n, ...)
		return oldf(...)
	end
	_G[name] = injf
end
		
local fupd = function(self, arg)
				--if OnUpdate_old ~= nil then
				--	OnUpdate_old()
				--end
				--print("UPDATE")
				if QuestFrame:IsVisible() then
				if qf_doprog2 == 1 then
					qf_prog2 = qf_prog2 + arg
					if qf_prog2 > 1 then
						qf_doprog2 = 0
						qf_prog2 = 1
					end
				end
				QuestInfoObjectivesText:SetAlpha(qf_prog2)
				QuestInfoRewardText:SetAlpha(qf_prog2)
				QuestInfoRequiredMoneyText:SetAlpha(qf_prog2)
				QuestInfoGroupSize:SetAlpha(qf_prog2)
				QuestInfoAnchor:SetAlpha(qf_prog2)
				QuestInfoDescriptionHeader:SetAlpha(qf_prog2)
				QuestInfoObjectivesHeader:SetAlpha(qf_prog2)
				QuestInfoRewardsFrame:SetAlpha(qf_prog2)
				--QuestInfoRewardsFrameQuestInfoTitleFrame:SetAlpha(df_prog2)
				--QuestFrameRewardPanel:SetAlpha(qf_prog2)
				--QuestFrameProgressPanel:SetAlpha(qf_prog2)
				--QuestInfoRewardSpell:SetAlpha(qf_prog2)
				--QuestInfoRewardFollower --
				--QuestIn
				QuestProgressTitleText:SetAlpha(qf_prog2)
				QuestProgressText:SetAlpha(qf_prog2)
				QuestProgressRequiredItemsText:SetAlpha(qf_prog2)
				QuestProgressRequiredMoneyText:SetAlpha(qf_prog2)
				QuestProgressRequiredMoneyFrame:SetAlpha(qf_prog2)
				QuestProgressItem1:SetAlpha(qf_prog2)
				QuestProgressItem2:SetAlpha(qf_prog2)
				QuestProgressItem3:SetAlpha(qf_prog2)
				QuestProgressItem4:SetAlpha(qf_prog2)
				QuestProgressItem5:SetAlpha(qf_prog2)
				QuestProgressItem6:SetAlpha(qf_prog2)
				if qf_done == 1 or current_mode == 2 then
				QuestInfoTitleHeader:SetAlpha(qf_prog2)
				end
				if current_mode == 2 then
					QuestInfoDescriptionText:SetAlpha(qf_prog2)
					
				end
				if qf_doprog == 1 then
					qf_prog = qf_prog + arg
					if qf_prog > qf_prog_old + 2 then
						qf_prog_old = qf_prog
						PlaySoundFile(sounds[math.random(3)], "SFX")
					end
					--if qf_prog > qf_prog_old + 1/QUEST_DESCRIPTION_GRADIENT_CPS then
					if arg > 1 then print(arg) end
					qf_width = QuestInfoDescriptionText:GetText():len() - 6
					QuestInfoDescriptionText:SetAlphaGradient(qf_prog * QUEST_DESCRIPTION_GRADIENT_CPS, QUEST_DESCRIPTION_GRADIENT_LENGTH)
					if qf_prog * QUEST_DESCRIPTION_GRADIENT_CPS > qf_width then
						qf_doprog = 0
						qf_prog = 0
						qf_prog2 = 0
						qf_doprog2 = 1
						QuestFrameAcceptButton:Enable()
						--self:SetScript("OnUpdate", nil)
					end
					
					--end
				end
				end
			end
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "QUEST_DETAIL" then
		if current_mode_w == nil then
			if QuestIsDaily() or QuestIsWeekly() then
				currentqid = -2
			else
				currentqid = -3
			end
			GetCurrentMode()
		end
		--print("detail")
		current_mode_w = nil
		--if QuestInfoFrame:IsVisible() then
				--print(current_mode)
				--print("EVENT FIRED")
				qf_prog = 0
				qf_prog2 = 0
				qf_done = 0
				if current_mode == 1 or current_mode == 3 then
				qf_prog_old = -2
				qf_doprog2 = 0
				qf_doprog = 1
				if current_mode == 3 then
					QuestFrameAcceptButton:Disable()
				else
					QuestFrameAcceptButton:Enable()
				end
				else
					if current_mode == 0 then
					qf_prog = 1
					qf_prog2 = 1
					qf_prog = qf_width
					QuestFrameAcceptButton:Enable()
					else
						if current_mode == 2 then
							qf_prog = qf_width
							qf_doprog2 = 1
							qf_doprog = 0
							QuestFrameAcceptButton:Enable()
						end
					end
				end
		--end
	end
	if event == "QUEST_GREETING" or event == "GOSSIP_SHOW" then
		--print("Greeting")
	end
	if event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
		qf_prog2 = 0
		qf_doprog2 = 1
		qf_done = 1
	end
	if event == "ADDON_LOADED" and ... == "QuestText" then
		if glob_sqt == nil then
			glob_sqt = {}
		end
		if glob_sqt.cps ~= nil then
			QUEST_DESCRIPTION_GRADIENT_CPS = glob_sqt.cps
		end
		if glob_sqt.len ~= nil then
			QUEST_DESCRIPTION_GRADIENT_LENGTH = glob_sqt.len
		end
		if glob_sqt.legendary == nil then
			glob_sqt.legendary = { mode = 1 }
		end
		if glob_sqt.normal == nil then
			glob_sqt.normal = { mode = 1 }
		end
		if glob_sqt.daily == nil then
			glob_sqt.daily = { mode = 2 }
		end
		if glob_sqt.repeatable == nil or glob_sqt.configver ~= 1 then
			glob_sqt.repeatable = {}
			glob_sqt.configver = 1
		end
		if glob_sqt.legendary.mode == 0 then
			config_frame.btn1:SetTextColor(1, 0.8, 0, 1)
		elseif glob_sqt.legendary.mode == 1 then
			config_frame.btn3:SetTextColor(1, 0.8, 0, 1)
		elseif glob_sqt.legendary.mode == 3 then
			config_frame.btn4:SetTextColor(1, 0.8, 0, 1)
		else
			config_frame.btn2:SetTextColor(1, 0.8, 0, 1)
		end
		if glob_sqt.normal.mode == 0 then
			config_frame.btn5:SetTextColor(1, 0.8, 0, 1)
		elseif glob_sqt.normal.mode == 1 then
			config_frame.btn7:SetTextColor(1, 0.8, 0, 1)
		elseif glob_sqt.normal.mode == 3 then
			config_frame.btn8:SetTextColor(1, 0.8, 0, 1)
		else
			config_frame.btn6:SetTextColor(1, 0.8, 0, 1)
		end
		if glob_sqt.daily.mode == 0 then
			config_frame.btn9:SetTextColor(1, 0.8, 0, 1)
		elseif glob_sqt.daily.mode == 1 then
			config_frame.btn11:SetTextColor(1, 0.8, 0, 1)
		elseif glob_sqt.daily.mode == 3 then
			config_frame.btn12:SetTextColor(1, 0.8, 0, 1)
		else
			config_frame.btn10:SetTextColor(1, 0.8, 0, 1)
		end
		if glob_sqt.help == nil then
			StaticPopupDialogs["QUESTTEXT_HELP"] = {
				text = "Scrolling Quest Text\n\nRight-click the quest text box for any quest to configure this AddOn\n\nYou can always skip the scrolling text by left-clicking it.",
				button1 = "Ok",
				OnAccept = function()
					glob_sqt.help = 1
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = false,
				preferredIndex = 3
			}
			StaticPopup_Show("QUESTTEXT_HELP")
		end
		QuestFrame:HookScript("OnMouseDown", function(self, ...)
			qf_prog = qf_width
			if ... == "RightButton" then
				config_frame:Show()
			end
		end)
		QuestFrameAcceptButton:HookScript("OnMouseDown", function(self, ...)
			qf_prog = qf_width
		end)
		config_frame:Hide()
		config_frame:SetBackgroundColor(0, 0, 0, 0.5)
		--[[
		local qtboc = QuestTitleButton_OnClick
		if qtboc == nil then
			print("Internal Quest Text Error")
		else
			QuestTitleButton_OnClick = function(self)
				--print("CLICK", slef:GetID())
				return qtboc(self)
			end
		end]]
		local saq = SelectAvailableQuest
		if saq == nil then
			print("Internal Quest Text Error Native")
		else
			SelectAvailableQuest = function(index)
				--print("AVAILABLE", index)
				currentqid = index
				currentqm = 0
				GetCurrentMode()
				return saq(index)
			end
		end
		local sac = SelectActiveQuest
		if sac == nil then
			print("Internal Quest Text Error Native")
		else
			SelectActiveQuest = function(index)
				--print("ACTIVE", index)
				currentqid = index
				currentqm = 1
				GetCurrentMode()
				return sac(index)
			end
		end
		local sgaq = SelectGossipAvailableQuest
		if sgaq ==  nil then
			print("Internal Quest Text Error NAtive")
		else
			SelectGossipAvailableQuest = function(index)
				--print("GAVAILABLE", index)
				currentqid = index
				currentqm = 2
				GetCurrentMode()
				return sgaq(index)
			end
		end
		local sgac = SelectGossipActiveQuest
		if sgac ==  nil then
			print("Internal Quest Text Error NAtive")
		else
			SelectGossipActiveQuest = function(index)
				--print("GAVAILABLE", index)
				currentqid = index
				currentqm = 3
				GetCurrentMode()
				return sgac(index)
			end
		end
		--[[local sgo = SelectGossipOption
		if sgo ==  nil then
			print("Internal Quest Text Error NAtive")
		else
			SelectGossipOption = function(index)
				--print("GOSSIP", index)
				currentqid = 1
				currentqm = -1
				GetCurrentMode()
				return sgo(index)
			end
		end]]
		--InjectPrint("CloseGossip")
			--print("TEST")
			
			
			
			
		local qisdt = QUEST_TEMPLATE_DETAIL.elements[4]
		if qisdt == nil then
			print("Internal Quest Text Error")
		else
			QuestInfo_ShowDescriptionText = function(contentWidth)
				
				--frame:GetScript("OnEvent")(frame, "QUEST_DETAIL")
			--	print("SHOWN")
				--print("SHOWN")
				qf_prog = 0
				qf_prog2 = 0
				qf_done = 0
				if current_mode == 1 or current_mode == 3 then
				qf_prog = 0
				qf_prog_old = -2
				qf_doprog = 1
				qf_prog2 = 0
				qf_done = 0
				else
					if current_mode == 0 then
					qf_prog = 1
					qf_prog2 = 1
					else
						if current_mode == 2 then
							qf_doprog2 = 1
							qf_doprog = 0
						end
					end
				end
				--frame:SetScript("OnUpdate", fupd)
				return qisdt(contentWidth)
			end
			QUEST_TEMPLATE_DETAIL.elements[4] = QuestInfo_ShowDescriptionText
		end
		local qisot = QUEST_TEMPLATE_DETAIL.elements[10]
		if qisot == nil then
			print("Iternal Quest Text Error")
		else
			--QuestInfo_ShowObjectivesText = function(contentWidth)
			--	if qf_done == 1 and qf_doprog == 0 then
			--		qf_prog2 = 0
			--		qf_doprog2 = 1
			--	end
			--	return qisot(contentWidth)
			--end
			--QUEST_TEMPLATE_DETAIL.elements[10] = QuestInfo_ShowObjectivesText
		end
		
		local OnUpdate_old = QuestInfoFrame:GetScript("OnUpdate")
			frame:SetScript("OnUpdate", fupd)
		local OnHide_old = QuestInfoFrame:GetScript("OnHide")
			QuestInfoFrame:SetScript("OnHide", function(self, ...)
				if OnHide_old then
					OnHide_old()
				end
				qf_doprog = 0
				qf_prog = 0
			end)
			
	end
end)

SLASH_SQT1, SLASH_SQT2, SLASH_SQT3 = "/sqt", "/questtext", "/scrollingquesttext"
SlashCmdList.SQT = function(...)
	if ... == "config" then
		if config_frame:IsVisible() then
			config_frame:Hide()
		else
			config_frame:Show()
		end
	elseif ... == "shownow" then
		qf_prog = qf_width
	else
		print("Use |cffffff00/sqt config|r to open the configuration or |cffffff00/sqt shownow|r to show all the quest details now (you can add it to a macro).")
	end
end