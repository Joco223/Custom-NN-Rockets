import csfml
import Visualizer
import TestField
import ConfigParser
import Rocket/RocketsController

loadMainConfig("C:/Programming/Nim/Custom-NN-Rockets/config.cfg")

let width:cint           = (cint)loadInt("Main_Parameters", "window_width", 800)
let height:cint          = (cint)loadInt("Main_Parameters", "window_height", 600)
let rocketCount          = loadInt("Main_Parameters", "rocket_count", 0)
let rocketStartPosition  = vec2(loadFloat("Main_Parameters", "rocket_position_x", 0), loadFloat("Main_Parameters", "rocket_position_y", 0))
let rocketStartAngle     = loadFloat("Main_Parameters", "rocket_angle", 0)
let rocketViewDistance   = loadFloat("Main_Parameters", "rocket_view_distance", 10)
let endTick              = loadInt("Main_Parameters", "rocket_count", 10)
let goalPosition         = vec2(loadFloat("Level_Parameters", "goal_position_x", 0), loadFloat("Level_Parameters", "goal_position_y", 0))
let visualizerEnabled    = loadBool("Main_Parameters", "visualizer_enabled", false)
let distanceReward       = loadFloat("Main_Parameters", "distance_reward", 1)
let mutationEnabled      = loadBool("Main_Parameters", "mutation_enabled", false)
let debugMode            = loadBool("Main_Parameters", "debug_mode", false)
let interRocketCollision = loadBool("Main_Parameters", "inter_rocket_collision", false)
let defaultBrain         = loadString("Main_Parameters", "default_brain", "")
let fpsLimit:cint        = (cint)loadInt("Main_Parameters", "framerate_limit", 60)
let mutationChance       = loadFloat("Main_Parameters", "mutation_chance", 0.1)
let neuronCount          = loadInt("Main_Parameters", "neuron_count", 30) - 21 #21 here is current input+output configuration
let maxConnectionCount   = loadInt("Main_Parameters", "max_connection_count", 1)
let adjustementValue     = loadFloat("Main_Parameters", "adjustement_value", 1)

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
      windowNN.close()
      window.close()

  if visualizerEnabled:
    while windowNN.pollEvent eventNN:
      if eventNN.kind == EventType.Closed:
        windowNN.close()
        window.close()

  window.clear(color(50, 50, 50, 255))

  if visualizerEnabled:
    windowNN.clear(color(50, 50, 50, 255))

  updateTestField(window, endTick, width, height, neuronCount, maxConnectionCount, distanceReward, rocketStartPosition, rocketStartAngle, mutationChance, adjustementValue, mutationEnabled, debugMode, interRocketCollision, visualizerEnabled)

  window.display()

  if visualizerEnabled:
    windowNN.display()