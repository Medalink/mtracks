-- Logo.lua - Reusable logo creation system for MTracks
-- Creates styled text logos with gradients and custom styling

local Logo = {}

-- Helper function to interpolate between two RGB colors
local function InterpolateColor(startR, startG, startB, endR, endG, endB, factor)
    factor = math.max(0, math.min(1, factor)) -- Clamp between 0 and 1
    local r = startR + (endR - startR) * factor
    local g = startG + (endG - startG) * factor
    local b = startB + (endB - startB) * factor
    return r, g, b
end

-- Convert RGB (0-1) to hex color code for WoW
local function RGBToHex(r, g, b)
    return string.format("%02x%02x%02x",
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255))
end

-- Create gradient text with color codes
local function CreateGradientText(text, startColor, endColor, direction)
    direction = direction or "horizontal" -- "horizontal" or "vertical"

    local result = ""
    local textLength = string.len(text)

    for i = 1, textLength do
        local char = string.sub(text, i, i)
        local factor = (i - 1) / math.max(1, textLength - 1)

        local r, g, b = InterpolateColor(
            startColor.r, startColor.g, startColor.b,
            endColor.r, endColor.g, endColor.b,
            factor
        )

        local hexColor = RGBToHex(r, g, b)
        result = result .. "|cff" .. hexColor .. char
    end

    return result .. "|r"
end

-- Parse text into words and identify first letters
local function ParseWords(text)
    local words = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(words, {
            text = word,
            firstLetter = string.sub(word, 1, 1),
            restOfWord = string.sub(word, 2)
        })
    end
    return words
end

-- Simplified function to create a styled logo - text is now a separate parameter
function Logo:CreateStyledLogo(parentFrame, text, options)
    options = options or {}

    -- Handle legacy usage where text was inside options table
    if type(text) == "table" then
        options = text
        text = options.text or "Sample Text"
    end

    -- Simplified options with great defaults - most users only need to specify text!
    local opts = {
        text = text,
        position = options.position or { x = 0, y = 0 },
        anchor = options.anchor or "CENTER",
        anchorTo = options.anchorTo or "CENTER",

        -- Font settings - more stylized defaults to match logo design
        firstLetterFont = options.firstLetterFont or "Fonts\\SKURRI.TTF", -- Fantasy/decorative style
        firstLetterSize = options.firstLetterSize or 72,                  -- Larger for impact
        restFont = options.restFont or "Fonts\\SKURRI.TTF",               -- Matching fantasy style
        restSize = options.restSize or 52,

        -- Colors - rich metallic gold gradient to match logo design
        startColor = options.startColor or { r = 1, g = 0.9, b = 0.3 }, -- Bright metallic gold
        endColor = options.endColor or { r = 0.8, g = 0.5, b = 0.1 },   -- Deep bronze gold
        gradientDirection = options.gradientDirection or "vertical",    -- Top-down gradient looks more dynamic

        -- Outline settings - clean black outlines look much better
        outlineEnabled = options.outlineEnabled ~= false,      -- Default true
        outlineStyle = options.outlineStyle or "THICKOUTLINE", -- OUTLINE, THICKOUTLINE, MONOCHROME

        -- Spacing - optimized for readability
        letterSpacing = options.letterSpacing or 8,
        wordSpacing = options.wordSpacing or 15,

        -- New option: Only style the very first letter of the entire text
        firstLetterOnly = options.firstLetterOnly or false,

        -- Size - fits most UI layouts perfectly
        containerSize = options.containerSize or { width = 400, height = 100 }
    }

    -- Create container frame
    local logoFrame = CreateFrame("Frame", nil, parentFrame)
    logoFrame:SetPoint(opts.anchor, parentFrame, opts.anchorTo, opts.position.x, opts.position.y)
    logoFrame:SetSize(opts.containerSize.width, opts.containerSize.height)

    local totalWidth = 0
    local renderData = {}

    if opts.firstLetterOnly then
        -- New mode: Only style the very first letter of the entire text
        local textLength = string.len(opts.text)
        if textLength > 0 then
            local firstChar = string.sub(opts.text, 1, 1)
            local restOfText = string.sub(opts.text, 2)

            -- Calculate first letter width (with special handling for M)
            local firstLetterSize = (firstChar == "M") and (opts.firstLetterSize + 8) or opts.firstLetterSize
            local firstLetterWidth = firstLetterSize * 0.7
            totalWidth = totalWidth + firstLetterWidth + opts.letterSpacing

            -- Add rest of text width
            if string.len(restOfText) > 0 then
                local restWidth = string.len(restOfText) * opts.restSize * 0.6
                totalWidth = totalWidth + restWidth
            end

            renderData = {
                mode = "firstLetterOnly",
                firstChar = firstChar,
                restOfText = restOfText
            }
        end
    else
        -- Original mode: Style first letter of each word
        local words = ParseWords(opts.text)

        for wordIndex, wordData in ipairs(words) do
            -- Calculate first letter width
            local firstLetterSize = (wordData.firstLetter == "M") and (opts.firstLetterSize + 8) or opts.firstLetterSize
            local firstLetterWidth = firstLetterSize * 0.7
            totalWidth = totalWidth + firstLetterWidth + opts.letterSpacing

            -- Add rest of word width if it exists
            if string.len(wordData.restOfWord) > 0 then
                local restWidth = string.len(wordData.restOfWord) * opts.restSize * 0.6
                totalWidth = totalWidth + restWidth
            end

            -- Add word spacing (except for last word)
            if wordIndex < #words then
                totalWidth = totalWidth + opts.wordSpacing
            end
        end

        renderData = {
            mode = "perWord",
            words = words
        }
    end

    -- Calculate starting X position to center the text
    local startX = (opts.containerSize.width - totalWidth) / 2

    -- Create text elements based on mode
    local currentX = startX
    local elements = {}

    if renderData.mode == "firstLetterOnly" then
        -- New mode: Only style the very first letter
        if renderData.firstChar then
            -- Create first letter (large) with enhanced styling
            local firstLetter = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge3")
            firstLetter:SetPoint("LEFT", logoFrame, "LEFT", currentX, 0)

            -- Use configurable outline styling
            if renderData.firstChar == "M" then
                firstLetter:SetFont(opts.firstLetterFont, opts.firstLetterSize + 8, opts.outlineStyle)
            else
                firstLetter:SetFont(opts.firstLetterFont, opts.firstLetterSize, opts.outlineStyle)
            end

            -- Apply gradient to first letter
            local firstLetterGradient = CreateGradientText(renderData.firstChar, opts.startColor, opts.endColor,
                opts.gradientDirection)
            firstLetter:SetText(firstLetterGradient)
            table.insert(elements, firstLetter)

            -- Calculate first letter width
            local firstLetterWidth = opts.firstLetterSize * 0.7
            currentX = currentX + firstLetterWidth + opts.letterSpacing

            -- Create rest of text (smaller, uniform styling)
            if string.len(renderData.restOfText) > 0 then
                local restText = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge2")
                restText:SetPoint("LEFT", logoFrame, "LEFT", currentX, 0)
                restText:SetFont(opts.restFont, opts.restSize, opts.outlineStyle)

                -- Apply gradient to rest of text
                local restGradient = CreateGradientText(renderData.restOfText, opts.startColor, opts.endColor,
                    opts.gradientDirection)
                restText:SetText(restGradient)
                table.insert(elements, restText)
            end
        end
    else
        -- Original mode: Style first letter of each word
        for wordIndex, wordData in ipairs(renderData.words) do
            -- Create first letter (large) with enhanced styling
            local firstLetter = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge3")
            firstLetter:SetPoint("LEFT", logoFrame, "LEFT", currentX, 0)

            -- Use configurable outline styling
            if wordData.firstLetter == "M" then
                firstLetter:SetFont(opts.firstLetterFont, opts.firstLetterSize + 8, opts.outlineStyle)
            else
                firstLetter:SetFont(opts.firstLetterFont, opts.firstLetterSize, opts.outlineStyle)
            end

            -- Apply gradient to first letter
            local firstLetterGradient = CreateGradientText(wordData.firstLetter, opts.startColor, opts.endColor,
                opts.gradientDirection)
            firstLetter:SetText(firstLetterGradient)
            table.insert(elements, firstLetter)

            -- Calculate first letter width
            local firstLetterWidth = opts.firstLetterSize * 0.7
            currentX = currentX + firstLetterWidth + opts.letterSpacing

            -- Create rest of word (smaller) if it exists
            if string.len(wordData.restOfWord) > 0 then
                local restText = logoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge2")
                restText:SetPoint("LEFT", logoFrame, "LEFT", currentX, 0)
                restText:SetFont(opts.restFont, opts.restSize, opts.outlineStyle)

                -- Apply gradient to rest of word
                local restGradient = CreateGradientText(wordData.restOfWord, opts.startColor, opts.endColor,
                    opts.gradientDirection)
                restText:SetText(restGradient)
                table.insert(elements, restText)

                -- Calculate rest of word width
                local restWidth = string.len(wordData.restOfWord) * opts.restSize * 0.6
                currentX = currentX + restWidth
            end

            -- Add word spacing (except for last word)
            if wordIndex < #renderData.words then
                currentX = currentX + opts.wordSpacing
            end
        end
    end

    -- Store elements in the logo frame for later access
    logoFrame.elements = elements
    logoFrame.options = opts

    return logoFrame
end

-- Utility function to update logo colors
function Logo:UpdateLogoColors(logoFrame, startColor, endColor)
    if not logoFrame or not logoFrame.elements or not logoFrame.options then
        return
    end

    local opts = logoFrame.options
    opts.startColor = startColor
    opts.endColor = endColor

    if opts.firstLetterOnly then
        -- Handle firstLetterOnly mode
        local textLength = string.len(opts.text)
        if textLength > 0 then
            local firstChar = string.sub(opts.text, 1, 1)
            local restOfText = string.sub(opts.text, 2)

            local elementIndex = 1

            -- Update first letter
            if logoFrame.elements[elementIndex] then
                local firstLetterGradient = CreateGradientText(firstChar, startColor, endColor, opts.gradientDirection)
                logoFrame.elements[elementIndex]:SetText(firstLetterGradient)
                elementIndex = elementIndex + 1
            end

            -- Update rest of text if it exists
            if string.len(restOfText) > 0 and logoFrame.elements[elementIndex] then
                local restGradient = CreateGradientText(restOfText, startColor, endColor, opts.gradientDirection)
                logoFrame.elements[elementIndex]:SetText(restGradient)
            end
        end
    else
        -- Handle original per-word mode
        local words = ParseWords(opts.text)
        local elementIndex = 1

        for wordIndex, wordData in ipairs(words) do
            -- Update first letter
            local firstLetter = logoFrame.elements[elementIndex]
            if firstLetter then
                local firstLetterGradient = CreateGradientText(wordData.firstLetter, startColor, endColor,
                    opts.gradientDirection)
                firstLetter:SetText(firstLetterGradient)
            end
            elementIndex = elementIndex + 1

            -- Update rest of word if it exists
            if string.len(wordData.restOfWord) > 0 then
                local restText = logoFrame.elements[elementIndex]
                if restText then
                    local restGradient = CreateGradientText(wordData.restOfWord, startColor, endColor, opts
                        .gradientDirection)
                    restText:SetText(restGradient)
                end
                elementIndex = elementIndex + 1
            end
        end
    end
end

-- Attach to MTracks if it exists, or make it globally available
if MTracks then
    MTracks.Logo = Logo
else
    _G.MTracksLogo = Logo -- Fallback global
end

return Logo
