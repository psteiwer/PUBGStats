Class PUBGStats.Utils [ Abstract ]
{

ClassMethod SynchronizeAll() As %Status
{
	set st=$$$OK
	
	set st=##class(%DeepSee.Utils).%SynchronizeCube("PUBGStats")
	
	quit st
}

ClassMethod LoadUs() As %Status
{
	set st=$$$OK
	
	set st=##class(PUBGStats.Player).GetMatchesForPlayer("hungryunicorn,drawkcab2138")
	//quit:'st st
	set st=##class(PUBGStats.Utils).SynchronizeAll()
	//quit:'st st
	
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
			set rs=##class(%SQL.Statement).%ExecDirect(,"SELECT COUNT(*) As Num FROM PUBGStats.RequestLog WHERE TimeRequested > DATEADD(s,-61,CURRENT_TIMESTAMP)")
			d rs.%Next()
			w rs.Num,!
		} while rs.Num >= ^APIKey("PUBG","Limit")
		set requestlog=##class(PUBGStats.RequestLog).%New()
		d requestlog.%Save()
		set st= request.Get(pGet)
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

}
