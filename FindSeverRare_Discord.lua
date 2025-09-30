-- FindSeverRare_Discord.lua
-- Chỉ gửi webhook khi FindSeverRare.lua phát hiện Rare Box / Ultra Rare Box / Fruit hiếm

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Webhook của bạn
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
            description = (description or "") ..
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
-- Hook lại RareFound từ script gốc
--------------------------------------------------------------------
if type(_G) == "table" then
    local old = _G.RareFound

    _G.RareFound = function(itemName, ...)
        -- Danh sách vật phẩm cần thông báo
        local validItems = {
            ["Rare Box"] = true,
            ["Ultra Rare Box"] = true,
            ["Rumble Fruit"] = true,
            ["Magma Fruit"] = true,
            ["Flare Fruit"] = true,
            ["Gas Fruit"] = true,
            ["Chilly Fruit"] = true,
        }

        if itemName and validItems[tostring(itemName)] then
            sendDiscordWebhook("🎉 Rare Item Detected!", "Script gốc phát hiện: **"..tostring(itemName).."**")
        end

        -- Gọi lại hàm gốc (nếu có)
        if type(old) == "function" then
            return old(itemName, ...)
        end
    end
end
print("[FindSeverRare_Discord.lua] Đã hook vào RareFound (sẽ chỉ báo khi có vật phẩm hiếm).")
