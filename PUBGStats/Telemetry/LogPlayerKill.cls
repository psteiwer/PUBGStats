Class PUBGStats.Telemetry.LogPlayerKill Extends (%Persistent,PUBGStats.Telemetry.Event)
{
Property Killer As PUBGStats.Telemetry.Player;
Property Victim As PUBGStats.Telemetry.Player;
Property DamageTypeCategory As %String;
Property DamageCauserName As %String;
Property Distance As %Double;

Storage Default
{
<Data name="LogPlayerKillDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Killer</Value>
</Value>
<Value name="3">
<Value>TimeStamp</Value>
</Value>
<Value name="4">
<Value>Telemetry</Value>
</Value>
<Value name="5">
<Value>Victim</Value>
</Value>
<Value name="6">
<Value>DamageTypeCategory</Value>
</Value>
<Value name="7">
<Value>DamageCauserName</Value>
</Value>
<Value name="8">
<Value>Distance</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.Te1E19.LogPlayerKillD</DataLocation>
<DefaultData>LogPlayerKillDefaultData</DefaultData>
<IdLocation>^PUBGStats.Te1E19.LogPlayerKillD</IdLocation>
<IndexLocation>^PUBGStats.Te1E19.LogPlayerKillI</IndexLocation>
<StreamLocation>^PUBGStats.Te1E19.LogPlayerKillS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}