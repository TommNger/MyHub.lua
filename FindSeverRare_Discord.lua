-- FindSeverRare_Discord.lua
-- Hook script gốc FindSeverRare.lua, gửi webhook khi phát hiện vật phẩm
-- Và quét inventory của player khác để gửi webhook nếu có trái hiếm

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Webhook Discord của bạn
local WEBHOOK_URL = "https://discord.com/api/webhooks/1422372427886755861/yWe3oPd3AoAzW3EsllVkkncmz6fFTX4TDyRS0bGnJ_WnrkcAWavotHKfH0O-uwxgyA-R"

--------------------------------------------------------------------
-- Hàm gửi webhook
--------------------------------------------------------------------
local function sendDiscordWebhook(title, description)
    local jobId = game.JobId or HttpService:GenerateGUID(false)
    local placeId = game.PlaceId or 0
    local link = "https://www.roblox.com/games/"..placeId.."/?gameInstanceId="..jobId

    local payload = {
        username = "RareFinder",
        embeds = {{
            title = title,
            description = (description or "")..
                "\n\n**JobId:** `"..jobId.."`\n[Join Server]("..link..")",
            footer = { text = "Auto alert" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    local body = HttpService:JSONEncode(payload)

    if syn and syn.request then
        syn.request({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body=body})
    elseif http_request then
        http_request({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body=body})
    elseif request then
        request({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"]="application/json"}, Body=body})
    else
        pcall(function()
            HttpService:PostAsync(WEBHOOK_URL, body, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

--------------------------------------------------------------------
-- Danh sách vật phẩm hiếm cần gửi webhook
--------------------------------------------------------------------
local validItems = {
    ["Rare Box"] = true,
    ["Ultra Rare Box"] = true,
    ["Rumble Fruit"] = true,
    ["Magma Fruit"] = true,
    ["Flare Fruit"] = true,
    ["Gas Fruit"] = true,
    ["Chilly Fruit"] = true,
    ["Phoenix Fruit"] = true,   -- thêm
    ["Dark Fruit"] = true,      -- thêm
    ["Quake Fruit"] = true,     -- thêm
}

--------------------------------------------------------------------
-- Hook vào hàm RareFound của script gốc
--------------------------------------------------------------------
if type(_G) == "table" then
    local old = _G.RareFound

    _G.RareFound = function(itemName, ...)
        if itemName and validItems[tostring(itemName)] then
            local emoji = "🎉" -- mặc định

            -- Gán emoji đặc biệt cho các trái mới
            if itemName == "Phoenix Fruit" then
                emoji = "🔥"
            elseif itemName == "Dark Fruit" then
                emoji = "🌑"
            elseif itemName == "Quake Fruit" then
                emoji = "🌋"
            end

            sendDiscordWebhook(
                emoji.." Vật phẩm hiếm phát hiện!",
                "Script gốc tìm thấy vật phẩm: **"..tostring(itemName).."**"
            )
        end

        -- Gọi lại hàm gốc nếu có
        if type(old) == "function" then
            return old(itemName, ...)
        end
    end
end

--------------------------------------------------------------------
-- Quét inventory của player khác
--------------------------------------------------------------------
spawn(function()
    while true do
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= localPlayer then
                local backpack = plr:FindFirstChild("Backpack")
                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if validItems[item.Name] then
                            local emoji = "🎒" -- mặc định
                            if item.Name == "Phoenix Fruit" then
                                emoji = "🔥"
                            elseif item.Name == "Dark Fruit" then
                                emoji = "🌑"
                            elseif item.Name == "Quake Fruit" then
                                emoji = "🌋"
                            end
                            sendDiscordWebhook(emoji.." Player Inventory", plr.Name.." có: "..item.Name)
                        end
                    end
                end
            end
        end
        wait(5) -- quét mỗi 5 giây để không spam
    end
end)

print("[FindSeverRare_Discord.lua] Hook và quét inventory thành công.")
