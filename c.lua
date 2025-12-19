-- ✅ Random Word Typer - Super Simpel + Rayfield UI
-- ✅ Tidak perlu ketik prefix. Tinggal klik tombol atau F8.
-- ✅ Langsung baca CurrentWord → auto-type sampai selesai

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Services
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UserInput = game:GetService("UserInputService")
local Vim = game:GetService("VirtualInputManager")

-- Word list (backup only)
local Words = {}
local loaded = false
math.randomseed(tick())

-- Logger
local function log(msg)
    print("[RWT] " .. msg)
end
local function errLog(msg)
    warn("[RWT] ERROR: " .. msg)
    Rayfield:Notify({ Title = "Error", Content = msg, Duration = 3 })
end

-- HTTP loader (backup)
local function LoadWords()
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return end
    local ok, res = pcall(function()
        return req({Url = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/words_alpha%20(1).txt", Method = "GET"}).Body
    end)
    if ok and res then
        for line in res:gmatch("[^\r\n]+") do
            local w = line:match("^%s*(.-)%s*$"):lower()
            if #w >= 3 and #w <= 12 and w:match("^[a-z]+$") then
                table.insert(Words, w)
            end
        end
        loaded = #Words > 0
        log("Backup words loaded: " .. #Words)
    end
end
spawn(LoadWords)

-- AutoType (typo 5%, backspace, enter, clear)
local function AutoTypeText(alreadyTyped, fullWord)
    task.wait(0.12)
    local keyMap = {
        ["a"] = Enum.KeyCode.A, ["b"] = Enum.KeyCode.B, ["c"] = Enum.KeyCode.C,
        ["d"] = Enum.KeyCode.D, ["e"] = Enum.KeyCode.E, ["f"] = Enum.KeyCode.F,
        ["g"] = Enum.KeyCode.G, ["h"] = Enum.KeyCode.H, ["i"] = Enum.KeyCode.I,
        ["j"] = Enum.KeyCode.J, ["k"] = Enum.KeyCode.K, ["l"] = Enum.KeyCode.L,
        ["m"] = Enum.KeyCode.M, ["n"] = Enum.KeyCode.N, ["o"] = Enum.KeyCode.O,
        ["p"] = Enum.KeyCode.P, ["q"] = Enum.KeyCode.Q, ["r"] = Enum.KeyCode.R,
        ["s"] = Enum.KeyCode.S, ["t"] = Enum.KeyCode.T, ["u"] = Enum.KeyCode.U,
        ["v"] = Enum.KeyCode.V, ["w"] = Enum.KeyCode.W, ["x"] = Enum.KeyCode.X,
        ["y"] = Enum.KeyCode.Y, ["z"] = Enum.KeyCode.Z,
        [" "] = Enum.KeyCode.Space
    }

    local vim = game:GetService("VirtualInputManager")
    local remaining = fullWord:sub(#alreadyTyped + 1)
    local typedCount = 0
    local i = 1

    while i <= #remaining do
        local char = remaining:sub(i, i):lower()
        -- 5% typo
        if char ~= " " and math.random() < 0.05 then
            local typoKeys = {Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L,
                              Enum.KeyCode.U, Enum.KeyCode.I, Enum.KeyCode.O}
            local typo = typoKeys[math.random(1, #typoKeys)]
            vim:SendKeyEvent(true, typo, false, game)
            task.wait(math.random(50, 120) / 1000)
            vim:SendKeyEvent(false, typo, false, game)
            task.wait(math.random(50, 120) / 1000)
            vim:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
            task.wait(math.random(50, 120) / 1000)
            vim:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
            task.wait(math.random(40, 70) / 1000)
        end
        if keyMap[char] then
            vim:SendKeyEvent(true, keyMap[char], false, game)
            task.wait(math.random(35, 70) / 1000)
            vim:SendKeyEvent(false, keyMap[char], false, game)
            task.wait(math.random(35, 70) / 1000)
            typedCount = typedCount + 1
        end
        i = i + 1
    end

    -- Enter
    task.wait(0.01)
    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.03)
    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)

    -- Clear
    for _ = 1, typedCount + 5 do
        vim:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(math.random(30, 50) / 1000)
        vim:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
        task.wait(math.random(30, 50) / 1000)
    end
end

-- CurrentWord grabber
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
        errLog("CurrentWord not found")
        return nil
    end
end

-- Auto solve (tanpa prefix)
local function autoSolveCurrentWord()
    local label = GetCurrentWordLabel()
    if not label then return end
    local fullWord = label.Text:lower()
    while fullWord == "" or fullWord == "..." do
        task.wait()
        fullWord = label.Text:lower()
    end
    log("Auto-solving: " .. fullWord)
    Rayfield:Notify({ Title = "Typing", Content = fullWord, Duration = 1 })
    AutoTypeText(0, fullWord)
    log("Done: " .. fullWord)
    Rayfield:Notify({ Title = "Done", Content = fullWord, Duration = 1 })
end

-- Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Random Word Typer",
    LoadingTitle = "Loading script...",
    LoadingSubtitle = "by kimi",
    ConfigurationSaving = { Enabled = false },
    DisableRayfieldPrompts = true,
})

local Main = Window:CreateTab("Main", 4483362458)

Main:CreateButton({
    Name = "✨ Auto CurrentWord",
    Callback = autoSolveCurrentWord
})

-- F8 hotkey
UserInput.InputBegan:Connect(function(inp, g)
    if g then return end
    if inp.KeyCode == Enum.KeyCode.F8 then autoSolveCurrentWord() end
end)

log("Script loaded. UI ready. Press F8 or use button.")
Rayfield:Notify({ Title = "Ready", Content = "Press F8 or use button", Duration = 2 })
