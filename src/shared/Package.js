//  Module:     Package
//  Project:    sq-toolbox
//  Author:     soviet
//  E-mail:     soviet@yandex.ru
//  Web:        https://vk.com/sovietxd

const path = require('path')
const child_process = require('child_process')
const packageJson = require('../../package.json')

class Package {
	static name = 'Squirrels Toolbox'
	static author = 'https://vk.com/sovietxd'
	static version = packageJson.version
	static nodeVersion = process.versions.node
	static v8Version = process.versions.v8
	static sqLibVersion = require('sq-lib').version
	static config = path.join(process.cwd(), 'Config.wtf')
	static test = process.argv.includes('--test')
}

Package.getRevisionData = function() {
	try {
		return {
			revision: child_process.execSync('git rev-parse HEAD').toString('utf8').slice(0, -2),
			date: child_process.execSync('git log -1 --date=format:"%Y-%m-%d %H:%H:%S %z0" --format="%ad"').toString('utf8').slice(0, -2)
		}
	} catch(e) {}
	return {
		revision: 'unknown',
		date: '1970-01-01 00:00:00 +0000'
	}
}

module.exports = Package