




//new animation for bandage loop without pulling out weapon after each animation
Lifeline_Anim_Bandage_new = {
	params ["_incap","_medic","_randomanimloop","_cprcheck"];

	if (_randomanimloop == 1) then {		
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};
		_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 10;
		_medic playmovenow "AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon";
		sleep 2;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 7;
			_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOtherOut";
			sleep 0.2;
		};
	};														

	if (_randomanimloop == 2) then {	
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};		
		_medic playmovenow "AinvPpneMstpSlayWpstDnon_medicOther";
		sleep 7;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 7;
			_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOtherOut";
			sleep 0.2;
		};
	};

	if (_randomanimloop == 3) then {
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};
		// _medic setAnimSpeedCoef 1.9;
		 _medic playmove "AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon"; 
		// _medic setAnimSpeedCoef 1;
		sleep 2;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 4;
		};
	};

	if (_randomanimloop == 4) then {
		_medic playmovenow "amovppnemstpsraswrfldnon"; 
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "ainvppnemstpslaywrfldnon_medicother"; 
			sleep 7.607; 
		};
	_medic playmovenow "amovppnemstpsraswrfldnon_amovpercmstpsraswrfldnon"; 
	};														
};

// function to check revive pair and cancel the medic if needed
Lifeline_exit_travel = {
	params ["_incap","_medic","_diagtext","_linenumber"];

	_pairtimeoutbaby = (_incap getVariable ["LifelinePairTimeOut",0]);
	_incapTL = (_incap getVariable ["LifelineBleedOutTime",0]);
	_distcalc = _medic distance2D _incap;
	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 
	_exit = false;

	_ifACEdragged = false;
	if (Lifeline_RevMethod == 3) then {
		if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
		_ifACEdragged = true;
		};
	};

	if ((_pairtimeoutbaby > 0 && time > _pairtimeoutbaby && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3)) 
		|| _pairtimeoutbaby == 0 || _ifACEdragged == true || (lifestate _incap != "INCAPACITATED") || (lifestate _medic == "INCAPACITATED") 
		|| !(alive _medic) || (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != "") 
		|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
		|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")
		|| (!(_medic in _AssignedMedic) && count _AssignedMedic > 0 )
		|| _AssignedMedic isEqualTo []
		|| _medic getVariable ["Lifeline_ExitTravel", false] == true
		|| (_pairtimeoutbaby - time) < 0 //might not need
		) then {
			_exit = true;
			_medic setVariable ["Lifeline_ExitTravel", true, true];
	};
_exit
};







Lifeline_countdown_timer2 = {
	params ["_unit","_seconds"];

	_bleedout = (_unit getVariable "LifelineBleedOutTime");
	_realseconds = round(_bleedout - time); // to adjust exactly	
	_counter = _realseconds;
	_colour = "#FFFAF8";	
	_font = Lifelinefonts select Lifeline_HUD_dist_font;//added for distance

	while {_counter >= 0 && lifeState _unit == "INCAPACITATED"} do {

		if (_unit getVariable ["Lifeline_canceltimer",false]) exitWith {/*_unit setVariable ["Lifeline_canceltimer",false,true]; */};

		if (time > (_bleedout - (Lifeline_cntdwn_disply+3)) && Lifeline_RevMethod == 2) then {

			// if (_counter <= 60 && isPlayer _unit) then {_colour = "#A10A0A"};
			if (_counter <= 60 && isPlayer _unit) then {_colour = "#EF5736"};
			if (_counter <= 10 && isPlayer _unit) then {_colour = "#FF0000";playSound "beep_hi_1";};
			if (isPlayer _unit && _counter <= _seconds) then { 
					[format ["<t align='right' size='%3' color='%1'>..%2</t><br>..<br>..",_colour,_counter,0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] spawn BIS_fnc_dynamicText;
					// [format ["<t align='right' size='%3' color='%1'>..%2</t><br>..<br>..",_colour,_counter,0.7],((safeZoneW - 1) * 0.48),1.3,1,0,0,LifelineBleedoutLayer] spawn BIS_fnc_dynamicText;
			};			
		};	

		//========================= ADDED distance
		if (Lifeline_HUD_distance) then {
			_AssignedMedic = (_unit getVariable ["Lifeline_AssignedMedic",[]]); 
			if (_AssignedMedic isNotEqualTo []) then {
				_incap = _unit;
				_medic = _AssignedMedic select 0;
				_distcalc = _medic distance2D _incap;
				if (isPlayer _incap && _distcalc > 10) then {
					[format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",_font],((safeZoneW - 1) * 0.48),1.26,3,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
					// [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",_font],((safeZoneW - 1) * 0.48),1.26,5,0,0,LifelineDistLayer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
				};
				if (isPlayer _incap && (_distcalc <= 10 && _distcalc >= 5 ) && Lifeline_HUD_distance) then {
					// ["",0.64,1.26,5,0,0,Lifelinetxt1Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					["",0.64,1.26,5,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText;
					// ["",0.64,1.26,5,0,0,LifelineDistLayer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};			
			};	
		};
		//last 3 are just counter instead of calc time
		if (_counter < 4) then {
			_counter = _counter - 1;
		} else { 
			// _counter = round(_bleedout - time);
			_counter = round((_unit getVariable "LifelineBleedOutTime") - time);
		};
		sleep 1;
	}; // end while

	// _unit setVariable ["Lifeline_canceltimer",false,true];
	_unit setVariable ["Lifeline_countdown_start",false,true];
};



// List of all incapped units and assigned medics in HUD. Needs to be used with "foreach"
Lifeline_incap_list_HUD = {
params ["_x","_diag_text"];

		// _diag_text = "";
		_underline = "";
		_underline2 = "";
		_colur =  "#EEEEEE"; //whiteish
		_colur2 = "#EEEEEE"; //whiteish
		_no = "";
		_medics = "";
		_tme = "";
		_distcalc = "";
		_incap = _x;

		if (lifestate _x == "INCAPACITATED" || !(alive _x)) then {
				_colur = "#FFBFA7"; //pinkish
				if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1 && Lifeline_HUD_names in [2,4]) then {
					_bandges = (_x getVariable ["num_bandages",0]);
					if (_bandges != 0) then {
						_no = " (" + str _bandges + ")";
						// _no = " .." + str _bandges;
					} else {
					_no = " (?)"; 
					// _no = " ..?"; 
					};
				};
		};
		if (isPlayer _x) then {_underline = "underline='1'";};

		if (_x getVariable ["ReviveInProgress",0] == 0) then {
			// _colur = "#EE5F09";
			// _colur = "#EE2809"; //red
			_colur = "#FFBFA7"; //pinkish
			// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + _no + "</t><br />";
			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + "</t>   <br />";
		};

		if (_x getVariable ["ReviveInProgress",0] == 3) then {
			_medic = (_x getVariable ["Lifeline_AssignedMedic", []]);
			{
				if (Lifeline_Revive_debug && isServer && Lifeline_HUD_names_pairtime) then {
					_tme = str round ((_incap getVariable ["LifelinePairTimeOut",0]) - time);
				};
				if (Lifeline_HUD_names in [2,3]) then {
					_distcalc = str round (_incap distance2D _x) + "m ";
				};
				if (_x getVariable ["ReviveInProgress",0] == 2) then {
					_colur2 = "#58D68D";
					_colur = "#58D68D";// COMMENT THIS OUT TO HAVE DIFF COLOURED INCAP / MEDIC PAIRS WHEN ACTUAL REVIVE
					_tme = "";
					_distcalc = "";
				};
				if (isPlayer _x) then {_underline2 = "underline='1'";};
				_medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + name _x + " " + _distcalc + _tme + "</t>   ";
			} foreach _medic;

			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + _no + "</t> - "  + _medics + "<br />";
		};
_diag_text
};





Lifeline_Smoke = {
	params ["_incap", "_medic"];
	_reldir = 0;
	_relpos = [];
	_col = "";
	_EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
	if (getPosATL _incap select 2 <1) then {
		if (!isNull _EnemyCloseBy && alive _EnemyCloseBy && _EnemyCloseBy isKindOf "CAManbase") then {
				_reldir = _incap getdir _EnemyCloseBy;
		} else {
			_reldir = _incap getdir _medic;
		};
		_relpos = _incap getPos [10, _reldir]; // 10 metres away
		_colors= ["yellow","red","purple","orange","green","white"];
		if (Lifeline_SmokeColour == "random") then {
			_col = selectRandom _colors;
		} else {
			_col = Lifeline_SmokeColour;
		};
		_percentchance = 0; _random = 0;
		if (isNull _EnemyCloseBy) then {_percentchance = Lifeline_SmokePerc; } else {_percentchance = Lifeline_EnemySmokePerc;  };
		if (_percentchance == 0) exitWith { };
		if (_percentchance != 100) then {  
			_random = [1,100] call BIS_fnc_randomInt; 
		};
		if (_percentchance == 100 OR _random <= _percentchance) then {
			if (_col=="white") then {_col = ""}; 
			_GrenadeSmokeCol = "SmokeShell"+_col;
			createVehicle [_GrenadeSmokeCol, _relpos, [], (random 6), "CAN_COLLIDE"];
		};	
	};
	true
};



Lifeline_EnemyCloseBy = {
	params ["_unit"];
	_EnemiesCloseBy = [];
	_EnemyCloseBy = objNull;
	_EnemySides = (Lifeline_Side call BIS_fnc_enemySides);
	_EnemyUnits = allunits select {side _x in _EnemySides};
	_EnemiesCloseBy = _EnemyUnits select {_x distance _unit <500 && simulationEnabled _x};
	if (count _EnemiesCloseBy >0) then {
		_EnemyCloseBy = _EnemiesCloseBy select 0;
	} else {
		_EnemyCloseBy = objNull;
	};
	_EnemyCloseBy
};



Lifeline_POSnexttoincap = {
params ["_incap", "_medic", "_distnextto"];	
	// Step 1: Get the positions of the units
	_posA = getPos _incap;
	_posB = getPos _medic;
	// Step 2: Calculate the direction vector from _unitA to _unitB
	_directionVector = _posB vectorDiff _posA;
	// Step 3: Normalize the direction vector
	_directionVectorNormalized = vectorNormalized _directionVector;
	// Step 4: Scale the direction vector by _distnextto meters
	_scaledDirectionVector = _directionVectorNormalized vectorMultiply _distnextto; //_distnextto = metres
	// Step 5: Calculate the new position _distnextto meters from _unitA in the direction of _unitB
	_newPosition = _posA vectorAdd _scaledDirectionVector;
	// testing, choose position that is safe
	// _newPosition = [_newPosition, 1, 5, 5, 0, 20, 0] call BIS_fnc_findSafePos; //experimental

	_newPosition
};



Lifeline_delYelMark = {
	params ["_unit"];
	if !(Lifeline_yellowmarker) exitWith {};
		_yelmark = _unit getVariable ["ymarker1", nil]; 
	if (!isNil "_yelmark") then {
		deleteVehicle _yelmark;
	};
	// _ymrkrs = nearestObjects [_unit,["Sign_Arrow_Yellow_F"], 2];
	// {deleteVehicle _x} foreach _ymrkrs;
};



Lifeline_delIncapMrk = {
	params ["_unit"];
	_allmarkers = allMapMarkers select {markerType _x == "loc_heal"};
	{
		_txt = markerText _x;
		if (alive _unit && (name _unit) in _txt) then {
			deleteMarker _x;
			_unit setVariable ["Lifeline_IncapMark","",true];
		};
	} foreach _allmarkers;
	true
};



Lifeline_reset2 = {
	params ["_units","_lineno"];
	{
		if (alive _x) then {
			[_x] spawn {
				params ["_unit"];
				sleep 2;
				_unit setVariable ["Lifeline_ExitTravel", false, true];
			};

			_x setVariable ["ReviveInProgress",0,true];	
			_x setVariable ["Lifeline_AssignedMedic", [], true];
			_x setvariable ["LifelinePairTimeOut",0,true];
			// _x setVariable ["Lifeline_ExitTravel", false, true];

			if (_x in Lifeline_Process) then {
				Lifeline_Process = Lifeline_Process - [_x];
				publicVariable "Lifeline_Process";
			};

			_x enableAI "ANIM";
			_x enableAI "MOVE";
			_x enableAI "AUTOTARGET";
			_x enableAI "AUTOCOMBAT";
			_x enableAI "SUPPRESSION";
			_x enableAI "TARGET";
			group _x setSpeedMode "NORMAL";
			_x doWatch objNull;
			doStop _x; //ADDED 
			[_x] joinSilent _x;

			if (alive leader _x && lifestate leader _x != "incapacitated") then {
				_x doFollow leader _x;
			};

			// _x setvariable ["LifelineBleedOutTime",0,true]; // must be OFF. Its called at end of revive loop even when 15 sec pair is cancelled.
			if (!isNull (_x getVariable ["AssignedVeh", objNull]) && !isPlayer leader _x && isNull assignedVehicle _x) then {
				(group _x) addVehicle (_x getVariable "AssignedVeh");
			};
			if (isplayer _x && alive _x && lifestate _x != "INCAPACITATED") then {
				[group _x, _x] remoteExec ["selectLeader", groupOwner group _x];
				{[_x] joinSilent group _x;} foreach units group _x;
			};

			// fix animation if animation if incap but unit is healthy
			// if (lifestate _x != "INCAPACITATED" && lifestate _x != "DEAD" && lifestate _x != "DEAD-RESPAWN" && (animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone")) then {
			if (lifestate _x != "INCAPACITATED" && alive _x && (animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone")) then {
					[_x, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
			};
			//this should be completely turned off. 
			if (lifestate _x != "INCAPACITATED") then { 
			// if !(local _x) then {
				// [_x, true] remoteExec ["allowDamage",_x];
				// [_x, false] remoteExec ["setCaptive",_x];
			// } else {
				_x allowDamage true;
				_x setCaptive false; 
			// };		
			};	
		};	//if (alive _x) then 
	} forEach _units;

		// sleep 1;
	/* {
		if (lifestate _x != "INCAPACITATED" && alive _x) then { 	//added this line
			//changed to non remoteExec.It didnt change one time for some reason. its global anyway.
			//method2
			// _x allowDamage true;
			// _x setCaptive false;			
			// if !(local _x) then {
				// [_x, true] remoteExec ["allowDamage",_x];
				// [_x, false] remoteExec ["setCaptive",_x];
			// } else {
				_x allowDamage true;
				_x setCaptive false;
			// };			
			//method2
			// [_x, true] remoteExec ["allowDamage",_x];
			// [_x, false] remoteExec ["setCaptive",_x];
			// waitUntil {isDamageAllowed _x == true};
			// waitUntil {captive _x == false};
		};	
	} forEach _units; */

	true
};



Lifeline_SelfHeal = {
	params ["_unit"];

	_unit setVariable ["Lifeline_selfheal_progss",true,true];

	sleep 3;
	sleep (random 2); // this must be BEFORE cheching incapacitated. Otherwise in these 5 secs it can happen, and bugs animation.

	if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod != 3 && (damage _unit > 0.2 || _unit getHitPointDamage "hitlegs" >= 0.5) && (isnull (objectParent _unit))) then {

		_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;

		if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
			_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];  
		}; // add 5 secs to timeout

		if (isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) then {
			[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
			sleep 6;
		} else {
			[_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
			sleep 7;
		};

		if (lifeState _unit != "INCAPACITATED") then { //added again
		_unit setdamage 0;
		};
	};
	// if (Lifeline_RevMethod != 3) then {
		// _unit setVariable ["Lifeline_selfheal_progss",false,true];
	// };

	if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod == 3 && (isnull (objectParent _unit))) then {
		[_unit] call Lifeline_SelfHeal_ACE;
	};
	_unit setVariable ["Lifeline_selfheal_progss",false,true];

	true
};



//========================== MAIN FUNCTION LOOP TO CHECK INCAP / MEDIC PAIR
Lifeline_PairLoop = {
	params ["_medic","_incap"];

	// if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["Incap: %1\nMedic: %2", name _incap, name _medic]] remoteExec ["hintsilent", 2]};

	_poscheck = getpos _medic; // for checking idle medic
	_idleMlimit = 7; // number of seconds an idle medic before resetting
	_repeatcount = _idleMlimit; // for checking idle medic
	_exit = false; // for exiting loop without using getVariable
	_idlemedic = false;
	_closermedic = false;

	while {alive _medic && lifestate _incap == "INCAPACITATED" && (_incap getVariable ["LifelinePairTimeOut",0])>0} do {

		// check time limit
		_elapsedTimeToRevive = (_incap getVariable ["LifelinePairTimeOut",0]);
		_incapTL = (_incap getVariable ["LifelineBleedOutTime",0]);

		if (isNil "_incapTL" && Lifeline_Revive_debug) then {
			[_incap,"_incapTL ISSUE"] remoteExec ["serverSide_unitstate", 2];
			["_incapTL ISSUE"] remoteExec ["serverSide_Globals", 2];
		};

		_distcalc = _medic distance2D _incap;

		// THIS IS TO STOP IDLE MEDICS. SOMETIMES HAPPENS.
		if (Lifeline_Idle_Medic_Stop && animationstate _medic in ["aidlpercmstpsraswrfldnon_g01","aidlpercmstpsraswrfldnon_g02","aidlpercmstpsraswrfldnon_g03",
				"aidlpercmstpsraswrfldnon_g04","amovpknlmstpslowwrfldnon","aidlpercmstpsraswrfldnon_ai"] || _repeatcount != 6) then { 
			if (_repeatcount < 4) then { // just beep for debugging
				if (Lifeline_Revive_debug) then {
					if (Lifeline_hintsilent) then {hintsilent format ["%1 IDLE MEDIC %2", name _medic, _repeatcount]}; 
					["beep_hi_1"] remoteExec ["playsound",2];
				};
			};
		   if (_repeatcount == _idleMlimit) then { _poscheck = getpos _medic; }; 
		   if (_repeatcount == 0 && _poscheck isEqualTo getpos _medic) exitWith { 
				if (Lifeline_Revive_debug) then {
				   if (Lifeline_debug_soundalert) then {["stop_idle_medic"] remoteExec ["playSound",2]}; 
				   if (Lifeline_hintsilent) then {hintsilent format ["%1 STOPPED IDLE MEDIC", name _medic]}; 
			   };
			   _repeatcount = _idleMlimit; 
			   // _incap setVariable ["LifelinePairTimeOut", 0,true]; 
			   _exit = true; 
			   _idlemedic = true;			   
			   if (Lifeline_Revive_debug) then {[_medic,"IDLE MEDIC [0403]"] call serverSide_unitstate};
			   _medic call reset_idle_medics;			   
		   }; 
		   // if (_poscheck isEqualTo getpos _medic) then {_repeatcount = _repeatcount - 1}; 
		   _repeatcount = _repeatcount - 1;
		   if (_repeatcount < 0 || _poscheck isNotEqualTo getpos _medic) then {_repeatcount = _idleMlimit; if (Lifeline_hintsilent) then {hintsilent ""};}; 
		};

		 //check for closer medic
		 _closermedic_dist = 100;
		if (_distcalc > _closermedic_dist ) then {
		 // if (_distcalc > 100 ) then {
			 Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
			 // Lifeline_medics2choose = (Lifeline_healthy_units select {!(side _x == civilian) && !isPlayer _x && !(_x in Lifeline_Process) && ((_x distance _incap) < Lifeline_LimitDist) && (currentWeapon _x != secondaryWeapon _x )}); 
			 Lifeline_medics2choose = (Lifeline_healthy_units select {!(side _x == civilian) && !isPlayer _x && !(_x in Lifeline_Process) && ((_x distance _incap) < Lifeline_LimitDist) 
				&& !(currentWeapon _x == secondaryWeapon _x && currentWeapon _x != "")
			 	&& !(((assignedTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit did not get order to hunt tank
				&& !(((getAttackTarget _x) isKindOf "Tank") && secondaryWeapon _x != "")			 
			 }); 
			 _closermedic = false;
			 {
				  _dis = _x distance2D _incap;
				 if (_dis < _closermedic_dist) then {
					 _closermedic = true;
				 };		 
			 } foreach Lifeline_medics2choose;

			 if (count Lifeline_medics2choose > 0 && _closermedic == true) then {
				if (Lifeline_Revive_debug) then {
					if (Lifeline_debug_soundalert) then {["closermedic"] remoteExec ["playSound",2]}; 
					if (Lifeline_hintsilent) then {hintsilent format ["%1  CLOSER MEDIC ", name _medic]}; 
				 };
				  _exit = true;
				  _medic setVariable ["Lifeline_ExitTravel", true, true];
			  };
		};

		//JUST DEBUGGING
		_formatedReviveTime = round(_elapsedTimeToRevive - time);
		if (Lifeline_RevMethod == 2 && Lifeline_Revive_debug) then {
			diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 BLEEDOUT %5 DISTANCE %6 ReviveInProgress %7 autoRecover %8 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, round(_incapTL - time), _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0], _incap getVariable ["Lifeline_autoRecover",false] ];
		};
		if (Lifeline_RevMethod == 3 && Lifeline_Revive_debug) then {
			diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 DISTANCE %5 ReviveInProgress %6 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0] ];
		};
		// };		


		_ifACEdragged = false;
		if (Lifeline_RevMethod == 3) then {
			if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
			_ifACEdragged = true;
			};
		};

		if ((_elapsedTimeToRevive > 0 && time > _elapsedTimeToRevive && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3)) 
			|| _elapsedTimeToRevive == 0 || _ifACEdragged == true || (lifestate _incap != "INCAPACITATED") || (lifestate _medic == "INCAPACITATED") 
			|| !(alive _medic) || (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != "") 
			|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
			|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")			
			|| _exit == true) then {
				_medic setVariable ["Lifeline_ExitTravel", true, true];

				if (Lifeline_Revive_debug) then {
					diag_log format ["%3|%4| '", _incap, _medic,name _incap,name _medic];
					if (_elapsedTimeToRevive > 0 && time > _elapsedTimeToRevive && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3))  then {
					if (Lifeline_hintsilent) then {["Medic reset\nTaking too long"] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0495] MEDIC RESET TAKING TOO LONG'", _incap, _medic,name _incap,name _medic];
					};
					if ((lifestate _medic == "INCAPACITATED") || (lifestate _medic == "DEAD") || (lifestate _medic == "DEAD-RESPAWN") || (lifestate _medic == "DEAD-SWITCHING")) then {
					if (Lifeline_hintsilent) then {[format ["Medic DOWN\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0499] MEDIC DOWN!!!'", _incap, _medic,name _incap,name _medic];
					};
					if (_closermedic == true && _exit == true) then {
					if (Lifeline_hintsilent) then {[format ["Medic Closer\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0503] CLOSER MEDIC !!!'", _incap, _medic,name _incap,name _medic];
					};				
					if (_idlemedic == true && _exit == true) then {
					if (Lifeline_hintsilent) then {[format ["Medic Idle\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0507] IDLE MEDIC !!!'", _incap, _medic,name _incap,name _medic];
					};
					if (lifestate _incap != "INCAPACITATED") then {
					if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0511] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
					};
					if (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != ""
						|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
						|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")					
					) then {
						if (Lifeline_debug_soundalert) then {["medichaslauncher"] remoteExec ["playSound",2]};
						if (Lifeline_hintsilent) then {[format ["Medic w Launcher\n%1", name _medic]] remoteExec ["hintsilent", 2]};
						diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0516] MEDIC HAS LAUNCHER!!!'", _incap, _medic,name _incap,name _medic];				
					};
					diag_log format ["%3|%4| '", _incap, _medic,name _incap,name _medic];
					_incap call Lifeline_delYelMark;
				};

				_exit = false;

				// if (lifestate _medic != "INCAPACITATED") then { //added this conditional. sometimes when medic is hit and downed, this needs to stay as is.			
						// [_medic,false] remoteExec ["setCaptive",_medic];
				// }; 
				[_medic] joinSilent _medic;
				_medic = objNull;

		}; // end time > _LifelinePairTimeOut 

		//if the medic switches to launcher, it means a tank needs to be taken out. Cancel medic then, more important is tank. - Lifeline
		if ((_incap getVariable ["LifelinePairTimeOut", 0]) == 0) exitWith {};
		if ((_medic getVariable ["Lifeline_ExitTravel", false]) == true) exitWith {};

		sleep 1;
	}; // end while

}; // END Fnc spawn recovery, recycle or death func



//========================== MAIN REVIVE FUNCTION STARTING MEDIC TRAVEL
Lifeline_StartRevive = {
	params ["_medic", "_incap"];
	// AI functions to make travel easier
	// _medic setSkill ["COURAGE", 1];
	// _medic allowFleeing 0.2;
	// _medic disableAI "AUTOTARGET";
	// _medic disableAI "AUTOCOMBAT";
	// _medic disableAI "SUPPRESSION";
	// _medic disableAI "TARGET";
	[_medic,["COURAGE", 1]] remoteExec ["setSkill",0];
	[_medic,"AUTOTARGET"] remoteExec ["disableAI",0];
	[_medic,"AUTOCOMBAT"] remoteExec ["disableAI",0];
	[_medic,"SUPPRESSION"] remoteExec ["disableAI",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];
	[_medic,0.2] remoteExec ["allowFleeing",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];

	_linenumber = "0744";
	_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;

	_voice = _medic getVariable "Lifeline_Voice";
	_B = "";
	_EnemyCloseBy = objNull;
	_yelmark = objNull;	
	_goup = group _medic;	// check group 4 medic
	_revivePos = [];
	_distnextto = 0;
	_dir = 0;
	_revtime = time;

	if !(_exit) then {
		_linenumber = "0757";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};	
	if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {

		// unassign vehicle if lost group status
		if (!isplayer (leader group _medic) && isPlayer _incap) then {
			{if (!isplayer _x) then {_x leaveVehicle (assignedVehicle _x)}} foreach (units leader _incap);
		};

		//check if bleeding. both for ACE and non-ACE
		_isbleeding = false;
		if (Lifeline_RevMethod == 3) then {
			_isbleeding = [_medic] call ace_medical_blood_fnc_isBleeding;
		} else {
			if (damage _medic >=0.2 || _medic getHitPointDamage "hitlegs" >= 0.5) then { 
			_isbleeding = true;
			};
		};
		if (!isPlayer _medic && !(lifestate _medic == "INCAPACITATED") && alive _medic && _isbleeding == true 
			&& _medic getVariable ["Lifeline_selfheal_progss",false] == false
		) then {
			_medic call Lifeline_SelfHeal;
		};

		//old spot for AI disable

		// remove collision
		if (alive _incap && alive _medic) then {
			[_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];
		};

		// ========== Start travel ===========

		// update this later. bad method for making sure animation works when not having primary weapon. 
		if (alive _medic && primaryWeapon _medic == "") then {_medic addWeapon "arifle_MX_F"};
		if (alive _medic && currentWeapon _medic != (primaryWeapon _medic)) then {_medic selectWeapon (primaryWeapon _medic)};

		_EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
		_cpr = false;
		if (Lifeline_RevMethod == 3) then {
				_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
		};

		// calc position depending on enemy proximity
		// if (!isnull _EnemyCloseBy) then {
		if (!isnull _EnemyCloseBy && _cpr == false) then {
			_distnextto = 1.5;
		} else {
			_distnextto = 0.8;
		};

		_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;		
		_revivePos set [2,0]; // Set height. Maybe turn this off
		//TEMP // maybe this whole block should move as a waitUntil {_medic distance2D _revivePos < 10} further down this function
		[_incap,_medic,_revivePos,_EnemyCloseBy] spawn {
			params ["_incap","_medic","_revivePos","_EnemyCloseBy"];
			// sleep 4;
			_revivePosCheck = "";
			_cpr = false;
			_medicpos = getPos _medic;
			_medicpos2 = [];
			while {alive _medic && alive _incap && _medic getVariable ["ReviveInProgress",0] in [1,2] && lifestate _incap == "INCAPACITATED"} do {
				if (_medic distance2D _revivePos < 10) then { 
					if (Lifeline_RevMethod == 3) then {
						_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
					};
					if (!isnull _EnemyCloseBy && _cpr == false) then {_revivePosCheck = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;} else {_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap; };
					if (_revivePos isNotEqualTo _revivePosCheck) then {
					// if (_revivePos distance2D _revivePosCheck > 0.2) then {
					// if (_revivePos distance2D _revivePosCheck > 0.5) then {	
						_revivePos = _revivePosCheck; // commenting out this line, gets diff results. Test/
						_incap setVariable ["Lifeline_RevPosX",_revivePos,true];
						if (_medic getVariable ["ReviveInProgress",0] == 1) then {
							[_medic] joinSilent _medic;
							_medic domove position _medic;
							_medic domove _revivePos;
							_medic moveto _revivePos;
							playsound "beep_hi_1";
							hint format ["%1 DOMOVE MEDIC", name _medic];
						};
						if (Lifeline_yellowmarker) then {
							_incap call Lifeline_delYelMark;
							_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
							_incap setVariable ["ymarker1", _yelmark, true]; 	
						};
					};
					if (_medic getVariable ["ReviveInProgress",0] == 2 && _medic distance2D _revivePosCheck > 0.3 && _cpr == false && _medicpos isEqualTo _medicpos2) then {
						playsound "beep_hi_1";
						hint format ["%1 TRANSPORT MEDIC", name _medic];
						_medic setPos _revivePosCheck;
						_direction = _medic getDir _incap;
						_medic setDir _direction;
					};
					_checkdegrees = [_incap,_medic,20] call Lifeline_checkdegrees;
					if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
						playsound "beep_hi_1";
						hint format ["%1 TRANSPORT MEDIC", name _medic];
						// _medic setPos _revivePosCheck;
						_direction = _medic getDir _incap;
						_medic setDir _direction;
					};
				};
				sleep 2;
				_medicpos2 = getPos _medic;
			};
			_incap setVariable ["Lifeline_RevPosX",nil,true];
		};

		// [center, minDist, maxDist, objDist, waterMode, maxGrad, shoreMode, blacklistPos, defaultPos] call BIS_fnc_findSafePos

	}; // END IF (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {


	if !(_exit) then {
		_linenumber = "0817";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};

	if (Lifeline_Revive_debug) then {
		if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
				diag_log format ["|%3|%4| '", _incap, _medic,name _incap,name _medic];
				diag_log format ["|%3|%4|++++ YELLOW MARKER ++++ [0632] Lifeline_Cancel: %5'", _incap, _medic,name _incap,name _medic];
				diag_log format ["|%3|%4| '", _incap, _medic,name _incap,name _medic];
				if (Lifeline_yellowmarker) then {
					_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
					_incap setVariable ["ymarker1", _yelmark, true]; 	
				};
		} else {
				diag_log format ["|%3|%4| '", _incap, _medic,name _incap,name _medic];
				diag_log format ["|%3|%4|++++ BYPASS YELLOW MARKER ++++ [0640] Lifeline_Cancel: %5'", _incap, _medic,name _incap,name _medic];
				diag_log format ["|%3|%4| '", _incap, _medic,name _incap,name _medic];	
		};
	};

	_waypoint = [];

	if (alive _medic && alive _incap && (lifestate _incap == "INCAPACITATED") && (lifestate _medic != "INCAPACITATED") && _medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
			_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	

			// good for getting confused in buildings - confirm later
			[_medic] joinSilent _medic;
			// _medic domove position _medic;
			// _medic domove _revivePos;
			// _medic moveto _revivePos;
			//remoteExec version. Even though documentation says doMove and MoveTo is global, was getting errors, so remoteExec seemed to fix it. 
			[_medic, position _medic] remoteExec ["doMove", _medic];
			[_medic, _revivePos] remoteExec ["doMove", _medic];
			[_medic, _revivePos] remoteExec ["moveTo", _medic];



			// good for getting confused in buildings - confirm later
			if (_medic distance2D _incap >8) then {
				for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};
				group _medic setSpeedMode "NORMAL";
				_waypoint = (group _medic) addWaypoint [_revivePos, 0];
				_waypoint setWaypointSpeed "FULL";
				_waypoint setWaypointType "MOVE";
			};

			_linenumber = "0868";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};
			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=100 or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0882";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			if (_medic distance2D _revivePos > 97 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
			&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
					[_incap, [_voice+"_100m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
			};	

			_linenumber = "0896";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=50 or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0909";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			if (_medic distance2D _revivePos > 47 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
				&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
						[_incap, [_voice+"_50m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
			};		

			_linenumber = "0923";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			waitUntil {
				sleep 0.1;
				// (_medic distance2D _revivePos <=10 or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				((_medic distance2D _revivePos <=10 && speed _medic < 17) or (_medic distance2D _revivePos <=15 && speed _medic > 17) or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			// randomized greeting as medic approaches incap
			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
					_pairtimebaby = "LifelinePairTimeOut";
					_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
					_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
				if (Lifeline_MedicComments) then {
					_A = str ([1, 3] call BIS_fnc_randomInt);
					_B = str ([1, 6] call BIS_fnc_randomInt);
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetA"+_A, 20, 1, true]] remoteExec ["say3D", 0]};
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetB"+_B, 20, 1, true]] remoteExec ["say3D", 0]};		
				};
			};

			_linenumber = "0953";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;
			waitUntil {
				sleep 0.1;
				// ((_medic distance2D _revivePos <= 6) or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED")
				// ((_medic distance2D _revivePos <= 6) or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				(((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=15 && speed _medic > 17)) or !alive _medic or !alive _incap or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true		
				)
			};

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
				// _medic allowDamage dmg_trig;
				// _medic setCaptive cptv_trig;
				// [_medic,dmg_trig] remoteExec ["allowDamage",_medic]; 
				// [_medic,cptv_trig] remoteExec ["setCaptive",_medic];
				if !(local _medic) then {
					[_medic,dmg_trig] remoteExec ["allowDamage",_medic];
					[_medic,cptv_trig] remoteExec ["setCaptive",_medic];
				} else {
					_medic allowDamage dmg_trig;
					_medic setCaptive cptv_trig;
				};								
			};

			_linenumber = "0978";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			_unblockwtime = time;

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			// some medics were getting stuck waiting for this. Added a timer to unblock.
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;
			waitUntil {
				// if (!(speedmode group _medic == "Limited") && _medic distance2D _incap <=6) then {group _medic setSpeedMode "Limited"};
				if (!(speedmode group _medic == "Limited") && ((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=10 && speed _medic > 17))) then {group _medic setSpeedMode "Limited"};
				_medic domove _revivePos;
				sleep 0.7;
				((_medic distance2D _revivePos <=2.5 && speed _medic < 17) or (_medic distance2D _revivePos <=5 && speed _medic > 17) or !alive _medic or !alive _incap or (time - _unblockwtime > 8) or (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				) 
			};

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
			};
			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;			

			_animMove = "";
			_animStop = "";
			_dist = _medic distance _revivePos;
			_timer = time;

			if (!isnull _EnemyCloseBy) then {
				// commando crawl
				// _revivePos = [_incap, _medic, 1.9] call Lifeline_POSnexttoincap;
				_animMove = "amovppnemsprslowwrfldf"; // move
				_animStop = "amovppnemstpsraswrfldnon"; // stop
			} else {
				// crouch
				// _revivePos = [_incap, _medic, 0.9] call Lifeline_POSnexttoincap;
				_animMove = "amovpknlmwlkslowwrfldf"; //"amovpknlmwlkslowwrfldf"; "amovpknlmrunslowwrfldf" "amovpercmrunsraswrfldf"
				_animStop = "amovpknlmstpslowwrfldnon";
			};
			//ADDED DUE TO _revivePos = 
			/* if (Lifeline_yellowmarker) then {
				_incap call Lifeline_delYelMark;
				_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
				_incap setVariable ["ymarker1", _yelmark, true]; 	
			}; */

			if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
				_medic disableAI "ANIM"; //TEMP
				// _medic playMoveNow _animMove;
				[_medic,_animMove] remoteExec ["playMoveNow",_medic];
				_medic setdir (_medic getDir _incap);
			};

			_rposDist = _revivePos distance2D _incap;

			_linenumber = "1031";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};			

			waitUntil {
				// _medic playMoveNow _animMove;
				[_medic,_animMove] remoteExec ["playMoveNow",_medic];
				_medic doWatch _revivePos;
				// ((_medic distance2D _revivePos <=0.1) or (_medic distance2D _incap <= _rposDist) or (!alive _medic) or (!alive _incap) or (lifestate _medic == "INCAPACITATED") or (lifestate _incap != "INCAPACITATED") or (_exit == true)
				((_medic distance2D _revivePos <=2) or (_medic distance2D _incap <= _rposDist) or (!alive _medic) or (!alive _incap) or (lifestate _medic == "INCAPACITATED") or (lifestate _incap != "INCAPACITATED") or (_exit == true)
				// ((_medic distance2D _revivePos <=5) or (_medic distance2D _incap <= _rposDist) or (!alive _medic) or (!alive _incap) or (lifestate _medic == "INCAPACITATED") or (lifestate _incap != "INCAPACITATED") or (_exit == true)
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)
			};

			if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
				_medic doWatch _incap;
				// _medic playMoveNow _animStop;
				[_medic,_animStop] remoteExec ["playMoveNow",_medic];
				_inview = [position _medic, getDir _medic, 7, position _incap] call BIS_fnc_inAngleSector;
				if (!_inview) then {_medic setdir (_medic getDir (position _incap))};
				_medic doWatch _incap;
			};

			_linenumber = "1056";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			//added
			waitUntil {
				(_medic getVariable ["Lifeline_selfheal_progss",false] == false or (!alive _medic) or (!alive _incap) or (lifestate _medic == "INCAPACITATED") or (lifestate _incap != "INCAPACITATED") or (_exit == true)
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

	};		// end (alive _medic && (lifestate _incap == "incapacitated")


	//======= END IF  end (alive _medic && (lifestate _incap == "incapacitated")


	sleep 0.2;

	// _linenumber = "1082";
	// _exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
	// if (_exit == true) exitWIth {};

	if (alive _incap && alive _medic && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && _exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false ) then {

		//TEMP==========================================
		/* if (!isnull _EnemyCloseBy) then {
			// commando crawl
			_revivePos = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;
		} else {
			// crouch
			_revivePos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
		};
		if (Lifeline_yellowmarker) then {
			_incap call Lifeline_delYelMark;
			_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
			_incap setVariable ["ymarker1", _yelmark, true]; 	
		}; */
		//====METHOD 1, transport to incap
		// _revivePos
		/* [_medic,_revivePos] spawn {
			params ["_medic","_revivePos"];
			// sleep 3;
			if (_medic distance2D _revivePos > 1) then { 
				_medic setPos _revivePos;
				playsound "beep_hi_1";
			};
		}; */
/* 		[_incap,_medic,_revivePos,_EnemyCloseBy] spawn {
			params ["_incap","_medic","_revivePos","_EnemyCloseBy"];
			sleep 4;
			_revivePosCheck = "";
			while {alive _medic && alive _incap && _medic getVariable ["ReviveInProgress",0] == 2 && lifestate _incap == "INCAPACITATED"} do {
				if (!isnull _EnemyCloseBy) then {_revivePosCheck = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;} else {_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap;};
				if (_revivePos isNotEqualTo _revivePosCheck) then {
				// if (_revivePos distance2D _revivePosCheck > 0.3) then {
				// if (_revivePos distance2D _revivePosCheck > 0.5) then {					
					if (Lifeline_yellowmarker) then {
						_incap call Lifeline_delYelMark;
						_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
						_incap setVariable ["ymarker1", _yelmark, true]; 	
					};
				};
				if (_medic distance2D _revivePosCheck > 0.3) then {
					playsound "beep_hi_1";
					_medic setPos _revivePosCheck;
				};
				_direction = _medic getDir _incap;
				_medic setDir _direction;
				sleep 2;
			};
		}; */

		/* //====METHOD 2, walk to incap
		// _revivePos
			// if (_medic distance2D _revivePos > 0.3) then { 
				_medic domove position _medic;
				_medic domove _revivePos;
				_medic moveto _revivePos;
				// playsound "beep_hi_1";
			// };
		// waitUntil {((moveToCompleted _medic) == true)};
		waitUntil {(_medic distance2D _revivePos <= 1)}; */

		//===============================================================
		_medic setVariable ["ReviveInProgress",2,true];

		_incap setVariable ["Lifeline_canceltimer",true,true]; // if showing, cancel it.

		// smoke
		[_incap, _medic] spawn Lifeline_Smoke; 

		_medic dowatch objNull;

		if (lifestate _medic != "INCAPACITATED" && alive _medic) then {_medic setdir (_medic getDir _incap);};

		_exitanim = false;

		//call animations and medic hands-on revive
		if (Lifeline_RevMethod != 3) then {
			_exitanim = [_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_Medic_Anim_and_Revive; 
		};

		if (Lifeline_RevMethod == 3) then {
			[_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_ACE_Revive;
		};

		//explaination of variables. _voice is the voice actor. _B is the randomized second half of greeting. We pass this variable to avoid repeated samples.

		if (_exitanim == true) exitWith {
		};


		// ========= WAKE UP (IF)
		if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap) then {
			// if (isMultiplayer && isPlayer _incap) then {
				// ["#rev", 1, _incap] remoteExecCall ["BIS_fnc_reviveOnState", _incap];
			// };
			[_incap, false] remoteExec ["setUnconscious",_incap]; //remoteexec version
			// _incap setUnconscious false; // non remote exec version
			_incap setdamage 0;			
		};		

	}; // END IF alive medic and incap unit and lifestate incap == "incapacitated" line 1438



	//=====================================================================================================
	//========= EITHER WAKE UP OR BYPASS ==================================================================
	//=====================================================================================================


	// Debug get total revive time and remove debug path marker
	if (Lifeline_Revive_debug) then {
		_incap call Lifeline_delYelMark;
		if (lifestate _incap != "incapacitated" && alive _incap && _exit == false) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ SUCCESS REVIVED // [0952] revive completed'", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap == "incapacitated" && lifestate _medic != "incapacitated" && alive _incap) then {
			// if (Lifeline_hintsilent) then {["Incap not revived"] remoteExec ["hintsilent",2]};
			diag_log format ["%1|%2|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0958] Incap not revived | LifelinePairTimeOut %3 | '", name _incap,name _medic,((_medic getvariable "LifelinePairTimeOut") - time)];
		};
		if (lifestate _medic == "incapacitated" || !alive _medic ) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0963] MEDIC DOWN'", _incap, _medic,name _incap,name _medic];
			if (Lifeline_hintsilent) then {[format ["MEDIC DOWN: %1", name _medic]] remoteExec ["hintsilent",2]};
		};
		if !(alive _incap) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ INCAP DEAD // [0969]'", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap != "INCAPACITATED" && alive _incap && (_exit == true)) then {
			if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0975] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
		};
	};


	// cancel domove and set speed back to normal
	if (_medic == leader _medic) then {
		group _medic setspeedMode "FULL";
	} else {
		group _medic setspeedMode "NORMAL";
	};
	_medic dofollow leader _medic;

	// Bleedout timer reset
	if (lifestate _incap != "INCAPACITATED") then {
		_incap doFollow leader _incap;
		_incap setVariable ["LifelineBleedOutTime", 0, true];
		_incap setVariable ["Lifeline_selfheal_progss",false,true];
	};

	// clear wayppoints for medic
	for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};

	if (lifestate _medic != "INCAPACITATED") then { //added this conditional. if the medic gets downed, then we dont want to reset these
		// [_medic,true] remoteExec ["allowDamage",_medic];
		// [_medic,false] remoteExec ["setCaptive",_medic];
		// _medic allowDamage true;
		// _medic setCaptive false;
		if !(local _medic) then {
				[_medic,true] remoteExec ["allowDamage",_medic];
				[_medic,false] remoteExec ["setCaptive",_medic];
			} else {
				_medic allowDamage true;
				_medic setCaptive false;
			};
		[_medic, objNull] remoteExec ["doWatch",_medic];
	};

	if (Lifeline_Revive_debug && Lifeline_hintsilent && alive _medic && !alive _incap) then {[format ["Incap dead: %1",name _incap]] remoteExec ["hintsilent", 2]};

	// Delete Incap marker
	if !(_incap getVariable ["Lifeline_IncapMark",""] == "") then {
		deleteMarker (_incap getVariable "Lifeline_IncapMark");
		_incap setVariable ["Lifeline_IncapMark","",true];
	};

	// turn on collision
	[_medic, _incap] remoteExecCall ["enableCollisionWith", 0, _medic];

	// Player control group
	if (isplayer _incap && alive _incap && lifestate _incap != "INCAPACITATED") then {
		[group _incap, _incap] remoteExec ["selectLeader", groupOwner group _incap];
	}; 

	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 
	// if ( !(_medic getVariable ["Lifeline_reset_trig",false]) 
	if (_incap getVariable ["ReviveInProgress",0] == 3 || _AssignedMedic isEqualTo [] || _medic getVariable ["Lifeline_ExitTravel", false] == true ) then {
			// _medic setVariable ["Lifeline_reset_trig", true, true]; 
		 [[_incap,_medic],"1232 VERY END TRAVEL"] call Lifeline_reset2;	
	};	


}; // End AIReviveUnits Fnc



Lifeline_Map = {
	params ["_unit"];
	// Add marker
	if (lifestate _unit == "INCAPACITATED" && isTouchingGround _unit && vehicle _unit == _unit) then {
		if ((_unit getVariable ["Lifeline_IncapMark",""]) == "") then {
			_markerName = "Marker" + (name _unit);
			_marker = createMarker [_markerName, position _unit];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "loc_heal";
			_marker setmarkerText (name _unit);
			_marker setMarkerColor "ColorRed";
			// _marker setMarkerSize [0.5,0.5];
			// _marker setMarkerSize [0.8,0.8];
			_marker setMarkerSize [1,1];
			_unit setVariable ["Lifeline_IncapMark",_markerName,true];
		};
	};
	// Remove marker
	if (alive _unit && lifestate _unit != "INCAPACITATED") then {
		if !(_unit getVariable ["Lifeline_IncapMark",""] == "") then {
			deleteMarker (_unit getVariable "Lifeline_IncapMark");
			_unit setVariable ["Lifeline_IncapMark","",true];
		};
	};
	// Add dead marker
	if (lifeState _unit == "DEAD" || lifeState _unit == "DEAD-RESPAWN" || lifeState _unit == "DEAD-SWITCHING") then {
		if ((_unit getVariable ["Lifeline_IncapMark",""]) != "Dead") then {
			_markerName = "Dead";
			_marker = createMarker [_markerName, position _unit];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "KIA";
			_marker setmarkerText (name _unit);
			_marker setMarkerColor "ColorBlack";
			// _marker setMarkerSize [0.5,0.5];
			// _marker setMarkerSize [0.8,0.8];
			_marker setMarkerSize [0.7,0.7];
			_unit setVariable ["Lifeline_IncapMark",_markerName,true];
		};
	};
};


Lifeline_checkdegrees = {
params ["_incap", "_medic","_range"];


_direction1 = _medic getDir _incap;
_direction2 = getDir _medic;



// Calculate the absolute difference
_difference = abs(_direction1 - _direction2);

// Adjust for circular nature
if (_difference > 180) then {
    _difference = 360 - _difference;
};

// Check if the difference is within the range
_isWithinRange = _difference <= _range;

/* if (_isWithinRange) then {
    hint "Direction is within range!";
} else {
    hint "Direction is not within range.";
};
 */

_isWithinRange

};



 //BONUS FUNCTIONS.
 //Hotwire locked vehicles
 