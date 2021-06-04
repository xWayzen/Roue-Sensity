ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('::{korioz#0110}::esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

local tour = {}
local load = false

Citizen.CreateThread(function()
    Wait(2500)
    TriggerServerEvent('roue:createPlayer')
end)

RegisterNetEvent('roue:servertoclient')
AddEventHandler('roue:servertoclient', function(table)
    load = true
    tour = table
end)

local tb = {}
local baseCoords = 29.8
local groundCoords = 29.392116928101

local isRolling = false

local roue, base, triangle, socle, veh, roueSpawn = nil,nil,nil,nil,false
local currentVehicleRewardModel = 'r1' -- lA VOITURE SUR VOUS VOULEZ AFFICHER

local function startSpin()
    Citizen.CreateThread(function()
        local pos = 7
        SetEntityRotation(roue, 0, 0, 160.0, false, true);

        local deg = 0.0;
        local inc = 1;

        -- First step, increment speed
        for i = 1,200 do
            SetEntityRotation(roue, 0, -deg, 160.0, false, true);
            deg = deg + inc;

            if inc < 4 then
                inc = inc + 0.2;
            end

            Citizen.Wait(5);
        end

        while math.ceil((deg - ((inc / 0.01) / 2) % 360 - pos) % 360) >= 5 do
            SetEntityRotation(roue, 0, -deg, 160.0, false, true);
            deg = deg + inc;
            Citizen.Wait(5);
        end
        
        isRolling = false;
    end)
end

local function deleteRoue()
    DeleteEntity(triangle)
    triangle = nil
    DeleteEntity(base)
    base = nil
    DeleteEntity(socle)
    socle = nil
    DeleteEntity(veh)
    veh = nil
    DeleteEntity(roue)
    roue = nil
    roueSpawn = false
end

local function GenerateRoue()
    -- Roue
    local model = GetHashKey('vw_prop_vw_luckywheel_02a')
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    roue = CreateObject(model, vector3(234.31323242188, -880.28216552734, (baseCoords)), false, false)
    -- Base
    model = GetHashKey("vw_prop_vw_luckywheel_01a")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    base = CreateObject(model, vector3(234.31323242188, -880.28216552734, (baseCoords-0.3)), false, false)
    -- Triangle
    model = GetHashKey("vw_prop_vw_jackpot_on")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    triangle = CreateObject(model, vector3(234.31323242188, -880.28216552734, (baseCoords+2.5)), false, false)
    -- Socle
    model = GetHashKey("vw_prop_vw_casino_podium_01a")
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    socle = CreateObject(model, vector3(226.07943725586, -877.56732177734, 29.392116928101), false, false)
    SetEntityRotation(roue, GetEntityPitch(roue), GetEntityRoll(roue), 160.0, 3, 1)
    SetEntityRotation(base, GetEntityPitch(base), GetEntityRoll(base), 160.0, 3, 1)
    SetEntityRotation(triangle, GetEntityPitch(triangle), GetEntityRoll(triangle), 160.0, 3, 1)
    -- Véhicule
    model = GetHashKey(currentVehicleRewardModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    veh = CreateVehicle(model, vector3(226.07943725586, -877.56732177734, 29.592116928101), 90.0, false, false)
    FreezeEntityPosition(veh, true)
    SetVehicleDoorsLocked(veh, 2)
    SetEntityInvincible(veh, true)
    SetVehicleFixed(veh)
    SetVehicleDirtLevel(veh, 0.0)
    SetVehicleEngineOn(veh, true, true, true)
    SetVehicleLights(veh, 2)
    SetVehicleCustomPrimaryColour(veh, 33,33,33)
    SetVehicleCustomSecondaryColour(veh, 33,33,33)
    roueSpawn = true
end


Citizen.CreateThread(function()
    local rot = 1.0
    while true do
        local interval = 1
        if roueSpawn and socle ~= nil and veh ~= nil then
            rot = rot - 0.15
            SetEntityRotation(socle, GetEntityPitch(socle), GetEntityRoll(socle), rot, 3, 1)
            SetEntityHeading(veh, rot)
        else
            interval = 500
        end
        Wait(interval)
    end
end)

Citizen.CreateThread(function()
    while not load do 
        Wait(0)
    end
    while true do
        local interval = 500
        local pos = GetEntityCoords(PlayerPedId())
        local basePos = vector3(236.00059509277, -880.18023681641, 30.492071151733)
        local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), basePos, true)
        if roueSpawn then
            if dist > 150.0 then
                deleteRoue()
            else
                interval = 1
                if dist <= 2.0 and not isRolling then
                    if tour.roue >= 1 then
                        ESX.ShowHelpNotification('~g~Roue de la Fortune ~n~~w~Appuie sur ~g~E~w~ pour tourner la roue') 
                        if IsControlJustPressed(0, 51) then
                            if not rStart then
                                TriggerServerEvent('roue:on')
                                TriggerServerEvent('ewen:loadingAnimation')
                                TriggerServerEvent('roue:start')
                                isRolling = true

                                local playerPed = PlayerPedId()
                                local _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@female'
                                if IsPedMale(playerPed) then
                                    _lib = 'anim_casino_a@amb@casino@games@lucky7wheel@male'
                                end
                                local lib, anim = _lib, 'enter_right_to_baseidle'
                                ESX.Streaming.RequestAnimDict(lib, function()
                                    TaskGoStraightToCoord(playerPed,  basePos.x, basePos.y, (baseCoords),  1.0,  -1,  107.2,  0.0)
                                    local hasMoved = false
                                    while not hasMoved do
                                        local coords = GetEntityCoords(PlayerPedId())
                                        if coords.x >= (basePos.x - 0.01) and coords.x <= (basePos.x + 0.01) and coords.y >= (basePos.y - 0.01) and coords.y <= (basePos.y + 0.01) then
                                            hasMoved = true
                                        end
                                        Citizen.Wait(0)
                                    end
                                    TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)
                                    TaskPlayAnim(playerPed, lib, 'armraisedidle_to_spinningidle_high', 8.0, -8.0, -1, 0, 0, false, false, false)
                                    startSpin()
                                end)
                            else
                                ESX.ShowNotification('~R~Erreur ~w~~n~Quelqu\'un est déjà entrain de tourner la roue')
                            end


                        end
                    else
                        ESX.ShowHelpNotification('~g~Roue de la Fortune ~n~~w~Vous n\'avez pas de Ticket.~n~')
                    end
                end
            end
        else
            if dist < 150.0 then
                GenerateRoue()
            end
        end
        Wait(interval)
    end
end)

RegisterNetEvent('roue:roueonoff')
AddEventHandler('roue:roueonoff', function(table)
    rStart = table
end)

RegisterNetEvent('buyVehicle')
AddEventHandler('buyVehicle', function(model)
    ESX.Game.SpawnVehicle(model, vector3(241.8798, -884.1371, 30.0705), nil, function(vehicle)
        TaskWarpPedIntoVehicle(GetPlayerPed(PlayerId()), vehicle, -1)
        local newPlate = GeneratePlate()
        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        vehicleProps.plate = newPlate
        SetVehicleNumberPlateText(vehicle, newPlate)
        TriggerServerEvent('::{korioz#0110}::esx_vehicleshop:setVehicleOwned', vehicleProps, 'car')
    end)
end)

-- CREATION PLAQUE

local NumberCharset = {}
local Charset = {}

for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	local generatedPlate
	local doBreak = false
    while true do
		Citizen.Wait(2)
		math.randomseed(GetGameTimer())
        generatedPlate = string.upper(GetRandomNumber(2) .. GetRandomLetter(3) .. GetRandomNumber(3))

		ESX.TriggerServerCallback('roue:getPlate', function (isPlateTaken)
			if not isPlateTaken then
				doBreak = true
			end
		end, generatedPlate)

		if doBreak then
			break
		end
	end

	return generatedPlate
end

-- mixing async with sync tasks
function IsPlateTaken(plate)
	local callback = 'waiting'

	ESX.TriggerServerCallback('roue:getPlate', function(isPlateTaken)
		callback = isPlateTaken
	end, plate)

	while type(callback) == 'string' do
		Citizen.Wait(0)
	end

	return callback
end

function GetRandomNumber(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GetRandomLetter(length)
	Citizen.Wait(1)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end