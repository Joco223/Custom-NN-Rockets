import csfml
import Visualizer
import TestField
import ConfigParser
import Rocket/RocketsController

loadMainConfig("C:/Programming/Nim/Custom-NN-Rockets/config.cfg")

let width:cint           = (cint)loadWindowWidth()
let height:cint          = (cint)loadWindowHeight()
let rocketCount          = loadRocketCount()
let rocketStartPosition  = vec2(loadRocketPositionX(), loadRocketPositionY())
let rocketStartAngle     = loadRocketAngle()
let rocketViewDistance   = loadRocketViewDistance()
let endTick              = loadTotalTime()
let goalPosition         = vec2(loadGoalPositionX(), loadGoalPositionY())
let visualizerEnabled    = loadVisualizerEnabled()
let distanceReward       = loadDistanceReward()
let mutationEnabled      = loadMutationEnabled()
let debugMode            = loadDebugMode()
let interRocketCollision = loadInterRocketCollision()
let defaultBrain         = loadDefaultBrain()
let fpsLimit:cint        = (cint)loadFramerateLimit()
let mutationChance       = loadMutationChance()
let neuronCount          = loadNeuronCount() - 21 #21 here is current input+output configuration
let maxConnectionCount   = loadMaxConnectionCount()
let adjustementValue     = loadAdjustementValue()

loadWalls(loadWallConfig())

var window = newRenderWindow(videoMode(width, height), "NN Rockets", WindowStyle.Titlebar|WindowStyle.Close)
window.framerateLimit = fpsLimit

if defaultBrain == "":
  generateRandomRockets(rocketCount, neuronCount, maxConnectionCount, rocketStartPosition, rocketViewDistance, rocketStartAngle, adjustementValue)
else:
  generateTrainedRockets(rocketCount, rocketStartPosition, rocketViewDistance, rocketStartAngle, defaultBrain)

if visualizerEnabled:
  initVisualizer()
setGoal(goalPosition)

while window.open:
  var event: Event
  var eventNN: Event

  while window.pollEvent event:
    if event.kind == EventType.Closed:
      window.close()

  if visualizerEnabled:
    while windowNN.pollEvent eventNN:
      if eventNN.kind == EventType.Closed:
        windowNN.close()

  window.clear(color(50, 50, 50, 255))

  if visualizerEnabled:
    windowNN.clear(color(50, 50, 50, 255))

  updateTestField(window, endTick, width, height, neuronCount, maxConnectionCount, distanceReward, rocketStartPosition, rocketStartAngle, mutationChance, adjustementValue, mutationEnabled, debugMode, interRocketCollision, visualizerEnabled)

  window.display()

  if visualizerEnabled:
    windowNN.display()