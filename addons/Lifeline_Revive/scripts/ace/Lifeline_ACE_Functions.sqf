diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================== Lifeline_ACE_Functions.sqf =========================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

["ace_unconscious", {
	params ["_unit",  "_status"];

		if (_unit in Lifeline_All_Units)	then {

			if (_status == true) then {
				_unit setVariable ["Lifeline_selfheal_progss",false,true]; //clear var if it was in middle of self healing

				// ================= added the killed event handler
				_unit addEventHandler ["Killed", {
					params ["_unit2", "_killer2", "_instigator2", "_useEffects2"];									
					_unit call Lifeline_reset;
					Lifeline_Process = Lifeline_Process - [_unit];
					Lifeline_incapacitated = Lifeline_incapacitated - [_unit]; 
					publicVariable "Lifeline_Process";	
					_unit enableSimulationGlobal false;//myedit test		
				}];
				//===============================================

				//	if !(lifestate _unit == "INCAPACITATED") then {
					[_unit] spawn {
						params ["_unit"];
						// if (damage _unit <0.9) then {
							// _unit setDamage 0.8;

							if (!isnull objectParent _unit) then {
								_vehicle = objectParent _unit;
								_pos = _unit getPos [(4 + random 3), (getdir _vehicle) + (60 + random 20)];
								sleep 3 + random 3;
								moveOut _unit;
								_unit setPosATL _pos
							};
							_unit setcaptive true; 
							// _unit allowdamage false; //zdo

							//_unit setUnconscious true; //old line
							//[_unit, true] call ace_medical_fnc_setUnconscious; //NEW line
							Lifeline_incapacitated pushBackUnique _unit;
							publicVariable "Lifeline_incapacitated";
							if (count units group _unit ==1) then {
								if (_unit getVariable ["Lifeline_OrigPos",[]] isEqualTo []) then {
									_pos = (getPosATL _unit);
									_dir = (getdir _unit);
									_unit setVariable ["Lifeline_OrigPos", _pos, true];
									_unit setVariable ["Lifeline_OrigDir", _dir, true];
								};
							};
					};
			//	};
			} else {
				_unit setVariable ["Lifeline_selfheal_progss",false,true];
			_AssignedMedic = (_unit getVariable ["Lifeline_AssignedMedic",[]]); 
			if (_AssignedMedic isNotEqualTo [] || _unit getVariable ["ReviveInProgress",0] == 3) then {
			// _unit setVariable ["Lifeline_ExitTravel", true, true];
			(_AssignedMedic select 0) setVariable ["Lifeline_ExitTravel", true, true];//medic set Lifeline_ExitTravel
			} else {	

			[[_unit],"72 ACE WAKEUP"] spawn Lifeline_reset2;

			};
			};		
		};	//	if (_unit in Lifeline_All_Units)					
}] call CBA_fnc_addEventHandler; 




Lifeline_ACE_Anims_Voice = {
params ["_incap", "_medic","_EnemyCloseBy","_voice","_switch", "_againswitch", "_encourage","_enc_count"];

		// Kneeling revive - no near enemy
		if (isNull _EnemyCloseBy) then {
		[_medic, "AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMove", _medic]; // ORIGNAL
			 // sleep 8;
					sleep 4;
						_rando = selectRandom[1,2,3,4];
						if (_rando == 1) then { 
						[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
						if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
						};
					sleep 4;
		};

		// Lying down revive - near enemy. Alternating between two anims to fix an Arma bug
		if (!isNull _EnemyCloseBy) then {
					if (_switch == 0) then {
						[_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", _medic];
						_switch = 1;
						// sleep 9;
						sleep 4.5;
							_rando = selectRandom[1,2,3,4];
							if (_rando == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							};
						sleep 4.5;
					} else {
						[_medic, "AinvPpneMstpSlayWpstDnon_medicOther"] remoteExec ["playMove", _medic];
						_switch = 0;
						// sleep 9.5;
						sleep 4.75;
							_rando = selectRandom[1,2,3,4];
							if (_rando == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							};
						sleep 4.75;
					}; 
		};	
[_switch, _againswitch, _enc_count]

};



Lifeline_ACE_Revive = {
params ["_incap", "_medic","_EnemyCloseBy","_voice"];
		_switch = 0;
		_againswitch = 1; // this is so the voice sample "and again" alternates samples and not sound robotic
		_encourage = ["_greetB5", "_greetB2", "_almostthere1"];	//different voices of encouragement
		_enc_count = 0;											//round-robin counter for above	
		_cprcount = 1;
		_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;

		while {_cpr == true && _cprcount < 6 && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED"} do {

					if (lifestate _incap == "DEAD" || !(alive _incap) ) exitWith {};

					// [_medic, [_voice+"_CPR1", 50, 1, true]] remoteExec ["say3D", 0];
					[_medic, [_voice+"_CPR1", 20, 1, true]] remoteExec ["say3D", 0]; //softer

					if (_cprcount == 1) then {
						[_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMove", _medic]; //kind of press, but static
					};

					//added to increase revive time limit on each loop pass
					_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
					_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
					_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
					_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

					if (isPlayer _incap && Lifeline_HUD_medical) then {
						_colour = "F9CAA7";
						[format ["<t align='right' size='%2' color='#%1'>CPR</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					};

					_cprcount = _cprcount + 1;
					[_medic, _incap, "RightArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
					sleep 2;
					[_medic, _incap] call ace_medical_treatment_fnc_cprStart;
					 sleep 10;
					// [_medic, _incap] call ace_medical_treatment_fnc_cprSuccess;
					// sleep 2;
					_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
		};

		if (_cprcount > 1 && alive _incap) then {
			[_medic, [_voice+"_pulse1", 20, 1, true]] remoteExec ["say3D", 0]; //softer
		};


		if (Lifeline_ACE_Bandage_Method == 1) then {		

					// ================= BANDAGE ACTION LOOP ================

				// _bandages = (_countw + _countf);		

				_countbaby = 0;
				_enc_count = 0;
				_notrepeat = "";
				_key1 = "head";

				// while {([_medic, _incap, _key1, "FieldDressing"] call ace_medical_treatment_fnc_canBandage)} do {
				while {(_incap call ace_medical_blood_fnc_isBleeding)} do {

					if (lifestate _incap != "INCAPACITATED") exitWith {};
					if (lifestate _medic == "INCAPACITATED") exitWith {}; //with other players healing simultaneously, this can happen
					if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};

					if ([_medic, _incap, _key1, "BasicBandage"] call ace_medical_treatment_fnc_canBandage) then {

						_bleedingwounds = [];
						_other = [];

						//==================== COUNT BNADAGES ===================

						if (oldACE == false) then {
							_jsonStr = _incap call ace_medical_fnc_serializeState; 		
							_jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  // 2nd arg will get native hashMaps
							_woundsHash = _jsonhash get "ace_medical_openwounds";
							_countw = 0;									
							{ 	
								private _woundsOnLimb = _y; 
								{ 
									if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ||  _x select 1 == 0 ) then {
										_other = _other + [_x];
									} else {
										_bleedingwounds = _bleedingwounds + [_x];
									};
								} forEach _woundsOnLimb; 
							} forEach _woundsHash; 	
						};

						if (oldACE == true) then {	
							 _jsonStr = _incap call ace_medical_fnc_serializeState; 		
							 _json = [_jsonStr] call CBA_fnc_parseJSON;	
							 _wounds = _json getVariable ["ace_medical_openwounds", false];
							{
								if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ||  _x select 2 == 0 ) then {
									_other = _other + [_x];
								} else {
									_bleedingwounds = _bleedingwounds + [_x];
								};
							} forEach _wounds;
						};


						//HINT	
						if (isPlayer _incap && Lifeline_HUD_medical) then {
							_colour = "F9CAA7";
							[format ["<t align='right' size='%2' color='#%1'>%3 Wound%4</t>",_colour, 0.5,count _bleedingwounds,if (count _bleedingwounds == 1) then {""} else {"s"}],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
						};	

						// dont voice empty keys

						if (_key1 != _notrepeat) then {
							if (_key1 == "leftleg") then {
								[_medic, [_voice+"_leftleg1", 20, 1, true]] remoteExec ["say3D", 0];
							};
							if (_key1 == "rightleg") then {
								[_medic, [_voice+"_rightleg1", 20, 1, true]] remoteExec ["say3D", 0];
							};
							if (_key1 == "body") then {
								[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
							};
							if (_key1 == "leftarm") then {
								[_medic, [_voice+"_leftarm1", 20, 1, true]] remoteExec ["say3D", 0];
							};
							if (_key1 == "rightarm") then {
								[_medic, [_voice+"_rightarm1", 20, 1, true]] remoteExec ["say3D", 0];
							};
							if (_key1 == "head") then {
								[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
							};
						};

						//encouragment or "and again" voice sample
						_repeatrandom = selectRandom[1,2];
						if (_key1 == _notrepeat && _enc_count < 3 && _repeatrandom == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
						};
						if (_key1 == _notrepeat && _repeatrandom == 2) then { 
							[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
							if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
						};	
						_notrepeat = _key1;

						if (lifestate _incap != "INCAPACITATED") exitWith {};
						if (lifestate _medic == "INCAPACITATED") exitWith {}; //with other players healing simultaneously, this can happen

						if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};

						sleep 0.5;
						// sleep 1;

						//added to increase revive time limit on each loop pass
						_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
						_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
						_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
						_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

						//===================================bandage 
						[_medic, _incap, _key1, "BasicBandage"] call ace_medical_treatment_fnc_bandage;
						//==========================================

						//============================ CALL ANIMATION ==============================
						_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
						_switch = _animsvoice select 0;
						_againswitch = _animsvoice select 1;
						_enc_count = _animsvoice select 2;
						// ==========================================================================

						_cprcount = 1;		
						sleep 1;

						// if (count _value1 <= 0) exitWith {}; //with other players healing simultaneously, this can happen

					} else {

						if (_key1 == "head") exitWith {
						_key1 = "body";
						};
						if (_key1 == "body") exitWith {
						_key1 = "leftleg";
						};
						if (_key1 == "leftleg") exitWith {
						_key1 = "rightleg";
						};
						if (_key1 == "rightleg") exitWith {
						_key1 = "leftarm";
						};
						if (_key1 == "leftarm") exitWith {
						_key1 = "rightarm";
						};
					};	// if can bandage			    

				}; //WHILE is Bleeding


		}; // if (Lifeline_ACE_Bandage_Method == 1) then



		if (Lifeline_ACE_Bandage_Method == 2) then {	

			if (oldACE == false) then {

				private _jsonStr = _incap call ace_medical_fnc_serializeState; 		
				private _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  // 2nd arg will get native hashMaps
				private _woundsHash = _jsonhash get "ace_medical_openwounds";
				private _fractures = _jsonhash get "ace_medical_fractures";

				_countw = 0;
				{ 	
					private _woundsOnLimb = _y; 
					{ 
						_countw = _countw + 1;
					} forEach _woundsOnLimb; 
				} forEach _woundsHash; 	

				_countf = 0;
				{
					private _index = _forEachIndex; // Get the current index
					if (_x == 1) then {
					_countf = _countf +1;
					};
				} forEach _fractures;

				// _bandages = (_countw + _countf);

				_countbaby = 0;
				_enc_count = 0;

				// ================= BANDAGE ACTION LOOP ================

				{
					if (lifestate _incap != "INCAPACITATED") exitWith {};
					if (lifestate _medic == "INCAPACITATED") exitWith {
						if (Lifeline_Revive_debug) then {
							if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
						};
					}; //with other players healing simultaneously, this can happen

					if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};

					 _jsonStr = _incap call ace_medical_fnc_serializeState; 		
					 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  // 2nd arg will get native hashMaps
					 _woundsHash = _jsonhash get "ace_medical_openwounds";

					 // delete wounds that have been done by a live player (wounds are not deleted, just a value changed to 0 )
					 {
						 _key2 = _x;    
						 _value2 = _woundsHash get _key2;  
						{
							if (_x select 1 == 0) then {
									_value2 = _value2 - [_x];
									_woundsHash set [_key2, _value2];
							};
							// _woundsHash set [_key2, _value2];									
						} forEach (_value2);
					} forEach (keys _woundsHash);

					 _fractures = _jsonhash get "ace_medical_fractures";
					 _key1 = _x;    // _x represents each key in the hashmap
					 _value1 = _woundsHash get _key1;  // Get the value associated with the key

					_bleedingwounds = [];
					_bruises = [];

					{
						if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
							_bruises = _bruises + [_x];
						} else {
							_bleedingwounds = _bleedingwounds + [_x];
						};
					} forEach _value1;



					_notrepeat = "";

					// if (count _value1 > 0) then {  // dont voice empty keys
					if (count _bleedingwounds > 0) then {  // dont voice empty keys

						if (_key1 == "leftleg") then {
							[_medic, [_voice+"_leftleg1", 20, 1, true]] remoteExec ["say3D", 0];
						};
						if (_key1 == "rightleg") then {
							[_medic, [_voice+"_rightleg1", 20, 1, true]] remoteExec ["say3D", 0];
						};
						if (_key1 == "body") then {
							[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
						};
						if (_key1 == "leftarm") then {
							[_medic, [_voice+"_leftarm1", 20, 1, true]] remoteExec ["say3D", 0];
						};
						if (_key1 == "rightarm") then {
							[_medic, [_voice+"_rightarm1", 20, 1, true]] remoteExec ["say3D", 0];
						};
						if (_key1 == "head") then {
							[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
						};
					};


					// while {count _value1 > 0} do {	
					while {count _bleedingwounds > 0} do {	


						//encouragment or "and again" voice sample
						_repeatrandom = selectRandom[1,2];
						if (_key1 == _notrepeat && _enc_count < 3 && _repeatrandom == 1) then { 
							[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
							if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
						};
						if (_key1 == _notrepeat && _repeatrandom == 2) then { 
							[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
							if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
						};	
						_notrepeat = _key1;

						// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};

						if (lifestate _incap != "INCAPACITATED") exitWith {};
						if (lifestate _medic == "INCAPACITATED") exitWith {
							if (Lifeline_Revive_debug) then {
								if (Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
							};
						}; //with other players healing simultaneously, this can happen

						if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};

						//ALL AT FRONT NOW
						 _jsonStr = _incap call ace_medical_fnc_serializeState; 	
						 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
						 _woundsHash = _jsonhash get "ace_medical_openwounds";				
						// private _key1 = _x;    

						// delete wounds that have been done by a live player (wounds are not deleted, just a value changed to 0. This deletes them instead )
						_countw = 0;
						{
							 _key2 = _x;    
							 _value2 = _woundsHash get _key2;  
							{
								if (_x select 1 == 0) then {
										_value2 = _value2 - [_x];
										_woundsHash set [_key2, _value2];
								} else {
									if (_x select 0 != 20 && _x select 0 != 21 && _x select 0 != 22 && _x select 0 != 80 && _x select 0 != 81 && _x select 0 != 82 ) then {
									_countw = _countw + 1;
									};
								};							
							} forEach (_value2);
						} forEach (keys _woundsHash);

						//SCREEN HINT
						if (isPlayer _incap && Lifeline_HUD_medical) then {
							_colour = "F9CAA7";
							[format ["<t align='right' size='%2' color='#%1'>%3 Bandages</t>",_colour, 0.5,_countw],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
						};

					     _value1 = _woundsHash get _key1; 

						// seperate bleeding wounds from bruises
						_bleedingwounds = [];
						_bruises = [];

						{
							if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
								_bruises = _bruises + [_x];
							} else {
								_bleedingwounds = _bleedingwounds + [_x];
							};
						} forEach _value1;


						sleep 0.5;

						// _value1 = _value1 - [_value1 select 0];
						_bleedingwounds = _bleedingwounds - [_bleedingwounds select 0];
						_woundsHash set [_key1, _bleedingwounds + _bruises];																				
						_jsonhash set ["ace_medical_openwounds", _woundsHash];

						 _newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
						[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
						// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];

						sleep 1;


						//added to increase revive time limit on each loop pass
						_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
						_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
						_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
						_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

						//============================ CALL ANIMATION ==============================
						_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
						_switch = _animsvoice select 0;
						_againswitch = _animsvoice select 1;
						_enc_count = _animsvoice select 2;
						// ==========================================================================

						_cprcount = 1;		
						sleep 1;

						if (count _value1 <= 0) exitWith {}; //with other players healing simultaneously, this can happen

					};	// while {count _bleedingwounds > 0} do {					    

				} forEach (keys _woundsHash);

			}; //============================ if not OLD ACE


			if (oldACE == true) then {	

					 _jsonStr = _incap call ace_medical_fnc_serializeState; 		
					 _json = [_jsonStr] call CBA_fnc_parseJSON;	
					 _wounds = _json getVariable ["ace_medical_openwounds", false];
					 _fractures = _json getVariable ["ace_medical_fractures", false];					
					_bleedingwounds = [];
					_bruises = [];

					{
						if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
							_bruises = _bruises + [_x];
						} else {
							_bleedingwounds = _bleedingwounds + [_x];
						};
					} forEach _wounds;

							{
								if (_bleedingwounds select 0 select 2 == 0) then {
									_bleedingwounds = _bleedingwounds - [_bleedingwounds select 0];
								};
							} forEach _bleedingwounds;


					_countf = 0;
					{
						private _index = _forEachIndex; // Get the current index
						if (_x == 1) then {
						_countf = _countf +1;
						};
					} forEach _fractures;

					_EnemyCloseBy = [_incap] call Lifeline_EnemyCloseBy;
					_woundcount = count _bleedingwounds;
					_counter = _woundcount;
					_counter2 = _woundcount;
					_wounds2 = _bleedingwounds;
					_switch = 0;
					_consolidated = [];
					_head = []; _torso = []; _leftarm = []; _rightarm = []; _leftleg = []; _rightleg = []; 

					while {_counter2 > 0} do {
						_bodypart = _wounds2 select 0 select 1;
						if (_bodypart == 0) then {
							_head = _head + [_wounds2 select 0];
						};
						if (_bodypart == 1) then {
							_torso = _torso + [_wounds2 select 0];
						};
						if (_bodypart == 2) then {
							_leftarm = _leftarm + [_wounds2 select 0];
						};
						if (_bodypart == 3) then {
							_rightarm = _rightarm + [_wounds2 select 0];
						};
						if (_bodypart == 4) then {
							_leftleg = _leftleg + [_wounds2 select 0];
						};
						if (_bodypart == 5) then {
							_rightleg = _rightleg + [_wounds2 select 0];
						};
						_counter2 = _counter2 - 1;
						_wounds2 = _wounds2 - [_wounds2 select 0];					
					};

					_reordered_wounds = _head + _torso + _leftarm + _rightarm + _leftleg + _rightleg;

					_json setVariable ["ace_medical_openwounds", _reordered_wounds + _bruises];
					_newJsonStr = [_json] call CBA_fnc_encodeJSON;
					// _json call CBA_fnc_deleteNamespace;
					[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
					// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];

					_bodypartcounter = 0;
					_notrepeat = -1;

					_encourage = ["_greetB5", "_greetB2", "_almostthere1"];
					_enc_count = 0;

					while {count _reordered_wounds > 0} do {

							_jsonStr = _incap call ace_medical_fnc_serializeState; 		
							_json = [_jsonStr] call CBA_fnc_parseJSON;	
							_wounds = _json getVariable ["ace_medical_openwounds", false];
							_bleedingwounds = [];
							_bruises = [];

								{
									if (_x select 0 == 20 || _x select 0 == 21 || _x select 0 == 22 || _x select 0 == 80 || _x select 0 == 81 || _x select 0 == 82 ) then {
										_bruises = _bruises + [_x];
									} else {
										_bleedingwounds = _bleedingwounds + [_x];
									};
								} forEach _wounds;


							_reordered_wounds = _bleedingwounds;


							{
								if (_reordered_wounds select 0 select 2 == 0) then {
									_reordered_wounds = _reordered_wounds - [_reordered_wounds select 0];
								};
							} forEach _reordered_wounds;

							_json setVariable ["ace_medical_openwounds", _reordered_wounds + _bruises];
							_newJsonStr = [_json] call CBA_fnc_encodeJSON;
							// _json call CBA_fnc_deleteNamespace;
							[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
							// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
							// if (_counter <= 0) exitWith {};
							if (count _reordered_wounds <= 0) exitWith {};
							if (lifestate _incap != "INCAPACITATED") exitWith {};
							if (lifestate _medic == "INCAPACITATED") exitWith {
								if (Lifeline_Revive_debug) then {
									if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
								};
							};
							if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};

							if (isPlayer _incap && Lifeline_HUD_medical) then {
								_colour = "F9CAA7";
								[format ["<t align='right' size='%2' color='#%1'>%3 Bandages</t>",_colour, 0.5,count _reordered_wounds],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
							};

							_bodypart = _reordered_wounds select 0 select 1;

							_partname = "";

							if (_bodypart != _notrepeat) then { // to stop voice stating body part twice in a row
								if (_bodypart == 0) then {
									[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "HEAD";
								};
								if (_bodypart == 1) then {
									[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "TORSO";
								};
								if (_bodypart == 2) then {
									[_medic, [_voice+"_leftarm1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "LEFT ARM";
								};
								if (_bodypart == 3) then {
									[_medic, [_voice+"_rightarm1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "RIGHT ARM";
								};
								if (_bodypart == 4) then {
									[_medic, [_voice+"_leftleg1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "LEFT LEG";
								};
								if (_bodypart == 5) then {
									[_medic, [_voice+"_rightleg1", 20, 1, true]] remoteExec ["say3D", 0];
									_partname = "RIGHT LEG";
								};
							};


							//encouragment or "and again" voice sample
							_repeatrandom = selectRandom[1,2];
							if (_bodypart == _notrepeat && _enc_count < 3 && _repeatrandom == 1) then { 
								[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
								if (_enc_count == 2) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							};
							if (_bodypart == _notrepeat && _repeatrandom == 2) then { 
								[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
								if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
							};

							_notrepeat = _bodypart;


							//added to increase revive time limit on each loop pass
							_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
							_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
							_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
							_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 

							//actual healing of data moved before animation now to stop errors when live players also healing incap at same time
							// _counter = _counter - 1;
							_reordered_wounds = _reordered_wounds - [_reordered_wounds select 0];
							_json setVariable ["ace_medical_openwounds", _reordered_wounds + _bruises];
							_newJsonStr = [_json] call CBA_fnc_encodeJSON;
							// _json call CBA_fnc_deleteNamespace;
							[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
							// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];

							//============================ CALL ANIMATION ==============================

							_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
							_switch = _animsvoice select 0;
							_againswitch = _animsvoice select 1;
							_enc_count = _animsvoice select 2;
							// ==========================================================================

							_cprcount = 1;	

							// _count = [_incap,_wott] call AceRevive1;
							//_counter = count _count;

							_currentpart = _bodypart;

					}; // WHILE 


			}; // OLD ACE
		}; // if ACE revive method == 2



		//checks to leave revive process
		if (lifestate _incap != "INCAPACITATED") exitWith {};
		if (lifestate _medic == "INCAPACITATED") exitWith {
			if (Lifeline_Revive_debug) then {
				if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
			};
		}; 
		if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};
		// IV if needed
		// ====================ADD BLOOD IF NEEDED
		_json = [];
		_bloodvolume = [];
		if (oldACE == false) then {
			 _jsonStr = _incap call ace_medical_fnc_serializeState; 
			 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
			 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
		} else {
			 _jsonStr = _incap call ace_medical_fnc_serializeState;
			 _json = [_jsonStr] call CBA_fnc_parseJSON;
			 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
		};

		_jsonStr = _incap call ace_medical_fnc_serializeState; 	
		_json = [_jsonStr] call CBA_fnc_parseJSON;
		_jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
		_fractures = [];

		if (oldACE == false) then {
			_fractures = _jsonhash get "ace_medical_fractures";
		} else {
			_fractures = _json getVariable ["ace_medical_fractures", false];
		};

		//=========FRACTURES

		// quick count of fractures	
			_countf = 0;
		{
			private _index = _forEachIndex; 
			if (_x == 1) then {
			_countf = _countf +1;
			};
		} forEach _fractures;			

		if (_bloodvolume <= 5) then {
			// [_medic, [_voice+"_giveblood1", 50, 1, true]] remoteExec ["say3D", 0];
			[_medic, [_voice+"_giveblood1", 20, 1, true]] remoteExec ["say3D", 0];
			[_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;

			if (_countf == 0) then { // if there are no fractures, then have anim for blood IV (usually blood can inject while fractures being fixed. Saves time)

				//added to increase revive time limit on each loop pass					
				_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
				_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
				_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 10, true]; 
				_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 10, true]; 			
				if (isPlayer _incap && Lifeline_HUD_medical) then {
				_colour = "F9CAA7";
				[format ["<t align='right' size='%2' color='#%1'>Blood IV</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};

				// Kneeling revive - no near enemy
				if (isNull _EnemyCloseBy) then {
					[_medic,  "AinvPknlMstpSnonWnonDnon_medic1" ] remoteExec ["playMove", _medic];
					 // [_medic, SelectRandom ["AinvPknlMstpSnonWnonDnon_medic1", "AinvPknlMstpSnonWnonDnon_medic2"]] remoteExec ["playMove", _medic];
					 sleep 8;  
				};

				// Lying down revive - near enemy. Alternating between two anims to fix an Arma bug
				if (!isNull _EnemyCloseBy) then {
					if (_switch == 0) then {
							[_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", _medic];
							_switch = 1; 
							sleep 9;
						 } else { [_medic, "AinvPpneMstpSlayWpstDnon_medicOther"] remoteExec ["playMove", _medic];
							// [_medic, "AinvPpneMstpSlayWnonDnon_medicOther"] remoteExec ["playMove", _medic]; //sometimes looks missing arm 
							_switch = 0;
							sleep 9.5;	
						}; 
				};	
			};
			if (_countf > 0) then {sleep 2;}; // add some seconds if fractures exist to give space between voice samples
		};

		_firstrun = true;

		{
			private _index = _forEachIndex; // Get the current index
			if (_x == 1) then {
				if (lifestate _incap != "INCAPACITATED") exitWith {};
				if (lifestate _medic == "INCAPACITATED") exitWith {
					if (Lifeline_Revive_debug) then {
						if (isPlayer _incap && Lifeline_hintsilent) then {[ "MEDIC DOWN" ] remoteExec ["hintsilent",_incap]};
					};
				}; //with other players healing simultaneously, this can happen
				// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) exitWith {};
				if (_firstrun == true) then {
					// [_medic, [_voice+"_fracture1", 50, 1, true]] remoteExec ["say3D", 0];
					[_medic, [_voice+"_fracture1", 20, 1, true]] remoteExec ["say3D", 0];
					_firstrun = false;
				} else {
					[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
					if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
				};

				//ALL AT FRONT NOW
				_jsonStr = _incap call ace_medical_fnc_serializeState; 	
				_json = [_jsonStr] call CBA_fnc_parseJSON;
				_jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 

				if (oldACE == false) then {
					_fractures = _jsonhash get "ace_medical_fractures";
				} else {
					_fractures = _json getVariable ["ace_medical_fractures", false];						
				};

				_countf = 0;{private _index = _forEachIndex; if (_x == 1) then {_countf = _countf +1;};} forEach _fractures;
				if (isPlayer _incap && Lifeline_HUD_medical) then {										
					_colour = "F9CAA7";
					[format ["<t align='right' size='%2' color='#%1'>%3 Fractures</t>",_colour, 0.5,_countf],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};

				if (oldACE == false) then {
					_fractures set [_index, 0]; // Change 1 to 0					
					_jsonhash set ["ace_medical_fractures", _fractures];
					_newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
					[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
					// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
				} else {
					_fractures set [_index, 0];
					_json setVariable ["ace_medical_fractures", _fractures];
					_newJsonStr = [_json] call CBA_fnc_encodeJSON;
					// _json call CBA_fnc_deleteNamespace;
					[_incap, _newJsonStr, true] call fix_medical_fnc_deserializeState;
					// [_incap, _newJsonStr] remoteExec ["fix_medical_fnc_deserializeState", _incap];
				};

				//added to increase revive time limit on each loop pass
				_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
				_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
				_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 10, true]; 
				_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 10, true]; 


				//============================ CALL ANIMATION ==============================
				_animsvoice = [_incap, _medic,_EnemyCloseBy,_voice,_switch, _againswitch, _encourage,_enc_count] call Lifeline_ACE_Anims_Voice;
				_switch = _animsvoice select 0;
				_againswitch = _animsvoice select 1;
				_enc_count = _animsvoice select 2;				
				// ==========================================================================

			}; // if (_x == 1) then {

		} forEach _fractures;


		if (lifestate _incap != "INCAPACITATED") exitWith {};

		// ====== blood again if needed - not spawned to allow voice sample time to play
		if (oldACE == false) then {
				 _jsonStr = _incap call ace_medical_fnc_serializeState; 
				 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
				 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
		} else {
				 _jsonStr = _incap call ace_medical_fnc_serializeState;
				 _json = [_jsonStr] call CBA_fnc_parseJSON;
				 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
		};

		if (_bloodvolume <= 5) then {
			// [_medic, [_voice+"_moreblood1", 50, 1, true]] remoteExec ["say3D", 0];
			[_medic, [_voice+"_moreblood1", 20, 1, true]] remoteExec ["say3D", 0];
			if (isPlayer _incap && Lifeline_HUD_medical) then {
				_colour = "F9CAA7";
				[format ["<t align='right' size='%2' color='#%1'>More Blood IV</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
			};

			[_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;

		}; 

		// last check for blood, in a spawned loop process
		[_incap,_medic] spawn {
			params ["_incap","_medic"];
			_json = [];
			_bloodvolume = [];
			if (oldACE == false) then {
				 _jsonStr = _incap call ace_medical_fnc_serializeState; 
				 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
				 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
			} else {
				 _jsonStr = _incap call ace_medical_fnc_serializeState;
				 _json = [_jsonStr] call CBA_fnc_parseJSON;
				 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
			};
			while {_bloodvolume <= 5} do {
				sleep 5;
				if (oldACE == false) then {
					 _jsonStr = _incap call ace_medical_fnc_serializeState; 
					 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
					 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
				} else {
					 _jsonStr = _incap call ace_medical_fnc_serializeState;
					 _json = [_jsonStr] call CBA_fnc_parseJSON;
					 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
				};
				[_incap, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;
			}; 
		};

		//========================== check cardiac arrest do CPR again to be sure

		_cprcount = 1;
		_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;

		while {_cpr == true && _cprcount < 6 && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED"} do {

			// [_medic, [_voice+"_CPR1", 50, 1, true]] remoteExec ["say3D", 0];
			[_medic, [_voice+"_CPR1", 20, 1, true]] remoteExec ["say3D", 0]; //softer

			if (!isNull _EnemyCloseBy) then {
				[_medic, "AmovPpneMstpSrasWrflDnon_AmovPercMsprSlowWrflDf"] remoteExec ["PlayMove", _medic];
			};	
			sleep 2;

			if (_cprcount == 1) then {
				[_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMove", _medic]; //from ACE DEVS
			};

			//added to increase revive time limit on each loop pass			
			_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
			_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
			_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 12, true]; 
			_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 12, true]; 


			if (isPlayer _incap && Lifeline_HUD_medical) then {
				_colour = "F9CAA7";
				[format ["<t align='right' size='%2' color='#%1'>CPR</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
			};

			_cprcount = _cprcount + 1;
			[_medic, _incap, "RightArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
			sleep 2;
			[_medic, _incap] call ace_medical_treatment_fnc_cprStart;
			 sleep 10;
			// [_medic, _incap] call ace_medical_treatment_fnc_cprSuccess;
			// sleep 2;
			_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;

		}; // end while

		if (_cprcount > 1 && alive _incap) then {
			[_medic, [_voice+"_pulse1", 20, 1, true]] remoteExec ["say3D", 0]; //softer
		};

		// ============== EPI & MORPHINE

		[_medic, _incap, "RightArm", "Morphine", objNull, "ACE_morphine"] call ace_medical_treatment_fnc_medication;

		_counter = 1;

		// EPI to wake up.
		while {_counter < 4 && lifestate _incap == "INCAPACITATED" } do {	

				if (lifestate _incap == "INCAPACITATED") then {
					// if (lifestate _incap == "INCAPACITATED" && !(_incap getVariable ["Lifeline_3timesEPI",false])) then {

					if (isPlayer _incap && Lifeline_HUD_medical) then {
						_colour = "F9CAA7";
						[format ["<t align='right' size='%2' color='#%1'>Epinephrine</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					};

					if (_counter == 1) then {
						// [_medic, [_voice+"_giveEpinephrine1", 50, 1, true]] remoteExec ["say3D", 0];
						[_medic, [_voice+"_giveEpinephrine1", 20, 1, true]] remoteExec ["say3D", 0];
							// morphine too in 4 seconds. Not said eveytime for some randomness
							if (selectRandom[1,2] ==1) then {
								[_incap,_medic,_voice] spawn {
								params ["_incap","_medic","_voice"];
								sleep 6;
								[_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
								if (isPlayer _incap && Lifeline_HUD_medical) then {
								_colour = "F9CAA7";
								[format ["<t align='right' size='%2' color='#%1'>Morphine</t>",_colour, 0.5],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
								};
								};
							};														
					} else {
						// [_medic, [_voice+"_givingmore"+str (_counter - 1), 50, 1, true]] remoteExec ["say3D", 0];
						[_medic, [_voice+"_givingmore"+str (_counter - 1), 20, 1, true]] remoteExec ["say3D", 0];
					};

					//added to increase revive time limit on each loop pass					
					_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
					_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
					_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 15, true]; 
					_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 15, true]; 				

					// Kneeling revive - no near enemy
					if (isNull _EnemyCloseBy) then {
						[_medic,  "AinvPknlMstpSnonWrflDnon_medic1" ] remoteExec ["playMove", _medic];
						sleep 8;
					};
					// Lying down revive - near enemy. Alternating between two anims to fix an Arma bug
					if (!isNull _EnemyCloseBy) then {
						if (_switch == 0) then {
							[_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", _medic];
							_switch = 1;
							sleep 9;
						} else {
							[_medic, "AinvPpneMstpSlayWpstDnon_medicOther"] remoteExec ["playMove", _medic];
							_switch = 0;
							sleep 9.5;
						}; 
					};	
					[_medic, _incap, "RightArm", "Epinephrine", objNull, "ACE_epinephrine"] call ace_medical_treatment_fnc_medication;
				};		

				if (lifestate _incap != "INCAPACITATED") exitWith {};

				sleep 5;

				if (_counter == 3) then {
					 // _incap setVariable ["Lifeline_3timesEPI",true,true];

					if (lifestate _incap == "INCAPACITATED") then {

						// this is a hack. need to figure out why not reviving with 3 epis sometimes

						//added to increase revive time limit on each loop pass					
						_timelimitincap = (_incap getvariable "LifelinePairTimeOut");
						_timelimitmedic = (_medic getvariable "LifelinePairTimeOut");
						_incap setVariable ["LifelinePairTimeOut", _timelimitincap + 15, true]; 
						_medic setVariable ["LifelinePairTimeOut", _timelimitmedic + 15, true]; 

						// sleep 5;
						// [_incap, false] call ace_medical_status_fnc_setUnconsciousState;
						sleep 5;
						// [_incap] call ace_medical_treatment_fnc_fullHealLocal;
						[_medic, _incap] call ace_medical_treatment_fnc_fullHeal;
					};
				};
				_counter = _counter + 1;
		};

		// sleep 10;	
		// [_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];

		[_medic, _incap] spawn {
			params ["_medic", "_incap"];
			_medic setdir (_medic getDir _incap)+10;
		};	
};



Lifeline_SelfHeal_ACE = {
params ["_unit"];
	if (alive _unit && lifestate _unit != "INCAPACITATED" && !isPlayer _unit) then {

		// _unit setVariable ["Lifeline_selfheal_progss",true,true]; // in original Lifeline_SelfHeal now
		// Get Nearest Enemy to Incap unit
		_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;
		_json = [];
		_bloodvolume = [];
		_jsonStr = [];
		_bloodvolume = "";
		_jsonhash = "";

		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

		// ================= BANDAGE ACTION LOOP ================

		if (oldACE == false) then {

				 _jsonStr = _unit call ace_medical_fnc_serializeState; 		
				// private _json = [_jsonStr] call CBA_fnc_parseJSON;					
				 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON;  // 2nd arg will get native hashMaps
				 _woundsHash = _jsonhash get "ace_medical_openwounds";
				 _fractures = _jsonhash get "ace_medical_fractures";
				{

					 _key1 = _x;    // _x represents each key in the hashmap
					 _value1 = _woundsHash get _key1;  // Get the value associated with the key

					if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

					while {count _value1 > 0} do {	

						if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };


						if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
							_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];
						}; // add 5 secs to timeout

						if ((isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) && count _value1 == 1) then {
							// [_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
							[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow",_unit];
							sleep 5;			
						} else {
							// [_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
							[_unit,"AinvPpneMstpSlayWnonDnon_medicIn"] remoteExec ["playMoveNow",_unit];
							sleep 5;	
						};

						sleep 0.5;

						_value1 = _value1 - [_value1 select 0];
						_woundsHash set [_key1, _value1];									
						_jsonhash set ["ace_medical_openwounds", _woundsHash];
						private _newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
					};	

				} forEach (keys _woundsHash);

		}; //NEW ACE


		if (oldACE == true) then {

				 _jsonStr = _unit call ace_medical_fnc_serializeState; 		
				 _json = [_jsonStr] call CBA_fnc_parseJSON;	
				 _wounds = _json getVariable ["ace_medical_openwounds", false];
				// private _fractures = _json get "ace_medical_fractures";
				_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;
				_woundcount = count _wounds;
				_counter = _woundcount;

				while {_counter > 0} do {

					if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

					if (_counter <= 0) exitWith {};
						_bodyparty = _wounds select 0 select 1;
						// sleep 1;		

						if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
							_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];						
						}; // add 5 secs to timeout

						if ((isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) && _counter == 1) then {
							// [_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
							[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow",_unit];
							sleep 5;			
						} else {
							// [_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
							[_unit,"AinvPpneMstpSlayWnonDnon_medicIn"] remoteExec ["playMoveNow",_unit];
							sleep 5;	
						};

						_counter = _counter - 1;
						_wounds = _wounds - [_wounds select 0];
						_json setVariable ["ace_medical_openwounds", _wounds];
						_newJsonStr = [_json] call CBA_fnc_encodeJSON;
						// _json call CBA_fnc_deleteNamespace;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
				}; //while {_counter > 0} do {

		}; //if (oldACE == true) then {


		// ====================ADD BLOOD IF NEEDED
		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

		if (oldACE == false) then {
			 _jsonStr = _unit call ace_medical_fnc_serializeState; 
			 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 
			 _bloodvolume = _jsonhash get "ace_medical_bloodvolume";
		} else {
			 _jsonStr = _unit call ace_medical_fnc_serializeState;
			 _json = [_jsonStr] call CBA_fnc_parseJSON;
			 _bloodvolume = _json getVariable ["ace_medical_bloodvolume", false];
		};

		if (_bloodvolume <= 6) then {
			// [_unit, "RightArm", selectRandom["BloodIV","PlasmaIV"]] call ace_medical_treatment_fnc_ivBagLocal;
			[_unit, _unit, "RightArm", "BloodIV", objNull, "ACE_bloodIV"] call ace_medical_treatment_fnc_ivBag
			// [_unit, "RightArm", "BloodIV"] call ace_medical_treatment_fnc_ivBagLocal;
			// sleep 10;
		};
		// test event handler for blood IV


		// =====================ADD MORPHINE	
		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

		_pain = [];

		if (oldACE == false) then {
			 _pain = _jsonhash get "ace_medical_pain";
		} else {
			 _pain = _json getVariable ["ace_medical_pain", false];
		};

		[_unit, "RightArm", "Morphine"] call ace_medical_treatment_fnc_medicationLocal;

		 _fractures = [];
		 _jsonStr = _unit call ace_medical_fnc_serializeState; 	
		  _json = [_jsonStr] call CBA_fnc_parseJSON;	
		 _jsonhash = [_jsonStr, 2] call CBA_fnc_parseJSON; 

		if (oldACE == false) then {	
			_fractures = _jsonhash get "ace_medical_fractures";
		} else {
			_fractures = _json getVariable ["ace_medical_fractures", false];
		};


		 //========== FRACTURE LOOP
		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

		{
			if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };
			_index = _forEachIndex; // Get the current index

			if (_x == 1) then {
				_fractures set [_index, 0]; // Change 1 to 0					
					if (oldACE == false) then {
						_fractures = _jsonhash get "ace_medical_fractures";
						_fractures set [_index, 0]; // Change 1 to 0					
						_jsonhash set ["ace_medical_fractures", _fractures];
						_newJsonStr  = [_jsonhash] call CBA_fnc_encodeJSON;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
					} else {
						_fractures = _json getVariable ["ace_medical_fractures", false];
						_fractures set [_index, 0];
						_json setVariable ["ace_medical_fractures", _fractures];
						_newJsonStr = [_json] call CBA_fnc_encodeJSON;
						// _json call CBA_fnc_deleteNamespace;
						[_unit, _newJsonStr] call fix_medical_fnc_deserializeState;
					};				
			}; //if (_x == 1) then {

		} forEach _fractures;

		if (lifeState _unit == "INCAPACITATED" || !alive _unit) exitWith { };

		_goup = group _unit;		

		if (_unit != leader _goup && count units group _unit >1 && _unit getVariable ["ReviveInProgress",0] ==0 ) then {
			[_unit] joinSilent (leader _goup);
			[_unit] joinsilent group _unit;
		}; 

		sleep 3;		
	};
	// _unit setVariable ["Lifeline_selfheal_progss",false,true]; // in original Lifeline_SelfHeal now
}; // end function