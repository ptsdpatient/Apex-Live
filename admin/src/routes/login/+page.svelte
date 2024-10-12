<script>
    import { onMount } from 'svelte';
    // let url = 'http://apex-computers.live:2000';
    let url ='http://192.168.1.15:2000'

    let username = '';
    let password = '';

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
                body: JSON.stringify({ name: username,password: password }) // Assuming 'email' is used as username in the backend
            });

            const data = await response.json();

            if (response.ok) {
                // Store token in local storage
                localStorage.setItem('authToken', data.token);
                window.location.href = '/user'; // Redirect to user page or dashboard
            } else {
                alert(data.error || 'Login failed');
            }
        } catch (error) {
            console.error('Error during login:', error);
            alert("An error occurred during login. Please try again.");
        }
    }

    // Optionally, you can call a function to check token validity on mount
    onMount(() => {
        // authenticateToken(); // Uncomment if you have this function to check the token
    });
</script>

<div class="flex flex-row justify-between w-full h-full bg-gray-200" style="width:100vw;height:100vh">
    <div class="w-2/3 flex flex-row justify-center h-3/4 m-auto">
        <img src="./icon.png" alt="">
    </div>
    <div class="flex flex-col py-10  justify-center my-auto mx-20 w-1/3 gap-3 text-2xl my-10 bg-gray-100 rounded-xl">
        <div class="ml-10 mt-5 my-2">Username:</div>
        <input 
            class="border-gray-500 border-1 mx-7 px-3 py-2 rounded-xl" 
            placeholder="firstname_lastname" 
            bind:value={username} 
        />
        <div class="ml-10 my-2">Password:</div>
        <input 
            type="password"
            class="border-gray-500 border-1 mx-7 px-3 py-2 rounded-xl" 
            placeholder="password" 
            bind:value={password} 
        />
        <button 
            on:click={loginUser} 
            class="mx-auto my-3 w-1/3 bg-gray-500 hover:bg-blue-500 px-7 py-2 rounded-xl mt-5 text-white transition-all transform duration-300 hover:shadow-xl"
        >
            Login
        </button>
    </div>
</div>
