xquery version "1.0-ml";
module namespace usingunits = "usingunits";

declare function usingunits:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};
declare function usingunits:transCheckValueForHypens($varVal) {
  if(fn:empty($varVal)) then
      ""
  else if($varVal eq "--") then
    ""
  else 
    $varVal 
};
declare function usingunits:getUnits($partResult) {
  let $units := $partResult/Units/Unit
  return $units  
};

(:======================================================================================================:)

declare function usingunits:process($uri) {
  let $result := fn:doc($uri)/CLAMPPart
  let $Units := usingunits:getUnits($result)

 return (<units>
 {
    for $unit in $Units
        let $PartNumber := $result/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
        let $unit_code := $unit/Attribute[@CLAMP_ID = "ProjectName"]/Value/string()
        let $legacy_code_t := $unit/Attribute[@CLAMP_ID = "j5_CodeEtablissement"]/Value/string()
        let $legacy_code := usingunits:transCheckValueForHypens($legacy_code_t)

        return
        <unit>
        <partnumber>{$PartNumber}</partnumber>
        <unitcode>{$unit_code}</unitcode>
        <unitdescription>{}</unitdescription>
        <legacycode>{$legacy_code}</legacycode>
        </unit>
 }</units> )
        
  };








  