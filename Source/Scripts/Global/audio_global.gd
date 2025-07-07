extends Node2D
var lastNameSt = "empty"

func _stop_st():
	
	$SoundTrack.stop()
	
func _play_st(nameSt:String):
	if lastNameSt!=nameSt:
		lastNameSt = nameSt
		match nameSt:
			"game":
				$SoundTrack.stream = load("res://Audio/sound_track/freepik-arcade-escape.mp3")
			"menu":
				$SoundTrack.stream = load("res://Audio/sound_track/freepik-fighters-game.mp3")
		$SoundTrack.play()
	
	
