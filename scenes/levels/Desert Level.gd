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
	$Camera/RayCast.force_raycast_update()
	var ground_pos = $Camera/RayCast.get_collision_point()+Vector3(0,1,0)
#	var space_state = get_world().direct_space_state
#	var cam_cords = $Camera.global_transform.origin
#	var result = space_state.intersect_ray(cam_cords+Vector3(0,100,0),cam_cords-Vector3(0,-500,0))
#	if result:
#		print("yeah reay hit")
#		ground_pos = result.position+Vector3(0,100,0)
#	print("ground pos")
#	print(ground_pos.y, " ", $Camera.global_transform.origin.y, " max is ", max(ground_pos.y,$Camera.global_transform.origin.y))
	$Camera.global_transform.origin.y = max(ground_pos.y,$Camera.global_transform.origin.y)
	var campos = $Camera.global_transform.origin
	get_tree().call_group("Camera Data Recievers", "recieve_3d_camera_position", campos)
#	pass
func recieve_player_position(pos):
	print("got player poz")
	print(pos)
#	camera_follow_point.x = pos.x/1000
#	camera_follow_point.y = -pos.y/1000
#	print(pos.x/1000, " ", -pos.y/1000)
#	$Camera.global_transform.origin.x = pos.x/1000
#	$Camera.global_transform.origin.y = -pos.y/1000
#	var campos = $Camera.global_transform.origin
	$Camera.global_transform.origin.x = pos.x
	$Camera.global_transform.origin.y = pos.y
#	print()


func _input(event):
#	$Viewport.input(event)
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left", "move_right", "move_down", "move_up")
		forwards_vector = Input.get_axis("move_backwards","move_forwards")

