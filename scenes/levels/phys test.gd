extends Node2D

export(Vector2) var camera_correction_scale = Vector2(1920,1080)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func recieve_3d_camera_position(pos):
	$Camera2D.global_position.x = 1000.0*pos.x
	$Camera2D.global_position.y = -1000.0*pos.y
	var x_factor = camera_correction_scale.x/1000
	var y_factor = camera_correction_scale.y/1000
	$Camera2D.zoom = Vector2(pos.z*x_factor,pos.z*y_factor)
