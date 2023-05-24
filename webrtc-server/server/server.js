const fs = require('fs');
const https = require('https');
const WebSocket = require('ws');
const WebSocketServer = WebSocket.Server;
const axios = require( "axios" );
const url = require('url');

// Load the right env file:
let env = process.env.NODE_ENV;
if( undefined === process.env.NODE_ENV )
{
  env = "development";
}
require( "dotenv" ).config( { path: `.env.${env}` } );

// Yes, TLS is required
const serverConfig = {
  key: fs.readFileSync( `${process.env.CERT_PATH}/privkey.pem` ),
  cert: fs.readFileSync( `${process.env.CERT_PATH}/fullchain.pem` ),
};

// ----------------------------------------------------------------------------------------

// Create a server for the client html page
const handleRequest = function(request, response) {
  // Render the single client html file for any request the HTTP server receives
  console.log('request received: ' + request.url);

  // Parse the url:
  let parsed = url.parse( request.url, true );

  if( parsed.pathname === '/webrtcdemo' )
  {
    response.writeHead(200, {'Content-Type': 'text/html'});
    response.end(fs.readFileSync('client/index.html'));
  }

  else if( parsed.pathname === "/webrtc.js" )
  {
    response.writeHead(200, {'Content-Type': 'application/javascript'});
    response.end(fs.readFileSync('client/webrtc.js'));
  }
};

const HTTPS_PORT = process.env.HTTPS_PORT;
const httpsServer = https.createServer(serverConfig, handleRequest);
httpsServer.listen(HTTPS_PORT, '0.0.0.0');

// ----------------------------------------------------------------------------------------

// Create a server for handling websocket calls
const wss = new WebSocketServer({server: httpsServer});

wss.on('connection', function(ws, req) {
  let parsed = url.parse( req.url, true );
  let headers = { "Authorization": parsed.query[ "t" ] }

  axios.get( `${process.env.API_URL}/api/webrtc`, { headers: headers } )
    .then(
      function( r )
      {
        console.log( "AUTH OK" );
      }
    )
    .catch(
      function( e )
      {
        console.log( "AUTH FAILED" );
        ws.close();
      }
    );

  ws.on('message', function(message) {
    // Broadcast any received message to all clients
    console.log('received: %s', message);
    wss.broadcast(message);
  });

});

wss.broadcast = function(data) {
  this.clients.forEach(function(client) {
    if(client.readyState === WebSocket.OPEN) {
      client.send(data);
    }
  });
};

console.log('Server running. Visit https://localhost:' + HTTPS_PORT + '/webrtcdemo in Firefox/Chrome.\n\n\
Some important notes:\n\
  * Note the HTTPS; there is no HTTP -> HTTPS redirect.\n\
  * You\'ll also need to accept the invalid TLS certificate.\n\
  * Some browsers or OSs may not allow the webcam to be used by multiple pages at once. You may need to use two different browsers or machines.\n'
);

