class_name Math

#const VECTOR_EPSILON = 0.00001

static func matrix_mult(A, B):
	return [
		A[0]*B[0] + A[1]*B[2],
		A[0]*B[1] + A[1]*B[3],
		A[2]*B[0] + A[3]*B[2],
		A[2]*B[1] + A[3]*B[3]
	]

static func are_equal_approx(A, B):
	if typeof(A) != typeof(B):
		print("WARNING in Math.are_equal_approx: object ", A, " and object ", B, " do not have the same type (", typeof(A), " != ", typeof(B), ")")
	elif typeof(A) == TYPE_COLOR:
		var col1 = Vector3(A.r, A.g, A.b)
		var col2 = Vector3(B.r, B.g, B.b)
		return (col1 - col2).length() < 1.0 / 250
