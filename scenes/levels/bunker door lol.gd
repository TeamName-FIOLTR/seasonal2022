extends Spatial



export(bool) var yeah_player_is_here = false
export(bool) var yes_i_do_want_package = false setget set_yes_please_package
export(bool) var but_do_they_gots_the_goods_tho = false
export(bool) var start_doing_the_thing
export(float) var thingy_chance = 0.3
export(float) var thingy_chance_with_a_side_of_oh_god_were_burning = 0.1
export(float) var the_cooler_daniel_of_probability = 0
export(float) var patience = 1
#export(bool) var DOOR_OPENEDDD = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_yes_please_package(n_i_do):
	yes_i_do_want_package = n_i_do
	if not is_inside_tree(): yield(self, "ready")
	if yes_i_do_want_package:
		$"bunker animations yeah".play("OPEN")
	else:
		$"bunker animations yeah".play("CLOSE")
#		$"Door Sound Close Yeah".play()
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = patience
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func check_the_whole_package_thing():
	if yes_i_do_want_package and yeah_player_is_here and but_do_they_gots_the_goods_tho:
		get_tree().call_group("Player", "recieve_package_taken", 1)
		self.yes_i_do_want_package = false
		get_tree().call_group("Player", "i_no_longer_need_the_stuff", self)
		$"Dropoff Sound".play()

func rol_ze_dice():
	var gigarealchance = lerp(thingy_chance,thingy_chance_with_a_side_of_oh_god_were_burning,the_cooler_daniel_of_probability)
	var ROLL = randf()
	if ROLL <= gigarealchance and yes_i_do_want_package == false:
		get_tree().call_group("Player", "GIVE_ME_THE_STUFF", self)
		self.yes_i_do_want_package = true
	pass

func recieve_relative_temperature(r_temp):
	the_cooler_daniel_of_probability = r_temp
	pass

func _on_package_taker_body_entered(body):
	if body is Player3D:
		print("YES")
		yeah_player_is_here = true
		but_do_they_gots_the_goods_tho = (body.packages > 0)
		check_the_whole_package_thing()
	pass # Replace with function body.


func _on_bunker_animations_yeah_animation_finished(anim_name):
	if anim_name == "OPEN":
		check_the_whole_package_thing()
	pass # Replace with function body.


func _on_package_taker_body_exited(body):
	if body is Player3D:
		print("DARN")
		yeah_player_is_here = false
	pass # Replace with function body.


func _on_Timer_timeout():
	if start_doing_the_thing:
		rol_ze_dice()
	pass # Replace with function body.
