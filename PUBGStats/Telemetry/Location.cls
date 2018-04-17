Class PUBGStats.Telemetry.Location Extends %SerialObject
{
Property x As %Double;
Property y As %Double;
Property z As %Double;


Storage Default
{
<Data name="LocationState">
<Value name="1">
<Value>x</Value>
</Value>
<Value name="2">
<Value>y</Value>
</Value>
<Value name="3">
<Value>z</Value>
</Value>
</Data>
<State>LocationState</State>
<StreamLocation>^PUBGStats.Telemetry.LocationS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}