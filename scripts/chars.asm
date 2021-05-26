chars:

	.word tile_0, tile_1, tile_2, tile_3, tile_4, tile_5, tile_6, tile_7, tile_8, tile_9
	.word tile_s, tile_c, tile_o, tile_r, tile_e, tile_t, tile_i, tile_m, tile_e, tile_r
	.word tile_2, tile_0, tile_4, tile_8, tile_blank, tile_f, tile_8


tile_0:
	.byte %01110010
	.byte %10010100
	.byte %10100111
	.byte %00000000



tile_1:
	.byte %00100011
	.byte %00001000
	.byte %01000111
	.byte %00000000


tile_2:
	.byte %01110000
	.byte %10011100
	.byte %10000111
	.byte %00000000



tile_3:
	.byte %01110000
	.byte %10011100
	.byte %00100111
	.byte %00000000



tile_4:
		.byte %01000010
	.byte %10011100
	.byte %00100001
	.byte %00000000


tile_5:
		.byte %01110010
		.byte %00011100
		.byte %00100111
		.byte %00000000



tile_6:
	.byte %01110010
	.byte %00011100
	.byte %10100111
	.byte %00000000



tile_7:
		.byte %01110000
		.byte %10000100
		.byte %00100001
		.byte %00000000


tile_8:
		.byte %01110010
		.byte %10011100
		.byte %10100111
		.byte %00000000

tile_9:
	.byte %01110010
	.byte %10011100
	.byte %00100001
	.byte %00000000


tile_s:

	.byte %01110010
	.byte %00011100
	.byte %00100111
	.byte %00000000

tile_c:
	.byte %01110010
	.byte %00010000
	.byte %10000111
	.byte %00000000

tile_o:

	.byte %01110010
	.byte %10010100
	.byte %10100111
	.byte %00000000

tile_r:

	.byte %01100010
	.byte %10011000
	.byte %10100101
	.byte %00000000

tile_e:

	.byte %01110010
	.byte %00011100
	.byte %10000111
	.byte %00000000


tile_t:

		.byte %01110001	
		.byte %00001000	
		.byte %01000010	
		.byte %00000000	

tile_i:

		.byte %01110001
		.byte %00001000
		.byte %01000111
		.byte %00000000

tile_m:

		.byte %01010011
		.byte %10010100
		.byte %10100101
		.byte %00000000

tile_f:
		.byte %01110010
		.byte %00011100
		.byte %10000100
		.byte %00000000

tile_blank:

		.byte %00000000
		.byte %00011100
		.byte %00000000
		.byte %00000000
