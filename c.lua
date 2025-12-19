-- ✅ Random Word Typer - Full Auto + Rayfield UI + Complete Logs
-- ✅ Tidak perlu ketik prefix. Tinggal klik tombol.

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Services
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UserInput = game:GetService("UserInputService")
local Vim = game:GetService("VirtualInputManager")

-- Word list
local Words = {}
local usedWords = {}
local loaded = false
local minLen, maxLen = 3, 12

math.randomseed(tick())

-- Logger
local function log(msg)
    print("[RWT] " .. msg)
end
local function errLog(msg)
    warn("[RWT] ERROR: " .. msg)
    Rayfield:Notify({ Title = "Error", Content = msg, Duration = 3 })
end

-- HTTP loader
local function getReq()
    return (syn and syn.request) or (http and http.request) or http_request or request or nil
end

local function LoadWords()
    if loaded then return end
    local req = getReq()
    if not req then errLog("No HTTP function"); return end

    log("Loading words...")
    local ok, res = pcall(function()
        return req({
            Url = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/words_alpha%20(1).txt",
            Method = "GET"
        }).Body
    end)

    if not ok or not res then errLog("Load failed: " .. tostring(res)); return end

    local c = 0
    for line in res:gmatch("[^\r\n]+") do
        local w = line:match("^%s*(.-)%s*$"):lower()
        if #w >= minLen and #w <= maxLen and w:match("^[a-z]+$") then
            table.insert(Words, w); c = c + 1
        end
    end
    loaded = c > 0
    log("Loaded " .. c .. " words")
    Rayfield:Notify({ Title = "Ready", Content = c .. " words loaded", Duration = 2 })
end
spawn(LoadWords)

-- Auto typer
local function AutoType(word)
    log('TYPING: "' .. word .. '"')
    for i = 1, #word do
        local key = Enum.KeyCode[word:sub(i, i):upper()]
        if key then
            Vim:SendKeyEvent(true, key, false, game)
            task.wait(math.random(40, 80) / 1000)
            Vim:SendKeyEvent(false, key, false, game)
            task.wait(math.random(40, 80) / 1000)
        end
    end
    Vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    Vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    log('DONE: "' .. word .. '"')
end

-- CurrentWord
local function GetCurrentWordLabel()
    local ok, gui = pcall(function()
        return lp.PlayerGui:WaitForChild("InGame", 5)
                           :WaitForChild("Frame", 5)
                           :WaitForChild("CurrentWord", 5)
    end)
    if ok and gui then
        log('CurrentWord = "' .. gui.Text .. '" at ' .. gui:GetFullName())
        return gui
    else
        errLog("CurrentWord label not found")
        warn("=== PlayerGui dump ===")
        for _, v in ipairs(lp.PlayerGui:GetChildren()) do
            warn("  - " .. v.Name .. " (" .. v.ClassName .. ")")
        end
        return nil
    end
end

-- Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Random Word Typer",
    LoadingTitle = "Loading script...",
    LoadingSubtitle = "by kimi",
    ConfigurationSaving = { Enabled = false },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false,
})

local Main = Window:CreateTab("Main", 4483362458)

local status = Main:CreateLabel("Status: Loading words...")

spawn(function()
    while not loaded do task.wait() end
    status:Set("Status: Ready (" .. #Words .. " words)")
end)

Main:CreateButton({
    Name = "🔀 Auto Random Type",
    Callback = function()
        if not loaded then errLog("Words not loaded yet"); return end
        local word = nil
        for _ = 1, 100 do
            local pick = Words[math.random(1, #Words)]
            if not usedWords[pick] then word = pick; usedWords[pick] = true; break end
        end
        if not word then errLog("All words used"); return end
        Rayfield:Notify({ Title = "Typing", Content = word, Duration = 1 })
        AutoType(word)
    end
})

Main:CreateButton({
    Name = "✨ Auto CurrentWord",
    Callback = function()
        local label = GetCurrentWordLabel()
        if label then
            local w = label.Text:lower()
            if #w > 0 and w ~= "..." then
                Rayfield:Notify({ Title = "Typing CurrentWord", Content = w, Duration = 1 })
                AutoType(w)
            else
                errLog("CurrentWord is empty or '...'")
            end
        end
    end
})

-- F8 hotkey
UserInput.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == Enum.KeyCode.F8 then
        local label = GetCurrentWordLabel()
        if label then AutoType(label.Text:lower()) end
    end
end)

-- Logger loop
spawn(function()
    while true do
        task.wait(2)
        GetCurrentWordLabel()
    end
end)

log("Script loaded. UI ready. Press F8 or use buttons.")
Rayfield:Notify({ Title = "Script Loaded", Content = "Press F8 or use buttons", Duration = 2 })
