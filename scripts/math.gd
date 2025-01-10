class_name Math

static func matrix_mult(A, B):
	return [
		A[0]*B[0] + A[1]*B[2],
		A[0]*B[1] + A[1]*B[3],
		A[2]*B[0] + A[3]*B[2],
		A[2]*B[1] + A[3]*B[3]
	]
