/// 
Class PUBGStats.Cubes.LogPlayerKill Extends %DeepSee.CubeDefinition [ DependsOn = PUBGStats.Telemetry.LogPlayerKill, ProcedureBlock ]
{

/// Cube definition from Architect.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" name="LogPlayerKill" displayName="LogPlayerKill" disabled="false" abstract="false" sourceClass="PUBGStats.Telemetry.LogPlayerKill" countMeasureName="%COUNT" bucketSize="8" bitmapChunkInMemory="false" precompute="0" disableListingGroups="false">
  <dimension name="KillerName" disabled="false" hasAll="false" allCaption="All Name" allDisplayName="Name" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="KillerName" disabled="false" sourceProperty="Killer.Player.Name" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="VictimName" disabled="false" hasAll="false" allCaption="All Name" allDisplayName="Name" type="data" calendar="gregorian" iKnowType="entity" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="VictimName" disabled="false" sourceProperty="Victim.Player.Name" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="DamageCauserName" disabled="false" hasAll="false" allCaption="All DamageCauserName" allDisplayName="DamageCauserName" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="DamageCauserName" disabled="false" sourceProperty="DamageCauserName" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="DamageTypeCategory" disabled="false" hasAll="false" allCaption="All DamageTypeCategory" allDisplayName="DamageTypeCategory" type="data" hidden="false" showHierarchies="default">
    <hierarchy name="H1" disabled="false" hidden="false">
      <level name="DamageTypeCategory" disabled="false" sourceProperty="DamageTypeCategory" list="false" useDisplayValue="true" useAsFilter="true" hidden="false">
      </level>
    </hierarchy>
  </dimension>
  <measure name="Distance" disabled="false" sourceProperty="Distance" aggregate="SUM" type="number" hidden="false" searchable="false">
  </measure>
</cube>
}

Parameter DOMAIN;

}
