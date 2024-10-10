<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>404 - Page Not Found</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white">
    <div class="min-h-screen flex flex-col items-center justify-center">
        <!-- Left-side image container -->
        <div class="w-1/3 flex justify-center">
            <img src="proicon.png" alt="error image initially" class="w-full h-full object-cover rounded-md">
        </div>
        <!-- Right-side text container -->
        <div class="w-2/3  text-center ml-8">
            <!-- Status Code -->
            <h1 class="text-5xl font-bold text-gray-800">Page Not Found</h1>
            <!-- Message -->
            <p class="text-2xl md:text-3xl font-medium text-gray-600 mt-4">
                Oops! The page you're looking for doesn't exist.
            </p>
            <!-- Description -->
            <p class="text-gray-500 mt-2 mb-8">
                It seems the page you're trying to reach isn't available.
            </p>
            <!-- Back to Home Button -->
            <a href="login" class="px-6 py-3 text-lg text-white bg-blue-600 hover:bg-blue-700 rounded-md transition duration-300">
                Go Back To login page
            </a>
            <a href="help" class="px-6 py-3 text-lg text-white bg-blue-600 hover:bg-blue-700 rounded-md transition duration-300">
                Help Desk
            </a>
        </div>
    </div>
</body>
</html>
