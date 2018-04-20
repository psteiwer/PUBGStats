Class PUBGStats.Utils [ Abstract ]
{

ClassMethod SynchronizeAll() As %Status
{
	set st=$$$OK
	
	set st=##class(%DeepSee.Utils).%SynchronizeCube("PUBGStats")
	set st=##class(%DeepSee.Utils).%SynchronizeCube("LogPlayerKill")
	
	quit st
}

ClassMethod LoadUs(pIdOnly As %Boolean = 0) As %Status
{
	set st=$$$OK
	try {
		set st=##class(PUBGStats.Player).GetMatchesForPlayer("hungryunicorn,drawkcab2138,lilj322,mannyquin",pIdOnly)
		quit:$$$ISERR(st)
		set st=##class(PUBGStats.Utils).SynchronizeAll()
		quit:$$$ISERR(st)
	} catch ex {
		set st=ex.AsStatus()
	}
	
	quit st
}

ClassMethod LoadStreamers(pIdOnly As %Boolean = 0) As %Status
{
	set st=$$$OK
	try {
		set st=##class(PUBGStats.Player).GetMatchesForPlayer("VissGames,DrDisRespect",pIdOnly)
		quit:$$$ISERR(st)
		set st=##class(PUBGStats.Utils).SynchronizeAll()
		quit:$$$ISERR(st)
	} catch ex {
		set st=ex.AsStatus()
	}
	quit st
}

ClassMethod SetAPIKey(pKey As %String, pLimit As %Integer) As %Status
{
	set st = $$$OK
	
	set ^APIKey("PUBG")=pKey
	set ^APIKey("PUBG","Limit")=pLimit
	
	quit $$$OK
}

ClassMethod GetAPIKey(ByRef pKey As %String, ByRef pLimit As %Integer) As %Status
{
	set st = $$$OK
	
	set pKey=^APIKey("PUBG")
	set pLimit=^APIKey("PUBG","Limit")
	
	quit $$$OK
}

/// Input form of /shards/<region>/<endpoint>
ClassMethod Requestjson(pGet, ByRef json) As %Status
{
	set st=$$$OK
	
	try {
		set request=##class(%Net.HttpRequest).%New()
		set request.Server="api.playbattlegrounds.com"
		set request.Https=1
		set request.Port=443
		set request.SSLConfiguration="test"
		do request.SetHeader("Authorization",^APIKey("PUBG"))
		do request.SetHeader("Accept","application/vnd.api+json")
		do {
			if $i(count)>1 {
				hang 1
			}
			set rs=##class(%SQL.Statement).%ExecDirect(,"SELECT COUNT(*) As Num FROM PUBGStats.RequestLog WHERE TimeRequested > DATEADD(s,-61,CURRENT_TIMESTAMP)")
			d rs.%Next()
			w "Current API Key Usage: "_rs.Num,!
		} while rs.Num >= ^APIKey("PUBG","Limit")
		set requestlog=##class(PUBGStats.RequestLog).%New()
		d requestlog.%Save()
		set st= request.Get(pGet)
		quit:$$$ISERR(st)
		set response=request.HttpResponse.Data.Read(request.HttpResponse.Data.SizeGet())
		if request.HttpResponse.StatusCode'=200 
		{
			THROW $$$ERROR($$$GeneralError,request.HttpResponse.StatusLine)
		}
		set st=##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(response,,.json)	
	} catch ex {
		set ^PUBGStatsErrors($i(^PUBGStatsErrors),"time")=$h
		set ^PUBGStatsErrors(^PUBGStatsErrors,"Status")=request.HttpResponse.StatusLine
		merge ^PUBGStatsErrors(^PUBGStatsErrors,"Headers")=request.HttpResponse.Headers
		if $g(request.HttpResponse.Headers("RETRY-AFTER"),"")'="" {
			hang request.HttpResponse.Headers("RETRY-AFTER")
		} else {
			hang 1
		}
		set st=..Requestjson(pGet,.json)
	}
	
	quit st
}

// SAMPLE URL: https://telemetry-cdn.playbattlegrounds.com/bluehole-pubg/pc-na/2018/04/06/02/14/441a15de-3940-11e8-a65f-0a586466e4a0-telemetry.json
ClassMethod GetTelemetryjson(pURL As %String, Byref json) As %Status
{
	set st=$$$OK
	
	try {
		set request=##class(%Net.HttpRequest).%New()
		set request.Server="telemetry-cdn.playbattlegrounds.com"
		set request.Https=1
		set request.Port=443
		set request.SSLConfiguration="test"
		set st= request.Get(pURL)
		quit:$$$ISERR(st)
		
		set json = ##class(%DynamicAbstractObject).%FromJSON(request.HttpResponse.Data)
	} catch ex {
		set st = $system.Status.GetErrorText(ex)
	}
	
	quit st
}

ClassMethod LoadMatchAndTelemetryData(pMatchId As %String) As %Status
{
	set st=$$$OK
	
	w "Match and Telemetry for "_pMatchId,!
	set st=##class(PUBGStats.Game).LoadMatchData(pMatchId)
	quit:$$$ISERR(st) st
	set st=##class(PUBGStats.Telemetry).LoadTelemetryData(pMatchId)
	quit:$$$ISERR(st) st
	// Once match and telemetry have been processed, mark match as Processed
	set match=##class(PUBGStats.Game).%OpenId(pMatchId)
	set match.Processed=1
	set st=match.%Save()

	quit st
}

ClassMethod ConvertTimeStamp(pTimeStamp As %String) As %TimeStamp
{
	quit $system.SQL.DATEADD("hour",-3,$zdth($translate(pTimeStamp,"TZ"," "),3))
}

ClassMethod ConvertDamage(pInput As %String) As %String
{
	quit $case(pInput,
		  "Damage_BlueZone": "Bluezone Damage",
		  "Damage_Drown": "Drowning Damage",
		  "Damage_Explosion_Grenade": "Grenade Explosion Damage",
		  "Damage_Explosion_RedZone": "Redzone Explosion Damage",
		  "Damage_Explosion_Vehicle": "Vehicle Explosion Damage",
		  "Damage_Groggy": "Bleed out damage",
		  "Damage_Gun": "Gun Damage",
		  "Damage_Instant_Fall": "Fall Damage",
		  "Damage_Melee": "Melee Damage",
		  "Damage_Molotov": "Molotov Damage",
		  "Damage_VehicleCrashHit": "Vehicle Crash Damage",
		  "Damage_VehicleHit": "Vehicle Damage",
		  "BattleRoyaleModeController_Def_C": "Bluezone",
		  "BattleRoyaleModeController_Desert_C": "Bluezone",
		  "Boat_PG117_C": "PG-117",
		  "BP_Motorbike_04_C": "Motorcycle",
		  "BP_Motorbike_04_Desert_C": "Motorcycle",
		  "BP_Motorbike_04_SideCar_C": "Motorcycle (w/ Sidecar)",
		  "BP_Motorbike_04_SideCar_Desert_C": "Motorcycle (w/ Sidecar)",
		  "BP_PickupTruck_A_01_C": "Pickup Truck",
		  "BP_PickupTruck_A_02_C": "Pickup Truck",
		  "BP_PickupTruck_A_03_C": "Pickup Truck",
		  "BP_PickupTruck_A_04_C": "Pickup Truck",
		  "BP_PickupTruck_A_05_C": "Pickup Truck",
		  "BP_PickupTruck_B_01_C": "Pickup Truck",
		  "BP_PickupTruck_B_02_C": "Pickup Truck",
		  "BP_PickupTruck_B_03_C": "Pickup Truck",
		  "BP_PickupTruck_B_04_C": "Pickup Truck",
		  "BP_PickupTruck_B_05_C": "Pickup Truck",
		  "BP_Van_A_01_C": "Van",
		  "BP_Van_A_02_C": "Van",
		  "BP_Van_A_03_C": "Van",
		  "Buff_DecreaseBreathInApnea_C": "Drowning",
		  "Buff_FireDOT_C": "Burning",
		  "Buggy_A_01_C": "Buggy",
		  "Buggy_A_02_C": "Buggy",
		  "Buggy_A_03_C": "Buggy",
		  "Buggy_A_04_C": "Buggy",
		  "Buggy_A_05_C": "Buggy",
		  "Buggy_A_06_C": "Buggy",
		  "Dacia_A_01_v2_C": "Dacia",
		  "Dacia_A_02_v2_C": "Dacia",
		  "Dacia_A_03_v2_C": "Dacia",
		  "Dacia_A_04_v2_C": "Dacia",
		  "PlayerFemale_A_C": "Player",
		  "PlayerMale_A_C": "Player",
		  "ProjGrenade_C": "Grenade",
		  "ProjMolotov_C": "Molotov Cocktail",
		  "ProjMolotov_DamageField_C": "Molotov Cocktail Fire Field",
		  "ProjMolotov_DamageFieldInWall_C": "Molotov Cocktail Fire Field",
		  "RedZoneBomb_C": "Redzone",
		  "Uaz_A_01_C": "UAZ",
		  "Uaz_B_01_C": "UAZ",
		  "Uaz_C_01_C": "UAZ",
		  "WeapAK47_C": "AKM",
		  "WeapAUG_C": "AUG A3",
		  "WeapAWM_C": "AWM",
		  "WeapBerreta686_C": "S686",
		  "WeapCowbar_C": "Crowbar",
		  "WeapCrossbow_1_C": "Crossbow",
		  "WeapDP28_C": "DP-28",
		  "WeapG18_C": "P18C",
		  "WeapGroza_C": "Groza",
		  "WeapHK416_C": "M416",
		  "WeapKar98k_C": "Kar98k",
		  "WeapM16A4_C": "M16A4",
		  "WeapM1911_C": "P1911",
		  "WeapM249_C": "M249",
		  "WeapM24_C": "M24",
		  "WeapM9_C": "P92",
		  "WeapMachete_C": "Machete",
		  "WeapMini14_C": "Mini 14",
		  "WeapMk14_C": "Mk14 EBR",
		  "WeapNagantM1895_C": "R1895",
		  "WeapPan_C": "Pan",
		  "WeapRhino_C": "R45",
		  "WeapSaiga12_C": "S12K",
		  "WeapSawnoff_C": "Sawed-off",
		  "WeapSCAR-L_C": "SCAR-L",
		  "WeapSickle_C": "Sickle",
		  "WeapSKS_C": "SKS",
		  "WeapThompson_C": "Tommy Gun",
		  "WeapUMP_C": "UMP9",
		  "WeapUZI_C": "Micro Uzi",
		  "WeapVector_C": "Vector",
		  "WeapVSS_C": "VSS",
		  "WeapWin94_C": "Win94",
		  "WeapWinchester_C": "S1897",
		  :"Invalid Input")
}

}
