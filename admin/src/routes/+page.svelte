<script>
    import { onMount } from 'svelte';
    let port=2000
    // let link='apex-computers.live'
    let link='localhost:2000'

    let url=`http://${link}/api`
    // let url = `https://${link}/api`;

    async function authenticateToken() {
        const token = localStorage.getItem('apexLiveToken'); 
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
                window.location='/user'
               
            } else {
                alert(data.error || 'Token is invalid');
                window.location = '/login'; 
            }
        } catch (error) {
            console.error('Error during token authentication:', error);
            alert("An error occurred while authenticating the token." + error);
        }
    }


    onMount(() => {
        authenticateToken();
    });
</script>
