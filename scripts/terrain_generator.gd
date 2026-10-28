extends Node3D
## Lightweight procedural terrain prototype. Generates a continuous heightfield with voxel-like stepped shading.
const SIZE := 96
const STEP := 2.0
var world_seed: int = 48291
var noise := FastNoiseLite.new()

func _ready() -> void:
    regenerate(world_seed)

func regenerate(new_seed: int) -> void:
    world_seed = int(new_seed)
    seed(world_seed)
    for child in get_children():
        child.queue_free()
    noise.seed = world_seed
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    noise.frequency = 0.006
    noise.fractal_octaves = 5
    noise.fractal_lacunarity = 2.0
    noise.fractal_gain = 0.48
    var mesh := _make_terrain_mesh()
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 1.0
    instance.material_override = mat
    add_child(instance)
    var body := StaticBody3D.new()
    var shape := CollisionShape3D.new()
    var trimesh := mesh.create_trimesh_shape()
    shape.shape = trimesh
    body.add_child(shape)
    add_child(body)
    _add_water()
    _add_far_islands()

func height_at(x: float, z: float) -> float:
    var continental := noise.get_noise_2d(x * 0.55, z * 0.55)
    var detail := noise.get_noise_2d(x * 1.8 + 900, z * 1.8 - 700)
    return 5.0 + continental * 17.0 + detail * 4.0

func _make_terrain_mesh() -> ArrayMesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for z in range(SIZE):
        for x in range(SIZE):
            var x0 := (x - SIZE / 2.0) * STEP
            var z0 := (z - SIZE / 2.0) * STEP
            var x1 := x0 + STEP
            var z1 := z0 + STEP
            var h00 := height_at(x0, z0)
            var h10 := height_at(x1, z0)
            var h01 := height_at(x0, z1)
            var h11 := height_at(x1, z1)
            var center := (h00 + h10 + h01 + h11) * 0.25
            var color := _terrain_color(center, x, z)
            _tri(st, Vector3(x0,h00,z0), Vector3(x1,h10,z0), Vector3(x0,h01,z1), color)
            _tri(st, Vector3(x1,h10,z0), Vector3(x1,h11,z1), Vector3(x0,h01,z1), color)
    st.generate_normals()
    return st.commit()

func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
    st.set_color(color); st.add_vertex(a)
    st.set_color(color); st.add_vertex(c)
    st.set_color(color); st.add_vertex(b)

func _terrain_color(h: float, x: int, z: int) -> Color:
    if h > 18.0: return Color("dce8ed")
    if h > 12.0: return Color("777f7d")
    var variation := noise.get_noise_2d(x * 8.0, z * 8.0) * 0.08
    if h < 1.0: return Color("b9a77d")
    return Color(0.20 + variation, 0.39 + variation, 0.20 + variation * 0.5)

func _add_water() -> void:
    var water := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(SIZE * STEP * 1.4, SIZE * STEP * 1.4)
    water.mesh = plane
    water.position.y = 2.0
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.10, 0.43, 0.61, 0.72)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.roughness = 0.18
    mat.metallic = 0.08
    water.material_override = mat
    add_child(water)

func _add_far_islands() -> void:
    # Low-poly tree silhouettes make the first build feel alive without external assets.
    for i in range(65):
        var px := randf_range(-82, 82)
        var pz := randf_range(-82, 82)
        var h := height_at(px, pz)
        if h < 3.0 or h > 14.0: continue
        var trunk := MeshInstance3D.new()
        var cylinder := CylinderMesh.new()
        cylinder.top_radius = 0.22
        cylinder.bottom_radius = 0.32
        cylinder.height = 2.0
        trunk.mesh = cylinder
        trunk.position = Vector3(px, h + 1.0, pz)
        trunk.material_override = _mat(Color("6b4a30"))
        add_child(trunk)
        var crown := MeshInstance3D.new()
        var cone := PrismMesh.new()
        cone.size = Vector3(3.0, 4.0, 3.0)
        crown.mesh = cone
        crown.position = Vector3(px, h + 3.4, pz)
        crown.material_override = _mat(Color("285b43"))
        add_child(crown)

func _mat(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 1.0
    return m
