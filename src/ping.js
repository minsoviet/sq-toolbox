const { GameClient } = require('sq-lib')

async function main() {
    let client = new GameClient({
        'port': 11111,
        'host': '127.0.0.1'
    })
    client.open()
    setTimeout(function() {
        client.close()
    }, 1000);
    console.log('tried to conn')
}

main()