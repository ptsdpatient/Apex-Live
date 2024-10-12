<script>
    import {onMount} from 'svelte'
    import Swal from 'sweetalert2';

    let viewMode = 0;
    let isAdmin=false

    let editItem=5

    let talukaName=''    
  

    let editReference=0

    let editCameraSerialNumber=''
    let editCameraPollingStation=''

    let editEmployeeName=''
    let editEmployeeNumber=''
    let editEmployeeAdmin=false

    let editPollingStationName=''
    let editPollingStationAddress=''
    let editPollingStationTaluka=''
    let editPollingStationOperator=''

    let editTalukaName=''

    let pollingStationNumber=''
    let pollingStationOperator=''
    let pollingStationAddress=''
    let pollingStationTaluka=''


    let employeeList=[]
    let cameraList=[]
    let pollingStationList=[]
    let talukasList=[]

    let cameraPollStation=''
    let serialNumber = '';

    let employeeName=''
    let employeePassword=''
    let employeeNumber=''
    let employeeAdmin=false



    // let url='http://apex-computers.live:2000'
    let url ='http://192.168.1.15:2000'

    let token


    const getToken = () => {
        return localStorage.getItem('authToken'); 
    };



    function showSuccessAlert(message) {
        Swal.fire({
            title: 'Success!',
            text: message,
            icon: 'success',
            showConfirmButton:false,
            timer: 1000, 
        });
    }






    async function fetchPollingStations() {
       
       try {
           const response = await fetch(`${url}/getPollingStation`, {
               method: 'GET',
               headers: {
                   'Authorization': `Bearer ${token}`,
                   'Content-Type': 'application/json'
               }
           });

          

           pollingStationList = await response.json();
       } catch (error) {
           console.error('Error fetching employees:', error);
           errorMessage = 'An error occurred while fetching employees.';
       }
   }

    async function fetchTalukas() {
       
        try {
            const response = await fetch(`${url}/getTalukas`, {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                const { error } = await response.json();
                errorMessage = error; // Display the error message from the server
                return;
            }

            talukasList = await response.json();
        } catch (error) {
            console.error('Error fetching employees:', error);
            errorMessage = 'An error occurred while fetching employees.';
        }
    }

    async function fetchCameras() {
        try {
            const response = await fetch(`${url}/getCameras`, {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                const { error } = await response.json();
                errorMessage = error;
                return;
            }

            cameraList = await response.json();
        } catch (error) {
            console.error('Error fetching cameras:', error);
            errorMessage = 'An error occurred while fetching cameras.';
        }
    }

    async function fetchEmployees() {
        try {
            const response = await fetch(`${url}/getEmployees`, {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                const { error } = await response.json();
                errorMessage = error; // Display the error message from the server
                return;
            }

            employeeList = await response.json();
        } catch (error) {
            console.error('Error fetching employees:', error);
            errorMessage = 'An error occurred while fetching employees.';
        }
    }



    async function registerPollingStation(){

        if (pollingStationNumber=='' || !pollingStationOperator || !pollingStationAddress || !pollingStationTaluka||pollingStationNumber==''||pollingStationOperator==''||pollingStationAddress==''||pollingStationTaluka=='') {
            alert("Missing some info for taluka");
            return;
        }

        try{

            const response = await fetch(`${url}/registerPollingStation`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                     number:pollingStationNumber,
                     operator:pollingStationOperator,
                     address:pollingStationAddress,
                     taluka:pollingStationTaluka
                })
            });

            const data = await response.json();

            if (response.ok) {
                if(data.done){
                    pollingStationNumber=''   
                    showSuccessAlert("Polling Station registered! with name : " + data.name)
                    getInfo()     
                         
                }
            } else {
                alert(data.error || 'Registeration failed');
            }

        }catch(err){

        }
    }


    async function registerTaluka(){
        if (!talukaName || talukaName=='') {
            alert("Please enter taluka name");
            return;
        }
        
        try {
            const response = await fetch(`${url}/registerTaluka`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: talukaName})
            });

            const data = await response.json();

            if (response.ok) {
                if(data.done){
                    talukaName=''
                    showSuccessAlert("Taluka registered! with name : " + data.name)
                    getInfo()          

                }
            } else {
                alert(data.error || 'Registeration failed');
            }
        } catch (error) {
            console.error('Error during registering:', error);
            alert("An error occurred during registering. Please try again.");
        }
    }


    async function registerCamera() {
        if (serialNumber=='' || cameraPollStation=='') {
            alert("Please enter all information regarding camera");
            return;
        }

        try {
            const response = await fetch(`${url}/registerCamera`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 
                    number: serialNumber,
                    poll_station: cameraPollStation,    
                }) 
            });

            const data = await response.json();

            if (response.ok) {
                if(data.done){
                    serialNumber=''
                    getInfo()
                    showSuccessAlert("Camera registered! with model number : " + data.name)
                }else {
                    alert("Camera already exists!")
                }
            } else {
                alert(data.error || 'Registeration failed');
            }
        } catch (error) {
            console.error('Error during registering:', error);
            alert("An error occurred during registering. Please try again.");
        }

        }


    async function registerEmployee(){
        if (!employeeName || !employeeNumber || !employeePassword || employeeName=='' || employeeNumber=='' || employeePassword=='') {
            alert("Please enter all name, password and number");
            return;
        }

        try {
            const response = await fetch(`${url}/registerEmployee`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: employeeName,password: employeePassword,number: employeeNumber,isAdmin:employeeAdmin}) // Assuming 'email' is used as username in the backend
            });

            const data = await response.json();

            if (response.ok) {
                if(data.done){
                    employeeName=''
                    employeePassword=''
                    employeeNumber=''
                    employeeAdmin=false
                    showSuccessAlert("Employee registered! with name : " + data.name)
                    getInfo()          

                }
            } else {
                alert(data.error || 'Registeration failed');
            }
        } catch (error) {
            console.error('Error during registering:', error);
            alert("An error occurred during registering. Please try again.");
        }
    }



    async function authenticateToken() {
        if (!token) {
            window.location = '/login'; 
            return;
        }
    
        try {
            const response = await fetch(`${url}/authenticateToken`, {
                method: 'GET',
                headers: {
                    'Authorization': `Bearer ${token}`, 
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if(data.done){
                console.log('Authenticated user:', data);
                if(data.error) window.location='/login'
                isAdmin=data.isAdmin
            }

            if (response.ok) {
                
               console.log("real")
            } else {
                alert(data.error || 'Token is invalid');
                window.location = '/login'; 
            }
        } catch (error) {
            console.error('Error during token authentication:', error);
            alert("An error occurred while authenticating the token.");
        }
    }

    async function saveChanges() {
        if(!isAdmin)return
        let info1='',info2='',info3='',info4='',infoTable=''
        switch(editItem){
            case 0:{
                info1=editCameraPollingStation
                info2=editCameraSerialNumber
                infoTable='cameras'
            }break;
            case 1:{
                info1=editEmployeeName
                info2=editEmployeeNumber
                info3=editEmployeeAdmin
                infoTable='employees'

            }break;
            case 2:{
                info1=editPollingStationName
                info2=editPollingStationAddress
                info3=editPollingStationTaluka
                info4=editPollingStationOperator
                infoTable='polling_stations'
            }break;
            case 3:{
                info1=editTalukaName
                infoTable='taluka'
            }break;

        }

        
        try {
            const response = await fetch(`${url}/editItem`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`, 
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                     info1: info1,
                     info2: info2,
                     info3: info3,
                     info4: info4,
                     table:infoTable,
                     reference: editReference
                    }) 

            });

            const data = await response.json();

            if(data.done){
                editItem=5
                showSuccessAlert("Item Altered! : " + data.info)
                getInfo(false)    
            }

            if (response.ok) {
                
               console.log("real")
            } else {
                alert(data.error || 'Token is invalid');
                window.location = '/login'; 
            }
        } catch (error) {
            console.error('Error during token authentication:', error);
            alert("An error occurred while authenticating the token.");
        }
    }



            async function deleteItem() {
                if(!isAdmin)return

                let infoTable=''
                switch(editItem){
                    case 0:{
                        
                        infoTable='cameras'
                    }break;
                    case 1:{
                        
                        infoTable='employees'

                    }break;
                    case 2:{
                        
                        infoTable='polling_stations'
                    }break;
                    case 3:{
                       
                        infoTable='taluka'
                    }break;

                }


                try {
                    const response = await fetch(`${url}/deleteItem`, {
                        method: 'POST',
                        headers: {
                            'Authorization': `Bearer ${token}`, 
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            table:infoTable,
                            reference: editReference
                            }) 

                    });

                    const data = await response.json();

                    if(data.done){
                        editItem=5
                        showSuccessAlert("Item Deleted! : " + data.info)
                        getInfo(false)    
                    }

                    if (response.ok) {
                        
                    console.log("real")
                    } else {
                        alert(data.error || 'Token is invalid');
                        window.location = '/login'; 
                    }
                } catch (error) {
                    console.error('Error during token authentication:', error);
                    alert("An error occurred while authenticating the token.");
                }
                }


   

    function getInfo(showDialogue){
        fetchPollingStations()
        fetchEmployees()
        fetchTalukas()
        fetchCameras()
        if(showDialogue)showSuccessAlert('Fetched info successful!')
    }

    function openCamera(camera){
        editCameraSerialNumber=camera.serial_number
        editCameraPollingStation=camera.polling_station
        editItem=0;
        editReference=camera.camera_id
    }

    function openEmployee(employee){
        editEmployeeName=employee.full_name
        editEmployeeNumber=employee.phone_number
        editEmployeeAdmin=employee.is_admin
        editItem=1;
        editReference=employee.id

    }
    function openPollingStation(station){
        editPollingStationName=station.polling_station
        editPollingStationAddress=station.polling_address
        editPollingStationTaluka=station.taluka_name
        editPollingStationOperator=station.operator_name
        editItem=2;
        editReference=station.polling_station_id
    }

    function openTaluka(taluka){
        editTalukaName=taluka.taluka
        editItem=3;
        editReference=taluka.id
    }

    

    onMount(()=>{
        token=getToken()
        authenticateToken();
        getInfo()
        showSuccessAlert('Login successful!')
    })
</script>


<div class="{editItem==0?"flex":"hidden"} p-10 flex-col items-center fixed z-20 bg-black bg-opacity-70" style="height:100%;width:100vw">
    <div class="w-2/3 bg-gray-100 mx-auto rounded-xl">
        <div class="w-full flex flex-row justify-between">
            <div class="text-5xl w-full flex flex-row justify-center mt-3">
                Edit Camera
            </div>
            <button on:click={()=>{editItem=5}} class="mt-3 px-7 py-3 text-red-500 text-4xl">❌</button>
        </div>
        <div style="max-height:70vh;" class="overflow-y-auto flex flex-col mx-auto w-2/3 gap-3 text-2xl my-10 bg-gray-300 rounded-xl">
            
            <div class="ml-10 mt-5 my-2">Polling Station :</div>
            
                <select bind:value={editCameraPollingStation} class="ml-7 w-3/4 px-3 py-2 rounded-xl">
                    {#each pollingStationList as poll}
                        <option value={poll.polling_station}>
                            {poll.polling_station}
                        </option>
                    {/each}
                </select>            
            <div class="ml-10 mt-5 my-2">Serial Number :</div>
            <input bind:value={editCameraSerialNumber} class="border-gray-500 border-1  ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Serial Number">
            
            <div class="flex flex-row gap-10 w-2/3 justify-around mx-auto">
                <button on:click={deleteItem} class=" mx-auto mt-10 mb-10 bg-white  bg-red-500 px-7 py-2 rounded-xl text-red-700 transition-all transform duration-300 hover:bg-red-500  hover:shadow-xl hover:text-white">Delete Item</button>
                <button on:click={saveChanges} class=" mx-auto mt-10 mb-10 bg-white  bg-blue-500 px-7 py-2 rounded-xl text-blue-700 transition-all transform duration-300 hover:bg-blue-500  hover:shadow-xl hover:text-white">Save Changes</button>
                
            </div>
        </div>
    </div>
</div>




<div class="{editItem==1?"flex":"hidden"} p-10 flex-col items-center fixed z-20 bg-black bg-opacity-70" style="height:100%;width:100vw">
    <div class="w-2/3 bg-gray-100 mx-auto rounded-xl">
        <div class="w-full flex flex-row justify-between">
            <div class="text-5xl w-full flex flex-row justify-center mt-3">
                Edit Employee
            </div>
            <button on:click={()=>{editItem=5}} class="mt-3 px-7 py-3 text-red-500 text-4xl">❌</button>
        </div>
        <div style="max-height:70vh;" class="overflow-y-auto flex flex-col mx-auto w-2/3 gap-3 text-2xl my-10 bg-gray-300 rounded-xl">
            
            <div class="ml-10 mt-5 my-2">Employee Name :</div>
            <input bind:value={editEmployeeName} class="border-gray-500 border-1 ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Employee Name">
            <div class="ml-10 mt-5 my-2">Phone Number :</div>
            <input bind:value={editEmployeeNumber} class="border-gray-500 border-1  ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Mobile Number">
            <div class="flex flex-row items-center w-full justify-center my-5 gap-5">
                <div>Is Admin?</div> 
                <input class="transform scale-[2]" bind:checked={editEmployeeAdmin} type="checkbox">
            </div>
            <div class="flex flex-row gap-10 w-2/3 justify-around mx-auto">
                <button on:click={deleteItem} class=" mx-auto mt-10 mb-10 bg-white  bg-red-500 px-7 py-2 rounded-xl text-red-700 transition-all transform duration-300 hover:bg-red-500  hover:shadow-xl hover:text-white">Delete Item</button>
                <button on:click={saveChanges} class=" mx-auto mt-10 mb-10 bg-white  bg-blue-500 px-7 py-2 rounded-xl text-blue-700 transition-all transform duration-300 hover:bg-blue-500  hover:shadow-xl hover:text-white">Save Changes</button>
            </div>
        </div>
    </div>
</div>


<div class="{editItem==2?"flex":"hidden"} p-10 flex-col items-center fixed z-20 bg-black bg-opacity-70" style="height:100%;width:100vw">
    <div class="w-2/3 bg-gray-100 mx-auto rounded-xl">
        <div class="w-full flex flex-row justify-between">
            <div class="text-5xl w-full flex flex-row justify-center mt-3">
                Edit Polling Station
            </div>
            <button on:click={()=>{editItem=5}} class="mt-3 px-7 py-3 text-red-500 text-4xl">❌</button>
        </div>


        <div style="max-height:70vh;" class="flex overflow-y-auto flex-col mx-auto w-2/3 gap-3 text-2xl my-10 bg-gray-300 rounded-xl">
            
            <div class="ml-10 mt-5 my-2">Polling Station :</div>
            <input bind:value={editPollingStationName} class="border-gray-500 border-1 ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Employee Name">
            <div class="ml-10 mt-5 my-2">Polling Station Address :</div>
            <input bind:value={editPollingStationAddress} class="border-gray-500 border-1  ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Mobile Number">
            
        
            <div class="ml-10 mt-5 my-2">Taluka :</div>
        
            <select bind:value={editPollingStationTaluka} class="ml-7 w-3/4 px-3 py-2 rounded-xl">
                {#each talukasList as taluka}
                    <option value={taluka.taluka}>
                        {taluka.taluka}
                    </option>
                {/each}
            </select>   

            <div class="ml-10 mt-5 my-2">Operator :</div>
        
            <select bind:value={editPollingStationOperator} class="ml-7 w-3/4 px-3 py-2 rounded-xl">
                {#each employeeList as employee}
                    <option value={employee.full_name}>
                        {employee.full_name}
                    </option>
                {/each}
            </select>  


            <div class="flex flex-row gap-10 w-2/3 justify-around mx-auto">
                <button on:click={deleteItem} class=" mx-auto mt-10 mb-10 bg-white  bg-red-500 px-7 py-2 rounded-xl text-red-700 transition-all transform duration-300 hover:bg-red-500  hover:shadow-xl hover:text-white">Delete Item</button>
                <button on:click={saveChanges} class=" mx-auto mt-10 mb-10 bg-white  bg-blue-500 px-7 py-2 rounded-xl text-blue-700 transition-all transform duration-300 hover:bg-blue-500  hover:shadow-xl hover:text-white">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<div class="{editItem==3?"flex":"hidden"} p-10 flex-col items-center fixed z-20 bg-black bg-opacity-70" style="height:100%;width:100vw">
    <div class="w-2/3 bg-gray-100 mx-auto rounded-xl">
        <div class="w-full flex flex-row justify-between">
            <div class="text-5xl w-full flex flex-row justify-center mt-3">
                Edit Taluka
            </div>
            <button on:click={()=>{editItem=5}} class="mt-3 px-7 py-3 text-red-500 text-4xl">❌</button>
        </div>
        <div style="max-height:70vh;" class="overflow-y-auto flex flex-col mx-auto w-2/3 gap-3 text-2xl my-10 bg-gray-300 rounded-xl">
            
            <div class="ml-10 mt-5 my-2">Taluka Name :</div>
            <input bind:value={editTalukaName} class="border-gray-500 border-1 ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Employee Name">
            
            <div class="flex flex-row gap-10 w-2/3 justify-around mx-auto">
                <button on:click={deleteItem} class=" mx-auto mt-10 mb-10 bg-white  bg-red-500 px-7 py-2 rounded-xl text-red-700 transition-all transform duration-300 hover:bg-red-500  hover:shadow-xl hover:text-white">Delete Item</button>
                <button on:click={saveChanges} class=" mx-auto mt-10 mb-10 bg-white  bg-blue-500 px-7 py-2 rounded-xl text-blue-700 transition-all transform duration-300 hover:bg-blue-500  hover:shadow-xl hover:text-white">Save Changes</button>
            </div>
        </div>
    </div>
</div>

<div class="flex flex-col bg-gray-200" style="min-height:200svh;width:100%">
    <div class="w-full  h-full rounded-xl  text-2xl mb-24">
        <div class="w-full fixed bg-white bg-opacity-30 py flex flex-row justify-between px-10 py-5 z-10 backdrop-blur-xl ">
            <div class=" flex flex-row gap-5  pl-5 ml-10">
                <button on:click={()=>{viewMode=0}} class="bg-{viewMode==0?"green-700":"transparent"} px-7 order-1 py-2 transform hover:scale-105 duration-300 transition-all rounded-xl text-{viewMode==0?"white":"black"} transition-all transform duration-300 {viewMode==0?"hover:bg-green-600 hover:shadow-xl hover:scale-105 text-white":""}">Cameras</button>
                <button on:click={()=>{viewMode=2}} class="bg-{viewMode==2?"purple-700":"transparent"} px-7 order-2 py-2 transform hover:scale-105 duration-300 transition-all rounded-xl text-{viewMode==2?"white":"black"} transition-all transform duration-300 {viewMode==2?"hover:bg-purple-600  hover:shadow-xl hover:scale-105 text-white":""}">Employees</button>
                {#if isAdmin}
                    <button on:click={()=>{viewMode=1}} class="bg-{viewMode==1?"orange-500":"transparent"} px-7 order-0 transform hover:scale-105 duration-300 transition-all py-2 rounded-xl text-{viewMode==1?"white":"black"} transition-all transform duration-300 {viewMode==1?"hover:bg-orange-400  hover:shadow-xl hover:scale-105 text-white":""}">Register</button>
                {/if}
                <button on:click={()=>{viewMode=3}} class="bg-{viewMode==3?"yellow-500":"transparent"} px-7 order-3 py-2 transform hover:scale-105 duration-300 transition-all rounded-xl text-{viewMode==3?"white":"black"} transition-all transform duration-300 {viewMode==3?"hover:bg-yellow-500  hover:shadow-xl hover:scale-105 text-white":""}">Polling Stations</button>
                <button on:click={()=>{viewMode=4}} class="bg-{viewMode==4?"red-500":"transparent"} px-7 order-4 py-2 transform hover:scale-105 duration-300 transition-all rounded-xl text-{viewMode==4?"white":"black"} transition-all transform duration-300 {viewMode==4?"hover:bg-red-500  hover:shadow-xl hover:scale-105 text-white":""}">Talukas</button>
            </div>
            
            <button on:click={getInfo} class="bg-pink-500 mr-10 px-7 order-4 py-2 rounded-xl transform hover:scale-105 duration-300 transition-all text-white transition-all transform duration-300 hover:bg-pink-500  hover:shadow-xl hover:scale-105 text-white">↻ fetch data</button>

           
        </div>

        <div class="w-full flex flex-row h-auto mt-24 px-12">
            <div class="w-full rounded-xl  flex flex-col h-auto text-2xl mt-10 ">
                {#if viewMode==0}
                    
                
                <div class="overflow-x-auto rounded-xl">
                    <table class="min-w-full bg-white shadow-md rounded-lg">
                      <thead>
                        <tr class="bg-gray-800 text-white text-left">
                          <th class="py-2 px-4">Camera ID</th>
                          <th class="py-2 px-4">Serial Number</th>
                          <th class="py-2 px-4">Taluka Name</th>
                          <th class="py-2 px-4">Polling Station</th>
                          <th class="py-2 px-4">Operator</th>
                          <th class="py-2 px-4">Operator Mobile Number</th>
                          <th class="py-2 px-4">Is Active</th>
                          <th class="py-2 px-4">Polling Station Address</th>
                        </tr>
                      </thead>
                      <tbody>
                        {#each cameraList as camera}
                          <tr on:click={()=>{if(isAdmin)openCamera(camera)}} class="hover:cursor-pointer border-b border-gray-200 hover:bg-gray-100">
                            <td class="py-2 px-4">{camera.camera_id}</td>
                            <td class="py-2 px-4">{camera.serial_number}</td>
                            <td class="py-2 px-4">{camera.taluka_name}</td>
                            <td class="py-2 px-4">{camera.polling_station}</td>
                            <td class="py-2 px-4">{camera.operator_name}</td>
                            <td class="py-2 px-4">{camera.operator_phone}</td>
                            <td class="py-2 px-4">{camera.is_active ? 'Active' : 'Inactive'}</td>
                            <td class="py-2 px-4">{camera.polling_address}</td>
                          </tr>
                     
                        {/each}
                      </tbody>
                    </table>
                  </div>
                  

                {:else if viewMode==1}
                    <div class="grid grid-rows-2 grid-cols-2 w-full gap-10 rounded-xl justify-around h-full">
                        <div class=" flex bg-gray-300 flex-col p-3 rounded-3xl justify-center">
                        
                            <div class="mx-auto mt-5 mb-5 text-4xl ">Register Camera</div>

                            <div class="ml-10 mt-5 my-2">Polling Station :</div>
                                <select bind:value={cameraPollStation} class="ml-7 w-3/4 px-3 py-2 rounded-xl">
                                    {#each pollingStationList as poll}
                                        <option value={poll.polling_station}>
                                            {poll.polling_station}
                                        </option>
                                    {/each}
                                </select>
                            <div class="ml-10 mt-5 my-2">Serial Number :</div>
                            <input
                            bind:value={serialNumber} 
                            on:keydown={(event) => {
                                if (event.key === 'Enter') {
                                    registerCamera();
                                }
                            }} 
                            class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Serial Number">
                            
                            <button on:click={registerCamera} class="w-1/4 mx-auto mt-10 mb-4  bg-{viewMode==1?"blue-500":"transparent"} px-7 py-2 rounded-xl text-{viewMode==1?"white":"black"} transition-all transform duration-300 {viewMode==1?"hover:bg-blue-500  hover:shadow-xl hover:scale-105 text-white":""}">Register</button>
                                             
                        </div>

                        <div class="overflow-y-auto bg-gray-300 flex flex-col rounded-3xl justify-center">
                            <div class="mx-auto mt-5 mb-5 text-4xl ">Register Employee</div>

                            <div class="ml-10 mt-5 my-2">Username :</div>
                            <input bind:value={employeeName} class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Username">
                            <div class="ml-10 my-2">Password :</div>
                            <input bind:value={employeePassword} class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Password">
                            <div class="ml-10 my-2">Mobile Number :</div>
                            <input bind:value={employeeNumber} class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Mobile">
                        
                            <div class="flex flex-row items-center w-full justify-center my-5 gap-5">
                                <div>Is Admin?</div> 
                                <input class="transform scale-[2]" bind:checked={employeeAdmin} type="checkbox">
                            </div>
                           
                            <button on:click={registerEmployee} class="w-1/4 mx-auto mt-2 mb-10  bg-{viewMode==1?"blue-500":"transparent"} px-7 py-2 rounded-xl text-{viewMode==1?"white":"black"} transition-all transform duration-300 {viewMode==1?"hover:bg-blue-500  hover:shadow-xl hover:scale-105 text-white":""}">Register</button>
                                   
                        </div>

                        <div class="bg-gray-300 flex flex-col p-3 rounded-3xl justify-center">
                        
                            <div class="mx-auto mt-5 mb-5 text-4xl ">Register Polling Station</div>

                            <div class="ml-10 mt-5 my-2">Polling Station :</div>
                            <input bind:value={pollingStationNumber} class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Polling Station">
                            <div class="ml-10 my-2">Operator :</div>
                            <select bind:value={pollingStationOperator} class="ml-7 w-3/4 px-3 py-2 rounded-xl">
                                {#each employeeList as employee}
                                    <option value={employee.full_name}>{employee.full_name}</option>
                                {/each}
                            </select>

                            
                            <div class="ml-10 mt-5 my-2">Taluka :</div>
                            <select bind:value={pollingStationTaluka} class="ml-7 w-3/4 px-3 py-2 rounded-xl">
                                {#each talukasList as taluka}
                                    <option value={taluka.taluka}>{taluka.taluka}</option>
                                {/each}
                            </select>
                            
                            <div class="ml-10 mt-5 my-2">Address :</div>
                            
                            <input bind:value={pollingStationAddress} class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Address">
                            
                            <button on:click={registerPollingStation} class="w-1/4 mx-auto mt-10 mb-4  bg-{viewMode==1?"blue-500":"transparent"} px-7 py-2 rounded-xl text-{viewMode==1?"white":"black"} transition-all transform duration-300 {viewMode==1?"hover:bg-blue-500  hover:shadow-xl hover:scale-105 text-white":""}">Register</button>
                                             
                        </div>



                        
                        <div class="overflow-y-auto bg-gray-300 flex flex-col rounded-3xl justify-center">
                            <div class="mx-auto mt-5 mb-5 text-4xl ">Register Taluka</div>

                            <div class="ml-10 mt-5 my-2">Taluka Name :</div>
                            <input bind:value={talukaName} class="ml-7 w-3/4 px-3 py-2 rounded-xl" placeholder="Taluka Name">
                                                      
                            <button on:click={registerTaluka} class="w-1/4 mx-auto mt-10 mb-10  bg-{viewMode==1?"blue-500":"transparent"} px-7 py-2 rounded-xl text-{viewMode==1?"white":"black"} transition-all transform duration-300 {viewMode==1?"hover:bg-blue-500  hover:shadow-xl hover:scale-105 text-white":""}">Register</button>
                                   
                        </div>
                    </div>
                    
                {:else if viewMode==2}
                    
                <div class="overflow-x-auto rounded-xl">
                    <table class="min-w-full bg-white shadow-md rounded-xl">
                      <thead>
                        <tr class="bg-gray-800 text-white text-left">
                          <th class="py-2 px-4">ID</th>
                          <th class="py-2 px-4">Full Name</th>
                          <th class="py-2 px-4">Phone Number</th>
                          <th class="py-2 px-4">Admin Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {#each employeeList as employee (employee.id)}
                          <tr on:click={()=>{if(isAdmin)openEmployee(employee)}} class="border-b border-gray-200 hover:bg-gray-100 hover:cursor-pointer">
                            <td class="py-2 px-4">{employee.id}</td>
                            <td class="py-2 px-4">{employee.full_name}</td>
                            <td class="py-2 px-4">{employee.phone_number}</td>
                            <td class="py-2 px-4">{employee.is_admin ? 'Admin' : 'User'}</td>
                          </tr>
                        {/each}
                      </tbody>
                    </table>
                  </div>



                {:else if viewMode==3}

                <div class="overflow-x-auto  rounded-xl">
                    <table class="min-w-full bg-white shadow-md rounded-lg">
                      <thead>
                        <tr class="bg-gray-800 text-white text-left">
                          <th class="py-2 px-4">Polling Station ID</th>
                          <th class="py-2 px-4">Polling Station Name</th>
                          <th class="py-2 px-4">Address</th>
                          <th class="py-2 px-4">Taluka</th>
                          <th class="py-2 px-4">Operator</th>
                        </tr>
                      </thead>
                      <tbody>
                        {#each pollingStationList as station (station.polling_station_id)}
                          <tr on:click={()=>{if(isAdmin)openPollingStation(station)}} class="hover:cursor-pointer border-b border-gray-200 hover:bg-gray-100">
                            <td class="py-2 px-4">{station.polling_station_id}</td>
                            <td class="py-2 px-4">{station.polling_station}</td>
                            <td class="py-2 px-4">{station.polling_address}</td>
                            <td class="py-2 px-4">{station.taluka_name}</td>
                            <td class="py-2 px-4">{station.operator_name}</td>
                          </tr>
                        {/each}
                      </tbody>
                    </table>
                  </div>

                
                {:else if viewMode==4}

                <div class="overflow-x-auto  rounded-xl">
                    <table class="min-w-full bg-white shadow-md rounded-lg">
                      <thead>
                        <tr class="bg-gray-800 text-white text-left">
                          <th class="py-2 px-4">Taluka ID</th>
                          <th class="py-2 px-4">Taluka Name</th>
                        </tr>
                      </thead>
                      <tbody>
                        {#each talukasList as taluka (taluka.id)}

                          <tr on:click={()=>{if(isAdmin)openTaluka(taluka)}} class="hover:cursor-pointer border-b border-gray-200 hover:bg-gray-100">
                            <td class="py-2 px-4">{taluka.id}</td>
                            <td class="py-2 px-4">{taluka.taluka}</td>
                          </tr>
                        
                        {/each}
                      </tbody>
                    </table>
                  </div>


                {/if}
            </div>
        </div>
    </div>
</div>
