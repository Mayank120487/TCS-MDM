xquery version "1.0-ml";
module namespace partcustomertranformation = "partcustomertranformation";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";


declare function partcustomertranformation:replaceForbiddenChars($valStr as xs:string?) as xs:string {
 if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};

declare function partcustomertranformation:getCustId($custname){
	let $search := cts:search(fn:collection("/orchestra_externalcustomers"),cts:element-value-query(xs:QName("Company_Name"),$custname))[1]/root/Customer_ID/text()
	return $search
};

declare function partcustomertranformation:replaceDoubleDashWithBlank($valStr as xs:string?) as xs:string { (:newly added:)
  if(fn:empty($valStr)) then
    ""
  else if($valStr = "--") then
    ""
  else
    $valStr
  };																														   

(:======================================================================================================:)

declare function partcustomertranformation:process($uri, $finalMap as map:map) {
	let $result := fn:doc($uri)/CLAMPPart
	let $partNumber :=$result/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
	let $partCustomers := $result/Customers/Customer
  let $customerPartNum := ""
  let $customerPartDesc := ""
  let $customerPartRev := ""
  let $clampCustomerName := ""
  let $clampPartNum := ""
  let $clampPartDesc := ""
  let $clampPartRev := ""

  let $index := 0 

	return 
		if(fn:empty($partCustomers)) then(<partcustomers></partcustomers>)
		else(<partcustomers>{
			for $partCustomer in $partCustomers
        let $partCustomerValValidationMap := map:new(())

		let $clampCustomerName :=  $partCustomer/Attribute[@CLAMP_ID="j5_NomClient"]/Value/text()
    (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Attribute@clampCustomerName", $clampCustomerName, $partCustomerValValidationMap):)
		let $customerID :=  partcustomertranformation:getCustId($clampCustomerName)
		return 
          if(fn:empty($customerID) or $customerID eq "") then 
            let $clampCustomerName := (xdmp:set($clampCustomerName, ""), $clampCustomerName)
            return()
        	else 
			let $customerPartNum :=  (xdmp:set($customerPartNum, $partCustomer/Attribute[@CLAMP_ID="j5_RefArtClient"]/Value/text()), $customerPartNum)
      (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Attribute@ClampCustomerPartNumber", $customerPartNum, $partCustomerValValidationMap):)

			let $customerPartDesc := (xdmp:set($customerPartDesc, $partCustomer/Attribute[@CLAMP_ID="j5_DesignationRefClient"]/Value/text()), $customerPartDesc)
      let $customerPartDesc := partcustomertranformation:replaceDoubleDashWithBlank($customerPartDesc)
     (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Attribute@ClampCustomerPartDescription", $customerPartDesc, $partCustomerValValidationMap):)

			let $customerPartRev := (xdmp:set($customerPartRev, $partCustomer/Attribute[@CLAMP_ID="j5_IndiceArtClient"]/Value/text()), $customerPartRev)
		  (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("Attribute@customerPartRev", $customerPartRev, $partCustomerValValidationMap) (:$clampcustomerRev ==> $customerPartRev:):)
            
            let $clampCustomerName := (xdmp:set($clampCustomerName, ""), $clampCustomerName)
						let $clampPartNum := (xdmp:set($clampPartNum, ""), $clampPartNum)
						let $clampPartDesc := (xdmp:set($clampPartDesc, ""), $clampPartDesc)
						let $clampPartRev := (xdmp:set($clampPartRev, ""), $clampPartRev)

            let $compositePrimaryKey := $partNumber || "_" || $customerID || "_" || $customerPartNum
            let $compositePrimaryKey := fn:replace($compositePrimaryKey, " ", "_")

            let $_ := 
              if(fn:count(map:keys($partCustomerValValidationMap)) gt 0) then              
                let $index := (xdmp:set($index, $index + 1), $index)
                let $valIdentifier := "3." || $index || " Parts Customer - (" || $clampPartNum||$customerPartNum || " - " ||  $clampCustomerName || " )&#13;-----------------------------------------------------------"
                return map:put($finalMap, $valIdentifier, $partCustomerValValidationMap)
              else ()	
              
              (: 30-29-2021 Passing "clampPartRev" instead of "customerPartRev"  :)				
			      return 
				        
           <partcustomer>
            <partCustomerId>{$compositePrimaryKey}</partCustomerId>
            <partNumber>{$partNumber}</partNumber>
            <customer>{$customerID}</customer>
            <customerPartNumber>{$customerPartNum}</customerPartNumber>
            <CustomerPartDescription>{$customerPartDesc}</CustomerPartDescription>
            <customerPartRevision>{$customerPartRev}</customerPartRevision>
			      <clampCustomer>{$clampCustomerName}</clampCustomer>
            <clampCustomerPartNumber>{$clampPartNum}</clampCustomerPartNumber>
            <clampCustomerPartDescription>{$clampPartDesc}</clampCustomerPartDescription>
            <clampCustomerPartRevision>{$clampPartRev}</clampCustomerPartRevision>
          </partcustomer>}
          </partcustomers>,$finalMap)
           
 };