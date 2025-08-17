-- Auction House Value Highlighter Classic
-- Highlights items in the auction house that are priced below vendor sell price
-- For WoW Classic 1.12

-- Create the main addon frame (global)
AHVH = CreateFrame('Frame', 'AuctionHouseValueHighlighter', UIParent)

-- Default settings
local defaultSettings = {
    enabled = true,
    highlightColor = {r = 1, g = 0, b = 0, a = 0.3}, -- Red highlight with transparency
    minProfitPercent = 10,
    minProfitCopper = 1000, -- Minimum profit in copper (10 silver = 1000 copper)
    enableSound = true,
    enableTooltip = true
}

-- Initialize saved variables
function AHVH:InitializeSettings()
    if not AHVHSettings then
        AHVHSettings = {}
    end
    
    for key, value in pairs(defaultSettings) do
        if AHVHSettings[key] == nil then
            AHVHSettings[key] = value
        end
    end
end

-- Print function
function AHVH:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00AHVH:|r " .. msg)
end

-- Get vendor sell price for an item (Classic API)
function AHVH:GetVendorSellPrice(itemLink)
    if not itemLink then return 0 end
    
    -- Parse item ID from link
    local _, _, itemID = string.find(itemLink, "item:(%d+)")
    if not itemID then return 0 end
    itemID = tonumber(itemID)
    
    -- Get item info using Classic API
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, 
          itemStackCount, itemEquipLoc, itemTexture, sellPrice = GetItemInfo(itemID)
    
    return sellPrice or 0
end

-- Calculate profit potential
function AHVH:CalculateProfit(buyoutPrice, vendorPrice, stackSize)
    if not buyoutPrice or not vendorPrice or buyoutPrice <= 0 or vendorPrice <= 0 then
        return 0, 0
    end
    
    stackSize = stackSize or 1
    local totalVendorValue = vendorPrice * stackSize
    local profit = totalVendorValue - buyoutPrice
    local profitPercent = (profit / buyoutPrice) * 100
    
    return profit, profitPercent
end

-- Parse money string to copper (e.g., "10s" -> 1000, "1g50s25c" -> 15025)
function AHVH:ParseMoneyString(moneyStr)
    if not moneyStr or moneyStr == "" then return 0 end
    
    local copper = 0
    local _, _, goldMatch = string.find(moneyStr, "(%d+)g")
    local _, _, silverMatch = string.find(moneyStr, "(%d+)s")
    local _, _, copperMatch = string.find(moneyStr, "(%d+)c")
    
    if goldMatch then
        copper = copper + (tonumber(goldMatch) * 10000)
    end
    if silverMatch then
        copper = copper + (tonumber(silverMatch) * 100)
    end
    if copperMatch then
        copper = copper + tonumber(copperMatch)
    end
    
    return copper
end

-- Format money string
function AHVH:FormatMoney(amount)
    if not amount or amount <= 0 then return "0c" end
    
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    
    local result = ""
    if gold > 0 then
        result = result .. gold .. "g"
    end
    if silver > 0 then
        result = result .. silver .. "s"
    end
    if copper > 0 or result == "" then
        result = result .. copper .. "c"
    end
    
    return result
end

-- Highlight auction row (Classic version)
function AHVH:HighlightAuctionRow(button, profit, profitPercent)
    if not button then return end
    
    -- Create highlight texture if it doesn't exist
    if not button.ahvhHighlight then
        button.ahvhHighlight = button:CreateTexture(nil, "BACKGROUND")
        button.ahvhHighlight:SetAllPoints(button)
        button.ahvhHighlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        button.ahvhHighlight:SetBlendMode("ADD")
    end
    
    -- Set highlight color
    local color = AHVHSettings.highlightColor
    button.ahvhHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
    button.ahvhHighlight:Show()
    
    -- Store profit info for tooltip
    button.ahvhProfit = profit
    button.ahvhProfitPercent = profitPercent
end

-- Remove highlight from auction row
function AHVH:RemoveHighlight(button)
    if button and button.ahvhHighlight then
        button.ahvhHighlight:Hide()
    end
end

-- Process auction house browse results (Classic version)
function AHVH:ProcessBrowseResults()
    if not AHVHSettings.enabled then return end
    if not AuctionFrame or not AuctionFrame:IsVisible() then return end
    
    local numBatchAuctions = GetNumAuctionItems("list")
    if numBatchAuctions == 0 then return end
    
    local profitableCount = 0
    local numButtons = NUM_BROWSE_TO_DISPLAY or 14 -- Fallback for Classic
    
    -- Clear old highlights
    for i = 1, numButtons do
        local button = getglobal("BrowseButton" .. i)
        if button then
            AHVH:RemoveHighlight(button)
        end
    end
    
    -- Check each visible auction
    for i = 1, numButtons do
        local index = i + FauxScrollFrame_GetOffset(BrowseScrollFrame)
        if index <= numBatchAuctions then
            local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner = GetAuctionItemInfo("list", index)
            local itemLink = GetAuctionItemLink("list", index)
            
            if itemLink and buyoutPrice and buyoutPrice > 0 then
                local vendorPrice = AHVH:GetVendorSellPrice(itemLink)
                
                if vendorPrice > 0 then
                    local profit, profitPercent = AHVH:CalculateProfit(buyoutPrice, vendorPrice, count)
                    
                    -- Check both percentage and absolute profit requirements
                    if profit > 0 and 
                       profitPercent >= AHVHSettings.minProfitPercent and 
                       profit >= AHVHSettings.minProfitCopper then
                        
                        local button = getglobal("BrowseButton" .. i)
                        if button then
                            AHVH:HighlightAuctionRow(button, profit, profitPercent)
                            profitableCount = profitableCount + 1
                        end
                    end
                end
            end
        end
    end
    
    -- Play sound if profitable items found
    if profitableCount > 0 and AHVHSettings.enableSound then
        PlaySound("AuctionWindowOpen")
    end
    
    -- Print summary
    if profitableCount > 0 then
        AHVH:Print(string.format("Found %d profitable items!", profitableCount))
    end
end

-- Hook into auction house events (Classic version)
function AHVH:HookAuctionHouse()
    -- Hook the browse update function (if available)
    if AuctionFrameBrowse_Update then
        local originalBrowseUpdate = AuctionFrameBrowse_Update
        AuctionFrameBrowse_Update = function()
            originalBrowseUpdate()
            AHVH:ProcessBrowseResults()
        end
    end
    
    -- Hook tooltip display for profitable items
    if AHVHSettings.enableTooltip then
        local function AddProfitTooltip(button)
            if button and button.ahvhProfit and button.ahvhProfitPercent then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFF00FF00AHVH: Profitable Item|r")
                GameTooltip:AddLine("Potential Profit: |cFFFFFFFF" .. AHVH:FormatMoney(button.ahvhProfit) .. "|r")
                GameTooltip:AddLine("Profit Percentage: |cFFFFFFFF" .. string.format("%.1f%%", button.ahvhProfitPercent) .. "|r")
                GameTooltip:Show()
            end
        end
        
        -- Hook browse button tooltips (try again if auction UI is loaded)
        local function HookTooltips()
            local numButtons = NUM_BROWSE_TO_DISPLAY or 14 -- Default fallback
            for i = 1, numButtons do
                local button = getglobal("BrowseButton" .. i)
                if button then
                    local originalScript = button:GetScript("OnEnter")
                    button:SetScript("OnEnter", function()
                        if originalScript then
                            originalScript()
                        end
                        AddProfitTooltip(this)
                    end)
                end
            end
        end
        
        -- Try to hook immediately and also later when auction UI is available
        HookTooltips()
    end
end

-- Slash commands
SLASH_AHVH1 = "/ahvh"
SLASH_AHVH2 = "/auctionhighlight"
SlashCmdList["AHVH"] = function(msg)
    local cmd = string.lower(msg)
    
    if cmd == "toggle" then
        AHVHSettings.enabled = not AHVHSettings.enabled
        AHVH:Print(string.format("%s", AHVHSettings.enabled and "Enabled" or "Disabled"))
    elseif cmd == "sound" then
        AHVHSettings.enableSound = not AHVHSettings.enableSound
        AHVH:Print(string.format("Sound %s", AHVHSettings.enableSound and "enabled" or "disabled"))
    elseif cmd == "tooltip" then
        AHVHSettings.enableTooltip = not AHVHSettings.enableTooltip
        AHVH:Print(string.format("Tooltip %s", AHVHSettings.enableTooltip and "enabled" or "disabled"))
    elseif string.find(cmd, "^profit ") then
        local _, _, percentStr = string.find(cmd, "^profit (%d+)")
        local percent = tonumber(percentStr)
        if percent and percent >= 0 and percent <= 1000 then
            AHVHSettings.minProfitPercent = percent
            AHVH:Print(string.format("Minimum profit set to %d%%", percent))
        else
            AHVH:Print("Invalid profit percentage. Use 0-1000.")
        end
    elseif string.find(cmd, "^minprofit ") then
        local _, _, moneyStr = string.find(cmd, "^minprofit (.+)")
        local copper = AHVH:ParseMoneyString(moneyStr)
        if copper > 0 then
            AHVHSettings.minProfitCopper = copper
            AHVH:Print(string.format("Minimum profit set to %s", AHVH:FormatMoney(copper)))
        else
            AHVH:Print("Invalid money format. Use format like '10s', '1g50s', or '1g50s25c'")
        end
    elseif cmd == "help" or cmd == "" then
        AHVH:Print("Commands:")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh toggle - Enable/disable highlighting")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh sound - Toggle sound notifications")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh tooltip - Toggle tooltip information")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh profit <number> - Set minimum profit percentage (default: 10)")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh minprofit <money> - Set minimum profit amount (e.g., '10s', '1g50s')")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh status - Show current settings")
        DEFAULT_CHAT_FRAME:AddMessage("  /ahvh help - Show this help")
    elseif cmd == "status" then
        AHVH:Print("Status:")
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  Enabled: %s", AHVHSettings.enabled and "|cFF00FF00Yes|r" or "|cFFFF0000No|r"))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  Min Profit %%: |cFFFFFFFF%d%%|r", AHVHSettings.minProfitPercent))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  Min Profit Amount: |cFFFFFFFF%s|r", AHVH:FormatMoney(AHVHSettings.minProfitCopper)))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  Sound: %s", AHVHSettings.enableSound and "|cFF00FF00On|r" or "|cFFFF0000Off|r"))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("  Tooltip: %s", AHVHSettings.enableTooltip and "|cFF00FF00On|r" or "|cFFFF0000Off|r"))
    else
        AHVH:Print("Unknown command. Use '/ahvh help' for help.")
    end
end

-- Event handling for Classic
function AHVH:OnEvent()
    if event == 'ADDON_LOADED' then
        if arg1 == 'AuctionHouseValueHighlighter' then
            AHVH:InitializeSettings()
            AHVH:HookAuctionHouse()
            AHVH:Print("Classic loaded! Use '/ahvh help' for commands.")
        end
    elseif event == 'VARIABLES_LOADED' then
        AHVH:InitializeSettings()
    end
end

AHVH:RegisterEvent('ADDON_LOADED')
AHVH:RegisterEvent('VARIABLES_LOADED')
AHVH:SetScript('OnEvent', AHVH.OnEvent)
