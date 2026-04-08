local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Tap World 🌍",
    Author = "By:Vannzx",
    Theme = "Dark"
})

local Main = Window:Tab({ Title = "⚡ Main" })
local EggsTab = Window:Tab({ Title = "🥚 Eggs" })
local WorldTab = Window:Tab({ Title = "🌎 World" })

local RS = game:GetService("ReplicatedStorage")
local UpgradeRemote = RS.Functions.PurchaseUpgrade
local HatchRemote = RS.Functions.Hatch
local ClickRemote = RS.Events.Click
local RebirthRemote = RS.Events.Rebirth
local TeleportRemote = RS.Events.Teleport

local AutoClick = false
local AutoRebirth = false
local AutoBestRebirth = false
local AutoUpgrade = false
local AutoEgg = false
local SelectedEgg = "Basic"
local SelectedWorld = "Spawn"
local SelectedRebirth = 1
local SelectedUpgrades = {}

local suffixes = {
    [3]="K",[6]="M",[9]="B",[12]="T",[15]="Qa",[18]="Qi",[21]="Sx",[24]="Sp",[27]="Oc",[30]="No",
    [33]="Dc",[36]="Ud",[39]="Dd",[42]="Td",[45]="Qad",[48]="Qid",[51]="Sxd",[54]="Spd",[57]="Ocd",[60]="Nod",
    [63]="Vg",[66]="Uvg",[69]="Dvg",[72]="Tvg",[75]="Qatv"
}

local function formatNumber(num)
    if num < 1000 then return tostring(math.floor(num)) end
    local exp = math.floor(math.log10(num))
    local rounded = exp - (exp % 3)
    local suffix = suffixes[rounded]
    if suffix then
        return math.floor(num / (10^rounded))..suffix
    end
    return string.format("%.0e", num)
end

local RebirthList = {
    5,10,15,25,50,75,100,150,250,500,750,1000,
    1250,1500,2000,2500,3000,3500,4500,5000,
    6000,8000,10000,15000,25000,50000,750000,
    1000000,1500000,2500000,3750000,5000000,7500000,
    10000000,12500000,15000000,17500000,20000000,
    22500000,25000000,30000000,40000000,50000000,
    75000000,100000000,125000000,150000000,
    200000000,225000000,250000000,275000000,
    300000000,400000000,500000000,600000000,
    750000000,850000000,1000000000,
    5e16,5e17,5e18,5e19,5e20,1e55,1e56,1e57,1e58,1e59,1e60,1e61,1e62,1e63,1e64,1e65,
    1e70,1e75,2e71,2.1e71,2.2e71,2.3e71,2.4e71,2.7e71,
    5e71,5.4e71,5.6e71,6e71,6.5e71,7e71,7.2e71,8e71,9e71,
    5e72,1.005e73,1.01e73,1.03e73,1.04e73,1.045e73,
    1.05e73,1.06e73,2e73,1.3e74,4e74,4.5e75,6e75,1e76
}

local DisplayList = {}
local Map = {}
for _, v in ipairs(RebirthList) do
    local f = formatNumber(v)
    table.insert(DisplayList, f)
    Map[f] = v
end

Main:Section({ Title = "🔥 Automatic Farming" })
Main:Toggle({
    Title = "Auto Click",
    Callback = function(v)
        AutoClick = v
        task.spawn(function()
            while AutoClick do
                ClickRemote:FireServer()
                task.wait()
            end
        end)
    end
})

Main:Section({ Title = "💎 Rebirth System" })
Main:Dropdown({
    Title = "Select Rebirth Amount",
    Values = DisplayList,
    Callback = function(v) SelectedRebirth = Map[v] end
})

Main:Toggle({
    Title = "Auto Rebirth",
    Callback = function(v)
        AutoRebirth = v
        task.spawn(function()
            while AutoRebirth do
                RebirthRemote:FireServer(SelectedRebirth)
                task.wait(0.15)
            end
        end)
    end
})

Main:Toggle({
    Title = "Auto Best Rebirth",
    Callback = function(v)
        AutoBestRebirth = v
        task.spawn(function()
            while AutoBestRebirth do
                for i = #RebirthList, 1, -1 do
                    local ok = pcall(function() RebirthRemote:FireServer(RebirthList[i]) end)
                    if ok then break end
                end
                task.wait(0.1)
            end
        end)
    end
})

Main:Section({ Title = "🛠️ Auto Upgrades" })
local UpgradesList = {"ClickMulti", "GemMulti", "GemChance", "RebirthButtons", "WalkSpeed", "MoreStorage", "PetEquip", "LuckMulti", "HatchSpeed", "CriticalChance", "ChestAutoCollect"}
Main:Dropdown({
    Title = "Select Upgrades to Buy",
    Values = UpgradesList,
    Multi = true,
    Callback = function(v) SelectedUpgrades = v end
})

Main:Toggle({
    Title = "Enable Auto Upgrade",
    Callback = function(v) AutoUpgrade = v end
})

task.spawn(function()
    while task.wait(0.5) do
        if AutoUpgrade then
            for _, u in pairs(SelectedUpgrades) do
                UpgradeRemote:InvokeServer("Spawn", u)
            end
        end
    end
end)

EggsTab:Section({ Title = "🥚 Hatching" })
EggsTab:Dropdown({
    Title = "Select Egg Type",
    Values = {"Basic", "Gummy Egg", "Rare", "Beach", "Snow", "Candy", "Easter", "Chocolate", "Weekly Egg", "MemeEgg"},
    Callback = function(v) SelectedEgg = v end
})

EggsTab:Toggle({
    Title = "Auto Hatch Eggs",
    Callback = function(v) AutoEgg = v end
})

task.spawn(function()
    while task.wait(0.1) do
        if AutoEgg then
            local ok = pcall(function() HatchRemote:InvokeServer(SelectedEgg, "Triple") end)
            if not ok then HatchRemote:InvokeServer(SelectedEgg, "Single") end
        end
    end
end)

WorldTab:Section({ Title = "🌌 Travel" })
WorldTab:Dropdown({
    Title = "Select Destination",
    Values = {"Spawn", "Beach", "Snow", "Candy", "Egg World", "Easter", "Tiki Island"},
    Callback = function(v) SelectedWorld = v end
})

WorldTab:Button({
    Title = "Teleport Now",
    Callback = function() TeleportRemote:FireServer(SelectedWorld) end
})
