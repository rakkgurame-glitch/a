-- Random Word Typer – Plain Text + 2-Source Fallback
-- Update: otomatis fallback ke sumber cadangan bila kata tidak ditemukan di utama
local Words      = {}
local usedWords  = {}
local loaded     = false
local minChars   = 1
local maxChars   = 100

math.randomseed(tick())

---------- UTILS ----------
local function getReqFunc()
    return (syn and syn.request) or (http and http.request) or http_request or request or nil
end

local function httpGet(url)
    local req = getReqFunc()
    if not req then return nil,"No HTTP func" end
    local ok,res = pcall(function()
        local r = req({Url=url,Method="GET"})
        return (type(r)=="table" and r.Body) or r
    end)
    if not ok or not res then return nil,res end
    return res
end

---------- VALIDASI ----------
local function isValidWord(w)
    if w:match("^[a-zA-Z]+$")==nil then return false end
    -- hindari 3 huruf sama di awal
    if #w>=3 and w:sub(1,3):match("^(.)\1\1$") then return false end
    return true
end

---------- LOAD MULTI-SOURCE ----------
local function LoadWords()
    if loaded then return end
    local loadedAny = false

    -- 1) Sumber utama
    local mainUrl = "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt"
    local body1   = httpGet(mainUrl)
    if body1 then
        for line in body1:gmatch("[^\r\n]+") do
            local w = line:match("^%s*(.-)%s*$"):lower()
            if #w>=minChars and #w<=maxChars and isValidWord(w) then
                table.insert(Words,w)
            end
        end
        if #Words>0 then loadedAny=true end
    end

    -- 2) Sumber cadangan (fallback) – Anda bisa ganti URL di bawah
    local backupUrl = "https://raw.githubusercontent.com/rakkgurame-glitch/a/refs/heads/main/wlist_match1.txt"
    local body2     = httpGet(backupUrl)
    if body2 then
        for line in body2:gmatch("[^\r\n]+") do
            local w = line:match("^%s*(.-)%s*$"):lower()
            if #w>=minChars and #w<=maxChars and isValidWord(w) then
                table.insert(Words,w)
            end
        end
        if #Words>0 then loadedAny=true end
    end

    loaded = loadedAny
    print("[RandomWordTyper] Total kata terkumpul:",#Words)
    if not loaded then warn("[RandomWordTyper] Gagal load dari kedua sumber!") end
end
spawn(LoadWords)

---------- AUTO-TYPE (tetap sama) ----------
local function AutoTypeText(alreadyTyped,fullWord)
    task.wait(.12)
    local keyMap, vim = {
        ["a"]=Enum.KeyCode.A,["b"]=Enum.KeyCode.B,["c"]=Enum.KeyCode.C,
        ["d"]=Enum.KeyCode.D,["e"]=Enum.KeyCode.E,["f"]=Enum.KeyCode.F,
        ["g"]=Enum.KeyCode.G,["h"]=Enum.KeyCode.H,["i"]=Enum.KeyCode.I,
        ["j"]=Enum.KeyCode.J,["k"]=Enum.KeyCode.K,["l"]=Enum.KeyCode.L,
        ["m"]=Enum.KeyCode.M,["n"]=Enum.KeyCode.N,["o"]=Enum.KeyCode.O,
        ["p"]=Enum.KeyCode.P,["q"]=Enum.KeyCode.Q,["r"]=Enum.KeyCode.R,
        ["s"]=Enum.KeyCode.S,["t"]=Enum.KeyCode.T,["u"]=Enum.KeyCode.U,
        ["v"]=Enum.KeyCode.V,["w"]=Enum.KeyCode.W,["x"]=Enum.KeyCode.X,
        ["y"]=Enum.KeyCode.Y,["z"]=Enum.KeyCode.Z,[" "]=Enum.KeyCode.Space
    }, game:GetService("VirtualInputManager")

    local remain = fullWord:sub(#alreadyTyped+1)
    local typed  = 0
    local i      = 1
    while i<=#remain do
        local ch = remain:sub(i,i):lower()
        -- 15% typo
        if ch~=" " and math.random()<.15 then
            local tKeys = {Enum.KeyCode.J,Enum.KeyCode.K,Enum.KeyCode.L,
                           Enum.KeyCode.U,Enum.KeyCode.I,Enum.KeyCode.O}
            local typo  = tKeys[math.random(1,#tKeys)]
            vim:SendKeyEvent(true ,typo,false,game) task.wait(math.random(80,120)/1000)
            vim:SendKeyEvent(false,typo,false,game) task.wait(math.random(80,120)/1000)
            vim:SendKeyEvent(true ,Enum.KeyCode.Backspace,false,game) task.wait(math.random(80,120)/1000)
            vim:SendKeyEvent(false,Enum.KeyCode.Backspace,false,game) task.wait(math.random(40,70)/1000)
        end
        if keyMap[ch] then
            vim:SendKeyEvent(true ,keyMap[ch],false,game) task.wait(math.random(35,70)/1000)
            vim:SendKeyEvent(false,keyMap[ch],false,game) task.wait(math.random(35,70)/1000)
            typed=typed+1
        end
        i=i+1
    end
    -- Enter
    task.wait(.01)
    vim:SendKeyEvent(true ,Enum.KeyCode.Return,false,game) task.wait(.03)
    vim:SendKeyEvent(false,Enum.KeyCode.Return,false,game)
    -- Clear line
    for _=1,typed+5 do
        vim:SendKeyEvent(true ,Enum.KeyCode.Backspace,false,game) task.wait(math.random(30,50)/1000)
        vim:SendKeyEvent(false,Enum.KeyCode.Backspace,false,game) task.wait(math.random(30,50)/1000)
    end
end

---------- WORD PICK + PREFIX LOGIC ----------
local function GetRandomWord(input)
    if not loaded then return nil end
    input=input:lower()
    if not usedWords[input] then usedWords[input]={} end
    -- cari di pool yang sesuai prefix & belum dipakai
    local pool={}
    for _,w in ipairs(Words) do
        if w:sub(1,#input)==input and not usedWords[input][w] then
            table.insert(pool,w)
        end
    end
    if #pool==0 then -- retry dengan prefix lebih pendek
        for i=#input-1,1,-1 do
            local shorter=input:sub(1,i)
            if not usedWords[shorter] then usedWords[shorter]={} end
            pool={}
            for _,w in ipairs(Words) do
                if w:sub(1,i)==shorter and not usedWords[shorter][w] then
                    table.insert(pool,w)
                end
            end
            if #pool>0 then input=shorter; break end
        end
    end
    if #pool==0 then return nil end
    local pick = pool[math.random(1,#pool)]
    usedWords[input][pick]=true
    return pick,input
end

---------- GUI (sama seperti sebelumnya, tidak berubah) ----------
local screen = Instance.new("ScreenGui")
screen.Name="RandomWordTyperGUI"
screen.ResetOnSpawn=false
screen.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() screen.Parent=game.CoreGui end)

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,300,0,250)
frame.Position=UDim2.new(0.5,-150,0.5,-125)
frame.BackgroundColor3=Color3.fromRGB(30,30,35)
frame.Active=true
frame.Draggable=true
frame.Parent=screen
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",frame).Thickness=2
Instance.new("UIStroke",frame).Color=Color3.fromRGB(60,60,70)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,30)
title.Position=UDim2.new(0,0,0,0)
title.BackgroundTransparency=1
title.Text="Random Word Typer"
title.TextColor3=Color3.new(1,1,1)
title.Font=Enum.Font.GothamBold
title.TextSize=16
title.Parent=frame

local searchBox=Instance.new("TextBox")
searchBox.PlaceholderText="Type prefix (e.g. 'pho')..."
searchBox.Size=UDim2.new(1,-20,0,35)
searchBox.Position=UDim2.new(0,10,0,40)
searchBox.BackgroundColor3=Color3.fromRGB(50,50,60)
searchBox.TextColor3=Color3.new(1,1,1)
searchBox.Font=Enum.Font.Gotham
searchBox.TextSize=16
searchBox.Parent=frame
Instance.new("UICorner",searchBox).CornerRadius=UDim.new(0,8)

local randomBtn=Instance.new("TextButton")
randomBtn.Size=UDim2.new(1,-20,0,40)
randomBtn.Position=UDim2.new(0,10,0,85)
randomBtn.BackgroundColor3=Color3.fromRGB(40,180,100)
randomBtn.Text="🔀 Random Type"
randomBtn.TextColor3=Color3.new(1,1,1)
randomBtn.Font=Enum.Font.GothamBold
randomBtn.TextSize=16
randomBtn.Parent=frame
Instance.new("UICorner",randomBtn).CornerRadius=UDim.new(0,8)

local resetBtn=Instance.new("TextButton")
resetBtn.Size=UDim2.new(1,-20,0,30)
resetBtn.Position=UDim2.new(0,10,0,135)
resetBtn.BackgroundColor3=Color3.fromRGB(200,80,80)
resetBtn.Text="🔄 Reset Used (Current Prefix)"
resetBtn.TextColor3=Color3.new(1,1,1)
resetBtn.Font=Enum.Font.Gotham
resetBtn.TextSize=13
resetBtn.Parent=frame
Instance.new("UICorner",resetBtn).CornerRadius=UDim.new(0,8)

local resetAllBtn=Instance.new("TextButton")
resetAllBtn.Size=UDim2.new(1,-20,0,30)
resetAllBtn.Position=UDim2.new(0,10,0,170)
resetAllBtn.BackgroundColor3=Color3.fromRGB(180,60,60)
resetAllBtn.Text="🗑️ Reset All Prefixes"
resetAllBtn.TextColor3=Color3.new(1,1,1)
resetAllBtn.Font=Enum.Font.Gotham
resetAllBtn.TextSize=12
resetAllBtn.Parent=frame
Instance.new("UICorner",resetAllBtn).CornerRadius=UDim.new(0,8)

local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,-20,0,30)
status.Position=UDim2.new(0,10,0,210)
status.BackgroundTransparency=1
status.Text="Status: Loading words..."
status.TextColor3=Color3.fromRGB(200,255,200)
status.Font=Enum.Font.Gotham
status.TextSize=13
status.TextXAlignment=Enum.TextXAlignment.Center
status.Parent=frame

local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,-20,0,20)
info.Position=UDim2.new(0,10,0,195)
info.BackgroundTransparency=1
info.Text="Auto-types only remaining letters"
info.TextColor3=Color3.fromRGB(150,200,255)
info.Font=Enum.Font.Gotham
info.TextSize=10
info.TextXAlignment=Enum.TextXAlignment.Center
info.Parent=frame

---------- BUTTON HANDLERS ----------
randomBtn.MouseButton1Click:Connect(function()
    if not loaded then status.Text="Still loading..."; return end
    local input=searchBox.Text:match("^%s*(.-)%s*$")
    if #input<1 then status.Text="Enter a prefix!"; return end
    local word,actual=GetRandomWord(input)
    if not word then status.Text="No unused word found!"; return end
    status.Text="Typing: "..word
    AutoTypeText(actual,word)
    status.Text="Typed: "..word.." (prefix: "..actual..")"
end)

resetBtn.MouseButton1Click:Connect(function()
    local input=searchBox.Text:match("^%s*(.-)%s*$")
    if #input>0 and usedWords[input] then
        usedWords[input]={}
        status.Text="Reset used for: "..input
    else
        status.Text=#input>0 and "No used words for: "..input or "Enter prefix to reset!"
    end
end)

resetAllBtn.MouseButton1Click:Connect(function()
    usedWords={}
    status.Text="✅ All prefixes reset!"
end)

---------- TOGGLE ----------
local toggle=Instance.new("TextButton")
toggle.Name="Toggle"
toggle.Size=UDim2.new(0,50,0,50)
toggle.Position=UDim2.new(0,10,0,10)
toggle.BackgroundColor3=Color3.fromRGB(40,120,200)
toggle.Text="🔀"
toggle.TextColor3=Color3.new(1,1,1)
toggle.Font=Enum.Font.GothamBold
toggle.TextSize=20
toggle.Parent=screen
Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,10)

local guiEnabled=false; frame.Visible=false
toggle.MouseButton1Click:Connect(function()
    guiEnabled=not guiEnabled
    frame.Visible=guiEnabled
    toggle.Text=guiEnabled and "❌" or "🔀"
end)

print("✅ Random Word Typer (Multi-Source + Plain-Text) loaded!")
