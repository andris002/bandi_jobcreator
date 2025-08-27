const app = Vue.createApp({
    data() {
        return {
            Opened: false,
            Modal: false,
            OpenedBossMenu: false,
            LANG:{
                TITLE: "JobCreator",
                CREATE: "Create Job",
                SEARCHJOB: "Search Job",
                CREATEJOB: "Create Job",
                CREATEGRADE: "Create Grade",
                NEWGRADE: "New Grade",
                NEWJOB: "New Job",
                RUN: "Run",
                VEHICLES: "Vehicles",
                CREATEVEHICLE: "Add Vehicle",
                EXTRAS: "Extras",
                JOBCOUNT: "Job Count",
                ACTIVEJOB: "Active Jobs",
                SEARCHMEMBER: "Search Member...",
                NOGRADE: "No grade available",
                NOCAR: "No car available",
            },
            currentPage: 'home',
            openedmodal: null,
            activejobs: 0,
            jobsearch: "",
            SelectedJob: [],
            currentChart: null,
            chartSettings: "bar",
            lastopenedJobname: "",
            importjobjson:"",
            Jobs: [
                {
                    name: "police", 
                    label:"ORFK", 
                    grade:[
                        {name: "officer", label: "Officer", grade: 0, salary: 1000},
                        {name: "sergeant", label: "Sergeant", grade: 1, salary: 1500},
                        {name: "lieutenant", label: "Lieutenant", grade: 2, salary: 2000},
                        {name: "captain", label: "Captain", grade: 3, salary: 2500},
                        {name: "chief", label: "Chief", grade: 4, salary: 3000},
                    ],
                    members: 10,
                    bossmenu: {y:-1003.356201171875,z:29.1602783203125,x:420.5468444824219},
                    armory: {y:-995.9468994140625,z:29.38966560363769,x:413.3197937011719},
                    garage: {x:426.9114, y:-957.3265, z:29.2555},
                    vehicles: [
                        {
                            name: "kuruma",
                            label: "Páncél"
                        }
                    ],
                    wardrobe: {y:-980.3121948242188,z:30.71090126037597,x:424.7767333984375},
                },
                {
                    name: "ambulance", 
                    label:"Mentő", 
                    grade:[
                        {name: "trainee", label: "Trainee", grade: 0, salary: 800},
                        {name: "paramedic", label: "Paramedic", grade: 1, salary: 1200},
                        {name: "doctor", label: "Doctor", grade: 2, salary: 1800},
                        {name: "chiefdoctor", label: "Chief Doctor", grade: 3, salary: 2500},
                    ],
                    members: 9,
                    bossmenu: {y:-500.356201171875,z:29.1602783203125,x:-300.5468444824219},
                    armory: null,
                    garage: {x:-295.9114, y:-450.3265, z:29.2555},
                    vehicles: [
                        {
                            name: "ambulance",
                            label: "Ambulance"
                        }
                    ],
                    wardrobe: null,
                },
            ],
            Modals: {
                Jobdata: false,
                CreateGrade: false,
                CreateNewJob: false,
                Vehicles: false,
                CreateVehicle: false,
                JobExtras: false,
                JobActions: false,
            },
            activebossmenuselect: "members",
            bossmenumembers: [],
            membersearch: "",
            maxgrade: 0,
            factionmoney: 0,
            moneytype: null,
        }
    },
    methods: {
        RefreshFunc() {
            const send = {};
            fetch(`https://${GetParentResourceName()}/refresh`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify(send)
            })
            .then(response => response.json())
            .then(data => {
                if (data) {
                    this.Jobs = data;
                    if (this.SelectedJob) {
                        for (let x in this.Jobs) {
                            if (this.Jobs[x].name === this.lastopenedJobname){
                                this.SelectedJob = this.Jobs[x]
                                break
                            }
                        }
                    }
                }
            })
            .catch(error => {
                console.error(error);
            });
        },
        CreateJob(){
            fetch(`https://${GetParentResourceName()}/createjob`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    name: jobName.value,
                    label: jobLabel.value,
                    color: jobColor.value
                })
            }).then(response => {
                if (response.ok) {
                    jobName.value = ""
                    jobLabel.value = "" 
                    this.RefreshFunc()
                    this.CloseModal()
                }
            }).catch(error => {
                console.error(error);
            });
        },
        Run(){
            fetch(`https://${GetParentResourceName()}/importjob`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(code.value)
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                }
            }).catch(error => {
                console.error(error);
            });
        },
        CreateGrade() {
            fetch(`https://${GetParentResourceName()}/creategrade`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    job: this.SelectedJob.name,
                    grade: {
                        name: gradeName.value,
                        label: gradeLabel.value,
                        salary: gradeSalary.value,
                        grade: Math.max(...this.SelectedJob.grade.map(grade => grade.grade)) + 1
                    }
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                    this.OpenModal("Jobdata")
                    gradeName.value = ""
                    gradeLabel.value = ""
                    gradeSalary.value = ""
                }
            }).catch(error => {
                console.error(error);
            });
        },
        PlaceThing(type){
            this.closePanel()
            fetch(`https://${GetParentResourceName()}/place`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    type: type,
                    job: this.SelectedJob.name
                })
            })
            .then(response => {
                if (response.ok) {
                    // nothing :)
                }
            })
        },
        CreateVehicle(){
            // Vehiclemodel.value VehicleLabel.value
            fetch(`https://${GetParentResourceName()}/createvehicle`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    job: this.SelectedJob.name,
                    model: Vehiclemodel.value,
                    label: VehicleLabel.value
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                    this.OpenModal("Jobdata")
                    Vehiclemodel.value = ""
                    VehicleLabel.value = ""
                }
            }).catch(error => {
                console.error(error);
            });
        },
        DeleteVehicle(label, model){
             fetch(`https://${GetParentResourceName()}/deletevehicle`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    job: this.SelectedJob.name,
                    model: model,
                    label: label
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                    this.OpenModal("Jobdata")
                }
            }).catch(error => {
                console.error(error);
            });
        },
        Deletegrade(grade){
            fetch(`https://${GetParentResourceName()}/deletegrade`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    name: this.SelectedJob.name,
                    grade: grade
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                    gradeName.value = ""
                    gradeLabel.value = ""
                    gradeSalary.value = ""
                }
            }).catch(error => {
                console.error(error);
            });
        },
        UpdateSalary(grade, newValue) {
            fetch(`https://${GetParentResourceName()}/updatesalary`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    jobname: this.SelectedJob.name,
                    gradename: grade.name,
                    gradenum: grade.grade,
                    newprice: newValue
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                }
            }).catch(error => {
                console.error(error);
            });
        },
        DownGrade(grade){
            fetch(`https://${GetParentResourceName()}/setgrade`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    jobname: this.SelectedJob.name,
                    gradename: grade.name,
                    gradenum: grade.grade,
                    newgrade: grade.grade - 1
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                }
            }).catch(error => {
                console.error(error);
            });
        },
        UpGrade(grade){
            fetch(`https://${GetParentResourceName()}/setgrade`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    jobname: this.SelectedJob.name,
                    gradename: grade.name,
                    gradenum: grade.grade,
                    newgrade: grade.grade + 1
                })
            }).then(response => {
                if (response.ok) {
                    this.RefreshFunc()
                }
            }).catch(error => {
                console.error(error);
            });
        },
        OpenModal(modalname) {
            this.CloseModal()
            this.Modal = true
            this.openedmodal = modalname
            this.Modals[modalname] = true
        },
        CloseModal(){
            this.Modal = false;
            this.Modals[this.openedmodal] = false;
            this.openedmodal = null;
        },
        CreateChart() {
            if (this.currentChart) {
                this.currentChart.destroy();
            }
            
            const filteredData = this.Jobs.filter(job => job.members !== 0);
            
            const config = {
                type: this.chartSettings === 'barHorizontal' ? 'bar' : this.chartSettings,
                data: {
                    labels: filteredData.map(job => job.label),
                    datasets: [{
                        skipNull: true,
                        backgroundColor: filteredData.map(job => job.color || "#ff5722"),
                        data: filteredData.map(job => job.members)
                    }]
                },
                options: {
                    responsive: true,
                }
            };
            
            if (this.chartSettings === 'barHorizontal') {
                config.options.indexAxis = 'y';
            }
            
            this.currentChart = new Chart("chart", config);
        },
        ImportJob(item) {
            const jsonString = JSON.stringify(item, null, 4);
            
            const textArea = document.createElement("textarea");
            textArea.value = jsonString;
            document.body.appendChild(textArea);
            
            textArea.select();
            try {
                document.execCommand('copy');
            } catch (err) {
                console.error(err);
            } finally {
                document.body.removeChild(textArea);
            }
        },
        handleKeydown(event) {
            if (event.key === "Escape") {
                this.closePanel();
            }
        },
        closePanel(){
            fetch(`https://${GetParentResourceName()}/close`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            })
            .then(response => {
                if (response.ok) {
                    this.Opened = false
                    this.Modal = false
                    this.OpenedBossMenu = false
                }
            })
        },
        GenerateRandomColor() {
          const letters = '0123456789ABCDEF';
          let color = '#';
          for (let i = 0; i < 6; i++) {
              color += letters[Math.floor(Math.random() * 16)];
          }
          return color || '#FFFFFF';
        },
        RefreshMembers(){
            fetch(`https://${GetParentResourceName()}/refreshmember`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            })
            .then(response => response.json())
            .then(data => {
                this.bossmenumembers = data
            })
        },
        KickMember(id){
            fetch(`https://${GetParentResourceName()}/kick`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(id)
            })
            .then(response => {
                if (response.ok) {
                    this.RefreshMembers()
                }
            })
        },
        PlayerFelvetel(){
            fetch(`https://${GetParentResourceName()}/felvetel`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    id: playerid.value,
                    grade: playergrade.value
                })
            })
            .then(response => {
                if (response.ok) {
                    playerid.value = ""
                    playergrade.value = ""

                    this.RefreshMembers()
                }
            })
        },
        NewColor(){
            fetch(`https://${GetParentResourceName()}/setnewcolor`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    fraki: this.SelectedJob.name,
                    newcolor: newcolor.value
                })
            })
            .then(response => {
                if(response.ok){
                    this.RefreshFunc()
                    setTimeout(() => {
                        this.CreateChart()
                    }, 100);
                }
            })
        },
        TPCOORD(cord){
            fetch(`https://${GetParentResourceName()}/teleport`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(cord)
            })
            .then(response => {
                if(response.ok){
                    this.closePanel()
                }
            })
        },
        DeleteJob(name){
            fetch(`https://${GetParentResourceName()}/deletejob`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(name)
            })
            .then(response => {
                if(response.ok){
                    this.RefreshFunc()
                }
            })
        },
        UpMember(grade, id){
            fetch(`https://${GetParentResourceName()}/upmember`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    newgrade: grade + 1,
                    id: id
                })
            })
            .then(response => {
                if (response.ok) {
                    this.RefreshMembers()
                }
            })
        },
        DownMember(grade, id){
            if (grade === 0){
                this.KickMember(id)
                return
            }
            fetch(`https://${GetParentResourceName()}/downmember`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    newgrade: grade - 1,
                    id: id
                })
            })
            .then(response => {
                if (response.ok) {
                    this.RefreshMembers()
                }
            })
        },
        Putmoney(){
            const pez = Number(money.value)
            if (pez > 0){
                fetch(`https://${GetParentResourceName()}/bossmenuaction`, {
                    method: "POST",
                    body: JSON.stringify({
                        type: this.moneytype,
                        money: pez  
                    })
                })
                .then(response => response.json())
                .then(data => {
                    this.factionmoney = data
                    this.moneytype = null
                })
            }
        },
        SetAction(action) {
            fetch(`https://${GetParentResourceName()}/setf6action`, {
                method: "POST",
                body: JSON.stringify({
                    action: action,
                    state: !this.SelectedJob.actions[action],
                    job: this.SelectedJob.name
                })
            })
            .then(response => {
                if (response.ok){
                    this.RefreshFunc()
                }
            })
        }
    },
    computed: {
        GradeLister(){
            return this.SelectedJob.grade?.sort((a, b) => a.grade - b.grade)
        },
        JobSearch() {
            if (this.jobsearch === "") {
                return this.Jobs;
            }

            return this.Jobs.filter(job => {
                return job.name.toLowerCase().includes(this.jobsearch.toLowerCase()) ||
                       job.label.toLowerCase().includes(this.jobsearch.toLowerCase());
            });
        },
        MemberShow(){
           if (this.membersearch === "") {
                return this.bossmenumembers;
            }

            return this.bossmenumembers.filter(user => {
                return user.firstname.toLowerCase().includes(this.membersearch.toLowerCase()) ||
                       user.lastname.toLowerCase().includes(this.membersearch.toLowerCase());
            }); 
        }
    },
    mounted() {
        window.addEventListener("keydown", this.handleKeydown);

        window.addEventListener('message', (event) => {
            if (event.data.type === 'open') {
                this.Jobs = event.data.table
                this.Opened = true
                this.activejobs = event.data.active
                this.CreateChart()
                this.LANG = event.data.larryage
            } 

            if (event.data.type === 'bossmenu'){
                this.OpenedBossMenu = true
                this.activebossmenuselect = 'members'
                this.bossmenumembers = event.data.members
                this.LANG = event.data.larryage
                this.maxgrade = event.data.maxgrade
                this.factionmoney = event.data.money
            }
        });
    },
    beforeUnmount() {
        console.log("App is about to be unmounted");
    }
}).mount('#app');