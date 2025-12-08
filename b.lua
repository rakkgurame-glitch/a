-- Random Word Typer - JSON + Clear Button
-- Updated: Removed backspace from AutoType, added dedicated Clear button

local Words = {}
local usedWords = {}
local loaded = false
local minCharacters = 1
local maxCharacters = 25

math.randomseed(tick())

-- HTTP request picker
local function getRequestFunction()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    return nil
end

-- Auto-type only the new part (no backspace at end)
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

    local remaining = fullWord:sub(#alreadyTyped + 1)
    local vim = game:GetService("VirtualInputManager")
    for i = 1, #remaining do
        local char = remaining:sub(i, i):lower()
        if keyMap[char] then
            local delay = math.random(20, 120) / 1000
            vim:SendKeyEvent(true, keyMap[char], false, game)
            task.wait(delay)
            vim:SendKeyEvent(false, keyMap[char], false, game)
            task.wait(delay)
        end
    end

    -- Press Enter
    task.wait(0.01)
    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.03)
    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end

-- 🔥 NEW: Dedicated clear function (15 backspaces)
local function ClearText()
    local vim = game:GetService("VirtualInputManager")
    for _ = 1, 15 do
        vim:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(0.03)
        vim:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
        task.wait(0.04)
    end
end

local function isValidWord(word)
    return word:match("^[a-zA-Z]+$") ~= nil
end

-- Load words from JSON
local function LoadWords()
    if loaded then return end

    local httpService = game:GetService("HttpService")
    local reqFunc = getRequestFunction()
    if not reqFunc then
        warn("[RandomWordTyper] No HTTP function available.")
        return
    end

    local ok, result = pcall(function()
        local res = reqFunc({
            Url = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/words_dictionary.json",
            Method = "GET"
        })
        return (type(res) == "table" and res.Body) or res
    end)

    if not ok or not result then
        warn("[RandomWordTyper] HTTP fetch failed:", result)
        return
    end

    local decoded
    ok, decoded = pcall(function()
        return httpService:JSONDecode(result)
    end)

    if not ok then
        warn("[RandomWordTyper] JSON decode failed:", decoded)
        return
    end

    if type(decoded) ~= "table" then
        warn("[RandomWordTyper] JSON root is not a table")
        return
    end

    for word in pairs(decoded) do
        if type(word) == "string" and
           #word >= minCharacters and
           #word <= maxCharacters and
           isValidWord(word) then
            table.insert(Words, word:lower())
        end
    end

    loaded = #Words > 0
    print("[RandomWordTyper] Loaded", #Words, "words from JSON.")
end

spawn(LoadWords)

-- === GUI ===
local screen = Instance.new("ScreenGui")
screen.Name = "RandomWordTyperGUI"
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() screen.Parent = game.CoreGui end)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 250)
frame.Position = UDim2.new(0.5, -150, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = screen
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Thickness = 2
Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 60, 70)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Random Word Typer (JSON)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Type prefix (e.g. 'pho')..."
searchBox.Size = UDim2.new(1, -20, 0, 35)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 16
searchBox.Parent = frame
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        if _G.RandomButtonRef then
            _G.RandomButtonRef.MouseButton1Click:Fire()
        end
    end
end)

local randomButton = Instance.new("TextButton")
randomButton.Size = UDim2.new(1, -20, 0, 40)
randomButton.Position = UDim2.new(0, 10, 0, 85)
randomButton.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
randomButton.Text = "🔀 Random Type"
randomButton.TextColor3 = Color3.fromRGB(255, 255, 255)
randomButton.Font = Enum.Font.GothamBold
randomButton.TextSize = 16
randomButton.Parent = frame
Instance.new("UICorner", randomButton).CornerRadius = UDim.new(0, 8)
_G.RandomButtonRef = randomButton

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(1, -20, 0, 30)
resetButton.Position = UDim2.new(0, 10, 0, 135)
resetButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
resetButton.Text = "🔄 Reset Used (Current Prefix)"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Font = Enum.Font.Gotham
resetButton.TextSize = 13
resetButton.Parent = frame
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 8)

local resetAllButton = Instance.new("TextButton")
resetAllButton.Size = UDim2.new(1, -20, 0, 30)
resetAllButton.Position = UDim2.new(0, 10, 0, 170)
resetAllButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
resetAllButton.Text = "🗑️ Reset All Prefixes"
resetAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetAllButton.Font = Enum.Font.Gotham
resetAllButton.TextSize = 12
resetAllButton.Parent = frame
Instance.new("UICorner", resetAllButton).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 210)
status.BackgroundTransparency = 1
status.Text = "Status: Loading words..."
status.TextColor3 = Color3.fromRGB(200, 255, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Center
status.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 0, 20)
infoLabel.Position = UDim2.new(0, 10, 0, 195)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Auto-types only remaining letters"
infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Center
infoLabel.Parent = frame

-- === Logic ===
local function GetRandomWord(input)
    if not loaded then return nil end
    input = input:lower()

    if not usedWords[input] then
        usedWords[input] = {}
    end

    local pool = {}
    for _, word in ipairs(Words) do
        if word:sub(1, #input) == input and not usedWords[input][word] then
            table.insert(pool, word)
        end
    end

    if #pool == 0 then
        for i = #input - 1, 1, -1 do
            local shorter = input:sub(1, i)
            if not usedWords[shorter] then
                usedWords[shorter] = {}
            end

            pool = {}
            for _, word in ipairs(Words) do
                if word:sub(1, i) == shorter and not usedWords[shorter][word] then
                    table.insert(pool, word)
                end
            end

            if #pool > 0 then
                input = shorter
                break
            end
        end
    end

    if #pool == 0 then return nil end
    local pick = pool[math.random(1, #pool)]
    usedWords[input][pick] = true
    return pick, input
end

randomButton.MouseButton1Click:Connect(function()
    if not loaded then
        status.Text = "Still loading words..."
        return
    end

    local input = searchBox.Text:match("^%s*(.-)%s*$")
    if #input < 1 then
        status.Text = "Enter a prefix first!"
        return
    end

    local word, actualPrefix = GetRandomWord(input)
    if not word then
        status.Text = "No unused words found!"
        return
    end

    status.Text = "Typing: " .. word
    AutoTypeText(input, word)
    status.Text = "Typed: " .. word .. " (Prefix: " .. actualPrefix .. ")"
end)

resetButton.MouseButton1Click:Connect(function()
    local input = searchBox.Text:match("^%s*(.-)%s*$")
    if #input > 0 then
        if usedWords[input] then
            usedWords[input] = {}
            status.Text = "Reset used words for: " .. input
        else
            status.Text = "No used words for: " .. input
        end
    else
        status.Text = "Enter a prefix to reset!"
    end
end)

resetAllButton.MouseButton1Click:Connect(function()
    usedWords = {}
    status.Text = "✅ All prefixes reset!"
end)

-- 🔘 Toggle GUI button (left top)
local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 50, 0, 50)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
toggle.Text = "🔀"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20
toggle.Parent = screen
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

-- 🔘 NEW: Clear button (right top)
local clearButton = Instance.new("TextButton")
clearButton.Name = "ClearButton"
clearButton.Size = UDim2.new(0, 50, 0, 50)
clearButton.Position = UDim2.new(1, -60, 0, 10) -- 10px from right edge
clearButton.BackgroundColor3 = Color3.fromRGB(220, 100, 100)
clearButton.Text = "⌫"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.Font = Enum.Font.GothamBold
clearButton.TextSize = 24
clearButton.Parent = screen
Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0, 10)

clearButton.MouseButton1Click:Connect(function()
    status.Text = "🧹 Clearing text..."
    ClearText()
    task.wait(0.2)
    status.Text = "Text cleared (15 backspaces)"
end)

-- Toggle visibility
local guiEnabled = false
frame.Visible = false

toggle.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    frame.Visible = guiEnabled
    toggle.Text = guiEnabled and "❌" or "🔀"
end)

print("✅ Random Word Typer (JSON + Clear) loaded!")
print("💡 Use '⌫' button in top-right to send 15 backspaces.")
