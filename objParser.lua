--[[

	objParser ~ pixe_ated <3
	
]]

local objParser = {}

local INTERP_LIMIT = 1000
local INTERP = 0

local random = math.random
local split = string.split
local find = string.find
local vector3 = Vector3.new
local insert = table.insert

local function v(str : string)

	local verts = {}

	local float = split(str," ")
	
	for _, number in float do
		
		if number == "v" then
			continue
		end
		
		insert(verts,tonumber(number))
	end
	
	return verts
	
end

local function f(str : string)
	
	local faces = split(str," ")
	
	local indexes = {}
	
	for _,face in faces do
		
		if face == "f" then
			continue
		end
		
		face = split(face,"/")
		
		insert(indexes,tonumber(face[1]))
	
	end

	return indexes
	
end

local function interp( str : string )
	
	if INTERP > INTERP_LIMIT  then
		task.wait(1/30)
		INTERP = 0
	end
	
	INTERP +=1
	
	local command = str:sub(1,2)
	
	-- vertex 
	if find(command,"v ") then
		return v(str),"v"
	end
	
	-- faces
	if find(command,"f") then
		return f(str),"f"
	end
	
	
end


objParser.renderSpeed = {
	NATIVE = 100_000_000,
	FAST = 100_000,
	SLOW = 1000,
}

objParser.new = function(data : string, color : Color3, renderSpeed : number)
	
	--[[
		data : string | obj data
		color : color3 | mesh color
		renderSpeed : number | speed to render
	]]
	
	assert(data," please give me an obj file so i can munch on it")
	
	local color = not color and Color3.new(1,1,1) or color
	INTERP = not renderSpeed and objParser.renderSpeed.NATIVE
	
	local lines_to_interpret = select(2,data:gsub("[^\n]+","[^\n]+"))
	local interpeted = 0
	
	local wait_clock = tick()
	local start_clock = tick()
	
	local vertex
	
	print("Creating Mesh from OBJ file")
	print("Lines to interpret: ", lines_to_interpret)

	local Mesh = Instance.new("DynamicMesh")
	Mesh.Parent = workspace
	
	for vert_data in string.gmatch(data,"[^\n]+") do
		
		if (tick() - wait_clock) >= 1 then
			
			wait_clock = tick()
			
			print(`Progress {interpeted/lines_to_interpret}%`)
			
		end
		
		local verts,mode = interp(vert_data)
		
		interpeted +=1
		
		if not verts then
			continue
		end
		
		if mode == "v" then

			vertex = Mesh:AddVertex(vector3(verts[1],verts[2],verts[3]))
			
			Mesh:SetVertexColor(vertex,color)
			continue	
		end
		
		if mode == "f" then

			Mesh:AddTriangle(verts[1],verts[2],verts[3])
			continue
		end	
		
	end
	
	local GeneratedMesh = Mesh:CreateMeshPartAsync(Enum.CollisionFidelity.Default)
	
	Mesh:Destroy()
	
	print(`All done! took: {tick()-start_clock}`)
	
	return GeneratedMesh
end

return objParser
