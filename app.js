// Load the HTTP module
const http = require('http');

// Define a port to listen on
const port = 3000;

// Create a server that responds with "Hello World"
const server = http.createServer((req, res) => {
  // Set the response HTTP header with HTTP status and Content type
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World\n');
});

// Make the server listen on the specified port
server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});
