xquery version "1.0-ml";
declare variable $URI external;

declare variable $FINAL_DB := "smart-data-hub-FINAL";
   declare function local:transProjectName($valStr) as xs:string {
    (: TransRule: ProjectName
        if PLM or DMA if <Attribute CLAMP_ID="ProjectName">
          <Label LANG="en_us">Control Unit</Label>
          <Value>DMA or PLM</Value>
          </Attribute>
        Else 
          CLAMP
    :)
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
 
  declare function local:isDocAttached($valResult) {
       if(fn:count($valResult/Specifications/Specification/Attribute[@CLAMP_ID="DocumentName"]) gt 0
          or fn:count($valResult/Drawings/Drawing/Attribute[@CLAMP_ID="DocumentName"]) gt 0
          (:Invalid Statement PGLS 22-12-2021:)
          (:
          or fn:count($valResult/Customers/Customer/Attribute[@CLAMP_ID="j5_RefArtClient"]) gt 0
          :)
          or fn:count($valResult/CustomerSpecifications/CustomerSpecification/Attribute[@CLAMP_ID="DocumentName"]) gt 0) then
          "yes"
        else if (fn:count($valResult/Customers/Customer/Attribute[@CLAMP_ID="j5_RefArtClient"]) gt 0) then "customerDocAttached"
        else "no"
          
 };
 declare function local:units($ValResult)
 {
   let $subscription_units := $ValResult/Units/Unit/Attribute[@CLAMP_ID = "ProjectName"]/Value/string()
   return
   if("PLM" = $subscription_units or "DMA"= $subscription_units or "EV6"= $subscription_units or
   "NEO"= $subscription_units or "NO1"= $subscription_units or "NO2"= $subscription_units or "NO3"= $subscription_units or
   "NO4"= $subscription_units or "NO5"= $subscription_units ) then "yes" 
   else 
   "no"
 };
 

let $PartNumbers := 
		for $partNumber in $URI
				let $res :=
 for $search in cts:search(fn:collection(("/sources/CLAMP/BatchLoad")),
cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value","=",$partNumber))
let $revision := $search/CLAMPPart/Attribute[@CLAMP_ID="Revision"]/Value/string()
let $Sequence := $search/CLAMPPart/Attribute[@CLAMP_ID="Sequence"]/Value/string()
let $TIMESTAMP := $search/CLAMPPart/Attribute[@CLAMP_ID="TIMESTAMP"]/Value/string()
order by $revision descending,xs:int($Sequence) descending ,$TIMESTAMP descending
return $search
let $docAttached := local:isDocAttached($res[1]/CLAMPPart) 
let $ProjectNameElement := $res[1]/CLAMPPart/Attribute[@CLAMP_ID="ProjectName"]
let $ProjectName := local:transProjectName($ProjectNameElement)
           let $units := local:units($res[1]/CLAMPPart)    
                
return 
if($docAttached = "yes" or $units = "yes") then ()
                else if($docAttached = "customerDocAttached" and $ProjectName = "CLAMP") then $partNumber
                else () 


return 
	(xdmp:invoke-function(
                   function() {
						for $partNumber in $PartNumbers
	let $search_doc := cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partNumber))
		
	return (xdmp:node-replace($search_doc/*:envelope/*:instance/*:Orchestra/part/partTp,
	<partTp>Standard Part (COTS)</partTp>),xdmp:commit())
						},
										<options xmlns="xdmp:eval">
                                        <database>{xdmp:database($FINAL_DB)}</database>
		
                                                     </options>))
