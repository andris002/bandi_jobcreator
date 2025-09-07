lib.callback.register('jobcreator:getData', function(source)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local jobs = MySQL.query.await('SELECT * FROM `jobs`')

    local returner = {}
    local players = ESX.GetPlayers()
    local activejobs = {}
    for a, playerId in ipairs(players) do 
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and not ContainData(activejobs, xPlayer.job.name) then 
            table.insert(activejobs, xPlayer.job.name)
        end
    end

    for k,job in ipairs(jobs) do
        local job_grade = MySQL.query.await('SELECT * FROM `job_grades` WHERE job_name = ?', {
            job.name
        })
        local members = MySQL.query.await('SELECT * FROM `users` WHERE job = ?', {
            job.name
        })
        local gradeTable = {}
        for i, grade in ipairs(job_grade) do 
            table.insert(gradeTable, {
                name = grade.name,
                label = grade.label,
                grade = grade.grade,
                salary = grade.salary
            })
        end
        table.insert(returner, {
            name = job.name,
            label = job.label,
            grade = gradeTable,
            members = #members,
            bossmenu = job.bossmenu,
            armory = job.armory,
            garage = job.garage,
            wardrobe = job.wardrobe,
            vehicles = json.decode(job.vehicles),
            color = job.color,
            money = job.money,
            actions = json.decode(job.actions),
        })
    end
    return returner, #activejobs
end)

lib.callback.register('jobcreator:createjob', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local asd = MySQL.insert.await('INSERT INTO `jobs` (name, label, color) VALUES (?, ?, ?)', {
        data.name, data.label, data.color
    })

    ESX.RefreshJobs()

    if asd then return true end
end)

lib.callback.register('jobcreator:creategrade', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end


    local asd = MySQL.insert.await('INSERT INTO `job_grades` (job_name, grade, name, label, salary) VALUES (?, ?, ?, ?, ?)', {
        data.job, data.grade.grade or 0, data.grade.name, data.grade.label, data.grade.salary
    })
    if asd then return true end
end)

lib.callback.register('jobcreator:deletegrade', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local asd = MySQL.query.await('DELETE FROM job_grades WHERE job_name = ? AND grade = ?', {
        data.name, data.grade
    })
    if asd then return true end
end)

lib.callback.register('jobcreator:updategradeSalary', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local affectedRows = MySQL.update.await('UPDATE job_grades SET salary = ? WHERE job_name = ? AND name = ? AND grade = ?', {
        data.newprice, data.jobname, data.gradename, data.gradenum
    })
    if affectedRows > 0 then return true end
end)

lib.callback.register('jobcreator:setgrade', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end
    if data.newgrade == -1 then return JOBCREATOR.Notify(JOBCREATOR.Language.cantchangetolower, "error", 3000, source) end
    local jobname = data.jobname
    local grades = MySQL.query.await('SELECT * FROM job_grades WHERE job_name = ?', {
        jobname
    })

    for _, i in ipairs(grades) do 
        if i.grade == data.newgrade then 
            MySQL.update.await('UPDATE job_grades SET grade = ? WHERE job_name = ? AND grade = ?', {
                data.gradenum, data.jobname, i.grade
            })
        end
    end

    local affectedRows = MySQL.update.await('UPDATE job_grades SET grade = ? WHERE job_name = ? AND grade = ? AND name = ?', {
        data.newgrade, data.jobname, data.gradenum, data.gradename
    })
    return affectedRows > 0
end)

lib.callback.register("jobcreator:importjob", function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    if not data.name or data.name == "" then return JOBCREATOR.Notify(JOBCREATOR.Language.nodata, "error", 3000, source) end

    local jobs = MySQL.query.await('SELECT * FROM jobs')
    for k,v in ipairs(jobs) do 
        if v.name == data.name then 
            return JOBCREATOR.Notify(JOBCREATOR.Language.jobalreadyexist, "error", 3000, source)
        end
    end

    MySQL.insert.await('INSERT INTO `jobs` (name, label, bossmenu, armory, garage, wardrobe, vehicles, color, money, actions) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        data.name, data.label, data.bossmenu, data.armory, data.garage, data.wardrobe, data.vehicles, data.color, data.money, json.encode(data.actions)
    })

    if data.grade then 
        for i, v in ipairs(data.grade) do 
            MySQL.insert.await('INSERT INTO `job_grades` (job_name, grade, name, label, salary) VALUES (?, ?, ?, ?, ?)', {
                data.name, v.grade, v.name, v.label, v.salary
            })
        end
    end

    ESX.RefreshJobs()

    return true
end)

lib.callback.register("jobcreator:createvehicle", function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local vehiclesJson = MySQL.scalar.await('SELECT vehicles FROM jobs WHERE name = ? LIMIT 1', {data.job})
    local vehicles = {}
    if vehiclesJson and vehiclesJson ~= '' then
        vehicles = json.decode(vehiclesJson)
    end
    table.insert(vehicles, {
        model = data.model,
        label = data.label
    })
    

    local affectedRows = MySQL.update.await('UPDATE jobs SET vehicles = ? WHERE name = ?', {
        json.encode(vehicles), data.job
    })
    return affectedRows > 0
end)

lib.callback.register("jobcreator:deletevehicle", function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local vehiclesJson = MySQL.scalar.await('SELECT vehicles FROM jobs WHERE name = ? LIMIT 1', {data.job})
    if not vehiclesJson or vehiclesJson == '' then
        return false
    end

    local vehicles = json.decode(vehiclesJson)
    if not vehicles or #vehicles == 0 then
        return false
    end

    local newVehicles = {}
    local found = false
    for _, vehicle in ipairs(vehicles) do
        if vehicle.model ~= data.model or vehicle.label ~= data.label then
            table.insert(newVehicles, vehicle)
        else
            found = true
        end
    end

    if not found then
        return false 
    end

    local affectedRows = MySQL.update.await('UPDATE jobs SET vehicles = ? WHERE name = ?', {
        json.encode(newVehicles), data.job
    })

    return affectedRows > 0
end)

lib.callback.register("jobcreator:place", function(source, type, job, coords)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    if type == "armory" then
        placeArmory(job, json.decode(coords))
    elseif type == "bossmenu" then
        
    elseif type == "garage" then

    elseif type == "wardrobe" then

    end

    local affectedRows = MySQL.update.await('UPDATE jobs SET '..type..' = ? WHERE name = ?', {
        coords, job
    })

    return affectedRows > 0
end)

lib.callback.register("jobcreator:getplaces", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local job = xPlayer.job.name
    local locations = MySQL.query.await('SELECT * FROM jobs WHERE name = ?', {
        job
    })

    return locations[1]
end)

lib.callback.register('jobcreator:getbossmenudata', function(source, job)
    local members = MySQL.query.await('SELECT * FROM users WHERE job = ?', {
        job
    })

    local label = MySQL.scalar.await('SELECT label FROM jobs WHERE name = ?', {
        job
    })

    local money = MySQL.scalar.await('SELECT money FROM jobs WHERE name = ?', {
        job
    })

    return members, label, money
end)

lib.callback.register('jobcreator:kickmember', function(source, id)
    local sajat = ESX.GetPlayerFromId(source)
    local player = ESX.GetPlayerFromIdentifier(id)
    if sajat.job.grade_name ~= "boss" then 
        return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) 
    end
    if player then 
        player.setJob("unemployed", 0)
        JOBCREATOR.Notify((JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.kirugas):format(sajat.job.label), "warning", 3000, player.source)
    end

    local affectedRows = MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {
        "unemployed", 0, id
    })

    return affectedRows > 0
end)

lib.callback.register('jobcreator:felvetel', function(source, data)
    local player = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromIdentifier(data.id)
    if not player then return false end
    if not target then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noplayer, "error", 3000, source) end
    if player.job.grade_name ~= "boss" then 
        return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) 
    end

    target.setJob(player.job.name, 0)
    JOBCREATOR.Notify((JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.successsetjob):format(player.job.label), "success", 3000, target.source)
    JOBCREATOR.Notify((JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.successfelvetel):format(target.getName()), "success", 3000, source)
    
    local affectedRows = MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {
        player.job.name, 0, target.identifier
    })
    return affectedRows > 0
end)

lib.callback.register('jobcreator:setnewcolor', function(source, data)
    MySQL.update.await('UPDATE jobs SET color = ? WHERE name = ?', {
        data.newcolor, data.fraki
    })
end)

lib.callback.register('jobcreator:deletejob', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local p = MySQL.query.await('SELECT identifier FROM users WHERE job = ?', {data})

    for _, id in ipairs(p) do 
        local pl = ESX.GetPlayerFromIdentifier(id.identifier)
        if pl then 
            pl.setJob('unemployed', 0, false)
        end
        MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {
            'unemployed', 0, id.identifier
        })
    end
    
    MySQL.query.await('DELETE FROM jobs WHERE name = ?', {
        data
    })

    MySQL.query.await('DELETE FROM job_grades WHERE job_name = ?', {
        data
    })

    ESX.RefreshJobs()
end)

lib.callback.register('jobcreator:updatemember', function(source, data)
    local player = ESX.GetPlayerFromId(source)
    local target = ESX.GetPlayerFromIdentifier(data.id)
    MySQL.update.await('UPDATE users SET job_grade = ? WHERE identifier = ?', {
        data.newgrade, data.id
    })
    if not player or not target then return end
    if player.job.grade_name ~= "boss" then 
        return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) 
    end

    if tonumber(target.job.grade) > tonumber(data.newgrade) then 
        JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.demote, "info", 3000, target.source)
    else 
        JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.promote, "info", 3000, target.source)
    end

    target.setJob(target.job.name, data.newgrade)
end)

lib.callback.register('jobcreator:bossmenuaction', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if xPlayer.job.grade_name ~= "boss" then 
        return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) 
    end

    local newmoney = 0
    local bossmoney = MySQL.scalar.await('SELECT money FROM jobs WHERE name = ?', {
        xPlayer.job.name
    })

    if data.type == 'deposit' then 
        local playermoney = xPlayer.getMoney()
        if playermoney < data.money then
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.nomoney, "error", 3000, source) 
            return bossmoney 
        end
        
        JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.successdeposit, "success", 3000, source)
        xPlayer.removeMoney(data.money)

        newmoney = bossmoney + data.money

    elseif data.type == 'withdraw' then
        if bossmoney < data.money then 
            JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.nomoney, "error", 3000, source) 
            return bossmoney
        end

        JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].bossmenu.successwithdraw, "success", 3000, source)
        xPlayer.addMoney(data.money)

        newmoney = bossmoney - data.money
    end

    MySQL.update.await('UPDATE jobs SET money = ? WHERE name = ?', {
        newmoney, xPlayer.job.name
    })

    return newmoney
end)

lib.callback.register('jobcreator:getvehicles', function(source, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    if xPlayer.job.name ~= job then 
        return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) 
    end
    local vehicles = MySQL.scalar.await('SELECT vehicles FROM jobs WHERE name = ?', {job})
    return json.decode(vehicles)
end)

lib.callback.register('jobcreator:setf6action', function(source, data)
    if not IsAdmin(source) then return JOBCREATOR.Notify(JOBCREATOR.Language[JOBCREATOR.lang].noperm, "error", 3000, source) end

    local b = MySQL.scalar.await('SELECT actions FROM jobs WHERE name = ?', {data.job})
    
    if not b then
        b = '{"cuff":0,"drag":0,"putInVehicle":0,"outVehicle":0,"search":0,"prop":0}'
    end

    local actions = json.decode(b)

    actions[data.action] = data.state and 1 or 0

    MySQL.update.await('UPDATE jobs SET actions = ? WHERE name = ?', {
        json.encode(actions), data.job
    })

    return true
end)

lib.callback.register('jobcreator:getf6actions', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local job = xPlayer.job.name
    local actions = MySQL.scalar.await('SELECT actions FROM jobs WHERE name = ?', {job})
    return json.decode(actions)
end)