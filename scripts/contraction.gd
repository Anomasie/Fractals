class_name Contraction

var translation = Vector2i.ZERO
var contract = Vector2i(0.5,0.5)
var rotation = 0

func apply(p):
	p = Vector2(p.x * contract.x, p.y * contract.y)
	p = p.rotated(rotation)
	p += translation
	return p
