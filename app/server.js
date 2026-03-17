const http = require("http");

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ status: "healthy" }));
    return;
  }

  res.writeHead(200, { "Content-Type": "text/html" });
  res.end("<h1>Hello World from ECS!</h1>\n");
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
