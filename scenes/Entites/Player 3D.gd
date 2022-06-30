extends RigidBody

#export(Vector2) var velocity = Vector2.ZERO
#export(Vector2) var gravity = Vector2(0,980)
export(NodePath) var left_thruster_node
export(NodePath) var right_thruster_node
export(Vector2) var input_vector = Vector2.ZERO
#export(float) var speed = 100
#export(float) var jump_speed = 1000
export(float) var thrust = 1
export(float) var thrust_left = 0
export(float) var thrust_right = 0
export(float) var temperature = 50 setget set_temperature
export(float) var ambient_temperature = 20
export(float) var battery = 100 setget set_battery
export(float) var heating_rate = 0.1
export(float) var thruster_heating_rate = 0.03
export(float) var thruster_battery_use = 0.3
export(float) var battery_change = 0
export(float) var temperature_change = 0
export(bool) var powered_on = true
export(float) var powered_heating_rate = 0.5
export(float) var powered_battery_use = 0.01

onready var left_thruster_position = get_node(left_thruster_node).translation
onready var right_thruster_position = get_node(right_thruster_node).translation
onready var left_thruster_transform = get_node(left_thruster_node).global_transform
onready var right_thruster_transform = get_node(right_thruster_node).global_transform

func set_temperature(n_temp):
	temperature = n_temp
	get_tree().call_group("Player Status Recievers", "recieve_player_temperature", temperature)

func set_battery(n_batt):
	battery = n_batt
	get_tree().call_group("Player Status Recievers", "recieve_player_battery", battery)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	apply_impulse(Vector3.ZERO,Vector3(1,0,0))
	pass # Replace with function body.


func _process(delta):
	var thruster_use = thrust_left+thrust_right
	temperature_change = float(powered_on)*powered_heating_rate+(ambient_temperature-temperature)*abs(heating_rate)
	battery_change = -(float(powered_on)*powered_battery_use+thruster_battery_use*thruster_use)
	self.temperature += temperature_change*delta
	self.battery = clamp(battery+battery_change*delta,0,100)
	pass


func _physics_process(delta):
	
	var left_thrust_vector = thrust_left*thrust*delta*Vector3.UP
	var right_thrust_vector = thrust_right*thrust*delta*Vector3.UP
	
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


func _input(event):
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left","move_right","move_up", "move_down")
		thrust_right = Input.get_action_strength("thruster_left")
		thrust_left = Input.get_action_strength("thruster_right")
	if event.is_action_pressed("ui_accept"):
		apply_impulse(Vector3.ZERO, Vector3.RIGHT+Vector3.UP)
