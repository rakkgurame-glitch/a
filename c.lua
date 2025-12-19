-- ✅ Random Word Typer - Full Auto + RTaO_UI + Complete Logs
-- ✅ Semua error & status akan muncul di Output + Notification

-- Load UI lib
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RTaOexe1/rtao_dev/refs/heads/main/RTaO_UI_1.lua"))()

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

-- Logger functions
local function log(msg)
    print("[RWT] " .. msg)
end

local function warnLog(msg)
    warn("[RWT] WARNING: " .. msg)
end

local function errorLog(msg)
    warn("[RWT] ERROR: " .. msg)
    UI:Notification("Error", msg, 3)
end

-- HTTP loader
local function getRequest()
    return (syn and syn.request) or (http and http.request) or http_request or request or nil
end

local function LoadWords()
    if loaded then return end
    local req = getRequest()
    if not req then
        errorLog("No HTTP function available")
        return
    end

    log("Loading words from GitHub...")
    local ok, res = pcall(function()
        return req({
            Url = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/words_alpha%20(1).txt",
            Method = "GET"
        }).Body
    end)

    if not ok or not res or type(res) ~= "string" then
        errorLog("Failed to load words: " .. tostring(res))
        return
    end

    local count = 0
    for line in res:gmatch("[^\r\n]+") do
        local word = line:match("^%s*(.-)%s*$"):lower()
        if #word >= minLen and #word <= maxLen and word:match("^[a-z]+$") then
            table.insert(Words, word)
            count = count + 1
        end
    end

    loaded = count > 0
    log("Loaded " .. count .. " words")
    if loaded then
        UI:Notification("Ready", "Words loaded: " .. count, 2)
    else
        errorLog("No valid words found in file")
    end
end
spawn(LoadWords)

-- Auto typer
local function AutoType(word)
    log("TYPING: \"" .. word .. "\"")
    for i = 1, #word do
        local char = word:sub(i, i):lower()
        local key = Enum.KeyCode[char:upper()]
        if key then
            Vim:SendKeyEvent(true, key, false, game)
            task.wait(math.random(40, 80) / 1000)
            Vim:SendKeyEvent(false, key, false, game)
            task.wait(math.random(40, 80) / 1000)
        else
            warnLog("Unsupported character: " .. char)
        end
    end
    task.wait(0.05)
    Vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.05)
    Vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    log("DONE: \"" .. word .. "\"")
end

-- CurrentWord scanner
local function GetCurrentWordLabel()
    local ok, gui = pcall(function()
        return lp.PlayerGui:WaitForChild("InGame", 5)
                           :WaitForChild("Frame", 5)
                           :WaitForChild("CurrentWord", 5)
    end)
    if ok and gui then
        log("CurrentWord = '" .. gui.Text .. "' at " .. gui:GetFullName())
        return gui
    else
        errorLog("CurrentWord label not found")
        -- Dump PlayerGui children
        warn("=== PlayerGui contents ===")
        for _, v in ipairs(lp.PlayerGui:GetChildren()) do
            warn("  - " .. v.Name .. " (" .. v.ClassName .. ")")
        end
        return nil
    end
end

-- UI
local win = UI:CreateWindow("Random Word Typer", Vector2.new(300, 240), Enum.KeyCode.RightControl)
local main = win:CreateTab("Main")
local status = main:CreateLabel("Status: Loading words...")

spawn(function()
    while not loaded do task.wait() end
    status.Text = "Status: Ready (" .. #Words .. " words)"
end)

-- Auto Random
main:CreateButton("🔀 Auto Random Type", function()
    if not loaded then
        errorLog("Words not loaded yet")
        return
    end
    local word = nil
    local attempts = 0
    while not word and attempts < 100 do
        local pick = Words[math.random(1, #Words)]
        if not usedWords[pick] then
            word = pick
            usedWords[pick] = true
        end
        attempts = attempts + 1
    end
    if not word then
        errorLog("All words used (reset belum ada)")
        return
    end
    UI:Notification("Typing", word, 1)
    AutoType(word)
end)

-- Auto Current
main:CreateButton("✨ Auto CurrentWord", function()
    local label = GetCurrentWordLabel()
    if label then
        local word = label.Text:lower()
        if #word > 0 and word ~= "..." then
            UI:Notification("Typing CurrentWord", word, 1)
            AutoType(word)
        else
            errorLog("CurrentWord is empty or '...'")
        end
    end
end)

-- F8 hotkey
UserInput.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == Enum.KeyCode.F8 then
        local label = GetCurrentWordLabel()
        if label then
            AutoType(label.Text:lower())
        end
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
UI:Notification("Script Loaded", "Press F8 or use buttons", 2)
