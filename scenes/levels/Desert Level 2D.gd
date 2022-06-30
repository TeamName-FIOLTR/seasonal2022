extends Node2D

export(NodePath) var camera_2d_node
export(Vector2) var camera_correction_scale = Vector2(1040,1040)
onready var camera_2d = get_node(camera_2d_node)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func recieve_3d_camera_position(cam_pos):
#	print("2d cam got pos yeah ", cam_pos)
	camera_2d.global_position.x = cam_pos.x*1000.0
	camera_2d.global_position.y = -cam_pos.y*1000.0
	camera_2d.zoom = Vector2(cam_pos.z, cam_pos.z)*camera_correction_scale/1000.0
	
