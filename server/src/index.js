const ws = require('ws');
const https = require('https');
const fs = require("fs");

const port = 9443;

const options = {
    ca: fs.readFileSync('../certificates/server-ca.crt'),
    cert: fs.readFileSync('../certificates/localhost.crt'),
    key: fs.readFileSync('../certificates/localhost.key'),
    requestCert: true
};

const server = https.createServer(options).listen(port);
const webSocketServer = new ws.Server({server});
const clients = new Set();
console.info(`Running the server under localhost:${port}`)

webSocketServer
    .on('connection', (webSocket, request) => {
        const subject = request.client.getPeerCertificate().subject.CN;
        console.info(`Connection opened to ${subject}`)
        clients.add(webSocket)

        webSocket.on('message', (messageAsString) => {
            console.info(`Message ${messageAsString} received from ${subject}`)
            clients.forEach(_ => _.send(`${subject}: ${messageAsString.toString()}`))
        })

        webSocket.on("close", () => {
            console.info(`Connection closed to ${subject}`)
            clients.delete(webSocket);
        });
    });