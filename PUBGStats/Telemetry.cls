Class PUBGStats.Telemetry Extends %Persistent
{
Property URL As %String;

Property Game As PUBGStats.Game;

Property Events As List Of PUBGStats.Telemetry.Event;

ClassMethod ProcessTelemetryjson(Byref pJSON) As %Status
{
	set st=$$$OK
	
	set telemetry = ##class(PUBGStats.Telemetry).%New()
	
	set event = pJSON.%GetIterator()
	while event.%GetNext(.key,.val) {
		if val."_T" = "LogMatchDefinition" {
			set matchid = $piece(val.MatchId,".",*)
			set st=##class(PUBGStats.Game).CreateMatch(matchid)
			set match = ##class(PUBGStats.Game).%OpenId(matchid)
			set telemetry.Game = match
			set st=##class(PUBGStats.Telemetry).DeleteTelemetryForMatch(matchid)
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
			set kill.Telemetry=telemetry
			set st=kill.%Save()
			do telemetry.Events.Insert(kill)
		} elseif val."_T" = "LogPlayerTakeDamage" {
			if val.damage'=0 {
				// This means the player was not already down when they took damage
				set downed=(val.damage=val.victim.health)
				w:((val.attacker.name="hungryunicorn")||(val.victim.name="hungryunicorn")||(val.attacker.name="drawkcab2138")||(val.victim.name="drawkcab2138")) key_": "_val.attacker.name_" delt "_val.damage_" damage "_$s(downed:"(downed)",1:"")_" to "_val.victim.name_" with "_val.damageCauserName,!
			}
		} elseif val."_T" = "LogGameStatePeriodic" {
			// This may provide interesting information such as avg distance from circle center
		} elseif val."_T" = "LogPlayerPosition" {
			// May be useful to track movement of a player
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


ClassMethod DeleteTelemetryForMatch(pMatchId As %String) As %Status
{
	set st=$$$OK
	
	
	d ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM PUBGStats_Telemetry.LogPlayerKill WHERE Telemetry->Game->%ID=?",pMatchId)
	d ##class(%SQL.Statement).%ExecDirect(,"DELETE FROM PUBGStats.Telemetry WHERE Game->%ID=?",pMatchId)
	
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
<Type>%Storage.Persistent</Type>
}

}