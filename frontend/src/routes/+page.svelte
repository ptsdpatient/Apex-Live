<script>
    import {onMount} from 'svelte'
    import Hls from 'hls.js';

    
    let port = 8080
    // let apiUrl='117.248.105.98'
    let apiUrl='apex-computers.live'
    let url=`https://${apiUrl}/api`
    let token
    let interval
    let ip=apiUrl
    const getToken = () =>{
    return localStorage.getItem('authToken')
    }

    let frontCameraMuted=true
    let showingCamera=false
    let showCameraPS=''
    let showCameraM=''
    let selectedConstituency='All'
    let selectedPollingStation='All'
    let showCameraPA=''
    let cameraList=[]
    let constituencyList=[]
    let pollingStationList=[]
    let cameraIndex=0
    let selectedResolution ={
         row:"2",
         col:"3"
    };
    let cameraPerSet = Number(selectedResolution.row) * Number(selectedResolution.col)

    let slideDurationList=[3,15,60,240,3600]

    let selectedDuration=3

    let resolutionList=[
        {
            r:"2",
            c:"3"
        },
        {
            r:"2",
            c:"2"
        },
        {
            r:"3",
            c:"5"
        },
        {
            r:"4",
            c:"7"
        },{
            r:"5",
            c:"9"
        }
    ]



    function showThisCamera(camera){
        showingCamera=true
        showCameraPS=camera.polling_station_name
        showCameraM=camera.serial_number
        showCameraPA=camera.polling_address
        const video = document.getElementById(`showCameraID`);
        if (!video) {
            console.error(`Video element not found for serial number: ${serialNumber}`);
            return;
        }

        const hls = new Hls();
        const sourceUrl = `https://${ip}/hls/${camera.serial_number}.m3u8`;

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

   async function fetchConstituency() {
       
       try {
           const response = await fetch(`${url}/getConstituencies`, {
               method: 'GET',
               headers: {
                   'Authorization': `Bearer ${token}`,
                   'Content-Type': 'application/json'
               }
           });

           constituencyList = await response.json();
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
        const sourceUrl = `https://${ip}/hls/${serialNumber}.m3u8`;

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


function muteThisCamera(camera){
    let desiredCamera= camera.serial_number;
    cameraList = cameraList.map((camera, index) => {
        if(camera.serial_number===desiredCamera) camera.muted=!camera.muted
        return camera;
    });
}

function changeSlide() {
    cameraPerSet = Number(selectedResolution.row) * Number(selectedResolution.col);

    cameraIndex += cameraPerSet;

    let visibleCamerasCount = 0;

    cameraList.forEach((camera) => {
        const matchesConstituency = selectedConstituency === "All" || camera.ac_name === selectedConstituency;
        const matchesPollingStation = selectedPollingStation === "All" || camera.polling_station_name === selectedPollingStation;

        if (matchesConstituency && matchesPollingStation) {
            visibleCamerasCount++;
        }
    });

    if (cameraIndex >= visibleCamerasCount) {
        cameraIndex = 0;  
    }

    updateVisibleCameras();
    
}

function updateVisibleCameras() {
 
    let visibleCount = 0; 

    cameraList = cameraList.map((camera, index) => {
    
    const matchesConstituency = selectedConstituency === "All" || camera.ac_name === selectedConstituency;
    const matchesPollingStation = selectedPollingStation === "All" || camera.polling_station_name === selectedPollingStation;

    if (matchesConstituency && matchesPollingStation) {
        visibleCount++;
        camera.visible = (visibleCount > cameraIndex && visibleCount <= (cameraIndex + cameraPerSet));
    } else {
        camera.visible = false; 
    }

    return camera;
});
}

  

function handleResolution(resolution) {
    selectedResolution.row = resolution.r;
    selectedResolution.col = resolution.c;
    cameraIndex = 0; 
    updateVisibleCameras(); 
    changeSlide()
}

async function getInfo(){
    authenticateToken()
    await fetchConstituency()
    await fetchCameras()
    await fetchPolls()
}

onMount(()=>{
    token=getToken()
    getInfo()

    setTimeout(() => {
        configureCameras()
    }, 2000);

    setTimeout(() => {
        playCameras()
    }, 5000);


    interval = setInterval(() => changeSlide(), selectedDuration*1000); 
})

</script>




<div class="flex flex-col pb-2 mx-auto bg-gray-900 transition-all duration-300" style="width:100%;height:100svh;">
    <button class="{showingCamera ? 'fixed' : 'hidden'} h-full w-full bg-black bg-opacity-90 z-40" style="overflow: hidden;">
        <div class="hover:cursor-default w-full h-full relative">
            <div class="absolute h-full w-full flex flex-col justify-end top-0 left-0">
                <div class="text-white relative bg-gray-800 flex border-2 border-gray-700 flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left rounded-lg  cursor-pointer">
                    <div class="rounded-lg relative group h-auto relative flex-grow w-full h-full overflow-hidden">
                        
                        <video bind:muted={frontCameraMuted} autoplay class="object-cover w-full h-full" style="object-fit: fill;" id='showCameraID'>
                            <track kind="captions">
                        </video>
                    </div>
                    <div class="w-full bg-gray-900 relative text-xl pt-1 items-center">
                        <div class="camera_info text-white rounded-xl whitespace-nowrap inline-block items-center overflow-hidden">
                            PS : {showCameraPS}, Model : {showCameraM}, Address : {showCameraPA}
                        </div>
                        <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-xl font-bold">
                            
                            <div class="bg-gray-900">
                                <button on:click={()=>{frontCameraMuted=!frontCameraMuted}} class=" transition-all duration-300  text-xl">{!frontCameraMuted?"🔊":"🔈"}</button>

                                <button on:click={() => { showingCamera=false}} class="px-2 transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300 h-full">⛶</button>
                            </div>
                        </div>
                    </div>
                </div>
<!-- 
                <div class="rounded-lg group w-full relative h-full">
                    <video autoplay bind:muted={isMuted} class="h-full w-full" style="" id='showCameraID'>
                        <track kind="captions">
                    </video>                    
                </div>
                <div class="w-full bg-gray-900 relative text-xl overflow-hidden z-60">
                    <div class="camera_info text-white rounded-xl whitespace-nowrap overflow-hidden">
                        PS: {showCameraPS}, Model: {showCameraM}, Address: {showCameraPA}
                    </div>
                    <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-xl font-bold">
                        <div class="bg-gray-900 h-full relative">
                            <button on:click={() => { showingCamera = false; }} class="px-3 transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300 h-full">⛶</button>
                        </div>
                    </div>
                </div>
                 -->
            </div>
        </div>
    </button>
    
    
    <div class="w-full mx-auto h-full flex flex-col bg-gray-900">
        
         
        <div class="w-full px-10 flex transition-all duration-300 flex-row text-xl p-2 justify-between items-center align-center" style="height:14svh">
                        
            <div class="text-white items-center flex flex-row gap-10">
                <div class="flex flex-row gap-3 justify-center">
                    <div>AC : </div>
                    <select bind:value={selectedConstituency} class="rounded-xl text-white bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer px-5 py-1" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each constituencyList as constituency}
                            <option value={constituency.ac_name}>{constituency.ac_name}</option>
                        {/each}
                    </select>
                </div>
                
                
                <div  class="flex flex-row gap-3 justify-center">
                    <div>Polling Station : </div>
                    <select bind:value={selectedPollingStation} class="rounded-xl text-white bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer px-5 py-1" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each pollingStationList as polling_station}
                            <option value={polling_station.polling_station_name}>PID : {polling_station.polling_station_id}. {polling_station.polling_station_name}</option>
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
        <div class="w-full relative transition-all duration-300 grid grid-rows-{selectedResolution.row} grid-cols-{selectedResolution.col} px-3 pb-3 jusify-around  gap-2 " style="height:86svh;">        
                {#each cameraList as camera}
                <div class="text-white relative bg-gray-800 {camera.visible ? 'flex' : 'hidden'} border-2 border-gray-700 flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left rounded-lg  cursor-pointer">
                    <div class="rounded-lg relative group h-auto relative flex-grow w-full h-full overflow-hidden">
                        <button on:click={()=>{muteThisCamera(camera)}} class="group-hover:block hidden z-20 transition-all duration-300 absolute right-0 p-3 text-4xl">{!camera.muted?"🔊":"🔈"}</button>
                        
                        <video autoplay class="object-cover w-full h-full" style="object-fit: fill;" bind:muted={camera.muted} id='{camera.serial_number}'>
                            <track kind="captions">
                        </video>
                    </div>
                    <div class="w-full bg-gray-900 relative text-sm pt-1 items-center">
                        <div class="camera_info text-white rounded-xl whitespace-nowrap inline-block items-center overflow-hidden">
                            PS : {camera.polling_id}, {camera.polling_station_name}, Model : {camera.serial_number}, Address : {camera.polling_address}
                        </div>
                        <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-sm font-bold">
                            <div class="bg-gray-900">
                                <button on:click={() => { showThisCamera(camera) }} class="px-2 transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300 h-full">⛶</button>
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
        animation: scroll_animation 13s linear infinite;
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