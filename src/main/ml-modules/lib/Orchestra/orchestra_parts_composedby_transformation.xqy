xquery version "1.0-ml";
module namespace partcomposedbytranformation = "partcomposedbytranformation";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";


declare function partcomposedbytranformation:getEncryptedString($srcStr as xs:string?) as xs:string? {
  let $md5 := xdmp:md5($srcStr, "hex")
  return fn:replace($md5, "a", "11") ! fn:replace(., "b", "12") ! fn:replace(., "c", "13") ! fn:replace(., "d", "14") ! fn:replace(., "e", "15") ! fn:replace(., "f", "16")
};

declare function partcomposedbytranformation:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};
 
declare function partcomposedbytranformation:checkNull($valStr){
  if(fn:empty($valStr)) then
  ""
  else
  $valStr
};

(:======================================================================================================:)

declare function partcomposedbytranformation:process($uri, $finalMap as map:map) {
  let $ClampPart := fn:doc($uri)/CLAMPPart
  let $PartNumber := $ClampPart/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
  let $partComposeKits := $ClampPart/ComposeKits/Part 
  let $index := 0
  return  
    if(fn:empty($partComposeKits)) then (<partcompositions></partcompositions>)
    else   
     (<partcompositions>{
      for $partComposeKit in $partComposeKits
        let $composedByValidationMap := map:new(())
        let $composedPartNum :=$partComposeKit/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("ComposeKits_Attribute@ComposedPartNumber", $composedPartNum, $composedByValidationMap):)

        let $shortdesc := $partComposeKit/Attribute[@CLAMP_ID="j5_DesignationAS400EN"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("ComposeKits_Attribute@j5_DesignationAS400EN", $shortdesc, $composedByValidationMap):)

        let $Quantity := $partComposeKit/Attribute[@CLAMP_ID="Quantity"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("ComposeKits_Attribute@Quantity", $Quantity, $composedByValidationMap):)

        (:Composite Primary Key: concatenation of Part Number, Composed Part Number :)
      (:let $compositePrimaryKey :=  $PartNumber || "_" || $composedPartNum
      let $compositePrimaryKey := partcomposedbytranformation:getEncryptedString($compositePrimaryKey):)

        let $_ := 
          if(fn:count(map:keys($composedByValidationMap)) gt 0) then              
            let $index := (xdmp:set($index, $index + 1), $index)
            let $valIdentifier := "4." || $index || " Part Composed By - (" || $composedPartNum || ")&#13;-----------------------------------------------------------"
            return map:put($finalMap, $valIdentifier, $composedByValidationMap)
          else ()

        return 	<partcomposition>
                  <partNumber>{$PartNumber}</partNumber>
		              <partComposedBy>{$composedPartNum}</partComposedBy>
		              <shortDesc>{$shortdesc}</shortDesc>
		              <quantity>{$Quantity}</quantity>
		              <unitOfMeasure></unitOfMeasure>
	              </partcomposition>
       }</partcompositions>, $finalMap )
  };