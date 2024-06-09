local Calculations = {}

function Calculations.CircularPath(centerObject, radius, angularSpeed)
  local angle = time() * angularSpeed
	local x = centerObject.Position.X + radius * math.cos(angle)
	local z = centerObject.Position.Z + radius * math.sin(angle)  -- Maintain original Y height
  return x, z
end

function Calculations.TargetPositionAndOrientation(partA, partB, FOV, minOffset)
	-- Calculate the midpoint between partA and partB
	local midpoint = (partA.Position + partB.Position) / 2
 
	-- Calculate the distance between partA and partB
	local distance = (partA.Position - partB.Position).magnitude
 
	-- Convert FOV to radians and calculate the required offset
	local fovRadians = math.rad(FOV)
	local halfDistance = distance / 2
	local offset = halfDistance / math.tan(fovRadians / 2)
 
	-- Ensure the offset is at least the minimum offset
	offset = math.max(offset, minOffset)
 
	-- Calculate the direction vector from partA to partB
	local direction = (partB.Position - partA.Position).unit
 
	-- Determine the right vector (perpendicular to the direction)
	local upVector = Vector3.new(0, 1, 0) -- Assuming upVector is the global up direction
	local rightVector = direction:Cross(upVector).unit
 
	-- Calculate the target position for partTest with the offset
	local targetPosition = midpoint + rightVector * offset
 
	return targetPosition, midpoint
end

return Calculations