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

Property TelemetryURL As %String(MAXLEN = 250);

ClassMethod CreateMatch(pMatchId) As %Status
{
	set st=$$$OK
	
	if pMatchId="" {
		quit $$$ERROR($$$GeneralError,"Please enter a match ID")
	}
	
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
	set match.GameTimeStamp = ##class(PUBGStats.Utils).ConvertTimeStamp(json.data.attributes.createdAt)
	
	set st=match.%Save()
	quit:$$$ISERR(st) st
	// Add participant data
	for i=1:1:json.included.Size {
		//Find type
		set type = json.included.GetAt(i).type
		if type="participant" {
			set gamestat = ##class(PUBGStats.GameStats).%New()
			set playerId=json.included.GetAt(i).attributes.stats.playerId
			set playerName=json.included.GetAt(i).attributes.stats.name
			if '##class(PUBGStats.Player).%ExistsId(playerId) {
				set player = ##class(PUBGStats.Player).%New()
				set player.PlayerID = playerId
				set player.Name = playerName
				set st = player.%Save()
				quit:$$$ISERR(st)
			} else {
				// Check if player name has been changed
				if ##class(PUBGStats.Player).NameGetStored(playerId)'=playerName {
					set st = ##class(PUBGStats.Player).UpdateName(playerId,playerName)
					quit:$$$ISERR(st)
				}
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
		set st=##class(PUBGStats.Utils).LoadMatchAndTelemetryData(rs.ID)
		if $$$ISERR(st) {
			w "Match "_rs.ID_" encountered an error:",!
			w $system.Status.GetErrorText(st),!
		} else {
			w "Match processed: "_rs.ID,!
			set match = ##class(PUBGStats.Game).%OpenId(rs.ID)
			set match.Processed = 1
			set st=match.%Save()
			quit:$$$ISERR(st)
		}
	}
	
	quit st
}

ClassMethod ExportGameIDs() As %Status
{
	set st=$$$OK
	
	set SQL = "SELECT ID FROM PUBGStats.Game"
	set rs = ##class(%SQL.Statement).%ExecDirect(,SQL)
	
	set stream = ##class(%Stream.FileBinary).%New()
	w stream.LinkToFile("GameIds.txt"),!
	
	while rs.%Next() {
		w rs.ID,!
		d stream.WriteLine(rs.ID)
	}
	
	w stream.%Save(),!
	
	quit st
}


ClassMethod ImportGameIDs() As %Status
{
	set st = $$$OK
	
	set stream = ##class(%Stream.FileBinary).%New()
	w stream.LinkToFile("GameIds.txt"),!
	
	while 'stream.AtEnd {
		set matchId = stream.ReadLine()
		w matchId,!
		set st = ##class(PUBGStats.Game).CreateMatch(matchId)
		w st,!
		set st = ##class(PUBGStats.Utils).LoadMatchAndTelemetryData(matchId)
		w st,!
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
<Type>%Library.CacheStorage</Type>
}

}
