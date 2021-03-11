ESX = nil
local mining = false
local processing = false

Citizen.CreateThread(function()
    while ESX == nil do TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end) Wait(0) end
    while ESX.GetPlayerData().job == nil do Wait(0) end
    for k, v in pairs(Config.MiningPositions) do
       addBlip(v.coords, 501, 6, Strings['mining'])
    end
    addBlip(Config.Sell, 501, 6, Strings['sell_mine'])
    addBlip(Config.Process, 501, 6, Strings['sell_process'])
    Citizen.CreateThread(function()
        while true do
            local sleep = 250
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Sell, true) <= 3.0 then
                sleep = 0
                helpText(Strings['e_sell'])
                if IsControlJustReleased(0, 38) then
                    TriggerServerEvent('gx_cocky:sell')
                end
            end
            Wait(sleep)
        end
    end)
    while true do
        local closeTo = 0
        for k, v in pairs(Config.MiningPositions) do
            if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), v.coords, true) <= 2.5 then
                closeTo = v
                break
            end
        end
        if type(closeTo) == 'table' then
            while GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), closeTo.coords, true) <= 2.5 do
                Wait(0)
                helpText(Strings['press_mine'])
                if IsControlJustReleased(0, 38) then
                    local player, distance = ESX.Game.GetClosestPlayer()
                    if distance == -1 or distance >= 4.0 then
                        mining = true
                        SetEntityCoords(PlayerPedId(), closeTo.coords)
                        SetEntityHeading(PlayerPedId(), closeTo.heading)
                        FreezeEntityPosition(PlayerPedId(), true)

                         local model = loadModel(GetHashKey(Config.Objects['machette']))
                         local axe = CreateObject(model, GetEntityCoords(PlayerPedId()), true, false, false)
                         AttachEntityToEntity(axe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.09, 0.03, -0.02, -118.0, 180.0, 08.0, false, true, true, true, 0, true)
                        AttachEntityToEntity(entity1, entity2, boneIndex, xPos, yPos, zPos, xRot, yRot, zRot, p9, useSoftPinning, collision, isPed, vertexIndex, fixedRot)
                        while mining do
                            Wait(0)
                            SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
                            helpText(Strings['mining_info'])
                            DisableControlAction(0, 24, true)
                            if IsDisabledControlJustReleased(0, 24) then
                                local dict = loadDict('random@domestic')
                                TaskPlayAnim(PlayerPedId(), dict, 'pickup_low', 8.0, -8.0, -1, 2, 0, false, false, false)
                                local timer = GetGameTimer() + 800
                                while GetGameTimer() <= timer do Wait(2000) DisableControlAction(0, 24, true) end
                                ClearPedTasks(PlayerPedId())
                                TriggerServerEvent('gx_cocky:getItem')
                            elseif IsControlJustReleased(0, 194) then
                                break
                            end
                        end
                        mining = false
                        DeleteObject(axe)
                        FreezeEntityPosition(PlayerPedId(), false)
                    else
                        ESX.ShowNotification(Strings['someone_close'])
                    end
                end
            end
        end
        Wait(250)
    end
end)

loadModel = function(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end

loadDict = function(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

helpText = function(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

addBlip = function(coords, sprite, colour, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()

	RequestModel(3545903169)
	while not HasModelLoaded(3545903169) do
	Wait(1)

	end

	--PROVIDER
		meth_dealer_seller = CreatePed(1, 3545903169, 201.119003659,64.6696472168,104.62797546387, 154.6, false, true)
		SetBlockingOfNonTemporaryEvents(meth_dealer_seller, true)
		SetPedDiesWhenInjured(meth_dealer_seller, false)
		SetPedCanPlayAmbientAnims(meth_dealer_seller, true)
		SetPedCanRagdollFromPlayerImpact(meth_dealer_seller, false)
		SetEntityInvincible(meth_dealer_seller, true)
		FreezeEntityPosition(meth_dealer_seller, true)
		TaskStartScenarioInPlace(meth_dealer_seller, "WORLD_HUMAN_SMOKING", 0, true);

end)

Citizen.CreateThread(function()

    while true do
        local sleep = 250
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.Process, true) <= 3.0 then
            sleep = 0
            helpText(Strings['e_process'])


            if IsControlJustReleased(0, 38) then
				SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"),true)
				Citizen.Wait(500)
				local animDict = "mini@repair"
				local animLib = "fixing_a_ped"

				RequestAnimDict(animDict)
				while not HasAnimDictLoaded(animDict) do
					Citizen.Wait(50)
				end
                ESX.TriggerServerCallback('gx_cocky:canprocess', function(can)
                    if can then
                        FreezeEntityPosition(PlayerPedId(), true)
                        TaskPlayAnim(PlayerPedId(),animDict,animLib,1.0, -1.0, -1, 2, 0, 0, 0, 0)
                        exports['progressBars']:startUI(10000, "PROCESSING")
                        Citizen.Wait (10100)
                        ClearPedTasks(PlayerPedId())
                        FreezeEntityPosition(PlayerPedId(), false)
                        TriggerServerEvent('gx_cocky:process')
                       --trigger process and start progressbar
                    end
                end)

            end
        end
        Wait(sleep)
    end
end)
