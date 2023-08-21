xquery version "1.0-ml";
module namespace ValidationStep2 = "ValidationStep2";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";

declare function ValidationStep2:V_partManufacturer($document as node(),$finalMap as map:map){
  let $doc := $document/*:instance/*:Orchestra
  (: 01-10-2021 Changes for Validation for new step 2 merging logic :)
  let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
  let $index := 0
  let $partmanufacturers := $document/*:instance/*:Orchestra/partmanufacturers/partmanufacturer
   

 return 
    for $partmanufacturer in $partmanufacturers 
     return  if(fn:exists($partmanufacturers)) then 
            let $manufValidationMap := map:new(())	
            let $ManufacturerShortName := $partmanufacturer/manuShortName/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@j5_NomFournisseur", $ManufacturerShortName, $manufValidationMap)
            
            let $valIdentifier := $index || ". Parts Manufacturer - (" || $ManufacturerShortName || ")&#13;-----------------------------------------------------------"
            (:let $index := (xdmp:set($index, $index + 1), $index):)																																																				   
            let $PartNumber := $partmanufacturer/partNumber/string()
            
            let $ManufacturerPartNumber := $partmanufacturer/parManuNumber/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@j5_RefArtFourn", $ManufacturerPartNumber, $manufValidationMap)
            
            let $MPNMonitored := $partmanufacturer/mpnMonitored/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@MPNMonitored", $MPNMonitored, $manufValidationMap)
            
            let $MPNLifeCycleStatus := $partmanufacturer/partManuLifecycleStatus/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@MPNLifeCycleStatus", $MPNLifeCycleStatus, $manufValidationMap)  
        
            let $ClampPartManufacturerStatus := $partmanufacturer/partClampManuStatus/string()
            let $validationResult :=  partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@ClampPartManufacturerStatus", $ClampPartManufacturerStatus, $manufValidationMap)
          
            let $Reach := $partmanufacturer/reach/string()
            let $validationResult :=  partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@Reach", $Reach, $manufValidationMap)
              
            let $ROHS := $partmanufacturer/rohs/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@LeadFree", $ROHS, $manufValidationMap)
           
            (:==================================================================
            DROP 2 ATTRIBUTE STARTED
            ====================================================================:)
            
            let $MSL := $partmanufacturer/MANUFACTURERCONSTRAINT/msl/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@MSLLevel", $MSL, $manufValidationMap)

            let $plating := $partmanufacturer/MANUFACTURERCONSTRAINT/plating/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@Plating", $plating, $manufValidationMap)
           

            let $otherconstraints :=  $partmanufacturer/MANUFACTURERCONSTRAINT/otherConstraint/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@OtherConstraints", $otherconstraints, $manufValidationMap)

            let $specificity := $partmanufacturer/MANUFACTURERCONSTRAINT/specificity/string()    
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@Specificity", $specificity, $manufValidationMap)
            

            let $maxtemp := $partmanufacturer/MANUFACTURERCONSTRAINT/reflowMaximumTemperature/string() 
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@MaxTemp", $maxtemp, $manufValidationMap)
             

            let $maxtime := $partmanufacturer/MANUFACTURERCONSTRAINT/reflowMaximumTime/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@MaxTime", $maxtime, $manufValidationMap)
            
            
            (:Composite Primary Key: concatenation of Part Number, Manufacturer Short Name, Manufaccturer Part Number :)
            let $compositePrimaryKey := $PartNumber || "_" || $ManufacturerShortName || "_" || $ManufacturerPartNumber
            (:let $compositePrimaryKey := partsmanuftranformation:getEncryptedString($compositePrimaryKey):)

            let $warningProcess := $partmanufacturer/warningProcess/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Supplier_Attribute@warningProcess", $warningProcess, $manufValidationMap)


            (:==================================================================
            DROP 2 ATTRIBUTE ENDED
            ====================================================================:)
                  
              let $_ := 
                        if(fn:count(map:keys($manufValidationMap)) gt 0) 
                        then
                            let $index := (xdmp:set($index, $index + 1), $index)
                            let $valIdentifier := "1." || $index || " Parts Manufacturer - (" || $ManufacturerShortName || ")&#13;-----------------------------------------------------------"
                            return map:put($finalMap, $valIdentifier, $manufValidationMap)
                        else ()  
                          
              return  ((:$document/*:instance/*:Orchestra,:)$manufValidationMap)
      else ()
};


declare function ValidationStep2:V_partCustomer($document as node(),$finalMap as map:map){

  let $doc := $document/*:instance/*:Orchestra
  let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
  let $partCustomers := $document/*:instance/*:Orchestra/partcustomers/partcustomer
  let $index := 0 
  let $clampPartNum := ""

	return 
		if(fn:exists($partCustomers)) then (	
     for $partCustomer in $partCustomers
     let $partCustomerValValidationMap := map:new(())

      let $clampCustomerName :=  $partCustomer/clampCustomer/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@clampCustomerName", $clampCustomerName, $partCustomerValValidationMap)
      
      let $customerPartNum :=  $partCustomer/customerPartNumber/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampCustomerPartNumber", $customerPartNum, $partCustomerValValidationMap)
      
      let $customerPartDesc := $partCustomer/CustomerPartDescription/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@ClampCustomerPartDescription", $customerPartDesc, $partCustomerValValidationMap)

      let $customerPartRev := $partCustomer/customerPartRevision/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@customerPartRev", $customerPartRev, $partCustomerValValidationMap) (:$clampcustomerRev ==> $customerPartRev:)

      let $clampPartNum := (xdmp:set($clampPartNum, ""), $clampPartNum)

      let $_ := 
              if(fn:count(map:keys($partCustomerValValidationMap)) gt 0) 
              then              
                let $index := (xdmp:set($index, $index + 1), $index)
                let $valIdentifier := "3." || $index || " Parts Customer - (" || $clampPartNum||$customerPartNum || " - " ||  $clampCustomerName || " )&#13;-----------------------------------------------------------"
                return map:put($finalMap, $valIdentifier, $partCustomerValValidationMap)
              else ()		 
         
             return  ((:$document/*:instance/*:Orchestra,:)$partCustomerValValidationMap)
            )
      else ()
};

declare function ValidationStep2:V_partComposed($document as node(),$finalMap as map:map){

  let $doc := $document/*:instance/*:Orchestra
  let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
  let $partcompositions := $document/*:instance/*:Orchestra/partcompositions/partcomposition
  let $index := 0 

  return 
	  if(fn:exists($partcompositions)) then (
      for $partcomposition in $partcompositions
        let $composedByValidationMap := map:new(())
        let $composedPartNum :=$partcomposition/partNumber/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"ComposeKits_Attribute@ComposedPartNumber", $composedPartNum, $composedByValidationMap)

        let $shortdesc := $partcomposition/shortDesc/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"ComposeKits_Attribute@j5_DesignationAS400EN", $shortdesc, $composedByValidationMap)

        let $Quantity := $partcomposition/quantity/string()
        let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"ComposeKits_Attribute@Quantity", $Quantity, $composedByValidationMap)

        (:Composite Primary Key: concatenation of Part Number, Composed Part Number :)
      (:let $compositePrimaryKey :=  $PartNumber || "_" || $composedPartNum
      let $compositePrimaryKey := partcomposedbytranformation:getEncryptedString($compositePrimaryKey):)

        let $_ := 
          if(fn:count(map:keys($composedByValidationMap)) gt 0) then              
            let $index := (xdmp:set($index, $index + 1), $index)
            let $valIdentifier := "4." || $index || " Part Composed By - (" || $composedPartNum || ")&#13;-----------------------------------------------------------"
            return map:put($finalMap, $valIdentifier, $composedByValidationMap)
          else ()
		 
         
             return  ((:$document/*:instance/*:Orchestra,:)$composedByValidationMap)
            )
      else ()
};


declare function ValidationStep2:V_partFamily($document as node(),$finalMap as map:map){

  let $doc := $document/*:instance/*:Orchestra
  let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
  let $familyAttributes := $document/*:instance/*:Orchestra/familyAttributes/familyAttribute
  let $index := 0 


	return 
		if(fn:exists($familyAttributes)) then (	
     for $familyAttribute in $familyAttributes
     let $familyAttrValValidationMap := map:new(())

            let $AttrId_ := fn:substring-after($familyAttribute/attribute/string()," ")
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"FamilyAttrVal_Attribute@AttrId", $AttrId_, $familyAttrValValidationMap)
            let $AttrValue := $familyAttribute/Value/string()
            let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"FamilyAttrVal_Attribute@AttrValue", $AttrValue, $familyAttrValValidationMap)
            (:let $SysUnit := familyattributevaluetranformation:getSysUnit($result, $AttrId_)
            let $validationResult := partvalidation:createDataQualityAndMigrationComments("FamilyAttrVal_Attribute@SysUnit", $SysUnit, $familyAttrValValidationMap)
            :)
            let $familyId := fn:substring-before($familyAttribute/attribute/string()," ")
            
            let $AttrId := $familyId||" " || $AttrId_

            let $_ := 
                        if(fn:count(map:keys($familyAttrValValidationMap)) gt 0) then              
                          let $index := (xdmp:set($index, $index + 1), $index)
                          let $valIdentifier := "2." || $index || " Family Attribute Value - (" || $familyId || " - " || $AttrId_  || ")&#13;-----------------------------------------------------------"
                          return map:put($finalMap, $valIdentifier, $familyAttrValValidationMap)
                        else ()		 
         
             return  ((:$document/*:instance/*:Orchestra,:)$familyAttrValValidationMap)
            )
      else ()
};

declare function ValidationStep2:V_partUnit($document as node(),$finalMap as map:map){

  let $doc := $document/*:instance/*:Orchestra
  let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
  let $units := $document/*:instance/*:Orchestra/units/unit
  let $index := 0 
  
    return 
        if(fn:exists($units)) then (    
     for $unit in $units
      let $UnitValidationMap := map:new(())
      let $PartNumber := $unit/partnumber/string()
      let $unitcode := $unit/unitcode/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@unitcode", $unitcode, $UnitValidationMap)
      
      let $legacycode := $unit/legacycode/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@legacycode", $legacycode, $UnitValidationMap)
      let $_ := 
              if(fn:count(map:keys($UnitValidationMap)) gt 0) 
              then              
                let $index := (xdmp:set($index, $index + 1), $index)
                let $valIdentifier := "7." || $index || " Using Units - (" ||$PartNumber|| " - "  ||$unitcode || ")&#13;-----------------------------------------------------------"
                return map:put($finalMap, $valIdentifier, $UnitValidationMap)
              else ()         
         
             return  ((:$document/*:instance/*:Orchestra,:)$UnitValidationMap)
            )
      else ()
};

declare function ValidationStep2:V_partProject($document as node(),$finalMap as map:map){

  let $doc := $document/*:instance/*:Orchestra
  let $source := $document/*:instance/*:Orchestra/part/systemMaster/string()
  let $Projects := $document/*:instance/*:Orchestra/PROJECTS/PROJECT
  let $index := 0 
  
    return 
        if(fn:exists($Projects)) then (    
     for $Project in $Projects
      let $projectforpartsValidationMap := map:new(())
      let $PartNumber := $Project/partnumber/string()
      let $projectId := $Project/projectId/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@projectId", $projectId, $projectforpartsValidationMap)
      
      let $originate := $Project/originate/string()
      let $validationResult := partvalidation:createDataQualityAndMigrationComments($source,"Attribute@originate", $originate, $projectforpartsValidationMap)
      let $_ := 
              if(fn:count(map:keys($projectforpartsValidationMap)) gt 0) 
              then              
                let $index := (xdmp:set($index, $index + 1), $index)
                let $valIdentifier := "8." || $index || " project for parts - (" ||$PartNumber|| " - "  ||$projectId || ")&#13;-----------------------------------------------------------"
                return map:put($finalMap, $valIdentifier, $projectforpartsValidationMap)
              else ()         
         
             return  ((:$document/*:instance/*:Orchestra,:)$projectforpartsValidationMap)
            )
      else ()
};