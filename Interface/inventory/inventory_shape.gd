extends Node

enum SHAPE { SINGLE, LINE1x2, LINE1x3, LINE1x4, BOX2x2, BOX3x2 }
enum ROTATION { ZERO, D90, D180, D270 }

const single_blocks = [
	[[ true ]], # 0

	[[ true ]], # 90

	[[ true ]], # 180

	[[ true ]]  # 270
	]

const line1x2_blocks = [
	[[ true ],
	 [ true ]],

	[[ true, true ]],

	[[ true ],
	 [ true ]],

	[[true, true]]
	]

const line1x3_blocks = [
	[[ true ],
	 [ true ],
	 [ true ]],

	[[ true, true, true ]],

	[[ true ],
	 [ true ],
	 [ true ]],

	[[true, true, true ]]
	]

const line1x4_blocks = [
	[[ true ],
	 [ true ],
	 [ true ],
	 [ true ]],

	[[ true, true, true, true ]],

	[[ true ],
	 [ true ],
	 [ true ],
	 [ true ]],

	[[ true, true, true, true ]]
	]

const box2x2_blocks = [
	[[ true, true ],
	 [ true, true ]],

	[[ true, true ],
	 [ true, true ]],

	[[ true, true ],
	 [ true, true ]],

	[[ true, true ],
	 [ true, true ]]
	]

const box2x3_blocks = [
	[[ true, true ],
	 [ true, true ],
	 [ true, true ]],

	[[ true, true, true ],
	 [ true, true, true ]],

	[[ true, true ],
	 [ true, true ],
	 [ true, true ]],

	[[ true, true, true ],
	 [ true, true, true ]]
	]

const blocks = [ single_blocks, line1x2_blocks, line1x3_blocks, line1x4_blocks, box2x2_blocks, box3x2_blocks ]