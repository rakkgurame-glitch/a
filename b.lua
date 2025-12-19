-- =========================================
-- DEBUG: COPY RAW CurrentWord.Text TO CLIPBOARD
-- =========================================

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local function copyCurrentWordRaw()
    local ok, text = pcall(function()
        return lp.PlayerGui.InGame.Frame.CurrentWord.Text
    end)

    if not ok or not text then
        if setclipboard then
            setclipboard("[ERROR] Failed to read CurrentWord.Text")
        end
        return
    end

    if setclipboard then
        setclipboard(text)
    end
end

-- langsung copy saat script dijalankan
copyCurrentWordRaw()

-- OPTIONAL: tekan F8 untuk copy ulang kapan saja
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        copyCurrentWordRaw()
    end
end)
