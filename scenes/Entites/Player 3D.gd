extends RigidBody


class_name Player3D
#export(Vector2) var velocity = Vector2.ZERO
#export(Vector2) var gravity = Vector2(0,980)
export(NodePath) var left_thruster_node
export(NodePath) var right_thruster_node
export(NodePath) var left_thruster_animation_node
export(NodePath) var right_thruster_animation_node
export(NodePath) var left_thruster_audio_node
export(NodePath) var right_thruster_audio_node
export(Vector2) var input_vector = Vector2.ZERO
#export(float) var speed = 100
#export(float) var jump_speed = 1000
export(float) var thrust = 1
export(float) var thrust_left = 0
export(float) var thrust_right = 0
export(bool) var invert_thrust_left = false
export(bool) var invert_thrust_right = false
export(float, EXP, -80, 10) var thruster_max_volume_db = 0
export(float) var thruster_volume_start = 0.2
export(float) var thruster_sound_min_pitch = 0.6
export(float) var thruster_sound_max_pitch = 2.4
export(float) var temperature = 50 setget set_temperature
export(float) var ambient_temperature = 20
export(bool) var inside = false
export(float) var battery = 100 setget set_battery
export(float) var heating_rate = 0.1
export(float) var thruster_heating_rate = 0.03
export(float) var thruster_battery_use = 0.3
export(float) var battery_change = 0
export(float) var temperature_change = 0
export(bool) var powered_on = true
export(float) var powered_heating_rate = 0.5
export(float) var powered_battery_use = 0.01
export(int,0,3) var packages = 0 setget set_packages
export(int) var packages_shipped = 0
export(bool) var temperature_warning = false
export(bool) var battery_warning = false
export(bool) var temperature_critical = false

onready var left_thruster_position = get_node(left_thruster_node).translation
onready var right_thruster_position = get_node(right_thruster_node).translation
onready var left_thruster_transform = get_node(left_thruster_node).global_transform
onready var right_thruster_transform = get_node(right_thruster_node).global_transform

onready var left_thruster_animations : AnimationPlayer = get_node(left_thruster_animation_node)
onready var right_thruster_animations : AnimationPlayer = get_node(right_thruster_animation_node)

onready var left_thruster_audio : AudioStreamPlayer3D = get_node(left_thruster_audio_node)
onready var right_thruster_audio : AudioStreamPlayer3D = get_node(right_thruster_audio_node)

var ugh_beggers = []

var arrow_cheveron_owner_peopl : Dictionary = {} # i actually don't think i need this

func set_temperature(n_temp):
	temperature = n_temp
	get_tree().call_group("Player Status Recievers", "recieve_player_temperature", temperature)

func set_battery(n_batt):
	battery = n_batt
	get_tree().call_group("Player Status Recievers", "recieve_player_battery", battery)

func set_packages(n_packages):
	packages = n_packages
	if not is_inside_tree(): yield(self, "ready")
	var package_nodes_count = $Packages.get_child_count()
	for node in $Packages.get_children():
		node.visible = false
	var loopy = min(packages, package_nodes_count)
	for i in range(loopy):
		$Packages.get_child(i).visible = true

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	apply_impulse(Vector3.ZERO,Vector3(1,0,0))
	if left_thruster_animations is AnimationPlayer:
		left_thruster_animations.play("Thrust")
	if right_thruster_animations is AnimationPlayer:
		right_thruster_animations.play("Thrust")
	pass # Replace with function body.


func _process(delta):
	var thruster_use = thrust_left+thrust_right
	temperature_change = float(powered_on)*powered_heating_rate+(ambient_temperature-temperature)*abs(heating_rate)
	var battery_degridation = max(1,range_lerp(temperature, 50, 100, 1, 5))
	battery_change = 10*float(inside)-(float(powered_on)*powered_battery_use+thruster_battery_use*thruster_use)*battery_degridation
	self.temperature += temperature_change*delta
	self.battery = clamp(battery+battery_change*delta,0,100)
	
	if left_thruster_animations is AnimationPlayer:
		left_thruster_animations.playback_speed = lerp(0,10,thrust_left*(1-2*float(invert_thrust_left)))
	if right_thruster_animations is AnimationPlayer:
		right_thruster_animations.playback_speed = lerp(0,10,thrust_right*(1-2*float(invert_thrust_right)))
	update_drone_sounds(delta)
	
	if temperature >= 90 and not temperature_warning:
		temperature_warning = true
		$"Warning Beep".play()
		get_tree().call_group("Player Status Recievers", "recieve_temperature_warning", true)
	elif temperature < 90 and temperature_warning:
		temperature_warning = false
		get_tree().call_group("Player Status Recievers", "recieve_temperature_warning", false)
	
	if battery <= 25 and not battery_warning:
		battery_warning = true
		$"Warning Beep".play()
		get_tree().call_group("Player Status Recievers", "recieve_battery_warning", true)
	elif battery > 25 and battery_warning:
		battery_warning = false
		get_tree().call_group("Player Status Recievers", "recieve_battery_warning", false)
	
	if battery == 0 and powered_on:
		$"Warning Beep".play()
		self.powered_on = false
	pass
	
	if temperature > 110 and $"Overheat Timer".is_stopped() and powered_on and not temperature_critical:
		$"Overheat Timer".start()
		$"Warning Beep".play()
		temperature_critical = true
		get_tree().call_group("Player Status Recievers", "recieve_temperature_critical", true)
	if not $"Overheat Timer".is_stopped():
		get_tree().call_group("Player Status Recievers", "recieve_player_overheat_time_left", $"Overheat Timer".time_left)
	if temperature_critical and temperature <= 70 and not powered_on:
		temperature_critical = false
		$"Overheat Timer".stop()
		$"Overheat Timer".wait_time = 30
		powered_on = true
		$"Warning Beep".play()
		get_tree().call_group("Player Status Recievers", "recieve_temperature_critical", false)

func _physics_process(delta):
	
	var left_thrust_vector = thrust_left*thrust*delta*Vector3.UP*(1-2*float(invert_thrust_left))
	var right_thrust_vector = thrust_right*thrust*delta*Vector3.UP*(1-2*float(invert_thrust_right))
	
	var left_thrust_pos = global_transform.basis*left_thruster_position
	var right_thrust_pos = global_transform.basis*right_thruster_position
	
	var left_thrust_force = global_transform.basis*left_thrust_vector
	var right_thrust_force = global_transform.basis*right_thrust_vector
	
	apply_impulse(left_thrust_pos,left_thrust_force)
	apply_impulse(right_thrust_pos,right_thrust_force)
#	pass
#	left_thruster_transform = get_node(left_thruster_node).global_transform
#	right_thruster_transform = get_node(right_thruster_node).global_transform
#	var left_thrust_vector = global_transform.basis*(thrust_left*thrust*delta*Vector3.UP)
#	var right_thrust_vector = global_transform.basis*(thrust_right*thrust*delta*Vector3.UP)
#	print("\n\n")
#	print("left",  left_thruster_position, left_thrust_vector)
#	print("right", right_thruster_position,right_thrust_vector)
#	apply_impulse(left_thruster_position,left_thrust_vector)
#	apply_impulse(right_thruster_position,right_thrust_vector)
#	print("angular velocity ", angular_velocity)
#	print("regular velocity ", linear_velocity)
#	print("global position ", global_transform.origin)
	get_tree().call_group("Player Status Recievers", "recieve_player_position", self.global_transform.origin)


func update_drone_sounds(delta = 1/60.0):
	var linar_vol = db2linear(thruster_max_volume_db)
#	if left_thruster_audio is AudioStreamPlayer3D:
#		pass
	var left_thrust_vol = range_lerp(thrust_left,thruster_volume_start,1.0,0,linar_vol)
	#	print("left thrust vol ", linear2db(max(left_thrust_vol,0)))
	left_thruster_audio.unit_db = linear2db(max(left_thrust_vol,0))
#	if right_thruster_audio is AudioStreamPlayer3D:
#		pass
	var right_thrust_vol = range_lerp(thrust_right,thruster_volume_start,1.0,0,linar_vol)
	right_thruster_audio.unit_db = linear2db(max(right_thrust_vol,0))
	var left_thruster_audio_new_pitch = range_lerp(thrust_left,thruster_volume_start,1.0,thruster_sound_min_pitch,thruster_sound_max_pitch)
	var right_thruster_audio_new_pitch = range_lerp(thrust_right,thruster_volume_start,1.0,thruster_sound_min_pitch,thruster_sound_max_pitch)
	var pitch_scaler_speeeeed = 10
	if left_thruster_audio_new_pitch < left_thruster_audio.pitch_scale:
		var thasdfj = 4.84
		
#		thasdfj.linear_interpolate()
		left_thruster_audio.pitch_scale = lerp(left_thruster_audio.pitch_scale,left_thruster_audio_new_pitch,pitch_scaler_speeeeed*delta)
	else:
		left_thruster_audio.pitch_scale = left_thruster_audio_new_pitch
	
	if right_thruster_audio_new_pitch < right_thruster_audio.pitch_scale:
		var thasdfj = 4.84
		
#		thasdfj.linear_interpolate()
		right_thruster_audio.pitch_scale = lerp(right_thruster_audio.pitch_scale,right_thruster_audio_new_pitch,pitch_scaler_speeeeed*delta)
	else:
		right_thruster_audio.pitch_scale = right_thruster_audio_new_pitch
	pass


func _input(event):
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left","move_right","move_up", "move_down")
		thrust_right = Input.get_action_strength("thruster_left")*float(powered_on)
		thrust_left = Input.get_action_strength("thruster_right")*float(powered_on)
#	if event.is_action_pressed("ui_accept"):
#		apply_impulse(Vector3.ZERO, Vector3.RIGHT+Vector3.UP)
	if event.is_action("invert_left_thrust"):
		invert_thrust_left = event.is_pressed()
	if event.is_action("invert_right_thrust"):
		invert_thrust_right = event.is_pressed()

func recieve_package_taken(packages_taken):
	self.packages = max(0,packages-packages_taken)
	packages_shipped += packages_taken
	get_tree().call_group("Player Status Recievers", "recieve_player_deliveries", packages_shipped)

func recieve_ambient_temperature(temp):
	if not inside:
		self.ambient_temperature = temp
		

func GIVE_ME_THE_STUFF(begger):
	if not begger in ugh_beggers:
		ugh_beggers.append(begger)
		get_tree().call_group("Player Status Recievers", "recieve_beggers_array", ugh_beggers)
		print("OI M80 I AWNT SOME OF THAT UHHH FRIEDDDDDDD saNd")
	pass


func i_no_longer_need_the_stuff(begger):
	if begger in ugh_beggers:
		ugh_beggers.erase(begger)
		get_tree().call_group("Player Status Recievers", "recieve_beggers_array", ugh_beggers)


func _on_Overheat_Timer_timeout():
	self.powered_on = false
	$"Warning Beep".play()
	get_tree().call_group("Player Status Recievers", "recieve_thermal_shutdown")
	pass # Replace with function body.
