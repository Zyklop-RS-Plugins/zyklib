---@alias ColourRGBA integer

---@class Mesh.Vertex
---@field pos Vector3
---@field color_rgba ColourRGBA

---@class zyklib.MutableMesh.VertexRef
---@field vertex Mesh.Vertex
---@field index integer

---@class zyklib.MutableMesh
---@field private vertices Mesh.Vertex[]
---@field private triangle_indices integer[]
---@field private line_indices integer[]
local MutableMesh = {}
MutableMesh.__index = MutableMesh

---@return zyklib.MutableMesh
function MutableMesh.new()
    return setmetatable({
        vertices = {},
        triangle_indices = {},
        line_indices = {},
    }, MutableMesh)
end

---@return integer
function MutableMesh:vertex_count()
    return #self.vertices
end

---@return integer
function MutableMesh:triangle_count()
    return #self.triangle_indices // 3
end

---@return integer
function MutableMesh:line_count()
    return #self.line_indices // 2
end

---@param pos Vector3
---@param color? ColourRGBA
---@return zyklib.MutableMesh.VertexRef
function MutableMesh:createVertex(pos, color)
    ---@type Mesh.Vertex
    local vertex = {
        pos = pos,
        color_rgba = color or 0xFFFFFFFF,
    }

    self.vertices[#self.vertices + 1] = vertex

    return {
        -- Mesh indices remain zero-based.
        index = #self.vertices - 1,
        vertex = vertex,
    }
end

---@param v0 zyklib.MutableMesh.VertexRef
---@param v1 zyklib.MutableMesh.VertexRef
---@param v2 zyklib.MutableMesh.VertexRef
function MutableMesh:triangle(v0, v1, v2)
    self.triangle_indices[#self.triangle_indices + 1] = v0.index
    self.triangle_indices[#self.triangle_indices + 1] = v1.index
    self.triangle_indices[#self.triangle_indices + 1] = v2.index
end

---@param v0 zyklib.MutableMesh.VertexRef
---@param v1 zyklib.MutableMesh.VertexRef
function MutableMesh:line(v0, v1)
    self.line_indices[#self.line_indices + 1] = v0.index
    self.line_indices[#self.line_indices + 1] = v1.index
end

---@param v0 zyklib.MutableMesh.VertexRef
---@param v1 zyklib.MutableMesh.VertexRef
---@param v2 zyklib.MutableMesh.VertexRef
---@param v3 zyklib.MutableMesh.VertexRef
function MutableMesh:quad(v0, v1, v2, v3)
    self:triangle(v0, v1, v2)
    self:triangle(v0, v2, v3)
end

---@param offset Vector3
---@return self
function MutableMesh:translate(offset)
    for _, vertex in ipairs(self.vertices) do
        vertex.pos.x = vertex.pos.x + offset.x
        vertex.pos.y = vertex.pos.y + offset.y
        vertex.pos.z = vertex.pos.z + offset.z
    end

    return self
end

---@param factor number
---@return self
function MutableMesh:scale(factor)
    for _, vertex in ipairs(self.vertices) do
        vertex.pos.x = vertex.pos.x * factor
        vertex.pos.y = vertex.pos.y * factor
        vertex.pos.z = vertex.pos.z * factor
    end

    return self
end

---@param factor Vector3
---@return self
function MutableMesh:scale3(factor)
    for _, vertex in ipairs(self.vertices) do
        vertex.pos = vertex.pos * factor
    end

    return self
end

---@param color ColourRGBA
---@return self
function MutableMesh:recolor(color)
    for _, vertex in ipairs(self.vertices) do
        vertex.color_rgba = color
    end

    return self
end

---Turns the mesh inside out by reversing the winding order of all triangles.
---@return self
function MutableMesh:inside_out()
    local indices = self.triangle_indices

    for i = 1, #indices, 3 do
        indices[i + 1], indices[i + 2] = indices[i + 2], indices[i + 1]
    end

    return self
end

---@param ... zyklib.MutableMesh
---@return self
function MutableMesh:add(...)
    for i = 1, select("#", ...) do
        local mesh = select(i, ...)
        local vertex_offset = #self.vertices

        for _, vertex in ipairs(mesh.vertices) do
            self.vertices[#self.vertices + 1] = vertex
        end

        for _, index in ipairs(mesh.triangle_indices) do
            self.triangle_indices[#self.triangle_indices + 1] = index + vertex_offset
        end

        for _, index in ipairs(mesh.line_indices) do
            self.line_indices[#self.line_indices + 1] = index + vertex_offset
        end
    end

    return self
end

---Create a ShapeData object from this mesh. This is a snapshot of the current state of the mesh, and will not reflect any future changes.
---@return ShapeData
function MutableMesh:shapeData()
    local positions = {}
    local colors = {}
    local tris = {}
    local lines = {}

    for _, vertex in ipairs(self.vertices) do
        table.insert(positions, Vector3.new(vertex.pos.x, vertex.pos.y, vertex.pos.z))
        table.insert(colors, vertex.color_rgba)
    end

    for _, index in ipairs(self.triangle_indices) do
        table.insert(tris, index)
    end

    for _, index in ipairs(self.line_indices) do
        table.insert(lines, index)
    end

    local shape = ShapeData.new()

    shape.positions = positions
    shape.rgba = colors
    shape.tris = tris
    shape.lines = lines

    return shape
end

function MutableMesh:faces_only()
    self.line_indices = {}
    return self
end

function MutableMesh:lines_only()
    self.triangle_indices = {}
    return self
end

---Creates a simple unit cube with vertices between (0,0,0) and (1,1,1). The cube is made of 12 triangles (2 per face).
---@return zyklib.MutableMesh
function MutableMesh.cube()
    local mesh = MutableMesh.new()

    local a = mesh:createVertex(Vector3.new(0, 0, 0))
    local b = mesh:createVertex(Vector3.new(1, 0, 0))
    local c = mesh:createVertex(Vector3.new(1, 1, 0))
    local d = mesh:createVertex(Vector3.new(0, 1, 0))
    local e = mesh:createVertex(Vector3.new(0, 0, 1))
    local f = mesh:createVertex(Vector3.new(1, 0, 1))
    local g = mesh:createVertex(Vector3.new(1, 1, 1))
    local h = mesh:createVertex(Vector3.new(0, 1, 1))

    mesh:triangle(a, b, c)
    mesh:triangle(c, d, a)
    mesh:triangle(e, f, g)
    mesh:triangle(g, h, e)
    mesh:triangle(a, b, f)
    mesh:triangle(f, e, a)
    mesh:triangle(c, d, h)
    mesh:triangle(h, g, c)
    mesh:triangle(a, d, h)
    mesh:triangle(h, e, a)
    mesh:triangle(b, c, g)
    mesh:triangle(g, f, b)

    mesh:line(a, b)    
    mesh:line(b, c)
    mesh:line(c, d)
    mesh:line(d, a)
    mesh:line(e, f)
    mesh:line(f, g)
    mesh:line(g, h)
    mesh:line(h, e)
    mesh:line(a, e)
    mesh:line(b, f)
    mesh:line(c, g)
    mesh:line(d, h)

    return mesh
end

return MutableMesh
