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
					for $search in cts:search(fn:doc(),cts:and-query((cts:or-query((
                                         cts:and-query(((cts:collection-query("/sources/CLAMP"),
                                         cts:or-query((cts:collection-query(cts:collection-match("2021-12-06*")),
                                                       cts:collection-query(cts:collection-match("2021-12-07*")),
                                                       cts:collection-query(cts:collection-match("2021-12-08*")),
                                                       cts:collection-query(cts:collection-match("2021-12-09*")),
                                                       cts:collection-query(cts:collection-match("2021-12-10*")),
                                                       cts:collection-query(cts:collection-match("2021-12-11*")),
                                                       cts:collection-query(cts:collection-match("2021-12-12*")),
                                                       cts:collection-query(cts:collection-match("2021-12-13*")),
                                                       cts:collection-query(cts:collection-match("2021-12-14*")),
                                                       cts:collection-query(cts:collection-match("2021-12-15*")),
                                                       cts:collection-query(cts:collection-match("2021-12-16*")),
                                                       cts:collection-query(cts:collection-match("2021-12-17*")),
                                                       cts:collection-query(cts:collection-match("2021-12-18*")),
                                                       cts:collection-query(cts:collection-match("2021-12-19*")),
                                                       cts:collection-query(cts:collection-match("2021-12-20*")),
                                                       cts:collection-query(cts:collection-match("2021-12-21*")),
                                                       cts:collection-query(cts:collection-match("2021-12-22*")),
                                                       cts:collection-query(cts:collection-match("2021-12-23*")),
													   cts:collection-query(cts:collection-match("2021-12-24*")),
													   cts:collection-query(cts:collection-match("2021-12-25*")),
													   cts:collection-query(cts:collection-match("2021-12-26*")),
													   cts:collection-query(cts:collection-match("2021-12-27*")),
													   cts:collection-query(cts:collection-match("2021-12-28*")),
													   cts:collection-query(cts:collection-match("2021-12-29*")),
													   cts:collection-query(cts:collection-match("2021-12-30*")),
													   cts:collection-query(cts:collection-match("2021-12-31*")),
													   cts:collection-query(cts:collection-match("2022-01-*"))
													   
                                                     ))
)))
)),
cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value","=",$partNumber)
))
)
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

