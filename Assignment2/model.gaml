
model Auction

global {
    init {
    	create Auctioneer number: 1;
        create participant number: 1;
        }
     
    
}

species Auctioneer skills:[fipa] {
    
	int flag<-0;
	reflex send_request when: flag=0
	{
		participant p<- participant at 0;
		write "sending message";
		do start_conversation (to :: [p], protocol :: 'fipa-request', performative :: 'request', contents :: ['Start']);
		
	}
	reflex read_agree_message when: !empty(agrees)
	{
		loop a over:agrees
		{
			write "agree message with content"+string(a.contents);
		}		
	}
	reflex read_failure_message when: !empty(failures)
	{
		loop f over:failures
		{
			write "agree message with content"+string(f.contents);
		}		
	}
}

species participant skills:[fipa] {
		reflex read_message when: !empty(requests)
		{
			message request_init_message<- requests at 0;
			do agree with: (message: request_init_message,contents:["I will"]);
			write "Failed to sleep";
			do failure with: (message: request_init_message,contents:["The bed is broken"]);
			
				
		}
}

experiment main type: gui {
   
 }
