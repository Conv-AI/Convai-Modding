local TargetingHelper = require('TargetingHelper')
local AIControl = require('AIControl')
local Cron = require('Cron')
local GameHUD = require('GameHUD')

local flag = false
local maleCharacterIds = {
    "616c376a-accb-11ee-8de5-42010a40000f"
}
local femaleCharacterIds = {
    "9c87b202-accb-11ee-901a-42010a40000f"
}

local characterIdMapping
local sessionIdMapping
local action = "None"
local npc_detected = false
local mod_called = false
local audio_flag = false
local character_present = false
local dialogue = ""
local user_entered_dialogue = false
local text_mod_called = false

local function getCharacterId(gender, name)

    local characterId = characterIdMapping[name]

    if characterId then
		print("Character is in the character table")
        return characterId
    else
		print("Character is not in the character table")
        if gender == 'M' then
            return maleCharacterIds[math.random(1, #maleCharacterIds)]
        else
            return femaleCharacterIds[math.random(1, #femaleCharacterIds)]
        end
    end
end

local function getSessionId(name)

    local sessionId = sessionIdMapping[name]
	
    if sessionId then
		print("Character is in the session table")
		character_present = true
        return sessionId
    else
		character_present = false
		print("Character is not in the session table")
        return ""
    end
end

-- onDraw
registerForEvent('onDraw', function()
    
	if mod_called and not npc_detected then
		mod_called = false
		npc_detected = false
		GameHUD.ShowWarning("NPC Not Detected", 5)
    end

	if mod_called and npc_detected and text_mod_called and ImGui.Begin('Press your cyber engine tweaks overlay key to interact with this.') then
        ImGui.SetWindowSize(700, 200)
        ImGui.Text('Enter your dialogue')
        text, selected = ImGui.InputTextMultiline("", "", 1000, 600, 50)

        if text ~= "" then
            dialogue = text
        end

        clicked = ImGui.Button("Send", 100, 50)
        if clicked then
            user_entered_dialogue = true
			text_mod_called = false
			mod_called = false
			npc_detected = false
        end

    end

    ImGui.End()

end)

function tryChangingAttitudeToHostile(npc, targetNpc)
    if not IsDefined(npc) then return end
    if not IsDefined(targetNpc) then return end
    local attitudeOwner = npc:GetAttitudeAgent();
    local attitudeTarget = targetNpc:GetAttitudeAgent();
    attitudeOwner:SetAttitudeTowardsAgentGroup(attitudeTarget, attitudeOwner, EAIAttitude.AIA_Hostile);
end;

local function main()

	mod_called = true

	local Character = TargetingHelper.GetLookAtTarget()

	if Character and Character:IsNPC() then

		npc_detected = true

		local CharacterName = tostring(Character:GetTweakDBFullDisplayName(true)):gsub("%s", ""):gsub("%.", "")
		print(CharacterName)

		local CharacterGender = tostring(Character:GetBodyType())
		print(CharacterGender)
		
		-- Extracting the part after the last '--[[ ' and before ' --]]'
		local CharacterGender = string.match(CharacterGender, '%-%-%[%[ (.-) %-%-%]%]')
		print("Extracted Character Gender: ", CharacterGender)

        -- Simplify the gender output 
        if string.find(CharacterGender:lower(), "woman") then
            CharacterGender = "F"
        elseif string.find(CharacterGender:lower(), "man") then
            CharacterGender = "M"
        else
            CharacterGender = "unknown" -- or handle other cases as needed
        end

        print("Simplified Gender: ", CharacterGender)

		user_dialogue_container = true
		if user_dialogue_container and text_mod_called then
			local keepgoing = true

			local function user_dialogue_checker()
				if user_entered_dialogue then
					keepgoing = false
					user_entered_dialogue = false
				end
			end
		
			local checking_interval = 1
			local total_seconds_so_far = 0
		
			local function user_dialogue_wait()
				Cron.After(checking_interval, function()
					print(total_seconds_so_far .. " seconds over")
					user_dialogue_checker()
					
					if keepgoing and total_seconds_so_far < 600 then
						total_seconds_so_far = total_seconds_so_far + 1
						user_dialogue_wait()
					else
						print("user entered dialogue after  " .. total_seconds_so_far .. " seconds")
						print(dialogue)
						GameHUD.ShowMessage(string.format("You: %s", dialogue))
						local file = io.open("convai\\user_dialogue.txt", "w")
						if file then
							file:write(dialogue)
							file:close()
						end
						flag = true
						if flag then
							print("sending signal to convai exe")
							local controlfilePath = "convai\\control.txt"
							local controlfile = io.open(controlfilePath, "w")
							if controlfile then
								controlfile:write("start")
								controlfile:close()
								print("start written to file.")
							else
								print("Failed to open the control file for writing.")
							end
							flag = false
						end
						print("convai exe execution started")
					end
				end)
			end
			
			user_dialogue_wait()
		end
		
		local selectedCharacterId = getCharacterId(CharacterGender, CharacterName)
		local selectedSessionId = getSessionId(CharacterName)
		print(string.format("Selected Character ID: %s", selectedCharacterId))
		print(string.format("Selected Session ID: %s", selectedSessionId))

		-- Read API key from api_key.txt
		local apiKeyFilePath = "convai\\api_key.txt"
		local apiKeyFile = io.open(apiKeyFilePath, "r")

		if apiKeyFile then
			local apiKey = apiKeyFile:read("*a")
			apiKeyFile:close()

			local filePath = "convai\\get_response_config_example.txt"
			--actions: "Physical Actions which can include eating, going somewhere, or anything"
			-- if actions not working, try explictly telling them to perform actions
			local fileContent = string.format([[
			character_id: "%s"
			api_key: "%s"
			audio_config {
				sample_rate_hertz: 44100
			}
			action_config {
				actions: "Join"
				actions: "Follow"
				actions: "Leave"
				actions: "Move To Location"
				actions: "Distract"

				characters {
					name: "Player"
					bio: "A mercenary named V in Night City, the character's must follow V's instructions."
				}

				classification: "multistep"
			}
			]], selectedCharacterId, apiKey)

			local file = io.open(filePath, "w")
			if file then
				file:write(fileContent)
				file:close()
				print("Character ID written to file.")
			else
				print("Failed to open the get_response_config_example file for writing.")
			end

			local sessionIdfileContent = string.format([[%s]], selectedSessionId)
			local sessionIdfilePath = "convai\\session.txt"
			local sessionIdfile = io.open(sessionIdfilePath, "w")
			if sessionIdfile then
				sessionIdfile:write(sessionIdfileContent)
				sessionIdfile:close()
				print("Session ID written to file.")
			else
				print("Failed to open the session file for writing.")
			end

			if audio_flag then
				flag = true
				if flag then
					print("sending signal to convai exe")
					local controlfilePath = "convai\\control.txt"
					local controlfile = io.open(controlfilePath, "w")
					if controlfile then
						controlfile:write("start")
						controlfile:close()
						print("start written to file.")
					else
						print("Failed to open the control file for writing.")
					end
					flag = false
				end
				print("convai exe execution started")
			end

			if audio_flag then

				local keepgoing = true
				local speakFilePath = "convai\\speak.txt"
					
				local function speak_checker()
					local speakFile = io.open(speakFilePath, "r")
					if speakFile then
						local speakFileText = speakFile:read("*a")
						speakFile:close()
						local speakcheck = string.find(speakFileText, "speak")
						if speakcheck then
							keepgoing = false
						end
					end
				end

				local checking_interval = 1
				local total_seconds_so_far = 0
			
				local function waitforspeak()
					Cron.After(checking_interval, function()
						print(total_seconds_so_far .. " seconds over")
						speak_checker()
						
						if keepgoing and total_seconds_so_far < 600 then
							total_seconds_so_far = total_seconds_so_far + 1
							waitforspeak()
						else
							print("speak present in speak.txt after  " .. total_seconds_so_far .. " seconds")
							GameHUD.ShowMessage('Speak Now')
							local file = io.open(speakFilePath, "w")
							if file then
								file:write("")
								file:close()
							end
						end
					end)
				end
				
				waitforspeak()

			end

			local responseFilePath = "convai\\response.txt"
			local userkeepgoing = true
			local user_dialogue_exists = true

			local function displayuserdialogue()
				local checking_interval = 1
				local total_seconds_so_far = 0
				local user_dialogue = ""

				local function waitdisplayuserdialogue()
					Cron.After(checking_interval, function()
						print(total_seconds_so_far .. " seconds over")

						local file = io.open("convai\\user_dialogue.txt", "r")
						if file then
							user_dialogue = file:read("*a")
							file:close()
						end

						if userkeepgoing and total_seconds_so_far < 600 and user_dialogue ~= "" then
							userkeepgoing = false
            			end

						if userkeepgoing then
							total_seconds_so_far = total_seconds_so_far + 1
							waitdisplayuserdialogue()
						else
							if user_dialogue_exists then
								GameHUD.ShowMessage(string.format("You: %s", user_dialogue))
								print("displaying user dialogue after " .. total_seconds_so_far .. " seconds")
								local file = io.open("convai\\user_dialogue.txt", "w")
								if file then
									file:write("")
									file:close()
								end
							end
						end
					end)
				end
				
				waitdisplayuserdialogue()
			end

			if audio_flag then
				displayuserdialogue()
				audio_flag = false
				mod_called = false
				npc_detected = false
			end

			local function main()
				user_dialogue_exists = false
				userkeepgoing = false

				local file = io.open("convai\\user_dialogue.txt", "w")
				if file then
					file:write("")
					file:close()
				end

				local responseFile = io.open(responseFilePath, "r")
				local responseText = responseFile:read("*a")
				responseFile:close()

				responseFile = io.open(responseFilePath, "w")
				if responseFile then
					responseFile:write("")
					responseFile:close()
				end

				sessionIdfile = io.open(sessionIdfilePath, "r")
				if sessionIdfile then   
					local sessionIdText = sessionIdfile:read("*a")
					sessionIdfile:close()
					if character_present then
						sessionIdMapping[CharacterName] = sessionIdText
					end
				end

				-- Find the position of "Action:" and "Bot:"
				local actionIndex = string.find(responseText, "Action:")
				local botIndex = string.find(responseText, "Bot:")

				if actionIndex then
					-- Extract bot response and action
					local botResponse = nil
					if botIndex then
						botResponse = string.sub(responseText, botIndex + 4, actionIndex - 1)
					else
						botResponse = string.sub(responseText, 0, actionIndex - 1)
					end
					local actionText = string.sub(responseText, actionIndex + 7)  

					-- Remove extra newlines
					botResponse = string.gsub(botResponse, "\n+", "")
					action = string.gsub(actionText, "\n+", "")

					print(string.format("Bot Response: %s", botResponse))
					print(string.format("Action: %s", actionText))

					GameHUD.ShowMessage(string.format("%s: %s ", tostring(Character:GetTweakDBFullDisplayName(true)), botResponse))
					
					-- handle actions, if action is none then return
					if string.find(action:lower(), "none") then
						return 0
					elseif string.find(action:lower(), "follow") or string.find(action:lower(), "join") then
						print("selected follow action")
						AIControl.InterruptCombat(Character)
						AIControl.MakeFollower(Character)
						companion = Character
					elseif string.find(action:lower(), "leave") then
						print("selected leave action")
						AIControl.InterruptCombat(Character)
						AIControl.FreeFollower(Character)
					elseif string.find(action:lower(), "move") then
						print("selected move action")
						local movePosition = TargetingHelper.GetLookAtPosition()				
						local player = Game.GetPlayer()
						local moveOffsetX, moveOffsetY = 0, 0.5						
						target = Character
						if not AIControl.HasQueue(target) then
							AIControl.InterruptBehavior(target)
						end
						local pinPosition = ToVector4(movePosition)
						TargetingHelper.MarkPosition(pinPosition)
						AIControl.QueueTask(target, function()
							AIControl.LookAt(target, player)
				
							return AIControl.MoveTo(target, movePosition)
						end)
						AIControl.QueueTask(target, function()
							TargetingHelper.UnmarkPosition(pinPosition)
				
							return AIControl.RotateTo(target, player:GetWorldPosition())
						end)
						AIControl.QueueTask(target, function()
							return AIControl.HoldFor(target, 1.0)
						end)
						AIControl.QueueTask(target, function()
							AIControl.StopLookAt(target)
						end)
						movePosition.x = movePosition.x + moveOffsetX
						movePosition.y = movePosition.y + moveOffsetY
				
						moveOffsetX, moveOffsetY = moveOffsetY, moveOffsetX
					elseif string.find(action:lower(), "distract") then
						print("selected distract action")
						local targetNpc = TargetingHelper.GetLookAtTarget()
						tryChangingAttitudeToHostile(Character, targetNpc);
						TargetTrackingExtension.InjectThreat(Character, targetNpc);
						AIActionHelper.TryStartCombatWithTarget(Character, targetNpc);
					else
						print(string.format("Action handling logic is not present for %s ", action:lower()))
					end

				else
					print("No 'Action:' found in response.")
					action = "None"
				end
			end

			local actionIndexcheck 
			local keepgoing = true

			local function actionchecker()
				local responseFilecheck = io.open(responseFilePath, "r")
				if responseFilecheck then
					local responseTextcheck = responseFilecheck:read("*a")
					responseFilecheck:close()
					actionIndexcheck = string.find(responseTextcheck, "Action:")
					if actionIndexcheck then
						keepgoing = false
					end
				end
			end

			local checking_interval = 1
			local total_seconds_so_far = 0

			local function waitexecuteaction()
				Cron.After(checking_interval, function()
					print(total_seconds_so_far .. " seconds over")
					actionchecker()
					
					if keepgoing and total_seconds_so_far < 600 then
						total_seconds_so_far = total_seconds_so_far + 1
						waitexecuteaction()
					else
						print("main.exe finished after " .. total_seconds_so_far .. " seconds")
						main()
					end
				end)
			end
			
			waitexecuteaction()

		else
			print("Failed to read the API key file.")
		end
	end

end

registerHotkey('TalkMic', 'Talk to NPCs with Microphone', function()

	audio_flag = true

	print("Player talking via Microphone")
	local inputMethodFilePath = "convai\\user_method_of_input.txt"
	local inputMethodFile = io.open(inputMethodFilePath, "w")
	if inputMethodFile then
		inputMethodFile:write("audio")
		inputMethodFile:close()
	end

	main()

end)

registerHotkey('TalkType', 'Talk to NPCs with Keyboard', function()

	print("Player talking via Keyboard")
	local inputMethodFilePath = "convai\\user_method_of_input.txt"
	local inputMethodFile = io.open(inputMethodFilePath, "w")
	if inputMethodFile then
		inputMethodFile:write("text")
		inputMethodFile:close()
	end

	text_mod_called = true

	main()

end)

registerForEvent('onInit', function()

	-- Free follower when NPC is detached
	Observe('ScriptedPuppet', 'OnDetach', function(self)
		if self and self:IsA('NPCPuppet') then
			TargetingHelper.UnmarkTarget(self)
			AIControl.FreeFollower(self)
		end
	end)

	-- Maintain the correct state on session end
	Observe('QuestTrackerGameController', 'OnUninitialize', function()
		if Game.GetPlayer() == nil then
			TargetingHelper.Dispose()
			AIControl.Dispose()
		end
	end)
end)

-- Maintain the correct state on "Reload All Mods"
registerForEvent('onShutdown', function()
	TargetingHelper.Dispose()
	AIControl.Dispose()
	local controlfilePath = "convai\\control.txt"
	local controlfile = io.open(controlfilePath, "w")
	if controlfile then
		controlfile:write("exit")
		controlfile:close()
		print("exit written to file.")
	else
		print("Failed to open the control file for writing.")
	end
end)

registerForEvent('onUpdate', function(delta)
	AIControl.UpdateTasks(delta)
	Cron.Update(delta)
end)

characterIdMapping = {
	ViktorVektor = "1ba8638a-cd8b-11ee-ba24-42010a40000f",
	RogueAmendiares = "e25f741c-cd74-11ee-ba24-42010a40000f",
	JohnnySilverhand = "a9dad842-cd57-11ee-ae44-42010a40000f",
	AdamSmasher = "d5daba4e-cd65-11ee-b316-42010a40000f",
	AndersHellman = "7348b254-cd66-11ee-9557-42010a40000f",
	AuroreCassel = "d847a796-cd66-11ee-b1fa-42010a40000f",
	AymericCassel = "126da2a4-cd67-11ee-bcd5-42010a40000f",
	BlueMoon = "6fcbee56-cd67-11ee-9557-42010a40000f",
	MamanBrigitte = "dcedb442-cd67-11ee-ae44-42010a40000f",
	BryceMosley = "0bcfc9f8-cd68-11ee-9557-42010a40000f",
	AaronMcCarlson = "aed17c28-cd63-11ee-af69-42010a40000f",
	CarolEmeka = "8c95206e-cd69-11ee-bab6-42010a40000f",
	CassidyRighter = "c6075b50-cd69-11ee-89ad-42010a40000f",
	ClaireRussell = "2c7d38dc-cd6a-11ee-ba24-42010a40000f",
	DakotaSmith = "8b112d40-cd6a-11ee-bab6-42010a40000f",
	Delamain = "fa1a72e6-cd6a-11ee-bab6-42010a40000f",
	Denny = "281919cc-cd6b-11ee-8080-42010a40000f",
	DexterDeShawn = "5c705f14-cd6b-11ee-8080-42010a40000f",
	DinoDinovic = "8739f854-cd6b-11ee-ba24-42010a40000f",
	DumDum = "d000d72e-cd6b-11ee-ba24-42010a40000f",
	ElizabethPeralez = "524ba90c-cd6c-11ee-ae44-42010a40000f",
	EmmerickBronson = "84df5d78-cd6c-11ee-bab6-42010a40000f",
	EvelynParker = "ce3e5514-cd6c-11ee-ae44-42010a40000f",
	Takemura = "4a8689e8-cd6d-11ee-bab6-42010a40000f",
	HanakoArasaka = "82c1be22-cd6d-11ee-ae44-42010a40000f",
	JackieWelles = "dcd2c186-cd6d-11ee-8080-42010a40000f",
	JeffersonPeralez = "07bcdfd0-cd6e-11ee-ae44-42010a40000f",
	JudyÁlvarez = "9679f49c-cd6e-11ee-8080-42010a40000f",
	KerryEurodyne = "ef209786-cd6e-11ee-b316-42010a40000f",
	KirkSawyer = "42b8528a-cd6f-11ee-ba24-42010a40000f",
	KurtHansen = "6f85f34e-cd6f-11ee-9279-42010a40000f",
	LinaMalina = "982a8ca6-cd6f-11ee-ba24-42010a40000f",
	ElisabethWissenfurth = "fb3eb484-cd6f-11ee-8080-42010a40000f",
	MateoThiago = "3a953eb4-cd70-11ee-89ad-42010a40000f",
	MeredithStout = "60b1a60a-cd70-11ee-a1f3-42010a40000f",
	MitchAnderson = "cce4f318-cd70-11ee-aff0-42010a40000f",
	MistyOlszewski = "23002290-cd71-11ee-bab6-42010a40000f",
	MuamarReyes = "4ada46f6-cd71-11ee-b316-42010a40000f",
	OzobBozo = "8a3dc17e-cd71-11ee-ba24-42010a40000f",
	OswaldForrest = "b8b88494-cd71-11ee-ae44-42010a40000f",
	PanamPalmer = "daf3a55a-cd73-11ee-ae44-42010a40000f",
	PepeNajarro = "2c5df558-cd74-11ee-aff0-42010a40000f",
	RachelCasich = "5dc7a468-cd74-11ee-ba24-42010a40000f",
	RiverWard = "9f324b92-cd74-11ee-bab6-42010a40000f",
	RosalindMyers = "246c8e12-cd75-11ee-a8b3-42010a40000f",
	Songbird = "087d8b10-cd76-11ee-ae44-42010a40000f",
	SolomonReed = "623e51de-cd76-11ee-ae44-42010a40000f",
	SebastianIbarra = "ad76a124-cd76-11ee-8080-42010a40000f",
	SaulBright = "e45cb00c-cd76-11ee-af69-42010a40000f",
	RobertWilson = "0d6404e6-cd77-11ee-8080-42010a40000f",
	RitaWheeler = "41101366-cd77-11ee-ba24-42010a40000f",
	ReginaJones = "9baf169e-cd79-11ee-af69-42010a40000f",
	Placide = "c4bbd950-cd79-11ee-b316-42010a40000f",
	WakakoOkada = "f957f22a-cd79-11ee-a8b3-42010a40000f",
	MrHands = "07644858-cd95-11ee-ae44-42010a40000f",
}

sessionIdMapping = {
	ViktorVektor = "",
	RogueAmendiares = "",
	JohnnySilverhand = "",
	AdamSmasher = "",
	AndersHellman = "",
	AuroreCassel = "",
	AymericCassel = "",
	BlueMoon = "",
	MamanBrigitte = "",
	BryceMosley = "",
	AaronMcCarlson = "",
	CarolEmeka = "",
	CassidyRighter = "",
	ClaireRussell = "",
	DakotaSmith = "",
	Delamain = "",
	Denny = "",
	DexterDeShawn = "",
	DinoDinovic = "",
	DumDum = "",
	ElizabethPeralez = "",
	EmmerickBronson = "",
	EvelynParker = "",
	Takemura = "",
	HanakoArasaka = "",
	JackieWelles = "",
	JeffersonPeralez = "",
	JudyÁlvarez = "",
	KerryEurodyne = "",
	KirkSawyer = "",
	KurtHansen = "",
	LinaMalina = "",
	ElisabethWissenfurth = "",
	MateoThiago = "",
	MeredithStout = "",
	MitchAnderson = "",
	MistyOlszewski = "",
	MuamarReyes = "",
	OzobBozo = "",
	OswaldForrest = "",
	PanamPalmer = "",
	PepeNajarro = "",
	RachelCasich = "",
	RiverWard = "",
	RosalindMyers = "",
	Songbird = "",
	SolomonReed = "",
	SebastianIbarra = "",
	SaulBright = "",
	RobertWilson = "",
	RitaWheeler = "",
	ReginaJones = "",
	Placide = "",
	WakakoOkada = "",
	MrHands = "",
}