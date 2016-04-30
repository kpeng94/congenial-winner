module.exports =
  # 16:9 ratio incase we need to make it full screen
  width: 1280
  height: 720
  gameContainer: 'game'
  backgroundColor: '#EEEEEE'
  numPlayers: 6
  numTeammates: 2
  fontStyle: '65px Arial' #TODO (kpeng94): change this
  fontColor: '#FF0000'
  pack: 'assets/pack.json'
  gameLength: 60 # seconds

  # Player movement settings
  PLAYER_MOVEMENT_DELTA: 100
  PLAYER_ROTATION_DELTA: 4

  # Player firing settings
  PLAYER_INIT_NUM_BULLETS: 6
  PLAYER_RELOAD_CD: 4000 # milliseconds
  PLAYER_FIRE_CD: 340 # milliseconds

  # Scoring configs
  HIT_INCREMENT: 2
  HURT_DECREMENT: 1
  SELF_HIT_DECREMENT: 1
