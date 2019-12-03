proc getLineIntersection(p0, p1, p2, p3: Vector2f): Vector2f =
  let s1_x:float = p1.x - p0.x
  let s1_y:float = p1.y - p0.y

  let s2_x:float = p3.x - p2.x
  let s2_y:float = p3.y - p2.y

  let s = (-s1_y * (p0.x - p2.x) + s1_x * (p0.y - p2.y)) / (-s2_x * s1_y + s1_x * s2_y)
  let t = ( s2_x * (p0.y - p2.y) - s2_y * (p0.x - p2.x)) / (-s2_x * s1_y + s1_x * s2_y)

  if (s >= 0 and s <= 1 and t >= 0 and t <= 1):
    return vec2(p0.x + (t*s1_x), p0.y + (t*s1_y))
  else:
    return vec2(9999, 9999)

proc getCircleIntersection(p1, p2, p3: Vector2f): Vector2f = 
  let lab = sqrt((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y))

  let dx = (p2.x-p1.x)/lab
  let dy = (p2.y-p1.y)/lab

  let t = dx*(p3.x-p1.x) + dy*(p3.y-p1.y)

  let ex = t*dx+p1.x
  let ey = t*dy+p1.y

  let lec = sqrt((ex-p3.x)*(ex-p3.x)+(ey-p3.y)*(ey-p3.y))

  if lec < 20:
    let dt = sqrt(20*20 - lec*lec)
    return vec2((t-dt)*dx+p1.x, (t-dt)*dy+p1.y)
  else:
    return vec2(9999, 9999)

proc intersectionRatio(p1, p2: Vector2f, totalLength: float): float =
  if p1 == vec2(9999, 9999):
    return 2
  let dist = sqrt((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y))
  var final = dist/totalLength
  if final > totalLength: final = 2
  return final