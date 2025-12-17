-- Random Word Typer - Plain Text + Clear Button
-- Updated: Removed JSON, now reads plain text (.txt)

local Words = {}
local usedWords = {}
local loaded = false
local minCharacters = 1
local maxCharacters = 100

math.randomseed(tick())

-- HTTP request picker
local function getRequestFunction()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    return nil
end

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
    local typedCount = 0        -- hitung berapa karakter yang benar-benar terkirim
    local i = 1

    while i <= #remaining do
        local char = remaining:sub(i, i):lower()

        -- 15% typo chance
        if char ~= " " and math.random() < 0.15 then
            local typoKeys = {Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L,
                              Enum.KeyCode.U, Enum.KeyCode.I, Enum.KeyCode.O}
            local typo = typoKeys[math.random(1, #typoKeys)]

            vim:SendKeyEvent(true, typo, false, game)
            task.wait(math.random(80, 120) / 1000)
            vim:SendKeyEvent(false, typo, false, game)
            task.wait(math.random(80, 120) / 1000)

            vim:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
            task.wait(math.random(80, 120) / 1000)
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

    -- Langsung hapus semua yang baru diketik
    for _ = 1, typedCount + 5 do
        vim:SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(math.random(30, 50) / 1000)
        vim:SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
        task.wait(math.random(30, 50) / 1000)
    end
end

local function isValidWord(word)
    if word:match("^[a-zA-Z]+$") == nil then
        return false
    end

    -- Cegah huruf yang sama di awal lebih dari 2 kali
    local firstThree = word:sub(1, 2)
    if #firstThree == 3 and firstThree:match("^(.)\1\1$") then
        return false
    end

    return true
end

-- Load words from plain text (.txt)
local function LoadWords()
    if loaded then return end

    local reqFunc = getRequestFunction()
    if not reqFunc then
        warn("[RandomWordTyper] No HTTP function available.")
        return
    end

    local ok, result = pcall(function()
        local res = reqFunc({
            Url = "https://raw.githubusercontent.com/dwyl/english-words/refs/heads/master/words_alpha.txt", -- ganti ini dengan link file .txt kamu
            Method = "GET"
        })
        return (type(res) == "table" and res.Body) or res
    end)

    if not ok or not result then
        warn("[RandomWordTyper] HTTP fetch failed:", result)
        return
    end

    -- Parse plain text
    for line in result:gmatch("[^\r\n]+") do
        local word = line:match("^%s*(.-)%s*$") -- trim whitespace
        if #word >= minCharacters and #word <= maxCharacters and isValidWord(word) then
            table.insert(Words, word:lower())
        end
    end

    loaded = #Words > 0
    print("[RandomWordTyper] Loaded", #Words, "words from plain text.")
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
