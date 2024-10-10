
<script>

    import {onMount} from 'svelte'
    import Hls from 'hls.js';


    let url='http://localhost:2000'
    let token

    let port=8000
    let ip='localhost'

    const getToken = () =>{
    return localStorage.getItem('authToken')
    }

    let showingCamera=false
    let showCameraSerialNumber=''
    let showCameraElement
    let showCameraPS=''
    let showCameraM=''
    let selectedTaluka='All'
    let showCameraPA=''
    let cameraList=[]
    let talukaList=[]
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
        showCameraSerialNumber=camera.serial_number
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
        const sourceUrl = `http://${ip}:${port}/live/${camera.serial_number}/index.m3u8`;

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
        const sourceUrl = `http://${ip}:${port}/live/${serialNumber}/index.m3u8`;

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

    if(selectedTaluka==="All"){
        if (cameraIndex >= cameraList.length) {
            cameraIndex = 0;
        }
    }else {
        let selectedTalukaLength = 0;
        cameraList.forEach((camera,index)=>{
            if (camera.taluka_name === selectedTaluka) {
                selectedTalukaLength++;
            }
        })
        if(cameraIndex>=slectedTalukaLength){
            cameraIndex=0
        }
    }

    updateVisibleCameras()
}

function updateVisibleCameras() {
    let selectedTalukaLength = 0;

    if (selectedTaluka !== "All") {
        // cameraIndex=0;
        cameraList = cameraList.map((camera, index) => {
                if (camera.taluka_name === selectedTaluka) {
                    selectedTalukaLength++;
                    camera.visible = (selectedTalukaLength > cameraIndex && selectedTalukaLength <= (cameraIndex + cameraPerSet));
                } else {
                    camera.visible = false;
                }
            return camera;
        });
    }

    if(selectedTaluka==="All"){
            cameraList = cameraList.map((camera, index) => {
            camera.visible = (index >= cameraIndex && index < (cameraIndex + cameraPerSet));
            if(camera.visible&&selectedTaluka!="All"){
                camera.visible=camera.taluka_name===selectedTaluka;
            }
            return camera;
        }
    );
    }
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
}

onMount(()=>{
    token=getToken()
    getInfo()

    setTimeout(() => {
        configureCameras()
    }, 1000);

    setTimeout(() => {
        playCameras()
    }, 10000);


    interval = setInterval(() => changeSlide(), selectedDuration*1000); 
})

</script>




<div class="flex flex-col pb-2 mx-auto bg-gray-900 transition-all duration-300" style="width:100%;height:100svh;">
    <button  class="{showingCamera?"fixed":"hidden"} h-full w-full bg-black bg-opacity-90 z-20">
        <div class="hover:cursor-default w-full h-full  relative">
            <div class="absolute h-full w-full flex flex-col justify-end top-0 left-0">
                <div class="w-1/12 absolute top-0 left-0 z-40 h-full bg-black">
                </div>
                    <div class="rounded-lg group  h-full relative flex-grow w-10/12 mx-auto h-full">
                        <div class="w-full bg-gray-900 relative text-xl">

                            <div class=" camera_info text-white rounded-xl  whitespace-nowrap overflow-hidden">  PS : {showCameraPS}, Model : {showCameraM}, Address : {showCameraPA}</div>
                            <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-xl font-bold  ">
                                <div class="bg-gray-900 h-full relative">
                                    <button on:click={()=>{showingCamera=false}} class=" px-3  transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300  h-full">⛶</button>
                                </div>
                            </div>
                        </div>
                        <video autoplay class="h-full w-full bg-gray-800" id='showCameraID'>
                            <track kind="captions">
                        </video>
                    </div>
                    <div class="w-1/12 absolute top-0 right-0 z-40 h-full bg-black">
                    </div>
                <!-- <button on:click={()=>{showingCamera=false}} class=" hover:cursor-pointer text-6xl text-white p-5">🖵</button> -->
            </div>
        </div>
    </button>
    
    <div class="w-full mx-auto h-full flex flex-col bg-gray-900">
        
        <!-- ye button ke liye hai -->
         
        <div class="w-full px-10 flex transition-all duration-300 flex-row text-xl p-2 justify-between items-center align-center" style="height:14svh">
                        
            <div class="text-white items-center flex flex-row gap-6">
                <div>Taluka : </div>
                <select value="All" class="rounded-xl text-white bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer px-5 py-1" on:change="{(e) => {selectedTaluka = e.target.value;cameraIndex=0;updateVisibleCameras();}}">
                    <option value="All">All</option>
                    {#each talukaList as taluka}
                        <option value={taluka.taluka}>{taluka.taluka}</option>
                    {/each}
                </select>
            
            </div>

            <div class="flex flex-row gap-7">
                <select class="rounded-xl  text-white py-1 bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer   px-5 py-1  " on:change="{(e) => handleResolution(resolutionList[e.target.selectedIndex])}">
                    {#each resolutionList as resolution}
                        <option value='{resolution.r} x {resolution.c}'>{resolution.r} x {resolution.c}</option>
                    {/each}
                </select>
                <select class="rounded-xl  text-white   bg-gray-800 hover:bg-gray-700 transition-all duration-300 hover:cursor-pointer   px-5 py-1  " on:change="{(e) => {selectedDuration=slideDurationList[e.target.selectedIndex]}}">
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
                        <div class="w-full bg-gray-900 relative text-base">

                            <div class=" camera_info text-white rounded-xl  whitespace-nowrap overflow-hidden"> PS : {camera.polling_station}, Model : {camera.serial_number}, Address : {camera.polling_address}</div>
                            <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-base font-bold  ">
                                <div class="bg-gray-900">
                                    <button on:click={()=>{showThisCamera(camera)}} class=" px-2 transform hover:scale-110 hover:text-white text-gray-200 transition-all duration-300  h-full">⛶</button>
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
        animation: scroll_animation 25s linear infinite;
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