module vending_machine( clk, reset, howManyTicket, origin, destination, money, costOfTicket, moneyToPay, totalMoney);

input clk, reset ;
input[2:0] howManyTicket, origin, destination ;
input[5:0] money ;

output reg[6:0] costOfTicket, moneyToPay, totalMoney ;

parameter S0 = 3'd0,
		  S1 = 3'd1,
		  S2 = 3'd2,
		  S3 = 3'd3;

reg [2:0] state, next_state ;


initial 
begin
	totalMoney = 0 ;
	costOfTicket = 0 ;
	moneyToPay = 0 ;	
	state = S0 ;
	next_state = S0;
end

 
always @( posedge clk )
begin
	if ( reset )
		begin
		costOfTicket = 0 ;		
		state = S3	 ;
		end
	else
		state = next_state ;
end 


always @( state or money or totalMoney  )
begin
	case(state)
		S0:		//選站 
		begin
			totalMoney = 0 ;
			moneyToPay = 0 ;
			costOfTicket = 0 ;
		end
		
		S1:		//張數
		begin
				if ( origin >= destination)
					costOfTicket = 5*(origin-destination+1)*howManyTicket ;
				else
					costOfTicket = 5*(destination-origin+1)*howManyTicket ;

				moneyToPay = costOfTicket ;					
				//$display( "origin: ", origin, " destination: ", destination ) ;	

		end
		
		S2: 	//付款
		begin			
			totalMoney = totalMoney + money ;
			if ( totalMoney < costOfTicket )
				begin 
					moneyToPay = costOfTicket - totalMoney ;
					$display( "total pay: ", totalMoney, " also need to pay :",  moneyToPay ) ;
				end 		
		end
		
		S3: 	//吐票&找錢
		begin
			if(reset)
					$display("ticket: 0 , change : ", totalMoney ) ;
			else
				$display("ticket: ", howManyTicket, ", change: ", totalMoney-costOfTicket) ;
				
			totalMoney = 0 ;
		end		
		
	endcase
	
end




always @( state or posedge clk ) 
begin
	case( state )
		S0:
		begin
			if (  ( 0 < origin && origin < 6 ) && ( 0 < destination && destination < 6) )	
					next_state = S1 ;
			else 
				next_state = S0 ;
		end
		
		S1:
		begin
			if ( howManyTicket > 0 && howManyTicket < 6 )
				begin
					next_state = S2 ;
				end 
			else
				next_state = S1 ;
		end
		
		S2:
		begin
			if ( totalMoney <= costOfTicket )		
				next_state = S2;
			else 
				begin
					next_state = S3;
				end
		end
		
		S3:
		begin
			next_state = S0 ;
		end
		
		default : next_state = S0 ;
	endcase
end

endmodule	