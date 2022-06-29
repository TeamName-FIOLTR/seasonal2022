extends RigidBody2D

#export(Vector2) var velocity = Vector2.ZERO
#export(Vector2) var gravity = Vector2(0,980)
export(Vector2) var input_vector = Vector2.ZERO
#export(float) var speed = 100
#export(float) var jump_speed = 1000
export(float) var thrust = 500
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
#export(float) var local_temperature_change = 0
var sprint_speed = 300
var sprint_amount = 0
onready var thruster_offet = $"Thruster Position".position
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func set_temperature(n_temp):
	temperature = n_temp
	get_tree().call_group("Player Status Recievers", "recieve_player_temperature", temperature)

func set_battery(n_batt):
	battery = n_batt
	get_tree().call_group("Player Status Recievers", "recieve_player_battery", battery)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var thruster_use = thrust_left+thrust_right
	temperature_change = float(powered_on)*powered_heating_rate+(ambient_temperature-temperature)*abs(heating_rate)
	battery_change = -(float(powered_on)*powered_battery_use+thruster_battery_use*thruster_use)
	self.temperature += temperature_change*delta
	self.battery = clamp(battery+battery_change*delta,0,100)
	pass
#	velocity += gravity*delta
#	velocity = input_vector*lerp(speed, sprint_speed, sprint_amount)
#	var collision = move_and_collide(velocity*delta, false)
#	if collision:
#		pass
#		velocity = move_and_slide(velocity, collision.normal, vec)
#	pass

func _physics_process(delta):
#	apply_impulse(Vector2.ZERO,input_vector*speed*delta)
	var left_thruster_offset = global_transform.basis_xform(thruster_offet*Vector2(-1,1))
	var right_thruster_offset = global_transform.basis_xform(thruster_offet*Vector2(1,1))
	var left_thruster_vector = global_transform.basis_xform(thrust_left*thrust*delta*Vector2.UP)
	var right_thruster_vector = global_transform.basis_xform(thrust_right*thrust*delta*Vector2.UP)
	apply_impulse(left_thruster_offset,left_thruster_vector)
	apply_impulse(right_thruster_offset,right_thruster_vector)
	get_tree().call_group("Player Status Recievers", "recieve_player_position", global_position)
#	add_force(Vector2.ZERO, Vector2.UP)

func _input(event):
	if event is InputEventKey or event is InputEventJoypadMotion:
		input_vector = Input.get_vector("move_left","move_right","move_up", "move_down")
		sprint_amount = Input.get_action_strength("sprint")
		thrust_right = Input.get_action_strength("thruster_left")
		thrust_left = Input.get_action_strength("thruster_right")
#	if event.is_action_pressed("jump"):
#		velocity.y = -jump_speed
