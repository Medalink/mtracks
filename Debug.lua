local MTracks = LibStub("AceAddon-3.0"):GetAddon("MTracks")

-- Debug module for testing MTracks with simulated data
local Debug = {}

-- Sample dungeon/raid names for realistic data
local SAMPLE_ACTIVITIES = {
    "Ara-Kara, City of Echoes",
    "The Dawnbreaker",
    "Eco-Dome Al'Dani",
    "Halls of Attonement",
    "Operation Floodgate",
    "Tazavesh, The Veiled Market",
    "Manaforge Omega (Normal)",
    "Manaforge Omega (Heroic)",
    "Manaforge Omega (Mythic)",
}

-- Your specific characters only
local SAMPLE_CHARACTERS = {
    { name = "Medamage",   realm = "Area 52",   class = "MAGE",        className = "Mage",         spec = "Arcane",      role = "DAMAGER" },
    { name = "Medadin",    realm = "Area 52",   class = "PALADIN",     className = "Paladin",      spec = "Retribution", role = "DAMAGER" },
    { name = "Medadh",     realm = "Area 52",   class = "DEMONHUNTER", className = "Demon Hunter", spec = "Vengeance",   role = "TANK" },
    { name = "Medapriest", realm = "Area 52",   class = "PRIEST",      className = "Priest",       spec = "Holy",        role = "HEALER" },
    { name = "Medalink",   realm = "Area 52",   class = "SHAMAN",      className = "Shaman",       spec = "Elemental",   role = "DAMAGER" },
    { name = "Medadruid",  realm = "Norgannon", class = "DRUID",       className = "Druid",        spec = "Restoration", role = "HEALER" }
}

-- Realistic party leader names with appropriate realms for demo data
local SAMPLE_PARTY_LEADERS = {
    { name = "Shadowfury",   realm = "Tichondrius",     class = "WARLOCK",     role = "DAMAGER" },
    { name = "Stormrage",    realm = "Stormrage",       class = "DRUID",       role = "HEALER" },
    { name = "Lightbringer", realm = "Lightbringer",    class = "PALADIN",     role = "TANK" },
    { name = "Deathwing",    realm = "Deathwing",       class = "WARRIOR",     role = "TANK" },
    { name = "Frostmourne",  realm = "Frostmourne",     class = "DEATHKNIGHT", role = "TANK" },
    { name = "Thunderlord",  realm = "Thunderlord",     class = "SHAMAN",      role = "HEALER" },
    { name = "Arthas",       realm = "Arthas",          class = "DEATHKNIGHT", role = "TANK" },
    { name = "Jaina",        realm = "Proudmoore",      class = "MAGE",        role = "DAMAGER" },
    { name = "Thrall",       realm = "Thrall",          class = "SHAMAN",      role = "DAMAGER" },
    { name = "Anduin",       realm = "Stormwind",       class = "PRIEST",      role = "HEALER" },
    { name = "Varian",       realm = "Stormwind",       class = "WARRIOR",     role = "DAMAGER" },
    { name = "Sylvanas",     realm = "Dalaran",         class = "HUNTER",      role = "DAMAGER" },
    { name = "Garrosh",      realm = "Mal'Ganis",       class = "WARRIOR",     role = "DAMAGER" },
    { name = "Khadgar",      realm = "Dalaran",         class = "MAGE",        role = "DAMAGER" },
    { name = "Tyrande",      realm = "Darnassus",       class = "PRIEST",      role = "HEALER" },
    { name = "Malfurion",    realm = "Darnassus",       class = "DRUID",       role = "HEALER" },
    { name = "Velen",        realm = "Azuremyst Isle",  class = "PRIEST",      role = "HEALER" },
    { name = "Uther",        realm = "Uther",           class = "PALADIN",     role = "HEALER" },
    { name = "Gul'dan",      realm = "Gul'dan",         class = "WARLOCK",     role = "DAMAGER" },
    { name = "Illidan",      realm = "Illidan",         class = "DEMONHUNTER", role = "TANK" },
    { name = "Keristrasza",  realm = "Borean Tundra",   class = "MAGE",        role = "DAMAGER" },
    { name = "Alexstrasza",  realm = "Wyrmrest Accord", class = "PRIEST",      role = "HEALER" },
    { name = "Ysera",        realm = "Emerald Dream",   class = "DRUID",       role = "DAMAGER" },
    { name = "Nozdormu",     realm = "Caverns of Time", class = "MAGE",        role = "DAMAGER" },
    { name = "Malygos",      realm = "The Nexus",       class = "MAGE",        role = "DAMAGER" },
    { name = "Ragnaros",     realm = "Ragnaros",        class = "SHAMAN",      role = "DAMAGER" },
    { name = "Nefarian",     realm = "Blackwing Lair",  class = "WARRIOR",     role = "TANK" },
    { name = "Onyxia",       realm = "Onyxia",          class = "WARRIOR",     role = "TANK" },
    { name = "Vaelastraz",   realm = "Blackwing Lair",  class = "WARRIOR",     role = "DAMAGER" },
    { name = "Chromaggus",   realm = "Blackwing Lair",  class = "HUNTER",      role = "DAMAGER" },
    { name = "Thunderaan",   realm = "Thunderhorn",     class = "SHAMAN",      role = "DAMAGER" },
    { name = "Azuregos",     realm = "Azjol-Nerub",     class = "MAGE",        role = "DAMAGER" },
    { name = "Doomwalker",   realm = "Doomhammer",      class = "WARRIOR",     role = "TANK" },
    { name = "Gruul",        realm = "Bleeding Hollow", class = "WARRIOR",     role = "TANK" },
    { name = "Magtheridon",  realm = "Magtheridon",     class = "WARLOCK",     role = "DAMAGER" },
    { name = "Kael'thas",    realm = "Kael'thas",       class = "MAGE",        role = "DAMAGER" },
    { name = "Vashj",        realm = "Coilfang",        class = "HUNTER",      role = "DAMAGER" },
    { name = "Archimonde",   realm = "Archimonde",      class = "WARLOCK",     role = "DAMAGER" },
    { name = "Kil'jaeden",   realm = "Kil'jaeden",      class = "WARLOCK",     role = "DAMAGER" },
    { name = "Brutallus",    realm = "Burning Legion",  class = "WARRIOR",     role = "DAMAGER" },
    { name = "Felmyst",      realm = "Sunwell",         class = "DRUID",       role = "DAMAGER" }
}

-- Realistic party sizes with weights (more realistic distribution)
local PARTY_SIZE_WEIGHTS = {
    { current = 1, max = 5, weight = 15 }, -- 1/5 - Very common, just started
    { current = 2, max = 5, weight = 25 }, -- 2/5 - Common, looking for more
    { current = 3, max = 5, weight = 30 }, -- 3/5 - Most common, decent group size
    { current = 4, max = 5, weight = 25 }, -- 4/5 - Common, need one more
    { current = 5, max = 5, weight = 5 }   -- 5/5 - Rare, group filled up quickly
}

-- Realistic desired roles for groups based on what's commonly needed
local DESIRED_ROLES_LIST = {
    "Tank",
    "Healer",
    "Damage",
    "Tank, Healer",
    "Tank, Damage",
    "Healer, Damage",
    "Damage x2",
    "Damage x3",
    "Any Role",
    "Tank/Healer",
    "Ranged Damage",
    "Melee Damage",
    "Tank, Ranged Damage",
    "Healer, Melee Damage"
}

-- Weighted outcome probabilities (more favorable for better demo data)
local APPLICATION_OUTCOMES = {
    { outcome = "accepted",  weight = 70 }, -- acceptance rate
    { outcome = "declined",  weight = 25 }, -- decline rate
    { outcome = "cancelled", weight = 5 }   -- cancel rate
}

local HOSTING_OUTCOMES = {
    { outcome = "successful", weight = 90 }, -- successful hosting
    { outcome = "cancelled",  weight = 10 }  -- cancelled hosting
}

-- Helper function to get weighted random outcome
local function GetWeightedRandom(outcomes)
    local totalWeight = 0
    for _, outcome in ipairs(outcomes) do
        totalWeight = totalWeight + outcome.weight
    end

    local random = math.random(1, totalWeight)
    local currentWeight = 0

    for _, outcome in ipairs(outcomes) do
        currentWeight = currentWeight + outcome.weight
        if random <= currentWeight then
            return outcome.outcome
        end
    end

    return outcomes[1].outcome -- fallback
end

-- Helper function to get weighted random party size
local function GetWeightedPartySize()
    local totalWeight = 0
    for _, sizeData in ipairs(PARTY_SIZE_WEIGHTS) do
        totalWeight = totalWeight + sizeData.weight
    end

    local random = math.random(1, totalWeight)
    local currentWeight = 0

    for _, sizeData in ipairs(PARTY_SIZE_WEIGHTS) do
        currentWeight = currentWeight + sizeData.weight
        if random <= currentWeight then
            return sizeData.current, sizeData.max
        end
    end

    return 3, 5 -- fallback
end

-- Helper function to generate a realistic party leader
local function GeneratePartyLeader()
    local leaderData = SAMPLE_PARTY_LEADERS[math.random(1, #SAMPLE_PARTY_LEADERS)]
    return leaderData.name, leaderData.realm, leaderData.class, leaderData.role
end

-- Generate character from predefined list with class info
local function GenerateCharacter(characterIndex)
    local charData = SAMPLE_CHARACTERS[characterIndex]
    local name = charData.name
    local realm = charData.realm
    local key = name .. "-" .. realm
    return name, realm, key, charData.class, charData.className, charData.spec, charData.role
end

-- Generate random timestamp within the last 30 days
local function GenerateRandomTimestamp()
    local now = time()
    local thirtyDaysAgo = now - (30 * 24 * 60 * 60)
    return math.random(thirtyDaysAgo, now)
end

-- Reset and populate database with demo data
function Debug:GenerateDemoData()
    -- Reset the database completely
    MTracks.db:ResetDB()
    MTracks:Print("|cffFFD700Demo Mode:|r Database reset. Generating character-focused demo data...")

    local accountData = MTracks.db.global.accountData
    local characters = MTracks.db.global.characters
    local history = MTracks.db.global.history

    -- Initialize account totals
    accountData.totalApplied = 0
    accountData.totalAccepted = 0
    accountData.totalDeclined = 0
    accountData.totalCancelled = 0
    accountData.totalHosted = 0
    accountData.totalHostedSuccessful = 0
    accountData.totalHostedCancelled = 0

    -- Track character-specific stats (build these first)
    local characterStats = {}

    MTracks:Print(
        "|cffFFD700Demo Mode:|r Generating character-focused data (6 characters, variable activity levels)...")

    for charIndex = 1, #SAMPLE_CHARACTERS do
        local characterData = SAMPLE_CHARACTERS[charIndex]
        local name, realm, key, class, className, spec, role = GenerateCharacter(charIndex)

        -- Generate random activity levels for variety
        local totalActivities = math.random(20, 100)           -- Random between 20-100 activities
        local hostingSessions = math.random(2, 15)             -- Random between 2-15 hosting sessions
        local applications = totalActivities - hostingSessions -- Remaining are applications

        -- Ensure we have at least some applications
        if applications < 5 then
            applications = 5
            hostingSessions = totalActivities - applications
        end

        -- Initialize character with empty stats
        characterStats[key] = {
            applied = 0,
            accepted = 0,
            declined = 0,
            cancelled = 0,
            hosted = 0,
            hostedSuccessful = 0,
            hostedCancelled = 0,
            name = name,
            realm = realm,
            class = class,
            className = className
        }

        MTracks:Print("|cffFFD700Demo Mode:|r Building stats for " ..
            name ..
            " (" .. spec .. " " .. className .. "): " .. applications .. " apps + " .. hostingSessions .. " hosting...")

        -- Generate applications for this character
        for i = 1, applications do
            local outcome = GetWeightedRandom(APPLICATION_OUTCOMES)
            local timestamp = GenerateRandomTimestamp()
            local activity = SAMPLE_ACTIVITIES[math.random(1, #SAMPLE_ACTIVITIES)]

            -- Generate realistic party leader and size
            local leaderName, leaderRealm, leaderClass, leaderRole = GeneratePartyLeader()
            local currentMembers, maxMembers = GetWeightedPartySize()
            local memberCount = string.format("%d/%d", currentMembers, maxMembers)

            -- Update character stats
            characterStats[key].applied = characterStats[key].applied + 1

            if outcome == "accepted" then
                characterStats[key].accepted = characterStats[key].accepted + 1
            elseif outcome == "declined" then
                characterStats[key].declined = characterStats[key].declined + 1
            elseif outcome == "cancelled" then
                characterStats[key].cancelled = characterStats[key].cancelled + 1
            end

            -- Add to history with realistic leader and party data
            table.insert(history, {
                timestamp = timestamp,
                eventType = "APPLICATION_" .. string.upper(outcome),
                status = outcome == "accepted" and "invited" or outcome, -- Convert to sparkline format
                characterName = name,
                realmName = realm,
                activityName = activity,

                -- Realistic LFG data
                leaderName = leaderName,
                leaderRealm = leaderRealm,
                leaderClass = leaderClass,
                leaderRole = leaderRole,
                memberCount = memberCount,
                numMembers = currentMembers,
                maxMembers = maxMembers,

                -- Player context (using character's actual role)
                applicantLevel = math.random(70, 80),
                applicantItemLevel = math.random(580, 650),
                applicantRole = role,
                playerAppliedRole = role,

                -- Group requirements
                requiredItemLevel = math.random(580, 640),
                levelRange = string.format("ilvl %d+", math.random(580, 640)),
                itemLevel = math.random(580, 640),
                desiredRoles = DESIRED_ROLES_LIST[math.random(1, #DESIRED_ROLES_LIST)]
            })
        end

        -- Generate hosting sessions for this character
        for i = 1, hostingSessions do
            local outcome = GetWeightedRandom(HOSTING_OUTCOMES)
            local timestamp = GenerateRandomTimestamp()
            local activity = SAMPLE_ACTIVITIES[math.random(1, #SAMPLE_ACTIVITIES)]

            -- Generate realistic party size for hosting (current character is the leader)
            local currentMembers, maxMembers = GetWeightedPartySize()
            local memberCount = string.format("%d/%d", currentMembers, maxMembers)

            -- Update character hosting stats
            characterStats[key].hosted = characterStats[key].hosted + 1

            if outcome == "successful" then
                characterStats[key].hostedSuccessful = characterStats[key].hostedSuccessful + 1
            elseif outcome == "cancelled" then
                characterStats[key].hostedCancelled = characterStats[key].hostedCancelled + 1
            end

            -- Add to history
            local hostingEventType
            if outcome == "successful" then
                hostingEventType = "group_completed"
            else
                hostingEventType = "group_cancelled"
            end

            table.insert(history, {
                timestamp = timestamp,
                eventType = hostingEventType,
                status = "hosting", -- Status for sparkline categorization
                characterName = name,
                realmName = realm,
                activityName = activity,

                -- Hosting data (current character is the leader)
                leaderName = name,
                leaderRealm = realm,
                leaderClass = class,
                leaderRole = role,
                memberCount = memberCount,
                numMembers = currentMembers,
                maxMembers = maxMembers,

                -- Player role (when hosting, you're playing your character's role)
                playerAppliedRole = role,
                applicantRole = role,

                -- Mythic+ specific data
                keyLevel = math.random(2, 15),
                groupSize = currentMembers,

                -- Group requirements
                requiredItemLevel = math.random(580, 640),
                levelRange = string.format("ilvl %d+", math.random(580, 640)),
                itemLevel = math.random(580, 640),
                desiredRoles = DESIRED_ROLES_LIST[math.random(1, #DESIRED_ROLES_LIST)]
            })

            -- Also add a group_created event for each hosting session
            table.insert(history, {
                timestamp = timestamp - 1, -- Slightly earlier timestamp
                eventType = "group_created",
                status = "hosting",
                characterName = name,
                realmName = realm,
                activityName = activity,

                -- Hosting data (current character is the leader)
                leaderName = name,
                leaderRealm = realm,
                leaderClass = class,
                leaderRole = role,
                memberCount = "1/5", -- Just started the group
                numMembers = 1,
                maxMembers = 5,

                -- Player role (when hosting, you're playing your character's role)
                playerAppliedRole = role,
                applicantRole = role,

                -- Mythic+ specific data
                keyLevel = math.random(2, 15),
                groupSize = 1,

                -- Group requirements
                requiredItemLevel = math.random(580, 640),
                levelRange = string.format("ilvl %d+", math.random(580, 640)),
                itemLevel = math.random(580, 640),
                desiredRoles = DESIRED_ROLES_LIST[math.random(1, #DESIRED_ROLES_LIST)]
            })
        end

        -- Set last activity to the most recent timestamp for this character
        local lastTimestamp = 0
        for _, entry in ipairs(history) do
            if (entry.characterName .. "-" .. entry.realmName) == key then
                lastTimestamp = math.max(lastTimestamp, entry.timestamp or 0)
            end
        end
        characterStats[key].lastActivity = lastTimestamp

        -- Show character summary
        local successRate = characterStats[key].applied > 0 and
            (characterStats[key].accepted / characterStats[key].applied * 100) or 0
        MTracks:Print(string.format("  |cff00FF00✓|r %s: %d apps, %.1f%% success, %d hosted",
            name, characterStats[key].applied, successRate, characterStats[key].hosted))
    end

    -- Now roll up character stats to account totals
    MTracks:Print("|cffFFD700Demo Mode:|r Rolling up account totals from character data...")

    for _, charStats in pairs(characterStats) do
        accountData.totalApplied = accountData.totalApplied + charStats.applied
        accountData.totalAccepted = accountData.totalAccepted + charStats.accepted
        accountData.totalDeclined = accountData.totalDeclined + charStats.declined
        accountData.totalCancelled = accountData.totalCancelled + charStats.cancelled
        accountData.totalHosted = accountData.totalHosted + charStats.hosted
        accountData.totalHostedSuccessful = accountData.totalHostedSuccessful + charStats.hostedSuccessful
        accountData.totalHostedCancelled = accountData.totalHostedCancelled + charStats.hostedCancelled
    end

    -- Store character data in the database
    for characterKey, stats in pairs(characterStats) do
        characters[characterKey] = stats
    end

    -- Sort history by timestamp
    table.sort(history, function(a, b)
        return a.timestamp > b.timestamp
    end)

    -- Initialize and rebuild sparkline history from the generated data
    MTracks:Print("|cffFFD700Demo Mode:|r Rebuilding sparkline data for visual trends...")

    -- Initialize sparkline data structure if needed
    if not MTracks.db.global.sparklineHistory then
        MTracks.db.global.sparklineHistory = {}
    end

    -- Rebuild sparklines from our demo data
    if MTracks.RebuildSparklineHistory then
        MTracks:RebuildSparklineHistory()
    end

    -- Update last activity timestamp
    accountData.lastUpdate = time()

    -- Print comprehensive summary
    local characterCount = 0
    for _ in pairs(characterStats) do characterCount = characterCount + 1 end

    local overallSuccessRate = accountData.totalApplied > 0 and
        (accountData.totalAccepted / accountData.totalApplied * 100) or 0

    local summary = string.format(
        "|cffFFD700Character-Focused Demo Data Generated:|r\n" ..
        "• |cff00FFFF%d Characters|r with meaningful individual stats\n" ..
        "• |cffFFFFFF%d Total Applications|r (|cff00FF00%d accepted|r, |cffFF6B6B%d declined|r, |cffFFFF00%d cancelled|r)\n" ..
        "• |cffAA88FF%d Total Hosting sessions|r (|cff00FF00%d successful|r, |cffFF6B6B%d cancelled|r)\n" ..
        "• |cffFFD700Overall Success Rate: %.1f%%|r\n" ..
        "• |cff88FFAAUsing your 6 characters with realistic LFG data:|r\n" ..
        "  - |cffFFFFFFRealistic party leader names|r from 40 different realms\n" ..
        "  - |cffFFFFFFRealistic party sizes|r (1/5 to 5/5) with proper weighting\n" ..
        "  - |cffFFFFFFProper role assignments|r based on character class/spec\n" ..
        "  - |cffFFFFFFRealistic desired roles|r for group listings\n" ..
        "  - |cffFFFFFFExpanded activity list|r with current WoW content\n" ..
        "  - |cffFFFFFFVariable activity levels|r (20-100 total, 2-15 hosting per character)",
        characterCount,
        accountData.totalApplied,
        accountData.totalAccepted,
        accountData.totalDeclined,
        accountData.totalCancelled,
        accountData.totalHosted,
        accountData.totalHostedSuccessful,
        accountData.totalHostedCancelled,
        overallSuccessRate
    )

    MTracks:Print(summary)

    -- Force a complete refresh of the display
    MTracks:Print("|cffFFD700Demo Mode:|r Refreshing UI with demo data...")
    if MTracks.UpdateDisplay then
        MTracks:UpdateDisplay()
    end

    -- Also refresh sparklines specifically
    if MTracks.mainFrame and MTracks.mainFrame.statCards then
        for _, cardData in pairs(MTracks.mainFrame.statCards) do
            if cardData.sparklineFrame and cardData.config and cardData.config.sparklineColor then
                local metricKey = cardData.config.key:gsub("total", ""):gsub("Rate", "")
                if metricKey == "Applied" then
                    metricKey = "totalApplied"
                elseif metricKey == "Invited" then
                    metricKey = "totalAccepted"
                elseif metricKey == "Declined" then
                    metricKey = "totalDeclined"
                elseif metricKey == "Cancelled" then
                    metricKey = "totalCancelled"
                elseif metricKey == "Hosted" then
                    metricKey = "totalHosted"
                elseif metricKey == "HostedSuccessful" then
                    metricKey = "totalHostedSuccessful"
                elseif metricKey == "HostedCancelled" then
                    metricKey = "totalHostedCancelled"
                end

                if MTracks.UpdateSparkline then
                    MTracks:UpdateSparkline(cardData.sparklineFrame, metricKey, cardData.config.sparklineColor)
                end
            end
        end
    end
end

-- Slash command handler
function Debug:RegisterSlashCommands()
    SLASH_MTRACKSDEMO1 = "/mtracksdemo"
    SLASH_MTRACKSDEMO2 = "/mtd"

    SlashCmdList["MTRACKSDEMO"] = function(msg)
        local cmd = string.lower(string.trim(msg or ""))

        if cmd == "" or cmd == "demo" then
            Debug:GenerateDemoData()
        else
            MTracks:Print("|cffFFD700MTracks Demo Commands:|r")
            MTracks:Print("  |cffFFFFFF/mtracks demo|r - Generate demo data for your 6 characters")
            MTracks:Print("  |cffFFFFFF/mtd|r - Short alias for demo command")
        end
    end
end

-- Initialize debug module
function MTracks:InitializeDebug()
    Debug:RegisterSlashCommands()
    self:Print("|cffFFD700Debug Mode Enabled:|r Use /mtracks demo or /mtd to generate test data")
end

-- Debug Window for MTracks Data Inspection
function MTracks:CreateDebugWindow()
    if self.debugFrame then
        self.debugFrame:Show()
        self:UpdateDebugWindow()
        return
    end

    local frame = CreateFrame("Frame", "MTracksDebugFrame", UIParent, "BackdropTemplate")
    frame:SetSize(800, 600)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Backdrop
    local backdrop = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    }
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.8)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText("MTracks Debug Data")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Copy button
    local copyBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    copyBtn:SetSize(100, 25)
    copyBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -110, -10)
    copyBtn:SetText("Copy Text")
    copyBtn:SetScript("OnClick", function()
        self:ShowCopyTextFrame()
    end)

    -- Simple Print button for backup
    local printBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    printBtn:SetSize(80, 25)
    printBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -200, -10)
    printBtn:SetText("Print Chat")
    printBtn:SetScript("OnClick", function()
        self:PrintDebugToChat()
    end)

    -- Scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -32, 16)

    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(750, 1000)
    scrollFrame:SetScrollChild(content)

    -- Text display
    local debugText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debugText:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -8)
    debugText:SetWidth(730)
    debugText:SetJustifyH("LEFT")
    debugText:SetJustifyV("TOP")

    frame.debugText = debugText
    self.debugFrame = frame

    self:UpdateDebugWindow()
    frame:Show()
end

function MTracks:UpdateDebugWindow()
    if not self.debugFrame or not self.debugFrame.debugText then return end

    local output = {}
    table.insert(output, "=== MTRACKS DEBUG DATA ===\n")
    table.insert(output, string.format("Timestamp: %s\n", date("%Y-%m-%d %H:%M:%S")))
    table.insert(output, "\n")

    -- History entries
    local history = self.db.global.history or {}
    table.insert(output, string.format("HISTORY ENTRIES: %d\n", #history))

    for i = 1, math.min(10, #history) do
        local entry = history[i]
        if entry then
            local leaderName = entry.leaderName or "NIL"
            local status = entry.status or "NIL"
            local charName = (entry.characterName or "NIL") .. "-" .. (entry.realmName or "NIL")
            local timestamp = entry.timestamp and date("%m/%d %H:%M", entry.timestamp) or "NIL"
            local resultID = entry.resultID or "NIL"

            table.insert(output, string.format("Entry %d:\n", i))
            table.insert(output, string.format("  Leader: [%s]\n", leaderName))
            table.insert(output, string.format("  Status: [%s]\n", status))
            table.insert(output, string.format("  Character: [%s]\n", charName))
            table.insert(output, string.format("  Time: [%s]\n", timestamp))
            table.insert(output, string.format("  ResultID: [%s]\n", resultID))
            table.insert(output, "\n")
        end
    end

    -- Cache entries
    local cache = self.db.global.applicationCache or {}
    local cacheCount = 0
    for _ in pairs(cache) do cacheCount = cacheCount + 1 end

    table.insert(output, string.format("APPLICATION CACHE: %d entries\n", cacheCount))

    local count = 0
    for appID, appData in pairs(cache) do
        count = count + 1
        if count <= 10 then
            local leaderName = appData.leaderName or "NIL"
            local resultID = appData.resultID or "NIL"
            local timestamp = appData.appliedTime and date("%m/%d %H:%M", appData.appliedTime) or "NIL"

            table.insert(output, string.format("Cache %d:\n", count))
            table.insert(output, string.format("  App ID: [%s]\n", appID or "NIL"))
            table.insert(output, string.format("  Leader: [%s]\n", leaderName))
            table.insert(output, string.format("  ResultID: [%s]\n", resultID))
            table.insert(output, string.format("  Time: [%s]\n", timestamp))
            table.insert(output, "\n")
        end
    end

    -- Current character info
    table.insert(output, "CURRENT CHARACTER\n")
    local currentChar = self:GetCurrentCharacterInfo()
    if currentChar then
        table.insert(output, string.format("Name: [%s]\n", currentChar.name or "NIL"))
        table.insert(output, string.format("Realm: [%s]\n", currentChar.realm or "NIL"))
        table.insert(output, string.format("Key: [%s]\n", currentChar.key or "NIL"))
    end

    table.insert(output, "\n=== END DEBUG DATA ===")

    local finalText = table.concat(output, "")
    self.debugFrame.debugText:SetText(finalText)

    -- Store the text for copying
    self.debugFrame.copyableText = finalText
end

function MTracks:ShowCopyTextFrame()
    -- Create or show the copy text frame
    if self.copyFrame then
        self.copyFrame:Show()
        if self.copyFrame.editBox and self.debugFrame.copyableText then
            self.copyFrame.editBox:SetText(self.debugFrame.copyableText)
            C_Timer.After(0.1, function()
                self.copyFrame.editBox:SetFocus()
                self.copyFrame.editBox:HighlightText()
            end)
        end
        return
    end

    local frame = CreateFrame("Frame", "MTracksCopyFrame", UIParent, "BackdropTemplate")
    frame:SetSize(600, 400)
    frame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Backdrop
    local backdrop = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    }
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(0, 0, 0, 0.9)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText("Copy Debug Data (Ctrl+A, Ctrl+C)")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

    -- Instructions
    local instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instructions:SetPoint("TOP", frame, "TOP", 0, -45)
    instructions:SetText("Click in text area, then Ctrl+A (Select All), then Ctrl+C (Copy)")

    -- Create scroll frame for the edit box
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -70)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -32, 50)

    -- Create the edit box
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(true)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(550)
    editBox:SetHeight(300)
    editBox:SetMaxLetters(0)                            -- No limit
    editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    editBox:SetScript("OnEnterPressed", function() end) -- Prevent closing on enter

    -- Enable text selection and editing
    editBox:EnableMouse(true)
    editBox:SetScript("OnMouseDown", function(self)
        self:SetFocus()
        -- Small delay to ensure text is set before highlighting
        C_Timer.After(0.1, function()
            self:HighlightText()
        end)
    end)

    -- Make sure the editbox can be interacted with
    editBox:SetScript("OnShow", function(self)
        self:SetFocus()
        C_Timer.After(0.1, function()
            self:HighlightText()
        end)
    end)

    scrollFrame:SetScrollChild(editBox)
    frame.editBox = editBox

    -- Select All button
    local selectAllBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    selectAllBtn:SetSize(80, 25)
    selectAllBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 16)
    selectAllBtn:SetText("Select All")
    selectAllBtn:SetScript("OnClick", function()
        editBox:SetFocus()
        editBox:SetCursorPosition(0)
        editBox:HighlightText()
    end)

    -- Done button
    local doneBtn = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
    doneBtn:SetSize(60, 25)
    doneBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    doneBtn:SetText("Done")
    doneBtn:SetScript("OnClick", function() frame:Hide() end)

    self.copyFrame = frame

    -- Set the text and highlight it
    if self.debugFrame.copyableText then
        editBox:SetText(self.debugFrame.copyableText)
        -- Use a timer to ensure the text is set before highlighting
        C_Timer.After(0.2, function()
            editBox:SetFocus()
            editBox:HighlightText()
        end)
    end

    frame:Show()
end

function MTracks:PrintDebugToChat()
    if not self.debugFrame or not self.debugFrame.copyableText then
        self:Print("No debug data available. Run /mtdebug first.")
        return
    end

    local lines = {}
    for line in self.debugFrame.copyableText:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    self:Print("=== DEBUG DATA START ===")
    for i, line in ipairs(lines) do
        if i <= 50 then -- Limit to first 50 lines to avoid spam
            self:Print(line)
        else
            self:Print("... (truncated, use copy window for full data)")
            break
        end
    end
    self:Print("=== DEBUG DATA END ===")
end

-- Auto-initialize when addon loads
if MTracks then
    MTracks:InitializeDebug()
end
