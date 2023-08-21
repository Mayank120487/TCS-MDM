xquery version "1.0-ml";
module namespace Migration = "Migration"; 
declare namespace es = "http://marklogic.com/entity-services";
declare namespace xls = "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace ss = "urn:schemas-microsoft-com:office:spreadsheet";
declare variable $nmsp := fn:namespace-uri(<xls:x/>);
 
  declare function Migration:generateXMLElement($valStr as xs:string?) {
    element {fn:QName($nmsp, "Cell")} {
        element {fn:QName($nmsp, "Data")} {
            attribute{"ss:Type"}{"String"}, text{Migration:replaceForbiddenChars($valStr)}
        }
    }
  };

declare function Migration:replaceForbiddenChars($valStr as xs:string?) as xs:string {
if(fn:exists($valStr) and ($valStr != "null")) then

let $retVal := fn:replace($valStr,"&amp;","&amp;")
let $retVal := fn:replace($retVal,"<","&lt;")
let $retVal := fn:replace($retVal,">","&gt;")
return $retVal

else
("")
};
  
 
  declare function Migration:processManufacturer($uri) {
    let $results := fn:doc($uri)/*:envelope/*:instance/Orchestra/partmanufacturers/partmanufacturer
    return  
      if(fn:empty($results)) then ()
      else 
      
      
      for $result in $results
        
          let $partmanuId := $result/partManufacturerId/string()
          let $PartNumber := $result/partNumber/string()
          let $manushortname := $result/manuShortName/string()
          let $manupartnumber := $result/parManuNumber/string()
          let $mpnMonitored := $result/mpnMonitored/string()
          let $mpnLifeCycleStatus := $result/partManuLifecycleStatus/string()
          let $mpnLifeCycleRefreshDate := $result/partManuLifecycleStatusRefreshDate/string()
          let $clampPartManuStatus := $result/partClampManuStatus/string()
          let $reach := $result/reach/string()
          let $rohs :=  $result/rohs/string()
          let $manuId := $result/manuId/string()
          let $manuDuns := $result/manuDuns/string()
          let $globalUtlimateParent := $result/globalUltimateParent/string()
          let $msl :=   $result/MANUFACTURERCONSTRAINT/msl/string()
          let $plating :=  $result/MANUFACTURERCONSTRAINT/plating/string()
          let $otherConstraint :=$result/MANUFACTURERCONSTRAINT/otherConstraint/string()
          let $specificity :=$result/MANUFACTURERCONSTRAINT/specificity/string()
          let $reflowMaximumTemperature := $result/MANUFACTURERCONSTRAINT/reflowMaximumTemperature/string()
          let $reflowMaximumTime :=   $result/MANUFACTURERCONSTRAINT/reflowMaximumTime/string()
          let $externalGtin := $result/MANUFACTURERCONSTRAINT/externalGTIN/string()
          let $recordStatus := $result/MANUFACTURERCONSTRAINT/recordStatus/string()
          let $startOfPrototypeProduction := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/startOfPrototypeProduction/string()
          let $startOfSeriesProduction := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/startOfSeriesProduction/string()
          let $endOfSalesParts := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/endOfSalesParts/string()
          let $endOfSeriesProduction := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/endOfSeriesProduction/string()
          let $endOfSalesOfSpareParts := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/endOfSalesOfSpareParts/string()
          let $endOfSalesOfRepairsForRepairableParts := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/endOfSalesOfRepairsForRepairableParts/string()
          let $endOfSupport := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/endOfSupport/string()
          let $endOfProductionOfPart_EOP := $result/MANUFACTURERCONSTRAINT/MILESTONEDATE/endOfProductionOfPart_EOP/string()
          let $warningProcess :=  $result/warningProcess/string()
        
        return element {fn:QName($nmsp, "Row")}{(
          Migration:generateXMLElement($partmanuId),
          Migration:generateXMLElement($PartNumber),
          Migration:generateXMLElement($manushortname),
          Migration:generateXMLElement($manupartnumber),
          Migration:generateXMLElement($mpnMonitored),
          Migration:generateXMLElement($mpnLifeCycleStatus),
          Migration:generateXMLElement(""),
          Migration:generateXMLElement($clampPartManuStatus),
          Migration:generateXMLElement($reach),
          Migration:generateXMLElement($rohs),
          Migration:generateXMLElement($manuId),
          Migration:generateXMLElement($manuDuns),
          Migration:generateXMLElement($globalUtlimateParent),
          Migration:generateXMLElement($msl),
          Migration:generateXMLElement($plating),
          Migration:generateXMLElement($otherConstraint),
          Migration:generateXMLElement($specificity),
          Migration:generateXMLElement($reflowMaximumTemperature),
          Migration:generateXMLElement($reflowMaximumTime),
          Migration:generateXMLElement($externalGtin),
          Migration:generateXMLElement($recordStatus),
          Migration:generateXMLElement($startOfPrototypeProduction),
          Migration:generateXMLElement($startOfSeriesProduction),
          Migration:generateXMLElement($endOfSalesParts),
          Migration:generateXMLElement($endOfSeriesProduction),
          Migration:generateXMLElement($endOfSalesOfSpareParts),
          Migration:generateXMLElement($endOfSalesOfRepairsForRepairableParts),
          Migration:generateXMLElement($endOfSupport),
          Migration:generateXMLElement($endOfProductionOfPart_EOP),
          Migration:generateXMLElement($warningProcess)
        )}           

};

 declare function Migration:processPart($uri) {
    let $result := fn:doc($uri)/*:envelope/*:instance/Orchestra/part
    return 
      if(fn:empty($result)) then ()
      else (
        let $PartNumber := $result/partNumber/string()
        let $Revision := $result/revisionLevel/string()
        let $PartTp := $result/partTp/string()
        let $UnitOfMeasure := $result/unitOfMeasure/string()
        let $Usability := $result/usability/string()
        let $SystemMaster := $result/systemMaster/string()
        let $PartLifecycleStatus := $result/partLifecycleStatus/string()
        let $DesignAuthority := $result/designAuthority/string()
        let $ShortDescription := $result/shortDescription/string()
        let $LongDescription := $result/longDescription/string()
        let $AlstomDescription := $result/alstomDescription/string()
        let $ShortDescFrench := $result/OTHERSHORTDESCRIPTION/shortDescFrench/string()
        let $ShortDescGerman := $result/OTHERSHORTDESCRIPTION/shortDescGerman/string()
        let $ShortDescItalian := $result/OTHERSHORTDESCRIPTION/shortDescItalian/string()
        let $ShortDescPolish := $result/OTHERSHORTDESCRIPTION/shortDescPolish/string()
        let $ShortDescPortuguese := $result/OTHERSHORTDESCRIPTION/shortDescPortuguese/string()
        let $ShortDescSpanish := $result/OTHERSHORTDESCRIPTION/shortDescSpanish/string()
        let $LongDescFrench := $result/OTHERLONGDESCRIPTION/longDescFrench/string()
        let $LongDescGerman := $result/OTHERLONGDESCRIPTION/longDescGerman/string()
        let $LongDescItalian := $result/OTHERLONGDESCRIPTION/longDescItalian/string()
        let $LongDescPolish := $result/OTHERLONGDESCRIPTION/longDescPolish/string()
        let $LongDescPortuguese := $result/OTHERLONGDESCRIPTION/longDescPortuguese/string()
        let $LongDescSpanish := $result/OTHERLONGDESCRIPTION/longDescSpanish/string()
        let $AlstomDescFrench := $result/OTHERALSTOMDESCRIPTION/alstomDescFrench/string()
        let $AlstomDescGerman := $result/OTHERALSTOMDESCRIPTION/alstomDescGerman/string()
        let $AlstomDescItalian := $result/OTHERALSTOMDESCRIPTION/alstomDescItalian/string()
        let $AlstomDescPolish := $result/OTHERALSTOMDESCRIPTION/alstomDescPolish/string()
        let $AlstomDescPortuguese := $result/OTHERALSTOMDESCRIPTION/alstomDescPortuguese/string()
        let $AlstomDescSpanish := $result/OTHERALSTOMDESCRIPTION/alstomDescSpanish/string()
        let $FamilyNameEnglish := $result/familyNameEnglish/string()
        let $Unspsc := $result/unspsc/string()
        let $Mass := $result/mass/string()
        let $PplFlag := $result/pplFlag/string()
        let $SubmitterUnit := $result/submitterUnit/string()
        let $QuickClampForm := $result/quickClampForm/string()
        let $RestrictedPart := $result/PARTUSAGE/restrictedPart/string()
        let $RestrictedPartComment := $result/PARTUSAGE/restrictedPartComment/string()
        let $ServiceLevel := $result/PARTUSAGE/serviceLevel/string()
        let $SelleableSparePart := $result/PARTUSAGE/selleableSparePart/string()
        let $Repairable := $result/PARTUSAGE/repairable/string()
        let $ReachWorstCase := $result/reachWorstCase/string()
        let $PartROHS := $result/partROHS/string()
        let $RislWorstCase := $result/PARTFEATURE/rislWorstCase/string()
        let $FireSmoke := $result/PARTFEATURE/fireSmoke/string()
        let $FireSmokeComment := $result/PARTFEATURE/fireSmokeComment/string()
        let $PerishablePart := $result/PARTFEATURE/perishablePart/string()
        let $PerishablePartComment := $result/PARTFEATURE/perishablePartComment/string()
        let $ShelfLife := $result/PARTFEATURE/shelfLife/string()
        let $Material := $result/PARTFEATURE/material/string()
        let $Traceability := $result/PARTFEATURE/traceability/string()
        let $HazardousGood := $result/PARTFEATURE/hazardousGood/string()
        let $AlstomIPOwner := $result/PARTFEATURE/alstomIPOwner/string()
        
        let $Standards := $result/PARTFEATURE/standards/standard/string()
        let $Standards_join := fn:string-join($Standards,"&#13;")
		(: These two attributes were not present in migration template :)
		
        let $ReflowMaxTempTime := $result/PARTFEATURE/reflowMaxTempTime/string()
        let $MslWorstCase := $result/PARTFEATURE/mslWorstCase/string()
        (: These Attributes are not present in Orchestra Collection but present in Data Migration Template, So we did set them for ""  
        <safetyClassification>""</safetyClassification>
        <justificationcomments>""</justificationcomments>
        <attachment>""</attachment>
        <alstomAssignedGTIN>""</alstomAssignedGTIN>
        <internationalCustomsCode>""</internationalCustomsCode>    :)
        let $safetyClassification := ""
        let $justificationcomments := ""
        let $attachment := ""
        let $alstomAssignedGTIN := ""
        let $internationalCustomsCode := ""
 (:
        (:04-08-21: Added Migration code for project element:)
        let $ProjectId := $result/PROJECTS/PROJECT/projectId/string()
        let $ProjectId_join := fn:string-join($ProjectId,"&#13;")
        let $SafetyClassificationId  := $result/PROJECTS/PROJECT/safetyClassificationId/string()
        let $SafetyClassificationId_join := fn:string-join($SafetyClassificationId,"&#13;")
        let $SafetyJustificationComment := $result/PROJECTS/PROJECT/safetyJustificationComment/string()
        let $SafetyJustificationComment_join := fn:string-join($SafetyJustificationComment,"&#13;")
        let $Attachment    := $result/PROJECTS/PROJECT/attachment/string()
        let $Attachment_join := fn:string-join($Attachment,"&#13;")
        let $Projects_Traceability  := $result/PROJECTS/PROJECT/traceability/string()
        let $Projects_Traceability_join := fn:string-join($Projects_Traceability,"&#13;")
        let $Originate  := $result/PROJECTS/PROJECT/originate/string()
        let $Originate_join := fn:string-join($Originate,"&#13;")

:)

        (:let $PartLifecycleStatusMonitored := $result/LIFECYCLE/monitored/string():)
        let $Monitored := $result/LIFECYCLE/monitored/string()
        let $OmtecPDNStatus := $result/LIFECYCLE/CHANGENOTICE/omtecPDNStatus/string()
        let $OmtecPDNNumber := $result/LIFECYCLE/CHANGENOTICE/omtecPDNNumber/string()
        let $OmtecPDNLink := $result/LIFECYCLE/CHANGENOTICE/omtecPDNLink/string()
        let $ClampControllingUnit := $result/clampPartData/clampControllingUnit/string()
        let $ClampCommodityCode := $result/clampPartData/clampCommodityCode/string()
        let $ClampDate := $result/clampPartData/clampDate/string()
        let $ClampPartStatus := $result/clampPartData/clampPartStatus/string()
        let $ClampSequence := $result/clampPartData/clampSequence/string()
        let $ClampPplFlag := $result/clampPartData/clampPplFlag/string()
        let $ClampContainsCombustibleMaterial := $result/clampPartData/clampContainsCombustibleMaterial/string()
        let $ClampProtection := $result/clampPartData/clampProtection/string()
        let $ClampMaterial := $result/clampPartData/clampMaterial/string()
        let $ClampVaultOwner := $result/clampPartData/clampVaultOwner/string()
        let $ClampReflowMaxTempTime := fn:tokenize($result/clampPartData/clampReflowMaxTempTime/string(),"," )[1]
        let $ClampMSLWorstCase := $result/clampPartData/clampMSLWorstCase/string()
        let $PartReplaceBy := $result/PARTREPLACE/partReplaceBy/string()
        let $ReasonForReplacement := $result/PARTREPLACE/reasonForReplacement/string()
        let $ReplacementComment := $result/PARTREPLACE/replacementComment/string()
        let $DataQualityStatus := $result/QUALITY/dataQualityStatus/string()
        let $CommentOnMigration := $result/QUALITY/commentOnMigration/string()
        let $Duplicate := $result/QUALITY/duplicate/string()
        let $ReachRefreshDate := $result/QUALITY/reachRefreshDate/string()
        let $FireSmokeRefreshDate := $result/QUALITY/fireSmokeRefreshDate/string()





        (: These Attributes are not present in Orchestra Collection, but present in Data Migration Template, So we did set them for ""  

<createdBy>""</createdBy>
<created>""</created>
<updatedBy>""</updatedBy>
<lastUpdated>""</lastUpdated>      :)
                        
        return
element {fn:QName($nmsp, "Row")}{
Migration:generateXMLElement($PartNumber),
Migration:generateXMLElement($Revision),
Migration:generateXMLElement($PartTp),
Migration:generateXMLElement($UnitOfMeasure),
Migration:generateXMLElement($Usability),
Migration:generateXMLElement($SystemMaster),
Migration:generateXMLElement($PartLifecycleStatus),
Migration:generateXMLElement($DesignAuthority),
Migration:generateXMLElement($ShortDescription),
Migration:generateXMLElement($LongDescription),
Migration:generateXMLElement($AlstomDescription),
Migration:generateXMLElement($ShortDescFrench),
Migration:generateXMLElement($ShortDescGerman),
Migration:generateXMLElement($ShortDescItalian),
(:Migration:generateXMLElement($ShortDescPolish),
Migration:generateXMLElement($ShortDescPortuguese),:)
Migration:generateXMLElement($ShortDescSpanish),
Migration:generateXMLElement($LongDescFrench),
Migration:generateXMLElement($LongDescGerman),
Migration:generateXMLElement($LongDescItalian),
(:Migration:generateXMLElement($LongDescPolish),
Migration:generateXMLElement($LongDescPortuguese),:)
Migration:generateXMLElement($LongDescSpanish),
Migration:generateXMLElement($AlstomDescFrench),
Migration:generateXMLElement($AlstomDescGerman),
Migration:generateXMLElement($AlstomDescItalian),
(:Migration:generateXMLElement($AlstomDescPolish),
Migration:generateXMLElement($AlstomDescPortuguese),:)
Migration:generateXMLElement($AlstomDescSpanish),
Migration:generateXMLElement($FamilyNameEnglish),
Migration:generateXMLElement($Unspsc),
Migration:generateXMLElement($Mass),
Migration:generateXMLElement($PplFlag),
Migration:generateXMLElement($SubmitterUnit),
Migration:generateXMLElement($QuickClampForm),
Migration:generateXMLElement($RestrictedPart),
Migration:generateXMLElement($RestrictedPartComment),
Migration:generateXMLElement($ServiceLevel),
Migration:generateXMLElement($SelleableSparePart),
Migration:generateXMLElement($Repairable),
Migration:generateXMLElement($ReachWorstCase),
Migration:generateXMLElement($PartROHS),
Migration:generateXMLElement($RislWorstCase),
Migration:generateXMLElement($FireSmoke),
Migration:generateXMLElement($FireSmokeComment),
Migration:generateXMLElement($PerishablePart),
Migration:generateXMLElement($PerishablePartComment),
Migration:generateXMLElement($ShelfLife),
Migration:generateXMLElement($Material),
Migration:generateXMLElement($Traceability),
Migration:generateXMLElement($HazardousGood),
Migration:generateXMLElement($AlstomIPOwner),
Migration:generateXMLElement($Standards_join),


Migration:generateXMLElement($ReflowMaxTempTime),
Migration:generateXMLElement($MslWorstCase),
Migration:generateXMLElement(""),
Migration:generateXMLElement(""),
Migration:generateXMLElement(""),
Migration:generateXMLElement(""),
Migration:generateXMLElement(""),

(:
Migration:generateXMLElement($ProjectId_join),
Migration:generateXMLElement($SafetyClassificationId_join),
Migration:generateXMLElement($SafetyJustificationComment_join),
Migration:generateXMLElement($Attachment_join),
Migration:generateXMLElement($Projects_Traceability_join),
Migration:generateXMLElement($Originate_join),
:)

Migration:generateXMLElement($Monitored),
Migration:generateXMLElement($OmtecPDNStatus),
Migration:generateXMLElement($OmtecPDNNumber),
Migration:generateXMLElement($OmtecPDNLink),
Migration:generateXMLElement($ClampControllingUnit),
Migration:generateXMLElement($ClampCommodityCode),
Migration:generateXMLElement($ClampDate),
Migration:generateXMLElement($ClampPartStatus),
Migration:generateXMLElement($ClampSequence),
Migration:generateXMLElement($ClampPplFlag),
Migration:generateXMLElement($ClampContainsCombustibleMaterial),
Migration:generateXMLElement($ClampProtection),
Migration:generateXMLElement($ClampMaterial),
Migration:generateXMLElement($ClampVaultOwner),
Migration:generateXMLElement($ClampReflowMaxTempTime),
Migration:generateXMLElement($ClampMSLWorstCase),
Migration:generateXMLElement($PartReplaceBy),
Migration:generateXMLElement($ReasonForReplacement),
Migration:generateXMLElement($ReplacementComment),
Migration:generateXMLElement($DataQualityStatus),
Migration:generateXMLElement($CommentOnMigration),
Migration:generateXMLElement($Duplicate),
Migration:generateXMLElement($ReachRefreshDate),
Migration:generateXMLElement($FireSmokeRefreshDate),

Migration:generateXMLElement(""),
Migration:generateXMLElement(""),
Migration:generateXMLElement(""),
Migration:generateXMLElement("")


}

) 
};


declare function Migration:processComposedby($uri) {
    let $results := fn:doc($uri)/*:envelope/*:instance/Orchestra/partcompositions/partcomposition
    return  
      if(fn:empty($results)) then ()
      else 
      
          for $result in $results
          let $partNumber := $result/partNumber/string()
          let $composedPartNum := $result/partComposedBy/string()
          let $shortDesc := $result/shortDesc/string()
          let $quantity := $result/quantity/string()
          let $Uom := $result/unitOfMeasure/string()

        
        return
            element {fn:QName($nmsp, "Row")}{
                  Migration:generateXMLElement($partNumber),
		              Migration:generateXMLElement($composedPartNum),
		              Migration:generateXMLElement($shortDesc),
		              Migration:generateXMLElement($quantity),
		              Migration:generateXMLElement($Uom)
            }    
           
};

  
declare function Migration:processCustomer($uri) { 
    let $results := fn:doc($uri)/*:envelope/*:instance/Orchestra/partcustomers/partcustomer
    return 
		if(fn:empty($results)) then()
		else
			for $result in $results
      
         let $PartCustomerId := $result/partCustomerId/string()
         let $PartNumber := $result/partNumber/string()
         let $CustomerID := $result/customer/string()
         let $CustomerPartNum := $result/customerPartNumber/string()
         let $CustomerPartDesc := $result/CustomerPartDescription/string()
         let $CustomerPartRev := $result/customerPartRevision/string()
         let $ClampCustomerName := $result/clampCustomer/string()
         let $ClampPartNum := $result/clampCustomerPartNumber/string()
         (: 21/09/21 changes made : $CustomerPartDesc changed to $ClampCustomerPartDesc :)
         (: let $CustomerPartDesc := $result/clampCustomerPartDescription/string() :)
         let $ClampCustomerPartDesc := $result/clampCustomerPartDescription/string()
         (: 30/09/21 changes made : $CustomerPartRev changed to $ClampCustomerPartRev :)
         (: let $CustomerPartRev := $result/clampCustomerPartRevision/string() :)
         let $ClampCustomerPartRev := $result/clampCustomerPartRevision/string()
         
          (: 30-09-2021 Changed from "CustomerPartRev" to "ClampCustomerPartRev" :)
        return
           element {fn:QName($nmsp, "Row")}{
            Migration:generateXMLElement($PartCustomerId),
            Migration:generateXMLElement($PartNumber),
            Migration:generateXMLElement($CustomerID),
            Migration:generateXMLElement($CustomerPartNum),
            Migration:generateXMLElement($CustomerPartDesc),
            Migration:generateXMLElement($CustomerPartRev),
            Migration:generateXMLElement($ClampCustomerName),
            Migration:generateXMLElement($ClampPartNum),
            Migration:generateXMLElement($ClampCustomerPartDesc),
            Migration:generateXMLElement($ClampCustomerPartRev),
            Migration:generateXMLElement(""),
            Migration:generateXMLElement(""),
            Migration:generateXMLElement(""),
            Migration:generateXMLElement("")
           }
           
     
};


declare function Migration:processFamily($uri) {
    let $results := fn:doc($uri)/*:envelope/*:instance/Orchestra/familyAttributes/familyAttribute
    return 
      if(fn:empty($results)) then ()
      else 
      for $result in $results
          let $AttributeValueID := $result/attributeValueID/string()
          let $PartFamilyClassificationLink := $result/partFamilyClassificationLink/string()
          let $Attribute := $result/attribute/string()
          let $Value := $result/Value/string()
          
        
        return


element {fn:QName($nmsp, "Row")}{
Migration:generateXMLElement($AttributeValueID),
Migration:generateXMLElement($PartFamilyClassificationLink),
Migration:generateXMLElement($Attribute),
Migration:generateXMLElement($Value)
}
 
      

};


declare function Migration:processFamilyClassification($uri) {
    let $result := fn:doc($uri)/*:envelope/*:instance/Orchestra/familyClassificationLink/string()
    return 
      if(fn:exists($result) and $result != "") then
       let $FamilyClassificationLink := $result
                           
        return
element {fn:QName($nmsp, "Row")}{
Migration:generateXMLElement($FamilyClassificationLink)
}
      else ()
        

 
};

declare function Migration:processUnits($uri) {
    let $results := fn:doc($uri)/*:envelope/*:instance/Orchestra/units/unit
    return 
      if(fn:empty($results)) then ()
      else 
      for $result in $results
        
        let $partnumber := $result/partnumber/string()
        let $unitcode := $result/unitcode/string()
        let $unitDescription := $result/unitdescription/string()
        let $legacycode := $result/legacycode/string()
   
        return
        element {fn:QName($nmsp, "Row")}{
        Migration:generateXMLElement($partnumber),
        Migration:generateXMLElement($unitcode),
        Migration:generateXMLElement($legacycode)
        }
    
};

declare function Migration:processProjects($uri) {
    let $results := fn:doc($uri)/*:envelope/*:instance/Orchestra/PROJECTS/PROJECT
    return 
      if(fn:empty($results)) then ()
      else 
      for $result in $results
        
        let $partnumber := $result/partNumber/string()
        let $projectId := $result/projectId/string()
        let $safetyClassificationId := $result/safetyClassificationId/string()
        let $safetyJustificationComment := $result/safetyJustificationComment/string()
        let $attachment := $result/attachment/string()
        let $traceability := $result/traceability/string()
        let $originate := $result/originate/string()
   
        return
        element {fn:QName($nmsp, "Row")}{
        Migration:generateXMLElement($partnumber),
        Migration:generateXMLElement($projectId),
        Migration:generateXMLElement($safetyClassificationId),
        Migration:generateXMLElement($safetyJustificationComment),
        Migration:generateXMLElement($attachment),
        Migration:generateXMLElement($traceability),
        Migration:generateXMLElement($originate)
        }
    
};
