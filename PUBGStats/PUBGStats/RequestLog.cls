Class PUBGStats.RequestLog Extends %Persistent
{

Property TimeRequested As %TimeStamp [ InitialExpression = {$zdt($h,3)} ];

Index TimeRequestedIDX On TimeRequested;

Storage Default
{
<Data name="RequestLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TimeRequested</Value>
</Value>
</Data>
<DataLocation>^PUBGStats.RequestLogD</DataLocation>
<DefaultData>RequestLogDefaultData</DefaultData>
<IdLocation>^PUBGStats.RequestLogD</IdLocation>
<IndexLocation>^PUBGStats.RequestLogI</IndexLocation>
<StreamLocation>^PUBGStats.RequestLogS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
