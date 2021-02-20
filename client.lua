ESX = nil

local wait = 0
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

zgarage = {
    listevoiture = {},
    listefourriere = {}
}

-- Blips Garage & Pound
Citizen.CreateThread(function()
    for k,v in pairs(garagepublic.zone) do
       local blip = AddBlipForCoord(v.sortie.x, v.sortie.y, v.sortie.z)
       SetBlipSprite(blip, 541)
       SetBlipColour(blip, 38)
       SetBlipScale(blip,0.6)
       SetBlipAsShortRange(blip, true)

       BeginTextCommandSetBlipName('STRING')
       AddTextComponentString("Garage")
       EndTextCommandSetBlipName(blip)
   end
end)


Citizen.CreateThread(function()
    for k,v in pairs(garagepublic.fourriere) do
       local blip = AddBlipForCoord(v.sortie.x, v.sortie.y, v.sortie.z)
       SetBlipSprite(blip, 67)
       SetBlipColour(blip, 64)
       SetBlipScale(blip,0.6)
       SetBlipAsShortRange(blip, true)

       BeginTextCommandSetBlipName('STRING')
       AddTextComponentString("Fourrière")
       EndTextCommandSetBlipName(blip)
   end
end)

-------------------------------------------------------------------------

-- Marker to exit a vehicle

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(wait)
        local coords, letSleep = GetEntityCoords(PlayerPedId()), true
        for k,v in pairs(garagepublic.zone) do
            if (garagepublic.Type ~= -1 and GetDistanceBetweenCoords(coords, v.sortie.x, v.sortie.y, v.sortie.z, true) < garagepublic.DrawDistance) then
                DrawMarker(garagepublic.Type, v.sortie.x, v.sortie.y, v.sortie.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, garagepublic.Size.x, garagepublic.Size.y, garagepublic.Size.z, garagepublic.Colorr.r, garagepublic.Colorr.g, garagepublic.Colorr.b, 100, false, true, 2, false, false, false, false)
                letSleep = false
            end
            if (garagepublic.Type ~= -1 and GetDistanceBetweenCoords(coords, v.ranger.x, v.ranger.y, v.ranger.z, true) < garagepublic.DrawDistance) then
                DrawMarker(garagepublic.Type, v.ranger.x, v.ranger.y, v.ranger.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, garagepublic.Size.x, garagepublic.Size.y, garagepublic.Size.z, garagepublic.Colorr.r, garagepublic.Colorr.g, garagepublic.Colorr.b, 100, false, true, 2, false, false, false, false)
                letSleep = false
            end
        end
        for k,v in pairs(garagepublic.fourriere) do
            if (garagepublic.Type ~= -1 and GetDistanceBetweenCoords(coords, v.sortie.x, v.sortie.y, v.sortie.z, true) < garagepublic.DrawDistance) then
                DrawMarker(39, v.sortie.x, v.sortie.y, v.sortie.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, garagepublic.Size.x, garagepublic.Size.y, garagepublic.Size.z, 255, 100, garagepublic.Colorr.b, 100, false, true, 2, false, false, false, false)
                letSleep = false
            end
        end
        if letSleep then
            Citizen.Wait(500)
        end
    end
end)



--open menu exit / put away and pound
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(wait)
    
        for k,v in pairs(garagepublic.zone) do
    
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.sortie.x, v.sortie.y, v.sortie.z)
            local distr = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.ranger.x, v.ranger.y, v.ranger.z)
            -- open menu exit vehicle
            if dist <= 1.0 then
                ESX.ShowHelpNotification("Appuyez sur [~b~E~w~] pour sortir un ~b~véhicule")
                if IsControlJustPressed(1,51) then
                    ESX.TriggerServerCallback('zgarage:listevoiture', function(ownedCars)
                        zgarage.listevoiture = ownedCars
                    end)
                    publicgarage = false
                    ouvrirpublicgar()
                end
            end
            -- tidy up car button
            if distr <= 1.0 then
                ESX.ShowHelpNotification("Appuyez sur [~b~E~w~] pour ranger un ~b~véhicule")
                if IsControlJustPressed(1,51) then
                    rangervoiture()
                end   
            end
        end
        -- open menu exit vehicle impound 
        for k,v in pairs(garagepublic.fourriere) do
    
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.sortie.x, v.sortie.y, v.sortie.z)

            if dist <= 1.0 then

                ESX.ShowHelpNotification("Appuyez sur [~b~E~w~] pour sortir de la fourrière un ~b~véhicule")
                if IsControlJustPressed(1,51) then
                    ESX.TriggerServerCallback('zgarage:listevoiturefourriere', function(ownedCars)
                        zgarage.listefourriere = ownedCars
                    end)
                    publicfourriere = false
                    ouvrirpublicfourr()
                end  
            end
        end
    end
end)
--------------- RAGEUI -----------------------

local publicgarage = false
RMenu.Add('garagepublic', 'main', RageUI.CreateMenu("Garage", "Pour sortir un véhicule"))
RMenu:Get('garagepublic', 'main').Closed = function()
    publicgarage = false
end

local publicfourriere = false
RMenu.Add('garagepublicfourriere', 'main', RageUI.CreateMenu("Fourrière", "Pour sortir un véhicule de la fourrière"))
RMenu:Get('garagepublicfourriere', 'main').Closed = function()
    publicfourriere = false
end


---------------- FONCTION -----------------------------

function ouvrirpublicgar()
    if not publicgarage then
        publicgarage = true
        RageUI.Visible(RMenu:Get('garagepublic', 'main'), true)
    while publicgarage do
        RageUI.IsVisible(RMenu:Get('garagepublic', 'main'), true, true, true, function()

        for i = 1, #zgarage.listevoiture, 1 do
        	local hashvoiture = zgarage.listevoiture[i].vehicle.model
        	local modelevoiturespawn = zgarage.listevoiture[i].vehicle
        	local nomvoituremodele = GetDisplayNameFromVehicleModel(hashvoiture)
        	local nomvoituretexte  = GetLabelText(nomvoituremodele)
        	local plaque = zgarage.listevoiture[i].plate


            RageUI.Button(plaque.." | "..nomvoituretexte, "Pour sortir votre véhicule", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                	sortirvoiture(modelevoiturespawn, plaque)
                	RageUI.CloseAll()
                    publicgarage = false
            end
            end)
        end

        end, function()
        end)
            Citizen.Wait(wait)
        end
    else
        publicgarage = false
    end
end



function sortirvoiture(vehicle, plate)
	x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))

	ESX.Game.SpawnVehicle(vehicle.model, {
		x = x,
		y = y,
		z = z 
	}, GetEntityHeading(PlayerPedId()), function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		SetVehicleFixed(callback_vehicle)
		SetVehicleDeformationFixed(callback_vehicle)
		SetVehicleUndriveable(callback_vehicle, false)
		SetVehicleEngineOn(callback_vehicle, true, true)
		--SetVehicleEngineHealth(callback_vehicle, 1000) -- Might not be needed
		--SetVehicleBodyHealth(callback_vehicle, 1000) -- Might not be needed
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
	end)

	TriggerServerEvent('zgarage:etatvehiculesortie', plate, false)
end


function rangervoiture()
	local playerPed  = GetPlayerPed(-1)
	if IsPedInAnyVehicle(playerPed,  false) then
		local playerPed    = GetPlayerPed(-1)
		local coords       = GetEntityCoords(playerPed)
		local vehicle      = GetVehiclePedIsIn(playerPed, false)
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		local current 	   = GetPlayersLastVehicle(GetPlayerPed(-1), true)
		local engineHealth = GetVehicleEngineHealth(current)
		local plate        = vehicleProps.plate

		ESX.TriggerServerCallback('zgarage:rangervoiture', function(valid)
			if valid then
					etatrangervoiture(vehicle, vehicleProps)
			else
				ESX.ShowNotification('Tu ne peu pas garer ce véhicule')
			end
		end, vehicleProps)
	else
		ESX.ShowNotification('Il n y a pas de véhicule à ranger dans le garage.')
	end
end

function etatrangervoiture(vehicle, vehicleProps)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('zgarage:etatvehiculesortie', vehicleProps.plate, true)
	ESX.ShowNotification('Ton véhicule est ranger dans le garage.')
end

function ouvrirpublicfourr()
    if not publicfourriere then
        publicfourriere = true
        RageUI.Visible(RMenu:Get('garagepublicfourriere', 'main'), true)
    while publicfourriere do
        RageUI.IsVisible(RMenu:Get('garagepublicfourriere', 'main'), true, true, true, function()

        for i = 1, #zgarage.listefourriere, 1 do
        	local hashvoiture = zgarage.listefourriere[i].vehicle.model
        	local modelevoiturespawn = zgarage.listefourriere[i].vehicle
        	local nomvoituremodele = GetDisplayNameFromVehicleModel(hashvoiture)
        	local nomvoituretexte  = GetLabelText(nomvoituremodele)
        	local plaque = zgarage.listefourriere[i].plate


            RageUI.Button(plaque.." | "..nomvoituretexte, "Pour sortir votre véhicule", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if (Selected) then   
                ESX.TriggerServerCallback('zgarage:verifsous', function(suffisantsous)
				if suffisantsous then
					TriggerServerEvent('zgarage:payechacal')
					sortirvoiture(modelevoiturespawn, plaque)
                    RageUI.CloseAll()
                    publicfourriere = false
				else
					ESX.ShowNotification('Tu n\'as pas assez d argent!')
				end

			end)
            end
            end)
        end

        end, function()
        end)
            Citizen.Wait(0)
        end
    else
        publicfourriere = false
    end
end

--- Script made by Zeeky, Function inspired by H4CI
