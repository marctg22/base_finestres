extends Node
class_name TabController

@export_node_path("TabContainer") var tab_container_path: NodePath
@export_node_path("Button") var btn_next_path: NodePath
@export_node_path("Button") var btn_prev_path: NodePath
@export_node_path("Button") var btn_close_path: NodePath

@onready var tabs: TabContainer = get_node(tab_container_path) if tab_container_path != NodePath("") else null
@onready var btn_next: Button = get_node(btn_next_path) if btn_next_path != NodePath("") else null
@onready var btn_prev: Button = get_node(btn_prev_path) if btn_prev_path != NodePath("") else null
@onready var btn_close: Button = get_node(btn_close_path) if btn_close_path != NodePath("") else null

func _ready() -> void:
	# Comprova si les accions d'InputMap existeixen; si no, avisem l'usuari.
	if not InputMap.has_action("window_next") or not InputMap.has_action("window_prev"):
		push_warning("TabController: Les accions 'window_next' i/o 'window_prev' no existeixen. Afegeix-les a Project Settings > Input Map per habilitar atalls de teclat.")
	# Connecta botons
	if btn_next:
		btn_next.pressed.connect(Callable(self, "_on_next_pressed"))
	if btn_prev:
		btn_prev.pressed.connect(Callable(self, "_on_prev_pressed"))
	if btn_close:
		btn_close.pressed.connect(Callable(self, "_on_close_pressed"))

	if not tabs:
		push_error("TabController: tab_container_path no assignat o és invàlid.")

# Afegir una instància (Control) com a nova pestanya i posar-li títol
func add_window(instance: Control, title: String="Window") -> void:
	if not tabs:
		return
	tabs.add_child(instance)
	var idx := tabs.get_tab_count() - 1
	if idx >= 0:
		tabs.set_tab_title(idx, title)
	# Connecta la senyal request_close (ara la senyal envia la mateixa instància)
	if instance.has_signal("request_close"):
		instance.connect("request_close", Callable(self, "_on_tab_request_close"))
	tabs.current_tab = idx

func add_window_from_scene(scene: PackedScene, title: String="Window") -> Control:
	var inst := scene.instantiate() as Control
	add_window(inst, title)
	return inst

func _on_next_pressed() -> void:
	next_window()

func _on_prev_pressed() -> void:
	prev_window()

func _on_close_pressed() -> void:
	close_current()

func next_window() -> void:
	if not tabs:
		return
	var count := tabs.get_tab_count()
	if count == 0:
		return
	tabs.current_tab = (tabs.current_tab + 1) % count

func prev_window() -> void:
	if not tabs:
		return
	var count := tabs.get_tab_count()
	if count == 0:
		return
	tabs.current_tab = (tabs.current_tab - 1 + count) % count

func close_current() -> void:
	if not tabs:
		return
	var idx := tabs.current_tab
	if idx < 0 or idx >= tabs.get_tab_count():
		return
	var child := tabs.get_child(idx)
	if is_instance_valid(child):
		child.queue_free()

# Callback rep la finestra com a paràmetre
func _on_tab_request_close(tab: Control) -> void:
	if is_instance_valid(tab):
		tab.queue_free()

# Input: només respon si l'acció existeix (evita assertions)
func _input(event: InputEvent) -> void:
	if InputMap.has_action("window_next") and event.is_action_released("window_next"):
		next_window()
	elif InputMap.has_action("window_prev") and event.is_action_released("window_prev"):
		prev_window()
