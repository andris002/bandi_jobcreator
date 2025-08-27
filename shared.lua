JOBCREATOR = {}

JOBCREATOR.DEBUG = false
JOBCREATOR.OpenKey = "F10"

JOBCREATOR.admingroupcanaccess = {
    "admin",
    "owner"
}

JOBCREATOR.lang = 'en' -- hu en

JOBCREATOR.Language = {
    ['hu'] = {
        noperm = "Nincs jogod",
        nodata = "Nincs elég adat megadva!",
        successjobcreate = "Sikeres job létrehozás",
        successgradecreate = "Sikeres grade létrehozás",
        successgradedelete = "Sikeres grade törlés",
        successgradeset = "Sikeres grade állítás",
        successgradesalary = "Sikeres fizetés változtatás",
        successcarcreate = "Sikeres autó létrehozás",
        successcardelete = "Sikeres autó törlés",
        cantchangetolower = "Nem tudod kisebbre állítani",
        jobalreadyexist = "A job már létezik",
        successplaceing = "Sikeres lerakás",
        novalidjob = "A job nem létezik",
        nooxlib = "Nem elérhető az ox_lib",
        stash = "%s tároló",
        ui = {
            TITLE = "JobCreator",
            CREATE = "Job létrehozás",
            SEARCHJOB = "Job keresés...",
            CREATEJOB = "Job létrehozás",
            CREATEGRADE = "Grade létrehozás",
            NEWGRADE = "Új Grade",
            NEWJOB = "Új Job",
            RUN = "Futtatás",
            VEHICLES = "Autók",
            CREATEVEHICLE = "Jármű hozzáadása",
            EXTRAS = "Exták",
            JOBCOUNT = "Jobok száma",
            ACTIVEJOB = "Aktív jobok",
            GRADENAME = "Grade név",
            GRADELABEL = "Grade cím",
            SALARY = "Fizetés",
            JOBNAME = "Job név",
            JOBLABEL = "Job cím",
            JOBCOLOR = "Job szín",
            MODELNAME = "Modell név",
            VEHICLELABEL = "Jármű név",
            BOSSMENU = "Főnök menü",
            ARMORY = "Tároló",
            GARAGE = "Garázs",
            WARDROBE = "Öltöző",
            NOGRADE = "Nincs elérhető grade",
            SEARCHMEMBER = "Tag keresése...",
            NOCAR = "Nincs elérhető autó",
            BOSSMENULABEL = "%s - Bossmenu",
            FACTIONMONEY = "Frakció Pénz",
            DEPOSITMONEY = "Pénz berakás",
            WITHDRAWMONEY = "Pénz kivétel",
            AMOUNT = "ÖSSZEG",
        },
        noplayer = "Nem elérhető játékos",
        bossmenu = {
            successkick = "Sikeres játékos kirúgás",
            failedkick = "Sikertelen játékos kirúgás",
            successfelvetel = "Sikeresen felvetted %s-t",
            successsetjob = "Fel lettél véve ide: %s",
            kirugas = "Kirúgtak innen: %s",
            nomoney = "Nincs elég pénzed",
            successdeposit = "Sikeres pénz berakás",
            successwithdraw = "Sikeres pénz kivétel",
            promote = "Elő lettél léptetve",
            demote = "Le lettél fokozva"
        },
        actions = {
            drag = "Húzás",
            putinveh = "Beültetés",
            putoutveh = "Kivétel járműből",
            handcuff = "Bilincs",
            unhandcuff = "Bilincs levétele",
            search = "Személy átvizsgálása",
            prop = "Tárgy lerakása", 
            F6MENU = "Műveletek"
        }
    },
    ['en'] = {
        noperm = "You don't have permission",
        nodata = "Not enough data provided!",
        successjobcreate = "Job created successfully",
        successgradecreate = "Grade created successfully",
        successgradedelete = "Grade deleted successfully",
        successgradeset = "Grade set successfully",
        successgradesalary = "Salary changed successfully",
        successcarcreate = "Vehicle created successfully",
        successcardelete = "Vehicle deleted successfully",
        cantchangetolower = "You cannot set it to a lower value",
        jobalreadyexist = "Job already exists",
        successplaceing = "Placed successfully",
        novalidjob = "The job is not valid",
        nooxlib = "ox_lib is not available",
        stash = "%s storage",
        ui = {
            TITLE = "JobCreator",
            CREATE = "Create Job",
            SEARCHJOB = "Search job...",
            CREATEJOB = "Create Job",
            CREATEGRADE = "Create Grade",
            NEWGRADE = "New Grade",
            NEWJOB = "New Job",
            RUN = "Execute",
            VEHICLES = "Vehicles",
            CREATEVEHICLE = "Add vehicle",
            EXTRAS = "Extras",
            JOBCOUNT = "Job count",
            ACTIVEJOB = "Active jobs",
            GRADENAME = "Grade name",
            GRADELABEL = "Grade label",
            SALARY = "Salary",
            JOBNAME = "Job name",
            JOBLABEL = "Job label",
            JOBCOLOR = "Job color",
            MODELNAME = "Model name",
            VEHICLELABEL = "Vehicle name",
            BOSSMENU = "Boss menu",
            ARMORY = "Armory",
            GARAGE = "Garage",
            WARDROBE = "Wardrobe",
            NOGRADE = "No grade available",

            SEARCHMEMBER = "Search member...",
            NOCAR = "No vehicle available",
            BOSSMENULABEL = "%s - Bossmenu",
            FACTIONMONEY = "Faction money",
            DEPOSITMONEY = "Deposit money",
            WITHDRAWMONEY = "Withdraw money",
            AMOUNT = "AMOUNT",
        },
        noplayer = "Player not available",
        bossmenu = {
            successkick = "Player kicked successfully",
            failedkick = "Failed to kick player",
            successfelvetel = "You have successfully hired %s",
            successsetjob = "You were hired here: %s",
            kirugas = "You were fired from: %s",
            nomoney = "You don't have enough money",
            successdeposit = "Money deposited successfully",
            successwithdraw = "Money withdrawn successfully",
            promote = "You were promoted",
            demote = "You were demoted"
        },
        actions = {
            drag = "Drag",
            putinveh = "Put in vehicle",
            putoutveh = "Take out of vehicle",
            handcuff = "Handcuff",
            unhandcuff = "Remove handcuffs",
            search = "Search person",
            prop = "Place object", 
            F6MENU = "Actions"
        }
    },
}

JOBCREATOR.Notify = function(msg, type, time, source)
    if source then 
        lib.notify(source, {
            description = msg,
            type = type,
            duration = time
        })
    else 
        lib.notify({
            description = msg,
            type = type,
            duration = time
        })
    end
end