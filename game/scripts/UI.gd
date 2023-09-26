extends Control

signal enable_power
signal restart


func restart():
	$NextButton.hide()
	$OverLabel.hide()


func show_win():
	$NextButton.show()
	$OverLabel.show()
	$OverLabel.text = "Winner :D"


func show_game_over():
	$NextButton.show()
	$OverLabel.show()
	$OverLabel.text = "Loser :("


func set_power_label(power_left):
	$PowerLabel.text = "Powers left: " + str(power_left)


func _on_FireButton_pressed():
	emit_signal("enable_power", "Fire")


func _on_WindButton_pressed():
	emit_signal("enable_power", "Wind")


func _on_LightningButton_pressed():
	emit_signal("enable_power", "Lightning")


func _on_NextButton_pressed():
	restart()
	emit_signal("restart")
