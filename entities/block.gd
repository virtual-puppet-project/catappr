class_name Block
extends Polygon2D

var dampening: float = 1.0

var _image_size := Vector2i.ZERO
var _image_parent_ratio := Vector2.ZERO

var _parent_size := Vector2i.ZERO

var _starting_position := Vector2.ZERO

var _children: Array[Block] = []

#-----------------------------------------------------------------------------#
# Builtin functions
#-----------------------------------------------------------------------------#

func _init(image: Image, parent_size: Vector2i = Vector2i.ZERO) -> void:
	_parent_size = parent_size if parent_size != Vector2i.ZERO else DisplayServer.window_get_size()
	
	texture = ImageTexture.create_from_image(image)
	
	_image_size = image.get_size()
	offset = -_image_size / 2.0
	
	_image_parent_ratio = Vector2(_image_size) / Vector2(_parent_size)
	
	var image_mapping := PackedVector2Array()
	
	# 0
	image_mapping.append(Vector2(0.0, 0.0))
	# 1
	image_mapping.append(Vector2(_image_size.x / 2.0, 0.0))
	# 2
	image_mapping.append(Vector2(_image_size.x, 0.0))
	# 3
	image_mapping.append(Vector2(_image_size.x, _image_size.y / 2.0))
	# 4
	image_mapping.append(Vector2(_image_size.x, _image_size.y))
	# 5
	image_mapping.append(Vector2(_image_size.x / 2.0, _image_size.y))
	# 6
	image_mapping.append(Vector2(0.0, _image_size.y))
	# 7
	image_mapping.append(Vector2(0.0, _image_size.y / 2.0))
	# 8
	image_mapping.append(Vector2(_image_size.x / 2.0, _image_size.y / 2.0))
	
	polygon = image_mapping
	uv = image_mapping
	
	_create_polygon(0 ,1, 8 ,7)
	_create_polygon(1, 2, 3, 8)
	_create_polygon(8, 3, 4, 5)
	_create_polygon(7, 8, 5, 6)

#-----------------------------------------------------------------------------#
# Private functions
#-----------------------------------------------------------------------------#

func _create_polygon(top_left: int, top_right: int, bot_right: int, bot_left: int) -> void:
	polygons.append(PackedInt32Array([
		top_left, top_right,
		bot_right, bot_left
	]))

#-----------------------------------------------------------------------------#
# Public functions
#-----------------------------------------------------------------------------#

func cache_children() -> void:
	_starting_position = global_position
	for child in get_children():
		_children.append(child)
		child.cache_children()

func apply(tx: Vector2, rx: Vector2) -> void:
	var scaled_rx: Vector2 = rx * _image_parent_ratio
	
	polygon[1].x = max(0, min(scaled_rx.x, _image_size.x))
	polygon[5].x = max(0, min(scaled_rx.x, _image_size.x))

	polygon[3].y = max(0, min(scaled_rx.y, _image_size.y))
	polygon[7].y = max(0, min(scaled_rx.y, _image_size.y))

	polygon[8] = scaled_rx.clamp(Vector2.ZERO, _image_size)
	
	global_position = _starting_position + tx
	
	for child in _children:
		child.apply(tx + (scaled_rx * 0.5), scaled_rx)
