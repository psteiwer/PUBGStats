Class PUBGStats.Telemetry.Player Extends %SerialObject
{
Property Player As PUBGStats.Player;
Property Health As %Double;
Property Location As PUBGStats.Telemetry.Location;

Storage Default
{
<Data name="PlayerState">
<Value name="1">
<Value>Player</Value>
</Value>
<Value name="2">
<Value>Health</Value>
</Value>
<Value name="3">
<Value>Location</Value>
</Value>
</Data>
<State>PlayerState</State>
<StreamLocation>^PUBGStats.Telemetry.PlayerS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}