
<script>

    import {onMount} from 'svelte'
    import Hls from 'hls.js';


    let url='http://localhost:2000'
    let token

    let port=4000
    let ip='localhost'

    const getToken = () =>{
    return localStorage.getItem('authToken')
    }

    let showingCamera=false
    let showCameraSerialNumber=''
    let showCamera
    let pollingStationList=[]    
    let cameraList=[]
    let talukaList=[]
    let cameraIndex=0
    let selectedResolution ={
        row : "2",
        col : "3"
    };

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
        // showCamera=
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
    let camerasPerSet = Number(selectedResolution.row) * Number(selectedResolution.col);
    
    cameraIndex += camerasPerSet;

    if (cameraIndex >= cameraList.length) {
      cameraIndex = 0;
    }
  }


  function loadCameras(){
  
  }

   function handleResolution(resolution){
    selectedResolution.row=resolution.r
    selectedResolution.col=resolution.c

    setTimeout(() => {
        configureCameras()
    }, 1000);

    setTimeout(() => {
        playCameras()
    }, 10000);

   

   }

   function getInfo(){
    authenticateToken()
    fetchPollingStations()
    fetchTalukas()
    fetchCameras()
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


   
    interval = setInterval(() => changeSlide(), selectedDuration * 1000); 
   })

</script>




<div class="flex flex-col pb-2 mx-auto bg-gray-900 transition-all duration-300" style="width:100%;height:100svh;">
    <button  class="{showingCamera?"fixed":"hidden"} h-full w-full bg-black bg-opacity-90 z-20">
        <div class="hover:cursor-default w-full h-full  relative">
            <div class="absolute w-full flex flex-row justify-end top-0 left-0">
                <button on:click={()=>{showingCamera=false}} class=" hover:cursor-pointer text-6xl text-white p-5">🖵</button>
            </div>
        </div>
    </button>
    
    <div class="w-full mx-auto h-full flex flex-col bg-gray-900">
        
        <!-- ye button ke liye hai -->
         
        <div class="w-full flex transition-all duration-300 flex-row p-2 justify-between items-center align-center" style="height:8svh">
                        
            <div class=" flex flex-row gap-6">
                <select class=" rounded-xl px-3 text-white py-1 bg-gray-600 ">
                    {#each pollingStationList as poll}
                        <option>{poll.polling_station}</option>
                        
                    {/each}
                </select>
                <select class="rounded-xl  text-white py-1 bg-gray-600   px-3 py-1  ">
                    {#each talukaList as taluka}
                        <option>{taluka.taluka}</option>
                        
                    {/each}
                </select>
            
            </div>

            <div class="flex flex-row gap-7">
                <select class="rounded-xl  text-white py-1 bg-gray-600   px-3 py-1  " on:change="{(e) => handleResolution(resolutionList[e.target.selectedIndex])}">
                    {#each resolutionList as resolution}
                        <option value='{resolution.r} x {resolution.c}'>{resolution.r} x {resolution.c}</option>
                    {/each}
                </select>
                <select class="rounded-xl  text-white py-1 bg-gray-600   px-3 py-1  " on:change="{(e) => {selectedDuration=slideDurationList[e.target.selectedIndex]}}">
                    {#each slideDurationList as duration}
                        <option value={duration}>Slide Duration : {duration}s</option>
                    {/each}
                </select>
            </div>

        </div>
         
        <!-- ye camera ka hai -->
        <div class="w-full relative transition-all duration-300 grid grid-rows-{selectedResolution.row} grid-cols-{selectedResolution.col} px-2 jusify-around  gap-2" style="height:92svh;">

               
        
                {#each cameraList.slice(cameraIndex, cameraIndex + Number(selectedResolution.row) * Number(selectedResolution.col)) as camera}
                    <div class="text-white bg-gray-600 flex flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left  rounded-lg transaction-all duration-300" >
                        <div class="rounded-lg group  h-auto relative flex-grow w-full h-full">
                            <!-- <button class="w-full h-full transition-all duration-200 absolute top-0 left-0 items-center hover:bg-black z-10 hover:bg-opacity-80 hidden group-hover:flex flex-row justify-center">
                                <div class="text-6xl text-white">⛶</div>
                            </button> -->
                            <video autoplay class="h-full w-full" id='{camera.serial_number}'>
                                <track kind="captions">
                            </video>
                        </div>
                        <div class="w-full bg-purple-100 relative">

                            <div class=" camera_info text-black"> PS : {camera.polling_station} Model : {camera.serial_number} Address : {camera.polling_address}</div>
                            <div class="w-full h-full items-center absolute top-0 left-0 flex flex-row justify-end text-xl font-bold px-1  text-black">
                                <button on:click={()=>{showThisCamera(camera)}} class="transform hover:scale-110 hover:text-gray-700 text-black transition-all duration-300">⛶</button>
                            </div>
                        </div>
                    </div>
                {/each}
                
        </div>
    </div>
</div>      



<style>

    .camera_info{
        animation: scroll_animation 15s linear infinite;
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