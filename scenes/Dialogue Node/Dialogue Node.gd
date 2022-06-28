extends Control

class_name DialogueNode

enum DIALOGUE_WRITE_MODE{
	CONSTANT_TIME,
	CONSTANT_SPEED
}

enum DIALOGUE_SOUND_PLAYS{
	ONCE,
	EACH_LETTER
}

export(NodePath) var next_dialogue_node
export(NodePath) var visibility_target
export(int,0) var next_dialogue_index
export(DIALOGUE_WRITE_MODE) var dialogue_write_mode = DIALOGUE_WRITE_MODE.CONSTANT_TIME
export(float) var letter_speed = 10.0
export(float) var dialogue_time = 1.0
export(NodePath) var dialogue_text_node

var dialogue_finished : bool = false

onready var text_node : Label = get_node_or_null(dialogue_text_node)
onready var next_dialogue : DialogueNode = get_node_or_null(next_dialogue_node)

signal dialogue_started
signal dialogue_finished
signal dialogue_scene_ended
signal dialogue_next
signal dialogue_prev

func _ready():
	dialogue_finished = false
#	visible = false

var t = 0
func _process(delta):
	if !dialogue_finished:
		if text_node is Label:
			var letter_count = len(text_node.text)
			match dialogue_write_mode:
				DIALOGUE_WRITE_MODE.CONSTANT_SPEED:
					text_node.visible_characters = int(t*letter_speed)
					if text_node.visible_characters >= letter_count:
						dialogue_finished = true
						emit_signal("dialogue_finished")
				DIALOGUE_WRITE_MODE.CONSTANT_TIME:
					var amount = 1
					if dialogue_time > 0:
						amount = t/dialogue_time
					text_node.percent_visible = clamp(amount,0,1)
					if amount >= 1:
						dialogue_finished = true
						emit_signal("dialogue_finished")
		t += delta
	pass

func focused():
	visible = true
	get_node(visibility_target).visible = true
	dialogue_finished = false
	t = 0
	text_node.visible_characters = 0
	text_node.percent_visible = 0
	emit_signal("dialogue_started")
	pass

func unfocused():
#	visible = false
	get_node(visibility_target).visible=false
	pass

func next():
	if next_dialogue:
		next_dialogue.grab_focus()
		
	else:
		var dialogue_options = get_dialogue_children()
		if next_dialogue_index < len(dialogue_options):
			dialogue_options[next_dialogue_index].grab_focus()
	emit_signal("dialogue_next")

func get_dialogue_children():
	var nodes = []
	for node in get_children():
		if node.has_method("get_dialogue_children"):
			nodes.append(node)
	return nodes

func _on_Dialogue_Node_gui_input(event : InputEvent):
	print(event)
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_right"):
		next()
	pass # Replace with function body.


func _on_Dialogue_Node_focus_exited():
	unfocused()
	pass # Replace with function body.


func _on_Dialogue_Node_focus_entered():
	focused()
	pass # Replace with function body.
