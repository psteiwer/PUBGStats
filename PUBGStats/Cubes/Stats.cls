/// 
Class PUBGStats.Cubes.Stats Extends %DeepSee.CubeDefinition [ DependsOn = PUBGStats.GameStats, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="PUBGStats" displayName="PUBGStats" disabled="false" abstract="false" sourceClass="PUBGStats.GameStats" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="Name" disabled="false" hasAll="false" allCaption="All Name" allDisplayName="Name" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Name" disabled="false" sourceProperty="Player.Name" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="Rank" disabled="false" hasAll="false" allCaption="All WinPlace" allDisplayName="WinPlace" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Rank Group" disabled="false" sourceProperty="WinPlace" list="false" rangeExpression="[1,1]:1;[2,10]:2-10;[11,100]:11-100;" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Rank" disabled="false" sourceProperty="WinPlace" list="false" useDisplayValue="true" sort="asc numeric" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="GameMode" disabled="false" hasAll="false" allCaption="All GameMode" allDisplayName="GameMode" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="GameMode" disabled="false" sourceProperty="Game.GameMode" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="GameDate" disabled="false" hasAll="false" allCaption="All GameTimeStamp" allDisplayName="GameTimeStamp" sourceProperty="Game.GameTimeStamp" type="time" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="Year" disabled="false" timeFunction="Year" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Month" disabled="false" timeFunction="MonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Day" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="Kills" disabled="false" sourceProperty="Kills" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="Assists" disabled="false" sourceProperty="Assists" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="DamageDealt" disabled="false" sourceProperty="DamageDealt" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="TimeSurvived" disabled="false" sourceProperty="TimeSurvived" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
  <measure name="Avg Rank" disabled="false" sourceProperty="WinPlace" aggregate="AVG" type="number" hidden="false" searchable="false">
  </measure>
  <listing name="Game Stats Details" disabled="false" listingType="table" fieldList="Player-&gt;Name,WinPlace As &quot;Rank&quot;,Game-&gt;GameTimeStamp,Game-&gt;GameMode,Kills,Assists,DBNOs,DamageDealt,TimeSurvived,DeathType">
  </listing>
</cube>
}

Parameter DOMAIN;

}
