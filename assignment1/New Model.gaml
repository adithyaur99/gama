///***
//* Name: Festival
//* Author: mataymayrany
//* Description: Simualating a festival with bars, restaurants 
//* and guests that find the directions to the stores via an information center
//***/
//
model Festival

global {
	init {
		
		seed <- 10.0;
		bool alternateFlag;
		
		create FestivalGuest number: 20 {
			location <- {rnd(100), rnd(100)};
		}
		
		create Store number: 4 {
			location <- {rnd(100), rnd(100)};
			// blue: bar, red: restaurant
			if(alternateFlag) {
				color <- #blue;
				bar <- true;
				restaurant <- false;
				alternateFlag <- false;
			} else {
				color <- #red; 
				bar <- false;
				restaurant <- true;
				alternateFlag <- true;
			}
		}
		
		create InformationCenter number: 1 {
			location <- {50, 50};
		}
		create cop number: 1 {
			location <- {5, 5};
		}
		
		
	}
}

species Store {	
	bool bar <- false;
	bool restaurant <- false;
	rgb color <- #white;
	
	aspect default {
		draw cube(8) at: location color: color; 
	}
	
}
species cop skills: [moving] {	
	point bad_loc<-nil;
	reflex throw when: bad_loc != nil
	{
			do goto target:bad_loc speed:10;
			ask FestivalGuest at_distance 0.5
			{
					self.rest_loc<-{99,99};
			}
			
		
	}
	aspect default {
		draw cube(8) at: location color: color; 
	}
	
}
species InformationCenter {
	list<Store> restaurants <- nil;
	list<Store> bars <- nil;
	point guard <- {5,5};
	
	init {
		ask Store {
			if(self.bar) {
				myself.bars << self;
			} else if(self.restaurant) {
				myself.restaurants << self;
				write myself.restaurants;
			}
		}
	}
	
	aspect default {
		draw pyramid(15) at: location color: #black;
	}
}


species FestivalGuest skills: [moving] {
	
	int thirsty <- rnd(1000);
	int hungry <- rnd(1000);
	point informationCenterLocation <- {50, 50};
	rgb color <- nil;
	point targetPoint <- nil;
	Store targetStore <- nil;
	Store prevstore <- nil;
	int ran<-69;
	int flag<-0;
	int flag2<-0;
	int drinks<-0;
	bool alternateFlag;
	int bad_flag<-0;
	point guard_loc<-nil;
	int cop_go_flag<-0;
	point baddy_loc<-nil;
	point rest_loc<-nil;
	
	reflex final_passage when: rest_loc!=nil
	{
		do goto target:rest_loc;
		if(location distance_to({99,99}) < 1)
		{	write "RIP";
			do die;
		}
	}
	reflex goToStore when: (targetStore != nil) and drinks<10 {
		write 'going to Store';
		
			do goto target:targetStore;
			
		ask Store at_distance 2 {
			if (myself.thirsty >= 500) {
				myself.thirsty <- 0;
				myself.drinks<-myself.drinks+1;
			} else {
				myself.hungry <- 0;
			}
		}
		
		if (thirsty < 500 and hungry < 500) {
			targetPoint <- nil;
			prevstore <- targetStore;
			targetStore <- nil;
			color <- #green;
		}
	}
	
	
	reflex beIdle when: targetPoint = nil and thirsty < 500 and hungry < 500 and drinks<10{
		write 'being idle';
		color <- #green;
		do wander;
		ask FestivalGuest at_distance 4 {
			if(self.drinks>=10)
			{
				write "Found a Baddy";
				bad_flag <- 1;
				myself.baddy_loc<-self.location;
				}		
			}
		}
	reflex bad_rem when:bad_flag=1
	{
		do goto target:informationCenterLocation;
		ask InformationCenter at_distance 4 {
			myself.guard_loc<-self.guard;
		}
		do goto target:guard_loc;
				ask cop at_distance 4 {
					myself.cop_go_flag<-1;
					self.bad_loc <- myself.baddy_loc;
		}
		if (cop_go_flag=1)
		{
			do goto target:baddy_loc speed:5;
		}
	
	}
	reflex drunk when: drinks>=10
	{
		write "Passed OUT";
	}
	
	reflex goToInformationCenter when: (hungry >= 500 or thirsty >= 500) and targetStore = nil and drinks<10 {
		flag<-0;
		ran<-rnd(2);

		if(ran=2 and prevstore!= nil)
		{
			targetStore<-prevstore;
		}
		if(ran=1 or prevstore= nil)
		{
			write 'going to information center';
		do goto target:informationCenterLocation;
		ask FestivalGuest at_distance 4 {
			if(self.prevstore!=nil)
			{
				write "human help";
				do goto target:self.prevstore;
				flag<-1;
			}
		}
		if (flag=0)
		{
		ask InformationCenter at_distance 2 {			
			if (myself.thirsty >= 500) {
				int i <- rnd(length(self.restaurants) - 1);
				myself.targetStore <- self.restaurants[i];
				write myself.targetStore;
				myself.color <- #red;
			} else {
				int i <- rnd(length(self.bars) - 1);
				myself.targetStore <- self.bars[i];
				myself.color <- #blue;
			}
		}
		
		}

	}
}

	reflex increaseValues when: thirsty < 500 or hungry < 500 {
		if (alternateFlag) {
			thirsty <- thirsty + 3;
			alternateFlag <- false;
		} else {
			hungry <- hungry + 3;
			alternateFlag <- true;
		}
	}
	
	aspect default {
		draw sphere(2) at: location color: color;
	}
	

}
experiment main type: gui {
	output {
		display map type: opengl 
		{
			species FestivalGuest;
			species Store;
			species InformationCenter;
			species cop;
		}
	}
}
