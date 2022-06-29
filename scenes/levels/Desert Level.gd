extends Spatial


export(NodePath) var camera_3d_node
export(Vector3) var camera_follow_point
export(float) var camera_follow_speed = 10
onready var camera_3d : Camera = get_node(camera_3d_node)

export(Vector2) var input_vector
export(float) var forwards_vector
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var move_vec = input_vector*delta
	var complete_vector = Vector3(move_vec.x,move_vec.y,forwards_vector*delta)
#	var campos = (camera_3d as Camera).global_transform.origin
#	camera_3d.global_transform.origin = campos.linear_interpolate(camera_follow_point, camera_follow_speed*delta)
	$Camera.global_transform.origin += complete_vector
	$Camera.global_transform.origin.z = max($Camera.global_transform.origin.z,0.001)
	var campos = $Camera.global_transform.origin
	get_tree().call_group("Camera Data Recievers", "recieve_3d_camera_position", campos)
#	pass
func recieve_player_position(pos):
	print("got player poz")
#	camera_follow_point.x = pos.x/1000
#	camera_follow_point.y = -pos.y/1000
	print(pos.x/1000, " ", -pos.y/1000)
	$Camera.global_transform.origin.x = pos.x/1000
	$Camera.global_transform.origin.y = -pos.y/1000
	var campos = $Camera.global_transform.origin
#	print()


func _input(event):
	$Viewport.input(event)
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left", "move_right", "move_down", "move_up")
		forwards_vector = Input.get_axis("move_backwards","move_forwards")

