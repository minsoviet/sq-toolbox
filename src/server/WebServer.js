//  Module:     WebServer
//  Project:    sq-toolbox
//  Author:     soviet
//  E-mail:     soviet@yandex.ru
//  Web:        https://vk.com/sovietxd

const { Logger } = require('sq-lib')

const fs = require('fs')
const http = require('http')
const https = require('https')
const express = require('express')

const CROSSDOMAIN_XML = fs.readFileSync('data/crossdomain.xml')
const CLIENT_SWF = fs.readFileSync('data/client.swf')

module.exports = function(options) {
    const app = express()
    app.get("/crossdomain.xml", (req, res) => {
        res.setHeader('Content-Type', 'text/xml')
        res.end(CROSSDOMAIN_XML)
    })
    app.get('/release/client_release*.swf', (req, res) => {
        res.setHeader('Content-Type', 'application/x-shockwave-flash')
        res.end(CLIENT_SWF)
    })
    app.get('*', (req, res) => {
        res.status(404).end('sq-toolbox')
    })

    return {
        httpServer: http.createServer({}, app),
        httpsServer: https.createServer({
            key: fs.readFileSync('data/ssl.key', 'utf8'),
            cert: fs.readFileSync('data/ssl.cert', 'utf8')
        }, app)
    }
}