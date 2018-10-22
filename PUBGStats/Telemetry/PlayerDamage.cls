Class PUBGStats.Telemetry.PlayerDamage Extends %Persistent
{

Property Attacker As PUBGStats.Player;

Property Victim As PUBGStats.Player;

Property Game As PUBGStats.Game;

Property DamageTypeCategory As %String;

Property DamageCauserName As %String;

Property Distance As %Double;

Property Damage As %Double;

Property DamageReason As %String;

Property Downed As %Boolean;

Index GameVictimIdx On (Game,Victim);

Index GameVictimCategoryIdx On (Game,Victim,DamageTypeCategory);


ClassMethod GetDamageTaken(pPlayerId, pGameId, pSource = "") As %Double [SQLPROC]
{
	set damage=0
	set sql="SELECT Damage FROM PUBGStats_Telemetry.PlayerDamage WHERE Game->ID = ? and Victim->ID = ?"
	if pSource="Player" {
		set sql=sql_" and DamageTypeCategory != 'Damage_Bluezone'"
	} elseif pSource="Bluezone" {
		set sql=sql_" and DamageTypeCategory = 'Damage_Bluezone'"
	}
	set sqlrs=##class(%SQL.Statement).%ExecDirect(,sql,pGameId,pPlayerId)
	while sqlrs.%Next() {
		set damage=damage+sqlrs.Damage
	}

	quit damage
}


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
<Value name="10">
<Value>Game</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.Tel1E19.PlayerDamageD</DataLocation>
<DefaultData>PlayerDamageDefaultData</DefaultData>
<IdLocation>^PUBGStats.Tel1E19.PlayerDamageD</IdLocation>
<IndexLocation>^PUBGStats.Tel1E19.PlayerDamageI</IndexLocation>
<StreamLocation>^PUBGStats.Tel1E19.PlayerDamageS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}