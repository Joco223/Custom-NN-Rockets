import parsecfg
import strutils
import csfml
import os

var mainConfig: Config

proc loadMainConfig*(path: string) =
  if existsFile(path):
    mainConfig = loadConfig(path)
  else:
    echo "File: ", path, " doesn't exist."

proc loadWindowWidth*(): int =
  let windowWidthValue = mainConfig.getSectionValue("Main_Parameters", "window_width")
  if windowWidthValue == "":
    echo "Main window width not defined. Defaulting to 800."
    echo "window_width = x"
    return 800
  else:
    return parseInt(windowWidthValue)

proc loadWindowHeight*(): int =
  let windowHeightValue = mainConfig.getSectionValue("Main_Parameters", "window_height")
  if windowHeightValue == "":
    echo "Main window height not defined. Defaulting to 600."
    echo "window_height = x"
    return 600
  else:
    return parseInt(windowHeightValue)

proc loadRocketCount*(): int =
  let rocketCountValue = mainConfig.getSectionValue("Main_Parameters", "rocket_count")
  if rocketCountValue == "":
    echo "Rocket count not defined. Defaulting to 0."
    echo "rocket_count = x"
    return 0
  else:
    return parseInt(rocketCountValue)

proc loadRocketPositionX*(): float =
  let rocketStartingPositionX = mainConfig.getSectionValue("Main_Parameters", "rocket_position_x")
  if rocketStartingPositionX == "":
    echo "Rocket position on X axis not defined. Defaulting to 0."
    echo "rocket_position_x = x"
    return 0.0
  else:
    return parseFloat(rocketStartingPositionX)

proc loadRocketPositionY*(): float =
  let rocketStartingPositionY = mainConfig.getSectionValue("Main_Parameters", "rocket_position_y")
  if rocketStartingPositionY == "":
    echo "Rocket position on Y axis not defined. Defaulting to 0."
    echo "rocket_position_y = x"
    return 0.0
  else:
    return parseFloat(rocketStartingPositionY)

proc loadRocketAngle*(): float =
  let rocketAngleValue = mainConfig.getSectionValue("Main_Parameters", "rocket_angle")
  if rocketAngleValue == "":
    echo "Rocket angle not defined. Defaulting to 0."
    echo "rocket_angle = x"
    return 0.0
  else:
    return parseFloat(rocketAngleValue)

proc loadRocketViewDistance*(): float =
  let rocketViewDistanceValue = mainConfig.getSectionValue("Main_Parameters", "rocket_view_distance")
  if rocketViewDistanceValue == "":
    echo "Rocket view distance not defined. Defaulting to 1."
    echo "rocket_view_distance = x"
    return 1.0
  else:
    return parseFloat(rocketViewDistanceValue)

proc loadTotalTime*(): int =
  let totalTimeValue = mainConfig.getSectionValue("Main_Parameters", "total_time")
  if totalTimeValue == "":
    echo "Total time not defined. Defaulting to 10."
    echo "total_time = x"
    return 10
  else:
    return parseInt(totalTimeValue)

proc loadVisualizerEnabled*(): bool =
  let visualizerEnabledValue = mainConfig.getSectionValue("Main_Parameters", "visualizer_enabled")
  if visualizerEnabledValue == "":
    echo "Visualizer enabled not defined. Defaulting to false."
    echo "visualizer_enabled = true/false"
    return false
  else:
    return parseBool(visualizerEnabledValue)

proc loadDistanceReward*(): float =
  let distanceRewardValue = mainConfig.getSectionValue("Main_Parameters", "distance_reward")
  if distanceRewardValue == "":
    echo "Distance reward not defined. Defaulting to 0."
    echo "distance_reward = x"
    return 0.0
  else:
    return parseFloat(distanceRewardValue)

proc loadMutationEnabled*(): bool =
  let mutationEnabledValue = mainConfig.getSectionValue("Main_Parameters", "mutation_enabled")
  if mutationEnabledValue == "":
    echo "Mutation enabled not defined. Defaulting to false."
    echo "mutation_enabled = true/false"
    return false
  else:
    return parseBool(mutationEnabledValue)

proc loadDebugMode*(): bool =
  let debugModeValue = mainConfig.getSectionValue("Main_Parameters", "debug_mode")
  if debugModeValue == "":
    echo "Debug mode not defined. Defaulting to false."
    echo "debug_mode = true/false"
    return false
  else:
    return parseBool(debugModeValue)

proc loadInterRocketCollision*(): bool =
  let interRocketCollisionValue = mainConfig.getSectionValue("Main_Parameters", "inter_rocket_collision")
  if interRocketCollisionValue == "":
    echo "Inter rocket collision not defined. Defaulting to false."
    echo "inter_rocket_collision = true/false"
    return false
  else:
    return parseBool(interRocketCollisionValue)

proc loadDefaultBrain*(): string =
  let defaultBrainValue = mainConfig.getSectionValue("Main_Parameters", "default_brain")
  if defaultBrainValue == "none":
    return ""
  elif defaultBrainValue == "":
    echo "Default brain not defined. Defaulting to none."
    echo "default_brain = none/path"
    return ""
  else:
    return defaultBrainValue

proc loadFramerateLimit*(): int =
  let framerateLimitValue = mainConfig.getSectionValue("Main_Parameters", "framerate_limit")
  if framerateLimitValue == "":
    echo "Framerate limit not defined. Defaulting to 60."
    echo "framerate_limit = x"
    return 60
  else:
    return parseInt(framerateLimitValue)

proc loadMutationChance*(): float =
  let mutationChanceValue = mainConfig.getSectionValue("Main_Parameters", "mutation_chance")
  if mutationChanceValue == "":
    echo "Mutation chance not defined. Defaulting to 0.1."
    echo "mutation_chance = x"
    return 0.1
  else:
    return parseFloat(mutationChanceValue)

proc loadNeuronCount*(): int = 
  let neuronCountValue = mainConfig.getSectionValue("Main_Parameters", "neuron_count")
  if neuronCountValue == "":
    echo "Neuron count value not defined. Defaulting to 30."
    echo "neuron_count = x"
    return 30
  else:
    return parseInt(neuronCountValue)

proc loadMaxConnectionCount*(): int =
  let maxConnectionCountValue = mainConfig.getSectionValue("Main_Parameters", "max_connection_count")
  if maxConnectionCountValue == "":
    echo "Max connection count not defined. Defaulting to 10."
    echo "max_connection_count = x"
    return 10
  else:
    return parseInt(maxConnectionCountValue)

proc loadAdjustementValue*(): float = 
  let adjustementValueValue = mainConfig.getSectionValue("Main_Parameters", "adjustement_value")
  if adjustementValueValue == "":
    echo "Adjustement value not defined. Defaulting to 2."
    echo "adjustement_value = x"
    return 2.0
  else:
    return parseFloat(adjustementValueValue)

proc loadGoalPositionX*(): float =
  let goalPositionXValue = mainConfig.getSectionValue("Level_Parameters", "goal_position_x")
  if goalPositionXValue == "":
    echo "Goal position X not defined. Defaulting to 0."
    echo "goal_position_x = x"
    return 0.0
  else:
    return parseFloat(goalPositionXValue)

proc loadGoalPositionY*(): float =
  let goalPositionYValue = mainConfig.getSectionValue("Level_Parameters", "goal_position_y")
  if goalPositionYValue == "":
    echo "Goal position Y not defined. Defaulting to 0."
    echo "goal position_y = x"
    return 0.0
  else:
    return parseFloat(goalPositionYValue)

proc loadWallConfig*(): seq[RectangleShape] =
  let wallCountValue = mainConfig.getSectionValue("Level_Parameters", "wall_count")
  for i in countup(1, parseInt(wallCountValue)):
    let wallPositionX = mainConfig.getSectionValue("Level_Parameters", "wall" & $i & "_position_x")
    let wallPositionY = mainConfig.getSectionValue("Level_Parameters", "wall" & $i & "_position_y")
    let wallSizeX     = mainConfig.getSectionValue("Level_Parameters", "wall" & $i & "_size_x")
    let wallSizeY     = mainConfig.getSectionValue("Level_Parameters", "wall" & $i & "_size_y")
    
    if wallPositionX == "": echo "Wall #", i, " position on X axis not defined."; echo "wall#_position_x = x"; continue
    if wallPositionY == "": echo "Wall #", i, " position on Y axis not defined."; echo "wall#_position_y = x"; continue
    if wallSizeX     == "": echo "Wall #", i, " size on X axis not defined."; echo "wall#_size_x = x"; continue
    if wallSizeY     == "": echo "Wall #", i, " size on Y axis not defined."; echo "wall#_size_y = x"; continue

    var tmpWall = newRectangleShape()
    tmpWall.position=vec2(parseFloat(wallPositionX), parseFloat(wallPositionY))
    tmpWall.size=vec2(parseFloat(wallSizeX), parseFloat(wallSizeY))

    result.add(tmpWall)