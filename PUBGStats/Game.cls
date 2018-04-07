Class PUBGStats.Game Extends %Persistent
{

Parameter DSTIME = "AUTO";

Property MatchID As %String [ Required ];

Index MatchIDIndex On MatchID [ IdKey, Unique ];

Property Processed As %Boolean [ InitialExpression = 0 ];

Property DateCreated As %TimeStamp [ InitialExpression = {$zdt($h,3)} ];

Property Duration As %Integer;

Property GameMode As %String;

Property GameTimeStamp As %TimeStamp;

Property TelemetryURL As %String (MAXLEN = 250);

ClassMethod CreateMatch(pMatchId) As %Status
{
	if '##class(PUBGStats.Game).%ExistsId(pMatchId) {
		// Since this match data does not already exist, add match entry
		set match = ##class(PUBGStats.Game).%New()
		set match.MatchID = pMatchId
		set st= match.%Save()
		if st {
			w "Match data added: ",pMatchId,!
		}
	}
	
	quit st
}

ClassMethod LoadMatchData(pMatchID As %Integer) As %Status
{
	If ##class(PUBGStats.Game).ProcessedGetStored(pMatchID) {
		w "Match already processed",!
		quit $$$OK
	} ElseIf  '##class(PUBGStats.Game).%ExistsId(pMatchID) {
		w "Match does not exist",!
		quit $$$OK
	}
	
	set st=##class(PUBGStats.Utils).Requestjson("/shards/pc-na/matches/"_pMatchID,.json)
	quit:$$$ISERR(st) st
	
	set match = ##class(PUBGStats.Game).%OpenId(pMatchID)
	set match.Duration = json.data.attributes.duration
	set match.GameMode = json.data.attributes.gameMode
	set match.GameTimeStamp =  $system.SQL.DATEADD("hour",-3,$zdth($translate(json.data.attributes.createdAt,"TZ"," "),3))
	
	set st=match.%Save()
	// Add participant data
	for i=1:1:json.included.Size {
		//Find type
		set type = json.included.GetAt(i).type
		if type="participant" {
			set gamestat = ##class(PUBGStats.GameStats).%New()
			set playerId=json.included.GetAt(i).attributes.stats.playerId
			if '##class(PUBGStats.Player).%ExistsId(playerId) {
				set player = ##class(PUBGStats.Player).%New()
				set player.PlayerID = playerId
				set player.Name = json.included.GetAt(i).attributes.stats.name
				d player.%Save()
			}
			d gamestat.PlayerSetObjectId(playerId)
			d gamestat.GameSetObjectId(pMatchID)
			set gamestat.DBNOs = json.included.GetAt(i).attributes.stats.DBNOs
			set gamestat.Assists = json.included.GetAt(i).attributes.stats.assists
			set gamestat.Boosts = json.included.GetAt(i).attributes.stats.boosts
			set gamestat.DamageDealt = json.included.GetAt(i).attributes.stats.damageDealt
			set gamestat.DeathType = json.included.GetAt(i).attributes.stats.deathType
			set gamestat.HeadshotKills = json.included.GetAt(i).attributes.stats.headshotKills
			set gamestat.Heals = json.included.GetAt(i).attributes.stats.heals
			set gamestat.KillPlace = json.included.GetAt(i).attributes.stats.killPlace
			set gamestat.KillPoints = json.included.GetAt(i).attributes.stats.killPoints
			set gamestat.KillPointsDelta = json.included.GetAt(i).attributes.stats.killPointsDelta
			set gamestat.KillStreaks = json.included.GetAt(i).attributes.stats.killStreaks
			set gamestat.Kills = json.included.GetAt(i).attributes.stats.kills
			set gamestat.LastKillPoints = json.included.GetAt(i).attributes.stats.lastKillPoints
			set gamestat.LastWinPoints = json.included.GetAt(i).attributes.stats.lastWinPoints
			set gamestat.LongestKill = json.included.GetAt(i).attributes.stats.longestKill
			set gamestat.MostDamage = json.included.GetAt(i).attributes.stats.mostDamage
			set gamestat.Revives = json.included.GetAt(i).attributes.stats.revives
			set gamestat.RideDistance = json.included.GetAt(i).attributes.stats.rideDistance
			set gamestat.RoadKills = json.included.GetAt(i).attributes.stats.roadKills
			set gamestat.TeamKills = json.included.GetAt(i).attributes.stats.teamKills
			set gamestat.TimeSurvived = json.included.GetAt(i).attributes.stats.timeSurvived
			set gamestat.VehicleDestroys = json.included.GetAt(i).attributes.stats.vehicleDestroys
			set gamestat.WalkDistance = json.included.GetAt(i).attributes.stats.walkDistance
			set gamestat.WeaponsAcquired = json.included.GetAt(i).attributes.stats.weaponsAcquired
			set gamestat.WinPlace = json.included.GetAt(i).attributes.stats.winPlace
			set gamestat.WinPoints = json.included.GetAt(i).attributes.stats.winPoints
			set gamestat.WinPointsDelta = json.included.GetAt(i).attributes.stats.winPointsDelta
			d gamestat.%Save()
		} elseif type="asset" {
			set match.TelemetryURL = json.included.GetAt(i).attributes.URL
			d match.%Save()
		} elseif type="roster" {
			
		}
	}
	
	quit st
}

ClassMethod LoadUnprocessedMatches() As %Status
{
	set st=$$$OK
	
	set SQL = "SELECT ID FROM PUBGStats.Game WHERE Processed = 0"
	set rs = ##class(%SQL.Statement).%ExecDirect(,SQL)
	
	while rs.%Next() {
		w "Loading match data: "_rs.ID,!
		set st=##class(PUBGStats.Game).LoadMatchData(rs.ID)
		if st {
			w "Match processed: "_rs.ID,!
			set match = ##class(PUBGStats.Game).%OpenId(rs.ID)
			set match.Processed = 1
			d match.%Save()
		}
	}
	
	quit st
}

Storage Default
{
<Data name="GameDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Processed</Value>
</Value>
<Value name="3">
<Value>DateCreated</Value>
</Value>
<Value name="4">
<Value>Duration</Value>
</Value>
<Value name="5">
<Value>GameMode</Value>
</Value>
<Value name="6">
<Value>GameTimeStamp</Value>
</Value>
<Value name="7">
<Value>TelemetryURL</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.GameD</DataLocation>
<DefaultData>GameDefaultData</DefaultData>
<IdLocation>^PUBGStats.GameD</IdLocation>
<IndexLocation>^PUBGStats.GameI</IndexLocation>
<StreamLocation>^PUBGStats.GameS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
