extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Vector2) var input_vector
export(float) var forwards_vector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_vec = input_vector*delta
	var complete_vector = Vector3(move_vec.x,move_vec.y,forwards_vector*delta)
#	$Camera.global_transform.origin.x += move_vec.x
#	$Camera.global_transform.origin.y += move_vec.y
	$Camera.global_transform.origin += complete_vector
	$Camera.global_transform.origin.z = max($Camera.global_transform.origin.z,0.001)
	var pos = $Camera.global_transform.origin
	get_tree().call_group("Camera Data Recievers", "recieve_3d_camera_position", pos)
#	pass

func recieve_player_position(pos):
	return
	var campos = $Camera.global_transform.origin
	$Camera.global_transform.origin.x = pos.x/1000
	$Camera.global_transform.origin.y = -pos.y/1000
#	campos.linear_interpolate()

func _input(event):
	$Viewport.input(event)
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left", "move_right", "move_down", "move_up")
		forwards_vector = Input.get_axis("move_backwards","move_forwards")
