proc onSegment(p, q, r: Vector2f): bool =
  if q.x <= max(p.x, r.x) and q.x >= min(p.x, r.x) and q.y <= max(p.y, r.y) and q.y >= min(p.y, r.y):
    return true
  return false

proc orientation(p, q, r: Vector2f): int = 
  let val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)

  if val == 0: return 0

  if val > 0:
    return 1
  else:
    return 2

proc checkLineIntersection(p1, q1, p2, q2: Vector2f): bool =
  let o1 = orientation(p1, q1, p2)
  let o2 = orientation(p1, q1, q2)
  let o3 = orientation(p2, q2, p1)
  let o4 = orientation(p2, q2, q1)

  if o1 != o2 and o3 != o4:
    return true

  if o1 == 0 and onSegment(p1, p2, q1): return true
  if o2 == 0 and onSegment(p1, q2, q1): return true
  if o3 == 0 and onSegment(p2, p1, q2): return true
  if o4 == 0 and onSegment(p2, q1, q2): return true