extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(bool) var PLAYER_IS_GONE = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Interiar_body_entered(body):
	if body is Player3D:
		body.inside = true
		body.ambient_temperature = 21.21
		PLAYER_IS_GONE = false
	pass # Replace with function body.


func _on_Interiar_body_exited(body):
	if body is Player3D:
		body.inside = false
#		PLAYER_IS_GONE = false
	pass # Replace with function body.


func _on_door_open_area_body_entered(body):
	if body is Player3D:
		if body.packages > 0:
			$AnimationPlayer.play("dooropen")
		else:
			$AnimationPlayer.play_backwards("dooropen")
	pass # Replace with function body.


func _on_giv_gift_body_entered(body):
	if body is Player3D:
		body.packages = 3
	pass # Replace with function body.


func _on_door_open_area_body_exited(body):
	pass # Replace with function body.


func _on_outside_let_me_iiiin_area_body_entered(body):
	if body is Player3D:
		if body.packages > 0 and (not body.inside) and PLAYER_IS_GONE:
			$AnimationPlayer.play_backwards("dooropen")
		else:
			$AnimationPlayer.play("dooropen")
	pass # Replace with function body.


func _on_outside_let_me_iiiin_area_body_exited(body):
	if body is Player3D:
		if not body.inside:
			pass
#			$AnimationPlayer.play_backwards("dooropen")
	pass # Replace with function body.


func _on_CONFIRM_THAT_THE_PLAYER_HAS_INFACT_LEFT_THE_BUILDING_body_exited(body):
	if body is Player3D:
		if not PLAYER_IS_GONE:
			PLAYER_IS_GONE = true
			$AnimationPlayer.play_backwards("dooropen")
		pass
	pass # Replace with function body.
