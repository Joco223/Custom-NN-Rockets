type neuroTransmitter* = object
  transType*: int
  strength*: float

proc newNeuroTransmitter*(transType: int, strength: float): neuroTransmitter =
  result.transType = transType
  result.strength = strength

type Neuron* = object
  inputs*: seq[neuroTransmitter]         #Input signals from other neurons
  inputNeurons*: seq[int]                #Indexes if input neurons (for the visualizer)
  outputIndexes*: seq[seq[int]]          #Indexes to other neurons input in the network
  inputOutputIndexes*: seq[int]          #Indexes to input neurons
  outputTransmitterTypes*: seq[seq[int]] #Types of transmitter types for output depending on input type
  inputAdjustements*: seq[seq[float]]    #Amounts to change the input signal strength depending on input type
  finalNeuron*: bool                     #Flag to mark if the neuron is a final output neuron
  inputNeuron*: bool                     #Flag for the visualizer

method updateNeuron*(this: Neuron): seq[neuroTransmitter] {.base.} =
  for i in countup(0, this.outputIndexes.len()-1):
    var outputNeuroTransmitter: neuroTransmitter
    outputNeuroTransmitter.transType = this.outputTransmitterTypes[i][this.inputs[this.inputOutputIndexes[i]].transType]
    outputNeuroTransmitter.strength = 0
    for j in countup(0, this.inputs.len()-1):
      outputNeuroTransmitter.strength += this.inputs[j].strength + this.inputAdjustements[i][this.inputs[j].transType]

    outputNeuroTransmitter.strength /= (float)this.inputs.len()

    result.add(outputNeuroTransmitter)