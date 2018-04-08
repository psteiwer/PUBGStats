Class PUBGStats.Utils [ Abstract ]
{

ClassMethod SynchronizeAll() As %Status
{
	set st=$$$OK
	
	set st=##class(%DeepSee.Utils).%SynchronizeCube("PUBGStats")
	set st=##class(%DeepSee.Utils).%SynchronizeCube("LogPlayerKill")
	
	quit st
}

ClassMethod LoadUs(pIdOnly As %Boolean = 0) As %Status
{
	set st=$$$OK
	try {
		set st=##class(PUBGStats.Player).GetMatchesForPlayer("hungryunicorn,drawkcab2138",pIdOnly)
		quit:$$$ISERR(st)
		set st=##class(PUBGStats.Utils).SynchronizeAll()
		quit:$$$ISERR(st)
	} catch ex {
		set st=ex.AsStatus()
	}
	
	quit st
}

ClassMethod LoadStreamers(pIdOnly As %Boolean = 0) As %Status
{
	set st=$$$OK
	try {
		set st=##class(PUBGStats.Player).GetMatchesForPlayer("VissGames,DrDisRespect",pIdOnly)
		quit:$$$ISERR(st)
		set st=##class(PUBGStats.Utils).SynchronizeAll()
		quit:$$$ISERR(st)
	} catch ex {
		set st=ex.AsStatus()
	}
	quit st
}

ClassMethod SetAPIKey(pKey As %String, pLimit As %Integer) As %Status
{
	set st = $$$OK
	
	set ^APIKey("PUBG")=pKey
	set ^APIKey("PUBG","Limit")=pLimit
	
	quit $$$OK
}

/// Input form of /shards/<region>/<endpoint>
ClassMethod Requestjson(pGet, ByRef json) As %ZEN.Auxiliary.jsonProvider
{
	try {
		set request=##class(%Net.HttpRequest).%New()
		set request.Server="api.playbattlegrounds.com"
		set request.Https=1
		set request.Port=443
		set request.SSLConfiguration="test"
		do request.SetHeader("Authorization",^APIKey("PUBG"))
		do request.SetHeader("Accept","application/vnd.api+json")
		do {
			if $i(count)>1 {
				hang 1
			}
			set rs=##class(%SQL.Statement).%ExecDirect(,"SELECT COUNT(*) As Num FROM PUBGStats.RequestLog WHERE TimeRequested > DATEADD(s,-61,CURRENT_TIMESTAMP)")
			d rs.%Next()
			w rs.Num,!
		} while rs.Num >= ^APIKey("PUBG","Limit")
		set requestlog=##class(PUBGStats.RequestLog).%New()
		d requestlog.%Save()
		set st= request.Get(pGet)
		quit:$$$ISERR(st)
		set response=request.HttpResponse.Data.Read(request.HttpResponse.Data.SizeGet())
		if request.HttpResponse.StatusCode'=200 
		{
			THROW $$$ERROR($$$GeneralError,request.HttpResponse.StatusLine)
		}
		set st=##class(%ZEN.Auxiliary.jsonProvider).%ConvertJSONToObject(response,,.json)	
	} catch ex {
		set ^PUBGStatsErrors($i(^PUBGStatsErrors),"time")=$h
		set ^PUBGStatsErrors(^PUBGStatsErrors,"Status")=request.HttpResponse.StatusLine
		merge ^PUBGStatsErrors(^PUBGStatsErrors,"Headers")=request.HttpResponse.Headers
		if $g(request.HttpResponse.Headers("RETRY-AFTER"),"")'="" {
			hang request.HttpResponse.Headers("RETRY-AFTER")
		} else {
			hang 1
		}
		d ..Requestjson(pGet,.json)
	}
	quit st
}

// SAMPLE URL: https://telemetry-cdn.playbattlegrounds.com/bluehole-pubg/pc-na/2018/04/06/02/14/441a15de-3940-11e8-a65f-0a586466e4a0-telemetry.json
ClassMethod GetTelemetryjson(pURL As %String, Byref json) As %Status
{
	set st=$$$OK
	
	try {
		set request=##class(%Net.HttpRequest).%New()
		set request.Server="telemetry-cdn.playbattlegrounds.com"
		set request.Https=1
		set request.Port=443
		set request.SSLConfiguration="test"
		set st= request.Get(pURL)
		quit:$$$ISERR(st)
		
		set json = ##class(%DynamicAbstractObject).%FromJSON(request.HttpResponse.Data)
	} catch ex {
		set st = $system.Status.GetErrorText(ex)
	}
	
	quit st
}

ClassMethod ConvertTimeStamp(pTimeStamp As %String) As %TimeStamp
{
	quit $system.SQL.DATEADD("hour",-3,$zdth($translate(pTimeStamp,"TZ"," "),3))
}

}
