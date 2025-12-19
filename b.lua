-- =========================================================
-- Random Word Typer (FULL REFACTOR)
-- Fast Prefix Index + Human Typing
-- =========================================================

-- === CONFIG ===
local WORD_URL = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/words_alpha%20(1).txt"
local MIN_LEN = 1
local MAX_LEN = 100
local MAX_PREFIX_INDEX = 6 -- jangan terlalu besar (RAM)

-- === SERVICES ===
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

-- === STATE ===
local WordsLoaded = false
local PrefixMap = {}
local UsedWords = {}
local CachedCurrentWordLabel

math.randomseed(os.clock())

-- =========================================================
-- HTTP PICKER
-- =========================================================
local function getRequest()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if request then return request end
end

-- =========================================================
-- GUI WORD FETCH (CACHED)
-- =========================================================
local function getCurrentWord()
    if CachedCurrentWordLabel and CachedCurrentWordLabel.Parent then
        return CachedCurrentWordLabel.Text:match("^%s*(.-)%s*$")
    end

    local ok, label = pcall(function()
        return lp.PlayerGui:WaitForChild("InGame", 5)
            :WaitForChild("Frame", 5)
            :WaitForChild("CurrentWord", 5)
    end)

    if ok and label and label:IsA("TextLabel") then
        CachedCurrentWordLabel = label
        return label.Text:match("^%s*(.-)%s*$")
    end
end

-- =========================================================
-- VALIDATION
-- =========================================================
local function isValidWord(word)
    if not word:match("^[a-z]+$") then return false end

    local first3 = word:sub(1, 3)
    if #first3 == 3 and first3:match("^(.)%1%1$") then
        return false
    end

    return true
end

-- =========================================================
-- LOAD & INDEX WORDS
-- =========================================================
local function LoadWords()
    local req = getRequest()
    if not req then
        warn("No HTTP request available")
        return
    end

    local ok, body = pcall(function()
        local res = req({ Url = WORD_URL, Method = "GET" })
        return res.Body or res
    end)

    if not ok or not body then
        warn("Failed to fetch word list")
        return
    end

    local count = 0

    for line in body:gmatch("[^\r\n]+") do
        local word = line:lower():match("^%s*(.-)%s*$")
        if #word >= MIN_LEN and #word <= MAX_LEN and isValidWord(word) then
            count += 1
            for i = 1, math.min(MAX_PREFIX_INDEX, #word) do
                local p = word:sub(1, i)
                PrefixMap[p] = PrefixMap[p] or {}
                table.insert(PrefixMap[p], word)
            end
        end
    end

    WordsLoaded = true
    print("✅ Loaded & indexed", count, "words")
end

task.spawn(LoadWords)

-- =========================================================
-- WORD PICKER (O(1))
-- =========================================================
local function getRandomWord(prefix)
    if not WordsLoaded then return end

    prefix = prefix:lower()
    UsedWords[prefix] = UsedWords[prefix] or {}

    local pool = PrefixMap[prefix]
    if not pool then return end

    for _ = 1, 20 do
        local pick = pool[math.random(#pool)]
        if not UsedWords[prefix][pick] then
            UsedWords[prefix][pick] = true
            return pick, prefix
        end
    end
end

-- =========================================================
-- AUTO TYPE (HUMAN STYLE)
-- =========================================================
local KeyMap = {
    a=Enum.KeyCode.A,b=Enum.KeyCode.B,c=Enum.KeyCode.C,d=Enum.KeyCode.D,
    e=Enum.KeyCode.E,f=Enum.KeyCode.F,g=Enum.KeyCode.G,h=Enum.KeyCode.H,
    i=Enum.KeyCode.I,j=Enum.KeyCode.J,k=Enum.KeyCode.K,l=Enum.KeyCode.L,
    m=Enum.KeyCode.M,n=Enum.KeyCode.N,o=Enum.KeyCode.O,p=Enum.KeyCode.P,
    q=Enum.KeyCode.Q,r=Enum.KeyCode.R,s=Enum.KeyCode.S,t=Enum.KeyCode.T,
    u=Enum.KeyCode.U,v=Enum.KeyCode.V,w=Enum.KeyCode.W,x=Enum.KeyCode.X,
    y=Enum.KeyCode.Y,z=Enum.KeyCode.Z,[" "]=Enum.KeyCode.Space
}

local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(math.random(30, 70) / 1000)
    VIM:SendKeyEvent(false, key, false, game)
end

local function AutoType(start, full)
    local remain = full:sub(#start + 1)
    local typoChance = (#full > 8) and 0.03 or 0.06
    local typed = 0

    for i = 1, #remain do
        local c = remain:sub(i, i)
        if c ~= " " and math.random() < typoChance then
            press(Enum.KeyCode.J)
            press(Enum.KeyCode.Backspace)
        end
        local k = KeyMap[c]
        if k then
            press(k)
            typed += 1
        end
    end

    press(Enum.KeyCode.Return)

    for _ = 1, typed do
        press(Enum.KeyCode.Backspace)
    end
end

-- =========================================================
-- GUI
-- =========================================================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "RandomWordTyper"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,200)
frame.Position = UDim2.new(0.5,-150,0.5,-100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local function btn(text,y,color)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,35)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = color
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Random Word Typer"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1,1,1)

local randomBtn = btn("🔀 Random Type",40,Color3.fromRGB(40,180,100))
local resetBtn  = btn("🔄 Reset Prefix",80,Color3.fromRGB(200,80,80))
local resetAll  = btn("🗑 Reset All",120,Color3.fromRGB(180,60,60))

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,160)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextColor3 = Color3.fromRGB(200,255,200)

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0,50,0,50)
toggle.Position = UDim2.new(0,10,0,10)
toggle.Text = "🔀"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 20
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,120,200)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,10)

toggle.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    toggle.Text = frame.Visible and "❌" or "🔀"
end)

-- =========================================================
-- EVENTS
-- =========================================================
randomBtn.MouseButton1Click:Connect(function()
    if not WordsLoaded then
        status.Text = "Loading words..."
        return
    end

    local prefix = getCurrentWord()
    if not prefix or prefix == "" then
        status.Text = "No CurrentWord"
        return
    end

    local word = getRandomWord(prefix)
    if not word then
        status.Text = "No unused word"
        return
    end

    status.Text = "Typing: "..word
    AutoType(prefix, word)
    status.Text = "Done: "..word
end)

resetBtn.MouseButton1Click:Connect(function()
    local p = getCurrentWord()
    if p then
        UsedWords[p] = {}
        status.Text = "Reset: "..p
    end
end)

resetAll.MouseButton1Click:Connect(function()
    UsedWords = {}
    status.Text = "All reset"
end)

print("✅ Random Word Typer FULL REFACTOR loaded")
