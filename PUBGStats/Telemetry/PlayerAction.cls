Class PUBGStats.Telemetry.PlayerAction Extends %Persistent
{

Property Player As PUBGStats.Telemetry.Player;
Property Game As PUBGStats.Game;
Property TimeStamp As %TimeStamp;
Property Action As %String;


Storage Default
{
<Data name="PlayerActionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Player</Value>
</Value>
<Value name="3">
<Value>Game</Value>
</Value>
<Value name="4">
<Value>TimeStamp</Value>
</Value>
<Value name="5">
<Value>Action</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.Tel1E19.PlayerActionD</DataLocation>
<DefaultData>PlayerActionDefaultData</DefaultData>
<IdLocation>^PUBGStats.Tel1E19.PlayerActionD</IdLocation>
<IndexLocation>^PUBGStats.Tel1E19.PlayerActionI</IndexLocation>
<StreamLocation>^PUBGStats.Tel1E19.PlayerActionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}