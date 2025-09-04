-- LibDBIcon-1.0
-- Simple minimap button library for WoW addons

local MAJOR, MINOR = "LibDBIcon-1.0", 55
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.objects = lib.objects or {}
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)

local function getAnchors(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return "CENTER" end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
    local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"
    return vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf
end

local function onEnter(self)
    if self.dataObject.OnTooltipShow then
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(getAnchors(self))
        self.dataObject.OnTooltipShow(GameTooltip)
        GameTooltip:Show()
    elseif self.dataObject.OnEnter then
        self.dataObject.OnEnter(self)
    end
end

local function onLeave(self)
    GameTooltip:Hide()
    if self.dataObject.OnLeave then
        self.dataObject.OnLeave(self)
    end
end

local function onClick(self, button)
    if self.dataObject.OnClick then
        self.dataObject.OnClick(self, button)
    end
end

function lib:Register(name, object, db)
    if not object.type or object.type ~= "data source" then return end

    local button = CreateFrame("Button", ("LibDBIconButton%s"):format(name), Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("anyUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture(object.icon or "Interface\\Icons\\Achievement_General_StayClassy")
    button.icon = icon

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetPoint("TOPLEFT")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    button.dataObject = object
    button:SetScript("OnEnter", onEnter)
    button:SetScript("OnLeave", onLeave)
    button:SetScript("OnClick", onClick)

    self.objects[name] = button

    -- Position button on minimap
    local angle = (db and db.minimapPos) and db.minimapPos or 225
    local x, y = cos(angle), sin(angle)
    button:SetPoint("CENTER", Minimap, "CENTER", x * 80, y * 80)

    if db and db.hide then
        button:Hide()
    else
        button:Show()
    end
end

function lib:Hide(name)
    if not self.objects[name] then return end
    self.objects[name]:Hide()
end

function lib:Show(name)
    if not self.objects[name] then return end
    self.objects[name]:Show()
end

function lib:IsRegistered(name)
    return self.objects[name] and true or false
end

function lib:Refresh(name, db)
    local button = self.objects[name]
    if not button then return end

    if db and db.hide then
        button:Hide()
    else
        button:Show()
    end

    if db and db.minimapPos then
        local angle = db.minimapPos
        local x, y = cos(angle), sin(angle)
        button:SetPoint("CENTER", Minimap, "CENTER", x * 80, y * 80)
    end
end

function lib:GetMinimapButton(name)
    return self.objects[name]
end
