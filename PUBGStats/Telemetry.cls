Class PUBGStats.Telemetry Extends %Persistent
{
Property URL As %String;

Property Game As PUBGStats.Game;

Property Events As Array Of PUBGStats.Telemetry.Event;

ClassMethod ProcessTelemetryjson(Byref pJSON) As %Status
{
	set st=$$$OK
	
	set event = pJSON.%GetIterator()
	while event.%GetNext(.key,.val) {
		if val."_T" = "LogMatchDefinition" {
			// This is match info, nothing useful at this time
		} elseif val."_T" = "LogPlayerPosition" {
			// May be useful, not yet sure
		} elseif val."_T" = "LogPlayerKill" {
			w:((val.killer.name="hungryunicorn")||(val.victim.name="hungryunicorn")||(val.killer.name="drawkcab2138")||(val.victim.name="drawkcab2138")) key_": "_val.killer.name_" killed "_val.victim.name_" with "_val.damageCauserName,!
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
<Type>%Storage.Persistent</Type>
}

}