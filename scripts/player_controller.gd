extends CharacterBody3D

@export var walk_speed := 7.0
@export var run_speed := 11.5
@export var jump_velocity := 6.5
@export var look_sensitivity := 0.0025
var flying := false
var mobile_jump := false
var yaw := 0.0
var pitch := 0.0
var camera: Camera3D
var visual_plane: Node3D
var touch_look_id := -1
var last_touch := Vector2.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    add_child(collision)
    camera = Camera3D.new()
    camera.position = Vector3(0, 1.55, 0)
    camera.current = true
    camera.fov = 78
    add_child(camera)
    _make_plane_visual()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if not OS.has_feature("mobile") else Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if get_tree().paused: return
    if Input.is_action_just_pressed("toggle_flight"):
        toggle_flight()
    var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var forward := -global_transform.basis.z
    var right := global_transform.basis.x
    var direction := (right * input.x + forward * input.y).normalized()
    if flying:
        var throttle := 0.0
        if Input.is_key_pressed(KEY_SPACE) or mobile_jump: throttle += 1.0
        if Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_C): throttle -= 1.0
        velocity.x = lerpf(velocity.x, direction.x * 28.0, delta * 1.6)
        velocity.z = lerpf(velocity.z, direction.z * 28.0, delta * 1.6)
        velocity.y = lerpf(velocity.y, (throttle * 12.0) + (-pitch * 10.0), delta * 1.2)
        if visual_plane: visual_plane.rotation.z = lerpf_angle(visual_plane.rotation.z, -input.x * 0.5, delta * 2.0)
        camera.position = camera.position.lerp(Vector3(0, 1.65, 0.25), delta * 2.0)
    else:
        var speed := run_speed if Input.is_action_pressed("run") else walk_speed
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
        if not is_on_floor(): velocity.y -= gravity * delta
        if (Input.is_action_just_pressed("jump") or mobile_jump) and is_on_floor(): velocity.y = jump_velocity
        camera.position = camera.position.lerp(Vector3(0, 1.55, 0), delta * 5.0)
    move_and_slide()
    if visual_plane:
        visual_plane.visible = flying
        visual_plane.global_position = global_position + Vector3(0, -0.4, 0)
        visual_plane.rotation.y = rotation.y

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _look(event.relative)
    elif event is InputEventScreenTouch:
        if event.pressed and event.position.x > get_viewport().get_visible_rect().size.x * 0.42:
            touch_look_id = event.index
            last_touch = event.position
        elif not event.pressed and event.index == touch_look_id:
            touch_look_id = -1
    elif event is InputEventScreenDrag and event.index == touch_look_id:
        _look(event.relative * 1.15)
    elif event is InputEventMouseButton and event.pressed and not OS.has_feature("mobile"):
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _look(relative: Vector2) -> void:
    yaw -= relative.x * look_sensitivity
    pitch = clampf(pitch - relative.y * look_sensitivity, -1.35, 1.35)
    rotation.y = yaw
    camera.rotation.x = pitch

func toggle_flight() -> void:
    flying = not flying
    if flying:
        velocity.y = maxf(velocity.y, 4.0)
    else:
        if visual_plane: visual_plane.visible = false

func _make_plane_visual() -> void:
    visual_plane = Node3D.new()
    visual_plane.name = "LowPolyPlane"
    visual_plane.visible = false
    add_child(visual_plane)
    _plane_box(Vector3(0, 0.0, 0), Vector3(0.65, 0.55, 3.8), Color("e9e5d7"))
    _plane_box(Vector3(0, 0.28, -0.05), Vector3(7.2, 0.12, 1.15), Color("c94f3b"))
    _plane_box(Vector3(0, 0.75, 1.35), Vector3(2.3, 0.1, 0.62), Color("c94f3b"))
    _plane_box(Vector3(0, 0.35, 1.65), Vector3(0.12, 0.9, 0.75), Color("d8d4c6"))

func _plane_box(pos: Vector3, size: Vector3, color: Color) -> void:
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.72
    mesh_instance.material_override = mat
    visual_plane.add_child(mesh_instance)
