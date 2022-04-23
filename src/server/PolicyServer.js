//  Module:     PolicyServer
//  Project:    sq-toolbox
//  Author:     soviet
//  E-mail:     soviet@yandex.ru
//  Web:        https://vk.com/sovietxd

const { Logger } = require('sq-lib')

const { PolicyServer } = require('sq-lib')

module.exports = function(options) {
	const policyServer = new PolicyServer({
		port: 843,
		allowedPorts: JSON.parse(options.local.ports),
		host: options.local.host
	})
	return policyServer
}