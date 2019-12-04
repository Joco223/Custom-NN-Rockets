import csfml
import json
import math

const width = 900
const height = 900

var windowNN*: RenderWindow

var nn: JsonNode
var neuronCount: int
var neuronColours = newSeq[Color]()
var positions = newSeq[Vector2f]()
var connectionPositions = newSeq[Vector2f]()
var connectionsInput = newSeq[seq[int]]()
var connectionLinesBasic = newSeq[VertexArray]()
var connectionLinesStrength = newSeq[VertexArray]()
var neuronCircle: CircleShape
var neuronSize: float

proc initNNVisualizer*(x: JsonNode) =
  windowNN = newRenderWindow(videoMode(width, height), "NN Visualizer", WindowStyle.Titlebar|WindowStyle.Close, context_settings(antialiasing=8))
  nn = x
  neuronCount = nn.len()-1
  let angle = 360/neuronCount

  neuronSize = (2*(width/2)*3.14) / (float)(neuronCount + 15) / 2
  neuronCircle = newCircleShape(neuronSize)

  var currentAngle:float = 0
  for i in countup(0, neuronCount):
    let posX:float = round(cos(degToRad(currentAngle)) * (height/2 - (neuronSize*1.5)) - neuronSize + width/2)
    let posy:float = round(sin(degToRad(currentAngle)) * (height/2 - (neuronSize*1.5)) - neuronSize + height/2)

    let posX2:float = round(cos(degToRad(currentAngle)) * (height/2 - (neuronSize*2.5)) - neuronSize + width/2)
    let posy2:float = round(sin(degToRad(currentAngle)) * (height/2 - (neuronSize*2.5)) - neuronSize + height/2)

    currentAngle += angle
    positions.add(vec2(posX, posY))
    connectionPositions.add(vec2(posX2, posY2))

  for i in countup(0, nn.len()-1):
    var neuronInputConnections = newSeq[int]()
    let outputs = nn["neuron" & $i]["inputNeurons"]
    for i in countup(0, outputs.len()-1):
      neuronInputConnections.add(outputs[i].getInt())
    connectionsInput.add(neuronInputConnections)
    
    if nn["neuron" & $i]["finalNeuron"].getBool():
      neuronColours.add(color(100, 100, 255, 255))
    elif nn["neuron" & $i]["inputNeuron"].getBool():
      neuronColours.add(color(100, 255, 100, 255))
    else:
      neuronColours.add(color(200, 200, 200, 255))

  for i in countup(0, connectionPositions.len()-1):
    for connection in connectionsInput[i]:
      var currentPosition = connectionPositions[i] + vec2(neuronSize, neuronSize)
      var targetPosition = connectionPositions[connection] + vec2(neuronSize, neuronSize)
      var vert1: Vertex
      vert1.color = color(100, 100, 255, 255)
      vert1.position = currentPosition

      var vert2: Vertex
      vert2.color = color(100, 255, 100, 255)
      vert2.position = targetPosition

      var connectionArray = newVertexArray(PrimitiveType.Lines)
      connectionArray.append(vert1)
      connectionArray.append(vert2)
      connectionLinesBasic.add(connectionArray)

  for i in countup(0, connectionPositions.len()-1):
    if nn["neuron" & $i]["inputs"].len() != 0:
      for j in countup(0, nn["neuron" & $i]["outputIndexes"].len()-1):
        var currentPosition = connectionPositions[i] + vec2(neuronSize, neuronSize)
        var targetPosition = connectionPositions[nn["neuron" & $i]["outputIndexes"][j].getInt()] + vec2(neuronSize, neuronSize)

        var averageStrength: float = nn["neuron" & $i]["inputAdjustements"][j].getFloat()
        let newAlpha:int = abs((int)(255 * averageStrength))

        var vert1: Vertex
        vert1.color = color(255, 255, 255, newAlpha)
        vert1.position = currentPosition

        var vert2: Vertex
        vert2.color = color(255, 255, 255, newAlpha)
        vert2.position = targetPosition

        var connectionArray = newVertexArray(PrimitiveType.Lines)
        connectionArray.append(vert1)
        connectionArray.append(vert2)
        connectionLinesStrength.add(connectionArray)

var connectionArray = newVertexArray(PrimitiveType.Lines)
var vert1: Vertex
var vert2: Vertex
connectionArray.append(vert1)
connectionArray.append(vert2)

proc drawNN*(x: JsonNode) =
  for i in countup(0, neuronCount):
    neuronCircle.position = positions[i]
    neuronCircle.fillColor = neuronColours[i]
    windowNN.draw(neuronCircle)
  
  for i in countup(0, connectionPositions.len()-1):
    if x["neuron" & $i]["inputs"].len() != 0:
      for j in countup(0, x["neuron" & $i]["inputs"].len()-1):
        if j < x["neuron" & $i]["inputNeurons"].len()-1:
          var currentPosition = connectionPositions[i] + vec2(neuronSize, neuronSize)
          var targetPosition = connectionPositions[x["neuron" & $i]["inputNeurons"][j].getInt()] + vec2(neuronSize, neuronSize)

          var currentStrength = x["neuron" & $i]["inputs"][j].getFloat()
          var newAlpha = abs((int)round(255*currentStrength))
  
          if newAlpha > 255: newAlpha = 255
          if newAlpha < 0: newAlpha = 0

          vert1.color = color(255, 255, 255, newAlpha)
          vert1.position = currentPosition
          
          vert2.color = color(255, 255, 255, newAlpha)
          vert2.position = targetPosition

          connectionArray.resize(0)
          connectionArray.append(vert1)
          connectionArray.append(vert2)
          windowNN.draw(connectionArray)