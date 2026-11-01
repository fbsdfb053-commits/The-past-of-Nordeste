extends Node2D

const PLAYER_SPEED := 175.0
var SAVE_SLOT := 1
var seeds := 5
var harvested := 0
var planted: Array[bool] = [false, false, false, false]
var crop_days: Array[int] = [0, 0, 0, 0]
var crop_visuals: Array[Node] = []

var player: CharacterBody2D
var hud_label: Label
var message_label: Label
var inventory_panel: PanelContainer
var inventory_label: Label
var day := 1
var money := 120
var paused := false

func _ready() -> void:
	_setup_input()
	SAVE_SLOT = SaveManager.active_slot
	_build_world()
	_build_player()
	_build_ui()
	_restore_save()
	_refresh_crop_visuals()
	_setup_autosave()
	_show_message("Bem-vindo ao sítio da família. Explore Mulungu!")

func _setup_input() -> void:
	_add_key_action("move_left", [KEY_A, KEY_LEFT])
	_add_key_action("move_right", [KEY_D, KEY_RIGHT])
	_add_key_action("move_up", [KEY_W, KEY_UP])
	_add_key_action("move_down", [KEY_S, KEY_DOWN])
	_add_key_action("interact", [KEY_ENTER, KEY_SPACE, KEY_E])
	_add_key_action("quick_save", [KEY_I, KEY_Y])
	_add_key_action("pause", [KEY_ESCAPE])
	_add_key_action("advance_day", [KEY_N])
	_add_key_action("inventory", [KEY_TAB])
	_add_joy_action("advance_day", JOY_BUTTON_X)
	_add_joy_action("inventory", JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_action("interact", JOY_BUTTON_A)
	_add_joy_action("quick_save", JOY_BUTTON_Y)
	_add_joy_action("pause", JOY_BUTTON_START)
	_add_joy_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)

func _add_key_action(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for keycode in keys:
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)

func _add_joy_action(action: String, button: JoyButton) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)

func _add_joy_axis(action: String, axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = value
	InputMap.action_add_event(action, event)

func _build_world() -> void:
	_add_rect(Vector2.ZERO, Vector2(960, 540), "#78966a")
	_add_rect(Vector2(0, 0), Vector2(960, 82), "#45634b")
	_add_rect(Vector2(0, 82), Vector2(960, 18), "#a8a078")
	_add_rect(Vector2(0, 460), Vector2(960, 80), "#45634b")
	_add_rect(Vector2(0, 82), Vector2(70, 378), "#45634b")
	_add_rect(Vector2(890, 82), Vector2(70, 378), "#45634b")
	_add_rect(Vector2(365, 105), Vector2(230, 112), "#d5bd8c")
	_add_rect(Vector2(345, 88), Vector2(270, 38), "#794b3b")
	_add_rect(Vector2(445, 157), Vector2(54, 60), "#684832")
	_add_rect(Vector2(385, 132), Vector2(34, 30), "#83b7bd")
	_add_rect(Vector2(535, 132), Vector2(34, 30), "#83b7bd")
	for i in range(4):
		_add_rect(Vector2(120 + i * 105, 310), Vector2(82, 48), "#76543a")
		for j in range(3):
			_add_rect(Vector2(135 + i * 105 + j * 20, 321), Vector2(7, 7), "#b2a16b")
	for p in [Vector2(115, 160), Vector2(205, 205), Vector2(765, 170), Vector2(820, 265), Vector2(710, 390)]:
		_add_rect(p, Vector2(28, 38), "#684a32")
		_add_circle(p + Vector2(14, -7), 25.0, "#315c3d")
	_add_circle(Vector2(270, 390), 13.0, "#92958a")
	_add_circle(Vector2(660, 270), 10.0, "#a6a69a")
	_add_rect(Vector2(70, 420), Vector2(820, 22), "#b69b6b")
	_add_rect(Vector2(70, 426), Vector2(820, 5), "#d3bd8a")

func _add_rect(pos: Vector2, dimensions: Vector2, color_value: String) -> void:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = dimensions
	rect.color = Color(color_value)
	add_child(rect)

func _add_circle(pos: Vector2, radius: float, color_value: String) -> void:
	var shape := Polygon2D.new()
	var points := PackedVector2Array()
	for i in range(16):
		var angle := TAU * float(i) / 16.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	shape.polygon = points
	shape.position = pos
	shape.color = Color(color_value)
	add_child(shape)

func _build_player() -> void:
	player = CharacterBody2D.new()
	player.position = Vector2(475, 270)
	player.z_index = 5
	add_child(player)
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([Vector2(-9, -12), Vector2(9, -12), Vector2(9, 10), Vector2(-9, 10)])
	visual.color = Color("#e9c18c")
	player.add_child(visual)
	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([Vector2(-7, -17), Vector2(7, -17), Vector2(7, -5), Vector2(-7, -5)])
	head.color = Color("#6b4030")
	player.add_child(head)
	var collision := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 9
	capsule.height = 26
	collision.shape = capsule
	player.add_child(collision)

func _build_ui() -> void:
	var panel := ColorRect.new()
	panel.position = Vector2(16, 14)
	panel.size = Vector2(928, 48)
	panel.color = Color(0.08, 0.12, 0.09, 0.82)
	panel.z_index = 20
	add_child(panel)
	hud_label = Label.new()
	hud_label.position = Vector2(32, 27)
	hud_label.z_index = 21
	hud_label.add_theme_font_size_override("font_size", 17)
	hud_label.add_theme_color_override("font_color", Color("#fff2d6"))
	add_child(hud_label)
	message_label = Label.new()
	message_label.position = Vector2(24, 475)
	message_label.size = Vector2(912, 42)
	message_label.z_index = 21
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", Color("#fff2d6"))
	add_child(message_label)
	_update_hud()
	inventory_panel = PanelContainer.new()
	inventory_panel.position = Vector2(300, 150)
	inventory_panel.size = Vector2(360, 220)
	inventory_panel.z_index = 30
	inventory_panel.visible = false
	var inv_style := StyleBoxFlat.new()
	inv_style.bg_color = Color("#304738")
	inv_style.border_color = Color("#c5a16b")
	inv_style.set_border_width_all(3)
	inv_style.set_corner_radius_all(12)
	inv_style.content_margin_left = 22
	inv_style.content_margin_right = 22
	inv_style.content_margin_top = 18
	inv_style.content_margin_bottom = 18
	inventory_panel.add_theme_stylebox_override("panel", inv_style)
	add_child(inventory_panel)
	inventory_label = Label.new()
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_label.add_theme_font_size_override("font_size", 20)
	inventory_label.add_theme_color_override("font_color", Color("#fff2d6"))
	inventory_panel.add_child(inventory_label)
	_update_inventory()(_delta: float) -> void:
	if paused:
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = direction * PLAYER_SPEED
	player.move_and_slide()
	player.position.x = clampf(player.position.x, 82, 878)
	player.position.y = clampf(player.position.y, 95, 450)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_interact()
	elif event.is_action_pressed("advance_day"):
		_advance_day()
	elif event.is_action_pressed("inventory"):
		inventory_panel.visible = not inventory_panel.visible
		_update_inventory()
	elif event.is_action_pressed("quick_save"):
		_save()
	elif event.is_action_pressed("pause"):
		paused = not paused
		_show_message("Jogo pausado." if paused else "Voltamos à aventura!")

func _setup_autosave() -> void:
	var timer := Timer.new()
	timer.wait_time = 300.0
	timer.one_shot = false
	timer.timeout.connect(_save)
	add_child(timer)
	timer.start()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_inside_tree() and player != null:
		_save()

func _restore_save() -> void:
	var data := SaveManager.load_game(SAVE_SLOT)
	if data.is_empty():
		return
	player.position = Vector2(float(data.get("player_x", 475.0)), float(data.get("player_y", 270.0)))
	day = int(data.get("day", 1))
	money = int(data.get("money", 120))
	seeds = int(data.get("seeds", 5))
	harvested = int(data.get("harvested", 0))
	var saved_plots = data.get("planted", [false, false, false, false])
	var saved_crop_days = data.get("crop_days", [0, 0, 0, 0])
	for i in range(min(4, saved_plots.size())):
		planted[i] = bool(saved_plots[i])
	for i in range(min(4, saved_crop_days.size())):
		crop_days[i] = int(saved_crop_days[i])
	_update_hud()

func _save() -> void:
	var data := {"player_x": player.position.x, "player_y": player.position.y, "day": day, "money": money, "seeds": seeds, "harvested": harvested, "planted": planted, "crop_days": crop_days}
	if SaveManager.save_game(SAVE_SLOT, data):
		_show_message("Jogo salvo no espaço %d!" % SAVE_SLOT)
	else:
		_show_message("Não foi possível salvar. Verifique o espaço em disco.")

func _show_message(value: String) -> void:
	if message_label != null:
		message_label.text = value

func _interact() -> void:
	if player.position.y > 285 and player.position.y < 380 and player.position.x > 105 and player.position.x < 835:
		var plot := clampi(int((player.position.x - 120.0) / 105.0), 0, 3)
		if planted[plot] and crop_days[plot] >= 2:
			planted[plot] = false
			crop_days[plot] = 0
			_refresh_crop_visuals()
			harvested += 1
			money += 18
			_show_message("Colheita feita! Você vendeu a produção por $ 18.")
		elif planted[plot]:
			_show_message("A plantação ainda está crescendo. Espere mais %d dia(s)." % (2 - crop_days[plot]))
		elif seeds > 0:
			seeds -= 1
			planted[plot] = true
			crop_days[plot] = 0
			_refresh_crop_visuals()
			_show_message("Semente plantada. Avance o dia com X / N para acompanhar o cultivo.")
		else:
			_show_message("Você não tem sementes. Por enquanto, explore e volte depois.")
	else:
		_show_message("O sítio é seu novo lar. Aproxime-se dos canteiros para plantar e colher.")

func _advance_day() -> void:
	day += 1
	for i in range(planted.size()):
		if planted[i]:
			crop_days[i] += 1
			money += 4
	_update_hud()
	_show_message("Um novo dia começa em Mulungu. As plantações cresceram um pouco!")

func _update_hud() -> void:
	if hud_label != null:
		hud_label.text = "MULUNGU  •  Dia %d  •  $ %d  •  Sementes: %d  •  Colheitas: %d  |  A: agir  X/N: dia  LB/Tab: bolsa  Y/I: salvar" % [day, money, seeds, harvested]
	_update_inventory()

func _update_inventory() -> void:
	if inventory_label != null:
		inventory_label.text = "MOCHILA\n\nSementes: %d\nColheitas realizadas: %d\nDinheiro: $ %d\n\nLB / Tab para fechar" % [seeds, harvested, money]

func _refresh_crop_visuals() -> void:
	for old_visual in crop_visuals:
		if is_instance_valid(old_visual):
			old_visual.queue_free()
	crop_visuals.clear()
	for i in range(planted.size()):
		if not planted[i]:
			continue
		var plant := Node2D.new()
		plant.position = Vector2(161 + i * 105, 334)
		var mature := crop_days[i] >= 2
		plant.z_index = 4
		add_child(plant)
		var stem := Polygon2D.new()
		stem.polygon = PackedVector2Array([Vector2(-3, 13), Vector2(3, 13), Vector2(2, -7), Vector2(-2, -7)])
		stem.color = Color("#6f9b45" if mature else "#9a9b4f")
		plant.add_child(stem)
		var leaf_left := Polygon2D.new()
		leaf_left.polygon = PackedVector2Array([Vector2(-1, 2), Vector2(-15, -5), Vector2(-4, -8)])
		leaf_left.color = Color("#8eb65b" if mature else "#b3a65a")
		plant.add_child(leaf_left)
		var leaf_right := Polygon2D.new()
		leaf_right.polygon = PackedVector2Array([Vector2(1, -1), Vector2(14, -9), Vector2(5, -10)])
		leaf_right.color = Color("#9abd62" if mature else "#c0b46a")
		plant.add_child(leaf_right)
		crop_visuals.append(plant)
