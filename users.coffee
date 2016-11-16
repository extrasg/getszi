jf = require 'jsonfile'
chalk = require 'chalk'
inquirer = require 'inquirer'
Steam = require 'steam'

POSSIBLE_GAMES = [
  {name: 'R6S', value: '359550', checked: true}
  {name: 'CS GO', value: '730', checked: true}
  {name: 'CS 1.6', value: '10', checked: true}
  {name: 'CS Source', value: '240', checked: true}
  {name: 'HL', value: '70', checked: true}
  {name: 'RUST', value: '252490', checked: true}
  {name: 'Dirt3', value: '321040', checked: true}
  {name: 'Rocket League', value: '252950', checked: true}
  {name: 'Forest', value: '242760', checked: true}
  {name: 'Dota 2', value: '570', checked: true}
  {name: 'War Thunder', value: '236390', checked: true}
  {name: 'ARK: Survival Evolved', value: '346110', checked: true}
  {name: 'Paladins', value: '444090', checked: true}444090
  {name: 'CS:CZ DS', value: '100', checked: true}
  {name: 'CS:CZ', value: '80', checked: true}
  {name: 'LIS', value: '319630', checked: true}
  {name: 'EAC', value: '282660', checked: true}
  {name: 'Alien Swarm', value: '630', checked: true}
  {name: 'Evolve Stage 2', value: '273350', checked: true}
  {name: 'Autumn', value: '473520', checked: true}
  {name: 'Bell Ringer', value: '424830', checked: true}
  {name: 'Limbo', value: '48000', checked: true}
  {name: 'TF2', value: '440', checked: true}
  {name: 'Cry of Fear', value: '223710', checked: true}
  {name: 'Loadout', value: '208090', checked: true}
  {name: 'Unturned', value: '304930', checked: true}
]
account = null

class SteamAccount
  accountName: null
  password: null
  authCode: null
  shaSentryfile: null
  games: []

  constructor: (@accountName, @password, @games) ->
    @steamClient = new Steam.SteamClient
    @steamClient.on 'loggedOn', @onLogin
    @steamClient.on 'sentry', @onSentry
    @steamClient.on 'error', @onError

  testLogin: (authCode=null) =>
    @steamClient.logOn
      accountName: @accountName,
      password: @password,
      authCode: authCode,
      shaSentryfile: @shaSentryfile

  onSentry: (sentryHash) =>
    @shaSentryfile = sentryHash.toString('base64')

  onLogin: =>
    console.log(chalk.green.bold('✔ ') + chalk.white("Sikeres bejelentkezés! '#{@accountName}'"))
    setTimeout =>
      database.push {@accountName, @password, @games, @shaSentryfile}
      jf.writeFileSync('db.json', database)
      process.exit(0)
    , 1500

  onError: (e) =>
    if e.eresult == Steam.EResult.InvalidPassword
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - rossz jelszó"))
    else if e.eresult == Steam.EResult.AlreadyLoggedInElsewhere
      console.log(chalk.bold.red("X ") + chalk.white("Logon failed for account '#{@accountName}' - already logged in elsewhere"))
    else if e.eresult == Steam.EResult.AccountLogonDenied
      query = {type: 'input', name: 'steamguard', message: 'Ird be a guard kodot! : '}
      inquirer.prompt query, ({steamguard}) =>
        @testLogin(steamguard)

# Load database
try
  database = jf.readFileSync('db.json')
catch e
  database = []

query = [
  {type: 'input', name: 'u_name', message: 'Felhasználónév: '}
  {type: 'password', name: 'u_password', message: 'Jelszó: '}
  {type: 'checkbox', name: 'u_games', message: 'Valaszd ki a jatekot amiben boostoljam az órákat: ', choices: POSSIBLE_GAMES}
]

inquirer.prompt query, (answers) ->
  account = new SteamAccount(answers.u_name, answers.u_password, answers.u_games)
  account.testLogin()
