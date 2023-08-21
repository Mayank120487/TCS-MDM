xquery version "1.0-ml";

module namespace partsmanuftranformation = "partsmanuftranformation";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";


(: declare function partsmanuftranformation:getEncryptedString($srcStr as xs:string?) as xs:string? {
  let $md5 := xdmp:md5($srcStr, "hex")
  return fn:replace($md5, "a", "11") ! fn:replace(., "b", "12") ! fn:replace(., "c", "13") ! fn:replace(., "d", "14") ! fn:replace(., "e", "15") ! fn:replace(., "f", "16")
}; :)
 
declare function partsmanuftranformation:transMPNMonitored($valStr) as xs:string {
  (: Transrule: If value is -- or Blank ==> false
      Else true    
  :)
  if(fn:empty($valStr)) then
    "false"
  else if($valStr = "--" or $valStr = "") then
    "false"
  else if($valStr = "j5StRefTT"  or $valStr = "j5StRefWP") then  (:newly added:)
    "false"
  else
     "true"
};

declare function partsmanuftranformation:replaceForbiddenChars($valStr as xs:string?) as xs:string {
 if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};

declare function partsmanuftranformation:checkNull($valStr){
  if(fn:empty($valStr)) then
  ""
  else
  $valStr
};

declare function partsmanuftranformation:transIsManufacturer($valStr as xs:string?) as xs:string {
  (: Transrule
      if j5Choix1 = Yes
      Else No
    j5Choix1 ==> Manufacturer
    j5Choix2 ==> Supplier
  :)
 if(fn:empty($valStr)) then
    ""
 else if($valStr = "j5Choix1") then
    "Yes"
   else
     "--"
};

declare function partsmanuftranformation:transMPNLifeCycleStatus($valStr as xs:string?) as xs:string {
  
  (: Transrule
    j5StRefI : <I  : Product introduction> ==> 10-Introduction
    j5StRefS : <S  : Product maturity> ==> 20-Current
    j5StRefM : <M  : Product declining> ==> 30-Mature
    j5StRefOA: <OA : Last time buy in progress> ==> 70-End of Life
    j5StRefOH: <OH : Product discontinued> ==> 90-After-Life
    j5StRefWP: <WP : Warning Process> == Blank
    j5StRefR : <R  : End of life stock> ==> 91-LTB Stock
    j5StRefOF: <OF : Manufacturer obsolete> ==> 90-After-Life
    j5StRefTT: <-- : No watch> ==> Blank
  :)
  if(fn:empty($valStr)) then
    ""
  else if($valStr = "j5StRefI") then
    "10" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Introduction"
  else if($valStr = "j5StRefS") then
    "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current"
  else if($valStr = "j5StRefM") then
    "30" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Mature"
  else if($valStr = "j5StRefOA") then
    "70" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "End of Life"
  else if($valStr = "j5StRefOH") then
    "90" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "After-Life"
  else if($valStr = "j5StRefR") then
    "91" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "LTB Stock"
  else if($valStr = "j5StRefOF") then
    "90" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "After-Life"
  else
    ""
};

declare function partsmanuftranformation:transClampPartManufacturerStatus($valStr as xs:string?) as xs:string {
  (: Transrule
      j5StRefI : <I  : Product introduction> ==> I
      j5StRefS : <S  : Product maturity> ==> S
      j5StRefM : <M  : Product declining> ==> M
      j5StRefOA: <OA : Last time buy in progress> ==> OA
      j5StRefOH: <OH : Product discontinued> ==> OH
      j5StRefWP: <WP : Warning Process> == WP
      j5StRefR : <R  : End of life stock> ==> R
      j5StRefOF: <OF : Manufacturer obsolete> ==> OF
      j5StRefTT: <-- : No watch> ==> Blank
  :)
  if(fn:empty($valStr)) then
    ""
  else if($valStr = "j5StRefI") then
    "I"
  else if($valStr = "j5StRefS") then
    "S"
  else if($valStr = "j5StRefM") then
    "M"
  else if($valStr = "j5StRefOA") then
    "OA"
  else if($valStr = "j5StRefOH") then
    "OH"
  else if($valStr = "j5StRefWP") then
    "WP"
  else if($valStr = "j5StRefR") then
    "R"
  else if($valStr = "j5StRefOF") then
    "OF"
  else
     ""
};

declare function partsmanuftranformation:transROHS($valStr as xs:string?) as xs:string {
  (: Transrule
      if -- ==> Blank
  :)
  if(fn:empty($valStr)) then
    "Not found"
  else if($valStr = "+") then
    "Yes"
  else if($valStr = "-") then
    "No"
  else
    "Not defined"
};

declare function partsmanuftranformation:transReach($valSupplier) as xs:string { 
  (: REACH TransRule
        j5_SVHC         j5_REACHCandidates        j5_REACHAnnexe	      REACHValue
        ===========================================================================
        --	              --                      --                  	--
        ----------------------------------------------------------------------------
        False	(-)         False (-)               False (-)            ‘Reach Secured’
        ----------------------------------------------------------------------------
        True	(+)         False	                  False	                ‘SVHC’
        -----------------------------------------------------------------------------
        Any value	        True	                  False	                ‘Candidate’
        -----------------------------------------------------------------------------
        Any value	        Any value	              True	                ‘Annex XIV’

  :)
  let $j5_SVHC := $valSupplier/Attribute[@CLAMP_ID='j5_SVHC']/RealValue/text()
  let $j5_REACHCandidates := $valSupplier/Attribute[@CLAMP_ID='j5_REACHCandidates']/RealValue/text()
  let $j5_REACHAnnexe := $valSupplier/Attribute[@CLAMP_ID='j5_REACHAnnexe']/RealValue/text()
  return 
    if($j5_SVHC = "--" and $j5_REACHCandidates = "--" and $j5_REACHAnnexe = "--") then
      "--"
    else if($j5_SVHC = "-" and $j5_REACHCandidates = "-" and $j5_REACHAnnexe = "-") then
      "Reach secured"
    else if($j5_SVHC = "+" and $j5_REACHCandidates = "-" and $j5_REACHAnnexe = "-") then
      "SVHC"
    else if($j5_REACHCandidates = "+" and $j5_REACHAnnexe = "-") then
      "Candidate"
    else if($j5_REACHAnnexe = "+") then
      "Annex XIV"
    else
      "--"                (:newly added:)       (:Not Set to "--":)
};

declare function partsmanuftranformation:getSuppliers($partResult) {
  let $suppliers := $partResult/Suppliers/Supplier
  return $suppliers  
};

(:==================================================================
  DROP 2 FUNCTIONS STARTED
====================================================================:)

declare function partsmanuftranformation:transCheckValueForHypens($varVal) {
  if(fn:empty($varVal)) then
      ""
  else if($varVal eq "--") then
    ""
  else 
    $varVal 
};


declare function partsmanuftranformation:transMaxtemp($valMaxTemp)  {
  if (fn:empty($valMaxTemp)) then
	  ""
  else if (fn:matches($valMaxTemp, '^[0-9]+$')) then
	  $valMaxTemp
  else ""  
};

declare function partsmanuftranformation:transMaxtime($valMaxTime)  {	
  if(fn:empty($valMaxTime)) then
    ""
  else if (fn:matches($valMaxTime, '^[0-9]+$')) then
	  $valMaxTime
  else ""
};

(: 06-10-2021 Added "Warning Process" Attribute as per New CR's :)
declare function partsmanuftranformation:transWarningProcess($valStr) {
  if(fn:empty($valStr)) then
    "false"
    else if ($valStr = "WP") then
    "true"
    else "false"
};


(:======================================================================================================:)

declare function partsmanuftranformation:process($uri, $finalMap as map:map) {
  let $result := fn:doc($uri)/CLAMPPart
  let $index := 0
  let $suppliers := partsmanuftranformation:getSuppliers($result)
   

 return (<partmanufacturers>{
    for $supplier in $suppliers 
    let $_IsManufacturer := $supplier/Attribute[@CLAMP_ID="j5_ChoixRelFourFab"]/RealValue/text() (:removed check null function:)
    let $IsManufacturer := partsmanuftranformation:transIsManufacturer($_IsManufacturer)
      (: Migrate if Manufacturer :)
    return  if($_IsManufacturer = "j5Choix1") then 
            let $manufValidationMap := map:new(())	
let $ManufacturerShortName := $supplier/Attribute[@CLAMP_ID="j5_NomFournisseur"]/Value/text()  (:removed check null function:)


            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@j5_NomFournisseur", $ManufacturerShortName, $manufValidationMap):)
            let $valIdentifier := $index || ". Parts Manufacturer - (" || $ManufacturerShortName || ")&#13;-----------------------------------------------------------"
            (:let $index := (xdmp:set($index, $index + 1), $index):)																																																				   
            let $PartNumber := $result/Attribute[@CLAMP_ID="PartNumber"]/Value/text()  (:removed check null function:)
            
            let $ManufacturerPartNumber := partsmanuftranformation:transCheckValueForHypens($supplier/Attribute[@CLAMP_ID="j5_RefArtFourn"]/Value/text())  (:removed check null function:)
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@j5_RefArtFourn", $ManufacturerPartNumber, $manufValidationMap):)
            let $j5_StatutReference := partsmanuftranformation:transCheckValueForHypens($supplier/Attribute[@CLAMP_ID="j5_StatutReference"]/RealValue/text()) (:removed check null function:)
            let $MPNMonitored := partsmanuftranformation:transMPNMonitored($j5_StatutReference)
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@MPNMonitored", $MPNMonitored, $manufValidationMap):)
            
            let $MPNLifeCycleStatus := partsmanuftranformation:transMPNLifeCycleStatus($j5_StatutReference)
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@MPNLifeCycleStatus", $MPNLifeCycleStatus, $manufValidationMap):)  
        
            let $ClampPartManufacturerStatus := partsmanuftranformation:transClampPartManufacturerStatus($j5_StatutReference)
            (:let $validationResult :=  partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@ClampPartManufacturerStatus", $j5_StatutReference, $manufValidationMap:)
            
            let $Reach := partsmanuftranformation:transReach($supplier)
            (:let $validationResult :=  partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@Reach", $Reach, $manufValidationMap):)
              
            let $ROHS := $supplier/Attribute[@CLAMP_ID="LeadFree"]/RealValue/text()  (:removed check null function:)
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@LeadFree", $ROHS, $manufValidationMap):)
            let $ROHS := partsmanuftranformation:transROHS($ROHS)
            (:==================================================================
            DROP 2 ATTRIBUTE STARTED
            ====================================================================:)
            let $MSL := $supplier/Attribute[@CLAMP_ID="MSLLevel"]/RealValue/text()
            let $MSL := partsmanuftranformation:transCheckValueForHypens($MSL)
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@MSLLevel", $MSL, $manufValidationMap):)

            let $plating := $supplier/Attribute[@CLAMP_ID="Terminaison"]/Value[@LANG="en_us"]/text()
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@Plating", $plating, $manufValidationMap):)
            let $plating := partsmanuftranformation:transCheckValueForHypens($plating)

            let $otherconstraints := partsmanuftranformation:transCheckValueForHypens($supplier/Attribute[@CLAMP_ID="j5_ObsRefArtFourn"]/Value/text())  (:Added transCheckValueForHypens transformation:)
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@OtherConstraints", $otherconstraints, $manufValidationMap):)

            let $specificity := $supplier/Attribute[@CLAMP_ID="MigrationDate"]/Value[@LANG="en_us"]/text()     
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@Specificity", $specificity, $manufValidationMap):)
            let $specificity := partsmanuftranformation:transCheckValueForHypens($specificity)

            let $maxtemp := $supplier/Attribute[@CLAMP_ID = "TempMax"]/Value/text()
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@MaxTemp", $maxtemp, $manufValidationMap):)
            let $maxtemp := partsmanuftranformation:transMaxtemp($maxtemp)     

            let $maxtime := $supplier/Attribute[@CLAMP_ID = "MaxTime"]/Value/text()
            (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Supplier_Attribute@MaxTime", $maxtime, $manufValidationMap):)
            let $maxtime := partsmanuftranformation:transMaxtime($maxtime)
            
            (:Composite Primary Key: concatenation of Part Number, Manufacturer Short Name, Manufaccturer Part Number :)
            
            let $compositePrimaryKey := $PartNumber || "_" || $ManufacturerShortName || "_" || $ManufacturerPartNumber
            let $compositePrimaryKey := fn:replace($compositePrimaryKey, " ", "_")
            (:let $compositePrimaryKey := partsmanuftranformation:getEncryptedString($compositePrimaryKey):)

            (: 06-10-2021 Added "Warning Process" Attribute as per New CR's :)
            let $warningProcess := partsmanuftranformation:transWarningProcess($ClampPartManufacturerStatus)


            (:==================================================================
            DROP 2 ATTRIBUTE ENDED
            ====================================================================:)
                  
      let $_ := 
                if(fn:count(map:keys($manufValidationMap)) gt 0) then
                  let $index := (xdmp:set($index, $index + 1), $index)
                  let $valIdentifier := "1." || $index || " Parts Manufacturer - (" || $ManufacturerShortName || ")&#13;-----------------------------------------------------------"
                  return map:put($finalMap, $valIdentifier, $manufValidationMap)
                else () 
                    
      return  
       <partmanufacturer>
	      <partManufacturerId>{$compositePrimaryKey}</partManufacturerId>
        <partNumber>{$PartNumber}</partNumber>
        <parManuNumber>{$ManufacturerPartNumber}</parManuNumber>
		    <manuShortName>{$ManufacturerShortName}</manuShortName>
        <suppManuRelationType>{$j5_StatutReference}</suppManuRelationType>
        <mpnMonitored>{$MPNMonitored}</mpnMonitored>
        <partManuLifecycleStatus>{$MPNLifeCycleStatus}</partManuLifecycleStatus>
		    <partManuLifecycleStatusRefreshDate></partManuLifecycleStatusRefreshDate>
        <partClampManuStatus>{$ClampPartManufacturerStatus}</partClampManuStatus>
        <reach>{$Reach}</reach>
		    <rohs>{$ROHS}</rohs>
        <manuId>MANU000000</manuId>
		    <manuDuns>MANU000000</manuDuns>
		    <globalUltimateParent>MANU000000</globalUltimateParent>
		    <MANUFACTURERCONSTRAINT>
			    <msl>{$MSL}</msl>
          <plating>{$plating}</plating>
          <otherConstraint>{$otherconstraints}</otherConstraint>
          <specificity>{$specificity}</specificity>
          <reflowMaximumTemperature>{$maxtemp}</reflowMaximumTemperature>
          <reflowMaximumTime>{$maxtime}</reflowMaximumTime>
          <externalGTIN></externalGTIN>
          <recordStatus>{"Active"}</recordStatus>
          <MILESTONEDATE>
            <startOfPrototypeProduction></startOfPrototypeProduction>
            <startOfSeriesProduction></startOfSeriesProduction>
            <endOfSalesParts></endOfSalesParts>
            <endOfSeriesProduction></endOfSeriesProduction>
            <endOfSalesOfSpareParts></endOfSalesOfSpareParts>
            <endOfSalesOfRepairsForRepairableParts></endOfSalesOfRepairsForRepairableParts>
            <endOfSupport></endOfSupport>
            <endOfProductionOfPart_EOP></endOfProductionOfPart_EOP>
          </MILESTONEDATE>
        </MANUFACTURERCONSTRAINT>
        <warningProcess>{$warningProcess}</warningProcess>
      </partmanufacturer>
      else ()
   }</partmanufacturers>,$finalMap)
  };