const NodeMediaServer = require("node-media-server");
const express = require("express");
const path = require("path");
require('dotenv').config();

const app = express();


const CLIENT_PORT = process.env.CLIENT_PORT || 3010; // Port for Express
const RTMP_PORT = process.env.RTMP_PORT || 1935; // Port for RTMP
const TRANSCODE_PORT = process.env.TRANSCODE_PORT || 3050; // Port for transcoding
const HTTP_PORT = process.env.HTTP_PORT || 8000; // Port for HTTP


// Node Media Server configuration
const httpConfig = {
  port: HTTP_PORT,
  allow_origin: "*",
  mediaroot: "./media/live",
};

const rtmpConfig = {
  port: RTMP_PORT,
  chunk_size: 60000,
  gop_cache: true,
  ping: 10,
  ping_timeout: 60,
};

const transformationConfig = {
  ffmpeg: './ffmpeg/ffmpeg.exe', // Make sure this points to your FFmpeg installation
  tasks: [
    {
      app: 'live',
      hls: true, // Enable HLS
      hlsFlags: '[hls_time=5:hls_list_size=3]',
      hlsPath: './media/live', // Path for HLS files
      hlsCleanup: true, // Enables automatic cleanup
    },
  ]

};

const config = {
  http: httpConfig,
  rtmp: rtmpConfig,
  trans: transformationConfig,
};

// Serve the index.html file
app.use(express.static(path.join(__dirname)));

// Route for the homepage to serve index.html
app.get("/", (req, res) => {
  console.log("nigga")
  res.sendFile(path.join(__dirname, "index.html"), (err) => {
    if (err) {
      res.status(err.status).end();
    }
  });
});

// Start the Express server
app.listen(CLIENT_PORT, () => {
  console.log(`Express server is running on http://localhost:${CLIENT_PORT}`);
});

// Start the Node Media Server
const nms = new NodeMediaServer(config);
nms.run();