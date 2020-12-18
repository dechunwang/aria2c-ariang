const http = require('http')
const httpProxy = require('http-proxy')
const express = require('express')
const request = require('request')
const httpsrv = require('httpsrv')
const fs = require('fs')

const PORT = process.env.PORT || 1234
const app = express()
const proxy = httpProxy.createProxyServer({
	target: 'ws://127.0.0.1:5001',
	ws: true
})
const server = http.createServer(app)

// Proxy websocket
server.on('upgrade', (req, socket, head) => {
	proxy.ws(req, socket, head)
})

// Handle normal http traffic
app.use('/rpc', (req, res) => {
	req.pipe(request('http://127.0.0.1:5001/jsonrpc')).pipe(res)
})

app.use(express.static(__dirname + '/static'))
server.listen(PORT, () => console.log(`Listening on http://127.0.0.1:${PORT}`))


