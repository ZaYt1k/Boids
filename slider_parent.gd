extends VBoxContainer

func _process(delta: float) -> void:
	$Value.text = str($HSlider.value)
