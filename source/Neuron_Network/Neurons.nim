type Neuron* = object
  inputs*: seq[float]                    #Input signals from other neurons
  inputNeurons*: seq[int]                #Indexes if input neurons (for the visualizer)
  outputIndexes*: seq[int]               #Indexes to other neurons input in the network
  inputAdjustements*: seq[float]         #Amounts to change the input signal strength depending on input type
  finalNeuron*: bool                     #Flag to mark if the neuron is a final output neuron
  inputNeuron*: bool                     #Flag for the visualizer

method updateNeuron*(this: var Neuron): seq[float] {.base.} =
  for i in countup(0, this.outputIndexes.len()-1):
    var outputNeuroTransmitter = 0.0
    for j in countup(0, this.inputs.len()-1):
      outputNeuroTransmitter += this.inputs[j] * this.inputAdjustements[i]

    if outputNeuroTransmitter != 0.0:
      outputNeuroTransmitter = outputNeuroTransmitter / (1 + abs(outputNeuroTransmitter))

    result.add(outputNeuroTransmitter)

method resetNeuron*(this: var Neuron) {.base.} =
  this.inputs = @[]
  this.inputNeurons = @[]