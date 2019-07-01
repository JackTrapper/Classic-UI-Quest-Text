local frame = CreateFrame("FRAME")
frame:Show()
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")
local qf_prog = 0
local qf_width = 0
local qf_doprog
local qf_prog_old = 0
local qf_prog2 = 1
local qf_doprog2 = 0
local qf_done = 1
local sounds = {"Sound/Interface/WriteQuestA.ogg", "Sound/Interface/WriteQuestB.ogg", "Sound/Interface/WriteQuestC.ogg"}
local fupd = function(self, arg)
				--if OnUpdate_old ~= nil then
				--	OnUpdate_old()
				--end
				--print("UPDATE")
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
				if qf_done == 1 then
				QuestInfoTitleHeader:SetAlpha(qf_prog2)
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
						--self:SetScript("OnUpdate", nil)
					end
					
					--end
				end
			end
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "QUEST_DETAIL" then
		--if QuestInfoFrame:IsVisible() then
			
			qf_prog = 0
			qf_doprog = 1
		--end
	end
	if event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
		qf_prog2 = 0
		qf_doprog2 = 1
		qf_done = 1
	end
	if event == "ADDON_LOADED" and ... == "QuestText" then
		local qisdt = QUEST_TEMPLATE_DETAIL.elements[4]
		if qisdt == nil then
			print("Internal Quest Text Error")
		else
			QuestInfo_ShowDescriptionText = function(contentWidth)
				
				--frame:GetScript("OnEvent")(frame, "QUEST_DETAIL")
			--	print("SHOWN")
				qf_prog = 0
				qf_prog_old = -2
				qf_doprog = 1
				qf_prog2 = 0
				qf_done = 0
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