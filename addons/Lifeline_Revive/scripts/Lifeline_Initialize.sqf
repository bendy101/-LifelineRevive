// Just some variables to set.

	Lifeline_yellowmarker = true;
	Lifeline_remove_3rd_pty_revive = true;
	Lifeline_RevMethod = 2; 
	Lifeline_hintsilent = false;
	Lifeline_debug_soundalert = true;
	Lifeline_HUD_names_pairtime = true;
	Lifeline_DEH_CallMethod = 2;	// 1 = "remoteexec ['addeventhandler', _x] (Default)",
	// 2 = "remoteExec ['call'] curley brackets {}", 
	// 3 = "remoteExec FNC ['Lifeline_custom_DamageH'", 
	// 4 = "remoteExec CALL FNC ['Lifeline_custom_DamageH'"
	// Debug_to = 2; //either "allplayers" or "2" which is server.
	Debug_to = 0; //either "allplayers" or "2" which is server.

	//for on screen text
	Lifelinetxt1Layer = "Lifelinetxt1" call BIS_fnc_rscLayer; 
	Lifelinetxt2Layer = "Lifelinetxt2" call BIS_fnc_rscLayer; 
	LifelineBleedoutLayer = "LifelineBleedouttxt" call BIS_fnc_rscLayer; 
	LifelineDistLayer = "LifelineDistLayertxt" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer1 = "Lifelinetxtdebug1" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer2 = "Lifelinetxtdebug2" call BIS_fnc_rscLayer; 
	LifelinetxtdebugLayer3 = "Lifelinetxtdebug3" call BIS_fnc_rscLayer; 

	// for experimentation
	Lifelinefonts =["EtelkaMonospacePro","EtelkaMonospaceProBold","EtelkaNarrowMediumPro","LCD14","LucidaConsoleB","PuristaBold","PuristaLight","PuristaMedium","PuristaSemibold","RobotoCondensed","RobotoCondensedBold","RobotoCondensedLight","TahomaB"];
	Lifeline_HUD_dist_font = 6;


	publicVariable "Lifeline_Scope";
	publicVariable "Lifeline_RevProtect";
	publicVariable "Lifeline_RevMethod";
	publicVariable "Lifeline_BleedOutTime";
	publicVariable "Lifeline_InstantDeath";
	publicVariable "Lifeline_autoRecover";
	publicVariable "Lifeline_BandageLimit";
	publicVariable "Lifeline_SmokePerc";
	publicVariable "Lifeline_EnemySmokePerc";
	publicVariable "Lifeline_SmokeColour";
	publicVariable "Lifeline_radio";
	publicVariable "Lifeline_MedicComments";
	publicVariable "Lifeline_Voices";
	publicVariable "Lifeline_BloodPool";
	publicVariable "Lifeline_Litter";
	publicVariable "Lifeline_HUD_distance"; 
	publicVariable "Lifeline_HUD_medical"; 
	publicVariable "Lifeline_HUD_names";  
	publicVariable "Lifeline_ACE_Bandage_Method";
	publicVariable "Lifeline_IncapThres";
	publicVariable "Lifeline_Revive_debug";
	publicVariable "Lifeline_version";
	publicVariable "Lifeline_cntdwn_disply";
