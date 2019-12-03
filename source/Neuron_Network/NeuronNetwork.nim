import random
import json
import Neurons

randomize()

type neuronNetwork* = object
  neurons*: seq[Neuron]
  outputSize: int

proc generateNetwork*(inputSize, outputSize, maxOutputCount, maxNetworkSize: int, maxAdjustement: float): neuronNetwork =
  let networkSize = inputSize + outputSize + maxNetworkSize
  var newNeuronNetwork: neuronNetwork
  newNeuronNetwork.neurons = newSeq[Neuron]()
  newNeuronNetwork.outputSize = outputSize

  var tmpNeuron: Neuron
  for i in countup(0, networkSize-1):
    if i <= inputSize:
      tmpNeuron.inputNeuron = true
    elif i > networkSize - outputSize - 1:
      tmpNeuron.finalNeuron = true
    else:
      tmpNeuron.inputNeuron = false
    newNeuronNetwork.neurons.add(tmpNeuron)

  for i in countup(0, networkSize-1):
    #Output connection configuration
    var connectionCount = 1
    if not newNeuronNetwork.neurons[i].finalNeuron:
      connectionCount = rand(maxOutputCount)

    if connectionCount > networkSize - i - 1: connectionCount = networkSize - i - 1
    if connectionCount == 0: connectionCount = 1

    newNeuronNetwork.neurons[i].outputIndexes = newSeq[int](connectionCount)
    for j in countup(0, connectionCount-1):
      let outputNeuron = rand(networkSize - i - 1) + i
      newNeuronNetwork.neurons[i].outputIndexes[j] = outputNeuron

    #Input adjustements configuration
    for j in countup(0, newNeuronNetwork.neurons[i].outputIndexes.len()-1):
      let adjustementValue: float = rand(maxAdjustement*2) - maxAdjustement
      newNeuronNetwork.neurons[i].inputAdjustements.add(adjustementValue)

  return newNeuronNetwork

proc loadNetwork*(path: string): neuronNetwork =
  var nn = parseFile(path)
  result.neurons = newSeq[Neuron]()
  var outputCount = 0

  for i in countup(0, nn.len()-1):
    var newNeuron: Neuron
    let currentNeuron = nn["neuron" & $i]

    for input in currentNeuron["inputs"]:
      newNeuron.inputs.add(input.getFloat())

    for inputNeuron in currentNeuron["inputNeurons"]:
      newNeuron.inputNeurons.add(inputNeuron.getInt())

    for outputIndex in currentNeuron["outputIndexes"]:
      newNeuron.outputIndexes.add(outputIndex.getInt())

    for inputAdjustement in currentNeuron["inputAdjustements"]:
      newNeuron.inputAdjustements.add(inputAdjustement.getFloat())

    newNeuron.finalNeuron = currentNeuron["finalNeuron"].getBool()
    newNeuron.inputNeuron = currentNeuron["inputNeuron"].getBool()

    if currentNeuron["inputNeuron"].getBool():
      inc(outputCount)

    result.neurons.add(newNeuron)
    result.outputSize = outputCount

method resetNeurons*(this: var neuronNetwork) {.base.} =
  for i in countup(0, this.neurons.len()-1):
    this.neurons[i].resetNeuron()

method updateNetwork*(this: var neuronNetwork, inputs: seq[float]): seq[float] {.base.} =
  for i in countup(0, inputs.len()-1):
    this.neurons[i].inputs.add(inputs[i])

  for j in countup(0, this.neurons.len()-1):
    if this.neurons[j].finalNeuron:
      result.add(this.neurons[j].updateNeuron()[0])
    else:
      let results = updateNeuron(this.neurons[j])

      for i in countup(0, results.len()-1):
        this.neurons[this.neurons[j].outputIndexes[i]].inputs.add(results[i])
        this.neurons[this.neurons[j].outputIndexes[i]].inputNeurons.add(j)

method len*(this: neuronNetwork): int {.base.} =
  result = this.neurons.len()

method mutateNetwork*(this: var neuronNetwork, maxOutputCount: int, maxAdjustement, mutationChance: float) {.base.} =
  for i in countup(0, this.neurons.len()-1):
    if rand(1.0) < mutationChance:
      #Output connection configuration
      if not this.neurons[i].finalNeuron:
        for j in countup(0, this.neurons[i].outputIndexes.len()-1):
          if rand(1.0) < 0.05: 
            let outputNeuron = rand(this.neurons.len() - i - 2) + i
            this.neurons[i].outputIndexes[j] = outputNeuron

      #Input adjustements configuration
      for j in countup(0, this.neurons[i].outputIndexes.len()-1):
        let adjustementValue: float = rand(maxAdjustement*2) - maxAdjustement
        this.neurons[i].inputAdjustements[j] = adjustementValue