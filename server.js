// Minimal static file server - only used if Python is not installed.
// Usage: node server.js [port]
const http = require("http");
const fs = require("fs");
const path = require("path");

const port = parseInt(process.argv[2], 10) || 8777;
const root = __dirname;
const types = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".txt": "text/plain; charset=utf-8"
};

http.createServer((req, res) => {
  let rel = decodeURIComponent(req.url.split("?")[0]);
  if (rel === "/") rel = "/teleprompter.html";
  const file = path.join(root, path.normalize(rel).replace(/^[\\/]+/, ""));
  if (!file.startsWith(root)) {
    res.writeHead(403).end("Forbidden");
    return;
  }
  fs.readFile(file, (err, data) => {
    if (err) {
      res.writeHead(404, { "Content-Type": "text/plain" }).end("Not found");
      return;
    }
    res.writeHead(200, { "Content-Type": types[path.extname(file).toLowerCase()] || "application/octet-stream" });
    res.end(data);
  });
}).listen(port, "127.0.0.1", () => {
  console.log("Teleprompter served at http://127.0.0.1:" + port + "/teleprompter.html");
});
