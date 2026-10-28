extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player_controller.gd")
const TERRAIN_SCRIPT = preload("res://scripts/terrain_generator.gd")

var player: CharacterBody3D
var terrain: Node3D
var sun: DirectionalLight3D
var elapsed := 0.0
var hud: Label
var flight_button: Button
var pause_panel: PanelContainer

func _ready() -> void:
    _build_environment()
    terrain = Node3D.new()
    terrain.name = "ProceduralWorld"
    terrain.set_script(TERRAIN_SCRIPT)
    add_child(terrain)
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER_SCRIPT)
    add_child(player)
    _build_ui()
    player.global_position = Vector3(0, 30, 0)

func _process(delta: float) -> void:
    elapsed += delta
    if sun:
        var phase := fposmod(elapsed / 1440.0, 1.0) * TAU
        sun.rotation.x = phase - PI * 0.5
        sun.light_energy = clampf(0.25 + maxf(0.0, sin(phase)) * 1.2, 0.15, 1.4)
    if hud and is_instance_valid(player):
        var mode := "ПОЛЁТ" if player.get("flying") else ("БЕГ" if Input.is_action_pressed("run") else "ИССЛЕДОВАНИЕ")
        hud.text = "FLIGHTCRAFT  •  %s\nСид: %s  |  Время: %02d:%02d\nWASD / джойстик · свайп камеры · F — самолёт" % [mode, str(terrain.get("world_seed")), int(elapsed / 60.0) % 24, int(elapsed) % 60]

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        _toggle_pause()

func _build_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color("183b68")
    sky_mat.sky_horizon_color = Color("f0b783")
    sky_mat.ground_bottom_color = Color("182b32")
    sky_mat.ground_horizon_color = Color("a1b9b9")
    sky.sky_material = sky_mat
    env.sky = sky
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.glow_enabled = true
    world_env.environment = env
    add_child(world_env)
    sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-42, -28, 0)
    sun.light_color = Color("ffe0b1")
    sun.shadow_enabled = true
    add_child(sun)

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud = Label.new()
    hud.position = Vector2(22, 18)
    hud.add_theme_font_size_override("font_size", 17)
    hud.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
    hud.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    hud.add_theme_constant_override("shadow_offset_x", 2)
    hud.add_theme_constant_override("shadow_offset_y", 2)
    layer.add_child(hud)
    var controls := HBoxContainer.new()
    controls.anchor_left = 1.0
    controls.anchor_top = 1.0
    controls.anchor_right = 1.0
    controls.anchor_bottom = 1.0
    controls.offset_left = -260
    controls.offset_top = -90
    controls.offset_right = -18
    controls.offset_bottom = -22
    controls.add_theme_constant_override("separation", 12)
    layer.add_child(controls)
    flight_button = Button.new()
    flight_button.text = "САМОЛЁТ: F"
    flight_button.custom_minimum_size = Vector2(145, 56)
    flight_button.pressed.connect(func(): player.toggle_flight())
    controls.add_child(flight_button)
    var jump_button := Button.new()
    jump_button.text = "ПРЫЖОК"
    jump_button.custom_minimum_size = Vector2(90, 56)
    jump_button.button_down.connect(func(): player.mobile_jump = true)
    jump_button.button_up.connect(func(): player.mobile_jump = false)
    controls.add_child(jump_button)
    pause_panel = PanelContainer.new()
    pause_panel.visible = false
    pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS
    pause_panel.set_anchors_preset(Control.PRESET_CENTER)
    pause_panel.position = Vector2(-130, -100)
    pause_panel.custom_minimum_size = Vector2(260, 200)
    var box := VBoxContainer.new()
    pause_panel.add_child(box)
    var title := Label.new()
    title.text = "Пауза"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    var resume := Button.new()
    resume.text = "Продолжить"
    resume.pressed.connect(_toggle_pause)
    box.add_child(resume)
    var seed_button := Button.new()
    seed_button.text = "Новый мир / сид"
    seed_button.pressed.connect(func(): terrain.regenerate(randi()))
    box.add_child(seed_button)
    layer.add_child(pause_panel)

func _toggle_pause() -> void:
    get_tree().paused = not get_tree().paused
    pause_panel.visible = get_tree().paused
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if get_tree().paused else Input.MOUSE_MODE_CAPTURED
