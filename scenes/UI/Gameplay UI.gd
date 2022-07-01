extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(bool) var freedom_degrees
export(bool) var temperature_critical = false
export(float) var time_left = 30
export(float) var powered_off = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func recieve_player_temperature(temp):
	$VBoxContainer/Temp.text = "Temperature: %3.1f °C"%temp
	if freedom_degrees:
		$VBoxContainer/Temp.text = "Temperature: %3.1f °F"%((temp*9.0/5.0)+32)
	if temperature_critical and not powered_off:
		$VBoxContainer/Temp.text += " %3.2f SECONDS UNTIL SHUTDOWN"%time_left
	elif temperature_critical and powered_off:
		$VBoxContainer/Temp.text += " POWERED OFF UNTIL TEMPERATURES ARE SAFE"

func recieve_player_battery(batt):
	$VBoxContainer/Batt.text = "Battery: %3.1f"%batt+"%"
	

func recieve_player_deliveries(packages):
	$VBoxContainer/Deliv.text = "Shipments Served: %s"%packages


func recieve_temperature_warning(warning):
	if warning:
		$VBoxContainer/Temp.modulate = Color.red
	else:
		$VBoxContainer/Temp.modulate = Color.white

func recieve_battery_warning(warning):
	if warning:
		$VBoxContainer/Batt.modulate = Color.red
	else:
		$VBoxContainer/Batt.modulate = Color.white


func recieve_temperature_critical(crit):
	temperature_critical = crit
	if not crit:
		powered_off = false

func recieve_player_overheat_time_left(t_left):
	time_left = t_left


func recieve_thermal_shutdown():
	powered_off = true
