import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
    plugins: [sveltekit()],
    server: {
        proxy: {
            '/api': {
                target: 'http://localhost:2000/',
                rewrite: (path) => path.replace(/^\/api/, '')  // Remove /api from the path
            },
            '/hls': {
                target: 'http://localhost:8080/',
                rewrite: (path) => path.replace(/^\/hls/, '')  // Remove /hls if necessary
            }
        }
    }
});
