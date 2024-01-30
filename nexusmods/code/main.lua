-- Function to calculate the distance between two locations
function CalculateDistance(location1, location2)
    local deltaX = location1.X - location2.X
    local deltaY = location1.Y - location2.Y
    local deltaZ = location1.Z - location2.Z
    return math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
end

-- Function to find the nearest character to the player
function FindNearestCharacter()
    local BipedPlayer = FindFirstOf("Biped_Player")
    local PlayerLocation = BipedPlayer:K2_GetActorLocation()

    local ActorInstances = FindAllOf("NPC_Character")
    local nearestCharacter = nil
    local nearestDistance = math.huge
    local nearestCharactergender =  'M'
    local nearestCharacterName = nil
    local gender = 'M'
    local genderflag = false

    for Index, ActorInstance in pairs(ActorInstances) do
        if ActorInstance:IsValid() and ActorInstance:GetFullName() ~= BipedPlayer:GetFullName() then
            local ActorLocation = ActorInstance:K2_GetActorLocation()
            local objectStateInfo = ActorInstance:GetObjectStateInfo()
            if objectStateInfo and type(objectStateInfo.GetDbGenderId) == "function" then
                gender = objectStateInfo:GetDbGenderId()
                genderflag = true
            end

            local distance = CalculateDistance(PlayerLocation, ActorLocation)

            if distance < nearestDistance then
                nearestCharacter = ActorInstance
                nearestDistance = distance
                if genderflag then
                    nearestCharactergender = gender:ToString()
                    genderflag = false
                end
            end
        end
    end

    if nearestCharacter then
        -- print(string.format("Nearest Character: %s", nearestCharacter:GetFullName()))
        -- print(string.format("Distance: %.2f", nearestDistance))
        -- print(string.format("Gender: %s", nearestCharactergender))
        local PhoenixBPLibrary = StaticFindObject("/Script/Phoenix.Default__PhoenixBPLibrary")
        if PhoenixBPLibrary:IsValid() then
            nearestCharacterName = PhoenixBPLibrary:GetActorName(nearestCharacter):ToString()
            print(string.format("Nearest Character Name: %s", nearestCharacterName))
        end
    else
        print("No valid characters found.")
    end
    
    return nearestCharactergender, nearestCharacterName
end


local flag = false
local maleCharacterIds = {
    "3bceba74-9b6d-11ee-9bda-42010a40000f"
}
local femaleCharacterIds = {
    "5424fce6-9b6d-11ee-bcdf-42010a40000f"
}

local characterIdMapping
local sessionIdMapping
local action = "None"

local function getCharacterId(gender, name)
    local lowercaseName = string.lower(name)
    
    for key, value in pairs(characterIdMapping) do
        if string.lower(key) == lowercaseName then
            return value
        end
    end

    if gender == 'M' then
        return maleCharacterIds[math.random(1, #maleCharacterIds)]
    else
        return femaleCharacterIds[math.random(1, #femaleCharacterIds)]
    end
end

local function getSessionId(name)
    local lowercaseName = string.lower(name)

    for key, value in pairs(sessionIdMapping) do
        if string.lower(key) == lowercaseName then
            return value
        end
    end

    return ""
end

RegisterCustomEvent("actionfunction", function(Context, Output)
        local output = action
        action = "None"
        Output:set(output)
end)


RegisterCustomEvent("printstringevent", function(Context, Param1)
    local P1 = Param1:get()
    print(string.format("\n<BPMod>\n%s\n</BPMod>", P1:ToString()))
end)

function closeLips(mymod)
    -- Set all blendshape values to zero to close the lips
    mymod:setblendshape('lwr_lip_funl_l', 0)
    mymod:setblendshape('lwr_lip_funl_r', 0)
    mymod:setblendshape('upr_lip_funl_r', 0)
    mymod:setblendshape('upr_lip_funl_l', 0)
    mymod:setblendshape('jaw_drop', 0)
    mymod:setblendshape('lips_up_l', 0)
    mymod:setblendshape('lwr_lip_dn_l', 0)
    mymod:setblendshape('lwr_lip_dn_r', 0)
    mymod:setblendshape('dimple_l', 0)
    mymod:setblendshape('dimple_r', 0)
    mymod:setblendshape('smile_l', 0)
    mymod:setblendshape('smile_r', 0)
    mymod:setblendshape('mouth_mov_r', 0)
    mymod:setblendshape('mouth_mov_l', 0)
    mymod:setblendshape('lips_up_r', 0)
end

function randomnumber(lowerBound, upperBound)
    return  lowerBound + math.random() * (upperBound - lowerBound)
end

function moveLipsWithTime(mymod)
    local time = os.clock()  -- Get the current time

    -- Parameters
    local commonoscillationRange = 0.2  -- common value for how far the blendshapes can move
    local frequency = 0.6  -- the speed at which they move

    -- Calculate blendshape values using sine function, take absolute value, and add random factor
    local lwr_lip_funl_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local lwr_lip_funl_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local upr_lip_funl_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local upr_lip_funl_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local jaw_drop = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time))  + randomnumber(0, 0.05)
    local lips_up_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time))  + randomnumber(0, 0.05)
    local lwr_lip_dn_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time))  + randomnumber(0, 0.05)
    local lwr_lip_dn_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time))  + randomnumber(0, 0.05)
    local dimple_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time))  + randomnumber(0, 0.05)
    local dimple_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time))  + randomnumber(0, 0.05)
    local smile_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local smile_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local mouth_mov_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local mouth_mov_l = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)
    local lips_up_r = commonoscillationRange * math.abs(math.sin(2 * math.pi * frequency * time)) + randomnumber(0, 0.05)

    -- Set blendshape values
    mymod:setblendshape('lwr_lip_funl_l', lwr_lip_funl_l)
    mymod:setblendshape('lwr_lip_funl_r', lwr_lip_funl_r)
    mymod:setblendshape('upr_lip_funl_r', upr_lip_funl_r)
    mymod:setblendshape('upr_lip_funl_l', upr_lip_funl_l)
    mymod:setblendshape('jaw_drop', jaw_drop)
    mymod:setblendshape('lips_up_l', lips_up_l)
    mymod:setblendshape('lwr_lip_dn_l', lwr_lip_dn_l)
    mymod:setblendshape('lwr_lip_dn_r', lwr_lip_dn_r)
    mymod:setblendshape('dimple_l', dimple_l)
    mymod:setblendshape('dimple_r', dimple_r)
    mymod:setblendshape('smile_l', smile_l)
    mymod:setblendshape('smile_r', smile_r)
    mymod:setblendshape('mouth_mov_r', mouth_mov_r)
    mymod:setblendshape('mouth_mov_l', mouth_mov_l)
    mymod:setblendshape('lips_up_r', lips_up_r)
end

local function sleep(seconds)
    local start = os.clock()
    repeat until os.clock() > start + seconds
end

local count = 0

RegisterKeyBind(Key.F7, {}, function()
    ExecuteAsync(function()

        print("===============================================")
        print("Convai Mod Interaction Started")
        local mymod = FindFirstOf("ModActor_C")
        
        local gender, name = FindNearestCharacter()
        if gender == "M" or gender == "F" then
            
            -- updating who the nearest character is so that setblendshape moves the lips of the correct character
            mymod:findnearestcharacter()

            -- Fix for lipsync not playing sometimes
            count = count + 1
            if count % 3 == 0 then
                mymod:resetcharacter()
            end

            local selectedCharacterId = getCharacterId(gender, name)
            local selectedSessionId = getSessionId(name)
            print(string.format("Selected Character ID: %s", selectedCharacterId))
            print(string.format("Selected Session ID: %s", selectedSessionId))

            -- Read API key from api_key.txt
            local apiKeyFilePath = "convai\\api_key.txt"
            local apiKeyFile = io.open(apiKeyFilePath, "r")

            if apiKeyFile then
                local apiKey = apiKeyFile:read("*a")
                apiKeyFile:close()

                local filePath = "convai\\get_response_config_example.txt"
                local fileContent = string.format([[
                character_id: "%s"
                api_key: "%s"
                audio_config {
                    sample_rate_hertz: 44100
                }
                action_config {
                    actions: "Join"
                    actions: "Leave"
                    actions: "Follow"
                    actions: "Stop Walking"
                    actions: "Move To Location"
                    
                    objects {
                        name: "Wand"
                        description: "A wand that can do magic."
                    }

                    characters {
                        name: "Player"
                        bio: "A wizard, He will ask you to follow him, stop and wait at a location until he tells you to follow him again or leave, move to a certain location, leave him or join him on adventure."
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
                    print("Failed to open the file for writing.")
                end

                local sessionIdfileContent = string.format([[%s]], selectedSessionId)
                local sessionIdfilePath = "convai\\session.txt"
                local sessionIdfile = io.open(sessionIdfilePath, "w")
                if sessionIdfile then
                    sessionIdfile:write(sessionIdfileContent)
                    sessionIdfile:close()
                    print("Session ID written to file.")
                else
                    print("Failed to open the file for writing.")
                end

                flag = true
                if flag then
                    local directory = "convai"
                    os.execute('cd "' .. directory .. '" && start /B main.exe')
                    flag = false
                end

                sessionIdfile = io.open(sessionIdfilePath, "r")
                if sessionIdfile then   
                    local sessionId = sessionIdMapping[name]
                    if sessionId then
                        local sessionIdText = sessionIdfile:read("*a")
                        sessionIdfile:close()
                        sessionIdMapping[name] = sessionIdText
                    end
                end

                local responseFilePath = "convai\\response.txt"

                local lipsyncstart = false
                local lipsyncfilepath = "convai\\lipsync.txt"

                while true do

                    if lipsyncstart then
                        moveLipsWithTime(mymod)
                        sleep(0.1)  -- Sleep for 0.1 seconds before updating again
                    else
                        local lipsyncfile = io.open(lipsyncfilepath, "r")
                        if lipsyncfile then
                            local lipsynctext = lipsyncfile:read("*a")
                            lipsyncfile:close()
                            local lipsyncstartindex = string.find(lipsynctext, "start")
                            if lipsyncstartindex then
                                lipsyncstart = true
                            end
                        end
                    end
                            

                    local responseFile = io.open(responseFilePath, "r")
                    if responseFile then
                        local responseText = responseFile:read("*a")
                        responseFile:close()
                        local actionIndex = string.find(responseText, "Action:")
                        if actionIndex then
                            closeLips(mymod)
                            print("Stopping lipsync")
                            break
                        end                      
                    end
                end

                local responseFile = io.open(responseFilePath, "r")
                

                if responseFile then

                    local responseText = responseFile:read("*a")
                    responseFile:close()

                    local actionIndex = string.find(responseText, "Action:")
                    local botIndex = string.find(responseText, "Bot:")

                    
                    if actionIndex then

                        responseFile = io.open(responseFilePath, "w")

                        if responseFile then
                            responseFile:close()
                            print("Response file cleared.")
                        else
                            print("Failed to open the response file for clearing.")
                        end

                        local lipsyncfile = io.open(lipsyncfilepath, "w")
                        if lipsyncfile then
                            lipsyncfile:close()
                            print("lipsync file cleared.")
                        else
                            print("Failed to open the lipsync file for clearing.")
                        end

                        -- Extract bot response and action
                        local botResponse = nil
                        if botIndex then
                            botResponse = string.sub(responseText, botIndex + 4, actionIndex - 1)
                        else
                            botResponse = string.sub(responseText, 0, actionIndex - 1)
                        end

                        action = string.sub(responseText, actionIndex + 7)  

                        botResponse = string.gsub(botResponse, "\n+", "")
                        action = string.gsub(action, "\n+", "")

                        print(string.format("Bot Response: %s", botResponse))
                        print(string.format("Action: %s", action))

                        local UIManager = FindFirstOf("UIManager")
                        local FTutorialLayoutData = {
                            ["Position"] = {
                                ["X"] = 500,
                                ["Y"] = 500
                            },
                            ["Alignment"] = {
                                ["X"] = 500,
                                ["Y"] = 500
                            }
                        }

                        UIManager:SetAndShowHintMessage(botResponse, FTutorialLayoutData, true, 10)

                        mymod:actionexecute()
                    end

                else
                    print("Failed to read the response file.")
                end

            else
                print("Failed to read the API key file.")
            end

        else
            print("Invalid gender value.")
        end

        print("Convai Mod Interaction Finished")
    print("===============================================")
    end)
end)

characterIdMapping = {
    AbrahamRonen = "3eac750c-9b67-11ee-8a4e-42010a40000f",
    AdelaideOakes = "6fce0910-9cd0-11ee-bc9d-42010a40000f",
    AesopSharp = "a9b6777a-9cd0-11ee-bc9d-42010a40000f",
    AgnesCoffey = "dcf375ac-9cd0-11ee-8e12-42010a40000f",
    AlbieWeekes = "05cf8e84-9cd1-11ee-9410-42010a40000f",
    AmitKakkar = "6f2135c2-9cd1-11ee-9772-42010a40000f",
    AnneSallow = "0f362356-9cd2-11ee-8798-42010a40000f",
    AstoriaCrickett = "afabcf8e-9cd2-11ee-8798-42010a40000f",
    AugustusHill = "d280b952-9cd2-11ee-8798-42010a40000f",
    BaiHowin = "1fe09758-9cd3-11ee-b75f-42010a40000f",
    BernardNdiaye = "887ef0de-9cd3-11ee-8804-42010a40000f",
    BOH_AbrahamRonen = "3eac750c-9b67-11ee-8a4e-42010a40000f",
    CalliopeSnelling = "dd12d2b4-9cd3-11ee-8e12-42010a40000f",
    CassandraMason = "2571c6d2-9cd4-11ee-8e12-42010a40000f",
    CharlotteMorrison = "4c14d9aa-9cd4-11ee-9410-42010a40000f",
    ChiyoKogawa = "88961498-9cd4-11ee-8cba-42010a40000f",
    ClaireBeaumont = "c1477c8c-9cd4-11ee-8804-42010a40000f",
    CliffordCromwell = "ee93074c-9cd4-11ee-9109-42010a40000f",
    ConstanceDagworth = "29517166-9cd5-11ee-8e12-42010a40000f",
    CressidaBlume = "544ad524-9cd5-11ee-9772-42010a40000f",
    CrispinDunn = "7f3bf560-9cd5-11ee-8a4e-42010a40000f",
    DinahHecat = "c7f0a0da-9cd5-11ee-9410-42010a40000f",
    DuncanHobhouse = "ebd95014-9cd5-11ee-ade2-42010a40000f",
    EddieThistlewood = "1370c102-9cd6-11ee-b49c-42010a40000f",
    EdgarAdley = "3ee8193e-9cd6-11ee-9772-42010a40000f",
    EleazarFig = "a1d35a22-9cd6-11ee-8f7d-42010a40000f",
    EricNorthcott = "c068e006-9cd6-11ee-8e12-42010a40000f",
    EvangelineBardsley = "e7ca5404-9cd6-11ee-8e12-42010a40000f",
    EverettClopton = "0dca0348-9cd7-11ee-bc9d-42010a40000f",
    FatimahLawang = "43c937ac-9cd7-11ee-ade2-42010a40000f",
    GarrethWeasley = "8cb12024-9cd7-11ee-8f7d-42010a40000f",
    GerboldOllivander = "bae12cd2-9cd7-11ee-8798-42010a40000f",
    GertrudeWigley = "f39a4e0a-9cd7-11ee-8a4e-42010a40000f",
    HectorFawley = "45623ffe-9cd8-11ee-8e12-42010a40000f",
    HectorWeasley = "726149a0-9cd8-11ee-8e12-42010a40000f",
    HildaLoddington = "b2d2a786-9cd8-11ee-8e12-42010a40000f",
    ImeldaReyes = "d4b5d86e-9cd8-11ee-ade2-42010a40000f",
    IndiraWolff = "f222215a-9cd8-11ee-ade2-42010a40000f",
    JalalSehmi = "180e065e-9cd9-11ee-8e12-42010a40000f",
    LawrenceDavies = "3c9e7cec-9cd9-11ee-8798-42010a40000f",
    LeanderPrewett = "641fb6e6-9cd9-11ee-8a4e-42010a40000f",
    LeopoldBabcocke = "9a860bb8-9cd9-11ee-b75f-42010a40000f",
    LucanBrattleby = "baaae3d2-9cd9-11ee-8a4e-42010a40000f",
    MatildaWeasley = "fc94146c-9cd9-11ee-9410-42010a40000f",
    MirabelGarlick = "3ee422b2-9cda-11ee-9772-42010a40000f",
    MudiwaOnai = "7057d3fc-9cda-11ee-b75f-42010a40000f",
    NatsaiOnai = "94d23538-9cda-11ee-ade2-42010a40000f",
    NellieOggspire = "bdccd5c4-9cda-11ee-9410-42010a40000f",
    NeridaRoberts = "030592ca-9cdb-11ee-8a4e-42010a40000f",
    NoraTreadwell = "4979cfbe-9cdb-11ee-8e12-42010a40000f",
    OminisGaunt = "6b4538d6-9cdb-11ee-b75f-42010a40000f",
    PadraicHaggarty = "a1e7a7e8-9cdb-11ee-9772-42010a40000f",
    PercivalPippin = "c1499984-9cdb-11ee-8798-42010a40000f",
    PhineasBlack = "6670b7da-9cdc-11ee-8e12-42010a40000f",
    PoppySweeting = "e0c4b9dc-9cdc-11ee-8804-42010a40000f",
    PriscillaWakefield = "1eaab4b8-9cdd-11ee-8798-42010a40000f",
    PriyaTreadwell = "39da4406-9cdd-11ee-8cba-42010a40000f",
    RohanPrakash = "5fea4f88-9cdd-11ee-8804-42010a40000f",
    RuthSinger = "90c2fa38-9cdd-11ee-8e12-42010a40000f",
    SacharissaTugwood = "c21fa158-9cdd-11ee-b54b-42010a40000f",
    SamanthaDale = "e55a43f8-9cdd-11ee-8e12-42010a40000f",
    SebastianSallow = "188130ca-9cde-11ee-b75f-42010a40000f",
    Sirona = "43fba956-9cde-11ee-9410-42010a40000f",
    SolomonSallow = "647bde08-9cde-11ee-ade2-42010a40000f",
    SophroniaFranklin = "85b3593e-9cde-11ee-8e12-42010a40000f",
    ThomasBrown = "a7f15fb4-9cde-11ee-8a4e-42010a40000f",
    TimothyTeasdale = "d675b0f6-9cde-11ee-8e12-42010a40000f",
    VictorRookwood = "ff46c060-9cde-11ee-8e12-42010a40000f",
    VioletMcDowell = "221a1b00-9cdf-11ee-9772-42010a40000f",
    ZenobiaNoke = "946371f6-49e3-11ee-9db9-42010a40000b",
    NearlyHeadlessNick = "3d93f3e2-9cdf-11ee-9772-42010a40000f",
    Peeves = "5ed9e5f2-9cdf-11ee-9410-42010a40000f",
    Scrope = "7b755016-9cdf-11ee-8798-42010a40000f",
}

sessionIdMapping = {
    AbrahamRonen = "",
    AdelaideOakes = "",
    AesopSharp = "",
    AgnesCoffey = "",
    AlbieWeekes = "",
    AmitKakkar = "",
    AnneSallow = "",
    AstoriaCrickett = "",
    AugustusHill = "",
    BaiHowin = "",
    BernardNdiaye = "",
    BOH_AbrahamRonen = "",
    CalliopeSnelling = "",
    CassandraMason = "",
    CharlotteMorrison = "",
    ChiyoKogawa = "",
    ClaireBeaumont = "",
    CliffordCromwell = "",
    ConstanceDagworth = "",
    CressidaBlume = "",
    CrispinDunn = "",
    DinahHecat = "",
    DuncanHobhouse = "",
    EddieThistlewood = "",
    EdgarAdley = "",
    EleazarFig = "",
    EricNorthcott = "",
    EvangelineBardsley = "",
    EverettClopton = "",
    FatimahLawang = "",
    GarrethWeasley = "",
    GerboldOllivander = "",
    GertrudeWigley = "",
    HectorFawley = "",
    HectorWeasley = "",
    HildaLoddington = "",
    ImeldaReyes = "",
    IndiraWolff = "",
    JalalSehmi = "",
    LawrenceDavies = "",
    LeanderPrewett = "",
    LeopoldBabcocke = "",
    LucanBrattleby = "",
    MatildaWeasley = "",
    MirabelGarlick = "",
    MudiwaOnai = "",
    NatsaiOnai = "",
    NellieOggspire = "",
    NeridaRoberts = "",
    NoraTreadwell = "",
    OminisGaunt = "",
    PadraicHaggarty = "",
    PercivalPippin = "",
    PhineasBlack = "",
    PoppySweeting = "",
    PriscillaWakefield = "",
    PriyaTreadwell = "",
    RohanPrakash = "",
    RuthSinger = "",
    SacharissaTugwood = "",
    SamanthaDale = "",
    SebastianSallow = "",
    Sirona = "",
    SolomonSallow = "",
    SophroniaFranklin = "",
    ThomasBrown = "",
    TimothyTeasdale = "",
    VictorRookwood = "",
    VioletMcDowell = "",
    ZenobiaNoke = "",
    NearlyHeadlessNick = "",
    Peeves = "",
    Scrope = "",
}