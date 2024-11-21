<script>
    import {onMount} from 'svelte'
    import Hls from 'hls.js';

    
    let port = 8080
    // let apiUrl='117.248.105.98'
    let openStatistics=false
    let apiUrl='apex-computers.live'

    let lightMode=false

    let zoomScale=1
    // let url=`https://${apiUrl}/api`
    let url='http://localhost:2000/api'


    let token
    let interval
    let ip=apiUrl
    const getToken = () =>{
    return localStorage.getItem('authToken')
    }

    let frontCameraMuted=true
    let showingCamera=false
    
    let showCameraAC=''
    let showCameraSN=''
    let showCameraPA=''

    let streamSats=[
        {
            name:"Total",
            value:2500
        },{
            name:"Online",
            value:500
        },{
            name:"Offline",
            value:2000
        },
    ]

    let selectedConstituency='All'
    let selectedPollingStation='All'
    let cameraList=[]
    let constituencyList=[]
    let pollingStationList=[]
    let cameraIndex=0
    let selectedResolution ={
         row:"2",
         col:"3"
    };
    let cameraPerSet = Number(selectedResolution.row) * Number(selectedResolution.col)

    let slideDurationList=[
        {
            name:"15s",
            value:15
        },{
            name:"30s",
            value:30
        },{
            name:"1m",
            value:60
        },{
            name:"5m",
            value:60*5
        },
    ]

    let selectedDuration=15

    let resolutionList=[
        {
            r:"2",
            c:"3"
        },{
            r:'1',
            c:'1'
        },
        {
            r:"2",
            c:"2"
        },
        {
            r:"3",
            c:"4"
        }
    ]



    function showThisCamera(camera){
        showingCamera=true
        showCameraAC=camera.ac_number+' '+camera.ac_name
        showCameraSN=camera.serial_number
        showCameraPA=camera.polling_id+' '+camera.polling_address
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

        // const sourceUrl=''
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




<div class="flex flex-col mx-auto {lightMode?"bg-gray-100 text-black":"bg-gray-900 text-white"} transition-all " style="width:100%;height:100svh;">
    <button class="{showingCamera ? 'fixed' : 'hidden'} h-full w-full bg-black bg-opacity-90 z-40" style="overflow: hidden;">
        <div class="hover:cursor-default w-full h-full relative">
            <div class="absolute h-full w-full flex flex-col justify-end top-0 left-0">
                <div class="  relative bg-gray-800 flex border-2 border-gray-700 flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left cursor-pointer">
                    <div class="relative group h-auto relative flex-grow w-full h-full overflow-hidden">
                        
                        <video bind:muted={frontCameraMuted} autoplay class="object-cover w-full h-full" style="object-fit: fill;transform:scale({zoomScale})" id='showCameraID'>
                            <track kind="captions">
                        </video>
                    </div>
                    <div class="w-full bg-gray-900 relative text-xl pt-1 items-center">
                        <div class="camera_info   rounded-xl whitespace-nowrap inline-block items-center overflow-hidden">     
                            AC : {showCameraAC}, Camera : {showCameraSN}, PS : {showCameraPA}
                        </div>
                        <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-xl font-bold">
                            
                            <div class="bg-gray-900">
                                <button on:click={()=>{if(zoomScale>1)zoomScale-=0.25}} class="px-2 transition-all duration-300 transform  text-xl">-</button>

                                <button on:click={()=>{if(zoomScale<10.25)zoomScale+=0.25}} class="px-2 transition-all duration-300 transform  text-xl">+</button>


                                <button on:click={()=>{frontCameraMuted=!frontCameraMuted}} class=" transition-all duration-300  text-xl">{!frontCameraMuted?"🔊":"🔈"}</button>

                                <button on:click={() => { showingCamera=false}} class="px-2 transform hover:scale-110 hover:  text-gray-200 transition-all duration-300 h-full">⛶</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </button>

    <div class="{openStatistics ? 'fixed' : 'hidden'} h-full w-full {lightMode?"bg-white":"bg-gray-900"}  z-40" style="overflow: hidden;">
        <div class="w-full h-full flex flex-col">
            <div class="w-full relative flex p-2 flex-row justify-between">

                <button on:click={()=>openStatistics=false} class="p-2 rounded-lg absolute right-0 top-0 m-2 {lightMode?"hover:bg-gray-200 hover:shadow-gray-400":"hover:bg-gray-800 hover:shadow-gray-700"} transform hover:scale-105 duration-200 ease-in-out text-lg text-red-500">
                    <img src="close.png" alt="">
                </button>

                <div class="w-full pt-10 h-full flex flex-row">
                    <div class="w-1/3 h-full">

                    </div>
                    <div class="w-2/3 h-full">
                        <div class="w-1/2 flex  mx-auto flex-col gap-4">
                            {#each streamSats as stat}
                                <button  class="transform w-2/3 hover:scale-105 {lightMode?"shadow-gray-400":"shadow-gray-600"}  {stat.name=="Total"?"hover:shadow-blue-500":stat.name=="Online"?"hover:shadow-green-500":"hover:shadow-red-500"} {lightMode?"bg-gray-100":"bg-gray-800"} duration-200 ease-in-out   shadow-sm flex w-3/4 px-5 py-3  mx-auto rounded-xl justify-between items-left flex-row">
                                    <div class="flex flex-col items-left text-left text-{stat.name==="Total"?"blue":stat.name==="Online"?"green":"red"}-600  ">
                                        <div class="text-xl font-bold">{stat.name}</div>
                                        <div class="pl-1 text-lg font-semibold">{stat.value}</div>
                                    </div>
                                    <div class="my-auto text-3xl text-{stat.name==="Total"?"blue":stat.name==="Online"?"green":"red"}-500 ">
                                        {
                                        (stat.name=="Online")?streamSats[1].value*100/streamSats[0].value:(stat.name=="Total")?100:streamSats[2].value*100/streamSats[0].value
                                        }%
                                    </div>
                                    <div class="p-1 bg-{stat.name==="Total"?"blue":stat.name==="Online"?"green":"red"}-500 rounded-lg">
                                        <img class=" p-2" src="{stat.name}.png" alt="video">
                                    </div>
                                </button>
                            {/each}
                        </div>
                        
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    
    <div class="w-full mx-auto h-full flex flex-col justify-end {lightMode?"bg-white":"bg-gray-900"}">
         
        <div class="w-full justify-around flex flex-row text-lg  justify-between items-center align-center pt-2 gap-1" style="height:13svh;">
                
                <div class="flex flex-col relative text-left justify-center">
                    <div class="text-sm shadow-sm ml-5 absolute bottom-full -m-3  rounded-lg px-2 border border-2 {lightMode?" border-gray-300 bg-white":"border-gray-700 bg-gray-900"}">Assembly</div>
                    <select bind:value={selectedConstituency} class="rounded-xl border border-2  {lightMode?" border-gray-300":"border-gray-700"} {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer px-2 py-2" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each constituencyList as constituency}
                            <option value={constituency.ac_name}>{constituency.ac_name}</option>
                        {/each}
                    </select>
                </div>
                
                
                <div  class="flex flex-col relative text-left justify-center">
                    <div class="text-sm shadow-sm ml-5 absolute bottom-full -m-3  rounded-lg px-2 border  border-2 {lightMode?" border-gray-300 bg-white":"border-gray-700 bg-gray-900"}">Polling Station</div>
                    <select bind:value={selectedPollingStation} class="rounded-xl  border border-2  {lightMode?" border-gray-300":"border-gray-700"}  {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer px-2 py-2" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each pollingStationList as polling_station}
                            <option value={polling_station.polling_station_name}>PS : {polling_station.polling_station_id} {polling_station.polling_station_name}</option>
                        {/each}
                    </select>
                </div>

                <div  class="flex flex-col relative text-left justify-center">
                    <div class="text-sm shadow-sm ml-5 absolute bottom-full -m-3 rounded-lg px-2 border  border-2 {lightMode?" border-gray-300 bg-white":"border-gray-700 bg-gray-900"}">Category </div>
                    <select bind:value={selectedPollingStation} class="rounded-xl  border border-2  {lightMode?" border-gray-300":"border-gray-700"}  {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer px-2 py-2" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each pollingStationList as polling_station}
                            <option value={polling_station.polling_station_name}>PS : {polling_station.polling_station_id} {polling_station.polling_station_name}</option>
                        {/each}
                    </select>
                </div>

                <div  class="flex gap-3 flex-row relative text-left justify-center">
                    <div class="text-sm shadow-sm mx-auto absolute bottom-full -m-3 rounded-lg px-2 border  border-2 {lightMode?" border-gray-300 bg-white":"border-gray-700 bg-gray-900"} z-10">Navigate </div>
                    <button class="p-2 rounded-xl px-5 items-center py-1  border border-2 {lightMode?" border-gray-300":"border-gray-700"}  {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer transform -scale-x-100  ">➔</button>
                    <button class="p-2 rounded-xl px-5 items-center py-1  border border-2 {lightMode?" border-gray-300":"border-gray-700"}  {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer   ">➔</button>
                </div>

                <div  class="flex flex-col relative text-left justify-center">
                    <div class="text-sm shadow-sm ml-2 absolute bottom-full -m-3 rounded-lg px-2 border  border-2 {lightMode?" border-gray-300 bg-white":"border-gray-700 bg-gray-900"}">Layout </div>
                    <select class="rounded-xl  items-center py-1  border border-2 {lightMode?" border-gray-300":"border-gray-700"}  {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer   px-2 py-2  " on:change="{(e) => handleResolution(resolutionList[e.target.selectedIndex])}">
                        {#each resolutionList as resolution}
                            <option value='{resolution.r} x {resolution.c}'>{resolution.r} x {resolution.c}</option>
                        {/each}
                    </select>
                </div>


                


                <div  class="flex flex-col relative text-left justify-center">
                    <div class="text-sm shadow-sm ml-4 absolute bottom-full -m-3 rounded-lg px-2 border  border-2 {lightMode?" border-gray-300 bg-white":"border-gray-700 bg-gray-900"}">Auto Slide </div>
                    <select bind:value={selectedDuration} class="rounded-xl  border border-2  {lightMode?" border-gray-300":"border-gray-700"}  {lightMode?"bg-gray-100 hover:bg-white ":"bg-gray-800 hover:bg-gray-700 "} transition-all duration-300 hover:cursor-pointer px-8 py-2" on:change="{(e) => {cameraIndex=0;updateVisibleCameras();}}">
                        <option value="All">All</option>
                        {#each slideDurationList as duration}
                            <option value={duration.value}>{duration.name}</option>
                        {/each}
                    </select>
                </div>

                

                <div class="flex flex-row gap-4">
                    <button on:click={()=>lightMode=!lightMode} class=" text-2xl {lightMode?"text-gray-800 bg-white border-gray-300":"text-white bg-gray-800 border-gray-700"} px-4 py-2 items-center focus:outline-none rounded-xl border border-2  text-center transform hover:scale-105 duration-200 transition-all">
                        ☀︎
                    </button>
                    <button on:click={()=>openStatistics=true} class=" text-2xl {lightMode?"text-gray-800 bg-white border-gray-300":"text-white bg-gray-800 border-gray-700"} px-4 py-2 items-center focus:outline-none rounded-xl border border-2  text-center transform hover:scale-105 duration-200 transition-all">
                        ⓘ
                    </button>
                </div>

        </div>
         
        <!-- ye camera ka hai -->
        <div class="w-full relative transition-all px-1 pb-1 duration-300 grid grid-rows-{selectedResolution.row} grid-cols-{selectedResolution.col} jusify-around gap-1 " style="height:87svh;">        
                {#each cameraList as camera}
                <div class="rounded-sm  relative {lightMode?"bg-gray-100":"bg-gray-700"} {camera.visible ? 'flex' : 'hidden'} border border-0 {lightMode?"border-gray-300":"border-gray-700"} flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left">
                    <div class=" relative group h-auto relative flex-grow w-full h-full overflow-hidden">

                        <video autoplay class="object-cover w-full h-full" style="object-fit: fill;" bind:muted={camera.muted} id='{camera.serial_number}'>
                            <track kind="captions">
                        </video>

                        <div  class="text-white video-controls absolute items-center text-lg bottom-0 w-full transition-all duration-200 group-hover:flex flex-row justify-between hidden">
                            <div class="flex gap-1 flex-row items-center">
                                <button class="px-2">❙❙</button>
                                <button class="">
                                    <img class="p-1" style="width:24px;height:24px;" src="sound.png" alt="sound">                                  
                                </button>
                                <input min="0" max="10" value="0" class="{selectedResolution.col==5?"w-14":"w-20"} accent-white" orient="vertical" type="range">

                            </div>
                            <div class="flex flex-row items-center gap-1">
                                <div class="text-sm text-center pr-1">1X</div>
                                <button><img class="p-1" src="zoom-in.png" alt=""></button>
                                <button><img class="p-1" src="zoom-out.png" alt=""></button>
                                <button on:click={showThisCamera(camera)} class="px-2">⛶</button>

                            </div>
                        </div>
                    </div>
                    <div class="w-full {lightMode?"bg-gray-200":"bg-gray-800"} relative text-sm pt-1 items-center">
                        <div class="camera_info   rounded-xl whitespace-nowrap inline-block items-center overflow-hidden">
                           AC : {camera.ac_number+' '+camera.ac_name}, Camera : {camera.serial_number} , PS : {camera.polling_id+' '+camera.polling_address}
                        </div>                        
                    </div>
                </div>
                {/each}
                
        </div>
    </div>
</div>      



<style>

    .video-controls {
        background: linear-gradient(to top, #020202a9, #00000000); 
    }

    .camera_info{
        animation: scroll_animation 30s linear infinite;
    }

    @keyframes scroll_animation{
        0%{
            transform:translate(20%);
        }
        100%{
            transform:translate(-100%);
        }
    }
</style>