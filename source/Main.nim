import csfml
import Rockets
import NeuronNetwork
import random
randomize()

const width = 800
const height = 600

var walls = newSeq[RectangleShape]()
var tmp = newRectangleShape()
tmp.position=vec2(400, 150)
tmp.size=vec2(30, 250)
#walls.add(tmp)
var rockets = newSeq[Rocket]()

var window = newRenderWindow(videoMode(width, height), "NN Rockets", WindowStyle.Titlebar|WindowStyle.Close)
#window.framerateLimit=60
var rocketSprite = newSprite(newTexture("../assets/Rocket.png"))
rocketSprite.origin = vec2(8, 8)

var goal = vec2(650, 450)
var goalCircle = newCircleShape(10)
goalCircle.position=goal
goalCircle.fillColor=color(0, 255, 0, 255)

proc generateRockets(count: int) =
  for i in countup(0, count-1):
    var tmpRocket = newRocket(vec2(100, 100), 80, i)
    tmpRocket.angle = 135
    tmpRocket.brain = generateNetwork(18, 2, 5, 100, 5, 1)
    rockets.add(tmpRocket)

proc findClosest(index: int): float =
  var closest: float = 9999999
  for i in countup(0, rockets.len()-1):
    if i != index:
      let dist = distance(rockets[index].position, rockets[i].position)
      if dist < closest:
        closest = dist
  return closest

proc updateRockets(debug, checkClose: bool) =
  for i in countup(0, rockets.len()-1):
    var closest = findClosest(i)
    if rockets[i].alive:
      var input = rockets[i].checkRayCollision(width, height, walls, rockets)
      input.add(distance(rockets[i].position, goal))
      input.add(findClosest(i))

      let result = rockets[i].brain.updateNetwork(input)
      rockets[i].thrust += result[0]
      rockets[i].angle += result[1]

      if debug:
        rockets[i].drawDebug(width, height, window, walls, rockets)

      if rockets[i].checkCollision(width, height, walls):
        rockets[i].alive = false
        rockets[i].thrust = 0

      if closest < 10 and checkClose:
        rockets[i].alive = false
        rockets[i].thrust = 0

    rockets[i].updatePhysics()

    rockets[i].draw(window, rocketSprite)

generateRockets(100)
var currentFrame = 0
var currentGeneration = 0

while window.open:
  var event: Event

  while window.pollEvent event:
    if event.kind == EventType.Closed:
      window.close()

  window.clear(color(50, 50, 50, 255))

  window.draw(goalCircle)
  #window.draw(walls[0])

  #updateRockets(true, true)

  if currentFrame < 180:
    updateRockets(false, false)
  else:
    updateRockets(false, true)

  inc(currentFrame)

  if currentFrame == 600:

    var matingPool = newSeq[neuronNetwork]()

    var best: (float, int)
    best[0] = 9999999.0
    best[1] = -1
    for i in countup(0, rockets.len()-1):
      if i != 0:
        let dist = distance(goal, rockets[i].position)
        if dist < best[0]:
          best[0] = dist
          if rockets[i].alive:
            best[1] = i

        var count = (int)(500 - dist)
        if rockets[i].alive:
          for j in countup(1, count):
            matingPool.add(rockets[i].brain)

    if matingPool.len() == 0:
      for i in countup(0, 19):
        matingPool.add(sample(rockets).brain)
        matingPool.add(generateNetwork(18, 2, 5, 100, 5, 1))

    if best[1] == -1:
      echo "Generation: #", currentGeneration, ", all rockets died"
    else:
      echo "Generation: #", currentGeneration, ", best fitness: ", best[0]
      rockets[best[1]].saveRocket(best[0], currentGeneration)

    shuffle(matingPool)

    for i in countup(0, rockets.len()-1):
      rockets[i].position = vec2(100, 100)
      rockets[i].angle = 135
      rockets[i].thrust = 0
      rockets[i].velocity = vec2(0, 0)
      rockets[i].alive = true

    for i in countup(0, 99):
      rockets[i].brain = sample(matingPool)
      if best[1] == -1:
        rockets[i].brain.mutateNetwork(0.5, 1, 5, 5)
      else:
        rockets[i].brain.mutateNetwork(0.1, 1, 5, 5)

    inc(currentGeneration)
    currentFrame = 0

  window.display()