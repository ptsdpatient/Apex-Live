<script>
    import {onMount} from 'svelte'
    let username = '';
    let password = '';
    // let url='http://117.248.105.198:2000'
    // let url='https://apex-computers.live/api'
    let url='http://localhost:2000/api'

    async function loginUser() {
        if (!username || !password) {
            alert("Please enter both username and password");
            return;
        }

        try {
            const response = await fetch(`${url}/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ name: username,password: password })
            });

            const data = await response.json();

            if (response.ok) {
                // Store token in local storage
                localStorage.setItem('apexLiveToken', data.token);
                window.location.href = '/view'; // Redirect to user page or dashboard
            } else {
                alert(data.error || 'Login failed');
            }
        } catch (error) {
            console.error('Error during login:', error);
            alert("An error occurred during login. Please try again.");
        }
    }


    onMount(()=>{

    })





</script>

<title>Login Page</title>

<div class="w-full h-full  flex flex-col items-center justify-center py-20  bg-gray-200" style="width:100vw;height:100svh;background-image:url(icon_bg.jpg);background-repeat:no-repeat;background-size:cover;background-position:center;">
    
        <div class="w-3/4 bg-opacity-40 backdrop-blur-sm shadow-lg shadow-black bg-white h-full flex flex-row justify-around rounded-2xl">
            <div class="w-1/2  m-auto" >
                <img src="camera.png" alt="camera" >
            </div>
            <div class="w-1/2 flex flex-col justify-end bg-gray-200 rounded-tr-3xl rounded-br-3xl px-20">
                <form class="w-full gap-2 space-y-4 my-10 text-lg">
                    <div class="text-4xl font-semibold pb-3 w-full text-center">Login</div>
                    <div>
                        <label for="username" class="block text-xl pb-1 font-medium">Username</label>
                        <input bind:value={username} placeholder="username" type="username" id="username" name="username" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring focus:ring-blue-500 text-black">
                    </div>
        
                    <div>
                        <label for="password" class="block pb-1 text-xl font-medium ">Password</label>
                        <input bind:value={password} placeholder="password" type="password" id="password" name="password" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring focus:ring-blue-500 text-black">
                    </div>
        
                    <button on:click={loginUser} class="mt-1 block w-1/3 mx-auto px-3 py-2  rounded-md text-white transform hover:scale-105 duration-300 transition-all shadow-sm focus:outline-none focus:ring bg-blue-500 focus:ring-blue-500">Login</button>
                    <p class="text-center text-sm text-gray-600">             
                        <a href="/help" class="font-medium text-blue-600 hover:text-blue-500">Need Help?</a>
                    </p>
                </form>
        
               
            </div>
      
    </div>
   
   

</div>