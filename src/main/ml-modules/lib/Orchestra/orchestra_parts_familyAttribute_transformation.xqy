xquery version "1.0-ml";
module namespace familyattributevaluetranformation = "familyattributevaluetranformation";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";
import module namespace queries = "http://alstom.com/Orchestra/Queries" at "/Orchestra/Queries.xqy";

declare function familyattributevaluetranformation:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};
 
declare function familyattributevaluetranformation:checkNull($valStr){
  if(fn:empty($valStr)) then
  ""
  else
  $valStr
};

declare function familyattributevaluetranformation:getFamilyName($valResultList) as xs:string? {    
    for $x in $valResultList
    let $retVal :=  $x/Value/text()
    where $x/Label/text()="Family name (local)"
    return $retVal
};

declare function familyattributevaluetranformation:getAttributeId($valResult) as xs:string? {    
    let $retVal :=  $valResult/@CLAMP_ID/fn:data()
    return 
      if(fn:not(fn:empty($retVal))) then
        $retVal      
      else 
        () 
};

declare function familyattributevaluetranformation:getAttributeValue($valResult, $attributeId as xs:string?) as xs:string? {  (:removed "--" to "" condition:)
    let $retVal :=  $valResult/.[@CLAMP_ID = $attributeId]/Value/text()
    return 
      if(fn:not(fn:empty($retVal))) then
        $retVal 
								
											   
      else 
        () 

 
};

declare function familyattributevaluetranformation:isElementTypeFamilyName($valResult) as xs:boolean {
    let $retVal :=  $valResult/Value/text()
    return  
      if($valResult/Label/text() eq "Family name (local)") then
        fn:true()
     else  
       fn:false()
};

declare function familyattributevaluetranformation:getSysUnit($valResult, $attributeId as xs:string?) as xs:string? { 
    let $retVal :=  $valResult/.[@CLAMP_ID = $attributeId]/Unit/text()
    return 
      if(fn:not(fn:empty($retVal))) then
        $retVal
      else
        () 
};

declare function familyattributevaluetranformation:getFamilyId($systemMaster, $unspsc) {
  
let $systemMaster := if ($systemMaster = "CLAMP") then "Orchestra Branch"
                     else if ($systemMaster = "DMA") then "DMA Branch"
                     else if ($systemMaster = "PLM") then "PLM Branch"
                     else()

let $node := cts:search(fn:collection("familyid_lookup_collection"),cts:and-query((
                  cts:element-value-query(xs:QName("Branch_Family"), $systemMaster),
                  cts:element-value-query(xs:QName("UNSPSC_-_UNSPSC"), $unspsc),
                  cts:element-value-query(xs:QName("Type"),"Leaf Family")
                )))[1]
return
    if(fn:empty($node)) then
      ()     
    else if(fn:empty($node//Family_Classification_ID/string())) then
      () 
    else $node//Family_Classification_ID/string() 
               
};

declare function familyattributevaluetranformation:transSystemMaster($valStr) as xs:string {
  if(fn:empty($valStr)) then
    ""
  else if($valStr/Label[@LANG="en_us"]/text() = "Control Unit") then
    let $ProjectName :=  $valStr/Value/text() 
    return 
      if($ProjectName = "DMA" or $ProjectName = "PLM") then
        $ProjectName
      else
        "CLAMP"
  else
      "CLAMP"
};

declare function familyattributevaluetranformation:replaceDoubleDashWithBlank($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
      ""
    else if($valStr = "--") then
      ""
    else
      $valStr
  };


(:======================================================================================================:)

declare function familyattributevaluetranformation:process($uri, $finalMap as map:map) {
  let $ClampPart := fn:doc($uri)/CLAMPPart
  let $PartNumber := $ClampPart/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
  let $resultsList := $ClampPart/PFMAttributes/Attribute[@LANG="en_us"]
  let $UNPSC := $ClampPart/Attribute[@CLAMP_ID="j5_UNSPSC"]/Value/text()
  let $strFamilyName := familyattributevaluetranformation:getFamilyName($resultsList)

  (: Added :)
  let $SystemMaster := $ClampPart/Attribute[@CLAMP_ID="ProjectName"]
  let $SystemMaster := familyattributevaluetranformation:transSystemMaster($SystemMaster)

  let $index := 0
  return  
    if(fn:not(fn:empty($resultsList))) then
      (<familyAttributes>{for $result in $resultsList
        return
          if(familyattributevaluetranformation:isElementTypeFamilyName($result) eq fn:false()) then
            let $familyAttrValValidationMap := map:new(())
            let $AttrId_ := familyattributevaluetranformation:getAttributeId($result)

            let $AttrValue := familyattributevaluetranformation:getAttributeValue($result, $AttrId_)
           
           (: 23-09-2021 Added to remove "--" values :)
           let $AttrValue := familyattributevaluetranformation:replaceDoubleDashWithBlank($AttrValue)

            let $SysUnit := familyattributevaluetranformation:getSysUnit($result, $AttrId_)

            let $familyId := familyattributevaluetranformation:getFamilyId($SystemMaster, $UNPSC)

            let $compositePrimaryKey := $PartNumber || "_" || $AttrId_ ||"_" || $familyId
            let $AttrId := $familyId||" " || $AttrId_

            let $unit := $ClampPart/PFMAttributes/Attribute[@CLAMP_ID = $AttrId_ and @LANG="en_us"]/Unit/string()

            let $ConvertedValue := queries:transUnitConversion($AttrValue,$unit,$AttrId)
            

            let $_ := 
                        if(fn:count(map:keys($familyAttrValValidationMap)) gt 0) then              
                          let $index := (xdmp:set($index, $index + 1), $index)
                          let $valIdentifier := "2." || $index || " Family Attribute Value - (" || $AttrId_ || " - " ||  $strFamilyName || ")&#13;-----------------------------------------------------------"
                          return map:put($finalMap, $valIdentifier, $familyAttrValValidationMap)
                        else ()
            
            return  
              <familyAttribute>
                <attributeValueID>{$compositePrimaryKey}</attributeValueID>
                <partFamilyClassificationLink>{$PartNumber}</partFamilyClassificationLink>
                <attribute>{$AttrId}</attribute>
                <Value>{$ConvertedValue}</Value>
              </familyAttribute>
          else ()
         }</familyAttributes>, $finalMap )
      else(<familyAttributes></familyAttributes>)  
       
  };