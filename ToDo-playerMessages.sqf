TODO List:

In general, review the TODO lists for this mod.

Overall areas for further developmend:

  First, setup a messaging system for players that addresses several areas of need.

styles of messages 
	_styles[1..n]  // 1 or more stsyles requested in an array sent to the client or specified on the client 
	// Coding of styles either sent to client is precompiled functions during JIP or hard coded on the client
	// Styles could include
	Hint 
	SystemChat 
	Cut or Title Text 			
	Toast (Exile Only)
	Epoch Message 
	blckeagls style 
	DMS Styles (best tomake our own variants but give credit)
	A3EAI / A3XAI Styles (best tomake our own variants but give credit)
	VEMFr styles (best tomake our own variants but give credit)

  a. Dynamic AI spawned near similar to the A3XAI style 'Thats him, Ghostrider'
		_message[
			Some kind of warning 
			Player name (could be pulled from clientside if helpuful as this would reduce network traffic a tiny bit)
		]
  b. Reinforcments are inbound 
		_message[

		]
  c. Killed
		killstreak (link GMSAI and GMS here ?)
		+/- unit name 
		+/- tabs or crypto 
		+/- respect 
		+/- Distance Bonus 
		+/- Killstreak Bonus
		+/- description of kill ["Fragged","Smashed" "etc"] which could be pulled from the client

	d. Notifications 
		Mission Spawned 
		Mission ended 
		Mission aborted 
		Next Mission in series available (consider alerting only those who participated ?)

		_message[
			A header 
			Message content
		]

	e. Warnings 
		AI Runover 
			_message [
				A header,
				This is not allowed,
				Damage applied (optional)
			]
		Others 

	Strategy for Messaging: How to minimize server load and network traffic
		_messageTypes: [1,2,3,4] correspond to message types a-d. The client handle formating of the information 
		_messageStyle // an array of integers, multiple message styles are allowed.
			[
				1, // Hint
				2, // System Chat 
				3, // titleText 
				4. // Toast (exile) // EpochMsg (Epoch) 
				5, // blckeagls style 
				6, // DMS Style 
				7 // A3XAI / A3EAI style 
			]
		_message ["string1" ... "stringN"] corresponds to however many strings are needed // Let the client sort out how to process these based on the type of message 
				So for a simple dynamic AI spawned near you would need the player name then pull the rest of the message from a table or string table 
				For reinforcements inbound from roaming AI you would simple alert the player with a string stored on the client
				For Warnings, this could be informational or apply damage to the player or have something intermediate like a loud noise and warning (set options in configs)
				For Kills, each catagrory 






1. revisit the deletion of dynamic AI debugg markers to ensre this is done properly.
2. Add EH for vehicles, e.g., hit should change combat mode and behavior, killed should alert everything nearby.
3. Check code for detecting players and triggering paradrops. 
4. Write code to handle paradrops which would be quite similar to that for airdropping crates.
5. Write code to have a one-time instance of an area patrol; Perhaps, this could add the patrol the the activeStaticAreas list for infantry with respawns == 0;
6. Think about how to make vehicle patrols slow near players and sniff them out.
7. think about adding more perstance to the hunting mode.
8. Add unit Killed event handler that includes any checks for illeagal kills and sends players messages.
9. send messages to specific client-side message handlers; there may be greater flexibility to having several of these but the downside is more network traffic if we remoteExec to several of these per client per kill.
10. Add debug markers for paratroops.
11. Develop a set of hunting logic beyond what is already there.



