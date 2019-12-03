import csfml
import math
import times
import os
import strutils
import json
import ../Neuron_Network/NeuronNetwork

include RocketCollisionPhysics

let currentRunDir = replace(getDateStr() & "_" & getClockStr(), ":", "-")
setCurrentDir("runs")
createDir(currentRunDir)

type Rocket* = object
  position*: Vector2f
  velocity*: Vector2f
  alive*: bool
  angle*: float
  thrust*: float
  rayLength: float
  id*: int
  brain*: neuronNetwork
  distanceTraveled*: float

method newRocket*(position: Vector2f, rayLength: float, id: int): Rocket {.base.} =
  result = Rocket()
  result.position = position
  result.velocity = vec2(0, 0)
  result.alive = true
  result.angle = 0
  result.thrust = 0
  result.rayLength = rayLength
  result.id = id

method wrapAround*(this: var Rocket, width, height: int) {.base.} = 
  if this.position.x < 0: this.position.x = (float)width
  if this.position.y < 0: this.position.y = (float)height
  
  if this.position.x > (float)width: this.position.x = 0
  if this.position.y > (float)height: this.position.y = 0

method checkCollision*(this: Rocket, width, height: int, walls: openArray[RectangleShape]): bool {.base.} =
  if this.position.x < 0 or this.position.x > (float)width: return true
  if this.position.y < 0 or this.position.y > (float)height: return true

  for wall in walls:
    if this.position.x > wall.position.x and this.position.x < wall.position.x + wall.size.x:
      if this.position.y > wall.position.y and this.position.y < wall.position.y + wall.size.y:
        return true

  return false

proc getAngle*(p1, p2: Vector2f): float =
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  return degToRad(arctan2(dy, dx))

proc distance*(p1, p2: Vector2f): float =
  return sqrt((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y))

proc dot*(p1, p2: Vector2f): float =
  return p1.x * p2.x + p1.y * p2.y

method checkRayCollision*(this: Rocket, width, height: int, walls: openArray[RectangleShape], rockets: openArray[Rocket], collidesWithRockets: bool): seq[float] {.base.} =
  var intersections = newSeq[float](16)
  let radAngle = degToRad(this.angle)

  for i in countup(0, 15):
    let rayAngle = radAngle + degToRad((float)((float)(i)*22.5))
    let rayDir = vec2(this.position.x + cos(rayAngle)*this.rayLength, this.position.y + sin(rayAngle)*this.rayLength)

    intersections[i] = intersectionRatio(getLineIntersection(this.position, rayDir, vec2(0, 0), vec2(width, 0)), this.position, this.rayLength)
    intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, vec2(0, height), vec2(width, height)), this.position, this.rayLength))
    intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, vec2(0, 0), vec2(0, height)), this.position, this.rayLength))
    intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, vec2(width, 0), vec2(width, height)), this.position, this.rayLength))

    for wall in walls:
      intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, wall.position, vec2(wall.position.x+wall.size.x, wall.position.y)), this.position, this.rayLength))
      intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, vec2(wall.position.x, wall.position.y+wall.size.y), vec2(wall.position.x+wall.size.x, wall.position.y+wall.size.y)), this.position, this.rayLength))
      intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, wall.position, vec2(wall.position.x, wall.position.y+wall.size.y)), this.position, this.rayLength))
      intersections[i] = min(intersections[i], intersectionRatio(getLineIntersection(this.position, rayDir, vec2(wall.position.x+wall.size.y, wall.position.y), vec2(wall.position.x+wall.size.x, wall.position.y+wall.size.y)), this.position, this.rayLength))

    if collidesWithRockets:
      for rocket in rockets:
        if this.id != rocket.id:
          intersections[i] = min(intersections[i], intersectionRatio(getCircleIntersection(this.position, rayDir, rocket.position), this.position, this.rayLength))

  return intersections

method updatePhysics*(this: var Rocket) {.base.} =
  let radAngle = degToRad(this.angle - 90)

  if this.thrust > 1: this.thrust = 1
  if this.thrust < -1: this.thrust = -1

  let accX = cos(radAngle) * this.thrust
  let accY = sin(radAngle) * this.thrust

  this.velocity.x += accX
  this.velocity.y += accY

  if this.velocity.x > 5: this.velocity.x = 5
  if this.velocity.x < -5: this.velocity.x = -5
  if this.velocity.y > 5: this.velocity.y = 5
  if this.velocity.y < -5: this.velocity.y = -5

  this.velocity = vec2(this.velocity.x*0.9, this.velocity.y*0.9)

  let oldPos = this.position

  this.position.x += this.velocity.x
  this.position.y += this.velocity.y

  this.distanceTraveled += distance(oldPos, this.position)

method convertBrain*(this: Rocket): JsonNode {.base.} = 
  var db = %*{}

  for i in countup(0, this.brain.neurons.len()-1):
    db["neuron" & $i] = %*this.brain.neurons[i]

  return db

method saveRocket*(this: Rocket, fitness: float, generation: int) {.base.} =
  let db = convertBrain(this)
  
  writeFile(currentRunDir & "/" & "fit[" & $(int)(fitness) &  "]gen[" & $generation & "].json", db.pretty())
  

method drawDebug*(this: Rocket, width, height: int, window: RenderWindow, walls: openArray[RectangleShape], rockets: openArray[Rocket], collidesWithRockets: bool) {.base.} =
  let intersectionRays = checkRayCollision(this, width, height, walls, rockets, collidesWithRockets)

  for i in countup(0, 15):
    let rayAngle = this.angle + (float)((float)(i)*22.5)
    let rayDir = vec2(this.rayLength, 1)

    let rayRect = newRectangleShape()
    rayRect.position = this.position
    rayRect.size = rayDir
    rayRect.rotation = rayAngle
    if intersectionRays[i] == 2:
      rayRect.fillColor = color(0, 255, 0, 255)
    else:
      rayRect.fillColor = color((int)((1-intersectionRays[i])*255), (int)(intersectionRays[i]*255), 0, 255)

    window.draw(rayRect)

method draw*(this: Rocket, window: RenderWindow, sprite: var Sprite) {.base.} =
  sprite.position = this.position
  sprite.rotation = this.angle
  window.draw(sprite)