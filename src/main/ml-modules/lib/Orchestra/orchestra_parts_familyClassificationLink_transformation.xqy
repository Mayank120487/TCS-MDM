xquery version "1.0-ml";
module namespace familyclassificationlinktransformation = "familyclassificationlinktransformation";

declare function familyclassificationlinktransformation:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};

(:======================================================================================================:)

declare function familyclassificationlinktransformation:process($uri, $finalMap as map:map) {
  let $ClampPart := fn:doc($uri)/CLAMPPart
  let $familyAttributeList := $ClampPart/PFMAttributes/Attribute[@LANG="en_us"]/@CLAMP_ID/fn:data()
  
  return  
          if(fn:empty($familyAttributeList)) 
          then 
            (<familyClassificationLink></familyClassificationLink>)
          else if(fn:count($familyAttributeList) gt 0)
               then
                    let $PartNumber := $ClampPart/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
                    return 
                      <familyClassificationLink>{$PartNumber}</familyClassificationLink>
               else ()       
  };