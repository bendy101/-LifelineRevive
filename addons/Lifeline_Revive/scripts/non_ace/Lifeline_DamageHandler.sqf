params ["_unit"];
// call with curley bracket version
		[[_unit],
			{ //curely bracket start
				params ["_unit"];
				//================================CODE BELOW
				_diag_text = format ["%1 | [008 Lifeline_DamageHandlerREMOTECALL.sqf] ADD DAMAGE HANDLER", name _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				// _diag_text = format ["%1 | [008 Lifeline_DamageHandlerREMOTECALL.sqf] ADD DAMAGE HANDLER", name _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				// _diag_text = format ["%1 | [008 Lifeline_DamageHandlerREMOTECALL.sqf] ADD DAMAGE HANDLER", name _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
				_unit removeAllEventHandlers "handleDamage";
				[format ["%1 !!!!!!!!! REMOVE ALL DAMAGE HANDLERS !!!!!!!!!!!!!", name _unit]] remoteExec ["diag_log", 2];

				//ADD Lifeline CUSTOM DAMAGE HANDLER
				_actionId = _unit addEventHandler ["handleDamage", {
					params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
					//change damage power curve
					// _powerValue = 1; 
					// _threshold = 0;
					// _damage = [_damage,_powerValue,_threshold] call powerCurve;
					_Lifeline_DHcount = _unit getVariable ["DHcount",0];
					_Lifeline_DHcount = _Lifeline_DHcount + 1;
					_unit setVariable ["DHcount",_Lifeline_DHcount,true];


					if (_hitPoint != "hitlegs" && _hitPoint != "hitarms" && _hitPoint != "hithands" && _damage >= 0.998 && !(_unit getVariable ["Lifeline_allowdeath",false])) then {
										_preventdeath = 0;   
										if (Lifeline_InstantDeath == 1) then {
											_preventdeath = _unit getVariable ["Lifeline_PreventDeath_count",0];
											if (_preventdeath == 4) then {
												_diag_text = format ["%1 | Lifeline_DamageHandlerREMOTECALL.sqf [0053]uuuuuuuuuuuuuuuuuuuuuuuu Lifeline_InstantDeath 1 DEAD THROUGH _preventdeath == 4 uuuuuuuuuuuuuuuuuuuuuuuuuuu", name _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
													if (Lifeline_debug_soundalert) then {		
															[] spawn {
															["beep_hi_1"] remoteExec ["playSound",2];sleep 0.1;
															["beep_hi_1"] remoteExec ["playSound",2];sleep 0.1;
															["beep_hi_1"] remoteExec ["playSound",2];sleep 0.1;
															};
													};
											};
										};

										if (Lifeline_InstantDeath == 0 || Lifeline_InstantDeath == 1 && (_preventdeath < 4 && !(_hitPoint == "hithead" && _damage > 2.66))) then {
											// this resets the preventdeath counter after 3 seconds.
												if (Lifeline_InstantDeath == 1 && _preventdeath == 0) then {
													[_unit] spawn {
														params ["_unit"];
														sleep 3;
														_unit setVariable ["Lifeline_PreventDeath_count", 0, true]
													};
												};
											if (Lifeline_InstantDeath == 1) then {_unit setVariable ["Lifeline_PreventDeath_count", _preventdeath + 1, true]}; 
											_damage = 0.998; //there is a weird bug where a value of 0.999 will round up to 0.1 on the server, which breaks things. So better to use 0.998
										};
										_diag_text = format ["[042] %6 | prevent instant death 1   TOT %3 | DMG: %2 | count: %4 | allowdeath %7 | directhit %8 | timelimit %9 |PART: %1	| captive %10",_hitPoint, _damage toFixed 6, damage _unit toFixed 6,  _Lifeline_DHcount, _directHit, name _unit, (_unit getVariable ["Lifeline_allowdeath",false]), _directHit,(_unit getVariable ["LifelineBleedOutTime",0]), captive _unit ]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};

					};	

					//===================================	
					//just for diag_logs debugging
					// if (damage _unit >= 1 && (_unit getVariable ["Lifeline_Down",false]) && Lifeline_InstantDeath == false) then {
					if (_hitPoint == "" && _damage >= 1 && (_unit getVariable ["Lifeline_Down",false]) && Lifeline_InstantDeath != 3 && Lifeline_Revive_debug) then {
						_diag_text = format ["%1 | %2 xxxxxxxxxxxxxxxxxxxx KILLED WHILE DOWN xxxxxxxxxxxxxxxxxxx", name _unit, lifestate _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
						_diag_text = format ["%1 | %2 xxxxxxxxxxxxxxxxxxxx KILLED WHILE DOWN xxxxxxxxxxxxxxxxxxx", name _unit, lifestate _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
					};


					// use _hitPoint == "incapacitated" to count bullets. Its not exact but close enough.
					_bullethits = (_unit getVariable ["Lifeline_bullethits",0]); 
					if (_hitPoint == "incapacitated" && _directHit == true) then {
						// _damage = 0;
						_bullethits = _bullethits + 1;
						_unit setVariable ["Lifeline_bullethits",_bullethits,true];
					};

					//headshot version
					if (((_damage > Lifeline_IncapThres && _hitPoint == "") ||  damage _unit > Lifeline_IncapThres  ||  ((_hitPoint == "hitface" || _hitPoint == "hitneck" || _hitPoint == "hithead") && _damage >= 0.998)) && isTouchingGround vehicle _unit && !(_unit getVariable ["Lifeline_Down",false])) then {			

						// if (((_damage > Lifeline_IncapThres && _hitPoint == "") ||  damage _unit > Lifeline_IncapThres ||  _hitPoint != "hitlegs" && _hitPoint != "hithands" && _hitPoint != "hitarms" && _damage > Lifeline_IncapThres) && isTouchingGround vehicle _unit && !(_unit getVariable ["Lifeline_Down",false])) then {
						// if (Lifeline_Revive_debug) then {diag_log format ["[144] %6 | THRUGATE 1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu**** TOT %3 | DMG: %2 | count: %4 | 		'", _hitPoint, _damage toFixed 6, damage _unit toFixed 6,  _Lifeline_DHcount, _directHit, name _unit]};
						_diag_text = format ["[144] %6 | THRUGATE 1 uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu**** TOT %3 | DMG: %2 | count: %4 | 		'", _hitPoint, _damage toFixed 6, damage _unit toFixed 6,  _Lifeline_DHcount, _directHit, name _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};


						_unit setCaptive true;	
						// [_unit,true] remoteExec ["setCaptive", _unit];	

						// _BleedOut = (time + round Lifeline_BleedOutTime); //this in Lifeline_Incapped now
						// _unit setVariable ["LifelineBleedOutTime", _BleedOut, true];  // this in Lifeline_Incapped
						_unit setVariable ["countdowntimer",true,true];
						_unit setVariable ["Lifeline_Down",true,true];
						// _unit setUnconscious true; //TEMPOFF		
						[_unit,_damage,false] call Lifeline_Incapped;
						// [_unit,_damage,false] spawn Lifeline_Incapped;

					}; // === END INCAP GATE

					//=========== non-projectile damage like fire and falling
					if (_directHit == false && _hitPoint == "") then {
						_lastotherdamage = _unit getVariable ["lastotherdamage",0];
						_otherdamagediff = _damage - _lastotherdamage;
						_otherdamage = _unit getVariable ["otherdamage",0];
						_otherdamage = _otherdamage + _otherdamagediff;
						_unit setVariable ["otherdamage",_otherdamage,true];
						_unit setVariable ["lastotherdamage",_damage,true];
					};										
					//========================================================

					// prevent more damage if the unconcoius state was triggered (spawn above resets it after 5 secs however)
					if (_unit getVariable ["Lifeline_Down",false]) then {	
						// this prevent death is needed for quick single shots building up 
						if (_hitPoint == "" && _damage >= 0.999) then {
							_damage = 0.998;
							// _unit setVariable ["preventdeath",true,true];
							_diag_text = format ["[042] %6 | prevent instant death 2   TOT %3 | DMG: %2 | count: %4 | allowdeath %7 | directhit %8 | timelimit %9 |PART: %1 | time:%10		",_hitPoint, _damage toFixed 6, damage _unit toFixed 6,  _Lifeline_DHcount, _directHit, name _unit, (_unit getVariable ["Lifeline_allowdeath",false]), _directHit,(_unit getVariable ["LifelineBleedOutTime",0]), time ]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
						};							
					};

					// if (_damage == _last_dmg) exitWith {};
					// _unit setVariable ["last_dmg",_damage,true];	

					_damage 
				}]; //end DamageHandler
				// ADD DH ID
				_unit setVariable ["Lifeline_DH_ID",_actionId,true];
				// if (!isPlayer _x) then {
				// hintsilent format ["%1", name _x];
				// };
				/* _x addMPEventHandler ["MPKilled", {
					params ["_unit", "_killer", "_instigator", "_useEffects"];	
						if (Lifeline_RevProtect == 1) then {
							if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2];[selectRandom["memberdied1","memberdied2","memberdied3","memberdied4","memberdied5"]] remoteExec ["playSound",2];};
						};
						[_unit,"KILLED"] remoteExec ["serverSide_unitstate", 2];
						["KILLED"] remoteExec ["serverSide_Globals", 2]
				}];
					 */				
				//================================FINISH CODE		
			} //end curly bracket
		// ] remoteExec ["call", _unit, true];
		] remoteExec ["call", 0, true];
	if (Lifeline_Revive_debug && !isPlayer _unit) then {[_unit,"Lifeline_DamageHandlerREMOTECALL.sqf"] remoteExec ["serverSide_unitstate", 2]}; // '2' indicates execution on the server
	if (Lifeline_Revive_debug && isPlayer _unit) then {[_unit,"PLAYER Lifeline_DamageHandlerREMOTECALL.sqf"] remoteExec ["serverSide_unitstate", 2]}; // '2' indicates execution on the server