xquery version "1.0-ml";
module namespace queries = "http://alstom.com/Orchestra/Queries";
declare namespace es = "http://marklogic.com/entity-services";
declare variable $FINAL_DB := "smart-data-hub-FINAL";
declare variable $orchestraCollection := "Orchestra";

declare function queries:getHeaders($CLAMPheaders, $systemHeaders)
{
   let $headers := <headers xmlns="http://marklogic.com/entity-services">
                    <source xmlns="">{$systemHeaders/source/text()}</source>
                    <Document_Timestamp xmlns="">{$systemHeaders/Document_Timestamp/text()}</Document_Timestamp>
                    <Harmonized_Date xmlns="">{$systemHeaders/Harmonized_Date/text()}</Harmonized_Date>
                    <PartNumber xmlns="">{$systemHeaders/PartNumber/text()}</PartNumber>
                    <PartPropogationStatus xmlns="">{$CLAMPheaders/PartPropogationStatus/text()}</PartPropogationStatus>
                    <sourceURI xmlns="">{$systemHeaders/sourceURI/text()}</sourceURI>
                  </headers>
     return $headers             
}; 
declare function queries:mergeClampAndPLM($partNumber){

let $CLAMPSearch := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/CLAMP"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))
                                )
                                
                                order by $i//revisionLevel/string() descending, xs:int($i//clampSequence/string()) descending , $i//Document_Timestamp/string() descending
                                return $i
                    return $res[1]
let $CLAMPDoc := $CLAMPSearch//part
let $partmanufacturers := <partmanufacturers></partmanufacturers>
let $partcompositions := <partcompositions></partcompositions>
let $partcustomers := <partcustomers></partcustomers>
let $familyAttributes := <familyAttributes></familyAttributes>
let $familyClassificationLink := <familyClassificationLink></familyClassificationLink>
let $partUnits := $CLAMPSearch//units
let $projectforparts := $CLAMPSearch//PROJECTS

let $CLAMPheaders := $CLAMPSearch//es:headers

(: 06-10-2021 Changed this function to get latest PLM Step1 to perform Step 2 :)
(: 02-11-2021 added one more sorting condition to get latest revision :)
let $PLMDoc_ := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/PLMSIG"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))

            )

            order by $i//revisionLevel/string() descending, $i//*:Harmonized_Date/string() descending
            return $i
return $res[1]
let $PLMDoc := $PLMDoc_/es:envelope/es:instance
let $PLMheaders := queries:getHeaders($CLAMPheaders, $PLMDoc_//es:headers)
let $partNumber := $PLMDoc/partNumber
let $revisionLevel :=  $PLMDoc/revisionLevel
let $clampPartData := $CLAMPDoc/clampPartData

let $clampPartData :=   <clampPartData>
                            <clampControllingUnit>{$PLMDoc/clampControllingUnit/text()}</clampControllingUnit>
                            <clampCommodityCode></clampCommodityCode>
                            <clampDate>{$PLMDoc/clampDate/text()}</clampDate>
                            <clampPartStatus></clampPartStatus>
                            <clampSequence></clampSequence>
                            <clampPplFlag></clampPplFlag>
                            <clampContainsCombustibleMaterial></clampContainsCombustibleMaterial>
                            <clampProtection></clampProtection>
                            <clampMaterial></clampMaterial>
                            <clampVaultOwner></clampVaultOwner>
                            <clampReflowMaxTempTime></clampReflowMaxTempTime>
                            <clampMSLWorstCase></clampMSLWorstCase>
                        </clampPartData>

let $familyNameEnglish := $PLMDoc/familyNameEnglish 
let $shortDescription := $PLMDoc/shortDescription
let $OTHERSHORTDESCRIPTION := <OTHERSHORTDESCRIPTION>{
                               $PLMDoc/shortDescFrench,
                               $PLMDoc/shortDescGerman,
                               $PLMDoc/shortDescItalian,
                               $PLMDoc/shortDescSpanish,
                               $CLAMPDoc/OTHERSHORTDESCRIPTION/shortDescPortuguese,
                               $CLAMPDoc/OTHERSHORTDESCRIPTION/shortDescPolish
                              }</OTHERSHORTDESCRIPTION>
let $longDescription := ""
let $OTHERLONGDESCRIPTION := ""
let $alstomDescription := ""
let $OTHERALSTOMDESCRIPTION := ""
let $quickClampForm := ""
let $usability := $PLMDoc/usability
let $systemMaster := $PLMDoc/systemMaster
let $designAuthority := $PLMDoc/designAuthority
let $partTp := $PLMDoc/partTp
let $unspsc := $PLMDoc/unspsc
let $unitOfMeasure := $PLMDoc/unitOfMeasure
let $mass := $PLMDoc/mass
let $pplFlag :=  ""
let $submitterUnit := ""
let $reachWorstCase := ""
(:let $PARTUSAGE := $CLAMPDoc/PARTUSAGE:)
let $PARTUSAGE :=   <PARTUSAGE>
                        <restrictedPart></restrictedPart>
                        <restrictedPartComment></restrictedPartComment>
                        <serviceLevel>{$PLMDoc/serviceLevel/text()}</serviceLevel>
                        <selleableSparePart></selleableSparePart>
                        <repairable></repairable>
			        </PARTUSAGE>
let $partROHS := ""
let $PARTFEATURE :=
<PARTFEATURE>
<mslWorstCase></mslWorstCase>
<reflowMaxTempTime></reflowMaxTempTime>
<rislWorstCase></rislWorstCase>
<fireSmoke></fireSmoke>
<fireSmokeComment></fireSmokeComment>
<perishablePart></perishablePart>
<perishablePartComment></perishablePartComment>
<shelfLife></shelfLife>
<material></material>
<traceability></traceability>
<hazardousGood></hazardousGood>
<alstomIPOwner></alstomIPOwner>
<standards></standards>
</PARTFEATURE>
let $Duplicate := ""
let $partLifecycleStatus := $PLMDoc/partLifecycleStatus
let $PartLifecycleStatusMonitored := $PLMDoc/PartLifecycleStatusMonitored
let $LIFECYCLE := 
<LIFECYCLE>
<monitored>{$PLMDoc/PartLifecycleStatusMonitored/text()}</monitored>
<CHANGENOTICE>
<omtecPDNStatus></omtecPDNStatus>
<omtecPDNNumber></omtecPDNNumber>
<omtecPDNLink></omtecPDNLink>
</CHANGENOTICE>
</LIFECYCLE>
let $SUBSCRIPTION := ""
let $Repairable := ""
let $PARTREPLACE := 
<PARTREPLACE>
<partReplaceBy></partReplaceBy>
<reasonForReplacement></reasonForReplacement>
<replacementComment></replacementComment>
</PARTREPLACE>
let $QUALITY := 
<QUALITY>
<dataQualityStatus>{$CLAMPDoc/QUALITY/dataQualityStatus/text()}</dataQualityStatus>
<commentOnMigration></commentOnMigration>
<duplicate></duplicate>
<reachRefreshDate></reachRefreshDate>
<fireSmokeRefreshDate></fireSmokeRefreshDate>
</QUALITY>


return
(
<envelope xmlns="http://marklogic.com/entity-services">{
$PLMheaders,
element instance {
element Orchestra { attribute xmlns { "" } ,
      <part xmlns="">{
                $partNumber,
                $revisionLevel,
                $clampPartData,
                $familyNameEnglish,
                $shortDescription,
                $OTHERSHORTDESCRIPTION,
                $longDescription,
                $OTHERLONGDESCRIPTION,
                $alstomDescription,
                $OTHERALSTOMDESCRIPTION,
                $quickClampForm,
                $usability,
                $systemMaster,
                $designAuthority,
                $partTp,
                $unspsc,
                $unitOfMeasure,
                $mass,
                $pplFlag,
                $submitterUnit,
                $reachWorstCase,
                $PARTUSAGE,
                $partROHS,
                $PARTFEATURE,
                $Duplicate,
                $partLifecycleStatus,
                $PartLifecycleStatusMonitored,
                $LIFECYCLE,
                $SUBSCRIPTION,
                $Repairable,
                $PARTREPLACE,
                $QUALITY                
}
</part>,
$partmanufacturers,
$partcompositions,
$partcustomers,
$familyAttributes,
$familyClassificationLink,
$partUnits,
$projectforparts
}
}
}</envelope>
)
};

declare function queries:mergeClampAndDMA($partNumber){

let $CLAMPSearch := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/CLAMP"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))
                                )
                                
                                order by $i//revisionLevel/string() descending, xs:int($i//clampSequence/string()) descending , $i//Document_Timestamp/string() descending
                                return $i
                    return $res[1]
let $CLAMPDoc := $CLAMPSearch//part
let $partmanufacturers := <partmanufacturers></partmanufacturers>
let $partcompositions := <partcompositions></partcompositions>
let $partcustomers := <partcustomers></partcustomers>
let $familyAttributes := <familyAttributes></familyAttributes>
let $familyClassificationLink := <familyClassificationLink></familyClassificationLink>
let $partUnits := $CLAMPSearch//units
let $projectforparts := $CLAMPSearch//PROJECTS

let $CLAMPheaders := $CLAMPSearch//es:headers
(: 02-11-2021 added one more sorting condition to get latest revision :)
let $DMADoc_ := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/ONEDMA"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))

            )

            order by $i//revisionLevel/string() descending, (fn:format-dateTime(xdmp:parse-dateTime("[D01]-[M01]-[Y0001]", $i//*:Harmonized_Date/string()), "[Y0001]-[M01]-[D01]")) descending
            return $i
return $res[1]
let $DMADoc := $DMADoc_/es:envelope/es:instance
let $DMAheaders := queries:getHeaders($CLAMPheaders, $DMADoc_//es:headers)
let $partNumber := $DMADoc/partNumber
let $revisionLevel :=  $DMADoc/revisionLevel
let $clampPartData := $CLAMPDoc/clampPartData

(: Newly added $clampPartData for ONEDMA :)
let $clampPartData :=   <clampPartData>
                            <clampControllingUnit>{$DMADoc/clampControllingUnit/text()}</clampControllingUnit>
                            <clampCommodityCode></clampCommodityCode>
                            <clampDate></clampDate>
                            <clampPartStatus></clampPartStatus>
                            <clampSequence></clampSequence>
                            <clampPplFlag></clampPplFlag>
                            <clampContainsCombustibleMaterial></clampContainsCombustibleMaterial>
                            <clampProtection></clampProtection>
                            <clampMaterial></clampMaterial>
                            <clampVaultOwner></clampVaultOwner>
                            <clampReflowMaxTempTime></clampReflowMaxTempTime>
                            <clampMSLWorstCase></clampMSLWorstCase>
                        </clampPartData>

let $familyNameEnglish := $DMADoc/familyNameEnglish
let $shortDescription := $DMADoc/shortDescription
let $OTHERSHORTDESCRIPTION := <OTHERSHORTDESCRIPTION>{
                               $DMADoc/shortDescFrench,
                               $DMADoc/shortDescGerman,
                               $DMADoc/shortDescItalian,
                               $DMADoc/shortDescSpanish,
                               $CLAMPDoc/OTHERSHORTDESCRIPTION/shortDescPortuguese,
                               $CLAMPDoc/OTHERSHORTDESCRIPTION/shortDescPolish
                              }</OTHERSHORTDESCRIPTION>
let $longDescription := ""
let $OTHERLONGDESCRIPTION := ""
let $alstomDescription := ""
let $OTHERALSTOMDESCRIPTION := ""
let $quickClampForm := ""
let $usability := $DMADoc/usability
let $systemMaster := $DMADoc/systemMaster
let $designAuthority := $DMADoc/designAuthority
let $partTp := $DMADoc/partTp
let $unspsc := $DMADoc/unspsc
let $unitOfMeasure := $DMADoc/unitOfMeasure
let $mass := $DMADoc/mass
let $pplFlag :=  ""
let $submitterUnit := ""
let $reachWorstCase := ""
(:let $PARTUSAGE := $CLAMPDoc/PARTUSAGE:)
let $PARTUSAGE :=   <PARTUSAGE>
                        <restrictedPart></restrictedPart>
                        <restrictedPartComment></restrictedPartComment>
                        <serviceLevel>{$DMADoc/serviceLevel/text()}</serviceLevel>
                        <selleableSparePart></selleableSparePart>
                        <repairable></repairable>
			        </PARTUSAGE>
let $partROHS := ""
let $PARTFEATURE := 
<PARTFEATURE>
<mslWorstCase></mslWorstCase>
<reflowMaxTempTime></reflowMaxTempTime>
<rislWorstCase></rislWorstCase>
<fireSmoke></fireSmoke>
<fireSmokeComment></fireSmokeComment>
<perishablePart></perishablePart>
<perishablePartComment></perishablePartComment>
<shelfLife></shelfLife>
<material></material>
<traceability></traceability>
<hazardousGood></hazardousGood>
<alstomIPOwner></alstomIPOwner>
<standards></standards>
</PARTFEATURE>
let $Duplicate := ""
let $partLifecycleStatus := $DMADoc/partLifecycleStatus
let $PartLifecycleStatusMonitored := $DMADoc/PartLifecycleStatusMonitored
let $LIFECYCLE := 
<LIFECYCLE>
<monitored>{$DMADoc/PartLifecycleStatusMonitored/text()}</monitored>
<CHANGENOTICE>
<omtecPDNStatus></omtecPDNStatus>
<omtecPDNNumber></omtecPDNNumber>
<omtecPDNLink></omtecPDNLink>
</CHANGENOTICE>
</LIFECYCLE>
let $SUBSCRIPTION := ""
let $Repairable := ""
let $PARTREPLACE := 
<PARTREPLACE>
<partReplaceBy></partReplaceBy>
<reasonForReplacement></reasonForReplacement>
<replacementComment></replacementComment>
</PARTREPLACE>
let $QUALITY := 
<QUALITY>
<dataQualityStatus>{$CLAMPDoc/QUALITY/dataQualityStatus/text()}</dataQualityStatus>
<commentOnMigration></commentOnMigration>
<duplicate></duplicate>
<reachRefreshDate></reachRefreshDate>
<fireSmokeRefreshDate></fireSmokeRefreshDate>
</QUALITY>


return
(
<envelope xmlns="http://marklogic.com/entity-services">{
$DMAheaders,
element instance {
element Orchestra { attribute xmlns { "" } ,
<part xmlns="">{
                $partNumber,
                $revisionLevel,
                $clampPartData,
                $familyNameEnglish,
                $shortDescription,
                $OTHERSHORTDESCRIPTION,
                $longDescription,
                $OTHERLONGDESCRIPTION,
                $alstomDescription,
                $OTHERALSTOMDESCRIPTION,
                $quickClampForm,
                $usability,
                $systemMaster,
                $designAuthority,
                $partTp,
                $unspsc,
                $unitOfMeasure,
                $mass,
                $pplFlag,
                $submitterUnit,
                $reachWorstCase,
                $PARTUSAGE,
                $partROHS,
                $PARTFEATURE,
                $Duplicate,
                $partLifecycleStatus,
                $PartLifecycleStatusMonitored,
                $LIFECYCLE,
                $SUBSCRIPTION,
                $Repairable,
                $PARTREPLACE,
                $QUALITY                
}
</part>,
$partmanufacturers,
$partcompositions,
$partcustomers,
$familyAttributes,
$familyClassificationLink,
$partUnits,
$projectforparts
}
}
}</envelope>
)
};

declare function queries:getPropogationStatus($partnumber as xs:string)
  {
  let $status := if(fn:exists(cts:search(fn:collection("ReplicatedFromMigration"),cts:element-value-query(xs:QName("PartNumber"),$partnumber))))
                 then "ReplicatedFromMigration" 
                 else 
                     (let $doc:= xdmp:invoke-function(
                                                       function() { cts:search(fn:collection($orchestraCollection),cts:and-query((
                                                                  cts:element-value-query(xs:QName("PartNumber"),$partnumber,"exact")
                                                             ))
                                                             )[1]
                                                                   },
                                                      <options xmlns="xdmp:eval">
                                                      <database>{xdmp:database($FINAL_DB)}</database>
                                                      </options>)

                          return if (fn:exists($doc))
                                 then (let $currentStatus := $doc/*:envelope/*:headers/PartPropogationStatus/string() 
                                       return if ($currentStatus eq ("ReplicatedfromPublication","NotReplicated","ReplicatedFromMigration") )
                                              then $currentStatus
                                              else "ReplicatedfromClamp"
                                       )
                                 else "NotReplicated"
                                 )


  return $status
  };

declare function queries:transUnitConversion( $Value, $UoM, $AttrId)
{
 let $numeric :=  fn:replace($Value,'[^0-9,.]','')
  let $lastDigVal := fn:replace($Value,'[^a-zA-Z]','')
  
  let $last := fn:replace(fn:substring-after($Value, "e"),'[^a-z]','')
  
  let $femto := xs:decimal("0.000000000000001")
  let $peco := xs:decimal("0.000000000001")
  let $nano := xs:decimal("0.000000001")
  let $micro := xs:decimal("0.000001")
  let $milli := xs:decimal("0.001")
  let $kilo := xs:int("1000")
  let $mega := xs:int("1000000")
  let $giga := xs:int("1000000000")
  let $tera := xs:double("1000000000000")
  let $peta := xs:double("1000000000000000")
  
  let $Orchestra_UoM := cts:search(fn:collection("FamilyAttributeUOM"),
                             cts:and-query((cts:element-value-query(xs:QName("Attribute_ID"),$AttrId))))//UoM/string()
  
  let $Step1 :=  if ($numeric = "")
                then ($Value)                
                else (  
                          if (fn:contains($Value,"en" )) then $Value
                         else if ($lastDigVal eq "f") then (xs:decimal($numeric)*$femto)
                             
                          else if(fn:contains($lastDigVal,"e") and $last = "f") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $femto)
                                         
                          else if ($lastDigVal eq "p") then (xs:decimal($numeric)*$peco)
                        
                          else if(fn:contains($lastDigVal,"e") and $last = "p") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $peco)
                        
                        else if ($lastDigVal eq "n") then (xs:decimal($numeric)*$nano)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "n") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $nano)
                                         
                        else if ($lastDigVal eq "u") then (xs:decimal($numeric)*$micro)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "u") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $micro)
                                         
                        else if ($lastDigVal eq "m") then (xs:decimal($numeric)*$milli)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "m") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $milli)
                                         
                        else if ($lastDigVal eq "k") then (xs:decimal($numeric)*$kilo)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "k") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $kilo)
                                         
                        else if ($lastDigVal eq "M") then (xs:decimal($numeric)*$mega)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "M") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $mega)
                                         
                        else if ($lastDigVal eq "G") then (xs:decimal($numeric)*$giga)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "G") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $giga)
                                         
                        else if ($lastDigVal eq "T") then (xs:decimal($numeric)*$tera)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "T") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $tera)
                                         
                        else if ($lastDigVal eq "P") then (xs:decimal($numeric)*$peta)
                        
                        else if(fn:contains($lastDigVal,"e") and $last = "P") then
                                         let $num := xs:decimal(fn:substring-before($Value, "e"))
                                         let $ex := xs:int(fn:replace(fn:substring-after($Value, "e"),'[a-z]',''))
                                         let $r := xs:double(math:pow(10, $ex))
                                         return ($num * $r * $peta)
                      else $Value
                        )
                        
                         
      let $Step2 :=                        
              if ($UoM = $Orchestra_UoM) then $Step1                
                else if (($UoM = "V") and ($Orchestra_UoM = "kV")) then (xs:double($Step1) * $milli)
                else if (($UoM = "kV") and ($Orchestra_UoM = "V")) then (xs:double($Step1) * $kilo)
                
                else if (($UoM = "s") and ($Orchestra_UoM = "ns")) then (xs:double($Step1) * $giga)
                else if (($UoM = "ns") and ($Orchestra_UoM = "s")) then (xs:double($Step1) * $nano)  
                
                else if (($UoM = "Hz") and ($Orchestra_UoM = "kHz")) then (xs:double($Step1) * $milli)    
                else if (($UoM = "kHz") and ($Orchestra_UoM = "Hz")) then (xs:double($Step1) * $kilo) 
                
                else if (($UoM = "m") and ($Orchestra_UoM = "mm")) then (xs:double($Step1) * $kilo)
                else if (($UoM = "mm") and ($Orchestra_UoM = "m")) then (xs:double($Step1) * $milli)
                
                else if (($UoM = "H") and ($Orchestra_UoM = "mH")) then (xs:double($Step1) * $kilo)
                else if (($UoM = "mH") and ($Orchestra_UoM = "H")) then (xs:double($Step1) * $milli)
                
                else if (($UoM = "H") and ($Orchestra_UoM = "nH")) then (xs:double($Step1) * $giga)
                else if (($UoM = "nH") and ($Orchestra_UoM = "H")) then (xs:double($Step1) * $nano)
                
                else if (($UoM = "bit") and ($Orchestra_UoM = "Kbit")) then (xs:double($Step1) * $milli)
                else if (($UoM = "Kbit") and ($Orchestra_UoM = "Bit")) then (xs:double($Step1) * $kilo)
                
                else if ($UoM = "inch") then (xs:decimal($Step1) * xs:double("25.4"))
                else if (($UoM = "gal") and ($Orchestra_UoM = "l")) then (xs:double($Step1) * xs:decimal("3.785"))
                else if (($UoM = "o") and ($Orchestra_UoM = "Ko")) then (xs:double($Step1) * $milli)
                else if (($UoM = "F") and ($Orchestra_UoM = "nF")) then (xs:double($Step1) * $giga)
                
              else $Step1
                
  return  $Step2
  
};

(: 01-10-2021 Changes for UAT Issue #37 :)
declare function queries:getFamilyName($systemMaster, $unspsc) {

let $systemMaster := if ($systemMaster = "CLAMP") then "Orchestra Branch"
else if ($systemMaster = "DMA") then "DMA Branch"
else if ($systemMaster = "PLM") then "PLM Branch"
else()

let $node := if ($systemMaster = "Orchestra Branch")
then
cts:search(fn:collection("familyid_lookup_collection"),cts:and-query((
cts:or-query((
cts:element-value-query(xs:QName("Branch_Family"), $systemMaster),
cts:element-value-query(xs:QName("Branch_Family"), "Infrastructure Branch")
))
,
cts:element-value-query(xs:QName("UNSPSC_-_UNSPSC"), $unspsc),
cts:element-value-query(xs:QName("Type"),"Leaf Family")
)))[1]
else
cts:search(fn:collection("familyid_lookup_collection"),cts:and-query((
cts:element-value-query(xs:QName("Branch_Family"), $systemMaster),
cts:element-value-query(xs:QName("UNSPSC_-_UNSPSC"), $unspsc),
cts:element-value-query(xs:QName("Type"),"Leaf Family")
)))[1]
return
if(fn:empty($node)) then
()
else if(fn:empty($node//Family_Name_English/string())) then
()
else $node//Family_Name_English/string()

};

(: 27-10-2021 Changes for Real Time Harmonization for PLM Check done by NIKHIL :)
declare function queries:RTH_PLM_UriCheck($input, $Source) {
let $source := $Source
let $plm_check := 
    for $uri in $input/URIS/uris/string()
    let $output := 
              if(fn:exists(
                    cts:search(fn:doc($uri),cts:and-query(((
          cts:element-value-query(xs:QName('Type'),"AT_DesignPart"),
          cts:element-value-query(xs:QName('State'),'Release'),
          cts:not-query(cts:element-value-query(xs:QName('Design_Responsibility'),'CLAMP')))
                          ))
                          )
                        ) )then $uri
                    
             else ()
               return
							$output
let $plm_uris := if($source = "CLAMP") then $input
      else if ($source = "PLMSIG") then
                    <URIS>{ 
                      for $uri in $plm_check
                      return <uris>{$uri}</uris>
                     }</URIS>
      else ()
  return $plm_uris
};

(: 11-11-2021 Changes for Rrplicated for Clamp Part Numbers :)
declare function queries:getPropogationStatusDelta($partnumber as xs:string,$source as xs:string)
  {
  let $status := if(fn:exists(cts:search(fn:collection("ReplicatedFromMigration"),cts:element-value-query(xs:QName("PartNumber"),$partnumber))))
                 then "ReplicatedFromMigration" 
                 else 
                     (let $doc:= xdmp:invoke-function(
                                                       function() { cts:search(fn:collection($orchestraCollection),cts:and-query((
                                                                  cts:element-value-query(xs:QName("PartNumber"),$partnumber,"exact")
                                                             ))
                                                             )[1]
                                                                   },
                                                      <options xmlns="xdmp:eval">
                                                      <database>{xdmp:database($FINAL_DB)}</database>
                                                      </options>)

                          return if (fn:exists($doc))
                                 then (let $currentStatus := $doc/*:envelope/*:headers/PartPropogationStatus/string() 
                                       return if ($source eq "CLAMP") then "ReplicatedfromClamp"                                  
                                              else if ($currentStatus eq ("ReplicatedfromPublication","NotReplicated","ReplicatedFromMigration"))
                                              then $currentStatus
                                              else "NotReplicated"
                                       )
                                 else if ($source eq "CLAMP") then "ReplicatedfromClamp"
                                 else "NotReplicated"
                                 )


  return $status
  };