
local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)


VorpInv = exports.vorp_inventory:vorp_inventoryApi()

for _, item in pairs(Config.Items) do   
    VorpInv.RegisterUsableItem(item.name, function(data)
        VorpInv.CloseInv(data.source)
        TriggerClientEvent("xakra_ufo:UFO", data.source, item)
    end)
end

RegisterServerEvent("xakra_ufo:SubItem")
AddEventHandler("xakra_ufo:SubItem", function(item)
    VorpInv.subItem(source, item.name, item.amount)
end)

