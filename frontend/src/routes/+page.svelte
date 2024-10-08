
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

    let pollingStationList=[]    
    let cameraList=[]
    let talukaList=[]
    let cameraIndex=0
    let selectedResolution ={
        row : "2",
        col : "3"
    };

    let slideDurationList=[3,7,12,16,20,30,35]

    let selectedDuration=12

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
                alert("login successful")
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
        hls.on(Hls.Events.MANIFEST_PARSED, function () {
            video.play();
        });
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
        video.src = sourceUrl;
        video.addEventListener('canplay', function () {
            video.play();
        });
    }
};


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

   function handleResolution(resolution){
    selectedResolution.row=resolution.r
    selectedResolution.col=resolution.c
   }

   function getInfo(){
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

   })

</script>
<div class="flex flex-col pb-2 pt-1 mx-auto bg-gray-900 transition-all duration-300" style="width:100%;height:100svh;">
    <div class="w-full mx-auto h-full flex flex-col transition-all duration-300">
        
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
        <div class="w-full transition-all duration-300 grid grid-rows-{selectedResolution.row} grid-cols-{selectedResolution.col} px-2 jusify-around  gap-2" style="height:92svh;">
        
        
                {#each cameraList.slice(cameraIndex, cameraIndex + Number(selectedResolution.row) * Number(selectedResolution.col)) as camera}
                    <button class="text-white bg-gray-600 px-1 py-1 flex flex-col text-left whitespace-nowrap overflow-hidden w-full text-ellipse justify-end items-left  transform hover:scale-95 rounded-lg transaction-all duration-300" >
                        <div class="rounded-lg h-auto flex-grow w-full h-full">
                            <video autoplay class="h-full w-full" id='{camera.serial_number}'>
                                <track kind="captions">
                            </video>
                        </div>
                        
                        <div> PS : {camera.polling_station} Model : {camera.serial_number} Address : {camera.polling_address}</div>
                    </button>
                {/each}
                
        </div>
    </div>
</div>      