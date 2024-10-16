<script>
    import {onMount} from 'svelte'
    import Hls from 'hls.js';
    // let url='http://apex-computers.live:2000'
    let url='http://localhost:2000'
    let token
    let interval
    let port=8080
    let ip='apex-computers.live'
    const getToken = () =>{
    return localStorage.getItem('authToken')
    }
    let showingCamera=false
    let showCameraPS=''
    let showCameraM=''
    let selectedTaluka='All'
    let selectedPollingStation='All'
    let showCameraPA=''
    let cameraList=[]
    let talukaList=[]
    let pollingStationList=[]
    let cameraIndex=0
    let selectedResolution ={
         row:"2",
         col:"3"
    };
    let cameraPerSet = Number(selectedResolution.row) * Number(selectedResolution.col)

    let slideDurationList=[3,7,12,16,20,30,35]

    let selectedDuration=3

    let resolutionList=[
        {
            r:"2",
            c:"3"
        },
        {
            r:"3",
            c:"4"
        },{
            r:"4",
            c:"6"
        },{
            r:"6",
            c:"12"
        },
    ]



    function showThisCamera(camera){
        showingCamera=true
        showCameraPS=camera.polling_station
        showCameraM=camera.serial_number
        showCameraPA=camera.polling_address
        const video = document.getElementById(`showCameraID`);
        if (!video) {
            console.error(`Video element not found for serial number: ${serialNumber}`);
            return;
        }

        const hls = new Hls();
        const sourceUrl = `http://${ip}:${port}/hls/${camera.serial_number}.m3u8`;

        console.log(`Loading HLS source: ${sourceUrl}`);
        
        if (Hls.isSupported()) {
            hls.loadSource(sourceUrl);
            hls.attachMedia(video);
            
        } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = sourceUrl;
            video.addEventListener('canplay', function () {
                video.play();
            });
        }
    }



    async function authenticateToken() {
        const token = localStorage.getItem('authToken'); 
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

            if (response.ok) {
                // Token is valid; you can proceed to the user page or show user data
                console.log('Authenticated user:', data);
                if(data.error)window.location='/login'
               
            } else {
                alert(data.error || 'Token is invalid');
                window.location = '/login'; // Redirect to login if token is invalid
            }
        } catch (error) {
            console.error('Error during token authentication:', error);
            alert("An error occurred while authenticating the token.");
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

           cameraList = await response.json();
           updateVisibleCameras()

       } catch (error) {
           console.error('Error fetching employees:', error);
           errorMessage = 'An error occurred while fetching employees.';
       }
   }

   async function fetchPolls() {
       
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

           talukaList = await response.json();
       } catch (error) {
           console.error('Error fetching employees:', error);
           errorMessage = 'An error occurred while fetching employees.';
       }
   }



    const playVideo = (serialNumber) =>{
        const video = document.getElementById(`${serialNumber}`);
        video.play().catch(error => {
                console.error(`Error playing video with ID ${id}:`, error);
        });
    }

   const initHLS = (serialNumber) => {
        const video = document.getElementById(`${serialNumber}`);
        if (!video) {
            console.error(`Video element not found for serial number: ${serialNumber}`);
            return;
        }

        const hls = new Hls();
        const sourceUrl = `http://${ip}:${port}/hls/${serialNumber}.m3u8`;

        console.log(`Loading HLS source: ${sourceUrl}`);
        
        if (Hls.isSupported()) {
            hls.loadSource(sourceUrl);
            hls.attachMedia(video);
            
            hls.on(Hls.Events.MANIFEST_PARSED, function() {
                video.play();
            });
            
        } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
            video.src = sourceUrl;
            video.addEventListener('canplay', function () {
                video.play();
            });
        }
  
};



function playCameras(){
    cameraList.forEach((camera) => {
        playVideo(camera.serial_number);
    });
}

   
   

function configureCameras(){
    cameraList.forEach((camera) => {
    initHLS(camera.serial_number);
});



}

function changeSlide() {
    cameraPerSet = Number(selectedResolution.row) * Number(selectedResolution.col);

    cameraIndex += cameraPerSet;

    // Get the total number of visible cameras based on the filters
    let visibleCamerasCount = 0;

    cameraList.forEach((camera) => {
        const matchesTaluka = selectedTaluka === "All" || camera.taluka_name === selectedTaluka;
        const matchesPollingStation = selectedPollingStation === "All" || camera.polling_station === selectedPollingStation;

        if (matchesTaluka && matchesPollingStation) {
            visibleCamerasCount++;
        }
    });

    // Reset cameraIndex if it exceeds the number of visible cameras
    if (cameraIndex >= visibleCamerasCount) {
        cameraIndex = 0;  // Loop back to the beginning
    }

    // Update the visible cameras based on the new cameraIndex
    updateVisibleCameras();



    // cameraPerSet = Number(selectedResolution.row) * Number(selectedResolution.col);

    // cameraIndex += cameraPerSet;

    // if(selectedTaluka==="All"){
    //     if (cameraIndex >= cameraList.length) {
    //         cameraIndex = 0;
    //     }
    // }else {
    //     let selectedTalukaLength = 0;
    //     cameraList.forEach((camera,index)=>{
    //         if (camera.taluka_name === selectedTaluka) {
    //             selectedTalukaLength++;
    //         }
    //     })
    //     if(cameraIndex>=slectedTalukaLength){
    //         cameraIndex=0
    //     }
    // }

    // updateVisibleCameras()
}

function updateVisibleCameras() {
    // let selectedTalukaLength = 0;
    // let selectedPollingStationLength=0

    // if (selectedTaluka !== "All") {
    //     cameraList = cameraList.map((camera, index) => {
    //             if (camera.taluka_name === selectedTaluka) {
    //                 selectedTalukaLength++;
    //                 camera.visible = (selectedTalukaLength > cameraIndex && selectedTalukaLength <= (cameraIndex + cameraPerSet));
    //             } else {
    //                 camera.visible = false;
    //             }
    //         return camera;
    //     });
    // }

    // if (selectedPollingStation !== "All") {
    //     cameraList = cameraList.map((camera, index) => {
    //             if (camera.polling_station === selectedPollingStation) {
    //                 selectedPollingStationLength++;
    //                 camera.visible = (selectedPollingStationLength > cameraIndex && selectedPollingStationLength <= (cameraIndex + cameraPerSet));
    //             } else {
    //                 camera.visible = false;
    //             }
    //         return camera;
    //     });
    // }

    // if(selectedPollingStation==="All"){
    //         cameraList = cameraList.map((camera, index) => {
    //         camera.visible = (index >= cameraIndex && index < (cameraIndex + cameraPerSet));
    //         if(camera.visible&&selectedPollingStation!="All"){
    //             camera.visible=camera.polling_station===selectedPollingStation;
    //         }
    //         return camera;
    //     }
    // );
    // }

    // if(selectedTaluka==="All"){
    //         cameraList = cameraList.map((camera, index) => {
    //         camera.visible = (index >= cameraIndex && index < (cameraIndex + cameraPerSet));
    //         if(camera.visible&&selectedTaluka!="All"){
    //             camera.visible=camera.taluka_name===selectedTaluka;
    //         }
    //         return camera;
    //     }
    // );
    // }



    let visibleCount = 0; // Tracks how many cameras are visible based on the filters

    cameraList = cameraList.map((camera, index) => {
    // Determine if the camera matches the taluka and polling station filters
    const matchesTaluka = selectedTaluka === "All" || camera.taluka_name === selectedTaluka;
    const matchesPollingStation = selectedPollingStation === "All" || camera.polling_station === selectedPollingStation;

    // Set camera visibility based on filters and current camera set (cameraPerSet)
    if (matchesTaluka && matchesPollingStation) {
        visibleCount++;
        camera.visible = (visibleCount > cameraIndex && visibleCount <= (cameraIndex + cameraPerSet));
    } else {
        camera.visible = false; // Hide camera if it doesn't match the filters
    }

    return camera;
});
}

  

function handleResolution(resolution) {
    selectedResolution.row = resolution.r;
    selectedResolution.col = resolution.c;
    cameraIndex = 0; 
    updateVisibleCameras(); 
}

async function getInfo(){
    authenticateToken()
    await fetchTalukas()
    await fetchCameras()
    await fetchPolls()
}

onMount(()=>{
    token=getToken()
    getInfo()

    setTimeout(() => {
        configureCameras()
    }, 5000);

    setTimeout(() => {
        playCameras()
    }, 15000);


    interval = setInterval(() => changeSlide(), selectedDuration*1000); 
})

</script>




<div class="flex flex-col pb-2 mx-auto bg-gray-900 transition-all duration-300" style="width:100%;height:100svh;">
    <button  class="{showingCamera?"fixed":"hidden"} h-full w-full bg-black bg-opacity-90 z-40">
        <div class="hover:cursor-default w-full h-full  relative">
            <div class="absolute h-full w-full flex flex-col justify-end top-0 left-0">
               
                    <div class="rounded-lg group  h-full relative flex-grow w-full mx-auto h-full">
                        <div class="w-full bg-gray-900 relative text-xl overflow-hidden">

                            <div class=" camera_info text-white rounded-xl  whitespace-nowrap overflow-hidden">  PS : {showCameraPS}, Model : {showCameraM}, Address : {showCameraPA}</div>
                            <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-xl font-bold  ">
                                <div class="bg-gray-900 h-full relative">
                                    <button on:click={()=>{showingCamera=false}} class=" px-3  transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300  h-full">⛶</button>
                                </div>
                            </div>
                        </div>
                        <video autoplay class="h-full w-full bg-gray-800" style="width:100%;height:100%" id='showCameraID'>
                            <track kind="captions">
                        </video>
                    </div>
                 
                <!-- <button on:click={()=>{showingCamera=false}} class=" hover:cursor-pointer text-6xl text-white p-5">🖵</button> -->
            </div>
        </div>
    </button>
    
    <div class="w-full mx-auto h-full flex flex-col bg-gray-900">
        
        <!-- ye button ke liye hai -->
         
        <div class="w-full px-10 flex transition-all duration-300 flex-row text-xl p-2 justify-between items-center align-center" style="height:14svh">
                        
            <div class="text-white items-center flex flex-row gap-10">
                <div class="flex flex-row gap-3 justify-center">
                    <div>Taluka : </div>
                    <select bind:value={selectedTaluka} class="rounded-xl text-white bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer px-5 py-1" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each talukaList as taluka}
                            <option value={taluka.taluka}>{taluka.taluka}</option>
                        {/each}
                    </select>
                </div>
                
                
                <div  class="flex flex-row gap-3 justify-center">
                    <div>Polling Station : </div>
                    <select bind:value={selectedPollingStation} class="rounded-xl text-white bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer px-5 py-1" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each pollingStationList as polling_station}
                            <option value={polling_station.polling_station}>{polling_station.polling_station}</option>
                        {/each}
                    </select>
                </div>
            
            </div>

            <div class="flex flex-row gap-7">
                <select class="rounded-xl  text-white py-1 bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer   px-5 py-1  " on:change="{(e) => handleResolution(resolutionList[e.target.selectedIndex])}">
                    {#each resolutionList as resolution}
                        <option value='{resolution.r} x {resolution.c}'>{resolution.r} x {resolution.c}</option>
                    {/each}
                </select>
                <select class="rounded-xl  text-white   bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer   px-5 py-1  " on:change="{(e) => {selectedDuration= Number(e.target.value);clearInterval(interval);interval = setInterval(() => changeSlide(), selectedDuration*1000); }}">
                    {#each slideDurationList as duration}
                        <option value={duration}>Slide Duration : {duration}s</option>
                    {/each}
                </select>
            </div>

        </div>
         
        <!-- ye camera ka hai -->
        <div class="w-full relative transition-all duration-300 grid grid-rows-{selectedResolution.row} grid-cols-{selectedResolution.col} px-3 pb-3 jusify-around  gap-2" style="height:86svh;">        
                {#each cameraList as camera}
                    <div class="text-white bg-gray-800 {camera.visible?"flex":"hidden"} border-2 border-gray-700  flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left  rounded-lg transaction-all duration-300" >
                        <div class="rounded-lg group  h-auto relative flex-grow w-full h-full">
                           
                            <video autoplay class="h-full w-full" id='{camera.serial_number}'>
                                <track kind="captions">
                            </video>
                        </div>
                        <div class="w-full bg-gray-900 relative text-base overflow-hidden">

                            <div class=" camera_info text-white rounded-xl  whitespace-nowrap inline-block overflow-hidden"> PS : {camera.polling_station}, Model : {camera.serial_number}, Address : {camera.polling_address}</div>
                            <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-base font-bold  ">
                                <div class="bg-gray-900">
                                    <button on:click={()=>{showThisCamera(camera)}} class=" px-2 transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300 z-50 h-full">⛶</button>
                                </div>
                            </div>
                        </div>
                    </div>
                {/each}
                
        </div>
    </div>
</div>      



<style>

    .camera_info{
        animation: scroll_animation 30s linear infinite;
    }

    @keyframes scroll_animation{
        0%{
            transform:translate(20%);
        }
        100%{
            transform:translate(-150%);
        }
    }
</style>