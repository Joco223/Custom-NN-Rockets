import parsecfg
import parseutils
import strutils
import csfml
import os

var mainConfig: Config

proc loadMainConfig*(path: string) =
  if existsFile(path):
    mainConfig = loadConfig(path)
  else:
    echo "File: ", path, " doesn't exist."

proc loadInt*(section, value: string, defaultValue: int): int = 
  let sectionValue = mainConfig.getSectionValue(section, value)
  if sectionValue == "":
    echo "Value: ", value, ", in section: ", section, " is not defined. Defaulting to: ", $defaultValue
    result = defaultValue
  else:
    discard parseInt(sectionValue, result)

proc loadFloat*(section, value: string, defaultValue: float): float =
  let sectionValue = mainConfig.getSectionValue(section, value)
  if sectionValue == "":
    echo "Value: ", value, ", in section: ", section, " is not defined. Defaulting to: ", $defaultValue
    result = defaultValue
  else:
    discard parseFloat(sectionValue, result)

proc loadBool*(section, value: string, defaultValue: bool): bool =
  let sectionValue = mainConfig.getSectionValue(section, value)
  if sectionValue == "":
    echo "Value: ", value, ", in section: ", section, " is not defined. Defaulting to: ", $defaultValue
    result = defaultValue
  else:
    if sectionValue == "true" or sectionValue == "True" or sectionValue == "TRUE":
      result = true
    elif sectionValue == "false" or sectionValue == "False" or sectionValue == "FALSE":
      result = false
    else:
      result = defaultValue
      echo "Error, unknown value: ", sectionValue, " in section: ", section, ". Defaulting to: ", $defaultValue

proc loadString*(section, value, defaultValue: string): string =
  let sectionValue = mainConfig.getSectionValue(section, value)
  if sectionValue == "":
    echo "Value: ", value, ", in section: ", section, " is not defined. Defaulting to: ", $defaultValue
    result = defaultValue
  else:
    if sectionValue == "none":
      result = ""
    else:
      result = sectionValue

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