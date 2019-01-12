/// PUBGStats.Cubes.CompareKPI
Class PUBGStats.Cubes.CompareKPI Extends %DeepSee.KPI
{

Parameter DOMAIN;

Parameter RESOURCE;

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="CompareKPI" sourceType="mdx"
 caption=""
>
<property name="Value" columnNo="1" />
<filter name="Measure" />
<filter name="CompareTo" />
</kpi>
}

/// Return an MDX statement to execute.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
	Set tMeasure=""
	// Use Measure filter to get measure
	If $IsObject(..%filterValues) {
		If (..%filterValues.Measure'="") {
			Set tMeasure=..%filterValues.Measure
		}
	}
	
	Set tFilter=""
	// Use CompareTo filter to get measure
	If $IsObject(..%filterValues) {
		If (..%filterValues.CompareTo'="") {
			Set tFilter="%FILTER "_..%filterValues.CompareTo
		}
	}
	
	Set pMDX="SELECT "_tMeasure_" ON 0 FROM [PUBGSTATS] "_tFilter
	set ^pfs($i(^pfs),"pMDX")=pMDX
	Quit $$$OK
}

}
