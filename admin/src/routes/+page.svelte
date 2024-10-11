<script>
    import { onMount } from 'svelte';
    let url = 'http://apex-computers.live:2000';

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
                    'Authorization': `Bearer ${token}`, // Send token in authorization header
                    'Content-Type': 'application/json'
                }
            });

            const data = await response.json();

            if (response.ok) {
                // Token is valid; you can proceed to the user page or show user data
                console.log('Authenticated user:', data);
                window.location=data.error?'/login':'/user'
               
            } else {
                alert(data.error || 'Token is invalid');
                window.location = '/login'; // Redirect to login if token is invalid
            }
        } catch (error) {
            console.error('Error during token authentication:', error);
            alert("An error occurred while authenticating the token.");
        }
    }

    onMount(() => {
        authenticateToken();
    });
</script>
