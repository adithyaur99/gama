/***
* Name: Unga Aaya
* Author: Group 24
***/

model Auction

global {
       init {
         
        create participant number: 20 {
           location <- {rnd(100), rnd(100)};
        }
     
        create Auctioneer number: 4 {
           	location <- {rnd(100), rnd(100)};
        }
    }
            int type_of_auction<-rnd(2);    
    
    
    
}

species Auctioneer skills:[fipa] {
    
	bool acutionStarted <- false;
    bool myTurn <- true;
    int minimumPrice <- 1000 + rnd(500, 1000);
    int startPrice <- minimumPrice + rnd(1000,2000);
    int currentPrice <- startPrice;
    participant winner <- nil;
    list<participant> potentialBuyers <- [];
    bool itemSold <- false;
    
    init {
    	ask participant {
    		myself.potentialBuyers << self;
    	}
    }
     reflex initiateAuction when: !acutionStarted
     {
        write "Auction Starting Everyone!!!";
        do start_conversation (to: list(potentialBuyers), protocol: 'fipa-request', performative: 'inform', contents: ['Start']);
        acutionStarted <- true;
    }
    reflex recvProposals_closed_bid when: acutionStarted and myTurn and !empty(potentialBuyers) and !itemSold and type_of_auction=2
    {
    	do start_conversation with:(to: list(potentialBuyers), protocol: 'fipa-contract-net', performative: 'cfp', contents: [currentPrice]);
    	myTurn <- false;
    }
    
    reflex sendProposals when: acutionStarted and myTurn and !empty(potentialBuyers) and !itemSold and type_of_auction=1
    {
    	write name + " Going for... " + currentPrice + "!!!";
    	do start_conversation with:(to: list(potentialBuyers), protocol: 'fipa-contract-net', performative: 'cfp', contents: [currentPrice]);
    	myTurn <- false;
    }
    reflex receieveProposes when: !empty(proposes) and winner = nil 
    {
    	bool foundWinner <- false;
    	loop p over: proposes {
    		write p.contents;
			if(list(p.contents)[0] = 'accept') {
				foundWinner <- true;
				itemSold <- true;
				winner <- p.sender;
				break;
			}
			else if(type_of_auction=2)
			{
				
			}
		}
		if(foundWinner) {
	        	acutionStarted <- false;
	            write ' Found a winner! '+ winner + ' won for '+ currentPrice;
		} else {
			write name + " No one likes this price, let's drop it!";
			if (currentPrice <= minimumPrice) {
				write "Opps price already too low, auction is over, you're all too cheap!";
				acutionStarted <- false;
				itemSold <- true;
			} else {
				currentPrice <- currentPrice - rnd(5,20);
	    		myTurn <- true;
			}
		}
    	proposes <- [];
    }
    
    aspect default 
	{
        draw pyramid(8) at: location color: #black;
    }
}

species participant skills:[fipa] 
{
	 rgb color <- #blue;   
    int willingToPay <- rnd(1500,2500);
    int currentPrice <- 0;
    
    reflex readOffers when: (!empty(cfps)) {
    	int decision<- rnd(2);
    	message offerFromAuctioneer <- cfps[0];
    	
        int offeredPrice <- int(list(offerFromAuctioneer.contents)[0]);
     	if(decision=1 and type_of_auction=2) 
        {
            write name + "Sealed bid";
            color <- #green;
            do propose with: (message: offerFromAuctioneer, contents: [offeredPrice]);
        }
        if(willingToPay >= offeredPrice and decision=1 and type_of_auction=1) 
        {
            write name + ": I accept!!!";
            color <- #green;
            do propose with: (message: offerFromAuctioneer, contents: ['accept', offeredPrice]);
        } 
        else 
        {
        	if(decision =2)
        	{
        		 write name + ": No Thanks!" +"Not Interested";
           	
        	}
        	else{
            write name + ": No Thanks!" +"Too High";
            
            }
            color <- #red;
            do propose with: (message: offerFromAuctioneer, contents: ['reject']);
        }
    }    	
		    
    	aspect default 
    	{
        	draw sphere(2) at: location color: color;
    	}
    	
}

experiment main type: gui {
      
    output {
        display map type: opengl {
            species participant;
            species Auctioneer;
        }
    }
 }
