-- FindSeverRare_Discord.lua
-- Phiên bản có webhook + gửi tin nhắn test khi script load

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Cấu hình webhook (của bạn)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1422372427886755861/yWe3oPd3AoAzW3EsllVkkncmz6fFTX4TDyRS0bGnJ_WnrkcAWavotHKfH0O-uwxgyA-R"

-- Hàm gửi webhook
local function sendDiscordWebhook(title, description)
    local jobId = game.JobId or HttpService:GenerateGUID(false)
    local placeId = game.PlaceId or 0
    local link = "https://www.roblox.com/games/"..placeId.."/?gameInstanceId="..jobId

    local payload = {
        username = "RareFinder",
        embeds = {{
            title = title,
            description = (description or "") .. "\n\n**JobId:** `"..jobId.."`\n[Join Server]("..link..")",
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

    if setclipboard then pcall(function() setclipboard(jobId) end) end
end

-- Hàm check tên object rare/rarebox
local PATTERNS = {"rare", "rarebox", "Rare", "RareBox"}
local function nameMatches(name)
    if not name then return false end
    name = tostring(name)
    for _, pat in ipairs(PATTERNS) do
        if string.find(name:lower(), pat:lower(), 1, true) then
            return true
        end
    end
    return false
end

-- Scanner workspace
spawn(function()
    while true do
        for _, obj in ipairs(workspace:GetDescendants()) do
            local ok, n = pcall(function() return obj.Name end)
            if ok and n and nameMatches(n) then
                local desc = "Detected object: "..(obj.GetFullName and obj:GetFullName() or tostring(obj)).." (Class: "..tostring(obj.ClassName)..")"
                sendDiscordWebhook("Rare Detected!", desc)
                wait(2)
            end
        end
        wait(1)
    end
end)

-- Hook nếu script gốc gọi _G.RareFound(name)
if type(_G) == "table" then
    local old = _G.RareFound
    _G.RareFound = function(...)
        local args = {...}
        pcall(function()
            sendDiscordWebhook("Rare Detected (_G.RareFound)", "Script gốc phát hiện: "..tostring(args[1] or "unknown"))
        end)
        if type(old) == "function" then return old(...) end
    end
end

print("[FindSeverRare_Discord.lua] Webhook integration loaded.")

-- 🔹 Gửi tin nhắn test ngay khi load
sendDiscordWebhook("✅ Script Loaded", "Webhook đã kết nối thành công! Người chơi: **"..localPlayer.Name.."**")
