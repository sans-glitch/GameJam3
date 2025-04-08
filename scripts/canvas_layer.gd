extends CanvasLayer


func _on_texture_button_pressed():
	await get_tree().create_timer(.1).timeout
	$Title.hide()
	Dialogic.start("start_game")	
	
