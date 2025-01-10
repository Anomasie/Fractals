class_name Contraction

var translation = Vector2.ZERO
var contract = Vector2(0.5,0.5)
var rotation = 0
var mirrored = false
var color = Color.BLACK

func apply(p):
	if p is Vector2:
		if mirrored:
			p.x *= -1 # mirror
		p = Vector2(p.x * contract.x, p.y * contract.y) # scale
		p = p.rotated(-rotation) # rotate
		p += translation # translate
		return p
	elif p is Contraction: # return self ° p
		var result = from_matrix(Math.matrix_mult(self.to_matrix(), p.to_matrix()))
		result.translation = self.apply(p.translation)
		result.color = mix(p.color)
		return result
	elif p is Array:
		var systems = []
		for system in p:
			systems.append(self.apply(system))
		return systems

func mix(c):
	c.r = linear(c.r, color.r)
	c.g = linear(c.g, color.g)
	c.b = linear(c.b, color.b)
	return c

func linear(a, b, lambda=0.5):
	return lambda * a + (1 - lambda) * b

# matrix

func to_matrix():
	var vec_x = Vector2(1,0)
	var vec_y = Vector2(0,1)
	vec_x = (vec_x * contract.x).rotated(-rotation)
	vec_y = (vec_y * contract.y).rotated(-rotation)
	if mirrored:
		vec_x *= -1
	var array = [vec_x.x, vec_x.y, vec_y.x, vec_y.y]
	return array

static func from_matrix(array):
	var result = Contraction.new()
	result.contract = contraction_from_matrix(array)
	result.rotation = rotation_from_matrix(array)
	result.mirrored = mirrored_from_matrix(array)
	return result # WARNING: Does not have a translation or a color yet

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
	var rot = (matrix * Vector2(1,0)).angle()
	# mirroring
	if mirrored_from_matrix(array):
		rot += PI
	return -rot

static func mirrored_from_matrix(array):
	# not the right format? -> return
	if typeof(array) != TYPE_ARRAY or len(array) != 4:
		return Vector2.ZERO
	# right format :)
	## use determinant
	return (array[0] * array[3] - array[1] * array[2] < 0)

static func nearest_allowed_matrix(array, unchangeable_index=0):
	if array[0] * array[2] + array[1] * array[3] == 0:
		return array
	else:
		var vec_x = Vector2(array[0], array[1])
		var vec_y = Vector2(array[2], array[3])
		if unchangeable_index in [0,1]:
			vec_y = vec_y.project(vec_x.orthogonal())
		elif unchangeable_index == 2:
			if vec_x.y != 0:
				vec_y.y = - vec_x.x * vec_y.x / vec_x.y
			else:
				vec_x = vec_x.project(vec_y.orthogonal())
		else:
			if vec_x.x != 0:
				vec_y.x = - vec_x.y * vec_y.y / vec_x.x
			else:
				vec_x = vec_x.project(vec_y.orthogonal())
		return [vec_x.x, vec_x.y, vec_y.x, vec_y.y]
