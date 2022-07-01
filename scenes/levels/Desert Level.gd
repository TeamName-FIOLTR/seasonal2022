extends Spatial


export(NodePath) var camera_3d_node
export(Vector3) var camera_follow_point
export(float) var camera_follow_speed = 10
onready var camera_3d : Camera = get_node(camera_3d_node)

export(Vector2) var input_vector
export(float) var forwards_vector

export(float) var temp_mixer = 0
export(float) var coldest_temp = 30
export(float) var hottest_temp = 130

export(NodePath) var sun_light_node
onready var the_sun : DirectionalLight = get_node(sun_light_node)
export(float) var sun_starting_horizontal_angle
export(float) var sun_ending_horizontal_angle
export(float) var sun_starting_height_angle
export(float) var sun_peak_height_angle

export(NodePath) var enviroment_thing
onready var envroyeah : WorldEnvironment = get_node(enviroment_thing)

export(Gradient) var sky_colors
export(Gradient) var horizon_colors

var beggers_on_the_level = [] #Just some beggers on the level ## actuallynvm i dont' need this either
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var shipments_served = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#	$Timer.
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
	update_temperature()
#	pass
func recieve_player_position(pos):
#	print("got player poz")
#	print(pos)
#	camera_follow_point.x = pos.x/1000
#	camera_follow_point.y = -pos.y/1000
#	print(pos.x/1000, " ", -pos.y/1000)
#	$Camera.global_transform.origin.x = pos.x/1000
#	$Camera.global_transform.origin.y = -pos.y/1000
#	var campos = $Camera.global_transform.origin
	$Camera.global_transform.origin.x = pos.x
	$Camera.global_transform.origin.y = pos.y+1
	do_the_beggy_checks(beggers_on_the_level)
#	print()


func update_temperature():
	var time_left = $Timer.time_left
	var time_at_all = $Timer.wait_time
	var temp_amount = (1.0-cos(2.0*PI*time_left/time_at_all))/2.0
	var relative_time = time_left/time_at_all
#	print(time_left, " ", temp_amount)
	var new_temp = lerp(coldest_temp,hottest_temp,temp_amount)
	get_tree().call_group("Ambient Data Recievers", "recieve_ambient_temperature", new_temp)
	get_tree().call_group("Ambient Data Recievers", "recieve_relative_temperature", temp_amount)
	$"Screen Space Shader".material.set_shader_param("Heat_Factor", temp_amount)
	if the_sun is DirectionalLight:
		the_sun.rotation_degrees.y = lerp(sun_starting_horizontal_angle,sun_ending_horizontal_angle,relative_time)
		the_sun.rotation_degrees.x = lerp(sun_starting_height_angle, sun_peak_height_angle, temp_amount)
	var sun_rel_vec = Vector3(0,0,1)
	var sun_glob_vec = the_sun.global_transform.basis*sun_rel_vec
	var longie = atan2(sun_glob_vec.x,-sun_glob_vec.z)
	var latty = asin(sun_glob_vec.y)
	if envroyeah is WorldEnvironment:
#		print(envroyeah.environment.background_sky.sun_latitude)
		envroyeah.environment.background_sky.sun_latitude = rad2deg(latty)
		envroyeah.environment.background_sky.sun_longitude = rad2deg(longie)
#		print(envroyeah.environment.background_sky.sun_latitude)
		
		var cool_color = (sky_colors as Gradient).interpolate(temp_amount)
		envroyeah.environment.background_sky.sky_top_color = cool_color
		envroyeah.environment.background_sky.ground_horizon_color = cool_color
#		envroyeah.environment.background_sky.sun_latitude = latty
#		envroyeah.environment.background_sky.sun_longitude = longie
		pass

func _input(event):
#	$Viewport.input(event)
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left", "move_right", "move_down", "move_up")
		forwards_vector = Input.get_axis("move_backwards","move_forwards")
	if event.is_action_pressed("menu"):
		$"Help Menu".visible = !$"Help Menu".visible

#func recieve_ambient_temperature(temp):
#	$"Screen Space Shader".material.set_shader_param("HeatFactor")

func recieve_beggers_array(beggarray):
	beggers_on_the_level = beggarray


func do_the_beggy_checks(beggarray):
	var do_the_left_chevy = false
	var do_the_right_chevy = false
	for begger in beggarray:
		var pos = begger.global_transform.origin
		var rel_cam_pos = camera_3d.global_transform.affine_inverse()*pos
#		Vector3.ZERO.normalized()
		var normalized_cam_pos = rel_cam_pos.normalized()
		var dotty = normalized_cam_pos.dot(Vector3(0,0,-1))
		var dotty_check = 0.8
#		print("dot product with the thing yeah ", dotty)
		if dotty <= dotty_check:
			if normalized_cam_pos.x > 0:
				do_the_right_chevy = true
			else:
				do_the_left_chevy = true
#	if do_the_left_chevy is true: #lol #wait
#		$"Camera/some of the ui weirdo stuff/chevy left".visible = true
	$"Camera/some of the ui weirdo stuff/chevy left".visible = do_the_left_chevy
	$"Camera/some of the ui weirdo stuff/chevy right".visible = do_the_right_chevy

func recieve_player_deliveries(packages):
	shipments_served = packages

func _on_Timer_timeout():
#	var thingy_next_level = preload("res://assets/shaders/You won!.tscn")
	if $"Player 3D".battery > 0:
#		var instance = thingy_next_level.instance()
#		instance.amount_of_won = shipments_served
		Globalnobel.amount_of_win = shipments_served
		get_tree().change_scene("res://assets/shaders/You won!.tscn")
#		get_tree().change_scene_to(instance)
	pass # Replace with function body.
