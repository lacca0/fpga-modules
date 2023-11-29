
module addr_gen #(

	parameter IMG_WIDTH     = 640,                    // image resolution
	parameter IMG_HEIGHT    = 480,                    // in pixels
	parameter BLK_SIZE      = 32,                     // block size BLK_SIZE x BLK_SIZE
	parameter ADDR_WIDTH    = (IMG_HEIGHT * IMG_WIDTH) / (BLK_SIZE ^ 2),
	parameter PIXELS_OFFSET = 4,                      // how many pixels to skip
	parameter COLUMNS       = IMG_WIDTH / BLK_SIZE,
	parameter ROWS          = IMG_HEIGHT / BLK_SIZE,
	parameter GROUPS        = COLUMNS / PIXELS_OFFSET // amount of vertical groups in a row, each group of 'offset' blocks	
	
	) (

	input                                      clk,
	input                                      rst_n,  // sync reset, active low
		
	input                                      i_gen_ena,  // one pulse for start read each block 32x32 in picture

	output reg                                 o_gen_vld,  // is active, when o_gen_adr is valid
	output reg [$clog2(ADDR_WIDTH - 1):0]      o_gen_adr,  // value of generated address for 32x32

	output                                     o_gen_eof   // one pulse when frame is processed (optional)
	);

	reg [$clog2(COLUMNS - 1):0] pos_x ;
	reg [$clog2(ROWS - 1):0] pos_y ;
	reg disable_on_next;

	always @(posedge clk)
	begin
		// verilator lint_off WIDTH
		if (!rst_n) begin // drop everything when resetting
			o_gen_vld <= 'b0;
			o_gen_eof <= 'b0;
			pos_x <= 'b0;
			pos_y <= 'b0;
			o_gen_adr <= 'b0;
			disable_on_next <= 'b0;
		end 
		else if (!i_gen_ena) begin
			o_gen_vld <= 'b1;
			o_gen_eof <= 'b0;
			pos_x <= 'b0;
			pos_y <= 'b0;
			o_gen_adr <= 'b0;
			disable_on_next <= 'b0;
		end
		else if (disable_on_next) begin
			o_gen_vld <= 'b0;
			disable_on_next <= 'b0;
			o_gen_eof <= 'b1;
			o_gen_adr <= 'b0; // for clean idle output
		end
		else if (o_gen_vld == 'b0) begin
			//do nothing, wait for i_gen_ena
		end
		else if (pos_x == COLUMNS - 'b1) begin // last column
			if (pos_y == ROWS - 'b1) begin // is it also the last row?
				o_gen_adr <=  pos_y * COLUMNS + pos_x;
				disable_on_next <= 'b1;
				pos_x <= 'b0;
				pos_y <= 'b0;
			end
			else begin
				pos_x <= 'b0; // next column then
				pos_y <= pos_y + 'b1;
				o_gen_adr <= pos_y * COLUMNS + pos_x;
			end
		end
		else begin
			if (pos_x + PIXELS_OFFSET >= COLUMNS) begin // next jump right would miss the table, jump left
				pos_x <= pos_x + 'b1 - PIXELS_OFFSET * (GROUPS - 'b1);
				o_gen_adr <=  pos_y * COLUMNS + pos_x;
			end
			else begin
				pos_x <= pos_x + PIXELS_OFFSET; // jump right
				o_gen_adr <= pos_y * COLUMNS + pos_x;
			end
		end
		// verilator lint_on WIDTH
	end
endmodule
