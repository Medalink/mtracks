local MTracks = LibStub("AceAddon-3.0"):NewAddon("MTracks", "AceConsole-3.0", "AceEvent-3.0")

-- Constants
local DB_VERSION = 1

-- UI Colors (Minimal Flat Style)
local COLORS = {
    background = { 0.08, 0.08, 0.08, 0.95 }, -- Very dark gray
    text = { 0.9, 0.9, 0.9, 1 },             -- Light text
    accent = { 0.2, 0.2, 0.2, 1 },           -- Dark gray accent
    header = { 0.12, 0.12, 0.12, 0.95 },     -- Header background
    row_even = { 0.1, 0.1, 0.1, 0.6 },       -- Even row color
    row_odd = { 0.15, 0.15, 0.15, 0.6 },     -- Odd row color
    success = { 0.2, 0.8, 0.2, 1 },          -- Green
    warning = { 0.8, 0.6, 0.2, 1 },          -- Orange
    danger = { 0.8, 0.2, 0.2, 1 },           -- Red

    -- Category-based colors for stat types
    character_theme = { 0.5, 0.7, 1.0, 0.8 }, -- Light blue for character-specific stats
    host_theme = { 0.7, 0.5, 1.0, 0.8 },      -- Light purple for host-specific stats
    account_theme = { 1.0, 0.8, 0.4, 0.8 },   -- Light gold for account-specific stats

    -- Hover colors matching themes
    character_hover = { 0.3, 0.5, 0.8, 0.6 }, -- Darker blue hover
    host_hover = { 0.5, 0.3, 0.8, 0.6 },      -- Darker purple hover
    account_hover = { 0.8, 0.6, 0.2, 0.6 },   -- Darker gold hover
}

-- Card-Based Colors for Stat Cards
local CARD_COLORS = {
    -- Card backgrounds
    card_primary = { 0.15, 0.15, 0.15, 0.95 },   -- Primary metrics
    card_secondary = { 0.12, 0.12, 0.12, 0.95 }, -- Secondary metrics

    -- Category-themed borders (1px, subtle dark grey)
    character_border = { 0.4, 0.4, 0.4, 0 }, -- Subtle dark grey border for character stats
    host_border = { 0.4, 0.4, 0.4, 0 },      -- Subtle dark grey border for host stats
    account_border = { 0.4, 0.4, 0.4, 0 },   -- Subtle dark grey border for account stats
    card_border = { 0.4, 0.4, 0.4, 0 },      -- Default subtle dark grey border

    -- Unified status colors
    applied = { 0.4, 0.7, 1.0, 1 },   -- Light blue - applications
    invited = { 0.2, 0.8, 0.3, 1 },   -- Green - invited/accepted
    declined = { 1.0, 0.3, 0.3, 1 },  -- Red - declined/negative
    cancelled = { 0.6, 0.6, 0.6, 1 }, -- Gray - cancelled/neutral
    host = { 0.7, 0.5, 1.0, 1 },      -- Purple - host-related

    -- Legacy aliases for compatibility
    success = { 0.2, 0.8, 0.3, 1 },    -- Green - same as invited
    decline = { 1.0, 0.3, 0.3, 1 },    -- Red - same as declined
    cancel = { 0.6, 0.6, 0.6, 1 },     -- Gray - same as cancelled
    removed = { 1.0, 0.3, 0.3, 1 },    -- Red - same as declined
    characters = { 0.4, 0.7, 1.0, 1 }, -- Light blue - same as applied

    -- Sparkline colors
    sparkline_bg = { 0.2, 0.2, 0.2, 0.6 },       -- Background line
    sparkline_positive = { 0.2, 0.7, 0.3, 0.8 }, -- Green trends
    sparkline_negative = { 0.8, 0.3, 0.3, 0.8 }, -- Red trends
    sparkline_neutral = { 0.6, 0.6, 0.6, 0.8 },  -- Gray trends

}

-- Blizzard-style rarity color system for percentages
-- Based on item quality colors with weighted distribution
local function GetRarityColorForPercentage(percentage)
    -- Ensure percentage is between 0 and 100
    percentage = math.max(0, math.min(100, percentage))

    -- Weighted breakpoints (80% of values fall in gray through blue)
    -- Gray: 0-15% (Poor quality)
    -- White: 15-30% (Common quality)
    -- Green: 30-50% (Uncommon quality)
    -- Blue: 50-70% (Rare quality)
    -- Purple: 70-85% (Epic quality)
    -- Orange: 85-95% (Legendary quality)
    -- Gold: 95-100% (Artifact quality)

    if percentage <= 15 then
        -- Gray (Poor) - 0.62, 0.62, 0.62
        local intensity = percentage / 15
        return { 0.5 + intensity * 0.12, 0.5 + intensity * 0.12, 0.5 + intensity * 0.12, 1 }
    elseif percentage <= 30 then
        -- White (Common) - 1.0, 1.0, 1.0
        local intensity = (percentage - 15) / 15
        return { 0.7 + intensity * 0.3, 0.7 + intensity * 0.3, 0.7 + intensity * 0.3, 1 }
    elseif percentage <= 50 then
        -- Green (Uncommon) - 0.12, 1.0, 0.0
        local intensity = (percentage - 30) / 20
        return { 0.1 + intensity * 0.02, 0.6 + intensity * 0.4, 0.1 + intensity * 0.0, 1 }
    elseif percentage <= 70 then
        -- Blue (Rare) - 0.0, 0.44, 0.87
        local intensity = (percentage - 50) / 20
        return { 0.0 + intensity * 0.2, 0.3 + intensity * 0.14, 0.7 + intensity * 0.17, 1 }
    elseif percentage <= 85 then
        -- Purple (Epic) - 0.64, 0.21, 0.93
        local intensity = (percentage - 70) / 15
        return { 0.5 + intensity * 0.14, 0.2 + intensity * 0.01, 0.8 + intensity * 0.13, 1 }
    elseif percentage <= 95 then
        -- Orange (Legendary) - 1.0, 0.5, 0.0
        local intensity = (percentage - 85) / 10
        return { 0.9 + intensity * 0.1, 0.4 + intensity * 0.1, 0.0 + intensity * 0.2, 1 }
    else
        -- Gold (Artifact) - 0.9, 0.8, 0.5
        local intensity = (percentage - 95) / 5
        return { 0.85 + intensity * 0.05, 0.75 + intensity * 0.05, 0.4 + intensity * 0.1, 1 }
    end
end

-- Format percentage to 1 decimal place
local function FormatPercentage(value)
    return string.format("%.1f%%", value)
end

-- Stat Card Configuration
local STAT_CARDS = {
    -- Row 1: Applications + Hosted (centered, 2 cards)
    {
        key = "totalApplied",
        label = "Applications",
        pos = { 1, 1 },
        category = "account", -- Account-wide stat
        bgColor = CARD_COLORS.card_primary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.applied,
        sparklineColor = CARD_COLORS.applied
    },
    {
        key = "totalHosted",
        label = "Hosted",
        pos = { 1, 2 },
        category = "host", -- Host-specific stat
        bgColor = CARD_COLORS.card_secondary,
        borderColor = CARD_COLORS.host_border,
        valueColor = CARD_COLORS.host,
        sparklineColor = CARD_COLORS.sparkline_positive
    },

    -- Row 2: Invited, Declined, Cancelled, Host Success (4 cards)
    {
        key = "totalInvited",
        label = "Invited",
        pos = { 2, 1 },
        category = "account", -- Account-wide stat
        bgColor = CARD_COLORS.card_secondary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.invited,
        sparklineColor = CARD_COLORS.sparkline_positive
    },
    {
        key = "totalDeclined",
        label = "Declined",
        pos = { 2, 2 },
        category = "account", -- Account-wide stat
        bgColor = CARD_COLORS.card_secondary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.decline,
        sparklineColor = CARD_COLORS.sparkline_negative
    },
    {
        key = "totalCancelled",
        label = "Cancelled",
        pos = { 2, 3 },
        category = "account", -- Account-wide stat
        bgColor = CARD_COLORS.card_secondary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.cancelled,
        sparklineColor = CARD_COLORS.sparkline_neutral
    },
    {
        key = "totalHostedSuccessful",
        label = "Host Success",
        pos = { 2, 4 },
        category = "host", -- Host-specific stat
        bgColor = CARD_COLORS.card_secondary,
        borderColor = CARD_COLORS.host_border,
        valueColor = CARD_COLORS.invited,
        sparklineColor = CARD_COLORS.sparkline_positive
    },

    -- Row 3: Rates + Host Cancel (4 cards)
    {
        key = "invitedRate",
        label = "Invited Rate",
        pos = { 3, 1 },
        category = "account", -- Account-wide rate
        bgColor = CARD_COLORS.card_primary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.success, -- Will be overridden with rarity color
        sparklineColor = CARD_COLORS.sparkline_positive,
        isRate = true                     -- Mark as percentage rate for dynamic coloring
    },
    {
        key = "declineRate",
        label = "Decline Rate",
        pos = { 3, 2 },
        category = "account", -- Account-wide rate
        bgColor = CARD_COLORS.card_primary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.decline, -- Will be overridden with rarity color (inverted)
        sparklineColor = CARD_COLORS.sparkline_negative,
        isRate = true,                    -- Mark as percentage rate for dynamic coloring
        isInverted = true                 -- Lower values are better for decline rates
    },
    {
        key = "cancelRate",
        label = "Cancel Rate",
        pos = { 3, 3 },
        category = "account", -- Account-wide rate
        bgColor = CARD_COLORS.card_primary,
        borderColor = CARD_COLORS.account_border,
        valueColor = CARD_COLORS.cancelled, -- Will be overridden with rarity color (inverted)
        sparklineColor = CARD_COLORS.sparkline_neutral,
        isRate = true,                      -- Mark as percentage rate for dynamic coloring
        isInverted = true                   -- Lower values are better for cancel rates
    },
    {
        key = "totalHostedCancelled",
        label = "Host Cancel",
        pos = { 3, 4 },
        category = "host", -- Host-specific stat
        bgColor = CARD_COLORS.card_secondary,
        borderColor = CARD_COLORS.host_border,
        valueColor = CARD_COLORS.cancelled,
        sparklineColor = CARD_COLORS.sparkline_neutral
    }
}

-- Static Popup Dialogs
StaticPopupDialogs["MTRACKS_RESET_CONFIRM"] = {
    text =
    "Are you sure you want to reset ALL MTracks data?\n\nThis will permanently delete:\n• Account-wide statistics\n• Character-specific data\n• All historical tracking\n\nThis action cannot be undone!",
    button1 = "Yes, Reset Everything",
    button2 = "Cancel",
    OnAccept = function()
        MTracks:ResetData()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        showMinimap = true,
        autoTrack = true,
        notifications = false,
    },
    global = {
        dbVersion = DB_VERSION,
        accountData = {
            totalApplied = 0,
            totalAccepted = 0,
            totalDeclined = 0,
            totalCancelled = 0,
            -- Hosting statistics
            totalHosted = 0,
            totalHostedSuccessful = 0,
            totalHostedCancelled = 0,
            lastUpdate = time(),
        },
        characters = {},                 -- Character data by character-realm key
        history = {},                    -- Array of historical application data
        applicationCache = {},           -- Cache of application data by applicationID
        maxHistoryEntries = 100,         -- Keep last 100 entries
        maxApplicationCacheEntries = 50, -- Keep last 50 application entries
        sparklineHistory = {},           -- Rolling 7-day data for sparklines
    }
}

function MTracks:FormatLeaderNameForDisplay(leaderName)
    if not leaderName or leaderName == "" then
        return "Group Leader"
    end

    -- If it already contains a realm (has hyphen), return as-is
    if string.find(leaderName, "-") then
        return leaderName
    end

    -- If no realm, add a note to indicate realm is unknown
    -- This helps users understand why some have realm and others don't
    return leaderName .. " (?)"
end

function MTracks:GetPlayerCurrentRole()
    -- Determine player's current role based on spec
    local specIndex = GetSpecialization()
    if not specIndex then
        return "UNKNOWN"
    end

    local role = GetSpecializationRole(specIndex)
    if role == "TANK" then
        return "TANK"
    elseif role == "HEALER" then
        return "HEALER"
    elseif role == "DAMAGER" then
        return "DAMAGER"
    else
        return "UNKNOWN"
    end
end

function MTracks:GetHostingStatusFromEventType(eventType, applicantName)
    if eventType == "group_created" then
        return "Created Group"
    elseif eventType == "group_cancelled" then
        return "Cancelled Group"
    elseif eventType == "group_completed" then
        return "Completed Group"
    elseif eventType == "group_ended_incomplete" then
        return "Ended Incomplete"
    elseif eventType == "applicant_invited" then
        return applicantName and ("Invited: " .. applicantName) or "Invited Applicant"
    elseif eventType == "applicant_declined" then
        return applicantName and ("Rejected: " .. applicantName) or "Rejected Applicant"
    elseif eventType == "member_joined" then
        return "Member Joined"
    elseif eventType == "member_left" then
        return "Member Left"
    else
        return "Hosting"
    end
end

function MTracks:OnInitialize()
    -- Initialize database using AceDB
    self.db = LibStub("AceDB-3.0"):New("MTracksDB", defaults, true)

    -- Register slash commands
    self:RegisterChatCommand("mtracks", "SlashCommand")

    -- Create minimap button
    self:CreateMinimapButton()

    -- Setup Ace3 configuration
    self:SetupConfiguration()

    -- Setup proper escape handling
    self:SetupEscapeHandling()

    -- Initialize current character in global database (so they always appear in the table)
    self:InitializeCurrentCharacter()

    -- Initialize sparkline data tracking
    self:InitializeSparklineData()

    -- Initialize hosting tracking variables
    self:InitializeHostingTracking()
end

function MTracks:SlashCommand(input)
    local cmd = string.lower(string.trim(input or ""))

    if cmd == "" then
        self:ToggleMainFrame()
    elseif cmd == "show" then
        self:ShowMainFrame()
    elseif cmd == "hide" then
        self:HideMainFrame()
    elseif cmd == "config" or cmd == "settings" then
        self:OpenSettings()
    elseif cmd == "reset" then
        StaticPopup_Show("MTRACKS_RESET_CONFIRM")
    else
        self:Print("|cffFFD700MTracks Commands:|r")
        self:Print("  |cffFFFFFF/mtracks|r - Toggle main window")
        self:Print("  |cffFFFFFF/mtracks show|r - Show main window")
        self:Print("  |cffFFFFFF/mtracks hide|r - Hide main window")
        self:Print("  |cffFFFFFF/mtracks config|r - Open settings")
        self:Print("  |cffFFFFFF/mtracks reset|r - Reset all data")
    end
end

function MTracks:InitializeCurrentCharacter()
    -- Ensure current character exists in global database (even with 0 stats)
    local charInfo = self:GetCurrentCharacterInfo()
    if not self.db.global.characters[charInfo.key] then
        self.db.global.characters[charInfo.key] = {
            applied = 0,
            accepted = 0,
            declined = 0,
            cancelled = 0,
            -- Hosting statistics
            hosted = 0,
            hostedSuccessful = 0,
            hostedCancelled = 0,
            lastActivity = 0,
            name = charInfo.name,
            realm = charInfo.realm,
            class = charInfo.class,
            level = charInfo.level
        }
    else
        -- Update existing character's class and level info (in case it changed)
        local existingChar = self.db.global.characters[charInfo.key]
        existingChar.class = charInfo.class
        existingChar.level = charInfo.level
        existingChar.name = charInfo.name -- In case of name change
        existingChar.realm = charInfo.realm
    end
end

function MTracks:OnEnable()
    -- Register events for tracking
    self:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
    self:RegisterEvent("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS")

    -- Register events for hosting tracking
    self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")

    -- Rebuild sparkline history from existing data on startup
    self:RebuildSparklineHistory()

    -- Initialize UI if needed
    if not self.mainFrame then
        self:CreateMainFrame()
    end
end

function MTracks:OnDisable()
    -- Cleanup if needed
    if self.mainFrame then
        self.mainFrame:Hide()
    end

    -- Restore original CloseSpecialWindows if we hooked it
    if self.originalCloseSpecialWindows then
        CloseSpecialWindows = self.originalCloseSpecialWindows
        self.originalCloseSpecialWindows = nil
    end
end

function MTracks:CreateMinimapButton()
    local LDB = LibStub("LibDataBroker-1.1", true)
    if not LDB then return end

    local minimapObject = LDB:NewDataObject("MTracks", {
        type = "data source",
        text = "MTracks",
        icon = "Interface\\Icons\\Achievement_General_StayClassy",
        OnClick = function(_, button)
            if button == "LeftButton" then
                self:ToggleMainFrame()
            elseif button == "RightButton" then
                self:OpenSettings()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("|cff3FC7EBMTracks|r")
            tooltip:AddLine("Left-click: Open tracker")
            tooltip:AddLine("Right-click: Settings")
        end,
    })

    local icon = LibStub("LibDBIcon-1.0", true)
    if icon then
        self.minimapButton = icon
        icon:Register("MTracks", minimapObject, self.db.profile.minimap)
    end
end

function MTracks:CreateMainFrame()
    local frame = CreateFrame("Frame", "MTracksMainFrame", UIParent, "BackdropTemplate")
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetSize(1080, 580) -- More compact: reduced width by 30px, height by 70px
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame:Hide()

    -- Add flat minimal backdrop
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = nil,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(unpack(COLORS.background))

    -- Initialize Logo module if not already attached
    if not self.Logo then
        self.Logo = _G.MTracksLogo
        if not self.Logo then
            self:Print("Warning: Logo module not found. Skipping logo display.")
            return
        end
    end

    -- Create logo INSIDE the frame using negative positioning to appear above it
    local logoFrame = self.Logo:CreateStyledLogo(frame, "MTracks", {
        position = { x = 0, y = -10 }, -- Small negative Y gap above the frame
        anchor = "BOTTOM",
        anchorTo = "TOP",
        firstLetterSize = 40,                        -- Slightly larger since we have more space
        restSize = 36,                               -- Slightly larger since we have more space
        containerSize = { width = 200, height = 70 } -- Reduced width to better match text width
    })

    -- Store reference for potential future use
    frame.logoFrame = logoFrame

    -- Create close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -10, -10)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Create settings button (flat minimalist icon)
    local settingsButton = CreateFrame("Button", nil, frame)
    settingsButton:SetSize(20, 20)                                      -- Slightly smaller to match close button style
    settingsButton:SetPoint("TOPRIGHT", closeButton, "TOPLEFT", -8, -2) -- Better alignment

    -- Settings icon texture - using a cleaner icon
    local settingsIcon = settingsButton:CreateTexture(nil, "ARTWORK")
    settingsIcon:SetSize(16, 16) -- Smaller for cleaner look
    settingsIcon:SetPoint("CENTER")
    settingsIcon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    settingsIcon:SetVertexColor(0.8, 0.8, 0.8, 1) -- Slightly muted to match flat style

    -- Settings button functionality
    settingsButton:SetScript("OnClick", function()
        self:OpenSettings()
    end)

    -- Settings button hover effects (subtle and flat)
    settingsButton:SetScript("OnEnter", function()
        settingsIcon:SetVertexColor(1.0, 1.0, 1.0, 1) -- Brighten slightly on hover
        GameTooltip:SetOwner(settingsButton, "ANCHOR_LEFT")
        GameTooltip:SetText("Settings")
        GameTooltip:Show()
    end)

    settingsButton:SetScript("OnLeave", function()
        settingsIcon:SetVertexColor(0.8, 0.8, 0.8, 1) -- Back to muted color
        GameTooltip:Hide()
    end)

    -- Create the new UI layout
    self:CreateStatCardsSection(frame)
    self:CreateCharacterTable(frame)

    -- Initialize frame references
    self:InitializeFrameReferences(frame)

    -- Apply minimal styling
    self:ApplyMinimalStyling(frame)

    self.mainFrame = frame
    self:UpdateDisplay()
end

function MTracks:CreateCharacterTable(parentFrame)
    -- Create table header (more compact)
    local headerFrame = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")
    headerFrame:SetSize(1030, 30)                                             -- Reduced width and height
    headerFrame:SetPoint("TOP", parentFrame.statCardsFrame, "BOTTOM", 0, -15) -- Reduced gap

    -- Header backdrop - minimal style
    local headerBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = nil,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

    headerFrame:SetBackdrop(headerBackdrop)
    headerFrame:SetBackdropColor(unpack(COLORS.header))

    -- Header columns
    local headers = {
        { text = "Character",     width = 200, align = "LEFT" },
        { text = "Applied",       width = 80,  align = "CENTER" },
        { text = "Invited",       width = 80,  align = "CENTER" },
        { text = "Declined",      width = 80,  align = "CENTER" },
        { text = "Cancelled",     width = 80,  align = "CENTER" },
        { text = "Success Rate",  width = 110, align = "CENTER" },
        { text = "Decline Rate",  width = 110, align = "CENTER" },
        { text = "Cancel Rate",   width = 110, align = "CENTER" },
        { text = "Last Activity", width = 140, align = "CENTER" }
    }

    local xOffset = 35 -- Center the table content better
    for i, header in ipairs(headers) do
        local headerText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerText:SetSize(header.width, 20)
        headerText:SetPoint("LEFT", headerFrame, "LEFT", xOffset, 0)
        headerText:SetText(header.text)
        headerText:SetTextColor(1, 1, 1, 1)
        headerText:SetJustifyH(header.align)
        xOffset = xOffset + header.width
    end

    -- Create scrollable content area
    local scrollFrame = CreateFrame("ScrollFrame", "MTracksCharacterScrollFrame", parentFrame,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(1030, 260)                            -- Further reduced to prevent overflow
    scrollFrame:SetPoint("TOP", headerFrame, "BOTTOM", 0, -3) -- Tighter spacing

    -- Scroll content frame
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1030, 200) -- Further reduced to match scroll frame
    scrollFrame:SetScrollChild(scrollChild)

    -- Store references for updates
    parentFrame.characterTable = {
        headerFrame = headerFrame,
        scrollFrame = scrollFrame,
        scrollChild = scrollChild,
        headers = headers
    }
end

function MTracks:CreateStatCardsSection(parentFrame)
    -- Create stat cards container above character table (more compact)
    local cardsFrame = CreateFrame("Frame", nil, parentFrame)
    cardsFrame:SetSize(1030, 200)                          -- Reduced: width by 30px, height by 40px
    cardsFrame:SetPoint("TOP", parentFrame, "TOP", 0, -10) -- Moved up significantly since logo is now outside

    -- Store card references
    parentFrame.statCards = {}
    parentFrame.statCardsFrame = cardsFrame

    -- Create cards in 4x3 grid with special handling for centered Applications card
    for i, cardConfig in ipairs(STAT_CARDS) do
        local row, col = cardConfig.pos[1], cardConfig.pos[2]
        local card = self:CreateStatCard(cardsFrame, cardConfig)

        -- Position card in grid with dynamic sizing (more compact)
        local frameWidth = 1030
        local cardSpacing = 12 -- Further reduced spacing
        local cardHeight = 48  -- Even more compact
        local x, y, cardWidth

        if row == 1 then
            -- Row 1: 2 cards (Applications + Hosted), centered
            cardWidth = (frameWidth * 0.3) -- Smaller cards
            local totalWidth = (cardWidth * 2) + cardSpacing
            local startX = (frameWidth - totalWidth) / 2
            x = startX + (col - 1) * (cardWidth + cardSpacing)
        elseif row == 2 or row == 3 then
            -- Row 2 & 3: 4 cards each, evenly distributed
            cardWidth = (frameWidth - (cardSpacing * 5)) / 4 -- 4 cards with 5 spacings
            x = cardSpacing + (col - 1) * (cardWidth + cardSpacing)
        end

        card:SetSize(cardWidth, cardHeight)

        -- Update sparkline size based on card width
        card.UpdateSparklineSize()

        y = -8 - (row - 1) * 60 -- More compact vertical spacing
        card:SetPoint("TOPLEFT", cardsFrame, "TOPLEFT", x, y)

        -- Store reference for updates
        parentFrame.statCards[cardConfig.key] = {
            card = card,
            valueText = card.valueText,
            sparklineFrame = card.sparklineFrame,
            config = cardConfig
        }
    end
end

function MTracks:CreateStatCard(parent, config)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    -- Size will be set dynamically by the caller

    -- Card background with subtle border
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    card:SetBackdrop(backdrop)
    card:SetBackdropColor(unpack(config.bgColor))
    -- Use themed border color if available, fallback to default
    local borderColor = config.borderColor or CARD_COLORS.card_border
    card:SetBackdropBorderColor(unpack(borderColor))

    -- Combined text container to center the entire value + label combination
    local textContainer = CreateFrame("Frame", nil, card)
    textContainer:SetPoint("TOP", card, "TOP", 0, -8)
    textContainer:SetSize(200, 20) -- Large enough to contain both texts

    -- Value text (number)
    local value = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    value:SetPoint("LEFT", textContainer, "LEFT", 0, 0)
    value:SetJustifyH("LEFT")
    card.valueText = value

    -- Label text positioned right after the value with some spacing
    local labelText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    labelText:SetPoint("LEFT", value, "RIGHT", 5, 0)
    labelText:SetJustifyH("LEFT")
    labelText:SetTextColor(0.5, 0.5, 0.5) -- Darker grey
    card.labelElement = labelText

    -- Store the label and colors for dynamic updates
    card.labelText = config.label
    card.valueColor = config.valueColor

    -- Function to update both the value and label elements and center them
    card.UpdateValueText = function(numberValue)
        -- Update the main value with color
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(config.valueColor[1] * 255),
            math.floor(config.valueColor[2] * 255),
            math.floor(config.valueColor[3] * 255))

        value:SetText(colorCode .. numberValue .. "|r")

        -- Update the smaller label element with lowercase text and dash
        local lowercaseLabel = string.lower(config.label)
        card.labelElement:SetText("- " .. lowercaseLabel)

        -- Ensure label color stays dark grey (in case it gets overridden by theme)
        card.labelElement:SetTextColor(0.5, 0.5, 0.5)

        -- Calculate the total width of both texts and center the container
        local valueWidth = value:GetStringWidth()
        local labelWidth = labelText:GetStringWidth()
        local totalWidth = valueWidth + 5 + labelWidth -- 5px spacing

        -- Center the container based on total text width
        textContainer:SetSize(totalWidth, 20)
        textContainer:SetPoint("TOP", card, "TOP", 0, -8)
    end

    -- Set initial text
    card.UpdateValueText("0")

    -- Sparkline area - will be sized dynamically after card is sized
    local sparklineFrame = CreateFrame("Frame", nil, card)
    sparklineFrame:SetPoint("BOTTOM", card, "BOTTOM", 0, 6)
    card.sparklineFrame = sparklineFrame

    -- Function to update sparkline size based on card size
    card.UpdateSparklineSize = function()
        local cardWidth = card:GetWidth()
        local sparklineWidth = cardWidth - 40 -- 20px padding on each side
        local sparklineHeight = 20            -- Increased height for better visibility
        sparklineFrame:SetSize(sparklineWidth, sparklineHeight)
    end

    return card
end

function MTracks:CreateAccountStatCards(parentFrame, accountData)
    -- Clear existing content
    for _, child in ipairs({ parentFrame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Use the same stat cards as main window (account-wide data)
    local ACCOUNT_STAT_CARDS = {
        {
            key = "applied",
            label = "Applied",
            value = accountData.totalApplied or 0,
            category = "account", -- Account-wide stat
            bgColor = CARD_COLORS.card_primary,
            borderColor = CARD_COLORS.account_border,
            valueColor = CARD_COLORS.applied,
            sparklineColor = CARD_COLORS.sparkline_positive
        },
        {
            key = "successRate",
            label = "Success Rate",
            value = ((accountData.totalApplied or 0) > 0 and FormatPercentage((accountData.totalAccepted or 0) / accountData.totalApplied * 100) or "0.0%"),
            category = "account", -- Account-wide stat
            bgColor = CARD_COLORS.card_primary,
            borderColor = CARD_COLORS.account_border,
            valueColor = CARD_COLORS.success,
            sparklineColor = CARD_COLORS.sparkline_positive
        },
        {
            key = "accepted",
            label = "Accepted",
            value = accountData.totalAccepted or 0,
            category = "account", -- Account-wide stat
            bgColor = CARD_COLORS.card_secondary,
            borderColor = CARD_COLORS.account_border,
            valueColor = CARD_COLORS.invited,
            sparklineColor = CARD_COLORS.sparkline_positive
        },
        {
            key = "declined",
            label = "Declined",
            value = accountData.totalDeclined or 0,
            category = "account", -- Account-wide stat
            bgColor = CARD_COLORS.card_secondary,
            borderColor = CARD_COLORS.account_border,
            valueColor = CARD_COLORS.decline,
            sparklineColor = CARD_COLORS.sparkline_negative
        },
        {
            key = "cancelled",
            label = "Cancelled",
            value = accountData.totalCancelled or 0,
            category = "account", -- Account-wide stat
            bgColor = CARD_COLORS.card_secondary,
            borderColor = CARD_COLORS.account_border,
            valueColor = CARD_COLORS.cancelled,
            sparklineColor = CARD_COLORS.sparkline_neutral
        }
    }

    -- Create 5 cards in a single row
    for i, cardConfig in ipairs(ACCOUNT_STAT_CARDS) do
        local card = self:CreateStatCard(parentFrame, cardConfig)

        -- Position cards in a row
        local cardWidth = 130                                          -- Smaller cards for character view
        local cardSpacing = 10
        local startX = (700 - (cardWidth * 5) - (cardSpacing * 4)) / 2 -- Center the row

        local x = startX + (i - 1) * (cardWidth + cardSpacing)
        card:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, -20)
        card:SetSize(cardWidth, 60) -- Override the default size for character cards

        -- Adjust text positioning for smaller cards
        card.valueText:SetPoint("TOP", card, "TOP", 0, -8)

        -- Update sparkline size to use full card width (removing hardcoded size)
        card.UpdateSparklineSize()
        card.sparklineFrame:SetPoint("BOTTOM", card, "BOTTOM", 0, 4)

        -- Update the values using the new combined format
        if type(cardConfig.value) == "string" then
            card.UpdateValueText(cardConfig.value)                    -- Already formatted (e.g., percentage)
        else
            card.UpdateValueText(self:FormatNumber(cardConfig.value)) -- Format numbers
        end
        if cardConfig.sparklineColor then
            local metricKey = cardConfig.key == "applied" and "totalApplied" or
                cardConfig.key == "accepted" and "totalAccepted" or
                cardConfig.key == "declined" and "totalDeclined" or
                cardConfig.key == "cancelled" and "totalCancelled" or
                cardConfig.key == "successRate" and "totalAccepted" or nil
            if metricKey then
                self:UpdateSparkline(card.sparklineFrame, metricKey, cardConfig.sparklineColor)
            end
        end
    end
end

function MTracks:CreateCharacterStatCards(parentFrame, charData)
    -- Clear existing content
    for _, child in ipairs({ parentFrame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Character stat card configuration using EXACT same logic as main window UpdateCharacterStats()
    local appliedCount = charData.applied or 0
    local acceptedCount = charData.accepted or 0
    local declinedCount = charData.declined or 0

    local cancelledCount = charData.cancelled or 0

    -- Hosting statistics
    local hostedCount = charData.hosted or 0
    local hostedSuccessfulCount = charData.hostedSuccessful or 0
    local hostedCancelledCount = charData.hostedCancelled or 0

    -- Use same success rate calculation as main window (line 1525)
    local successRate = appliedCount > 0 and (acceptedCount / appliedCount * 100) or 0
    -- Use same decline rate calculation as main window (line 1532)
    local declineRate = appliedCount > 0 and (declinedCount / appliedCount * 100) or 0

    local CHARACTER_STAT_CARDS = {
        {
            key = "applied",
            label = "Applications",
            value = appliedCount,
            category = "character", -- Character-specific stat
            bgColor = CARD_COLORS.card_primary,
            borderColor = CARD_COLORS.character_border,
            valueColor = CARD_COLORS.applied,
            sparklineColor = CARD_COLORS.sparkline_positive
        },
        {
            key = "invited",
            label = "Invited",
            value = acceptedCount,
            category = "character", -- Character-specific stat
            bgColor = CARD_COLORS.card_secondary,
            borderColor = CARD_COLORS.character_border,
            valueColor = CARD_COLORS.invited,
            sparklineColor = CARD_COLORS.sparkline_positive
        },
        {
            key = "declined",
            label = "Declined",
            value = declinedCount,
            category = "character", -- Character-specific stat
            bgColor = CARD_COLORS.card_secondary,
            borderColor = CARD_COLORS.character_border,
            valueColor = CARD_COLORS.decline,
            sparklineColor = CARD_COLORS.sparkline_negative
        },
        {
            key = "cancelled",
            label = "Cancelled",
            value = cancelledCount,
            category = "character", -- Character-specific stat
            bgColor = CARD_COLORS.card_secondary,
            borderColor = CARD_COLORS.character_border,
            valueColor = CARD_COLORS.cancelled,
            sparklineColor = CARD_COLORS.sparkline_neutral
        }
        -- Removed hosting statistics cards per user request
    }

    -- Create cards in single row (4 application cards only)
    for i, cardConfig in ipairs(CHARACTER_STAT_CARDS) do
        local card = self:CreateStatCard(parentFrame, cardConfig)

        -- Position cards in single row (4 cards, centered)
        local frameWidth = 700
        local cardSpacing = 10
        local cardWidth = (frameWidth - (cardSpacing * 5)) / 4 -- 4 cards with 5 spacings
        local startX = (frameWidth - (cardWidth * 4) - (cardSpacing * 3)) / 2
        local x = startX + (i - 1) * (cardWidth + cardSpacing)
        local y = -20

        card:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", x, y)
        card:SetSize(cardWidth, 60)

        -- Update sparkline size for character cards
        card.UpdateSparklineSize()

        -- Adjust text positioning for smaller cards
        card.valueText:SetPoint("TOP", card, "TOP", 0, -8)

        -- Set the value using the new combined format
        if type(cardConfig.value) == "string" then
            card.UpdateValueText(cardConfig.value)                    -- Already formatted (percentages)
        else
            card.UpdateValueText(self:FormatNumber(cardConfig.value)) -- Format numbers
        end

        -- Add character-specific sparklines
        if cardConfig.sparklineColor then
            local metricKey = cardConfig.key == "applied" and "applied" or
                cardConfig.key == "invited" and "accepted" or
                cardConfig.key == "declined" and "declined" or
                cardConfig.key == "cancelled" and "cancelled" or
                cardConfig.key == "hosted" and "hosted" or
                cardConfig.key == "hostedSuccessful" and "hostedSuccessful" or
                cardConfig.key == "hostedCancelled" and "hostedCancelled" or nil
            if metricKey then
                self:UpdateCharacterSparkline(card.sparklineFrame, metricKey, cardConfig.sparklineColor, charData)
            end
        end
    end
end

function MTracks:GetSparklineDataKey(timestamp)
    -- Use hourly buckets for all data to provide consistent granularity
    local currentTime = timestamp or time()
    local hoursSinceEpoch = math.floor(currentTime / 3600) -- 3600 = 1 hour
    return string.format("hour_%d", hoursSinceEpoch)
end

function MTracks:InitializeSparklineData()
    local sparklineHistory = self.db.global.sparklineHistory

    -- Clean up data older than 7 days (168 hours)
    local currentTime = time()
    local sevenDaysAgo = currentTime - (7 * 86400)
    local cutoffHour = math.floor(sevenDaysAgo / 3600)

    for key, data in pairs(sparklineHistory) do
        -- Extract hour number from key format "hour_XXXXXX"
        local hourNum = tonumber(key:match("hour_(%d+)"))
        if hourNum and hourNum < cutoffHour then
            sparklineHistory[key] = nil
        elseif data.timestamp and data.timestamp < sevenDaysAgo then
            -- Fallback for old format data
            sparklineHistory[key] = nil
        end
    end
end

function MTracks:UpdateSparklineData(metricKey, value)
    local sparklineHistory = self.db.global.sparklineHistory
    local currentTime = time()
    local dataKey = self:GetSparklineDataKey(currentTime)




    -- Initialize bucket if it doesn't exist
    if not sparklineHistory[dataKey] then
        sparklineHistory[dataKey] = {
            timestamp = currentTime,
            totalApplied = 0,
            totalAccepted = 0,
            totalDeclined = 0,
            totalCancelled = 0,
            -- Hosting metrics
            totalHosted = 0,
            totalHostedSuccessful = 0,
            totalHostedCancelled = 0,
        }
    end

    -- Update the metric
    local oldValue = sparklineHistory[dataKey][metricKey] or 0
    sparklineHistory[dataKey][metricKey] = oldValue + value


    -- Clean up old data
    self:InitializeSparklineData()
end

function MTracks:RebuildSparklineHistory()
    -- Rebuild sparkline history from raw history data

    local sparklineHistory = self.db.global.sparklineHistory
    local globalHistory = self.db.global.history or {}

    -- Clear existing sparkline history to rebuild fresh
    for key, _ in pairs(sparklineHistory) do
        sparklineHistory[key] = nil
    end

    -- Process each history entry and aggregate into hourly buckets
    for _, entry in ipairs(globalHistory) do
        if entry.timestamp and entry.status then
            local hourKey = self:GetSparklineDataKey(entry.timestamp)

            -- Initialize bucket if it doesn't exist
            if not sparklineHistory[hourKey] then
                sparklineHistory[hourKey] = {
                    timestamp = entry.timestamp,
                    totalApplied = 0,
                    totalAccepted = 0,
                    totalDeclined = 0,
                    totalCancelled = 0,
                    -- Hosting metrics
                    totalHosted = 0,
                    totalHostedSuccessful = 0,
                    totalHostedCancelled = 0,
                }
            end

            -- Increment appropriate counters based on status
            if entry.status == "applied" then
                sparklineHistory[hourKey].totalApplied = sparklineHistory[hourKey].totalApplied + 1
            elseif entry.status == "invited" then
                sparklineHistory[hourKey].totalAccepted = sparklineHistory[hourKey].totalAccepted + 1
            elseif entry.status == "declined" or entry.status == "declined_delisted" or entry.status == "removed" then
                sparklineHistory[hourKey].totalDeclined = sparklineHistory[hourKey].totalDeclined + 1
            elseif entry.status == "cancelled" or entry.status == "withdrawapplication" then
                sparklineHistory[hourKey].totalCancelled = sparklineHistory[hourKey].totalCancelled + 1
            elseif entry.status == "hosting" then
                -- Handle hosting events
                if entry.eventType == "group_created" then
                    sparklineHistory[hourKey].totalHosted = sparklineHistory[hourKey].totalHosted + 1
                elseif entry.eventType == "group_completed" then
                    sparklineHistory[hourKey].totalHostedSuccessful = sparklineHistory[hourKey].totalHostedSuccessful + 1
                elseif entry.eventType == "group_cancelled" then
                    sparklineHistory[hourKey].totalHostedCancelled = sparklineHistory[hourKey].totalHostedCancelled + 1
                end
            end
        end
    end

    -- Clean up old data after rebuilding
    self:InitializeSparklineData()
end

function MTracks:CalculateRollingAverage(dataPoints, windowSize)
    -- Calculate rolling average with the specified window size
    local rollingAvg = {}
    windowSize = windowSize or 3 -- Default 3-hour window

    for i = 1, #dataPoints do
        local sum = 0
        local count = 0
        local startIdx = math.max(1, i - windowSize + 1)

        for j = startIdx, i do
            if dataPoints[j] then
                sum = sum + dataPoints[j]
                count = count + 1
            end
        end

        rollingAvg[i] = count > 0 and (sum / count) or 0
    end

    return rollingAvg
end

function MTracks:CalculateStandardDeviation(dataPoints, mean)
    -- Calculate standard deviation for trend analysis
    if #dataPoints < 2 then return 0 end

    local variance = 0
    local count = 0

    for _, value in ipairs(dataPoints) do
        if value and value > 0 then
            local diff = value - mean
            variance = variance + (diff * diff)
            count = count + 1
        end
    end

    return count > 1 and math.sqrt(variance / (count - 1)) or 0
end

function MTracks:ApplyExponentialSmoothing(dataPoints, alpha)
    -- Apply exponential smoothing to reduce dramatic jumps
    if #dataPoints == 0 then return {} end

    alpha = alpha or 0.3 -- Smoothing factor (0 = no smoothing, 1 = no history)
    local smoothed = {}
    smoothed[1] = dataPoints[1] or 0

    for i = 2, #dataPoints do
        local currentValue = dataPoints[i] or 0
        smoothed[i] = alpha * currentValue + (1 - alpha) * smoothed[i - 1]
    end

    return smoothed
end

function MTracks:CalculateTrendDirection(dataPoints, windowSize)
    -- Calculate trend direction using linear regression on recent data
    windowSize = windowSize or 6 -- Use last 6 hours for trend
    if #dataPoints < 2 then return 0 end

    local startIdx = math.max(1, #dataPoints - windowSize + 1)
    local n = #dataPoints - startIdx + 1
    if n < 2 then return 0 end

    local sumX = 0
    local sumY = 0
    local sumXY = 0
    local sumXX = 0

    for i = startIdx, #dataPoints do
        local x = i - startIdx + 1
        local y = dataPoints[i] or 0
        sumX = sumX + x
        sumY = sumY + y
        sumXY = sumXY + (x * y)
        sumXX = sumXX + (x * x)
    end

    local denominator = n * sumXX - sumX * sumX
    if denominator == 0 then return 0 end

    local slope = (n * sumXY - sumX * sumY) / denominator
    return slope -- Positive = increasing trend, Negative = decreasing trend
end

function MTracks:DrawSparkline(sparklineFrame, metricKey, color)
    -- Clear existing sparkline
    if sparklineFrame.segments then
        for _, segment in ipairs(sparklineFrame.segments) do
            segment:Hide()
        end
    end
    sparklineFrame.segments = {}

    local sparklineHistory = self.db.global.sparklineHistory
    local currentTime = time()
    local currentHour = math.floor(currentTime / 3600)

    -- Standardized sparkline configuration
    local SPARKLINE_HOURS = 24 -- Always show last 24 hours
    local SPARKLINE_WIDTH = sparklineFrame:GetWidth()
    if not SPARKLINE_WIDTH or SPARKLINE_WIDTH <= 0 then
        SPARKLINE_WIDTH = 160 -- Fallback width
    end
    local SEGMENT_WIDTH = SPARKLINE_WIDTH / SPARKLINE_HOURS

    -- Collect hourly data points from newest to oldest (right to left display)
    local rawDataPoints = {}
    local rateDataPoints = {}
    local totalDataPoints = 0

    for i = 0, SPARKLINE_HOURS - 1 do
        local hourKey = string.format("hour_%d", currentHour - i)
        local data = sparklineHistory[hourKey]
        local value = data and data[metricKey] or 0
        totalDataPoints = totalDataPoints + value
        -- Insert at beginning to maintain chronological order (oldest first)
        table.insert(rawDataPoints, 1, value)
    end

    -- Calculate rates: use 3-hour rolling windows to smooth out noise and show meaningful trends
    local windowSize = 3
    for i = 1, #rawDataPoints do
        local windowSum = 0
        local windowCount = 0
        local startIdx = math.max(1, i - windowSize + 1)
        local endIdx = i

        for j = startIdx, endIdx do
            windowSum = windowSum + rawDataPoints[j]
            windowCount = windowCount + 1
        end

        -- Rate = average events per hour over the window
        local rate = windowSum / windowCount
        table.insert(rateDataPoints, rate)
    end

    -- Apply light additional smoothing to rate data for better visualization
    local smoothedRates = self:ApplyExponentialSmoothing(rateDataPoints, 0.7) -- Moderate smoothing

    -- Calculate trend direction for visual feedback (use longer window for rates)
    local trendSlope = self:CalculateTrendDirection(smoothedRates, 8)

    -- Find max rate for normalization, with minimum baseline for better scaling
    local maxRate = 0
    local minRate = math.huge
    for _, rate in ipairs(smoothedRates) do
        maxRate = math.max(maxRate, rate)
        if rate > 0 then
            minRate = math.min(minRate, rate)
        end
    end

    -- Ensure we have meaningful scaling even with low activity
    if maxRate <= 0 then
        maxRate = 1
    elseif maxRate - (minRate == math.huge and 0 or minRate) < 0.5 then
        -- If the range is very small, artificially expand it for better visibility
        maxRate = maxRate + 0.5
    end

    local HEIGHT = sparklineFrame:GetHeight()
    if not HEIGHT or HEIGHT <= 0 then
        HEIGHT = 16 -- Fallback height
    end

    -- Draw sparkline segments using rate data for meaningful trend visualization
    for i = 1, #smoothedRates do
        local x = (i - 1) * SEGMENT_WIDTH
        local rate = smoothedRates[i]
        local normalizedRate = rate / maxRate
        local segmentHeight = normalizedRate * HEIGHT

        local segment = sparklineFrame:CreateTexture(nil, "ARTWORK")
        segment:SetTexture("Interface\\BUTTONS\\WHITE8X8")

        -- Color coding based on trend and rate intensity
        local alpha = 0.8
        local r, g, b = color[1], color[2], color[3]

        -- Enhance color based on rate intensity and trend
        if rate > 0 then
            local intensity = math.min(1, normalizedRate * 1.5) -- Boost intensity
            alpha = 0.5 + (intensity * 0.4)                     -- Range from 0.5 to 0.9

            -- Add trend-based color modulation for recent hours
            if i > #smoothedRates - 6 then -- Last 6 hours get trend coloring
                if trendSlope > 0.1 then
                    -- Positive trend: add green tint
                    g = math.min(1, g + 0.15)
                elseif trendSlope < -0.1 then
                    -- Negative trend: add red tint
                    r = math.min(1, r + 0.15)
                end
            end
        else
            alpha = 0.3 -- Lower alpha for zero values
        end

        segment:SetVertexColor(r, g, b, alpha)
        segment:SetSize(SEGMENT_WIDTH, math.max(1, segmentHeight)) -- Minimum 1px height for visibility
        segment:SetPoint("BOTTOMLEFT", sparklineFrame, "BOTTOMLEFT", x, 0)

        table.insert(sparklineFrame.segments, segment)
    end

    -- Calculate rate statistics for tooltips
    local rateSum = 0
    local nonZeroRateCount = 0
    local currentRate = smoothedRates[#smoothedRates] or 0 -- Most recent rate

    for _, rate in ipairs(smoothedRates) do
        rateSum = rateSum + rate
        if rate > 0 then
            nonZeroRateCount = nonZeroRateCount + 1
        end
    end

    local meanRate = #smoothedRates > 0 and (rateSum / #smoothedRates) or 0
    local recentRate = 0
    if #smoothedRates >= 6 then
        -- Calculate recent average (last 6 hours)
        local recentSum = 0
        for i = #smoothedRates - 5, #smoothedRates do
            recentSum = recentSum + smoothedRates[i]
        end
        recentRate = recentSum / 6
    else
        recentRate = meanRate
    end

    -- Calculate rate variance for trend confidence
    local rateVariance = 0
    if #smoothedRates > 0 then
        for _, rate in ipairs(smoothedRates) do
            rateVariance = rateVariance + math.pow(rate - meanRate, 2)
        end
        rateVariance = rateVariance / #smoothedRates
    end
    local rateStdDev = math.sqrt(rateVariance)

    -- Store enhanced trend information for tooltips
    sparklineFrame.trendSlope = trendSlope
    sparklineFrame.meanRate = meanRate
    sparklineFrame.currentRate = currentRate
    sparklineFrame.recentRate = recentRate
    sparklineFrame.rateStdDev = rateStdDev
    sparklineFrame.maxRate = maxRate

    -- Add rate-focused tooltip functionality
    sparklineFrame:EnableMouse(true)
    sparklineFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(sparklineFrame, "ANCHOR_TOP")
        GameTooltip:ClearLines()

        local metricName = metricKey:gsub("total", ""):gsub("^%l", string.upper) -- Clean up metric name
        GameTooltip:SetText("24-Hour " .. metricName .. " Rate Trend", 1, 0.82, 0, true)

        -- Current rate info
        GameTooltip:AddLine(string.format("Current Rate: %.1f/hour", currentRate), 1, 1, 1)

        -- Recent trend
        local trendText = ""
        local trendColor = { 0.8, 0.8, 0.8 }
        if trendSlope > 0.1 then
            trendText = "Increasing trend"
            trendColor = { 0.5, 1, 0.5 } -- Green
        elseif trendSlope < -0.1 then
            trendText = "Decreasing trend"
            trendColor = { 1, 0.5, 0.5 } -- Red
        else
            trendText = "Stable trend"
            trendColor = { 0.8, 0.8, 0.8 } -- Gray
        end
        GameTooltip:AddLine(trendText, trendColor[1], trendColor[2], trendColor[3])

        -- Rate comparison
        GameTooltip:AddLine(string.format("Recent 6h: %.1f/hour", recentRate), 0.7, 0.7, 0.7)
        GameTooltip:AddLine(string.format("24h Average: %.1f/hour", meanRate), 0.7, 0.7, 0.7)

        -- Explanation
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Shows activity rate over time to identify trends", 0.6, 0.6, 1, true)

        GameTooltip:Show()
    end)

    sparklineFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function MTracks:UpdateSparkline(sparklineFrame, metricKey, color)
    -- Initialize sparkline data and draw
    self:InitializeSparklineData()

    -- Ensure the sparkline frame has the correct size before drawing
    if sparklineFrame.GetParent and sparklineFrame:GetParent().UpdateSparklineSize then
        sparklineFrame:GetParent().UpdateSparklineSize()
    end

    self:DrawSparkline(sparklineFrame, metricKey, color)
end

function MTracks:UpdateCharacterSparkline(sparklineFrame, metricKey, color, charData)
    -- Ensure the sparkline frame has the correct size before drawing
    if sparklineFrame.GetParent and sparklineFrame:GetParent().UpdateSparklineSize then
        sparklineFrame:GetParent().UpdateSparklineSize()
    end

    -- Generate character-specific sparkline from history data
    self:DrawCharacterSparkline(sparklineFrame, metricKey, color, charData)
end

function MTracks:DrawCharacterSparkline(sparklineFrame, metricKey, color, charData)
    -- Clear existing sparkline
    if sparklineFrame.segments then
        for _, segment in ipairs(sparklineFrame.segments) do
            segment:Hide()
        end
    end
    sparklineFrame.segments = {}

    local currentTime = time()
    local currentHour = math.floor(currentTime / 3600)
    local characterKey = charData.key or (charData.name .. "-" .. charData.realm)

    -- Standardized sparkline configuration - same as account sparklines
    local SPARKLINE_HOURS = 24 -- Always show last 24 hours
    local SPARKLINE_WIDTH = sparklineFrame:GetWidth()
    if not SPARKLINE_WIDTH or SPARKLINE_WIDTH <= 0 then
        SPARKLINE_WIDTH = 100 -- Fallback width for character cards
    end
    local SEGMENT_WIDTH = SPARKLINE_WIDTH / SPARKLINE_HOURS

    -- Collect hourly data points from character history
    local rawDataPoints = {}
    local globalHistory = self.db.global.history or {}

    for i = 0, SPARKLINE_HOURS - 1 do
        local hourStart = (currentHour - i) * 3600
        local hourEnd = hourStart + 3600
        local count = 0

        for _, entry in ipairs(globalHistory) do
            local entryCharKey = (entry.characterName or "") .. "-" .. (entry.realmName or "")
            if entryCharKey == characterKey and entry.timestamp then
                if entry.timestamp >= hourStart and entry.timestamp < hourEnd then
                    -- Count the specific metric
                    if metricKey == "applied" and entry.status == "applied" then
                        count = count + 1
                    elseif metricKey == "accepted" and entry.status == "invited" then
                        count = count + 1
                    elseif metricKey == "declined" and (entry.status == "declined" or entry.status == "declined_delisted" or entry.status == "removed") then
                        count = count + 1
                    elseif metricKey == "cancelled" and (entry.status == "cancelled" or entry.status == "withdrawapplication") then
                        count = count + 1
                    end
                end
            end
        end

        -- Insert at beginning to maintain chronological order (oldest first)
        table.insert(rawDataPoints, 1, count)
    end

    -- Calculate rates using same approach as account sparklines for consistency
    local rateDataPoints = {}
    local windowSize = 3
    for i = 1, #rawDataPoints do
        local windowSum = 0
        local windowCount = 0
        local startIdx = math.max(1, i - windowSize + 1)
        local endIdx = i

        for j = startIdx, endIdx do
            windowSum = windowSum + rawDataPoints[j]
            windowCount = windowCount + 1
        end

        -- Rate = average events per hour over the window
        local rate = windowSum / windowCount
        table.insert(rateDataPoints, rate)
    end

    -- Apply light additional smoothing to rate data for better visualization
    local smoothedRates = self:ApplyExponentialSmoothing(rateDataPoints, 0.7) -- Moderate smoothing
    local trendSlope = self:CalculateTrendDirection(smoothedRates, 8)

    -- Find max rate for normalization, with minimum baseline for better scaling
    local maxRate = 0
    local minRate = math.huge
    for _, rate in ipairs(smoothedRates) do
        maxRate = math.max(maxRate, rate)
        if rate > 0 then
            minRate = math.min(minRate, rate)
        end
    end

    -- Ensure we have meaningful scaling even with low activity
    if maxRate <= 0 then
        maxRate = 1
    elseif maxRate - (minRate == math.huge and 0 or minRate) < 0.5 then
        -- If the range is very small, artificially expand it for better visibility
        maxRate = maxRate + 0.5
    end

    local HEIGHT = sparklineFrame:GetHeight()
    if not HEIGHT or HEIGHT <= 0 then
        HEIGHT = 14 -- Fallback height for character cards
    end

    -- Draw sparkline segments using rate data (same approach as account sparklines)
    for i = 1, #smoothedRates do
        local x = (i - 1) * SEGMENT_WIDTH
        local rate = smoothedRates[i]
        local normalizedRate = rate / maxRate
        local segmentHeight = normalizedRate * HEIGHT

        local segment = sparklineFrame:CreateTexture(nil, "ARTWORK")
        segment:SetTexture("Interface\\BUTTONS\\WHITE8X8")

        -- Color coding based on trend and rate intensity
        local alpha = 0.8
        local r, g, b = color[1], color[2], color[3]

        -- Enhance color based on rate intensity and trend
        if rate > 0 then
            local intensity = math.min(1, normalizedRate * 1.5) -- Boost intensity
            alpha = 0.5 + (intensity * 0.4)                     -- Range from 0.5 to 0.9

            -- Add trend-based color modulation for recent hours
            if i > #smoothedRates - 6 then -- Last 6 hours get trend coloring
                if trendSlope > 0.1 then
                    -- Positive trend: add green tint
                    g = math.min(1, g + 0.15)
                elseif trendSlope < -0.1 then
                    -- Negative trend: add red tint
                    r = math.min(1, r + 0.15)
                end
            end
        else
            alpha = 0.3 -- Lower alpha for zero values
        end

        segment:SetVertexColor(r, g, b, alpha)
        segment:SetSize(SEGMENT_WIDTH, math.max(1, segmentHeight)) -- Minimum 1px height for visibility
        segment:SetPoint("BOTTOMLEFT", sparklineFrame, "BOTTOMLEFT", x, 0)

        table.insert(sparklineFrame.segments, segment)
    end

    -- Calculate rate statistics for tooltips (same as account sparklines)
    local rateSum = 0
    local currentRate = smoothedRates[#smoothedRates] or 0 -- Most recent rate

    for _, rate in ipairs(smoothedRates) do
        rateSum = rateSum + rate
    end

    local meanRate = #smoothedRates > 0 and (rateSum / #smoothedRates) or 0
    local recentRate = 0
    if #smoothedRates >= 6 then
        -- Calculate recent average (last 6 hours)
        local recentSum = 0
        for i = #smoothedRates - 5, #smoothedRates do
            recentSum = recentSum + smoothedRates[i]
        end
        recentRate = recentSum / 6
    else
        recentRate = meanRate
    end

    -- Store enhanced trend information for tooltips
    sparklineFrame.trendSlope = trendSlope
    sparklineFrame.meanRate = meanRate
    sparklineFrame.currentRate = currentRate
    sparklineFrame.recentRate = recentRate
    sparklineFrame.maxRate = maxRate

    -- Add rate-focused tooltip functionality for character sparklines
    sparklineFrame:EnableMouse(true)
    sparklineFrame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(sparklineFrame, "ANCHOR_TOP")
        GameTooltip:ClearLines()

        local metricName = metricKey:gsub("^%l", string.upper) -- Capitalize first letter
        local charName = charData.name or "Character"
        GameTooltip:SetText(charName .. " - " .. metricName .. " Rate (24h)", 1, 0.82, 0, true)

        -- Current rate info
        GameTooltip:AddLine(string.format("Current Rate: %.1f/hour", currentRate), 1, 1, 1)

        -- Recent trend
        local trendText = ""
        local trendColor = { 0.8, 0.8, 0.8 }
        if trendSlope > 0.1 then
            trendText = "Increasing trend"
            trendColor = { 0.5, 1, 0.5 } -- Green
        elseif trendSlope < -0.1 then
            trendText = "Decreasing trend"
            trendColor = { 1, 0.5, 0.5 } -- Red
        else
            trendText = "Stable trend"
            trendColor = { 0.8, 0.8, 0.8 } -- Gray
        end
        GameTooltip:AddLine(trendText, trendColor[1], trendColor[2], trendColor[3])

        -- Rate comparison
        GameTooltip:AddLine(string.format("Recent 6h: %.1f/hour", recentRate), 0.7, 0.7, 0.7)
        GameTooltip:AddLine(string.format("24h Average: %.1f/hour", meanRate), 0.7, 0.7, 0.7)

        -- Explanation
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Shows activity rate over time to identify trends", 0.6, 0.6, 1, true)

        GameTooltip:Show()
    end)

    sparklineFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function MTracks:CreateAccountSection(parentFrame)
    local section = CreateFrame("Frame", "MTracksMainFrameAccountSection", parentFrame, "BackdropTemplate")
    section:SetSize(400, 200)
    section:SetPoint("TOPLEFT", 20, -60)

    -- Section backdrop - flat minimal
    local sectionBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = nil,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
    section:SetBackdrop(sectionBackdrop)
    section:SetBackdropColor(unpack(COLORS.header))

    -- Section title
    local title = section:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Account Statistics")
    title:SetTextColor(unpack(COLORS.text))

    -- Create stats labels and values
    local yOffset = -45
    local stats = { "Applied", "Success", "Decline", "Delisted", "Removed", "LastActivity" }

    for i, stat in ipairs(stats) do
        -- Label
        local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 20, yOffset)
        label:SetText(stat .. ":")
        label:SetTextColor(unpack(COLORS.text))

        -- Value
        local value = section:CreateFontString("MTracksMainFrameAccountSection" .. stat .. "Value", "OVERLAY",
            "GameFontHighlight")
        value:SetPoint("TOPRIGHT", -20, yOffset)
        value:SetText("0")
        value:SetTextColor(unpack(COLORS.text))

        yOffset = yOffset - 25
    end
end

function MTracks:CreateCharacterSection(parentFrame)
    local section = CreateFrame("Frame", "MTracksMainFrameCharacterSection", parentFrame, "BackdropTemplate")
    section:SetSize(400, 200)
    section:SetPoint("TOPRIGHT", -20, -60)

    -- Section backdrop - flat minimal
    local sectionBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = nil,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }
    section:SetBackdrop(sectionBackdrop)
    section:SetBackdropColor(unpack(COLORS.header))

    -- Character title (will be set dynamically)
    local title = section:CreateFontString("MTracksMainFrameCharacterSectionTitle", "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Character Statistics")
    title:SetTextColor(unpack(COLORS.text))

    -- Create stats labels and values
    local yOffset = -45
    local stats = { "Applied", "Success", "Decline", "Delisted", "Removed", "LastActivity" }

    for i, stat in ipairs(stats) do
        -- Label
        local label = section:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 20, yOffset)
        label:SetText(stat .. ":")
        label:SetTextColor(unpack(COLORS.text))

        -- Value
        local value = section:CreateFontString("MTracksMainFrameCharacterSection" .. stat .. "Value", "OVERLAY",
            "GameFontHighlight")
        value:SetPoint("TOPRIGHT", -20, yOffset)
        value:SetText("0")
        value:SetTextColor(unpack(COLORS.text))

        yOffset = yOffset - 25
    end
end

function MTracks:InitializeFrameReferences(frame)
    -- Set up references to child frames and their elements
    local frameName = frame:GetName()
    if not frameName then return end

    -- Account section references
    frame.accountAppliedValue = _G[frameName .. "AccountSectionAppliedValue"]
    frame.accountSuccessValue = _G[frameName .. "AccountSectionSuccessValue"]
    frame.accountDeclineValue = _G[frameName .. "AccountSectionDeclineValue"]
    frame.accountDelistedValue = _G[frameName .. "AccountSectionDelistedValue"]
    frame.accountRemovedValue = _G[frameName .. "AccountSectionRemovedValue"]
    frame.accountLastActivityValue = _G[frameName .. "AccountSectionLastActivityValue"]

    -- Character section references
    frame.charAppliedValue = _G[frameName .. "CharacterSectionAppliedValue"]
    frame.charSuccessValue = _G[frameName .. "CharacterSectionSuccessValue"]
    frame.charDeclineValue = _G[frameName .. "CharacterSectionDeclineValue"]
    frame.charDelistedValue = _G[frameName .. "CharacterSectionDelistedValue"]
    frame.charRemovedValue = _G[frameName .. "CharacterSectionRemovedValue"]
    frame.charLastActivityValue = _G[frameName .. "CharacterSectionLastActivityValue"]
    frame.charTitle = _G[frameName .. "CharacterSectionTitle"]

    -- Legacy support - these may not exist anymore since we don't create progress bars
    -- but keep the references for compatibility
    frame.successBar = nil
    frame.declineBar = nil
    frame.removeBar = nil
end

function MTracks:ApplyMinimalStyling(frame)
    -- Apply minimal flat design backdrop to main frame
    if frame == self.mainFrame then
        local backdrop = {
            bgFile = "Interface\\Buttons\\WHITE8x8",
            tile = false,
            edgeFile = nil,
            edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        }
        frame:SetBackdrop(backdrop)
        frame:SetBackdropColor(unpack(COLORS.background))
    end

    -- Style text elements (skip title - already styled with gradient)

    -- Recursively style all text elements
    self:StyleTextElements(frame)
end

function MTracks:StyleTextElements(frame)
    if not frame or not frame.GetChildren or not frame.GetRegions then return end

    -- Style font strings (but skip label elements that should stay dark grey)
    for _, child in ipairs({ frame:GetChildren() }) do
        if child and child.GetObjectType and child:GetObjectType() == "FontString" and child.SetTextColor then
            -- Skip label elements - they have their own color set
            if not (child:GetParent() and child:GetParent().labelElement == child) then
                child:SetTextColor(unpack(COLORS.text))
            end
        end
        -- Recursively style children
        if child and child.GetChildren then
            self:StyleTextElements(child)
        end
    end

    -- Also check regions (for font strings in layers) but skip label elements
    for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" and region.SetTextColor then
            -- Skip label elements - they have their own color set
            if not (region:GetParent() and region:GetParent().labelElement == region) then
                region:SetTextColor(unpack(COLORS.text))
            end
        end
    end
end

function MTracks:StyleButton(button)
    if not button or not button.CreateTexture or not button.SetNormalTexture then return end

    local normalTexture = button:CreateTexture(nil, "BACKGROUND")
    if normalTexture then
        normalTexture:SetColorTexture(unpack(COLORS.accent))
        normalTexture:SetAllPoints()
        button:SetNormalTexture(normalTexture)
    end

    local highlightTexture = button:CreateTexture(nil, "HIGHLIGHT")
    if highlightTexture then
        highlightTexture:SetColorTexture(0.4, 0.6, 0.9, 0.5)
        highlightTexture:SetAllPoints()
        button:SetHighlightTexture(highlightTexture)
    end

    -- Style button text (buttons use font strings for text)
    local fontString = button:GetFontString()
    if fontString and fontString.SetTextColor then
        fontString:SetTextColor(unpack(COLORS.text))
    end
end

function MTracks:ToggleMainFrame()
    -- Create main frame if it doesn't exist yet
    if not self.mainFrame then
        self:CreateMainFrame()
    end

    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
        -- Also close history detail popup when main window closes
        self:CloseHistoryDetail()
    else
        self.mainFrame:Show()
        self:UpdateDisplay()
    end
end

function MTracks:ShowMainFrame()
    if not self.mainFrame then
        self:CreateMainFrame()
    end
    self.mainFrame:Show()
    self:UpdateDisplay()
end

function MTracks:HideMainFrame()
    if self.mainFrame then
        self.mainFrame:Hide()
        self:CloseHistoryDetail()
    end
end

function MTracks:UpdateDisplay()
    if not self.mainFrame then return end

    -- Update the new epic table format
    self:UpdateCharacterTable()
    self:UpdateStatCards()
end

function MTracks:GetAllCharacterData()
    -- Collect data from all characters stored in the database
    local allCharacters = {}

    -- Always include current character (even with 0 applications)
    local currentChar = self:GetCurrentCharacterInfo()
    -- Get current character data from global database
    local charData = self.db.global.characters[currentChar.key] or {}

    -- Always add current character data (even if no applications yet)
    currentChar.applied = charData.applied or 0
    currentChar.accepted = charData.accepted or 0
    currentChar.declined = charData.declined or 0

    currentChar.cancelled = charData.cancelled or 0
    currentChar.lastActivity = charData.lastActivity or 0
    table.insert(allCharacters, currentChar)

    -- Get data from global character database
    if self.db.global.characters then
        for charKey, data in pairs(self.db.global.characters) do
            if charKey ~= currentChar.key then -- Don't duplicate current character
                local charInfo = self:ParseCharacterKey(charKey)
                if charInfo then
                    -- Include all characters from global database (even with 0 applications)
                    charInfo.applied = data.applied or 0
                    charInfo.accepted = data.accepted or 0
                    charInfo.declined = data.declined or 0

                    charInfo.cancelled = data.cancelled or 0
                    charInfo.lastActivity = data.lastActivity or 0
                    charInfo.class = data.class or "Unknown"
                    charInfo.level = data.level or 0
                    -- Set proper class color based on stored class
                    charInfo.classColor = self:GetClassColor(charInfo.class)
                    table.insert(allCharacters, charInfo)
                end
            end
        end
    end

    return allCharacters
end

function MTracks:GetCurrentCharacterInfo()
    local charName = UnitName("player") or "Unknown"
    local realmName = GetRealmName() or "Unknown"
    local _, className = UnitClass("player")
    local classColor = { 1, 1, 1 }

    if className then
        local classColors = RAID_CLASS_COLORS[className]
        if classColors then
            classColor = { classColors.r, classColors.g, classColors.b }
        end
    end

    return {
        key = charName .. "-" .. realmName,
        name = charName,
        realm = realmName,
        class = className or "Unknown",
        classColor = classColor,
        level = UnitLevel("player") or 0
    }
end

function MTracks:ParseCharacterKey(charKey)
    local name, realm = string.match(charKey, "^(.+)-(.+)$")
    if name and realm then
        return {
            key = charKey,
            name = name,
            realm = realm,
            class = "Unknown",        -- Will be updated from stored data
            classColor = { 1, 1, 1 }, -- Will be updated from stored data
            level = 0                 -- Will be updated from stored data
        }
    end
    return nil
end

function MTracks:GetClassColor(className)
    if className and className ~= "Unknown" then
        local classColors = RAID_CLASS_COLORS[className]
        if classColors then
            return { classColors.r, classColors.g, classColors.b }
        end
    end
    return { 1, 1, 1 } -- Default white
end

function MTracks:GetClassColorHex(className)
    if className and className ~= "Unknown" then
        local classColors = RAID_CLASS_COLORS[className]
        if classColors then
            return string.format("ff%02x%02x%02x",
                math.floor(classColors.r * 255),
                math.floor(classColors.g * 255),
                math.floor(classColors.b * 255))
        end
    end
    return "ffffffff" -- Default white
end

function MTracks:GetPlayerAppliedRole()
    -- Get the player's currently assigned role
    local assignedRole = UnitGroupRolesAssigned("player")
    if assignedRole and assignedRole ~= "NONE" then
        return assignedRole -- Returns "TANK", "HEALER", or "DAMAGER"
    end

    -- Fallback: Try to determine role from spec
    local specIndex = GetSpecialization()
    if specIndex then
        local role = GetSpecializationRole(specIndex)
        if role and role ~= "NONE" then
            return role
        end
    end

    return "UNKNOWN"
end

function MTracks:GetGroupDesiredRoles(searchResultID)
    -- Unfortunately, WoW's native API doesn't provide group role requirements
    -- We'll implement this as a placeholder for now, and potentially enhance later
    -- with heuristics or other detection methods

    if not searchResultID then
        return "Any Roles"
    end

    -- Try to get additional info about the group
    local success, info = pcall(C_LFGList.GetSearchResultInfo, searchResultID)
    if success and info then
        -- Check if the group description gives us any hints about desired roles
        local comment = info.comment or ""
        local desiredRoles = {}

        -- Simple keyword detection (case insensitive)
        if string.match(string.lower(comment), "tank") then
            table.insert(desiredRoles, "TANK")
        end
        if string.match(string.lower(comment), "heal") then
            table.insert(desiredRoles, "HEALER")
        end
        if string.match(string.lower(comment), "dps") or string.match(string.lower(comment), "damage") then
            table.insert(desiredRoles, "DAMAGER")
        end

        if #desiredRoles > 0 then
            return table.concat(desiredRoles, ", ")
        end
    end

    return "Any Roles" -- Default fallback
end

function MTracks:FormatPlayerRole(role)
    if role == "TANK" then
        return "|cff1E90FFTank|r"    -- Blue
    elseif role == "HEALER" then
        return "|cff32CD32Healer|r"  -- Green
    elseif role == "DAMAGER" then
        return "|cffFF6347DPS|r"     -- Red
    else
        return "|cffC0C0C0Unknown|r" -- Gray
    end
end

function MTracks:UpdateCharacterTable()
    if not self.mainFrame or not self.mainFrame.characterTable then return end

    local scrollChild = self.mainFrame.characterTable.scrollChild
    local characters = self:GetAllCharacterData()

    -- Get current character key for comparison
    local currentChar = self:GetCurrentCharacterInfo()
    local currentCharKey = currentChar.key

    -- Sort characters: current character first, then by last activity (most recent first)
    table.sort(characters, function(a, b)
        -- Current character always comes first
        if a.key == currentCharKey then
            return true
        elseif b.key == currentCharKey then
            return false
        else
            -- For all other characters, sort by last activity (most recent first)
            local aLastActivity = a.lastActivity or 0
            local bLastActivity = b.lastActivity or 0
            return aLastActivity > bLastActivity
        end
    end)

    -- Clear existing rows
    local children = { scrollChild:GetChildren() }
    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Clear selection state since we're recreating all rows
    self.selectedCharacterRow = nil

    -- Create rows for each character (more compact)
    local rowHeight = 35
    local yOffset = 0

    for i, charData in ipairs(characters) do
        local row = self:CreateCharacterRow(scrollChild, charData, yOffset, i)
        yOffset = yOffset - rowHeight
    end

    -- Update scroll child height
    scrollChild:SetHeight(math.max(200, math.abs(yOffset)))
end

function MTracks:CreateCharacterRow(parent, charData, yOffset, index)
    local row = CreateFrame("Button", nil, parent, "BackdropTemplate") -- Changed to Button for clicking
    row:SetSize(1030, 32)                                              -- More compact: reduced width and height
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    -- Store character data for click handling
    row.charData = charData

    -- Alternating row colors - minimal style
    local bgColor = (index % 2 == 0) and COLORS.row_even or COLORS.row_odd
    local selectedColor = { 0.25, 0.25, 0.25, 0.9 } -- Dark grey highlight for selected row
    local rowBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false
    }

    row:SetBackdrop(rowBackdrop)
    row:SetBackdropColor(unpack(bgColor))

    -- Add themed hover effect (character rows get character theme)
    local hoverColor = COLORS.character_hover

    -- Store original colors for state management
    row.originalBgColor = bgColor
    row.hoverColor = hoverColor
    row.selectedColor = selectedColor

    row:SetScript("OnEnter", function()
        if not row.isSelected then
            row:SetBackdropColor(unpack(hoverColor))
        end
    end)
    row:SetScript("OnLeave", function()
        if not row.isSelected then
            row:SetBackdropColor(unpack(bgColor))
        end
    end)

    -- Add click handling
    row:SetScript("OnClick", function()
        self:OnCharacterRowClick(row)
    end)

    -- Use the same positioning system as headers for perfect alignment
    local headers = {
        { width = 200, align = "LEFT" },   -- Character
        { width = 80,  align = "CENTER" }, -- Applied
        { width = 80,  align = "CENTER" }, -- Invited
        { width = 80,  align = "CENTER" }, -- Declined
        { width = 80,  align = "CENTER" }, -- Cancelled
        { width = 110, align = "CENTER" }, -- Success Rate
        { width = 110, align = "CENTER" }, -- Decline Rate
        { width = 110, align = "CENTER" }, -- Cancel Rate
        { width = 140, align = "CENTER" }  -- Last Activity
    }

    local xOffset = 35 -- Match header positioning

    -- Character name (class colored)
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetSize(headers[1].width, 20)
    nameText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    nameText:SetJustifyH(headers[1].align)

    local colorCode = string.format("|cff%02x%02x%02x",
        math.floor(charData.classColor[1] * 255),
        math.floor(charData.classColor[2] * 255),
        math.floor(charData.classColor[3] * 255))
    nameText:SetText(string.format("%s%s-%s|r", colorCode, charData.name, charData.realm))
    xOffset = xOffset + headers[1].width

    -- Applications
    local appliedText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    appliedText:SetSize(headers[2].width, 20)
    appliedText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    appliedText:SetJustifyH(headers[2].align)
    appliedText:SetText(tostring(charData.applied or 0))
    appliedText:SetTextColor(1, 1, 1)
    xOffset = xOffset + headers[2].width

    -- Invited
    local invitedText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    invitedText:SetSize(headers[3].width, 20)
    invitedText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    invitedText:SetJustifyH(headers[3].align)
    invitedText:SetText(tostring(charData.accepted or 0))
    invitedText:SetTextColor(0.2, 1, 0.2) -- Green for invited (positive outcome)
    xOffset = xOffset + headers[3].width

    -- Declined
    local declinedText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    declinedText:SetSize(headers[4].width, 20)
    declinedText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    declinedText:SetJustifyH(headers[4].align)
    declinedText:SetText(tostring(charData.declined or 0))
    declinedText:SetTextColor(1, 0.6, 0.6) -- Light red for declined
    xOffset = xOffset + headers[4].width



    -- Cancelled
    local cancelledText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cancelledText:SetSize(headers[5].width, 20)
    cancelledText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    cancelledText:SetJustifyH(headers[5].align)
    cancelledText:SetText(tostring(charData.cancelled or 0))
    cancelledText:SetTextColor(0.7, 0.7, 0.7) -- Light grey for cancelled
    xOffset = xOffset + headers[5].width

    -- Success rate
    local successRate = (charData.applied or 0) > 0 and ((charData.accepted or 0) / charData.applied * 100) or 0
    local successText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    successText:SetSize(headers[6].width, 20)
    successText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    successText:SetJustifyH(headers[6].align)
    successText:SetText(FormatPercentage(successRate))
    self:SetRateColor(successText, successRate, true)
    xOffset = xOffset + headers[6].width

    -- Decline rate
    local declineRate = (charData.applied or 0) > 0 and ((charData.declined or 0) / charData.applied * 100) or 0
    local declineText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    declineText:SetSize(headers[7].width, 20)
    declineText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    declineText:SetJustifyH(headers[7].align)
    declineText:SetText(FormatPercentage(declineRate))
    self:SetRateColor(declineText, declineRate, false)
    xOffset = xOffset + headers[7].width

    -- Cancel rate
    local cancelRate = (charData.applied or 0) > 0 and ((charData.cancelled or 0) / charData.applied * 100) or 0
    local cancelText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cancelText:SetSize(headers[8].width, 20)
    cancelText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    cancelText:SetJustifyH(headers[8].align)
    cancelText:SetText(FormatPercentage(cancelRate))
    self:SetRateColor(cancelText, cancelRate, false) -- Lower is better for cancel rates
    xOffset = xOffset + headers[8].width

    -- Last activity
    local lastActivityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lastActivityText:SetSize(headers[9].width, 20)
    lastActivityText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    lastActivityText:SetJustifyH(headers[9].align)

    local activityText
    if charData.lastActivity and charData.lastActivity > 0 then
        activityText = self:FormatTimeAgo(charData.lastActivity)
        lastActivityText:SetTextColor(0.7, 0.7, 0.7)
    elseif (charData.applied or 0) == 0 then
        activityText = "Ready to track!"
        lastActivityText:SetTextColor(0.5, 1, 0.5) -- Light green for "ready" state
    else
        activityText = "Never"
        lastActivityText:SetTextColor(0.7, 0.7, 0.7)
    end

    lastActivityText:SetText(activityText)

    return row
end

function MTracks:UpdateStatCards()
    if not self.mainFrame or not self.mainFrame.statCards then return end

    local accountData = self.db.global.accountData
    local cards = self.mainFrame.statCards

    -- Row 1: Applications (centered)
    if cards.totalApplied then
        cards.totalApplied.card.UpdateValueText(self:FormatNumber(accountData.totalApplied))
        self:UpdateSparkline(cards.totalApplied.sparklineFrame, "totalApplied", cards.totalApplied.config.sparklineColor)
    end

    -- Row 2: Counts
    if cards.totalInvited then
        cards.totalInvited.card.UpdateValueText(self:FormatNumber(accountData.totalAccepted))
        self:UpdateSparkline(cards.totalInvited.sparklineFrame, "totalAccepted", cards.totalInvited.config
            .sparklineColor)
    end

    if cards.totalDeclined then
        cards.totalDeclined.card.UpdateValueText(self:FormatNumber(accountData.totalDeclined))
        self:UpdateSparkline(cards.totalDeclined.sparklineFrame, "totalDeclined",
            cards.totalDeclined.config.sparklineColor)
    end

    if cards.totalCancelled then
        cards.totalCancelled.card.UpdateValueText(self:FormatNumber(accountData.totalCancelled))
        self:UpdateSparkline(cards.totalCancelled.sparklineFrame, "totalCancelled",
            cards.totalCancelled.config.sparklineColor)
    end

    -- Row 3: Rates (with dynamic rarity colors)
    if cards.invitedRate then
        local invitedRate = accountData.totalApplied > 0 and (accountData.totalAccepted / accountData.totalApplied * 100) or
            0
        local rarityColor = GetRarityColorForPercentage(invitedRate)
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(rarityColor[1] * 255),
            math.floor(rarityColor[2] * 255),
            math.floor(rarityColor[3] * 255))
        cards.invitedRate.valueText:SetText(colorCode .. FormatPercentage(invitedRate) .. "|r")
        if cards.invitedRate.card.labelElement then
            local lowercaseLabel = string.lower(cards.invitedRate.config.label)
            cards.invitedRate.card.labelElement:SetText("- " .. lowercaseLabel)
            cards.invitedRate.card.labelElement:SetTextColor(0.5, 0.5, 0.5) -- Ensure dark grey
        end
        self:UpdateSparkline(cards.invitedRate.sparklineFrame, "totalAccepted", cards.invitedRate.config.sparklineColor)
    end

    if cards.declineRate then
        local declineRate = accountData.totalApplied > 0 and (accountData.totalDeclined / accountData.totalApplied * 100) or
            0
        local invertedRate = math.max(0, 100 - declineRate)
        local rarityColor = GetRarityColorForPercentage(invertedRate)
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(rarityColor[1] * 255),
            math.floor(rarityColor[2] * 255),
            math.floor(rarityColor[3] * 255))
        cards.declineRate.valueText:SetText(colorCode .. FormatPercentage(declineRate) .. "|r")
        if cards.declineRate.card.labelElement then
            local lowercaseLabel = string.lower(cards.declineRate.config.label)
            cards.declineRate.card.labelElement:SetText("- " .. lowercaseLabel)
            cards.declineRate.card.labelElement:SetTextColor(0.5, 0.5, 0.5) -- Ensure dark grey
        end
        self:UpdateSparkline(cards.declineRate.sparklineFrame, "totalDeclined", cards.declineRate.config.sparklineColor)
    end

    if cards.cancelRate then
        local cancelRate = accountData.totalApplied > 0 and (accountData.totalCancelled / accountData.totalApplied * 100) or
            0
        local invertedRate = math.max(0, 100 - cancelRate)
        local rarityColor = GetRarityColorForPercentage(invertedRate)
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(rarityColor[1] * 255),
            math.floor(rarityColor[2] * 255),
            math.floor(rarityColor[3] * 255))
        cards.cancelRate.valueText:SetText(colorCode .. FormatPercentage(cancelRate) .. "|r")
        if cards.cancelRate.card.labelElement then
            local lowercaseLabel = string.lower(cards.cancelRate.config.label)
            cards.cancelRate.card.labelElement:SetText("- " .. lowercaseLabel)
            cards.cancelRate.card.labelElement:SetTextColor(0.5, 0.5, 0.5) -- Ensure dark grey
        end
        self:UpdateSparkline(cards.cancelRate.sparklineFrame, "totalCancelled", cards.cancelRate.config.sparklineColor)
    end

    -- Row 4: Hosting Statistics
    if cards.totalHosted then
        cards.totalHosted.card.UpdateValueText(self:FormatNumber(accountData.totalHosted or 0))
        self:UpdateSparkline(cards.totalHosted.sparklineFrame, "totalHosted", cards.totalHosted.config.sparklineColor)
    end

    if cards.totalHostedSuccessful then
        cards.totalHostedSuccessful.card.UpdateValueText(self:FormatNumber(accountData.totalHostedSuccessful or 0))
        self:UpdateSparkline(cards.totalHostedSuccessful.sparklineFrame, "totalHostedSuccessful",
            cards.totalHostedSuccessful.config.sparklineColor)
    end

    if cards.totalHostedCancelled then
        cards.totalHostedCancelled.card.UpdateValueText(self:FormatNumber(accountData.totalHostedCancelled or 0))
        self:UpdateSparkline(cards.totalHostedCancelled.sparklineFrame, "totalHostedCancelled",
            cards.totalHostedCancelled.config.sparklineColor)
    end
end

function MTracks:UpdateAccountStats()
    local accountData = self.db.global.accountData
    local frame = self.mainFrame

    -- Applications count
    if frame.accountAppliedValue then
        frame.accountAppliedValue:SetText(self:FormatNumber(accountData.totalApplied))
        frame.accountAppliedValue:SetTextColor(1, 1, 1) -- White
    end

    -- Success rate with color coding
    if frame.accountSuccessValue then
        local successRate = accountData.totalApplied > 0 and (accountData.totalAccepted / accountData.totalApplied * 100) or
            0
        frame.accountSuccessValue:SetText(FormatPercentage(successRate))
        self:SetRateColor(frame.accountSuccessValue, successRate, true) -- Green for good success rate
    end

    -- Decline rate with color coding
    if frame.accountDeclineValue then
        local declineRate = accountData.totalApplied > 0 and (accountData.totalDeclined / accountData.totalApplied * 100) or
            0
        frame.accountDeclineValue:SetText(FormatPercentage(declineRate))
        self:SetRateColor(frame.accountDeclineValue, declineRate, false) -- Red for bad decline rate
    end

    -- Declined count
    if frame.accountDelistedValue then
        frame.accountDelistedValue:SetText(self:FormatNumber(accountData.totalDeclined))
        frame.accountDelistedValue:SetTextColor(1, 0.8, 0) -- Orange
    end

    -- Removed count


    -- Last activity
    if frame.accountLastActivityValue then
        local lastActivityText = accountData.lastUpdate > 0 and self:FormatTimeAgo(accountData.lastUpdate) or "Never"
        frame.accountLastActivityValue:SetText(lastActivityText)
        frame.accountLastActivityValue:SetTextColor(0.7, 0.7, 0.7) -- Gray
    end
end

function MTracks:UpdateCharacterStats()
    local currentChar = self:GetCurrentCharacterInfo()
    local charData = self.db.global.characters[currentChar.key] or {}
    local frame = self.mainFrame

    -- Update character title with name-realm (both class-colored)
    if frame.charTitle then
        local charName = UnitName("player") or "Unknown"
        local charRealm = GetRealmName() or "Unknown"
        local _, className = UnitClass("player")

        -- Get class color
        local classColor = { 1, 1, 1 } -- Default white
        if className then
            local classColors = RAID_CLASS_COLORS[className]
            if classColors then
                classColor = { classColors.r, classColors.g, classColors.b }
            end
        end

        -- Create formatted text with both name and realm class-colored
        local colorCode = string.format("|cff%02x%02x%02x",
            math.floor(classColor[1] * 255),
            math.floor(classColor[2] * 255),
            math.floor(classColor[3] * 255))

        frame.charTitle:SetText(string.format("%s%s|r - %s%s|r", colorCode, charName, colorCode, charRealm))
        -- Don't set overall text color since we're using embedded colors
    end

    -- Applications count
    if frame.charAppliedValue then
        frame.charAppliedValue:SetText(self:FormatNumber(charData.applied))
        frame.charAppliedValue:SetTextColor(1, 1, 1) -- White
    end

    -- Success rate with color coding
    if frame.charSuccessValue then
        local successRate = charData.applied > 0 and (charData.accepted / charData.applied * 100) or 0
        frame.charSuccessValue:SetText(FormatPercentage(successRate))
        self:SetRateColor(frame.charSuccessValue, successRate, true) -- Green for good success rate
    end

    -- Decline rate with color coding
    if frame.charDeclineValue then
        local declineRate = charData.applied > 0 and (charData.declined / charData.applied * 100) or 0
        frame.charDeclineValue:SetText(FormatPercentage(declineRate))
        self:SetRateColor(frame.charDeclineValue, declineRate, false) -- Red for bad decline rate
    end

    -- Declined count
    if frame.charDelistedValue then
        frame.charDelistedValue:SetText(self:FormatNumber(charData.declined))
        frame.charDelistedValue:SetTextColor(1, 0.8, 0) -- Orange
    end

    -- Last activity
    if frame.charLastActivityValue then
        local lastActivityText = charData.lastActivity > 0 and self:FormatTimeAgo(charData.lastActivity) or "Never"
        frame.charLastActivityValue:SetText(lastActivityText)
        frame.charLastActivityValue:SetTextColor(0.7, 0.7, 0.7) -- Gray
    end
end

function MTracks:SetRateColor(fontString, rate, isGood)
    if not fontString or not fontString.SetTextColor then return end

    -- Use rarity color system for all rates
    local displayRate
    if isGood then
        -- For success rates, higher is better (use rate directly)
        displayRate = rate
    else
        -- For decline/cancel rates, lower is better (invert the rate)
        displayRate = math.max(0, 100 - rate)
    end

    local rarityColor = GetRarityColorForPercentage(displayRate)
    fontString:SetTextColor(unpack(rarityColor))
end

function MTracks:FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

function MTracks:FormatTimeAgo(timestamp)
    local diff = time() - timestamp
    if diff < 60 then
        return "Just now"
    elseif diff < 3600 then
        return string.format("%dm ago", math.floor(diff / 60))
    elseif diff < 86400 then
        return string.format("%dh ago", math.floor(diff / 3600))
    elseif diff < 604800 then
        return string.format("%dd ago", math.floor(diff / 86400))
    else
        return tostring(date("%m/%d", timestamp))
    end
end

function MTracks:AddToHistory(eventType, resultID, status, searchResultID)
    if not self.db.profile.autoTrack then return end

    local history = self.db.global.history
    local maxEntries = self.db.global.maxHistoryEntries or 100

    -- Try to get information from application cache first (preferred for accuracy)
    local leaderName, activityName, levelRange, itemLevel, memberCount, groupDesiredRoles
    local applicationData = nil

    if self.db.global.applicationCache then
        -- Find the most recent application data by matching group characteristics
        -- Don't rely on resultID since it changes between sessions
        local latestTime = 0
        local cacheCount = 0
        for appID, appData in pairs(self.db.global.applicationCache) do
            cacheCount = cacheCount + 1

            -- Match by a combination of recent time and stored resultID for this session,
            -- but if no match found, we'll look for similar groups by leader/activity
            if (resultID and appData.resultID == resultID and appData.appliedTime > latestTime) then
                applicationData = appData
                latestTime = appData.appliedTime
            end
        end

        -- If no exact resultID match (likely after relog), find by group characteristics
        if not applicationData then
            for appID, appData in pairs(self.db.global.applicationCache) do
                -- Look for recent applications (within last 24 hours) that might be the same group
                local timeDiff = time() - (appData.appliedTime or 0)
                if timeDiff < 86400 and appData.appliedTime > latestTime then -- 24 hours
                    applicationData = appData
                    latestTime = appData.appliedTime
                end
            end
        end
    end

    if not applicationData then
        -- If we don't have cached data, we cannot create a proper historical entry
        -- This should only happen if the caching system failed
        self:Print("Warning: No cached application data found for resultID " ..
            tostring(resultID) .. ". Skipping history entry.")
        return
    end

    -- Use ONLY cached application data for historical accuracy - NO live API lookups
    leaderName = applicationData.leaderName or ""

    activityName = applicationData.activityName or "Unknown Activity"
    levelRange = applicationData.requiredItemLevel > 0 and
        string.format("ilvl %d+", applicationData.requiredItemLevel) or "No Requirement"
    itemLevel = applicationData.requiredItemLevel or 0
    memberCount = applicationData.memberCount or "?/?"
    groupDesiredRoles = applicationData.desiredRoles or "Any Roles"

    -- Get player's applied role
    local playerAppliedRole = self:GetPlayerAppliedRole()

    -- Create history entry with comprehensive snapshot data
    local entry = {
        timestamp = time(),
        eventType = eventType,
        status = status,
        resultID = resultID,

        -- Core group snapshot data (what the UI displays)
        leaderName = leaderName,
        activityName = activityName,
        levelRange = levelRange,
        itemLevel = itemLevel,
        memberCount = memberCount,
        groupDesiredRoles = groupDesiredRoles,

        -- Extended snapshot data from application cache
        voiceChat = applicationData.voiceChat or "",
        requiredHonorLevel = applicationData.requiredHonorLevel or 0,
        activityDescription = applicationData.activityDescription or "",
        activityCategoryID = applicationData.activityCategoryID or 0,
        activityID = applicationData.activityID or 0,
        activityShortName = applicationData.activityShortName or "",
        activityFullName = applicationData.activityFullName or "",
        numBNetFriends = applicationData.numBNetFriends or 0,
        numCharFriends = applicationData.numCharFriends or 0,
        numGuildMates = applicationData.numGuildMates or 0,
        isWarMode = applicationData.isWarMode or false,
        groupAutoAccept = applicationData.groupAutoAccept or false,

        -- Player context at time of application
        playerAppliedRole = playerAppliedRole,
        characterName = UnitName("player"),
        realmName = GetRealmName(),

        -- Timing data (snapshot of when originally applied)
        appliedTime = applicationData.appliedTime,
        lastUpdated = applicationData.lastUpdated,
    }

    -- Add to beginning of array (most recent first)
    table.insert(history, 1, entry)

    -- Keep only the last maxEntries
    while #history > maxEntries do
        table.remove(history)
    end
end

function MTracks:CacheApplicationInfo(resultID, status)
    if not resultID or not self.db.global.applicationCache then
        return
    end

    -- Cache on all status changes to create historical snapshots
    -- We need the data regardless of the final outcome

    -- Try to get comprehensive group information
    local success, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
    if not success or not info then
        -- Try to get info from active application as fallback
        local appInfo = C_LFGList.GetApplicationInfo()
        if appInfo and appInfo.resultID == resultID then
            success, info = pcall(C_LFGList.GetSearchResultInfo, appInfo.resultID)
        end

        if not success or not info then
            return
        end
    end

    -- Get activity information
    local activityInfo = nil
    local activityID = nil

    -- Use new API (activityIDs array) from patch 11.0.7+
    if info.activityIDs and type(info.activityIDs) == "table" and #info.activityIDs > 0 then
        activityID = info.activityIDs[1] -- Use first activity ID from the array
    end

    if activityID then
        -- Debug what activityID we're trying to use

        local activitySuccess, activityData = pcall(C_LFGList.GetActivityInfoTable, activityID)
        if activitySuccess and activityData then
            activityInfo = activityData
        else
            -- Try alternative API
            local altSuccess, altData = pcall(C_LFGList.GetActivityInfo, activityID)
            if altSuccess and altData then
                activityInfo = altData
            end
        end
    end

    -- Get current member count
    local currentMembers = (info.numMembers or 0)
    local maxMembers = (activityInfo and activityInfo.maxNumPlayers) or 5
    local memberCount = string.format("%d/%d", currentMembers, maxMembers)

    -- Determine activity name
    local activityName = "Unknown Activity"
    if activityInfo and activityInfo.fullName then
        activityName = activityInfo.fullName
    elseif activityID then
        activityName = "Activity ID: " .. tostring(activityID)
    end




    -- Note: Status updates are now handled in the event handler, not here
    -- This function creates new cache entries with comprehensive snapshot data

    -- Generate a session-independent application ID based on group content and timestamp
    -- Use group leader + activity + timestamp to create a stable key across sessions
    local groupKey = (info.leaderName or "unknown") .. "_" ..
        (activityID or "noactivity") .. "_" ..
        (info.requiredItemLevel or 0)
    local applicationID = groupKey .. "_" .. time()


    -- Store comprehensive application data
    local applicationData = {
        -- Basic application info
        resultID = resultID,
        applicationID = applicationID,
        status = status,
        appliedTime = time(),
        lastUpdated = time(),

        -- Group leader info
        leaderName = info.leaderName or "",

        -- Group details removed - protected strings show as "Unknown" in addon UI
        groupAutoAccept = info.autoAccept or false,

        -- Activity information
        activityID = activityID,
        activityName = activityName,
        activityShortName = activityInfo and activityInfo.shortName or "",
        activityFullName = activityInfo and activityInfo.fullName or "",
        activityDescription = (activityInfo and activityInfo.description) or "",
        activityCategoryID = (activityInfo and activityInfo.categoryID) or 0,
        activityGroupID = (activityInfo and activityInfo.groupID) or 0,
        activityItemLevel = (activityInfo and activityInfo.itemLevel) or 0,
        activityHonorLevel = (activityInfo and activityInfo.honorLevel) or 0,
        activityMaxNumPlayers = activityInfo and activityInfo.maxNumPlayers or 5,
        activityMinLevel = activityInfo and activityInfo.minLevel or 0,
        activityMaxLevel = activityInfo and activityInfo.maxLevel or 0,

        -- Group requirements
        requiredItemLevel = info.requiredItemLevel or 0,
        requiredHonorLevel = info.requiredHonorLevel or 0,
        voiceChat = info.voiceChat or "",
        isDelisted = info.isDelisted or false,

        -- Member information
        numMembers = currentMembers,
        maxMembers = maxMembers,
        memberCount = memberCount,

        -- Role information
        desiredRoles = self:GetGroupDesiredRoles(resultID),

        -- Additional API data
        age = info.age or 0,
        numBNetFriends = info.numBNetFriends or 0,
        numCharFriends = info.numCharFriends or 0,
        numGuildMates = info.numGuildMates or 0,
        isWarMode = info.isWarMode or false,

        -- Caching metadata
        cachedTime = time(),
    }

    -- Store the new application data
    self.db.global.applicationCache[applicationID] = applicationData

    -- Clean up old cache entries
    self:CleanupApplicationCache()
end

function MTracks:CleanupApplicationCache()
    local applicationCache = self.db.global.applicationCache
    local maxEntries = self.db.global.maxApplicationCacheEntries or 50

    -- Count current entries
    local count = 0
    local entries = {}
    for id, info in pairs(applicationCache) do
        count = count + 1
        table.insert(entries, { id = id, time = info.cachedTime or 0 })
    end

    -- If we have too many, remove oldest entries
    if count > maxEntries then
        -- Sort by time (oldest first)
        table.sort(entries, function(a, b) return a.time < b.time end)

        -- Remove oldest entries
        local toRemove = count - maxEntries
        for i = 1, toRemove do
            if entries[i] then
                applicationCache[entries[i].id] = nil
            end
        end
    end
end

function MTracks:GetGroupInfo(searchResultID)
    if not searchResultID then
        -- Try to get some basic info from current application status
        local applicationInfo = C_LFGList.GetApplicationInfo()
        if applicationInfo and applicationInfo.applicationStatus then
            return {
                leader = "Group Leader",
                name = nil, -- Don't fallback to generic group names
                activityName = "Mythic Keystone",
                levelRange = "Various",
                itemLevel = 0,
            }
        end
        return {}
    end

    -- Try to get from application cache (preferred method)
    if self.db.global.applicationCache then
        -- Find the most recent application for this resultID
        local mostRecentApp = nil
        local latestTime = 0

        for appID, appData in pairs(self.db.global.applicationCache) do
            -- Try exact resultID match first (same session)
            if searchResultID and appData.resultID == searchResultID and appData.appliedTime > latestTime then
                mostRecentApp = appData
                latestTime = appData.appliedTime
            end
        end

        -- If no exact match (likely different session), get most recent application
        if not mostRecentApp then
            for appID, appData in pairs(self.db.global.applicationCache) do
                if appData.appliedTime > latestTime then
                    mostRecentApp = appData
                    latestTime = appData.appliedTime
                end
            end
        end

        if mostRecentApp then
            return {
                leader = mostRecentApp.leaderName,
                name = mostRecentApp.groupName,
                activityName = mostRecentApp.activityName,
                levelRange = mostRecentApp.requiredItemLevel > 0 and
                    string.format("ilvl %d+", mostRecentApp.requiredItemLevel) or "No Requirement",
                itemLevel = mostRecentApp.requiredItemLevel,
                memberCount = mostRecentApp.memberCount,
                desiredRoles = mostRecentApp.desiredRoles or "Any Roles",
                applicationStatus = mostRecentApp.status,
                appliedTime = mostRecentApp.appliedTime,
                -- Additional comprehensive data available:
                activityDescription = mostRecentApp.activityDescription,
                voiceChat = mostRecentApp.voiceChat,
                numBNetFriends = mostRecentApp.numBNetFriends,
                numCharFriends = mostRecentApp.numCharFriends,
                numGuildMates = mostRecentApp.numGuildMates,
                isWarMode = mostRecentApp.isWarMode,
            }
        end
    end

    -- NO live API fallbacks - only use cached data for historical accuracy
    -- Live API calls fail after relog when session IDs change

    -- Final fallback with basic defaults
    return {
        leader = "Group Leader",
        name = nil, -- Don't fallback to generic group names
        activityName = "Group Content",
        levelRange = "Applied",
        itemLevel = 0,
        memberCount = "?/?",
    }
end

function MTracks:GetApplicationHistory(resultID)
    if not self.db.global.applicationCache then return {} end

    local applications = {}
    for appID, appData in pairs(self.db.global.applicationCache) do
        if not resultID or appData.resultID == resultID then
            table.insert(applications, appData)
        end
    end

    -- Sort by application time (most recent first)
    table.sort(applications, function(a, b) return a.appliedTime > b.appliedTime end)

    return applications
end

function MTracks:GetApplicationStats()
    if not self.db.global.applicationCache then
        return {
            totalApplications = 0,
            totalAccepted = 0,
            totalDeclined = 0,
            successRate = 0
        }
    end

    local totalApplications = 0
    local totalAccepted = 0
    local totalDeclined = 0

    for appID, appData in pairs(self.db.global.applicationCache) do
        totalApplications = totalApplications + 1
        if appData.status == "accepted" then
            totalAccepted = totalAccepted + 1
        elseif appData.status == "declined" or appData.status == "cancelled" then
            totalDeclined = totalDeclined + 1
        end
    end

    local successRate = totalApplications > 0 and (totalAccepted / totalApplications * 100) or 0

    return {
        totalApplications = totalApplications,
        totalAccepted = totalAccepted,
        totalDeclined = totalDeclined,
        successRate = successRate
    }
end

function MTracks:OnCharacterRowClick(row)
    local charData = row.charData

    -- If clicking the same row that's already selected, close the character history
    if self.selectedCharacterRow == row and self.characterHistoryFrame and self.characterHistoryFrame:IsShown() then
        self:CloseCharacterHistory()
        return
    end

    -- Deselect previous row
    if self.selectedCharacterRow and self.selectedCharacterRow ~= row then
        self.selectedCharacterRow.isSelected = false
        self.selectedCharacterRow:SetBackdropColor(unpack(self.selectedCharacterRow.originalBgColor))
    end

    -- Select new row
    row.isSelected = true
    row:SetBackdropColor(unpack(row.selectedColor))
    self.selectedCharacterRow = row

    -- Open character history window
    self:OpenCharacterHistory(charData)
end

function MTracks:CloseCharacterHistory()
    if self.characterHistoryFrame then
        self.characterHistoryFrame:Hide()
    end

    if self.selectedCharacterRow then
        self.selectedCharacterRow.isSelected = false
        self.selectedCharacterRow:SetBackdropColor(unpack(self.selectedCharacterRow.originalBgColor))
        self.selectedCharacterRow = nil
    end

    -- Also hide detail popup when closing character history
    self:CloseHistoryDetail()
end

function MTracks:OpenCharacterHistory(charData)
    if not self.characterHistoryFrame then
        self:CreateCharacterHistoryWindow()
    end

    -- Ensure character detail popup exists
    if not self.characterHistoryDetailFrame then
        self:CreateCharacterHistoryDetailPopup(self.characterHistoryFrame)
    end

    self.currentCharacterData = charData
    self:UpdateCharacterHistoryDisplay()
    self.characterHistoryFrame:Show()
end

function MTracks:CreateCharacterHistoryWindow()
    local frame = CreateFrame("Frame", "MTracksCharacterHistoryFrame", UIParent, "BackdropTemplate")
    frame:SetSize(750, 420) -- Increased from 400 to 420 to better match main window height
    -- Position to the LEFT of the main MTracks window
    if self.mainFrame then
        frame:SetPoint("TOPRIGHT", self.mainFrame, "TOPLEFT", -10, 0)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", -400, 0) -- Fallback position to the left
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Backdrop - minimal style
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = nil,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

    frame:SetBackdrop(backdrop)
    frame:SetBackdropColor(unpack(COLORS.background))

    -- Initialize Logo module if not already attached
    if not self.Logo then
        self.Logo = _G.MTracksLogo
        if not self.Logo then
            self:Print("Warning: Logo module not found. Skipping logo display.")
            return
        end
    end

    -- Create logo ABOVE the frame using negative positioning (will be updated with character name)
    local logoFrame = self.Logo:CreateStyledLogo(frame, "Character History", {
        position = { x = 0, y = -10 }, -- Small negative Y gap above the frame
        anchor = "BOTTOM",
        anchorTo = "TOP",
        firstLetterSize = 32,                         -- Slightly smaller than main window
        restSize = 28,                                -- Slightly smaller than main window
        containerSize = { width = 300, height = 60 }, -- Appropriate size for character history
        firstLetterOnly = true                        -- Only style the very first letter, not each word's first letter
    })

    -- Store reference for later updates
    frame.logoFrame = logoFrame

    -- Close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        self:CloseCharacterHistory()
    end)

    -- Character stats cards section at the top - now positioned at the very top since no internal title
    local statsFrame = CreateFrame("Frame", nil, frame)
    statsFrame:SetSize(700, 90)                      -- Reduced from 120 to 90 since we only have one row of cards now
    statsFrame:SetPoint("TOP", frame, "TOP", 0, -10) -- Positioned at top with small margin
    frame.statsFrame = statsFrame

    -- Character stats cards will be created dynamically in UpdateCharacterHistoryDisplay

    -- Create history table header - positioned closer to stats since no internal title
    local historyHeaderFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    historyHeaderFrame:SetSize(700, 30)
    historyHeaderFrame:SetPoint("TOP", statsFrame, "BOTTOM", 0, -5) -- Keeps existing tight spacing
    frame.historyHeaderFrame = historyHeaderFrame

    local headerBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false
    }
    historyHeaderFrame:SetBackdrop(headerBackdrop)
    historyHeaderFrame:SetBackdropColor(unpack(COLORS.header))

    -- History table headers
    local historyHeaders = {
        { text = "Time",     width = 70,  align = "LEFT" },
        { text = "Role",     width = 50,  align = "CENTER" },
        { text = "Status",   width = 80,  align = "CENTER" },
        { text = "Leader",   width = 140, align = "LEFT" },
        { text = "Members",  width = 60,  align = "CENTER" },
        { text = "Activity", width = 300, align = "LEFT" }
    }

    local xOffset = 10
    for i, header in ipairs(historyHeaders) do
        local headerText = historyHeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        headerText:SetSize(header.width, 20)
        headerText:SetPoint("LEFT", historyHeaderFrame, "LEFT", xOffset, 0)
        headerText:SetText(header.text)
        headerText:SetTextColor(1, 1, 1, 1)
        headerText:SetJustifyH(header.align)
        xOffset = xOffset + header.width
    end

    -- Scroll frame setup for history
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", historyHeaderFrame, "BOTTOMLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -40, 20)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(690, 1000) -- Will be resized dynamically
    scrollFrame:SetScrollChild(content)

    frame.scrollContent = content
    frame.historyHeaders = historyHeaders
    self.characterHistoryFrame = frame

    -- Create detail popup for character history
    self:CreateCharacterHistoryDetailPopup(frame)
end

-- REMOVED: Generic history window functionality



function MTracks:CreateCharacterHistoryDetailPopup(characterHistoryFrame)
    local detailFrame = CreateFrame("Frame", "MTracksCharacterHistoryDetailFrame", UIParent, "BackdropTemplate")
    detailFrame:SetSize(750, 160)                                      -- Reduced from 250 to 160 (420 + 160 = 580 to match main window)
    detailFrame:SetPoint("TOP", characterHistoryFrame, "BOTTOM", 0, 0) -- Position directly below character history window
    detailFrame:SetFrameStrata("HIGH")                                 -- Make sure it's visible
    detailFrame:Hide()                                                 -- Hidden by default

    -- Backdrop
    local backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
    detailFrame:SetBackdrop(backdrop)
    detailFrame:SetBackdropColor(unpack(COLORS.background))
    detailFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Removed title to reclaim space for content

    -- Content area for detailed information - now positioned at top since no title
    local contentFrame = CreateFrame("Frame", nil, detailFrame)
    contentFrame:SetSize(700, 150)                          -- Increased from 130 to 150 since we removed title (160-10 for minimal padding)
    contentFrame:SetPoint("TOP", detailFrame, "TOP", 0, -5) -- Position directly at top with minimal padding
    detailFrame.contentFrame = contentFrame

    self.characterHistoryDetailFrame = detailFrame
end

function MTracks:CloseHistoryDetail()
    -- Hide character history detail popup and clear selection
    if self.characterHistoryDetailFrame then
        self.characterHistoryDetailFrame:Hide()
    end

    -- Clear selected history row
    if self.selectedHistoryRow then
        self.selectedHistoryRow.isSelected = false
        self.selectedHistoryRow:SetBackdropColor(unpack(self.selectedHistoryRow.originalBgColor))
        self.selectedHistoryRow = nil
    end
end

function MTracks:OnHistoryRowClick(row)
    local entryData = row.entryData


    -- Deselect previous row
    if self.selectedHistoryRow and self.selectedHistoryRow ~= row then
        self.selectedHistoryRow.isSelected = false
        self.selectedHistoryRow:SetBackdropColor(unpack(self.selectedHistoryRow.originalBgColor))
    end

    -- Select new row
    row.isSelected = true
    row:SetBackdropColor(unpack(row.selectedColor))
    self.selectedHistoryRow = row

    -- Show and update detail popup
    self:ShowHistoryDetail(entryData)
end

function MTracks:ShowHistoryDetail(entryData)
    -- Only works with character history now
    if not self.characterHistoryFrame or not self.characterHistoryFrame:IsShown() then
        return
    end

    if not self.characterHistoryDetailFrame then
        self:CreateCharacterHistoryDetailPopup(self.characterHistoryFrame)
    end

    local detailFrame = self.characterHistoryDetailFrame
    local contentFrame = detailFrame.contentFrame



    -- Clear existing content
    for _, child in ipairs({ contentFrame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in ipairs({ contentFrame:GetRegions() }) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            region:Hide()
            region:SetParent(nil)
        end
    end

    -- Create detailed view of the entry
    self:CreateDetailedEntryView(contentFrame, entryData)

    -- Show the detail frame
    detailFrame:Show()
end

function MTracks:CreateDetailedEntryView(parent, entry)
    -- Two-column layout with better spacing - no backgrounds or borders
    local yOffset = -5              -- Start closer to top since no title
    local lineHeight = 18           -- Reduced from 25 to 18 for more compact layout
    local labelColor = "|cff888888" -- Gray for labels

    -- Status line - prominent at top, spans both columns
    local statusText = entry.status:gsub("^%l", string.upper)
    local statusColor = "|cffffffff" -- Default white
    if entry.status == "applied" then
        statusColor = "|cffffff00"   -- Yellow
    elseif entry.status == "declined" then
        statusColor = "|cffff6666"   -- Red
    elseif entry.status == "invited" then
        statusColor = "|cff33ff33"   -- Green
    elseif entry.status == "cancelled" or entry.status == "withdrawapplication" then
        statusColor = "|cffb3b3b3"   -- Gray
    elseif entry.status == "delisted" or entry.status == "declined_delisted" then
        statusColor = "|cffff8080"   -- Light red
    end

    self:CreateDetailLineSplit(parent, 20, yOffset,
        labelColor .. "Status:|r " .. statusColor .. statusText .. "|r",
        "", "GameFontHighlight")
    yOffset = yOffset - lineHeight

    -- Get character's class color for the character name from the current character data being viewed
    local playerClassColor = "|cffffffff" -- Default white
    if self.currentCharacterData and self.currentCharacterData.class and self.currentCharacterData.class ~= "Unknown" then
        playerClassColor = "|c" .. self:GetClassColorHex(self.currentCharacterData.class)
    end

    -- Get leader info with class color
    local leaderName = self:FormatLeaderNameForDisplay(entry.leaderName)
    if entry.leaderClass then
        local classColor = self:GetClassColorHex(entry.leaderClass)
        leaderName = string.format("|c%s%s|r", classColor, leaderName)
    end

    -- Build role info
    local roleDisplay = ""
    if entry.playerAppliedRole and entry.playerAppliedRole ~= "UNKNOWN" then
        roleDisplay = self:FormatPlayerRole(entry.playerAppliedRole)
    end

    -- Build looking for text
    local lookingForText = ""
    if entry.groupDesiredRoles and entry.groupDesiredRoles ~= "Any Roles" then
        lookingForText = entry.groupDesiredRoles
    end

    -- Line 1: Time | Character
    local timeText = self:FormatTimeAgo(entry.timestamp)
    local charText = string.format("%s-%s", entry.characterName or "Unknown", entry.realmName or "Unknown")
    self:CreateDetailLineSplit(parent, 20, yOffset,
        labelColor .. "Time:|r " .. timeText,
        labelColor .. "Character:|r " .. playerClassColor .. charText .. "|r",
        "GameFontHighlight")
    yOffset = yOffset - lineHeight

    -- Line 2: Applied as | Status
    self:CreateDetailLineSplit(parent, 20, yOffset,
        labelColor .. "Applied as:|r " .. (roleDisplay ~= "" and roleDisplay or "Unknown"),
        labelColor .. "Status:|r " .. (entry.status and entry.status:gsub("^%l", string.upper) or "Unknown"),
        "GameFontHighlight")
    yOffset = yOffset - lineHeight

    -- Line 3: Activity | Leader
    self:CreateDetailLineSplit(parent, 20, yOffset,
        labelColor .. "Activity:|r " .. (entry.activityName or "Mythic+ Activity"),
        labelColor .. "Leader:|r " .. leaderName,
        "GameFontHighlight")
    yOffset = yOffset - lineHeight

    -- Line 4: Required iLvl | Members
    self:CreateDetailLineSplit(parent, 20, yOffset,
        labelColor .. "Required iLvl:|r " .. tostring(entry.itemLevel or 0),
        labelColor .. "Members:|r " .. (entry.memberCount or "?/?"),
        "GameFontHighlight")
    yOffset = yOffset - lineHeight

    -- Line 5: Looking for | Event
    self:CreateDetailLineSplit(parent, 20, yOffset,
        labelColor .. "Looking for:|r " .. (lookingForText ~= "" and lookingForText or "Any Roles"),
        labelColor .. "Event:|r " .. (entry.eventType or "Unknown"),
        "GameFontHighlight")
    yOffset = yOffset - lineHeight

    -- Additional line for hosting events with applicant details
    if entry.isHostingEvent and entry.applicantName then
        self:CreateDetailLineSplit(parent, 20, yOffset,
            labelColor .. "Applicant:|r " .. entry.applicantName,
            labelColor .. "Role:|r " .. (entry.applicantRole and self:FormatPlayerRole(entry.applicantRole) or "Unknown"),
            "GameFontHighlight")
        yOffset = yOffset - lineHeight

        -- Show applicant stats if available
        if entry.applicantItemLevel and entry.applicantItemLevel > 0 then
            local ilvlText = "ilvl " .. entry.applicantItemLevel
            local scoreText = entry.applicantDungeonScore and entry.applicantDungeonScore > 0 and
                ("Score: " .. entry.applicantDungeonScore) or "No Score"

            self:CreateDetailLineSplit(parent, 20, yOffset,
                labelColor .. "Item Level:|r " .. ilvlText,
                labelColor .. "M+ Score:|r " .. scoreText,
                "GameFontHighlight")
            yOffset = yOffset - lineHeight
        end

        -- Show applicant comment if available
        if entry.applicantComment and entry.applicantComment ~= "" then
            self:CreateDetailLineSplit(parent, 20, yOffset,
                labelColor .. "Comment:|r " .. entry.applicantComment,
                "",
                "GameFontHighlight")
        end
    end
end

function MTracks:CreateDetailLine(parent, x, y, text, fontTemplate)
    local line = parent:CreateFontString(nil, "OVERLAY", fontTemplate or "GameFontHighlight")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    line:SetSize(660, 16) -- Reduced height from 20 to 16 for smaller fonts
    line:SetJustifyH("LEFT")
    line:SetText(text)
    line:SetTextColor(1, 1, 1) -- Base white color, colors come from the text markup
    return line
end

function MTracks:CreateDetailLineSplit(parent, x, y, leftText, rightText, fontTemplate)
    -- Create left side text (if provided)
    if leftText and leftText ~= "" then
        local leftLine = parent:CreateFontString(nil, "OVERLAY", fontTemplate or "GameFontHighlight")
        leftLine:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        leftLine:SetSize(320, 16) -- Reduced height from 20 to 16 for smaller fonts
        leftLine:SetJustifyH("LEFT")
        leftLine:SetText(leftText)
        leftLine:SetTextColor(1, 1, 1)
    end

    -- Create right side text (if provided)
    if rightText and rightText ~= "" then
        local rightLine = parent:CreateFontString(nil, "OVERLAY", fontTemplate or "GameFontHighlight")
        rightLine:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 340, y) -- Position on right side with some spacing
        rightLine:SetSize(320, 16)                                   -- Reduced height from 20 to 16 for smaller fonts
        rightLine:SetJustifyH("LEFT")
        rightLine:SetText(rightText)
        rightLine:SetTextColor(1, 1, 1)
    end
end

function MTracks:UpdateCharacterHistoryDisplay()
    if not self.characterHistoryFrame or not self.currentCharacterData then return end

    local frame = self.characterHistoryFrame
    local charData = self.currentCharacterData

    -- Update logo with character name and class colors
    if frame.logoFrame and self.Logo then
        local characterName = charData.name .. "-" .. charData.realm

        -- Convert class colors to the format expected by the logo system
        local startColor = {
            r = charData.classColor[1],
            g = charData.classColor[2],
            b = charData.classColor[3]
        }

        -- Create a slightly darker version for the end color to maintain gradient effect
        local endColor = {
            r = charData.classColor[1] * 0.7,
            g = charData.classColor[2] * 0.7,
            b = charData.classColor[3] * 0.7
        }

        -- If character name changed, recreate the logo completely
        if frame.logoFrame.options.text ~= characterName then
            -- Hide and remove old logo elements
            if frame.logoFrame.elements then
                for _, element in ipairs(frame.logoFrame.elements) do
                    element:Hide()
                    element:SetParent(nil)
                end
            end

            -- Recreate logo with new character name
            local newLogo = self.Logo:CreateStyledLogo(frame, characterName, {
                position = { x = 0, y = -10 },
                anchor = "BOTTOM",
                anchorTo = "TOP",
                firstLetterSize = 32,
                restSize = 28,
                containerSize = { width = 300, height = 60 },
                startColor = startColor,
                endColor = endColor,
                firstLetterOnly = true -- Only style the very first letter
            })

            frame.logoFrame = newLogo
        else
            -- Just update colors if name hasn't changed
            self.Logo:UpdateLogoColors(frame.logoFrame, startColor, endColor)
        end
    end

    -- Update character stats section
    self:UpdateCharacterStatsSection()

    -- Update history list
    local content = frame.scrollContent
    local history = self:GetCharacterHistory(charData.key)

    -- Clear existing content completely
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    -- Also clear font strings from regions
    for _, region in ipairs({ content:GetRegions() }) do
        if region and region.GetObjectType and region:GetObjectType() == "FontString" then
            region:Hide()
            region:SetParent(nil)
        end
    end

    if #history == 0 then
        -- No history message
        local noHistoryLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noHistoryLabel:SetPoint("TOPLEFT", 20, -20)
        noHistoryLabel:SetText(
            "No application history for this character yet.\n\nPlay on this character and apply to Mythic+ groups to see history here!")
        noHistoryLabel:SetTextColor(0.7, 0.7, 0.7)
        return
    end

    -- Create history entries (table format)
    local yOffset = 0
    local rowHeight = 25
    for i, entry in ipairs(history) do
        local entryFrame = self:CreateHistoryEntry(content, entry, yOffset, i)
        yOffset = yOffset - rowHeight
    end

    -- Resize content frame
    content:SetHeight(math.max(200, math.abs(yOffset)))
end

function MTracks:UpdateCharacterStatsSection()
    if not self.characterHistoryFrame or not self.currentCharacterData then return end

    local statsFrame = self.characterHistoryFrame.statsFrame
    local charData = self.currentCharacterData

    -- Use character-specific data from the same source as main window's character section
    -- Get fresh data from global characters database to ensure consistency
    local characterKey = charData.key or (charData.name .. "-" .. charData.realm)
    local freshCharData = self.db.global.characters[characterKey] or charData

    -- Create character stat cards using the same data source as main window
    self:CreateCharacterStatCards(statsFrame, freshCharData)
end

function MTracks:GetCharacterHistory(characterKey)
    -- Filter global history to only show entries for this character
    local characterHistory = {}
    local globalHistory = self.db.global.history or {}


    for i, entry in ipairs(globalHistory) do
        local entryCharKey = (entry.characterName or "") .. "-" .. (entry.realmName or "")
        if entryCharKey == characterKey then
            table.insert(characterHistory, entry)
        end
    end

    return characterHistory
end

function MTracks:CreateHistoryEntry(parent, entry, yOffset, index)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetSize(690, 25)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    -- Alternating row colors
    local bgColor = (index % 2 == 0) and COLORS.row_even or COLORS.row_odd
    local rowBackdrop = {
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false
    }
    row:SetBackdrop(rowBackdrop)
    row:SetBackdropColor(unpack(bgColor))

    -- Store entry data and selection state
    row.entryData = entry
    row.originalBgColor = bgColor
    row.isSelected = false
    row.selectedColor = { 0.3, 0.3, 0.6, 0.8 } -- Blue selection color

    -- Add hover effect
    local hoverColor = { 0.2, 0.2, 0.2, 0.8 }
    row:SetScript("OnEnter", function()
        if not row.isSelected then
            row:SetBackdropColor(unpack(hoverColor))
        end
    end)
    row:SetScript("OnLeave", function()
        if not row.isSelected then
            row:SetBackdropColor(unpack(bgColor))
        end
    end)

    -- Add click functionality
    row:EnableMouse(true)
    row:SetScript("OnMouseDown", function()
        self:OnHistoryRowClick(row)
    end)

    -- Use same header structure as defined in CreateCharacterHistoryWindow
    local headers = {
        { width = 70,  align = "LEFT" },   -- Time
        { width = 50,  align = "CENTER" }, -- Role
        { width = 80,  align = "CENTER" }, -- Status
        { width = 140, align = "LEFT" },   -- Leader (expanded for realm)
        { width = 60,  align = "CENTER" }, -- Members
        { width = 300, align = "LEFT" }    -- Activity (reduced to make room)
    }

    local xOffset = 10

    -- Time column
    local timeText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeText:SetSize(headers[1].width, 20)
    timeText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    timeText:SetJustifyH(headers[1].align)
    timeText:SetText(self:FormatTimeAgo(entry.timestamp))
    timeText:SetTextColor(0.7, 0.7, 0.7)
    xOffset = xOffset + headers[1].width

    -- Role column
    local roleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    roleText:SetSize(headers[2].width, 20)
    roleText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    roleText:SetJustifyH(headers[2].align)
    local roleDisplay = "?"
    if entry.playerAppliedRole and entry.playerAppliedRole ~= "UNKNOWN" then
        roleDisplay = self:FormatPlayerRole(entry.playerAppliedRole)
    end
    roleText:SetText(roleDisplay)
    roleText:SetTextColor(0.8, 0.8, 1) -- Light blue for role
    xOffset = xOffset + headers[2].width

    -- Status column with color coding
    local statusColor = { 1, 1, 1 }
    if entry.status == "applied" then
        statusColor = { 1, 1, 0 }       -- Yellow
    elseif entry.status == "declined" then
        statusColor = { 1, 0.4, 0.4 }   -- Red
    elseif entry.status == "invited" then
        statusColor = { 0.2, 1, 0.2 }   -- Green
    elseif entry.status == "inviteDeclined" then
        statusColor = { 1, 0.6, 0.2 }   -- Orange
    elseif entry.status == "cancelled" or entry.status == "withdrawapplication" then
        statusColor = { 0.7, 0.7, 0.7 } -- Light grey for cancelled
    elseif entry.status == "delisted" or entry.status == "declined_delisted" then
        statusColor = { 1, 0.5, 0.5 }   -- Light red for delisted (not picked, group became full)
    elseif entry.status == "failed" then
        statusColor = { 1, 0.3, 0.3 }   -- Bright red for failed
        -- Hosting statuses
    elseif entry.status == "Created Group" then
        statusColor = { 0.4, 0.8, 1 }   -- Light blue for group creation
    elseif entry.status == "Completed Group" then
        statusColor = { 0.2, 1, 0.2 }   -- Green for successful completion
    elseif entry.status == "Cancelled Group" then
        statusColor = { 0.7, 0.7, 0.7 } -- Grey for cancelled
    elseif entry.status == "Ended Incomplete" then
        statusColor = { 1, 0.6, 0.2 }   -- Orange for incomplete
    elseif entry.status == "Invited Applicant" then
        statusColor = { 0.6, 1, 0.6 }   -- Light green for invites
    elseif entry.status == "Rejected Applicant" then
        statusColor = { 1, 0.5, 0.5 }   -- Light red for rejections
        -- Named applicant statuses (your decisions only)
    elseif string.find(entry.status, "^Invited: ") then
        statusColor = { 0.6, 1, 0.6 } -- Light green for named invites
    elseif string.find(entry.status, "^Rejected: ") then
        statusColor = { 1, 0.5, 0.5 } -- Light red for named rejections
    elseif entry.status == "Member Joined" then
        statusColor = { 0.5, 1, 0.8 } -- Cyan for joining
    elseif entry.status == "Member Left" then
        statusColor = { 1, 0.8, 0.5 } -- Light orange for leaving
    elseif entry.status == "Hosting" then
        statusColor = { 0.7, 0.5, 1 } -- Purple for generic hosting
    end

    local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetSize(headers[3].width, 20)
    statusText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    statusText:SetJustifyH(headers[3].align)
    statusText:SetText(entry.status:gsub("^%l", string.upper))
    statusText:SetTextColor(unpack(statusColor))
    xOffset = xOffset + headers[3].width

    -- Leader column with class color
    local leaderText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    leaderText:SetSize(headers[4].width, 20)
    leaderText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    leaderText:SetJustifyH(headers[4].align)

    -- Apply class color if available
    local displayName = self:FormatLeaderNameForDisplay(entry.leaderName)

    -- Truncate very long names to fit in column (140px ~= 18-20 chars max)
    if string.len(displayName) > 18 then
        displayName = string.sub(displayName, 1, 15) .. "..."
    end

    if entry.leaderClass then
        local classColor = self:GetClassColorHex(entry.leaderClass)
        displayName = string.format("|c%s%s|r", classColor, displayName)
    end

    leaderText:SetText(displayName)
    leaderText:SetTextColor(1, 1, 1) -- White base color
    xOffset = xOffset + headers[4].width

    -- Members column
    local membersText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    membersText:SetSize(headers[5].width, 20)
    membersText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    membersText:SetJustifyH(headers[5].align)
    membersText:SetText(entry.memberCount or "?/?")
    membersText:SetTextColor(0.8, 1, 0.8)
    xOffset = xOffset + headers[5].width

    -- Activity column (remove role information since it's now in its own column)
    local activityText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    activityText:SetSize(headers[6].width, 20)
    activityText:SetPoint("LEFT", row, "LEFT", xOffset, 0)
    activityText:SetJustifyH(headers[6].align)

    -- Build activity text (role is now in separate column)
    local activityDisplay = entry.activityName or "Mythic Keystone"

    activityText:SetText(activityDisplay)
    activityText:SetTextColor(1, 1, 1) -- White base color for role colors to show

    return row
end

function MTracks:UpdateProgressBars()
    if not self.mainFrame then return end

    local accountData = self.db.global.accountData

    -- Account success rate
    if self.mainFrame.successBar then
        local successRate = accountData.totalApplied > 0 and (accountData.totalAccepted / accountData.totalApplied) or 0
        self.mainFrame.successBar:SetMinMaxValues(0, 1)
        self.mainFrame.successBar:SetValue(successRate)
        if self.mainFrame.successBar.Text then
            self.mainFrame.successBar.Text:SetText("Success Rate: " .. FormatPercentage(successRate * 100))
        end
    end

    -- Account decline rate
    if self.mainFrame.declineBar then
        local declineRate = accountData.totalApplied > 0 and (accountData.totalDeclined / accountData.totalApplied) or 0
        self.mainFrame.declineBar:SetMinMaxValues(0, 1)
        self.mainFrame.declineBar:SetValue(declineRate)
        if self.mainFrame.declineBar.Text then
            self.mainFrame.declineBar.Text:SetText("Decline Rate: " .. FormatPercentage(declineRate * 100))
        end
    end

    -- Account remove rate
    if self.mainFrame.removeBar then
        local removeRate = 0 -- Removed category merged with declined
        self.mainFrame.removeBar:SetMinMaxValues(0, 1)
        self.mainFrame.removeBar:SetValue(removeRate)
        if self.mainFrame.removeBar.Text then
            self.mainFrame.removeBar.Text:SetText("Remove Rate: " .. FormatPercentage(removeRate * 100))
        end
    end
end

-- Event handlers for tracking
function MTracks:LFG_LIST_APPLICATION_STATUS_UPDATED(event, resultID, status)
    if not self.db.profile.autoTrack then return end



    -- Cache application information for ALL status changes to ensure we have historical snapshots
    if resultID then
        if status == "applied" then
            -- Cache immediately when we apply (data should be fresh)
            self:CacheApplicationInfo(resultID, status)
        else
            -- For status updates (accepted, declined, cancelled, etc.), ensure we have cached data
            -- If we don't have it yet, try to cache it now, otherwise just update the status
            local hasExistingCache = false
            if self.db.global.applicationCache then
                for appID, appData in pairs(self.db.global.applicationCache) do
                    if appData.resultID == resultID then
                        -- Update the status of existing cache entry (same session)
                        appData.status = status
                        appData.lastUpdated = time()
                        hasExistingCache = true
                        break
                    end
                end
            end

            -- If we don't have existing cache, try to create it now
            if not hasExistingCache then
                self:CacheApplicationInfo(resultID, status)
            end
        end
    end

    local accountData = self.db.global.accountData


    -- Also save to global character database
    local charInfo = self:GetCurrentCharacterInfo()
    if not self.db.global.characters[charInfo.key] then
        self.db.global.characters[charInfo.key] = {
            applied = 0,
            accepted = 0,
            declined = 0,
            cancelled = 0,
            -- Hosting statistics
            hosted = 0,
            hostedSuccessful = 0,
            hostedCancelled = 0,
            lastActivity = time(),
            name = charInfo.name,
            realm = charInfo.realm,
            class = charInfo.class,
            level = charInfo.level
        }
    else
        -- Update character info in case class or level changed
        local existingChar = self.db.global.characters[charInfo.key]
        existingChar.class = charInfo.class
        existingChar.level = charInfo.level
        existingChar.name = charInfo.name
        existingChar.realm = charInfo.realm
    end
    local globalCharData = self.db.global.characters[charInfo.key]

    -- Track history
    self:AddToHistory(event, resultID, status, resultID)

    if status == "applied" then
        accountData.totalApplied = accountData.totalApplied + 1

        globalCharData.applied = globalCharData.applied + 1

        globalCharData.lastActivity = time()

        -- Update sparkline data
        self:UpdateSparklineData("totalApplied", 1)

        if self.db.profile.notifications then
            self:Print("Application sent!")
        end
    elseif status == "declined" or status == "declined_delisted" then
        -- Clean up any pending invite tracking if application gets declined
        if self.pendingInvites and self.pendingInvites[resultID] then
            self.pendingInvites[resultID] = nil
        end

        accountData.totalDeclined = accountData.totalDeclined + 1

        globalCharData.declined = globalCharData.declined + 1

        -- Update weekly data for sparklines
        self:UpdateSparklineData("totalDeclined", 1)

        if self.db.profile.notifications then
            self:Print("|cffFF6B6BApplication declined.|r")
        end
    elseif status == "invited" then
        -- Store timestamp of invite for 30-second rule tracking
        local inviteTime = time()

        -- Store pending invite info for later classification
        if not self.pendingInvites then
            self.pendingInvites = {}
        end

        self.pendingInvites[resultID] = {
            timestamp = inviteTime,
            accountData = accountData,
            globalCharData = globalCharData
        }

        -- Set timer to classify as success after 30 seconds
        C_Timer.After(30, function()
            if self.pendingInvites and self.pendingInvites[resultID] then
                -- Still in pending state after 30 seconds = success
                local pendingData = self.pendingInvites[resultID]

                pendingData.accountData.totalAccepted = pendingData.accountData.totalAccepted + 1
                pendingData.globalCharData.accepted = pendingData.globalCharData.accepted + 1

                -- Update weekly data for sparklines
                self:UpdateSparklineData("totalAccepted", 1)

                if self.db.profile.notifications then
                    self:Print("|cff51CF66Application successful! (30+ seconds in group)|r")
                end

                -- Clean up pending invite
                self.pendingInvites[resultID] = nil

                -- Update display
                self:UpdateDisplay()
            end
        end)

        if self.db.profile.notifications then
            self:Print("|cff51CF66Application accepted! Tracking for success...|r")
        end
    elseif status == "inviteDeclined" then
        -- Check if this was within 30 seconds of invite (decline) or after (removed)
        if self.pendingInvites and self.pendingInvites[resultID] then
            local pendingData = self.pendingInvites[resultID]
            local timeDiff = time() - pendingData.timestamp

            if timeDiff <= 30 then
                -- Removed within 30 seconds = decline
                accountData.totalDeclined = accountData.totalDeclined + 1

                globalCharData.declined = globalCharData.declined + 1

                self:UpdateSparklineData("totalDeclined", 1)

                if self.db.profile.notifications then
                    self:Print("|cffFF6B6BRemoved from group within 30s (declined).|r")
                end
            else
                -- Removed after 30 seconds = treat as declined
                accountData.totalDeclined = accountData.totalDeclined + 1

                globalCharData.declined = globalCharData.declined + 1

                self:UpdateSparklineData("totalDeclined", 1)

                if self.db.profile.notifications then
                    self:Print("|cffFF6B6BRemoved from group (declined).|r")
                end
            end

            -- Clean up pending invite
            self.pendingInvites[resultID] = nil
        else
            -- No pending invite record, treat as declined
            accountData.totalDeclined = accountData.totalDeclined + 1

            globalCharData.declined = globalCharData.declined + 1

            self:UpdateSparklineData("totalDeclined", 1)

            if self.db.profile.notifications then
                self:Print("|cffFF6B6BRemoved from group (declined).|r")
            end
        end
    elseif status == "cancelled" or status == "withdrawapplication" then
        -- Clean up any pending invite tracking if player cancels after being invited
        if self.pendingInvites and self.pendingInvites[resultID] then
            self.pendingInvites[resultID] = nil
        end

        accountData.totalCancelled = accountData.totalCancelled + 1

        globalCharData.cancelled = globalCharData.cancelled + 1

        -- Update weekly data for sparklines
        self:UpdateSparklineData("totalCancelled", 1)

        if self.db.profile.notifications then
            self:Print("|cffFFFF66Application cancelled.|r")
        end
    elseif status == "failed" then
        -- Clean up any pending invite tracking if application fails
        if self.pendingInvites and self.pendingInvites[resultID] then
            self.pendingInvites[resultID] = nil
        end

        -- Track failed applications as declined for statistics
        accountData.totalDeclined = accountData.totalDeclined + 1

        globalCharData.declined = globalCharData.declined + 1

        -- Update weekly data for sparklines
        self:UpdateSparklineData("totalDeclined", 1)

        if self.db.profile.notifications then
            self:Print("|cffFF6B6BApplication failed.|r")
        end
    end

    accountData.lastUpdate = time()
    self:UpdateDisplay()
end

function MTracks:LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS()
    if not self.db.profile.autoTrack then return end

    local accountData = self.db.global.accountData

    -- Also save to global character database
    local charInfo = self:GetCurrentCharacterInfo()
    if not self.db.global.characters[charInfo.key] then
        self.db.global.characters[charInfo.key] = {
            applied = 0,
            accepted = 0,
            declined = 0,
            cancelled = 0,
            -- Hosting statistics
            hosted = 0,
            hostedSuccessful = 0,
            hostedCancelled = 0,
            lastActivity = time(),
            name = charInfo.name,
            realm = charInfo.realm,
            class = charInfo.class,
            level = charInfo.level
        }
    else
        -- Update character info in case class or level changed
        local existingChar = self.db.global.characters[charInfo.key]
        existingChar.class = charInfo.class
        existingChar.level = charInfo.level
        existingChar.name = charInfo.name
        existingChar.realm = charInfo.realm
    end
    local globalCharData = self.db.global.characters[charInfo.key]

    -- Track history for declined groups (listing cancelled by leader)
    self:AddToHistory("LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS", nil, "declined", nil)

    -- Count as declined since listing was cancelled by leader, not player
    accountData.totalDeclined = accountData.totalDeclined + 1

    globalCharData.declined = globalCharData.declined + 1

    -- Update weekly data for sparklines
    self:UpdateSparklineData("totalDeclined", 1)

    accountData.lastUpdate = time()

    if self.db.profile.notifications then
        self:Print("|cffFFA500Group listing cancelled by leader (declined).|r")
    end

    self:UpdateDisplay()
end

function MTracks:ShowStats()
    local accountData = self.db.global.accountData
    local currentChar = self:GetCurrentCharacterInfo()
    local charData = self.db.global.characters[currentChar.key] or {}

    self:Print("=== MTracks Statistics ===")
    self:Print(string.format("Account-wide: %d applied, %d accepted (%.1f%%), %d declined (%.1f%%)",
        accountData.totalApplied,
        accountData.totalAccepted,
        accountData.totalApplied > 0 and (accountData.totalAccepted / accountData.totalApplied * 100) or 0,
        accountData.totalDeclined,
        accountData.totalApplied > 0 and (accountData.totalDeclined / accountData.totalApplied * 100) or 0
    ))

    self:Print(string.format("This character: %d applied, %d accepted (%.1f%%), %d declined (%.1f%%)",
        charData.applied,
        charData.accepted,
        charData.applied > 0 and (charData.accepted / charData.applied * 100) or 0,
        charData.declined,
        charData.applied > 0 and (charData.declined / charData.applied * 100) or 0
    ))
end

function MTracks:ResetData()
    self.db:ResetDB()
    self:Print("All data has been reset.")
    self:UpdateDisplay()
end

function MTracks:SetupConfiguration()
    -- Create Ace3 configuration options table
    local options = {
        type = "group",
        name = "MTracks",
        desc = "Mythic+ Group Application Tracker Settings",
        args = {
            general = {
                type = "group",
                name = "General Settings",
                desc = "Basic addon configuration",
                order = 1,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "Enable MTracks",
                        desc = "Enable or disable the addon",
                        get = function() return self.db.profile.enabled end,
                        set = function(_, value) self.db.profile.enabled = value end,
                        order = 1,
                    },
                    autoTrack = {
                        type = "toggle",
                        name = "Auto-track Applications",
                        desc = "Automatically track your Mythic+ group applications",
                        get = function() return self.db.profile.autoTrack end,
                        set = function(_, value)
                            self.db.profile.autoTrack = value
                            self:Print("Auto-tracking " .. (value and "enabled" or "disabled"))
                        end,
                        order = 2,
                    },
                    notifications = {
                        type = "toggle",
                        name = "Show Notifications",
                        desc = "Show chat notifications for application status changes",
                        get = function() return self.db.profile.notifications end,
                        set = function(_, value)
                            self.db.profile.notifications = value
                            self:Print("Notifications " .. (value and "enabled" or "disabled"))
                        end,
                        order = 3,
                    },
                    showMinimap = {
                        type = "toggle",
                        name = "Show Minimap Button",
                        desc = "Show or hide the minimap button",
                        get = function() return self.db.profile.showMinimap end,
                        set = function(_, value)
                            self.db.profile.showMinimap = value
                            if self.minimapButton then
                                if value then
                                    self.minimapButton:Show("MTracks")
                                else
                                    self.minimapButton:Hide("MTracks")
                                end
                            end
                            self:Print("Minimap button " .. (value and "shown" or "hidden"))
                        end,
                        order = 4,
                    },
                }
            },

            actions = {
                type = "group",
                name = "Actions",
                desc = "Addon actions and utilities",
                order = 3,
                args = {
                    openTracker = {
                        type = "execute",
                        name = "Open Tracker",
                        desc = "Open the main MTracks window",
                        func = function() self:ToggleMainFrame() end,
                        order = 1,
                    },

                    showStats = {
                        type = "execute",
                        name = "Show Statistics",
                        desc = "Display statistics in chat",
                        func = function() self:ShowStats() end,
                        order = 3,
                    },
                    exportData = {
                        type = "execute",
                        name = "Export Data",
                        desc = "Export your MTracks data for backup or sharing",
                        func = function() self:ExportData() end,
                        order = 4,
                    },
                    header = {
                        type = "header",
                        name = "Data Management",
                        order = 5,
                    },
                    resetData = {
                        type = "execute",
                        name = "Reset All Data",
                        desc = "WARNING: This will permanently delete all MTracks data!",
                        func = function() StaticPopup_Show("MTRACKS_RESET_CONFIRM") end,
                        confirm = true,
                        confirmText = "Are you sure you want to reset all data? This cannot be undone!",
                        order = 6,
                    },
                }
            }
        }
    }

    -- Register with AceConfig
    local AceConfig = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    AceConfig:RegisterOptionsTable("MTracks", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("MTracks", "MTracks")
end

function MTracks:SetupEscapeHandling()
    -- Hook into CloseSpecialWindows to handle escape properly
    if not self.originalCloseSpecialWindows then
        self.originalCloseSpecialWindows = CloseSpecialWindows
        CloseSpecialWindows = function()
            local closedSomething = false

            -- Close character history window first (if open)
            if self.characterHistoryFrame and self.characterHistoryFrame:IsShown() then
                self:CloseCharacterHistory()
                closedSomething = true
            end

            -- Close main MTracks window (logo will hide automatically as child)
            if self.mainFrame and self.mainFrame:IsShown() then
                self.mainFrame:Hide()
                closedSomething = true
            end

            -- If we closed something, don't call the original function
            if closedSomething then
                return true
            end

            -- Otherwise, call the original function
            return self.originalCloseSpecialWindows()
        end
    end
end

function MTracks:OpenSettings()
    -- Open the Ace3 config dialog
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    AceConfigDialog:Open("MTracks")
end

function MTracks:ExportData()
    local accountData = self.db.global.accountData
    local currentChar = self:GetCurrentCharacterInfo()
    local charData = self.db.global.characters[currentChar.key] or {}

    local exportString = string.format(
        "MTracks Data Export (%s)\n\n",
        tostring(date("%Y-%m-%d %H:%M:%S"))
    )

    exportString = exportString .. "=== ACCOUNT STATISTICS ===\n"
    exportString = exportString .. string.format("Total Applied: %d\n", accountData.totalApplied)
    exportString = exportString .. string.format("Total Accepted: %d (%.1f%%)\n",
        accountData.totalAccepted,
        accountData.totalApplied > 0 and (accountData.totalAccepted / accountData.totalApplied * 100) or 0)
    exportString = exportString .. string.format("Total Declined: %d (%.1f%%)\n",
        accountData.totalDeclined,
        accountData.totalApplied > 0 and (accountData.totalDeclined / accountData.totalApplied * 100) or 0)

    exportString = exportString .. string.format("Last Update: %s\n\n",
        accountData.lastUpdate > 0 and tostring(date("%Y-%m-%d %H:%M:%S", accountData.lastUpdate)) or "Never")

    exportString = exportString .. "=== CHARACTER STATISTICS ===\n"
    exportString = exportString .. string.format("Character: %s\n", UnitName("player") or "Unknown")
    exportString = exportString .. string.format("Realm: %s\n", GetRealmName() or "Unknown")
    exportString = exportString .. string.format("Faction: %s\n", UnitFactionGroup("player") or "Unknown")
    exportString = exportString .. string.format("Applied: %d\n", charData.applied)
    exportString = exportString .. string.format("Accepted: %d (%.1f%%)\n",
        charData.accepted,
        charData.applied > 0 and (charData.accepted / charData.applied * 100) or 0)
    exportString = exportString .. string.format("Declined: %d (%.1f%%)\n",
        charData.declined,
        charData.applied > 0 and (charData.declined / charData.applied * 100) or 0)

    exportString = exportString .. string.format("Last Activity: %s\n",
        charData.lastActivity > 0 and tostring(date("%Y-%m-%d %H:%M:%S", charData.lastActivity)) or "Never")

    -- Create export frame
    local exportFrame = CreateFrame("Frame", "MTracksExportFrame", UIParent, "BackdropTemplate")
    exportFrame:SetSize(500, 400)
    exportFrame:SetPoint("CENTER", UIParent, "CENTER")
    exportFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeFile = nil,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    exportFrame:SetBackdropColor(unpack(COLORS.background))
    exportFrame:EnableMouse(true)
    exportFrame:SetMovable(true)
    exportFrame:RegisterForDrag("LeftButton")
    exportFrame:SetScript("OnDragStart", exportFrame.StartMoving)
    exportFrame:SetScript("OnDragStop", exportFrame.StopMovingOrSizing)

    -- Title
    local title = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("MTracks Data Export")

    -- Scroll frame for text
    local scrollFrame = CreateFrame("ScrollFrame", nil, exportFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(450, 300)
    scrollFrame:SetPoint("TOPLEFT", 20, -50)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetSize(430, 300)
    editBox:SetMultiLine(true)
    editBox:SetFontObject("GameFontHighlight")
    editBox:SetText(exportString)
    editBox:SetAutoFocus(false)
    editBox:HighlightText()
    editBox:SetScript("OnEscapePressed", function() exportFrame:Hide() end)

    scrollFrame:SetScrollChild(editBox)

    -- Close button
    local closeButton = CreateFrame("Button", nil, exportFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() exportFrame:Hide() end)

    -- Instructions
    local instructions = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    instructions:SetPoint("BOTTOM", 0, 15)
    instructions:SetText("Press Ctrl+C to copy, then Ctrl+V to paste elsewhere")

    exportFrame:Show()
end

-- Hosting tracking implementation
function MTracks:InitializeHostingTracking()
    -- Initialize hosting state tracking
    self.hostingData = {
        isHosting = false,
        currentEntry = nil,
        hasInvitedAnyone = false,
        groupMembers = {},
        maxMembers = 5,
        startTime = nil
    }
end

function MTracks:LFG_LIST_APPLICANT_UPDATED(event, resultID, applicantID, status, pendingActionTime, role)
    if not self.db.profile.autoTrack then return end

    -- Only track if we're the group leader hosting
    if not self:IsHostingGroup() then return end

    -- When you reject someone, Blizzard sends nil parameters
    -- This is a known limitation of the LFG API
    if status == nil and applicantID == nil then
        -- Prevent duplicate rejection logs by throttling
        local now = time()
        if not self.hostingData.lastRejectionTime or (now - self.hostingData.lastRejectionTime) > 2 then
            -- Get our active entry to log a general rejection
            local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
            if activeEntryInfo then
                self:AddHostingHistoryEntry("applicant_declined", activeEntryInfo.resultID, nil, nil)
                self.hostingData.lastRejectionTime = now
            end
        end
        return
    end

    -- Only track YOUR decisions as group leader, not every applicant
    if status == "invited" then
        -- We invited someone (our decision to invite)
        self.hostingData.hasInvitedAnyone = true
        self:AddHostingHistoryEntry("applicant_invited", resultID, applicantID, role)
    elseif status == "declined" then
        -- We declined/rejected someone (our decision to reject)
        self:AddHostingHistoryEntry("applicant_declined", resultID, applicantID, role)
    end
end

function MTracks:GROUP_ROSTER_UPDATE(event)
    if not self.db.profile.autoTrack then return end
    if not self:IsHostingGroup() then return end

    local currentMembers = GetNumGroupMembers()
    local previousMembers = #self.hostingData.groupMembers

    -- Update member list
    self:UpdateHostingMemberList()

    -- Check if group is full
    if currentMembers >= self.hostingData.maxMembers and previousMembers < self.hostingData.maxMembers then
        -- Group just became full - count as successful hosting
        self:CompleteHostedGroup(true)
    elseif currentMembers < previousMembers then
        -- Someone left the group
        self:AddHostingHistoryEntry("member_left", nil, nil, nil)
    elseif currentMembers > previousMembers and previousMembers > 0 then
        -- Someone joined the group (but not the initial host joining)
        self:AddHostingHistoryEntry("member_joined", nil, nil, nil)
    end
end

function MTracks:LFG_LIST_ACTIVE_ENTRY_UPDATE(event, entryCreated)
    if not self.db.profile.autoTrack then return end

    if entryCreated then
        -- We just created a group listing
        self:StartHostingGroup()
    else
        -- Our group listing was removed/ended
        -- Add a small delay to avoid false cancellations during group creation
        C_Timer.After(0.1, function()
            if not C_LFGList.GetActiveEntryInfo() then
                -- Confirmed: we really don't have an active listing anymore
                self:EndHostingGroup()
            end
        end)
    end
end

function MTracks:IsHostingGroup()
    -- Check if we have an active LFG listing and are the leader
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
    local isLeader = UnitIsGroupLeader and UnitIsGroupLeader("player") or (_G.IsPartyLeader and _G.IsPartyLeader())
    return activeEntryInfo ~= nil and isLeader
end

function MTracks:StartHostingGroup()
    self.hostingData.isHosting = true
    self.hostingData.hasInvitedAnyone = false
    self.hostingData.startTime = time()
    self.hostingData.groupMembers = {}

    -- Get max members for this activity type
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
    if activeEntryInfo then
        local activityID = (activeEntryInfo and activeEntryInfo.activityID) or
            (activeEntryInfo and activeEntryInfo.activityIDs and activeEntryInfo.activityIDs[1])
        if activityID then
            local activityInfo = C_LFGList.GetActivityInfoTable(activityID)
            if activityInfo and activityInfo.maxNumPlayers then
                self.hostingData.maxMembers = activityInfo.maxNumPlayers
            end
        end
    end

    -- Increment hosted counter
    self:IncrementHostingStats("hosted")

    self:AddHostingHistoryEntry("group_created", nil, nil, nil)

    if self.db.profile.notifications then
        self:Print("|cff00FF00Started hosting LFG group.|r")
    end
end

function MTracks:EndHostingGroup()
    if not self.hostingData.isHosting then return end

    local wasSuccessful = GetNumGroupMembers() >= self.hostingData.maxMembers

    if not self.hostingData.hasInvitedAnyone then
        -- Cancelled without inviting anyone
        self:IncrementHostingStats("hostedCancelled")
        self:AddHostingHistoryEntry("group_cancelled", nil, nil, nil)

        if self.db.profile.notifications then
            self:Print("|cffFFFF66Hosting cancelled (no invites sent).|r")
        end
    elseif not wasSuccessful then
        -- Ended before completion
        self:AddHostingHistoryEntry("group_ended_incomplete", nil, nil, nil)

        if self.db.profile.notifications then
            self:Print("|cffFFA500Hosting ended (group incomplete).|r")
        end
    end

    self.hostingData.isHosting = false
    self.hostingData.currentEntry = nil
    self.hostingData.hasInvitedAnyone = false
    self.hostingData.groupMembers = {}
end

function MTracks:CompleteHostedGroup(successful)
    if not self.hostingData.isHosting then return end

    if successful then
        self:IncrementHostingStats("hostedSuccessful")
        self:AddHostingHistoryEntry("group_completed", nil, nil, nil)

        if self.db.profile.notifications then
            self:Print("|cff00FF00Hosting successful (group full)!|r")
        end
    end
end

function MTracks:UpdateHostingMemberList()
    local members = {}
    local numMembers = GetNumGroupMembers()

    for i = 1, numMembers do
        local unit = "party" .. i
        if UnitExists(unit) then
            local name = UnitName(unit)
            if name then
                table.insert(members, name)
            end
        end
    end

    self.hostingData.groupMembers = members
end

function MTracks:IncrementHostingStats(statType)
    local accountData = self.db.global.accountData
    local charInfo = self:GetCurrentCharacterInfo()
    local globalCharData = self.db.global.characters[charInfo.key]

    -- Increment account-wide stats
    if statType == "hosted" then
        accountData.totalHosted = (accountData.totalHosted or 0) + 1
    elseif statType == "hostedSuccessful" then
        accountData.totalHostedSuccessful = (accountData.totalHostedSuccessful or 0) + 1
    elseif statType == "hostedCancelled" then
        accountData.totalHostedCancelled = (accountData.totalHostedCancelled or 0) + 1
    end

    -- Increment character-specific stats
    if globalCharData then
        if statType == "hosted" then
            globalCharData.hosted = (globalCharData.hosted or 0) + 1
        elseif statType == "hostedSuccessful" then
            globalCharData.hostedSuccessful = (globalCharData.hostedSuccessful or 0) + 1
        elseif statType == "hostedCancelled" then
            globalCharData.hostedCancelled = (globalCharData.hostedCancelled or 0) + 1
        end
        globalCharData.lastActivity = time()
    end

    -- Update sparkline data
    if statType == "hosted" then
        self:UpdateSparklineData("totalHosted", 1)
    elseif statType == "hostedSuccessful" then
        self:UpdateSparklineData("totalHostedSuccessful", 1)
    elseif statType == "hostedCancelled" then
        self:UpdateSparklineData("totalHostedCancelled", 1)
    end

    accountData.lastUpdate = time()
    self:UpdateDisplay()
end

function MTracks:AddHostingHistoryEntry(eventType, resultID, applicantID, role)
    if not self.db.profile.autoTrack then return end

    local history = self.db.global.history
    local maxEntries = self.db.global.maxHistoryEntries or 100

    -- Get current group info
    local activeEntryInfo = C_LFGList.GetActiveEntryInfo()
    local activityInfo = nil

    if activeEntryInfo then
        local activityID = activeEntryInfo.activityID or (activeEntryInfo.activityIDs and activeEntryInfo.activityIDs[1])
        if activityID then
            activityInfo = C_LFGList.GetActivityInfoTable(activityID)
        end
    end

    local leaderName = UnitName("player") .. "-" .. GetRealmName()
    local activityName = activityInfo and activityInfo.fullName or "Unknown Activity"
    local memberCount = string.format("%d/%d", GetNumGroupMembers(), self.hostingData.maxMembers)

    -- Get applicant details if this is an applicant-specific event
    local applicantName = nil
    local applicantComment = nil
    local applicantItemLevel = nil
    local applicantDungeonScore = nil

    if applicantID and activeEntryInfo then
        local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
        if applicantInfo then
            applicantName = (applicantInfo and applicantInfo.name) or "Unknown Applicant"
            applicantComment = (applicantInfo and applicantInfo.comment) or ""
            applicantItemLevel = (applicantInfo and applicantInfo.itemLevel) or 0
            applicantDungeonScore = (applicantInfo and applicantInfo.dungeonScore) or 0
        end
    end

    -- Create hosting history entry
    local entry = {
        timestamp = time(),
        eventType = eventType,
        status = self:GetHostingStatusFromEventType(eventType, applicantName),
        resultID = resultID,
        applicantID = applicantID,

        -- Core group data
        leaderName = leaderName,
        activityName = activityName,
        memberCount = memberCount,
        levelRange = activeEntryInfo and activeEntryInfo.requiredItemLevel and
            string.format("ilvl %d+", activeEntryInfo.requiredItemLevel) or "No Requirement",
        itemLevel = activeEntryInfo and activeEntryInfo.requiredItemLevel or 0,
        groupDesiredRoles = "Various",

        -- Hosting-specific data
        isHostingEvent = true,
        hostingRole = role,

        -- Applicant-specific data (for applicant events)
        applicantName = applicantName,
        applicantComment = applicantComment,
        applicantItemLevel = applicantItemLevel,
        applicantDungeonScore = applicantDungeonScore,
        applicantRole = role, -- Role the applicant applied for

        -- Player context (use player's actual role when hosting)
        characterName = UnitName("player"),
        realmName = GetRealmName(),
        playerAppliedRole = self:GetPlayerCurrentRole(), -- Player's own role when hosting

        -- Timing
        appliedTime = self.hostingData.startTime or time(),
        lastUpdated = time(),
    }

    -- Add to beginning of array (most recent first)
    table.insert(history, 1, entry)

    -- Keep only the last maxEntries
    while #history > maxEntries do
        table.remove(history)
    end
end
