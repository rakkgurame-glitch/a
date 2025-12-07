-- Random Word Typer - Script Baru
-- Fitur: Search -> Random Type -> Tidak pakai kata lagi -> Reset

local url = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/word.txt"

local Words = {}
local usedWords = {} -- Tabel untuk menyimpan kata yang sudah dipakai berdasarkan prefix
local loaded = false
local minCharacters = 1
local maxCharacters = 25

-- HTTP request picker
local function getRequestFunction()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if http_request then return http_request end
    if request then return request end
    return nil
end

-- Auto type yang diperbaiki - hanya ketik bagian yang belum diketik
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
-- pastikan seed di-set sekali saja (bisa di paling atas script)
math.randomseed(tick())

local remaining = fullWord:sub(#alreadyTyped + 1)
for i = 1, #remaining do
    local char = remaining:sub(i, i):lower()
    if keyMap[char] then
        -- delay acak 0.02–0.25 detik
        local delay = math.random(20, 150) / 1000

        game:GetService("VirtualInputManager"):SendKeyEvent(true,  keyMap[char], false, game)
        task.wait(delay)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, keyMap[char], false, game)
        task.wait(delay)
    end
end


    task.wait(0.01)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.03)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Return, false, game)

    for _ = 1, 10 do
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Backspace, false, game)
        task.wait(0.01)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Backspace, false, game)
        task.wait(0.01)
    end
end

local function isValidWord(word)
    return word:match("^[a-zA-Z]+$") ~= nil
end

local function LoadWords()
    if loaded then return end
    local reqFunc = getRequestFunction()
    if not reqFunc then
        warn("No HTTP request function available.")
        return
    end

    local ok, result = pcall(function()
        local res = reqFunc({Url = url, Method = "GET"})
        return (type(res) == "table" and res.Body) or res
    end)

    if not ok then
        warn("Failed to load words: " .. tostring(result))
        return
    end

    for w in string.gmatch(result or "", "[^\r\n]+") do
        if #w >= minCharacters and #w <= maxCharacters and isValidWord(w) then
            table.insert(Words, w:lower())
        end
    end

    loaded = #Words > 0
    print("[RandomWordTyper] Loaded " .. #Words .. " words.")
end

spawn(LoadWords)

-- GUI
local screen = Instance.new("ScreenGui", game.CoreGui)
screen.Name = "RandomWordTyperGUI"
screen.ResetOnSpawn = false

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.5, -150, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", frame).Thickness = 2
Instance.new("UIStroke", frame).Color = Color3.fromRGB(60, 60, 70)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Random Word Typer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local searchBox = Instance.new("TextBox", frame)
searchBox.PlaceholderText = "Type letters..."
searchBox.Size = UDim2.new(1, -20, 0, 35)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 16
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        randomButton.Activated:Fire() -- memicu klik tombol Random
    end
end)

local randomButton = Instance.new("TextButton", frame)
randomButton.Size = UDim2.new(1, -20, 0, 40)
randomButton.Position = UDim2.new(0, 10, 0, 85)
randomButton.BackgroundColor3 = Color3.fromRGB(40, 180, 100)
randomButton.Text = "🔀 Random Type"
randomButton.TextColor3 = Color3.fromRGB(255, 255, 255)
randomButton.Font = Enum.Font.GothamBold
randomButton.TextSize = 16
Instance.new("UICorner", randomButton).CornerRadius = UDim.new(0, 8)

local resetButton = Instance.new("TextButton", frame)
resetButton.Size = UDim2.new(1, -20, 0, 35)
resetButton.Position = UDim2.new(0, 10, 0, 135)
resetButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
resetButton.Text = "🔄 Reset Used"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Font = Enum.Font.Gotham
resetButton.TextSize = 14
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 180)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(200, 255, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 13

-- Logic
local function GetRandomWord(input)
    if not loaded then return nil end
    input = input:lower()
    
    -- Inisialisasi tabel usedWords untuk prefix ini jika belum ada
    if not usedWords[input] then
        usedWords[input] = {}
    end
    
    local pool = {}
    for _, word in ipairs(Words) do
        -- Cek apakah kata dimulai dengan input dan belum digunakan untuk prefix ini
        if word:sub(1, #input) == input and not usedWords[input][word] then
            table.insert(pool, word)
        end
    end
    
    if #pool == 0 then
        -- Coba cari kata dengan prefix yang lebih pendek jika tidak ada
        for i = #input - 1, 1, -1 do
            local shorterInput = input:sub(1, i)
            if not usedWords[shorterInput] then
                usedWords[shorterInput] = {}
            end
            
            pool = {}
            for _, word in ipairs(Words) do
                if word:sub(1, i) == shorterInput and not usedWords[shorterInput][word] then
                    table.insert(pool, word)
                end
            end
            
            if #pool > 0 then
                input = shorterInput
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
    local input = searchBox.Text
    if #input < 1 then
        status.Text = "Please type something first!"
        return
    end
    local word, actualPrefix = GetRandomWord(input)
    if not word then
        status.Text = "No unused words found!"
        return
    end
    
    status.Text = "Typing: " .. word
    -- Hanya ketik bagian yang belum diketik (setelah input)
    AutoTypeText(input, word)
    status.Text = "Typed: " .. word .. " (Prefix: " .. actualPrefix .. ")"
end)

resetButton.MouseButton1Click:Connect(function()
    -- Reset hanya untuk prefix yang sedang dicari
    local input = searchBox.Text
    if #input > 0 then
        if usedWords[input] then
            usedWords[input] = {}
            status.Text = "Reset used words for: " .. input
        else
            status.Text = "No used words for: " .. input
        end
    else
        -- Jika searchBox kosong, reset semua
        usedWords = {}
        status.Text = "All used words reset!"
    end
end)

-- Toggle GUI
local toggle = Instance.new("TextButton", screen)
toggle.Name = "Toggle"
toggle.Size = UDim2.new(0, 50, 0, 50)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
toggle.Text = "🔀"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

local guiEnabled = false
frame.Visible = false

toggle.MouseButton1Click:Connect(function()
    guiEnabled = not guiEnabled
    frame.Visible = guiEnabled
    toggle.Text = guiEnabled and "❌" or "🔀"
end)

-- Tombol untuk mereset semua kata yang sudah digunakan
local resetAllButton = Instance.new("TextButton", frame)
resetAllButton.Size = UDim2.new(1, -20, 0, 35)
resetAllButton.Position = UDim2.new(0, 10, 0, 175)
resetAllButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
resetAllButton.Text = "🗑️ Reset All Prefixes"
resetAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetAllButton.Font = Enum.Font.Gotham
resetAllButton.TextSize = 12
Instance.new("UICorner", resetAllButton).CornerRadius = UDim.new(0, 8)
resetAllButton.Visible = true

-- Perbarui posisi status
status.Position = UDim2.new(0, 10, 0, 215)

resetAllButton.MouseButton1Click:Connect(function()
    usedWords = {}
    status.Text = "All prefixes reset!"
end)

-- Informasi penggunaan
local infoLabel = Instance.new("TextLabel", frame)
infoLabel.Size = UDim2.new(1, -20, 0, 20)
infoLabel.Position = UDim2.new(0, 10, 0, 195)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Auto-types only remaining letters"
infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Center

print("Random Word Typer loaded! Gunakan search -> Random Type -> Reset jika perlu.")
print("Fitur: Tidak mengetik ulang huruf yang sudah diketik di search box.")
