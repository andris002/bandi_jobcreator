function IsAdmin(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end

    for i, group in ipairs(JOBCREATOR.admingroupcanaccess) do 
        if group == xPlayer.getGroup() then 
            return true
        end
    end
    return false
end

function ContainData(table, value)
    local talalt = false
    for k,v in ipairs(table) do 
        if v == value then talalt = true end
    end
    return talalt
end

function placeArmory(job, coords)
    exports.ox_inventory:RegisterStash(job, (JOBCREATOR.Language[JOBCREATOR.lang].stash):format(job), 45, 54000, nil, job, coords)
end 

RegisterNetEvent('jobcreator:stashnigger', function(name)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if xPlayer.getJob().name ~= name then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000) end
    exports.ox_inventory:forceOpenInventory(source, 'stash', name)
end)

function IsInServer(id)
    for _, playerId in ipairs(GetPlayers()) do
        if id == tonumber(playerId) then return true end
    end
    return false
end

RegisterCommand('setjob', function(source, args)
    if source ~= 0 then 
        if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end
        local target
        if args[1] == 'me' then 
            target = source
        else 
            target = tonumber(args[1])
        end

        if not IsInServer(target) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noplayer, "error", 3000, source) end
        
        local validjob = MySQL.scalar.await('SELECT `label` FROM `jobs` WHERE `name` = ? LIMIT 1', {
            args[2]
        })
        local grade = tonumber(args[3])
        local validgrade = MySQL.scalar.await('SELECT `label` FROM `job_grades` WHERE `job_name` = ? AND `grade` = ? LIMIT 1', {
            args[2], grade
        })
        if not validjob or not validgrade then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].novalidjob, "error", 3000, source) end

        local xPlayer = ESX.GetPlayerFromId(target)
        xPlayer.setJob(args[2], grade, true)

        MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {
            args[2], grade, xPlayer.identifier
        })
    end
end, false)

CreateThread(function()
    exports.oxmysql:execute([=[
        ALTER TABLE `jobs` 
        ADD COLUMN IF NOT EXISTS `bossmenu` varchar(255) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `armory` varchar(255) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `garage` varchar(255) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `wardrobe` varchar(255) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `vehicles` longtext DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `color` varchar(50) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `money` INT DEFAULT '0',
        ADD COLUMN IF NOT EXISTS `actions` longtext DEFAULT '{"cuff":0,"drag":0,"putInVehicle":0,"outVehicle":0,"search":0,"prop":0}';
    ]=])
    Wait(100)
    exports.oxmysql:execute([=[
        ALTER TABLE `job_grades`
        MODIFY COLUMN `skin_female` longtext DEFAULT '{}',
        MODIFY COLUMN `skin_male` longtext DEFAULT '{}';   
    ]=])
end)

CreateThread(function()
    local sql

    local su, res = pcall(function()
        sql = MySQL.query.await('SELECT * FROM jobs WHERE armory IS NOT NULL')
    end)

    while not su do
        Wait(1000)
        su, res = pcall(function()
            sql = MySQL.query.await('SELECT * FROM jobs WHERE armory IS NOT NULL')
        end)
    end

    for i, v in ipairs(sql) do
        local coords = json.decode(v.armory)
        placeArmory(v.name, coords)
    end
end)

RegisterNetEvent('jobcreator:cancuff', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
		TriggerClientEvent('jobcreator:coordtocuff', xTarget.source, xPlayer.source)
		TriggerClientEvent('jobcreator:cufftry', xPlayer.source, true, false)
		TriggerClientEvent('jobcreator:cufftry', xTarget.source, false, false)
		lib.callback("jobcreator:iscuffed", xTarget.source, function(bool)
			TriggerClientEvent('jobcreator:cufftry', xPlayer.source, true, bool)
		end)
end)

RegisterNetEvent('jobcreator:drag', function(target)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xTarget = ESX.GetPlayerFromId(target)
    
        TriggerClientEvent('jobcreator:drag', xTarget.source, xPlayer.source)
        TriggerClientEvent('jobcreator:dragStart', xPlayer.source, xTarget.source)
end)

RegisterNetEvent('jobcreator:dragStop', function(target)
    local xTarget = ESX.GetPlayerFromId(target)
    
        TriggerClientEvent('jobcreator:dragStop', xTarget.source)
end)

RegisterNetEvent('jobcreator:getinveh', function(target)
    local xTarget = ESX.GetPlayerFromId(target)
    
		TriggerClientEvent('jobcreator:getinveh', xTarget.source)
end)