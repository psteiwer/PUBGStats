Class PUBGStats.Telemetry.PlayerDamage Extends %Persistent
{

Property Attacker As PUBGStats.Telemetry.Player;

Property Victim As PUBGStats.Telemetry.Player;

Property DamageTypeCategory As %String;

Property DamageCauserName As %String;

Property Distance As %Double;

Property Damage As %Double;

Property DamageReason As %String;

Property Downed As %Boolean;


Storage Default
{
<Data name="PlayerDamageDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Attacker</Value>
</Value>
<Value name="3">
<Value>Victim</Value>
</Value>
<Value name="4">
<Value>Damage</Value>
</Value>
<Value name="5">
<Value>DamageTypeCategory</Value>
</Value>
<Value name="6">
<Value>DamageCauserName</Value>
</Value>
<Value name="7">
<Value>Distance</Value>
</Value>
<Value name="8">
<Value>DamageReason</Value>
</Value>
<Value name="9">
<Value>Downed</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.Tel1E19.PlayerDamageD</DataLocation>
<DefaultData>PlayerDamageDefaultData</DefaultData>
<IdLocation>^PUBGStats.Tel1E19.PlayerDamageD</IdLocation>
<IndexLocation>^PUBGStats.Tel1E19.PlayerDamageI</IndexLocation>
<StreamLocation>^PUBGStats.Tel1E19.PlayerDamageS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}