class_name Contraction

var translation = Vector2.ZERO
var contract = Vector2(0.5,0.5)
var rotation = 0
var mirrored = false
var color = Color.BLACK

func apply(p):
	p = Vector2(p.x * contract.x, p.y * contract.y) # scale
	p = p.rotated(rotation) # rotate
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
		contr.translation = dict["translation"]
	if dict.has("contract"):
		contr.contract = dict["contract"]
	if dict.has("rotation"):
		contr.rotation = dict["rotation"]
	if dict.has("mirrored"):
		contr.mirrored = dict["mirrored"]
	if dict.has("color"):
		contr.color = dict["color"]
	return contr
