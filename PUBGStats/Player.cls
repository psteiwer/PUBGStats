Class PUBGStats.Player Extends %Persistent
{
Parameter DSTIME = "AUTO";
Property Name As %String [ Required ];
Property PlayerID As %String [ Required ];
Index PlayerIDIndex On PlayerID [ IdKey, Unique ];
ClassMethod AddPlayer(pPlayerID As %Integer, ByRef pPlayer As PUBGStats.Player) As %Status
{
	set st=$$$OK
	set id=""
	if ##class(PUBGStats.Player).%ExistsId(pPlayerID) {
		set pPlayer=##class(PUBGStats.Player).%OpenId(pPlayerID)
		quit 1
	}
	w "adding player data for "_pPlayerID,!
	set player=..%New()
	do {
		set st=##class(PUBGStats.Utils).Requestjson("/shards/pc-na/players?filter[playerIds]="_pPlayerID,.json)
	} while $$$ISERR(st)
	do json.%CopyToArray(.array)
	set json=array(pPlayerID)
	set player.PlayerID=pPlayerID
	set player.Name=json.name
	set st=player.%Save()
	set pPlayer=player
	quit st
}

ClassMethod GetMatchesForPlayer(pPlayerNames As %String, pIdOnly As %Boolean = 0) As %Status
{
	set st=$$$OK
	set st=##class(PUBGStats.Utils).Requestjson("/shards/pc-na/players?filter[playerNames]="_pPlayerNames,.json)
	quit:$$$ISERR(st) st
	for i=1:1:json.data.Size {
		for j=1:1:json.data.GetAt(i).relationships.matches.data.Size {
			set matchId = json.data.GetAt(i).relationships.matches.data.GetAt(j).id
			set st = ##class(PUBGStats.Game).CreateMatch(matchId)
			if $$$ISERR(st) {
				w $system.Status.GetErrorText(st),!
				continue
			}
			if 'pIdOnly {
				set st=##class(PUBGStats.Utils).LoadMatchAndTelemetryData(matchId)
				if $$$ISERR(st) {
					w "Match "_matchId_" encountered an error:",!
					w $system.Status.GetErrorText(st),!
				}
			}
		}
	}
	quit st
}


ClassMethod UpdateName(pPlayerId, pPlayerName) As %Status
{
	// Update player name in Player
	set player = ##class(PUBGStats.Player).%OpenId(pPlayerId)
	set player.Name = pPlayerName
	set st = player.%Save()
	quit:$$$ISERR(st) st
	
	// Mark GameStats for this player as changed
	set RS = ##class(%SQL.Statement).%ExecDirect(,"SELECT %ID FROM PUBGStats.GameStats WHERE Player = ?",pPlayerId)
	while RS.%Next() {
		do ##class(%DeepSee.Utils).%SetDSTimeIndex("PUBGStats.GameStats",RS.%Get("ID"),1)
	}
	
	quit st
}

Storage Default
{
<Data name="PlayerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.PlayerD</DataLocation>
<DefaultData>PlayerDefaultData</DefaultData>
<IdLocation>^PUBGStats.PlayerD</IdLocation>
<IndexLocation>^PUBGStats.PlayerI</IndexLocation>
<StreamLocation>^PUBGStats.PlayerS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
