Class PUBGStats.Telemetry Extends %Persistent
{
Property URL As %String;

Property Game As PUBGStats.Game;

Property Events As List Of PUBGStats.Telemetry.Event;

Index GameIdx On Game [Unique];

ClassMethod ProcessTelemetryjson(Byref pJSON) As %Status
{
	set st=$$$OK
	
	set telemetry = ##class(PUBGStats.Telemetry).%New()
	
	set event = pJSON.%GetIterator()
	while event.%GetNext(.key,.val) {
		if val."_T" = "LogMatchDefinition" {
			set matchid = $piece(val.MatchId,".",*)
			set st=##class(PUBGStats.Game).CreateMatch(matchid)
			quit:$$$ISERR(st)
			set match = ##class(PUBGStats.Game).%OpenId(matchid)
			set telemetry.Game = match
			set st=##class(PUBGStats.Telemetry).DeleteTelemetryForMatch(matchid)
			quit:$$$ISERR(st)
		} elseif val."_T" = "LogPlayerPosition" {
			// May be useful, not yet sure
		} elseif val."_T" = "LogPlayerKill" {
			//w:((val.killer.name="hungryunicorn")||(val.victim.name="hungryunicorn")||(val.killer.name="drawkcab2138")||(val.victim.name="drawkcab2138")) key_": "_val.killer.name_" killed "_val.victim.name_" with "_val.damageCauserName,!
			set kill = ##class(PUBGStats.Telemetry.LogPlayerKill).%New()
			if val.killer'="" {
				set killer = ##class(PUBGStats.Telemetry.Player).%New()
				d killer.PlayerSetObjectId(val.killer.accountId)
				set killer.Health = val.killer.health
				set location = ##class(PUBGStats.Telemetry.Location).%New()
				set location.x=val.killer.location.x
				set location.y=val.killer.location.y
				set location.z=val.killer.location.z
				set killer.Location = location
				set kill.Killer = killer
			}
			if val.victim'="" {
				set victim = ##class(PUBGStats.Telemetry.Player).%New()
				d victim.PlayerSetObjectId(val.victim.accountId)
				set victim.Health = val.victim.health
				set location = ##class(PUBGStats.Telemetry.Location).%New()
				set location.x=val.victim.location.x
				set location.y=val.victim.location.y
				set location.z=val.victim.location.z
				set victim.Location = location
				set kill.Victim = victim
			}
			set kill.DamageCauserName=val.damageCauserName
			set kill.DamageTypeCategory=val.damageTypeCategory
			set kill.TimeStamp = ##class(PUBGStats.Utils).ConvertTimeStamp(val."_D")
			set kill.Distance = val.distance
			set kill.Telemetry=telemetry
			set st=kill.%Save()
			quit:$$$ISERR(st)
			do telemetry.Events.Insert(kill)
		} elseif val."_T" = "LogPlayerTakeDamage" {
			set damage = ##class(PUBGStats.Telemetry.PlayerDamage).%New()
			do damage.AttackerSetObjectId(val.attacker.accountId)
			do damage.VictimSetObjectId(val.victim.accountId)
			do damage.GameSetObjectId(matchid)
			set damage.DamageTypeCategory = val.damageTypeCategory
			set damage.DamageCauserName = val.damageCauserName
			set damage.Distance = val.distance
			set damage.Damage = val.damage
			set damage.DamageReason = val.damageReason
			set damage.Downed = 0
			if val.damage'=0 {
				// This means the player was not already down when they took damage
				set downed=(val.damage=val.victim.health)
				//w:((val.attacker.name="hungryunicorn")||(val.victim.name="hungryunicorn")||(val.attacker.name="drawkcab2138")||(val.victim.name="drawkcab2138")) key_": "_val.attacker.name_" delt "_val.damage_" damage "_$s(downed:"(downed)",1:"")_" to "_val.victim.name_" with "_val.damageCauserName,!
			}
			set st=damage.%Save()
			quit:$$$ISERR(st)
		} elseif val."_T" = "LogGameStatePeriodic" {
			// This may provide interesting information such as avg distance from circle center
		} elseif val."_T" = "LogPlayerPosition" {
			// May be useful to track movement of a player
		} elseif val."_T" = "LogItemPickup" {
			//set temp = $I(items(val.character.name,val.item.itemId),val.item.stackCount)
		} elseif val."_T" = "LogItemDrop" {
			//w:val.character.name="Goterdone" key_": Goterdone dropped "_val.item.stackCount_" "_val.item.itemId,!
			//set temp = $I(items(val.character.name,val.item.itemId),-val.item.stackCount)
		} elseif val."_T" = "LogItemUse" {
			//w key_": "_val.character.name_" used "_val.item.itemId_". "_val.item.stackCount_" remaining",!
		} elseif val."_T" = "LogItemEquip" {
			//w key,!
		} elseif val."_T" = "LogVehicleLeave" {
			if ((val.vehicle.vehicleType="TransportAircraft") || (val.vehicle.vehicleType="Parachute")) {
				set action=##class(PUBGStats.Telemetry.PlayerAction).%New()
				if val.vehicle.vehicleType="Parachute" {
					set action.Action="Land"
				} else {
					set action.Action="Jump"
				}
				do action.GameSetObjectId(matchid)
				do action.Player.PlayerSetObjectId(val.character.accountId)
				set action.Player.Health=val.character.health
				set action.TimeStamp=##class(PUBGStats.Utils).ConvertTimeStamp(val."_D")
				set location=##class(PUBGStats.Telemetry.Location).%New()
				set location.x=val.character.location.x
				set location.y=val.character.location.y
				set location.z=val.character.location.z
				set action.Player.Location=location
				
				set st=action.%Save()
				quit:$$$ISERR(st)
			}
		}
		
		if '$IsObject($G(match)) {
			set st = $$$ERROR(5001,"No Match") 
			quit 
		}
	}
	
	if '$$$ISERR(st) {
		set st=telemetry.%Save()
	}
	
	quit st
}

ClassMethod LoadTelemetryData(pMatchId As %String) As %Status
{
	set st=$$$OK
	
	set sql="SELECT count(*) As C from PUBGStats.Telemetry WHERE Game = ?"
	set rs=##class(%SQL.Statement).%ExecDirect(,sql,pMatchId)
	d rs.%Next()
	if 'rs.C {
		set st=##class(PUBGStats.Utils).StoreTelemetry(pMatchId)
		quit:$$$ISERR(st) st
		set st=##class(PUBGStats.Utils).GetTelemetryjson(##class(PUBGStats.Game).TelemetryURLGetStored(pMatchId),.telemetryjson)
		quit:$$$ISERR(st) st
		set st=##class(PUBGStats.Telemetry).ProcessTelemetryjson(.telemetryjson)
		quit:$$$ISERR(st) st
	} else {
		w "Telemetry already processed",!
	}
	
	quit st
}

ClassMethod DeleteTelemetryForMatch(pMatchId As %String) As %Status
{
	set st=$$$OK
	
	set rs=##class(%SQL.Statement).%ExecDirect(,"DELETE FROM PUBGStats_Telemetry.LogPlayerKill WHERE Telemetry->Game->%ID=?",pMatchId)
	If (rs.%SQLCODE<0) {
		set st=$$$ERROR($$$GeneralError,"SQL Error ("_rs.%SQLCODE_") deleting from PUBGStats_Telemetry.LogPlayerKill. Match ID:"_pMatchId)
		quit st
	}
	set rs=##class(%SQL.Statement).%ExecDirect(,"DELETE FROM PUBGStats_Telemetry.PlayerAction WHERE Game->%ID=?",pMatchId)
	If (rs.%SQLCODE<0) {
		set st=$$$ERROR($$$GeneralError,"SQL Error ("_rs.%SQLCODE_") deleting from PUBGStats_Telemetry.PlayerAction. Match ID:"_pMatchId)
		quit st
	}
	set rs=##class(%SQL.Statement).%ExecDirect(,"DELETE FROM PUBGStats_Telemetry.PlayerDamage WHERE Game->%ID=?",pMatchId)
	If (rs.%SQLCODE<0) {
		set st=$$$ERROR($$$GeneralError,"SQL Error ("_rs.%SQLCODE_") deleting from PUBGStats_Telemetry.PlayerDamage. Match ID:"_pMatchId)
		quit st
	}
	set rs=##class(%SQL.Statement).%ExecDirect(,"DELETE FROM PUBGStats.Telemetry WHERE Game->%ID=?",pMatchId)
	If (rs.%SQLCODE<0) {
		set st=$$$ERROR($$$GeneralError,"SQL Error ("_rs.%SQLCODE_") deleting from PUBGStats.Telemetry. Match ID:"_pMatchId)
		quit st
	}
	  	
	quit st
}


Storage Default
{
<Data name="Events">
<Attribute>Events</Attribute>
<Structure>subnode</Structure>
<Subscript>"Events"</Subscript>
</Data>
<Data name="TelemetryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>URL</Value>
</Value>
<Value name="3">
<Value>Game</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.TelemetryD</DataLocation>
<DefaultData>TelemetryDefaultData</DefaultData>
<IdLocation>^PUBGStats.TelemetryD</IdLocation>
<IndexLocation>^PUBGStats.TelemetryI</IndexLocation>
<StreamLocation>^PUBGStats.TelemetryS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}