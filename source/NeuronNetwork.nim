import random
import Neurons

randomize()

type neuronNetwork* = object
  neurons*: seq[Neuron]
  outputSize: int

proc generateNetwork*(inputSize, outputSize, maxOutputCount, maxNetworkSize, maxTransmitterTypeCount: int, maxAdjustement: float): neuronNetwork =
  let networkSize = inputSize + outputSize + maxNetworkSize
  var newNeuronNetwork: neuronNetwork
  newNeuronNetwork.neurons = newSeq[Neuron]()
  newNeuronNetwork.outputSize = outputSize
  var outputsLeft = outputSize

  var tmpNeuron: Neuron
  for i in countup(0, networkSize-1):
    newNeuronNetwork.neurons.add(tmpNeuron)

  for i in countup(0, networkSize-1):
    if outputsLeft > 0:
      if rand(networkSize) == 0: #It is a new output neuron
        newNeuronNetwork.neurons[i].finalNeuron = true
        dec(outputsLeft)

    #Output connection configuration
    var connectionCount = 1
    if not newNeuronNetwork.neurons[i].finalNeuron:
      connectionCount = rand(maxOutputCount)

    if connectionCount == 0: connectionCount = 1

    newNeuronNetwork.neurons[i].outputIndexes = newSeq[seq[int]](connectionCount)
    for j in countup(0, connectionCount-1):
      let outputNeuron = rand(networkSize-1)
      newNeuronNetwork.neurons[outputNeuron].inputs = newSeq[neuroTransmitter](newNeuronNetwork.neurons[outputNeuron].inputs.len()+1)
      let newSize = newNeuronNetwork.neurons[outputNeuron].inputs.len()
      var outputIndex = newSeq[int](2)
      outputIndex[0] = outputNeuron
      if newSize != 0:
        outputIndex[1] = rand(newSize-1)
      else:
        outputIndex[1] = 0
      newNeuronNetwork.neurons[i].outputIndexes[j] = outputIndex

    if newNeuronNetwork.neurons[i].inputs.len() == 0: newNeuronNetwork.neurons[i].inputs = newSeq[neuroTransmitter](1)

    #Input output indexes configuration
    for j in countup(0, newNeuronNetwork.neurons[i].outputIndexes.len()-1):
      var index = 0
      if not newNeuronNetwork.neurons[i].inputs.len() == 0:
        index = rand(newNeuronNetwork.neurons[i].inputs.len()-1)
      newNeuronNetwork.neurons[i].inputOutputIndexes.add(index)

    #Output transmitter types configuration
    for j in countup(0, newNeuronNetwork.neurons[i].outputIndexes.len()-1):
      newNeuronNetwork.neurons[i].outputTransmitterTypes.add(newSeq[int]())
      for k in countup(0, maxTransmitterTypeCount-1):
        newNeuronNetwork.neurons[i].outputTransmitterTypes[j].add(rand(maxTransmitterTypeCount-1))
    
    #Input adjustements configuration
    for j in countup(0, newNeuronNetwork.neurons[i].outputIndexes.len()-1):
      newNeuronNetwork.neurons[i].inputAdjustements.add(newSeq[float]())
      for k in countup(0, maxTransmitterTypeCount-1):
        let adjustementValue: float = rand(maxAdjustement*2) - maxAdjustement
        newNeuronNetwork.neurons[i].inputAdjustements[j].add(adjustementValue)

  while outputsLeft > 0:
    var randomNeuron = rand(networkSize-1)
    if not newNeuronNetwork.neurons[randomNeuron].finalNeuron:
      newNeuronNetwork.neurons[randomNeuron].finalNeuron = true
      dec(outputsLeft)

  return newNeuronNetwork

method updateNetwork*(this: var neuronNetwork, inputs: seq[float]): seq[float] {.base.} =
  for i in countup(0, inputs.len()-1):
    var inputTransmitter = newNeuroTransmitter(0, inputs[i])
    this.neurons[i].inputs[0] = inputTransmitter

  for neuron in this.neurons:
    if neuron.finalNeuron:
      result.add(neuron.updateNeuron()[0].strength)
    else:
      let results = updateNeuron(neuron)

      for i in countup(0, results.len()-1):
        this.neurons[neuron.outputIndexes[i][0]].inputs[neuron.outputIndexes[i][1]] = results[i]

method len*(this: neuronNetwork): int {.base.} = 
  result = this.neurons.len()

method mutateNetwork*(this: var neuronNetwork, mutationChance, maxAdjustement: float, maxTransmitterTypeCount, maxOutputCount: int) {.base.} =
  for i in countup(0, this.neurons.len()-1):
    if rand(1.0) < mutationChance:
      if rand(1.0) < 0.05 and not this.neurons[i].finalNeuron:
        #Output connection configuration
        for j in countup(0, this.neurons[i].outputIndexes.len()-1):
          let outputNeuron = rand(this.len()-1)
          let newSize = this.neurons[outputNeuron].inputs.len()
          var outputIndex = newSeq[int](2)
          outputIndex[0] = outputNeuron
          if newSize != 0:
            outputIndex[1] = rand(newSize-1)
          else:
            outputIndex[1] = 0
            this.neurons[i].outputIndexes[j] = outputIndex

      if rand(1.0) < 0.1:
        #Input output indexes configuration
        for j in countup(0, this.neurons[i].outputIndexes.len()-1):
          var index = 0
          if not this.neurons[i].inputs.len() == 0:
            index = rand(this.neurons[i].inputs.len()-1)
            this.neurons[i].inputOutputIndexes[j] = index

      if rand(1.0) < 0.3:
        #Output transmitter types configuration
        for j in countup(0, this.neurons[i].outputIndexes.len()-1):
          for k in countup(0, maxTransmitterTypeCount-1):
            this.neurons[i].outputTransmitterTypes[j][k] = rand(maxTransmitterTypeCount-1)

      #Input adjustements configuration
      for j in countup(0, this.neurons[i].outputIndexes.len()-1):
        for k in countup(0, maxTransmitterTypeCount-1):
          let adjustementValue: float = rand(maxAdjustement*2) - maxAdjustement
          this.neurons[i].inputAdjustements[j][k] = adjustementValue

proc convertToFloat*(input: seq[bool]): seq[float] =
  for i in input:
    if i:
      result.add(1)
    else:
      result.add(0)