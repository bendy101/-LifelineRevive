diag_log "                                                                                 				               "; 
diag_log "                                                                                  			               "; 
diag_log "                                                                                    			               "; 
diag_log "                                                                                   		   	               "; 
diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "==================================================== MOD ===================================================='";
diag_log "============================================= XEH_postInit.sqf =============================================='";
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";



if !(Lifeline_revive_enable) exitWith {diag_log "1. nnnnnnnnnnnnnnnnnnnnnn MOD DISABLED. EXIT. nnnnnnnnnnnnnnnnnnnnnnn";};


diag_log " ";
diag_log " ";
diag_log " ";

diag_log "===============================START XEH_postInit.sqf===========================";
if (Lifeline_ACEcheck_ == true) then {
diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkkkkkk ACE oldACE var = %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk", oldACE];
};
diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkkkkkk ACE Lifeline_ACEcheck_ var = %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk", Lifeline_ACEcheck_];
player setVariable ["tcb_ais_aisInit",true];
diag_log format ["!!!!!!!!!!!!!!!!!!!! XEH_postInit.sqf IN MY FILE tcb_ais_aisInit = %1 player !!!!!!!!!!!!!!!!!!!!!", player getVariable "tcb_ais_aisInit"];
diag_log " ";
diag_log " ";
diag_log " ";

	_players = allPlayers - entities "HeadlessClient_F";
	Lifeline_Side = side (_players select 0);
	


	{

			_x setVariable ["tcb_ais_aisInit",true];
			diag_log format ["%1 !!!!!!!!!!!!!!!!! my hack removing psycho on each unit !!!!!!!!!!!!!!!!!!!!!!", name _x]

	} foreach (allunits select {(simulationEnabled _x)});

diag_log format ["xxxxxxxxxxxxxx XEH_postInit.sqf testicles %1", testicles];


// check for ACE medical
if (isClass (configFile >> "cfgPatches" >> "ace_medical")) then {
diag_log "+++++++++++ACE MEDICAL (2ND TIME) +++++++++++++++";
_aceversion = [] call ace_common_fnc_getVersion; //unfortunatley gets a string, so need to parse below
_aceversionarr = _aceversion splitString ".";
aceversion = (_aceversionarr select 1) + "." +  (_aceversionarr select 2);
aceversion = parseNumber aceversion;

if (aceversion >= 16) then {
diag_log format ["=====kkkkkkkkkkkkkkkkkkkkkkk NEW ACE version %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk====", _aceversion];
oldACE = false;
fix_medical_fnc_deserializeState = compile preprocessFile "Lifeline_Revive\scripts\ace\fnc_deserializeState3.16.sqf";
} else {
diag_log format ["=====kkkkkkkkkkkkkkkkkkkkkkk OLD ACE version %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkk====", _aceversion];
oldACE = true;
fix_medical_fnc_deserializeState = compile preprocessFile "Lifeline_Revive\scripts\ace\fnc_deserializeState3.15.sqf";
};

} else {
oldACE = nil;

diag_log "=====kkkkkkkkkkkkkkkkkkkkkkkkkkk NO ACE MEDICAL kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk====";
diag_log "=====kkkkkkkkkkkkkkkkkkkkkkkkkkk NO ACE MEDICAL kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk====";
diag_log "=====kkkkkkkkkkkkkkkkkkkkkkkkkkk NO ACE MEDICAL kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk====";
diag_log "=====kkkkkkkkkkkkkkkkkkkkkkkkkkk NO ACE MEDICAL kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk====";
};



diag_log format ["kkkkkkkkkkkkkkkkkkkkkkkkkkkk ACE DECLARED AGAIN var = %1 kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk", oldACE];



[] execvm "Lifeline_Revive\init.sqf";
[] execvm "Lifeline_Revive\initserver.sqf";

