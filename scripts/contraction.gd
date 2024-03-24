class_name Contraction

var translation = Vector2.ZERO
var contract = Vector2(0.5,0.5)
var rotation = 0
var mirrored = false
var color = Color.BLACK

func apply(p):
	if mirrored:
		p = Vector2(1.0 - p.x, p.y) # mirror
	p = Vector2(p.x * contract.x, p.y * contract.y) # scale
	p = p.rotated(-rotation) # rotate
	p += translation # translate
	return p

func mix(c):
	c.r = linear(c.r, color.r)
	c.g = linear(c.g, color.g)
	c.b = linear(c.b, color.b)
	return c

func linear(a, b, lambda=0.5):
	return lambda * a + (1 - lambda) * b

# dict

static func from_dict(dict):
	var contr = Contraction.new()
	if dict.has("translation"):
		contr.translation = Vector2(
			dict["translation"].x,
			dict["translation"].y
		)
	if dict.has("contract"):
		contr.contract = dict["contract"]
	if dict.has("rotation"):
		contr.rotation = dict["rotation"]
	if dict.has("mirrored"):
		contr.mirrored = dict["mirrored"]
	if dict.has("color"):
		contr.color = dict["color"]
	return contr

# matrix

static func contraction_from_matrix(array):
	# not the right format? -> return
	if typeof(array) != TYPE_ARRAY or len(array) != 4:
		return Vector2.ZERO
	# right format :)
	# get matrix
	var matrix = Transform2D(
		Vector2(array[0], array[1]),
		Vector2(array[2], array[3]),
		Vector2.ZERO
	)
	# contraction
	return Vector2(
		(matrix * Vector2(1,0)).length(),
		(matrix * Vector2(0,1)).length()
	)

static func rotation_from_matrix(array):
	# not the right format? -> return
	if typeof(array) != TYPE_ARRAY or len(array) != 4:
		return Vector2.ZERO
	# right format :)
	# get matrix
	var matrix = Transform2D(
		Vector2(array[0], array[1]),
		Vector2(array[2], array[3]),
		Vector2.ZERO
	)
	# rotation
	var rotation = (matrix * Vector2(1,0)).angle()
	# mirroring?
	## calculate determinant
	var mirrored = (matrix.x.x * matrix.y.y - matrix.x.y * matrix.y.x) < 0
	if mirrored:
		rotation = PI - rotation
	return rotation

static func mirrored_from_matrix(array):
	# not the right format? -> return
	if typeof(array) != TYPE_ARRAY or len(array) != 4:
		return Vector2.ZERO
	# right format :)
	## use determinant
	return (array[0] * array[3] - array[1] * array[2]) < 0
