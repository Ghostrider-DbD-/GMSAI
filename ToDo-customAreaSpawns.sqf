TODO List:

	Things we know about the asset:
		Static weapons are kindOf "StaticWeapon"
		Aircraft are kindOf 
			- drones: "Air", "Helicopter" 
			- Helis: "Air", "Helicopter" 
			- Planes: "Plane"
			- Infantry: "Man"
			- Arma 3 submersibles: "SDV_01_base_F"
			- Boats: "Ship"
	1. There would be 4 categories: 
		a. infantry 
			- number of units specified 
		b. land vehicle (or sea if surfaceIsWater) including UGVs
			i. classname provided directly or by selectRandom[name1, name2, etc]
		c. air including UAVs
			i. classname provided directly or by selectRandom[name1, name2, etc]
		d. static 
			i. classname provided directly or by selectRandom[name1, name2, etc]			

	2. User defines area parameters:
		- respawns 
		- area shape and size  
		- cooldown time 
		- difficulty 
		
	3. Gear is selected from GMSAI tables 

	4. To avoid any confusion and such, we need two types of functions to add custom content.
		a. GMSAI_fnc_addInfantrySpawn[
			_pos,
			_shape,  ["RECCTANGLE","ELLIPSE"] 
			_size,	 [[sizeA,sizeB]/Radius]
			_units,  can be [_min,_max],  [_min], or _min
			_difficulty,  can be 1..N per GMSAI configs.
			_respawns,  0..N, -1 for infinite respawns 
			_cooldown  time in seconds until group respawns
		];

		b. GMSAI_fnc_addVehicleSpawn[
			_classname,
			_disabledTurrets,
			_shape,  ["RECCTANGLE","ELLIPSE"] 
			_size,	 [[sizeA,sizeB]/Radius]
			_units,  can be [_min,_max],  [_min], or _min
			_difficulty,  can be 1..N per GMSAI configs.
			_respawns,  0..N, -1 for infinite respawns 
			_cooldown  time in seconds until group respawns
		]

		c. Define an .sqf with the custom spawns	

		d. make sure that script is read after full initialization  



	 

	


			








