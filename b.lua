-- ✅ LOG ONLY: cek apakah CurrentWord ada & isinya apa
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function logCurrentWord()
    local ok, gui = pcall(function()
        return lp.PlayerGui:WaitForChild("InGame", 5)
                           :WaitForChild("Frame", 5)
                           :WaitForChild("CurrentWord", 5)
    end)

    if ok and gui then
        print("[LOG] CurrentWord Text = '" .. gui.Text .. "'")
        print("[LOG] CurrentWord FullPath = " .. gui:GetFullName())
    else
        warn("[LOG] CurrentWord TIDAK ditemukan!")
        -- coba scan apa saja yang ada di PlayerGui
        warn("[LOG] Isi PlayerGui:")
        for _,v in ipairs(lp.PlayerGui:GetChildren()) do
            warn("  - " .. v.Name .. " (" .. v.ClassName .. ")")
        end
    end
end

-- jalankan sekali + loop setiap 2 detik
logCurrentWord()
while true do
    task.wait(2)
    logCurrentWord()
end
