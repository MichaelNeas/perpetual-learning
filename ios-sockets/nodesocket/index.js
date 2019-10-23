var app = require('express')();
var http = require('http').createServer(app);
//var io = require('socket.io')(http);
const WebSocket = require('ws');

app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

// io.on('connection', function(socket) {
//   console.log('a user connected');
//   socket.on('chat message', function(msg){
//     io.emit('chat message', msg);
//   });  
//   socket.on('disconnect', function(){
//     console.log('user disconnected');
//   });
// });

const wss = new WebSocket.Server({ port: 3000 });

wss.on('connection', ws => {
  ws.on('message', message => {
    console.log(`Received message => ${message}`)
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });
  ws.on('close', () => {
    console.log('disconnected');
  });
  console.log('connected')
});

http.listen(3001, function(){
  console.log('listening on *:3001');
});
