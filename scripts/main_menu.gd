extends Control

const GAME_SCENE := "res://scenes/game.tscn"
var selected_slot := 1
var slot_buttons: Array[Button] = []
var status_label: Label

func _ready() -> void:
	_setup_input()
	_build_ui()
	_refresh_slots()
	if slot_buttons.size() > 0:
		slot_buttons[0].grab_focus()

func _setup_input() -> void:
	if not InputMap.has_action("ui_accept"):
		InputMap.add_action("ui_accept")
	var a := InputEventJoypadButton.new()
	a.button_index = JOY_BUTTON_A
	InputMap.action_add_event("ui_accept", a)
	var b := InputEventJoypadButton.new()
	b.button_index = JOY_BUTTON_B
	InputMap.action_add_event("ui_cancel", b)

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#253b30")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var decor := ColorRect.new()
	decor.color = Color("#b58a55")
	decor.position = Vector2(0, 0)
	decor.size = Vector2(960, 12)
	add_child(decor)
	var title := Label.new()
	title.text = "THE PAST OF NORDESTE"
	title.position = Vector2(0, 72)
	title.size = Vector2(960, 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color("#f5e7c8"))
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Uma jornada começa no coração do Maciço de Baturité"
	subtitle.position = Vector2(0, 137)
	subtitle.size = Vector2(960, 30)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#d2c6a7"))
	add_child(subtitle)
	var panel := PanelContainer.new()
	panel.position = Vector2(290, 195)
	panel.size = Vector2(380, 260)
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 12)
	panel.add_child(list)
	var heading := Label.new()
	heading.text = "SEUS SALVAMENTOS"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color("#f5e7c8"))
	list.add_child(heading)
	for i in range(1, 4):
		var button := Button.new()
		button.custom_minimum_size = Vector2(340, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		button.focus_mode = Control.FOCUS_ALL
		button.pressed.connect(_choose_slot.bind(i))
		list.add_child(button)
		slot_buttons.append(button)
	var hint := Label.new()
	hint.text = "A / Enter: abrir   •   B / Esc: sair"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_color_override("font_color", Color("#d2c6a7"))
	list.add_child(hint)
	status_label = Label.new()
	status_label.position = Vector2(0, 475)
	status_label.size = Vector2(960, 28)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_color_override("font_color", Color("#f5e7c8"))
	add_child(status_label)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#405b46")
	style.border_color = Color("#b58a55")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	return style

func _refresh_slots() -> void:
	for i in range(3):
		var data := SaveManager.load_game(i + 1)
		if data.is_empty():
			slot_buttons[i].text = "ESPAÇO %d   —   Novo jogo" % (i + 1)
		else:
			var day := int(data.get("day", 1))
			var cash := int(data.get("money", 120))
			slot_buttons[i].text = "ESPAÇO %d   —   Dia %d   •   $ %d" % [i + 1, day, cash]

func _choose_slot(slot: int) -> void:
	selected_slot = slot
	SaveManager.active_slot = slot
	var data := SaveManager.load_game(slot)
	if data.is_empty():
		status_label.text = "Novo começo: o sítio da família espera por você."
	else:
		status_label.text = "Continuando sua jornada..."
	get_tree().change_scene_to_file(GAME_SCENE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		status_label.text = "Obrigado por visitar Mulungu. Você pode fechar esta janela."
