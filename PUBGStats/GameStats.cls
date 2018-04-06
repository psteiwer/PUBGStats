Class PUBGStats.GameStats Extends %Persistent
{

Parameter DSTIME = "AUTO";

Property Player As PUBGStats.Player;

Property Game As PUBGStats.Game;

Property DBNOs As %Integer;

Property Assists As %Integer;

Property Boosts As %Integer;

Property DamageDealt As %Double;

Property DeathType As %String;

Property HeadshotKills As %Integer;

Property Heals As %Integer;

Property KillPlace As %Integer;

Property KillPoints As %Double;

Property KillPointsDelta As %Double;

Property KillStreaks As %Integer;

Property Kills As %Integer;

Property LastKillPoints As %Integer;

Property LastWinPoints As %Integer;

Property LongestKill As %Double;

Property MostDamage As %Integer;

Property Revives As %Integer;

Property RideDistance As %Double;

Property RoadKills As %Integer;

Property TeamKills As %Integer;

Property TimeSurvived As %Integer;

Property VehicleDestroys As %Integer;

Property WalkDistance As %Double;

Property WeaponsAcquired As %Integer;

Property WinPlace As %Integer;

Property WinPoints As %Integer;

Property WinPointsDelta As %Double;

Storage Default
{
<Data name="GameStatsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Player</Value>
</Value>
<Value name="3">
<Value>DBNOs</Value>
</Value>
<Value name="4">
<Value>Assists</Value>
</Value>
<Value name="5">
<Value>Boosts</Value>
</Value>
<Value name="6">
<Value>DamageDealt</Value>
</Value>
<Value name="7">
<Value>DeathType</Value>
</Value>
<Value name="8">
<Value>HeadshotKills</Value>
</Value>
<Value name="9">
<Value>Heals</Value>
</Value>
<Value name="10">
<Value>KillPlace</Value>
</Value>
<Value name="11">
<Value>KillPoints</Value>
</Value>
<Value name="12">
<Value>KillPointsDelta</Value>
</Value>
<Value name="13">
<Value>KillStreaks</Value>
</Value>
<Value name="14">
<Value>Kills</Value>
</Value>
<Value name="15">
<Value>LastKillPoints</Value>
</Value>
<Value name="16">
<Value>LastWinPoints</Value>
</Value>
<Value name="17">
<Value>LongestKill</Value>
</Value>
<Value name="18">
<Value>MostDamage</Value>
</Value>
<Value name="19">
<Value>Revives</Value>
</Value>
<Value name="20">
<Value>RideDistance</Value>
</Value>
<Value name="21">
<Value>RoadKills</Value>
</Value>
<Value name="22">
<Value>TeamKills</Value>
</Value>
<Value name="23">
<Value>TimeSurvived</Value>
</Value>
<Value name="24">
<Value>VehicleDestroys</Value>
</Value>
<Value name="25">
<Value>WalkDistance</Value>
</Value>
<Value name="26">
<Value>WeaponsAcquired</Value>
</Value>
<Value name="27">
<Value>WinPlace</Value>
</Value>
<Value name="28">
<Value>WinPoints</Value>
</Value>
<Value name="29">
<Value>WinPointsDelta</Value>
</Value>
<Value name="30">
<Value>Game</Value>
</Value>
<Value name="31">
<Value>Rank</Value>
</Value>
<Value name="32">
<Value>TeamNumber</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.GameStatsD</DataLocation>
<DefaultData>GameStatsDefaultData</DefaultData>
<IdLocation>^PUBGStats.GameStatsD</IdLocation>
<IndexLocation>^PUBGStats.GameStatsI</IndexLocation>
<StreamLocation>^PUBGStats.GameStatsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
