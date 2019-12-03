import csfml
import Visualizer
import Rocket/RocketsController
import random
randomize()

var walls = newSeq[RectangleShape]()
var goal = newCircleShape(10)
goal.fillColor=color(0, 255, 0, 150)

var currentTick = 0
var currentGeneration = 1

proc setGoal*(position: Vector2f) =
  goal.position=position

proc addWall*(position, size: Vector2f) =
  var tmpWall = newRectangleShape()
  tmpWall.position=position
  tmpWall.size=size
  walls.add(tmpWall)

proc loadWalls*(newWalls: seq[RectangleShape]) =
  walls = newWalls

proc drawWalls(window: RenderWindow) =
  for wall in walls:
    window.draw(wall)

proc initVisualizer*() =
  if getRocketCount() > 0:
    initNNVisualizer(getRocketBrain(0))
  else:
    echo "No rockets present."

proc updateTestField*(window: RenderWindow, endTick, windowWidth, windowHeight, neuronCount, maxConnectionCount: int, distanceReward: float, rocketPosition: Vector2f, rocketAngle, mutationChance, adjustementValue: float, toMutate, drawDebug, collideWithRockets, visualizerEnabled: bool) =
  if getRocketCount() > 0:
    updateRockets(drawDebug, collideWithRockets, windowWidth, windowHeight, window, goal, walls)

    if visualizerEnabled:
      drawNN(getRocketBrain(0))

    drawWalls(window)
    window.draw(goal)

    resetRocketBrains()

    if currentTick == endTick and toMutate:
      mutateRockets(distanceReward, goal, currentGeneration, neuronCount, maxConnectionCount, rocketPosition, rocketAngle, mutationChance, adjustementValue)
      inc(currentGeneration)
      currentTick = 0
      GC_fullcollect()

    inc(currentTick)
  else:
    echo "No rockets present."