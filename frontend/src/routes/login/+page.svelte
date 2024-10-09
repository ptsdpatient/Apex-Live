<script>
    import {onMount} from 'svelte'
    let username = '';
    let password = '';
    let url='http://localhost:2000'

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
                localStorage.setItem('authToken', data.token);
                window.location.href = '/'; // Redirect to user page or dashboard
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

<head>
    <title>Login Page</title>
</head>

<body class="w-full h-full  flex flex-row items-center justify-center px-10 gap-10  bg-white" style="width:100vw;height:100vh;">

    <div class="w-2/3 p-10 h-full flex flex-col ">
        <img src="camera.png" alt="camera" class="w-4/5 mx-right">
    </div>
    <div class=" w-1/3 p-8 space-y-6 bg-gray-200 rounded-lg shadow-xl">
        <h2 class="text-2xl font-bold text-center text-gray-800">Apex Live</h2>

        <form class="space-y-4">
            <div>
                <label for="username" class="block text-xl font-medium text-gray-700">Username</label>
                <input bind:value={username} type="username" id="username" name="username" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring focus:ring-blue-500" placeholder="">
            </div>

            <div>
                <label for="password" class="block text-xl font-medium text-gray-700">Password</label>
                <input bind:value={password} type="password" id="password" name="password" required class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring focus:ring-blue-500" placeholder="">
            </div>

            <button on:click={loginUser} class="mt-1 block w-1/3 mx-auto px-3 py-2 border border-gray-300 rounded-md text-white transform hover:scale-105 duration-300 transition-all shadow-sm focus:outline-none focus:ring bg-blue-500 focus:ring-blue-500">Login</button>
        </form>

        <p class="text-center text-sm text-gray-600">
            
            <a href="/help" class="font-medium text-blue-600 hover:text-blue-500">Help Desktop</a>
        </p>
    </div>

</body>