import Rockets
import ../Neuron_Network/NeuronNetwork
import math
import random
import csfml
import json

var rockets = newSeq[Rocket]()

var defaultRocketSprite = newSprite(newTexture("../assets/Rocket.png"))
defaultRocketSprite.origin = vec2(8, 8)
var selectedRocketSprite = newSprite(newTexture("../assets/RocketBest.png"))
selectedRocketSprite.origin = vec2(8, 8)

var previousBestFitness = 9999999.0
var previousBestBrain: neuronNetwork

proc getRocketCount*(): int =
  return rockets.len()

proc resetRocketBrains*() =
  for i in countup(0, rockets.len()-1):
    rockets[i].brain.resetNeurons()

proc getRocketBrain*(index: int): JsonNode =
  return rockets[index].convertBrain()

proc generateRandomRockets*(count, neuronCount, maxConnections: int, position: Vector2f, viewDistance, angle, adjustementValue: float) =
  for i in countup(0, count-1):
    var tmpRocket = newRocket(position, viewDistance, i)
    tmpRocket.angle = angle
    tmpRocket.brain = generateNetwork(19, 2, maxConnections, neuronCount, adjustementValue)
    rockets.add(tmpRocket)

proc generateTrainedRockets*(count: int, position: Vector2f, viewDistance, angle: float, path: string) =
  for i in countup(0, count-1):
    var tmpRocket = newRocket(position, viewDistance, i)
    tmpRocket.angle = angle
    tmpRocket.brain = loadNetwork(path)
    rockets.add(tmpRocket)

proc findClosestRocket(index: int): float =
  var closest: float = 9999999
  for i in countup(0, rockets.len()-1):
    if i != index:
      let dist = distance(rockets[index].position, rockets[i].position)
      if dist < closest:
        closest = dist
  return closest

proc updateRockets*(debug, checkRocketCollision: bool, windowWidth, windowHeight: int, window: RenderWindow, goal: CircleShape, walls: seq[RectangleShape]) =
  for i in countup(0, rockets.len()-1):
    if rockets[i].alive:

      var input = rockets[i].checkRayCollision(windowWidth, windowHeight, walls, rockets, false)
      for j in countup(0, input.len()-1):
        if input[j] >= 2:
          input[j] = 0

      input.add(1/distance(rockets[i].position, goal.position))
      input.add((float)((int)(rockets[i].angle - getAngle(rockets[i].position, goal.position)) mod (int)360) / 360)
      input.add(rockets[i].thrust)

      let result = rockets[i].brain.updateNetwork(input)
      rockets[i].thrust = result[0]
      rockets[i].angle += result[1]

      if debug:
        rockets[i].drawDebug(windowWidth, windowHeight, window, walls, rockets, false)

      if rockets[i].checkCollision(windowWidth, windowHeight, walls):
        rockets[i].alive = false
        rockets[i].thrust = 0

      if checkRocketCollision:
        if findClosestRocket(i) < 10:
          rockets[i].alive = false
          rockets[i].thrust = 0

      rockets[i].updatePhysics()

    if 0 == i:
      rockets[i].draw(window, selectedRocketSprite)
    else:
      rockets[i].draw(window, defaultRocketSprite)

proc mutateRockets*(distanceReward: float, goal: CircleShape, currentGeneration, neuronCount, maxConnections: int, rocketPosition: Vector2f, rocketAngle, mutation_chance, adjustementValue: float) =
  var matingPool = newSeq[int]()
  var bestFitness = 9999999.0
  var bestFitnessID = -1

  for i in countup(0, rockets.len()-1):
    let dist = distance(goal.position, rockets[i].position)

    var count = round((1/dist) * distanceReward)
    if rockets[i].alive:
      for j in countup(1, (int)count):
        matingPool.add(i)

      if dist < bestFitness:
        bestFitness = dist
        bestFitnessID = i

  if bestFitness > previousBestFitness:
    bestFitnessID = -2:
  else:
    previousBestFitness = bestFitness
    previousBestBrain = rockets[bestFitnessID].brain

  if bestFitnessID == -1:
    echo "Generation: #", currentGeneration, ", no survivors."
  elif bestFitnessID == -2:
    echo "Generation: #", currentGeneration, ", best fitness: ", bestFitness, ", no improvement, rolling back."
  else:
    echo "Generation: #", currentGeneration, ", best fitness: ", bestFitness
    rockets[bestFitnessID].saveRocket(bestFitness, currentGeneration)

  shuffle(matingPool)

  for i in countup(0, rockets.len()-1):
    rockets[i].position = rocketPosition
    rockets[i].angle = rocketAngle
    rockets[i].thrust = 0
    rockets[i].velocity = vec2(0, 0)
    rockets[i].alive = true

  var tmpRockets = newSeq[Rocket]()

  for i in countup(0, rockets.len()-1):
    tmpRockets.add(newRocket(vec2(0, 0), 0, 0))

  for i in countup(0, rockets.len()-1):
    if matingPool.len() == 0:
      tmpRockets[i].brain = generateNetwork(19, 2, maxConnections, neuronCount, adjustementValue)
      tmpRockets[i].brain.mutateNetwork(maxConnections, adjustementValue, mutation_chance)
    else:
      if bestFitnessID == -2:
        tmpRockets[i].brain = previousBestBrain
      else:
        tmpRockets[i].brain = rockets[sample(matingPool)].brain
        tmpRockets[i].brain.mutateNetwork(maxConnections, adjustementValue, mutation_chance)

  for i in countup(0, rockets.len()-1):
    rockets[i].brain = tmpRockets[i].brain

  tmpRockets = @[]