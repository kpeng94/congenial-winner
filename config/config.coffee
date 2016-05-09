module.exports =
  # 16:9 ratio incase we need to make it full screen
  width: 1280
  height: 720
  gameContainer: 'game'
  backgroundColor: '#666666'

  # Game settings
  numPlayers: 6
  numTeammates: 2
  numLevels: 3
  gameLength: 60 # seconds

  # Game font styles
  fontStyle: '55px Orbitron' #TODO (kpeng94): change this
  fontColor: '#000000'
  pack: 'assets/pack.json'

  # Player movement settings
  PLAYER_MOVEMENT_DELTA: 100
  PLAYER_ROTATION_DELTA: 4

  # Player firing settings
  PLAYER_RELOAD_CD: 4000 # milliseconds
  PLAYER_FIRE_CD: 500 # milliseconds

  # Scoring configs
  HIT_INCREMENT: 1
  HURT_DECREMENT: 1
  SELF_HIT_DECREMENT: 1
