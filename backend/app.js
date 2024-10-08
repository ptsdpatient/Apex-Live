const NodeMediaServer = require("node-media-server");
const express = require("express");
const app = express();
const path = require("path");

const RTMP_PORT = process.env.CLIENT_PORT || 1935; 
const HTTP_PORT = process.env.HTTP_PORT || 4000; 


const httpConfig = {
  port: HTTP_PORT,
  allow_origin: "*",
  mediaroot: "./media/",
};

const rtmpConfig = {
  port: RTMP_PORT,
  chunk_size: 60000,
  gop_cache: true,
  ping: 10,
  ping_timeout: 60,
};

const transformationConfig = {
  ffmpeg: './ffmpeg/ffmpeg.exe', 
  tasks: [
    {
      app: 'live',
      hls: true, 
      hlsFlags: '[hls_time=5:hls_list_size=3]',
      hlsPath: './media/', 
      hlsCleanup: true, 
    },
  ]

};

const config = {
  http: httpConfig,
  rtmp: rtmpConfig,
  trans: transformationConfig,
};


app.use(express.static(path.join(__dirname)));

// Route for the homepage to serve index.html
app.get("/", (req, res) => {
  console.log("showing video")
  res.sendFile(path.join(__dirname, "index.html"), (err) => {
    if (err) {
      res.status(err.status).end();
    }
  });
});

// Start the Express server
app.listen(8000, () => {
  console.log(`Express server is running on http://localhost:${8000}`);
});



const nms = new NodeMediaServer(config);
nms.run();