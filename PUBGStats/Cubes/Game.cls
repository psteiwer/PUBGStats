/// 
Class PUBGStats.Cubes.Game Extends %DeepSee.CubeDefinition [ DependsOn = PUBGStats.Game, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="PUBGGame" displayName="PUBGGame" disabled="false" abstract="false" sourceClass="PUBGStats.Game" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="GameTimeStamp" disabled="false" hasAll="false" allCaption="All GameTimeStamp" allDisplayName="GameTimeStamp" sourceProperty="GameTimeStamp" type="time" calendar="gregorian" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="GameTimeStamp" disabled="false" timeFunction="Year" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Month" disabled="false" timeFunction="MonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
      <level name="Day" disabled="false" timeFunction="DayMonthYear" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="GameMode" disabled="false" hasAll="false" allCaption="All GameMode" allDisplayName="GameMode" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="GameMode" disabled="false" sourceProperty="GameMode" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="Duration" disabled="false" sourceProperty="Duration" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
  <relationship name="GameStats" disabled="false" relatedCube="PUBGStats" inverse="Game" cardinality="many">
  </relationship>
</cube>
}

Parameter DOMAIN;

}
