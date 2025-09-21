local jobBlips = {}
local jobPoints = {}
local vehicle
if not lib then error(JOBCREATOR.Language[JOBCREATOR.lang].nooxlib) end

local function debugprint(msg)
    if not JOBCREATOR.DEBUG then return end
    print("^2|~[DEBUG]~| - ".. msg)
end

local function place(type, job)
    while true do
        Wait(0)
        lib.showTextUI("[E]")
        if IsControlJustReleased(0, 38) then
            break
        end
    end
    lib.hideTextUI()
    local coords = GetEntityCoords(PlayerPedId())
    lib.callback("jobcreator:place", false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successplaceing, "success", 3000)
        end
    end, type, job, json.encode(coords))
end

RegisterNuiCallback("close", function(data, cb)
    SetNuiFocus(false, false)
    debugprint('NUI closed')
    cb('ok')
end)

RegisterCommand("jobcreator", function()
    lib.callback('jobcreator:getData', false, function(table, activejob)
        debugprint("JobCreator opened\nData received: " .. json.encode(table))
        SendNUIMessage({
            type = 'open',
            table = table,
            active = activejob,
            larryage = JOBCREATOR.Language[JOBCREATOR.lang].ui
        })
        SetNuiFocus(true, true)
    end)
end)

RegisterCommand('f6menu', function()
    local actions = lib.callback.await('jobcreator:getf6actions', false)
    local options = {}
    for action, data in pairs(actions) do
        if not action then 
            goto continue
        end
        
        if data == 0 then
            goto continue
        end

        table.insert(options, {
            title = action == 'drag' and data == 1 and JOBCREATOR.Language[JOBCREATOR.lang].actions.drag 
            or action == 'putInVehicle' and data == 1 and JOBCREATOR.Language[JOBCREATOR.lang].actions.putinveh 
            or action == 'outVehicle' and data == 1 and JOBCREATOR.Language[JOBCREATOR.lang].actions.putoutveh 
            or action == 'cuff' and data == 1 and JOBCREATOR.Language[JOBCREATOR.lang].actions.handcuff 
            or action == 'search' and data == 1 and JOBCREATOR.Language[JOBCREATOR.lang].actions.search
            or action == 'prop' and data == 1 and JOBCREATOR.Language[JOBCREATOR.lang].actions.prop,
            icon = action == 'drag' and data == 1 and 'fa-solid fa-arrows-down-to-people' 
            or action == 'putInVehicle' and data == 1 and 'fa-solid fa-car-side'
            or action == 'outVehicle' and data == 1 and 'fa-solid fa-car-side'
            or action == 'cuff' and data == 1 and 'fa-solid fa-handcuffs'
            or action == 'search' and data == 1 and 'fa-solid fa-id-card'
            or action == 'prop' and data == 1 and 'fa-solid fa-boxes-stacked',
            onSelect = function()
                local Coords = GetEntityCoords(PlayerPedId())
                local player = lib.getClosestPlayer(Coords, 2.0, false)
                if player then
                    if action == 'drag' then
                        TriggerServerEvent('jobcreator:drag', GetPlayerServerId(player))
                    elseif action == 'putInVehicle' then
                        TriggerServerEvent('jobcreator:getinveh', GetPlayerServerId(player))
                    elseif action == 'outVehicle' then
                        TriggerServerEvent('jobcreator:getinveh', GetPlayerServerId(player))
                    elseif action == 'cuff' then
                        TriggerServerEvent('jobcreator:cancuff', GetPlayerServerId(player))
                    elseif action == 'search' then
                        exports.ox_inventory:openNearbyInventory()
                    elseif action == 'prop' then
                        lib.registerContext({
                            id = 'props',
                            title = "Object Placer",
                            options = {
                                {
                                    title = "Barrier",
                                    icon = 'road-barrier',
                                    onSelect = function()
                                        PlaceObject('prop_barrier_work05', 'road-barrier')
                                    end
                                },
                                {
                                    title = "Cone",
                                    icon = 'life-ring',
                                    onSelect = function()
                                        PlaceObject('prop_roadcone02a', 'life-ring')
                                    end
                                },
                                {
                                    title = "Spike Strip",
                                    icon = 'xmarks-lines',
                                    onSelect = function()
                                        PlaceObject('p_ld_stinger_s', 'xmarks-lines')
                                    end
                                }
                            }
                        })
                        lib.showContext('props')
                    end
                end
            end
        })
        :: continue ::
    end

    if #options == 0 then return end

    lib.registerContext({
        id = 'f6menu',
        title = JOBCREATOR.Language[JOBCREATOR.lang].actions.F6MENU,
        options = options
    })
    lib.showContext('f6menu')
    debugprint("Action menu opened\nActions received: " .. json.encode(actions))
end)

RegisterNuiCallback("refresh", function(_, cb)
    lib.callback('jobcreator:getData', false, function(table, activejob)
        debugprint("Jobs refreshed\nData received: " .. json.encode(table))
        cb(table)
    end)
end)

RegisterNuiCallback("createjob", function(data, cb)
    debugprint("Try to create job with data: " .. json.encode(data))
    if data.name == "" or data.label == "" then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].nodata, "error", 3000) end
    lib.callback('jobcreator:createjob', false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successjobcreate, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("creategrade", function(data, cb)
    debugprint("Try to create grade with data: " .. json.encode(data))
    if data.job == "" then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].nodata, "error", 3000) end
    lib.callback('jobcreator:creategrade', false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successgradecreate, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("deletegrade", function(data, cb)
    debugprint("Try to delete grade with data: " .. json.encode(data))
    lib.callback('jobcreator:deletegrade', false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successgradedelete, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("updatesalary", function(data, cb)
    debugprint("Try to update salary with data: " .. json.encode(data))
    lib.callback('jobcreator:updategradeSalary', false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successgradesalary, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("setgrade", function(data, cb)
    lib.callback('jobcreator:setgrade', false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successgradeset, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("importjob", function(text, cb)
    debugprint("Try to import job with data: " .. text)
    local data = json.decode(text)
    lib.callback("jobcreator:importjob", false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successjobcreate, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("createvehicle", function(data, cb)
    debugprint("Try to create vehicle with data: " .. json.encode(data))
    lib.callback("jobcreator:createvehicle", false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successcarcreate, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("deletevehicle", function(data, cb)
    debugprint("Try to delete vehicle with data: " .. json.encode(data))
    lib.callback("jobcreator:deletevehicle", false, function(success)
        if success then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].successcardelete, "success", 3000)
            cb('ok')
        end
    end, data)
end)

RegisterNuiCallback("place", function(data, cb)
    place(data.type, data.job)
    cb('ok')
end)

RegisterNUICallback("refreshmember", function(data, cb)
    lib.callback('jobcreator:getbossmenudata', false, function(members)
        cb(members)
    end, ESX.PlayerData.job.name)
end)

RegisterNuiCallback("felvetel", function (data, cb)
    lib.callback.await('jobcreator:felvetel', false, data)
    cb('ok')
end)

RegisterNUICallback("kick", function(data, cb)
    local tesztt = lib.callback.await('jobcreator:kickmember', false, data)
    if tesztt then 
        JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.successkick, "success", 3000)
        cb('ok')
    else 
        JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.failedkick, "error", 3000)
    end
end)

RegisterNuiCallback("setnewcolor", function(data, cb)
    lib.callback.await('jobcreator:setnewcolor', false, data)
    cb('ok')
end)

RegisterNuiCallback('teleport', function(cord, cb)
    local c = json.decode(cord)
    SetEntityCoords(PlayerPedId(), c.x, c.y, c.z, false, false, false, false)
    cb('ok')
end)

RegisterNuiCallback('deletejob', function(name, cb)
    debugprint("Try to delete job with name: " .. name)
    lib.callback.await('jobcreator:deletejob', false, name)
    cb('ok')
end)

RegisterNuiCallback('upmember', function(data, cb)
    lib.callback.await('jobcreator:updatemember', false, data)
    cb('ok')
end)

RegisterNuiCallback('downmember', function(data, cb)
    lib.callback.await('jobcreator:updatemember', false, data)
    cb('ok')
end)

RegisterNuiCallback('bossmenuaction', function(data, cb)
    if not data.type then return end
    local money = lib.callback.await('jobcreator:bossmenuaction', false, data)
    cb(money)
end)

RegisterNuiCallback('setf6action', function(data, cb)
    debugprint("Try to set F6 action with data: " .. json.encode(data))
    lib.callback.await('jobcreator:setf6action', false, data)
    cb('ok')
end)

local function ClearJobPoints()
    for _, point in pairs(jobPoints) do
        if point.remove then point:remove() end
    end
    jobPoints = {}
end

function UpdateJobBlips(jobData)
    for _, blip in pairs(jobBlips) do
        RemoveBlip(blip)
    end
    jobBlips = {}
    ClearJobPoints()
    
    if not jobData then return end

    local locations = {
        bossmenu = jobData.bossmenu and json.decode(jobData.bossmenu),
        armory = jobData.armory and json.decode(jobData.armory),
        garage = jobData.garage and json.decode(jobData.garage),
        wardrobe = jobData.wardrobe and json.decode(jobData.wardrobe)
    }

    local function CreateLocationMarker(coords, sprite, color, name, type)
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, sprite)
        SetBlipColour(blip, color)
        SetBlipAsShortRange(blip, true)
        SetBlipScale(blip, 0.7)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(name)
        EndTextCommandSetBlipName(blip)
        table.insert(jobBlips, blip)

        local point = lib.points.new({
            coords = vector3(coords.x, coords.y, coords.z),
            distance = 2.0,
            onEnter = function()
                lib.showTextUI(('[E] - %s'):format(name))
            end,
            onExit = function()
                lib.hideTextUI()
            end,
            nearby = function()
                DrawMarker(2, coords.x, coords.y, coords.z, 0.0,0.0,0.0,0.0,0.0,0.0, 0.5,0.5,0.5, 25,55,175, 175,true,true,0,false,nil,nil,false)
                if IsControlJustReleased(0, 38) then
                    _G["Open"..type](jobData)
                end
            end
        })
        table.insert(jobPoints, point)
    end

    if locations.bossmenu and type(locations.bossmenu) == 'table' then
        CreateLocationMarker(locations.bossmenu, 351, 40, ("%s - Boss Menu"):format(jobData.label), "bossmenu")
    end

    if locations.armory and type(locations.armory) == 'table' then
        CreateLocationMarker(locations.armory, 175, 3, ("%s - Armory"):format(jobData.label), "armory")
    end

    if locations.garage and type(locations.garage) == 'table' then
        CreateLocationMarker(locations.garage, 50, 30, ("%s - Garage"):format(jobData.label), "garage")
    end

    if locations.wardrobe and type(locations.wardrobe) == 'table' then
        CreateLocationMarker(locations.wardrobe, 366, 4, ("%s - Wardrobe"):format(jobData.label), "wardrobe")
    end
end

function Opengarage(job)
    if vehicle then
        DeleteEntity(vehicle)
        vehicle = nil
        return
    end

    lib.callback('jobcreator:getvehicles', false, function(vehicles)
        local options = {}
        for i, v in ipairs(vehicles) do
            table.insert(options, {
                title = v.label,
                onSelect = function()
                    local coords = json.decode(job.garage)
                    lib.requestModel(v.model)
                    while not HasModelLoaded(v.model) do
                        Wait(100)
                    end
                    vehicle = CreateVehicle(GetHashKey(v.model), coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    SetModelAsNoLongerNeeded(v.model)
                end
            })
        end
        lib.registerContext({
            id = 'garage',
            title = "Garage",
            options = options
        })
        lib.showContext('garage')
    end, job.name)
end

function Openbossmenu(job)
    if ESX.PlayerData.job.name ~= job.name or ESX.PlayerData.job.grade_name ~= "boss" then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000) end 
    lib.callback('jobcreator:getbossmenudata', false, function(members, label, money)
        JOBCREATOR.Language[JOBCREATOR.lang].ui.BOSSMENULABEL = (JOBCREATOR.Language[JOBCREATOR.lang].ui.BOSSMENULABEL):format(label)
        SendNUIMessage({
            type = 'bossmenu',
            members = members,
            label = label,
            larryage = JOBCREATOR.Language[JOBCREATOR.lang].ui,
            maxgrade = ESX.PlayerData.job.grade,
            money = money
        })
    end, job.name)
    SetNuiFocus(true, true)
end

function Openwardrobe()
    TriggerEvent("illenium-appearance:client:openOutfitMenu")
end

function Openarmory(job)
    if ESX.PlayerData.job.name ~= job.name then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000) end
    TriggerServerEvent('jobcreator:stashnigger', job.name)
end

CreateThread(function()
    while true do
        Wait(5000)
        lib.callback("jobcreator:getplaces", false, UpdateJobBlips)
    end
end)

local cuffInfo = {
    pos = vec3(0.0, 0.07, 0.03),
    rot = vec3(10.0, 115.0, -65.0)
}
local handcuffed = false
local handucff
local isEscorting = false
local function playAnim(ped, dict, anim, duration, flag)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or -1, flag or 49, 0, false, false, false)
end
lib.callback.register("jobcreator:iscuffed", function()
    return handcuffed
end)

RegisterNetEvent("jobcreator:coordtocuff", function(otherPlayerId)
    local ped = PlayerPedId()
    local copPed = GetPlayerPed(GetPlayerFromServerId(otherPlayerId))
    local pedCoords = GetEntityCoords(ped)
    local copCoords = GetEntityCoords(copPed)
    if #(pedCoords - copCoords) > 3.0 then 
        return 
    end
    local copCoords = GetEntityCoords(copPed)
    local copHeading = GetEntityHeading(copPed)
    
    local offsetCoords = GetOffsetFromEntityInWorldCoords(copPed, 0.0, 1.2, 0.0)
    
    SetEntityCoords(ped, offsetCoords.x, offsetCoords.y, copCoords.z)
    SetEntityHeading(ped, copHeading)
end)

RegisterNetEvent("jobcreator:cufftry", function(iscop, sus)
    local targetSrc = GetPlayerFromServerId(source)
    local targetPed = GetPlayerPed(targetSrc)
    local ped = PlayerPedId()
    if #(GetEntityCoords(ped) - GetEntityCoords(targetPed)) > 3.0 then
        return
    end
    if handcuffed then
        playAnim(PlayerPedId(), "mp_arresting", "b_uncuff", 3500, 3) 
        Wait(3800)
        SetEnableHandcuffs(PlayerPedId(), false)
        DisablePlayerFiring(PlayerPedId(), false)
        SetPedCanPlayGestureAnims(PlayerPedId(), true)
        ClearPedTasksImmediately(PlayerPedId())
        ClearPedSecondaryTask(PlayerPedId())
        DeleteEntity(handucff)
        handcuffed = false
        TerminateThread("handcuff")
        Wait(200)
        ClearPedTasksImmediately(PlayerPedId())
        ClearPedTasks(PlayerPedId())
        ClearPedSecondaryTask(PlayerPedId())
        TriggerEvent('skinchanger:getSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
            TriggerEvent('esx:restoreLoadout')
        end)
        return
    elseif sus then
        playAnim(PlayerPedId(), "mp_arresting", "a_uncuff", 3500, 3) 
        sus = false
        return
    elseif iscop and not sus then
        playAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 3500, 3) 
        return
    elseif not iscop then
        playAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3500, 3) 
    end
    local success = lib.skillCheck({'easy', 'easy', 'medium', 'hard'})
    if success then
        return
    else
        handcuffed = true
        playAnim(PlayerPedId(), "mp_arresting", "idle")
        local position = cuffInfo
        local pos, rot = position.pos, position.rot
        RequestModel(`p_cs_cuffs_02_s`)
        while not HasModelLoaded(`p_cs_cuffs_02_s`) do Wait(10) end 
        handucff = CreateObject(`p_cs_cuffs_02_s`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(handucff, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x49D9), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
        SetEnableHandcuffs(PlayerPedId(), true)
        DisablePlayerFiring(PlayerPedId(), true)
        SetPedCanPlayGestureAnims(PlayerPedId(), false)

        CreateThread(function(handcuff)
            while handcuffed do
                Wait(0)
                for _, control in ipairs({22, 23, 24, 25, 36, 45, 49, 75, 59, 63, 64, 140, 141}) do
                    DisableControlAction(0, control, true)
                end
                if not IsEntityPlayingAnim(PlayerPedId(), 'mp_arresting', 'idle', 49) then
                    playAnim(PlayerPedId(), "mp_arresting", "idle")
                end
            end
        end)
    end
end)

RegisterNetEvent('jobcreator:drag', function(copSource)
    local playerPed = cache.ped
    local copPed = GetPlayerPed(GetPlayerFromServerId(copSource))
    if #(GetEntityCoords(playerPed) - GetEntityCoords(copPed)) > 3.0 then
        return
    end
    if DoesEntityExist(copPed) then
        Entity(playerPed).state:set('dragged', true, true)
        AttachEntityToEntity(playerPed, copPed, 11816, -0.16, 0.55, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        SetEntityCollision(playerPed, false, false)
        SetEntityInvincible(playerPed, true)
        SetPedCanBeTargetted(playerPed, false)
    end
end)

RegisterNetEvent('jobcreator:dragStop', function()
    local playerPed = cache.ped
    DetachEntity(playerPed, true, true)
    SetEntityCollision(playerPed, true, true)
    SetEntityInvincible(playerPed, false)
    SetPedCanBeTargetted(playerPed, true)
    if handcuffed then playAnim(playerPed, "mp_arresting", "idle") end
end)

RegisterNetEvent('jobcreator:dragStart', function(target)
    local playerPed = cache.ped
    local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

    if #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed)) > 3.0 then
        return
    end
    Entity(playerPed).state:set('dragging', target, true)
    playAnim(playerPed, "amb@world_human_drinking@coffee@female@base", "base")
    lib.showTextUI("[E] - Elengedés", { position = "right-center", icon = 'handcuffs' })
    CreateThread(function()
        while true do 
            Wait(0)
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent("jobcreator:dragStop", target)
                Wait(200)
                ClearPedTasksImmediately(PlayerPedId())
                ClearPedTasks(PlayerPedId())
                ClearPedSecondaryTask(PlayerPedId())
                lib.hideTextUI()
                break
            end
        end
    end)
end)

RegisterNetEvent('jobcreator:getinveh', function()
    local playerPed = cache.ped
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

    if closestVehicle then
        if IsPedInAnyVehicle(playerPed, false) then
            TaskLeaveVehicle(playerPed, closestVehicle, 0)
        else
            for _, seat in ipairs({0, 1, 2, 3, 4, 6}) do
                if IsVehicleSeatFree(closestVehicle, seat) then
                    TaskEnterVehicle(playerPed, closestVehicle, -1, seat, 1.0, 1, 0)
                    return
                end
            end
        end
    end
end)

RegisterNetEvent('jobcreator:getinveh', function()
    local playerPed = cache.ped
    local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)

    if closestVehicle then
        if IsPedInAnyVehicle(playerPed, false) then
            TaskLeaveVehicle(playerPed, closestVehicle, 0)
        else
            if IsPedInAnyVehicle(playerPed, false) then
                TaskLeaveVehicle(playerPed, closestVehicle, 0)
            else
                for _, seat in ipairs({0, 1, 2}) do
                    if IsVehicleSeatFree(closestVehicle, seat) then
                        TaskEnterVehicle(playerPed, closestVehicle, -1, seat, 1.0, 1, 0)
                        return
                    end
                end
            end
        end
    end
end)

function PlaceObject(prop, icon)
    local modelName = prop
    local playerPed = PlayerPedId()
    local forwardVector = GetEntityForwardVector(playerPed)
    local playerCoords = GetEntityCoords(playerPed)

    if not IsModelInCdimage(modelName) then
        return
    end

    RequestModel(modelName)
    while not HasModelLoaded(modelName) do
        Wait(100)
    end

    local propCoords = vector3(playerCoords.x + forwardVector.x * 1.5, playerCoords.y + forwardVector.y * 1.5, playerCoords.z)
    local prop = CreateObjectNoOffset(modelName, propCoords.x, propCoords.y, propCoords.z, false, false, false)
    SetEntityCollision(prop, false, false)
    SetEntityAlpha(prop, 200, false)
    FreezeEntityPosition(prop, true)
    local editing = true

    SetEntityVisible(prop, true, false)
    PlaceObjectOnGroundProperly(prop)
    lib.showTextUI(JOBCREATOR.Language[JOBCREATOR.lang].prop_rotate)
    SetEntityDrawOutline(prop, true)

        Citizen.CreateThread(function()
        while editing do
            Citizen.Wait(0)
            local x, y, z = table.unpack(GetEntityCoords(prop))
            local heading = GetEntityHeading(prop)
            local playerHeading = GetEntityHeading(playerPed)
            local rad = math.rad(playerHeading)
    
            if IsControlPressed(0, 172) then
                local forwardX = -math.sin(rad) * 0.02
                local forwardY = math.cos(rad) * 0.02
                if IsControlPressed(0, 174) then
                    SetEntityCoords(prop, x + (forwardX - math.cos(rad) * 0.02), y + (forwardY - math.sin(rad) * 0.02), z)
                elseif IsControlPressed(0, 175) then
                    SetEntityCoords(prop, x + (forwardX + math.cos(rad) * 0.02), y + (forwardY + math.sin(rad) * 0.02), z)
                else
                    SetEntityCoords(prop, x + forwardX, y + forwardY, z)
                end
            end
    
            if IsControlPressed(0, 173) then
                local backwardX = math.sin(rad) * 0.02
                local backwardY = -math.cos(rad) * 0.02
                if IsControlPressed(0, 174) then
                    SetEntityCoords(prop, x + (backwardX - math.cos(rad) * 0.02), y + (backwardY - math.sin(rad) * 0.02), z)
                elseif IsControlPressed(0, 175) then
                    SetEntityCoords(prop, x + (backwardX + math.cos(rad) * 0.02), y + (backwardY + math.sin(rad) * 0.02), z)
                else
                    SetEntityCoords(prop, x + backwardX, y + backwardY, z)
                end
            end
    
            if IsControlPressed(0, 174) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
                local leftX = -math.cos(rad) * 0.02
                local leftY = -math.sin(rad) * 0.02
                SetEntityCoords(prop, x + leftX, y + leftY, z)
            end
    
            if IsControlPressed(0, 175) and not IsControlPressed(0, 172) and not IsControlPressed(0, 173) then
                local rightX = math.cos(rad) * 0.02
                local rightY = math.sin(rad) * 0.02
                SetEntityCoords(prop, x + rightX, y + rightY, z)
            end
    
            if IsControlPressed(0, 44) then
                SetEntityCoords(prop, x, y, z + 0.02)
            end
    
            if IsControlPressed(0, 38) then
                SetEntityCoords(prop, x, y, z - 0.02)
            end
    
            if IsControlPressed(0, 14) then
                SetEntityHeading(prop, heading + 1.5)
            end
    
            if IsControlPressed(0, 15) then
                SetEntityHeading(prop, heading - 1.5)
            end
    
            if IsControlJustPressed(0, 191) then
                editing = false
                PlaceObjectOnGroundProperly(prop)
                local props = CreateObjectNoOffset(modelName, GetEntityCoords(prop), true, false, false)
                SetEntityHeading(props, GetEntityHeading(prop))
                DeleteObject(prop) 
                SetEntityCollision(props, true, true)
                SetEntityVisible(props, true, true)
                FreezeEntityPosition(props, false)
                SetObjectAsNoLongerNeeded(prop)
            
                lib.hideTextUI()
                propCoords = GetEntityCoords(props)
                table.insert(obj, props)
                local point = lib.points.new({
                    coords = propCoords,
                    distance = 1.5,
                    onEnter = function()
                        lib.showTextUI(CJOBCREATOR.Language[JOBCREATOR.lang].prop_delete, {
                            position = "right-center",
                            icon = icon
                        })
                    end,
                    onExit = function()
                        lib.hideTextUI()
                    end
                })
                function point:nearby()
                    if IsControlJustReleased(0, 38) then
                        SetEntityAsMissionEntity(props, false, false) 
                        for i, v in ipairs(obj) do
                            if v == props then
                                table.remove(obj, i)
                                break
                            end
                        end
                        DeleteEntity(props)
                        DeleteObject(props)
                        self:remove()
                        lib.hideTextUI()
                    end
                end
            end
        end
    end)
end

RegisterKeyMapping('jobcreator', 'Job Creator', 'keyboard', JOBCREATOR.OpenKey)
RegisterKeyMapping('f6menu', 'Job Action', 'keyboard', 'f6')
