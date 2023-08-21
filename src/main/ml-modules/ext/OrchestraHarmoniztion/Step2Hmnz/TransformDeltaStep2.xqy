xquery version "1.0-ml";

declare namespace harmonizationstep2 = "http://alstom.com/harmonizationstep2";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";
import module namespace queries = "http://alstom.com/Orchestra/Queries" at "/Orchestra/Queries.xqy";
import module namespace ValidationStep2 = "ValidationStep2" at "/Orchestra/orchestra_Validation_step2.xqy";
declare namespace es = "http://marklogic.com/entity-services";
declare variable $URI external;

declare function harmonizationstep2:GenerateFinalXML($headers,$instance){

let $source := $headers/source/string()
let $timestamp := if (fn:empty($headers/Document_Timestamp/string())) then () else $headers/Document_Timestamp/string()
let $Harmonized_Date := $headers/Harmonized_Date/string()
let $PartNumber := $headers/PartNumber/string()
(: let $PartPropogationStatus  := queries:getPropogationStatus($PartNumber):)
(: changes made on 08/12/2021 :)
let $PartPropogationStatus  := $headers/PartPropogationStatus/string()
let $partTp  := $instance/partTp
let $PartNumberInst := $instance/partNumber
let $revisionLevel := $instance/revisionLevel
let $shortDescription := $instance/shortDescription
let $shortDescFrench := $instance/shortDescFrench
let $shortDescGerman := $instance/shortDescGerman
let $shortDescItalian := $instance/shortDescItalian
let $shortDescSpanish := $instance/shortDescSpanish
let $unspsc := $instance/unspsc
let $familyNameEnglish := $instance/familyNameEnglish
let $mass := $instance/mass
let $designAuthority := $instance/designAuthority
let $clampControllingUnit := if (fn:empty($instance/clampControllingUnit)) then () else $instance/clampControllingUnit
let $systemMaster := $instance/systemMaster
let $unitOfMeasure := $instance/unitOfMeasure
let $clampPartData :=   <clampPartData>
                            <clampControllingUnit>{$clampControllingUnit}</clampControllingUnit>
                            <clampCommodityCode>{}</clampCommodityCode>
                            <clampDate>{if (fn:empty($instance/clampDate/text())) then () else ($instance/clampDate/string())}</clampDate>
                            <clampPartStatus>{}</clampPartStatus>
                            <clampSequence>{}</clampSequence>
                            <clampPplFlag>{}</clampPplFlag>
                            <clampContainsCombustibleMaterial>{}</clampContainsCombustibleMaterial>
                            <clampProtection>{}</clampProtection>
                            <clampMaterial>{}</clampMaterial>
                            <clampVaultOwner>{}</clampVaultOwner>
                            <clampReflowMaxTempTime>{}</clampReflowMaxTempTime>
                            <clampMSLWorstCase>{}</clampMSLWorstCase>
                        </clampPartData>
let $partLifecycleStatus := $instance/partLifecycleStatus
let $PartLifecycleStatusMonitored := $instance/PartLifecycleStatusMonitored
let $usability := $instance/usability
let $serviceLevel := $instance/serviceLevel
let $PartUsage := <PARTUSAGE>
                              <restrictedPart>
                              </restrictedPart>
                              <restrictedPartComment>
                              </restrictedPartComment>
                              {$serviceLevel}
                              <selleableSparePart>
                              </selleableSparePart>
                              <repairable>
                              </repairable>
                    </PARTUSAGE>

return 
<envelope xmlns="http://marklogic.com/entity-services">
<headers>
  <source xmlns="">{$source}</source>
  <Document_Timestamp xmlns="">{$timestamp}</Document_Timestamp>
  <Harmonized_Date xmlns="">{$Harmonized_Date}</Harmonized_Date>
  <PartNumber xmlns="">{$PartNumber}</PartNumber>
  <PartPropogationStatus xmlns="">{$PartPropogationStatus}</PartPropogationStatus>
</headers>
<triples></triples>
{element instance {
element Orchestra { attribute xmlns { "" } ,
<part xmlns="">{$partTp,$PartNumberInst,$revisionLevel,$clampPartData,$shortDescription,$shortDescFrench,$shortDescGerman,$shortDescItalian,$shortDescSpanish,$unspsc,$familyNameEnglish,$mass,$designAuthority,$systemMaster,$unitOfMeasure,$partLifecycleStatus,$PartLifecycleStatusMonitored,$usability,$PartUsage
}</part>,
<partmanufacturers xmlns=""></partmanufacturers>,
<partcompositions xmlns=""></partcompositions>,
<partcustomers xmlns=""></partcustomers>,
<familyAttributes xmlns=""></familyAttributes>,
<familyClassificationLink xmlns=""></familyClassificationLink>,
<units xmlns=""></units>,
<PROJECTS xmlns=""></PROJECTS>
}
}
}
</envelope>
};

declare function harmonizationstep2:searchPartInAllSystem($partNumber){
let $searchPartinClamp := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/CLAMP"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))
              
            )
            order by $i//revisionLevel/string() descending, xs:int($i//clampSequence/string()) descending , $i//Document_Timestamp/string() descending
            return $i
return $res[1]
let $systemMaster := if (fn:exists($searchPartinClamp//systemMaster/string())) then $searchPartinClamp//systemMaster/string() else  ""

(: 06-10-2021 Nikhil Changed this function to get latest PLM Step1 to perform Step 2 :)
(: 02-11-2021 added one more sorting condition to get latest revision :)
let $searchPartinPLM := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/PLMSIG"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))

            )

            order by $i//revisionLevel/string() descending, $i//*:Harmonized_Date/string() descending
            return $i
return $res[1]
let $PLMheaders := $searchPartinPLM//es:headers
let $PLMtriples := $searchPartinPLM//es:triples
let $PLMinstance := $searchPartinPLM//es:instance
let $PLMGeneratedXML :=  harmonizationstep2:GenerateFinalXML($PLMheaders,$PLMinstance)
 (: 02-11-2021 added one more sorting condition to get latest revision :)
let $searchPartinDMA := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/ONEDMA"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  ))

            )

            order by $i//revisionLevel/string() descending, (fn:format-dateTime(xdmp:parse-dateTime("[D01]-[M01]-[Y0001]", $i//*:Harmonized_Date/string()), "[Y0001]-[M01]-[D01]")) descending
            return $i
return $res[1]
let $DMAheaders := $searchPartinDMA//es:headers
let $DMAtriples := $searchPartinDMA//es:triples
let $DMAinstance := $searchPartinDMA//es:instance
let $DMAGeneratedXML :=  harmonizationstep2:GenerateFinalXML($DMAheaders,$DMAinstance)

let $doc :=  if ($systemMaster = "PLM") 
              then queries:mergeClampAndPLM($partNumber)
              else( 
                   if ($systemMaster = "DMA")
                   then queries:mergeClampAndDMA($partNumber)
                   else (
                          if ($systemMaster = "CLAMP")
                          then ($searchPartinClamp/es:envelope)
                          else(
                                if ($systemMaster != ("CLAMP","PLM","DMA"))
                                then ( if (fn:exists($searchPartinPLM))
                                       then document {$PLMGeneratedXML}
                                       else( if (fn:exists($searchPartinDMA))
                                              then document {$DMAGeneratedXML}
                                              else ("This part will not be propagated to Orchestra")
                                           )
                                      )
                                else($partNumber||" No Such Part")
                              )
                        )
                   )
  return ($doc)

};

declare function harmonizationstep2:step2Validation($document as node(),$finalMap as map:map){

let $doc := $document/*:instance/*:Orchestra
let $header := <headers>{
                  element source {$document/*:headers/*:source/string()},
                  element Document_Timestamp {$document/*:headers/*:Document_Timestamp/string()},
                  element Harmonized_Date {$document/*:headers/*:Harmonized_Date/string()},
                  element PartNumber {$document/*:headers/*:PartNumber/string()},
                  element PartPropogationStatus {$document/*:headers/*:PartPropogationStatus/string()},
                  element PartAcquisitionStatus {"NO"}
               }</headers>
               (: 01-10-2021 Changes for New step 2 merging and validation :)
let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
let $partsValidationMap := map:new(())

let $partNumber := $doc/part/partNumber/string()
let $valIdentifierPart := "0.0 Parts - (" || $partNumber || ")&#13;-----------------------------------------"
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@PartNumber", $partNumber, $partsValidationMap)

let $revisionLevel := $doc/part/revisionLevel/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@Revision", $revisionLevel, $partsValidationMap)

let $clampControllingUnit := if (fn:exists($doc/part/clampPartData/clampControllingUnit/string())) then ($doc/part/clampPartData/clampControllingUnit/string()) else ($doc/part/clampControllingUnit/string())

let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampControllingUnit", $clampControllingUnit, $partsValidationMap)

let $clampCommodityCode := $doc/part/clampPartData/clampCommodityCode/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampCommodityCodes", $clampCommodityCode, $partsValidationMap)

let $clampDate := $doc/part/clampPartData/clampDate/string()     
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampDate", $clampDate, $partsValidationMap)

let $clampPartStatus := $doc/part/clampPartData/clampPartStatus/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_PartStatus", $clampPartStatus, $partsValidationMap)

let $clampSequence := $doc/part/clampPartData/clampSequence/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@Sequence", $clampSequence, $partsValidationMap)

let $clampPplFlag := $doc/part/clampPartData/clampPplFlag/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@CLAMPPPLFlag", $clampPplFlag, $partsValidationMap)

let $clampContainsCombustibleMaterial := $doc/part/clampPartData/clampContainsCombustibleMaterial/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampContainsCombustibleMat", $clampContainsCombustibleMaterial, $partsValidationMap)

let $clampProtection := $doc/part/clampPartData/clampProtection/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampProtection", $clampProtection, $partsValidationMap)        

let $clampMaterial := $doc/part/clampPartData/clampMaterial/string()
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampMaterial", $clampMaterial, $partsValidationMap)

let $clampVaultOwner := $doc/part/clampPartData/clampVaultOwner/string() 
let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampVaultOwner", $clampVaultOwner, $partsValidationMap)        

        let $clampReflowMaxTempTime := $doc/part/clampPartData/clampReflowMaxTempTime/string() 
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampReflowMaxTempTime", $clampReflowMaxTempTime, $partsValidationMap)        

        let $clampMSLWorstCase := $doc/part/clampPartData/clampMSLWorstCase/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampMSLWorstCase", $clampMSLWorstCase, $partsValidationMap)

        let $familyNameEnglish := $doc/part/familyNameEnglish/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@familyname", $familyNameEnglish,$partsValidationMap)

        let $shortDescriptionEN := fn:substring($doc/part/shortDescription/string(),1,40)
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ShortDescriptionEN", $shortDescriptionEN, $partsValidationMap)

        let $shortDescriptionFR := if (fn:exists($doc/part/OTHERSHORTDESCRIPTION/shortDescFrench/string())) then (fn:substring($doc/part/OTHERSHORTDESCRIPTION/shortDescFrench/string(),1,40)) else (fn:substring($doc/part/shortDescFrench/string(),1,40))
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ShortDescriptionFR", $shortDescriptionFR, $partsValidationMap)

        let $shortDescriptionGE := if (fn:exists($doc/part/OTHERSHORTDESCRIPTION/shortDescGerman/string())) then (fn:substring($doc/part/OTHERSHORTDESCRIPTION/shortDescGerman/string(),1,40)) else (fn:substring($doc/part/shortDescGerman/string(),1,40))
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ShortDescriptionAL", $shortDescriptionGE, $partsValidationMap)

        let $shortDescriptionIT := if (fn:exists($doc/part/OTHERSHORTDESCRIPTION/shortDescItalian/string())) then (fn:substring($doc/part/OTHERSHORTDESCRIPTION/shortDescItalian/string(),1,40)) else (fn:substring($doc/part/shortDescItalian/string(),1,40))
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ShortDescriptionAU", $shortDescriptionIT, $partsValidationMap)
         
        let $shortDescriptionSP := if (fn:exists($doc/part/OTHERSHORTDESCRIPTION/shortDescSpanish/string())) then (fn:substring($doc/part/OTHERSHORTDESCRIPTION/shortDescSpanish/string(),1,40)) else (fn:substring($doc/part/shortDescSpanish/string(),1,40))
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ShortDescriptionES", $shortDescriptionSP, $partsValidationMap)

        let $longDescriptionEN := $doc/part/longDescription/string()
        
        let $longDescriptionFR := $doc/part/OTHERLONGDESCRIPTION/longDescFrench/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"AttrLocSel_Attribute@LongDescriptionFR", $longDescriptionFR, $partsValidationMap)
              
        let $longDescriptionAL := $doc/part/OTHERLONGDESCRIPTION/longDescGerman/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"AttrLocSel_Attribute@LongDescriptionAL", $longDescriptionAL, $partsValidationMap)

        let $longDescriptionAU := $doc/part/OTHERLONGDESCRIPTION/longDescItalian/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"AttrLocSel_Attribute@LongDescriptionAU", $longDescriptionAU, $partsValidationMap)

        let $longDescriptionES := $doc/part/OTHERLONGDESCRIPTION/longDescSpanish/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"AttrLocSel_Attribute@LongDescriptionES", $longDescriptionES, $partsValidationMap)
        
        let $alstomDescriptionEN := $doc/part/alstomDescription/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@AlstomDescriptionEN", $alstomDescriptionEN, $partsValidationMap)

        let $alstomDescriptionFR := $doc/part/OTHERALSTOMDESCRIPTION/alstomDescFrench/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@AlstomDescriptionFR", $alstomDescriptionFR, $partsValidationMap)

        let $alstomDescriptionAL := $doc/part/OTHERALSTOMDESCRIPTION/alstomDescGerman/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@AlstomDescriptionAL", $alstomDescriptionAL, $partsValidationMap)

        let $alstomDescriptionAU := $doc/part/OTHERALSTOMDESCRIPTION/alstomDescItalian/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@AlstomDescriptionAU", $alstomDescriptionAU, $partsValidationMap)

        let $alstomDescriptionES := $doc/part/OTHERALSTOMDESCRIPTION/alstomDescSpanish/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@AlstomDescriptionES", $alstomDescriptionES, $partsValidationMap)
        
        let $PartFormURL := $doc/part/quickClampForm/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@PartFormURL", $PartFormURL, $partsValidationMap)
            
        let $MakeBuyIndicator := $doc/part/usability/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@MakeBuyIndicator", $MakeBuyIndicator,$partsValidationMap)
        
        let $designAuthority :=  $doc/part/designAuthority/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@DesignAuthority", $designAuthority, $partsValidationMap)
        
        let $PartType := $doc/part/partTp/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@Class", $PartType,$partsValidationMap)   
      
        let $UNPSC := $doc/part/unspsc/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@UNPSC", $UNPSC,$partsValidationMap)  
       
        let $UnitOfMeasure := $doc/part/unitOfMeasure/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_UniteGestion", $UnitOfMeasure, $partsValidationMap)      
        
        let $Mass := $doc/part/mass/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_Masse", $Mass, $partsValidationMap)

        (: 23/07/21- Changes after UAT but not removed in Step 2 
        let $CLAMPPPLFlag := $doc/part/pplFlag/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@CLAMPPPLFlag", $CLAMPPPLFlag, $partsValidationMap)
        :)
        let $submitterUnit := $doc/part/submitterUnit/string()  
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@SubmitterUnit", $submitterUnit, $partsValidationMap)

        let $ReachWorstCase := $doc/part/reachWorstCase/string() 
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_SynthWorstCase", $ReachWorstCase, $partsValidationMap)

        let $RestrictedPart := $doc/part/PARTUSAGE/restrictedPart/string() 
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_Interdit", $RestrictedPart, $partsValidationMap)

        let $Repairable := $doc/part/PARTUSAGE/repairable/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_Repairable", $Repairable, $partsValidationMap)
       
        let $partROHS := $doc/part/partROHS/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@PartROHS", $partROHS, $partsValidationMap)        

        let $MSLWorstCase := $doc/part/PARTFEATURE/mslWorstCase/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@MSLWorstCase", $MSLWorstCase, $partsValidationMap)

        let $ReflowMaxTempTime := $doc/part/PARTFEATURE/reflowMaxTempTime/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ReflowMaxTempTime", $ReflowMaxTempTime, $partsValidationMap)

        let $Perishable := $doc/part/PARTFEATURE/perishablePart/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@Perishable", $Perishable, $partsValidationMap)        

        let $material := $doc/part/PARTFEATURE/material/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@Material", $material, $partsValidationMap)       

        let $hazardousGoods := $doc/part/PARTFEATURE/hazardousGood/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@HazardousGoods", $hazardousGoods, $partsValidationMap)


        let $Standards := $doc/part/PARTFEATURE/standards/standard/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationCommentsForListOfValues($source,"Attribute@Standards", $Standards, $partsValidationMap)

        let $Duplicate := $doc/part/QUALITY/duplicate/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_PartStatus_duplicate", $Duplicate, $partsValidationMap)
       
        let $PartLifecycleStatus := $doc/part/partLifecycleStatus/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@PartLifecycleStatus", $PartLifecycleStatus, $partsValidationMap)
              
        let $PartLifecycleStatusMonitored := $doc/part/PartLifecycleStatusMonitored/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier@PartLifecycleStatusMonitored", $PartLifecycleStatusMonitored, $partsValidationMap)


        let $OMTECPDNStatus := $doc/part/LIFECYCLE/CHANGENOTICE/omtecPDNStatus/string()  
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_PDN", $OMTECPDNStatus, $partsValidationMap)

        let $OMTECPDNNumber := $doc/part/LIFECYCLE/CHANGENOTICE/omtecPDNNumber/string()  
        let $validationResult := 
          if($OMTECPDNStatus eq "true") then
            partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_TextePDN_number", $OMTECPDNNumber, $partsValidationMap)
          else()

        let $OMTECPDNLink := $doc/part/LIFECYCLE/CHANGENOTICE/omtecPDNLink/string()  
        let $validationResult := 
          if($OMTECPDNLink ne "") then 
            partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_TextePDN_link", $OMTECPDNLink, $partsValidationMap)
          else()              

       (: let $ProjectName := for $Project in $doc/part/PROJECT/clampProjects/clampProject/string()
                            return $Project
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source, "Attribute@ProjectName", $ProjectName, $partsValidationMap):)

        let $CLAMPPartReplaceBy := $doc/part/PARTREPLACE/partReplaceBy/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ReplacedBy", $CLAMPPartReplaceBy, $partsValidationMap)

        let $ReasonForReplacement := $doc/part/PARTREPLACE/reasonForReplacement/string()
        let $validationResult := 
          if($ReasonForReplacement ne "") then
            partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ReasonForReplacement", $ReasonForReplacement, $partsValidationMap)
          else()

        let $ReplacementComment := $doc/part/PARTREPLACE/replacementComment/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@j5_Commentaire", $ReplacementComment, $partsValidationMap)

        let $ShelfLife := $doc/part/PARTFEATURE/shelfLife/string()
        
        let $validationResult := if($Perishable eq "true") 
                                  then (
                                  partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ShelfLife_Mandatory", $ShelfLife, $partsValidationMap)
                                  )
                                  else ()
    
        let $systemMaster := $doc/part/systemMaster/string()
        (:let $systemMaster := if ($systemMaster eq "DMA") then "DMA" 
                                                            else (if ($systemMaster = "PLM") then "PLM"
                                                            else (if ($systemMaster = "CLAMP") then "CLAMP"
                                                                  else()
                                                                  )
                                                            )
        :)
         let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ProjectName",$systemMaster, $partsValidationMap)

         let $serviceLevel := $doc/part/PARTUSAGE/serviceLevel/string()
         let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ServiceLevel",$serviceLevel, $partsValidationMap)
   
   (:Putting Validation data into Final Map:)
   
   let $manufValidationMap           := ValidationStep2:V_partManufacturer($document,$finalMap)[1]
   let $partCustomerValValidationMap := ValidationStep2:V_partCustomer($document,$finalMap)[1]
   let $composedByValidationMap := ValidationStep2:V_partComposed($document,$finalMap)[1]
   let $familyAttrValValidationMap := ValidationStep2:V_partFamily($document,$finalMap)[1]
   let $unitValidationMap := ValidationStep2:V_partUnit($document ,$finalMap)[1]
   let $projectforpartsValidationMap := ValidationStep2:V_partProject($document,$finalMap)[1]
   let $_ := map:put($finalMap, $valIdentifierPart, $partsValidationMap)

let $dataQualityAndValidationMessageMap := partvalidation:getDataQualityAndValidationMessages($finalMap)
let $dataQuality := 
      if(fn:empty($finalMap) and fn:empty($dataQualityAndValidationMessageMap)) then 
        ""
      else 
        map:keys($dataQualityAndValidationMessageMap)[1]

    let  $migrationComments := 
             if(fn:empty($finalMap) and fn:empty($dataQualityAndValidationMessageMap)) then 
        ""
      else
        map:get($dataQualityAndValidationMessageMap, map:keys($dataQualityAndValidationMessageMap)[1])
return ((:$finalMap,$manufValidationMap,$partsValidationMap,:)
element envelope {attribute xmlns { "http://marklogic.com/entity-services" } ,$header,
       element instance { element Orchestra {
      <part>
       <partNumber>{$partNumber}</partNumber>
       <revisionLevel>{$revisionLevel}</revisionLevel>
       <clampPartData>
               <clampControllingUnit>{$clampControllingUnit}</clampControllingUnit>
               <clampCommodityCode>{$clampCommodityCode}</clampCommodityCode>
               <clampDate>{$clampDate}</clampDate>
               <clampPartStatus>{$clampPartStatus}</clampPartStatus>
               <clampSequence>{$clampSequence}</clampSequence>
               <clampPplFlag>{$clampPplFlag}</clampPplFlag>
               <clampContainsCombustibleMaterial>{$clampContainsCombustibleMaterial}</clampContainsCombustibleMaterial>
               <clampProtection>{$clampProtection}</clampProtection>
               <clampMaterial>{$clampMaterial}</clampMaterial>
               <clampVaultOwner>{$clampVaultOwner}</clampVaultOwner>
               <clampReflowMaxTempTime>{$clampReflowMaxTempTime}</clampReflowMaxTempTime>
               <clampMSLWorstCase>{$clampMSLWorstCase}</clampMSLWorstCase>
       </clampPartData> 
       <familyNameEnglish>{$familyNameEnglish}</familyNameEnglish>
       <shortDescription>{$shortDescriptionEN}</shortDescription>
            <OTHERSHORTDESCRIPTION>
              <shortDescFrench>{$shortDescriptionFR}</shortDescFrench>
              <shortDescGerman>{$shortDescriptionGE}</shortDescGerman>
                <shortDescItalian>{$shortDescriptionIT}</shortDescItalian>
              <shortDescPolish>{}</shortDescPolish>
              <shortDescPortuguese>{}</shortDescPortuguese>
              <shortDescSpanish>{$shortDescriptionSP}</shortDescSpanish>
            </OTHERSHORTDESCRIPTION>
            <longDescription>{$longDescriptionEN}</longDescription>
            <OTHERLONGDESCRIPTION>
              <longDescFrench>{$longDescriptionFR}</longDescFrench>
              <longDescGerman>{$longDescriptionAL}</longDescGerman>
              <longDescItalian>{$longDescriptionAU}</longDescItalian>
              <longDescPolish>{}</longDescPolish>
              <longDescPortuguese>{}</longDescPortuguese>
              <longDescSpanish>{$longDescriptionES}</longDescSpanish>
            </OTHERLONGDESCRIPTION>
            <alstomDescription>{$alstomDescriptionEN}</alstomDescription>
            <OTHERALSTOMDESCRIPTION>
                  <alstomDescFrench>{$alstomDescriptionFR}</alstomDescFrench>
                  <alstomDescGerman>{$alstomDescriptionAL}</alstomDescGerman>
                  <alstomDescItalian>{$alstomDescriptionAU}</alstomDescItalian>
                  <alstomDescPolish>{}</alstomDescPolish>
                  <alstomDescPortuguese>{}</alstomDescPortuguese>
                  <alstomDescSpanish>{$alstomDescriptionES}</alstomDescSpanish>
            </OTHERALSTOMDESCRIPTION>
            <quickClampForm>{$PartFormURL}</quickClampForm>
            <usability>{$MakeBuyIndicator}</usability>
            <systemMaster>{$systemMaster}</systemMaster>
            <designAuthority>{$designAuthority}</designAuthority>
            <partTp>{$PartType}</partTp>
            <unspsc>{$UNPSC}</unspsc>
            <unitOfMeasure>{$UnitOfMeasure}</unitOfMeasure>
            <mass>{$Mass}</mass>
            <pplFlag>{}</pplFlag>
            <submitterUnit>{$submitterUnit}</submitterUnit>
            <reachWorstCase>{$ReachWorstCase}</reachWorstCase>
            <PARTUSAGE>
              <restrictedPart>{$RestrictedPart}</restrictedPart>
              <restrictedPartComment></restrictedPartComment>
              <serviceLevel>{$serviceLevel}</serviceLevel>
              <selleableSparePart></selleableSparePart>
              <repairable>{$Repairable}</repairable>
            </PARTUSAGE>
             <partROHS>{$partROHS}</partROHS>
            <PARTFEATURE>
              <mslWorstCase>{$MSLWorstCase}</mslWorstCase>
              <reflowMaxTempTime>{$ReflowMaxTempTime}</reflowMaxTempTime>
              <rislWorstCase></rislWorstCase>
              <fireSmoke></fireSmoke>
              <fireSmokeComment></fireSmokeComment>
              <perishablePart>{$Perishable}</perishablePart>
              <perishablePartComment></perishablePartComment>
              <shelfLife>{$ShelfLife}</shelfLife>
              <material>{$material}</material>
              <traceability></traceability>
              <hazardousGood>{$hazardousGoods}</hazardousGood>
              <alstomIPOwner></alstomIPOwner>
              <standards>{          
                for $standard in $Standards
                return 
                  <standard>{$standard}</standard>}
              </standards>
            </PARTFEATURE>
            <partLifecycleStatus>{$PartLifecycleStatus}</partLifecycleStatus>
             <LIFECYCLE>
             <monitored>{$PartLifecycleStatusMonitored}</monitored>
             <CHANGENOTICE>
              <omtecPDNStatus>{$OMTECPDNStatus}</omtecPDNStatus>
              <omtecPDNNumber>{$OMTECPDNNumber}</omtecPDNNumber>
              <omtecPDNLink>{$OMTECPDNLink}</omtecPDNLink>
             </CHANGENOTICE>
            </LIFECYCLE>
            <SUBSCRIPTION></SUBSCRIPTION>
            <PARTREPLACE>
              <partReplaceBy>{$CLAMPPartReplaceBy}</partReplaceBy>
              <reasonForReplacement>{$ReasonForReplacement}</reasonForReplacement>
              <replacementComment>{$ReplacementComment}</replacementComment>
            </PARTREPLACE>
       <QUALITY>
        <dataQualityStatus>{$dataQuality}</dataQualityStatus>
        <commentOnMigration>{$migrationComments}
        </commentOnMigration>
        <duplicate>{$Duplicate}</duplicate>
        <reachRefreshDate>{}</reachRefreshDate>
        <fireSmokeRefreshDate>{}</fireSmokeRefreshDate> 
        </QUALITY>
      </part>,
      $doc/partmanufacturers,
      $doc/partcustomers,
      $doc/partcompositions,
      $doc/familyAttributes,
      $doc/familyClassificationLink,
      $doc/units,
      $doc/PROJECTS
  }
  }
}
)

};



let $partNumber := $URI
let $document :=  document {harmonizationstep2:searchPartInAllSystem($partNumber)}
let $orhestraUri := "http://alstom.com/Orchestra/Final/"||$partNumber||".xml"
let $deltaOrchestraCollection := xs:string(fn:concat("/Orchestra/Delta/",fn:format-date(fn:current-date(),"[D01]-[M01]-[Y0001]")))
let $options := map:map()
let $_ := map:put($options,"collections",("Orchestra",$deltaOrchestraCollection))
let $_ := map:put($options,"permissions",(xdmp:permission("rest-reader","read","object"),
                                          xdmp:permission("rest-writer","update","object"),
                                          xdmp:permission("data-hub-operator","read","object"),
                                          xdmp:permission("data-hub-operator","update","object")))
let $finalDocument := harmonizationstep2:step2Validation($document/es:envelope,map:map())
return xdmp:document-insert($orhestraUri,$finalDocument,$options)