-- =========================================
-- RANDOM WORD TYPER (CLEAN FROM ZERO)
-- =========================================

-- === SERVICES ===
local Players = game:GetService("Players")
local VIM = game:GetService("VirtualInputManager")
local lp = Players.LocalPlayer

math.randomseed(os.clock())

-- === CONFIG ===
local WORD_URL = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/words_alpha%20(1).txt"
local MIN_LEN = 1
local MAX_LEN = 100

-- === STATE ===
local Words = {}
local Loaded = false
local Used = {}

-- =========================================
-- HTTP
-- =========================================
local function getRequest()
    if syn and syn.request then return syn.request end
    if http and http.request then return http.request end
    if request then return request end
end

-- =========================================
-- GET CURRENT WORD (DIRECT PATH)
-- =========================================
local function getCurrentWord()
    local ok, txt = pcall(function()
        return lp.PlayerGui.InGame.Frame.CurrentWord.Text
    end)

    if not ok or not txt then return nil end

    -- bersihkan SEMUA karakter aneh
    txt = txt:gsub("[%c%s]", ""):lower()

    if txt == "" then return nil end
    return txt
end

-- =========================================
-- LOAD WORDS
-- =========================================
local function loadWords()
    local req = getRequest()
    if not req then
        warn("No HTTP available")
        return
    end

    local ok, body = pcall(function()
        local res = req({ Url = WORD_URL, Method = "GET" })
        return res.Body or res
    end)

    if not ok or not body then
        warn("Failed to load words")
        return
    end

    for line in body:gmatch("[^\r\n]+") do
        local w = line:lower()
        if #w >= MIN_LEN and #w <= MAX_LEN and w:match("^[a-z]+$") then
            table.insert(Words, w)
        end
    end

    Loaded = true
    print("✅ Words loaded:", #Words)
end

task.spawn(loadWords)

-- =========================================
-- PICK WORD
-- =========================================
local function pickWord(prefix)
    Used[prefix] = Used[prefix] or {}

    local pool = {}

    for _, w in ipairs(Words) do
        if w:sub(1, #prefix) == prefix and not Used[prefix][w] then
            table.insert(pool, w)
        end
    end

    if #pool == 0 then return nil end

    local pick = pool[math.random(#pool)]
    Used[prefix][pick] = true
    return pick
end

-- =========================================
-- TYPE FUNCTION
-- =========================================
local KeyMap = {
    a=Enum.KeyCode.A,b=Enum.KeyCode.B,c=Enum.KeyCode.C,d=Enum.KeyCode.D,
    e=Enum.KeyCode.E,f=Enum.KeyCode.F,g=Enum.KeyCode.G,h=Enum.KeyCode.H,
    i=Enum.KeyCode.I,j=Enum.KeyCode.J,k=Enum.KeyCode.K,l=Enum.KeyCode.L,
    m=Enum.KeyCode.M,n=Enum.KeyCode.N,o=Enum.KeyCode.O,p=Enum.KeyCode.P,
    q=Enum.KeyCode.Q,r=Enum.KeyCode.R,s=Enum.KeyCode.S,t=Enum.KeyCode.T,
    u=Enum.KeyCode.U,v=Enum.KeyCode.V,w=Enum.KeyCode.W,x=Enum.KeyCode.X,
    y=Enum.KeyCode.Y,z=Enum.KeyCode.Z
}

local function press(key)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(math.random(30, 60) / 1000)
    VIM:SendKeyEvent(false, key, false, game)
end

local function typeWord(prefix, full)
    local rest = full:sub(#prefix + 1)

    for i = 1, #rest do
        local c = rest:sub(i, i)
        local k = KeyMap[c]
        if k then
            press(k)
        end
    end

    press(Enum.KeyCode.Return)
end

-- =========================================
-- HOTKEY (TEST MODE)
-- Tekan F6 untuk test
-- =========================================
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        if not Loaded then
            warn("Words not loaded yet")
            return
        end

        local prefix = getCurrentWord()
        print("DEBUG CurrentWord:", prefix)

        if not prefix then
            warn("NO CURRENT WORD")
            return
        end

        local word = pickWord(prefix)
        if not word then
            warn("NO MATCH WORD")
            return
        end

        print("Typing:", word)
        typeWord(prefix, word)
    end
end)

print("✅ CLEAN Random Word Typer loaded (Press F6)")
