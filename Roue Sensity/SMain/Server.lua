ESX = nil

TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)

local ArmeItem =  false -- METTEZ EN FALSE SI VOUS N'UTILISEZ PAS ARMES EN ITEM ( SYSTEME QUE JE VEND )
local webhook = '' -- LOGS DISCORD LORSQU'UN JOUEUR OUVRE LA ROUE
local webhookticket = '' -- LOGS QUAND UN JOUEUR ACHETE UN TICKET

local roueActive = {}
local GetVehicle = {}
local playerroue = {}

local roue = {
    [1] = { "Fusil Sniper", "Mercedes-Benz GT 63S AMG", "1500 FiftyCoin", "Carabine" }, -- LOTS EPIC !
    [2] = { "500.000$", "350.000$", "150.000$", "T-max" },  -- LOTS RARE
    [3] = {"Pistolet", "Karting", "Hache de Combat"}, -- LOTS COMMUN
    [4] = { "15 Gilet par balle", "10 Gilet par balle", "10 Menottes" }, -- LOTS DE MERDE
}

local getrecompense = {
    ['2500 FiftyCoins'] = {type = 'coin', coincount = '2500'}, -- MARCHE SEULEMENT SI VOUS UTILISEZ MON SYSTEME DE BOUTIQUE SINON VOUS DEVEZ ADAPTEZ !
    ['Mercedes-Benz GT 63S AMG'] = {type = 'vehicle', vehiclemodel = 'e63amg'}, -- SI VOUS VOULEZ AJOUTEZ DES VEHICULES PRENEZ EXEMPLE SUR CELUI CI
    ['500.000$'] = {type = 'money', moneycount = 750000}, -- SI VOUS VOULE FAIRE GAGNER DE L'ARGENT PRENEZ EXEMPLE ICI
    ['350.000$'] = {type = 'money', moneycount = 500000},
    ['Karting'] = {type = 'vehicle', vehiclemodel = 'veto2'},
    ['T-max'] = {type = 'vehicle', vehiclemodel = 'tmax'},
    ['150.000$'] = {type = 'money', moneycount = 350000},
    ['Pistolet'] = {type = 'weapon', weaponmodel = 'pistol'}, -- SI VOUS VOULEZ FAIRE GAGNER DES ARMES PRENEZ EXEMPLE SUR CELUI CI
    ['Carabine'] = {type = 'weapon', weaponmodel = 'carbinerifle'},
    ['Fusil Sniper'] = {type = 'weapon', weaponmodel = 'sniperrifle'},
    ['10 Gilet par balle'] = {type = 'item', itemmodel = 'armor', quantity = 10}, -- SI VOUS VOULEZ FAIRE GAGNER DES ITEMS PRENEZ EXEMPLE SUR SA
    ['15 Gilet par balle'] = {type = 'item', itemmodel = 'armor', quantity = 15},
    ['10 Menottes'] = {type = 'item', itemmodel = 'basic_cuff', quantity = 10}, 
    ['Hache de Combat'] = {type = 'weapon', weaponmodel = 'battleaxe'},
}

RegisterServerEvent('roue:createPlayer')
AddEventHandler('roue:createPlayer', function()
    src = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll("SELECT roue FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
        for k,v in pairs(result) do
            if not playerroue[xPlayer.identifier] then 
                playerroue[xPlayer.identifier] =  {} 
                playerroue[xPlayer.identifier].roue = v.roue
            end
        end
        TriggerClientEvent('roue:servertoclient', src, playerroue[xPlayer.identifier])
    end)
end)

RegisterServerEvent('ewen:loadingAnimation')
AddEventHandler('ewen:loadingAnimation', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('roue:roueonoff', -1, true)
    src = source
    roueActive[xPlayer.identifier] = true
    local xPlayer = ESX.GetPlayerFromId(src)
    if playerroue[xPlayer.identifier].roue == 1 then
        playerroue[xPlayer.identifier].roue = 0
    else
        local newticket = playerroue[xPlayer.identifier].roue - 1
        MySQL.Async.execute("UPDATE `users` SET `roue`= '".. newticket .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)  
        playerroue[xPlayer.identifier].roue = newticket
    end
    TriggerClientEvent('roue:servertoclient', src, playerroue[xPlayer.identifier])
end)

RegisterServerEvent('roue:buyTicket') -- MARCHE QUE SI VOUS UTILISEZ MA BOUTIQUE SINON VOUS DEVEZ FAIRE DES MODIFICATIONS
AddEventHandler('roue:buyTicket', function(numbers)
    src = source
    local xPlayer  = ESX.GetPlayerFromId(src)
    
    if numbers == 1 then 
            playerroue[xPlayer.identifier].roue = playerroue[xPlayer.identifier].roue + 1
            local newroue = playerroue[xPlayer.identifier].roue + 1
            MySQL.Async.execute("UPDATE `users` SET `roue`= '".. newroue .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
            TriggerClientEvent('roue:servertoclient', src, playerroue[xPlayer.identifier])
            PerformHttpRequest(webhookticket, function(err, text, headers) end, 'POST', json.encode({content = xPlayer.getName() .. " a acheter "..numbers.." tickets roue de la Fortune"}), { ['Content-Type'] = 'application/json' })
    elseif numbers == 5 then
            playerroue[xPlayer.identifier].roue = playerroue[xPlayer.identifier].roue + 5
            local newroue = playerroue[xPlayer.identifier].roue + 5
            local newpoint = result[1].syltacoin - 2350
            MySQL.Async.execute("UPDATE `users` SET `roue`= '".. newroue .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
            TriggerClientEvent('roue:servertoclient', src, playerroue[xPlayer.identifier])
            PerformHttpRequest(webhookticket, function(err, text, headers) end, 'POST', json.encode({content = xPlayer.getName() .. " a acheter "..numbers.." tickets roue de la Fortune"}), { ['Content-Type'] = 'application/json' })
    elseif numbers == 10 then
            playerroue[xPlayer.identifier].roue = playerroue[xPlayer.identifier].roue + 10
            local newroue = playerroue[xPlayer.identifier].roue + 10
            local newpoint = result[1].syltacoin - 4500
            MySQL.Async.execute("UPDATE `users` SET `syltacoin`= '".. newpoint .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
            MySQL.Async.execute("UPDATE `users` SET `roue`= '".. newroue .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
            TriggerClientEvent('roue:servertoclient', src, playerroue[xPlayer.identifier])
            PerformHttpRequest(webhookticket, function(err, text, headers) end, 'POST', json.encode({content = xPlayer.getName() .. " a acheter "..numbers.." tickets roue de la Fortune"}), { ['Content-Type'] = 'application/json' })
    else 
        TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', xPlayer.source)
    end
end)

local playerRouee = {}

RegisterServerEvent('roue:start')
AddEventHandler('roue:start', function()
    src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if roueActive[xPlayer.identifier] then
        Wait(5000)
        table.insert(playerRouee, src)
        StartRoue(src)
        roueActive[xPlayer.identifier] = false
    else
        print('non')
    end
end)

function StartRoue(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local percentage = math.random(1, 100)
    local award = {}
    for k,v in pairs(playerRouee) do
        if v == src then
            award[v] = {}
            if src == v then
                if percentage >= 95 then
                    award[v] = roue[1][math.random(1, #roue[1])]
                elseif percentage >= 75 then
                    award[v] = roue[2][math.random(1, #roue[2])]
                elseif percentage >= 40 then
                    award[v] = roue[3][math.random(1, #roue[3])]
                else
                    award[v] = roue[4][math.random(1, #roue[4])]
                end
                xPlayer.showAdvancedNotification("Fifty", "~y~Roue de la Fortune", 'Félicitation vous avez gagné : '.. award[v], 'CHAR_CALIFORNIA', 9)
                local lot = award[v]
                award = {}
                if getrecompense[lot] == nil then
                    TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', xPlayer.source)
                elseif getrecompense[lot].type == 'vehicle' then
                    GetVehicle[v] = true
                    TriggerClientEvent('buyVehicle', src, getrecompense[lot].vehiclemodel)
                elseif getrecompense[lot].type == 'item' then
                    xPlayer.addInventoryItem(getrecompense[lot].itemmodel, getrecompense[lot].quantity)
                elseif getrecompense[lot].type == 'weapon' then
                    if ArmeItem then
                        xPlayer.addInventoryItem(getrecompense[lot].weaponmodel, 1)
                    else
                        xPlayer.addWeapon(getrecompense[lot].weaponmodel, 250)
                    end
                elseif getrecompense[lot].type == 'coin' then
                    MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
                        if result[1] then
                            ExecuteCommand('p give ' .. result[1].character_id .. ' '.. getrecompense[lot].coincount)
                        end
                    end)
                elseif getrecompense[lot].type == 'money' then
                    xPlayer.addAccountMoney("bank", getrecompense[lot].moneycount)
                end
                TriggerClientEvent('roue:roueonoff', -1, false)
                table.remove(playerRouee, k)
                PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = xPlayer.getName() .. " a obtenue "..lot.."  dans la roue de la Fortune"}), { ['Content-Type'] = 'application/json' })
            end
        end
    end
end

RegisterServerEvent('ewen:boutiquevehicle')
AddEventHandler('ewen:boutiquevehicle', function (vehicleProps, vehicleType)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if GetVehicle[_source] == true then
        
        MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = vehicleProps.plate,
            ['@vehicle'] = json.encode(vehicleProps),
            ['@type'] = vehicleType
        }, function(rowsChanged)
        end)
        MySQL.Async.execute('INSERT INTO open_car (owner, plate, NB) VALUES (@owner, @plate, @NB)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = vehicleProps.plate,
            ['@NB'] = 1
        }, function(rowsChanged)
        end)
        GetVehicle[_source] = false
    else
        TriggerEvent('::{korioz#0110}::BanSql:ICheatServer', xPlayer.source)
    end
end)

ESX.RegisterServerCallback('roue:getPlate', function (source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function (result)
		cb(result[1] ~= nil)
	end)
end)