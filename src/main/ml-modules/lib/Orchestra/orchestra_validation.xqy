xquery version "1.0-ml";
module namespace partvalidation = "partvalidation";
declare namespace xls = "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace o = "urn:schemas-microsoft-com:office:office";
declare namespace x = "urn:schemas-microsoft-com:office:excel";
declare namespace ss = "urn:schemas-microsoft-com:office:spreadsheet";
declare option xdmp:mapping "false"; 
declare variable $nmsp := fn:namespace-uri(<xls:x/>);
declare variable $LENGTH := "Length (##) is Incorrect. Defined Length %%";
declare variable $MAXLENGTH := "Length (##) Exceeded defined MaxLength %%";
declare variable $MINLENGTH := "Length (##) Less than defined MinLength %%";
declare variable $MANDATORY := "Missing Mandatory field";
declare variable $ALLOWED := "Value(s) [##] not allowed";
declare variable $FORMAT := "Incorrect Format, expected format - ##";
declare variable $TYPE := "Invalid character(s), expected type - ##";
declare variable $VALID_CHARACTERS := "Invalid character(s) [##]";
declare variable $OVERALL_VALIDATION_HEADER := "Overall Validation Message";
declare variable $ALL_VALIDATIONS := ($LENGTH, $MAXLENGTH, $MINLENGTH, $MANDATORY, $ALLOWED, $FORMAT, $TYPE);
declare variable $definationFile := "/orchestra_transformation/definition.xml";

declare function partvalidation:trim($arg as xs:string?)  as xs:string {
   replace(replace($arg,'\s+$',''),'^\s+','')
} ;

declare function partvalidation:sort($arg as item()*) as item()*{
    for $item in $arg
    order by $item
    return $item
};

declare function partvalidation:validate-max-length($value, $def as element(validation)) as map:map? {
   let $max-length := $def/@MaxLength/fn:data()
   return
        if(fn:not(fn:empty($value))) then
            if (fn:string-length($max-length) gt 0) then
                if (fn:string-length($value) le $max-length) then () 
                else  
                    map:entry(fn:replace($MAXLENGTH, "##", fn:string(fn:string-length($value))) ! fn:replace(., "%%", fn:string($max-length)), $value)
            else ()
        else ()
};

declare function partvalidation:validate-min-length($value, $def as element(validation)) as map:map? {
   let $min-length := $def/@MinLength/fn:data()
    return
        if(fn:not(fn:empty($value))) then
            if (fn:string-length($min-length) gt 0) then
                if (fn:string-length($value) ge $min-length) then () 
                else 
                   map:entry(fn:replace($MINLENGTH, "##", fn:string(fn:string-length($value))) ! fn:replace(., "%%", fn:string($min-length)), $value)
            else ()
        else ()
};

declare function partvalidation:validate-mandatory($value, $def as element(validation)) as map:map? {
    let $mandatory := fn:boolean((fn:lower-case($def/@Mandatory/fn:data()) eq "yes") or (fn:lower-case($def/@Mandatory/fn:data()) eq "true"))
    return
        if(fn:not(fn:empty($mandatory)) and fn:exists($mandatory)) then
            if ($mandatory) then
                if (fn:not(fn:exists($value))) then
                    map:entry($MANDATORY, "<<missing>>")
                else if(partvalidation:trim($value) = "") then
                   map:entry($MANDATORY, "<<missing>>")
                else ()   
            else()
        else ()
};

declare function partvalidation:validate-allowed-values($value, $def as element(validation)) as map:map? {
    let $allowed-values-attr := $def/@Allowed-Values/fn:data()
    let $allowed-values := fn:tokenize($allowed-values-attr, ',') ! replace(replace(.,'\s+$',''),'^\s+','') ! fn:lower-case(.)
    let $mandatory_ := fn:boolean((fn:lower-case($def/@Mandatory/fn:data()) eq "yes") or (fn:lower-case($def/@Mandatory/fn:data()) eq "true"))
    let $mandatory :=
        if(fn:empty($mandatory_) and fn:not(fn:exists($mandatory_))) then
            fn:false()
        else
           $mandatory_   
    return
        if(fn:not(fn:empty($value))) then
            if(fn:exists($allowed-values-attr)) then
                if (fn:lower-case($value) = $allowed-values) then ()
                else if($value eq "" and $mandatory eq fn:false()) then ()
                else map:entry(fn:replace($ALLOWED, "##", $value), $value)
            else ()
        else()
};

declare function partvalidation:getInvalidCharacters($value, $def as element(validation)) as xs:string*{
    let $valid-characters := $def/@Valid-Characters/fn:data()
    (:let $value := xdmp:quote($value):)
    return
        if(fn:exists($valid-characters)) then
            let $lstValueChars := partvalidation:getCharsFromString($value)          
            let $lstValidChars := partvalidation:getCharsFromString($valid-characters)
            for $valueChar in $lstValueChars
            return
                if (fn:not(fn:exists(index-of($lstValidChars, $valueChar)))) then
                    $valueChar
                else()           
        else ()  
};

declare function partvalidation:getCharsFromString($arg as xs:string? ) as xs:string* {
   for $ch in fn:string-to-codepoints($arg)
   return fn:codepoints-to-string($ch)
} ;

declare function partvalidation:validate-characters($value, $def as element(validation)) as map:map? {
    let $invalidChars := partvalidation:getInvalidCharacters($value, $def)
    return
        if(fn:not(fn:empty($invalidChars))) then
            map:entry(fn:replace($VALID_CHARACTERS, "##", fn:string-join($invalidChars, ",")), $value)          
        else()    
};

(:declare function partvalidation:validate-format($value, $def as element(validation)) as map:map? {
    let $format := $def/@Format/fn:data()
    return
        switch($format)
            case 'URL' return
                if (fn:matches($value, '(http://|https://)([a-z0-9])((\.[a-z0-9-])|([a-z0-9-]))*')) then ()                    
                else
                    map:entry(fn:replace($FORMAT, "##", $format), $value)
            case 'AANN' return
                if (fn:matches($value, '[a-zA-Z]?[a-zA-Z]?\d?\d?')) then ()
                else  
                    map:entry(fn:replace($FORMAT, "##", $format), $value)
            case '[M01]/[D01]/[Y0001]' return
                try {
                    xdmp:parse-dateTime("[M01]/[D01]/[Y0001]", $value)
                } catch($_) {
                     map:entry(fn:replace($FORMAT, "##", $format), $value)
                }
            case 'YYMMXXXX' return ()
            case () return ()
                default return 
                    fn:error(xs:QName("ERROR"), "unknown format: " || $format)
}; :)

declare function partvalidation:validate-format($value, $def as element(validation)) as map:map?  {

    let $format := $def/@Format/fn:data()
    let $mandatory_ := fn:boolean((fn:lower-case($def/@Mandatory/fn:data()) eq "yes") or (fn:lower-case($def/@Mandatory/fn:data()) eq "true"))
    let $mandatory :=
        if(fn:empty($mandatory_) and fn:not(fn:exists($mandatory_))) then
            fn:false()
        else
           $mandatory_
    let $isToCheck :=
        if($mandatory = fn:true()) then fn:true()
        else if(fn:empty($value) or fn:not(fn:exists($value)) or $value eq "") then fn:false()
        else fn:true()
   
   return 
        if($isToCheck) then
            switch($format)
            case 'URL' return
                if (fn:matches($value, '(http://|https://)([a-z0-9])((\.[a-z0-9-])|([a-z0-9-]))*')) then ()                    
                else
                    map:entry(fn:replace($FORMAT, "##", $format), $value)
            case 'AANN' return
                if((fn:string-length($value) eq xs:int("1")) and (fn:matches($value, '^[A-Z0-9]{1}') )) then ()
                else if((fn:string-length($value) eq xs:int("2")) and (fn:matches($value, '^[A-Z]{1}[A-Z0-9]{1}$') or fn:matches($value, '^[0-9]{2}$'))) then ()
                else if((fn:string-length($value) eq xs:int("3")) and ( fn:matches($value, '^[0-9]{2}$') or fn:matches($value, '^[A-Z]{2}[0-9]{1}$') or fn:matches($value, '^[A-Z]{1}[0-9]{2}$'))) then ()
                else if ((fn:string-length($value) eq xs:int("4")) and ( fn:matches($value, '^[0-9]{2}$')  or fn:matches($value, '^[A-Z]{2}[0-9]{2}$') )) then ()
                else  
                    map:entry(fn:replace($FORMAT, "##", $format), $value)
            case '[M01]/[D01]/[Y0001]' return
                try {
                    xdmp:parse-dateTime("[M01]/[D01]/[Y0001]", $value)
                } catch($_) {
                     map:entry(fn:replace($FORMAT, "##", $format), $value)
                }
            case 'YYMMXXXX' return ("")
            case () return ()
                default return 
                    fn:error(xs:QName("ERROR"), "unknown format: " || $format)
                    
       else ()
      
};


(:declare function partvalidation:validate-type($value, $def as element(validation)) as map:map? {    
    let $type := $def/@Type/fn:data()
    return if(fn:not(fn:empty($type))) then
        let $type := fn:lower-case($type)
        return switch($type)
            case 'alphanumeric' return
                if (fn:matches($value, '^[a-zA-Z0-9]+$')) then ()
                else 
                    map:entry(fn:replace($TYPE, "##", $type), $value)
            case 'numeric' return
                if (fn:matches($value, '^[0-9]+$')) then ()
                else 
                    map:entry(fn:replace($TYPE, "##", $type), $value)
            case 'alphabetic' return
                if (fn:matches($value, '^[a-zA-Z]+$')) then ()
                else 
                    map:entry(fn:replace($TYPE, "##", $type), $value)
            case 'float' return 
                if (fn:matches($value, '^[0-9]\d{0,9}(\.\d*)?%?$')) then ()
                else 
                    map:entry(fn:replace($TYPE, "##", $type), $value)
            case () return ()
            default return 
                fn:error(xs:QName("ERROR"), "unknown type: " || $type)
    else ()
}; :)

declare function partvalidation:validate-type($value, $def as element(validation)) as map:map? {  
    let $type := $def/@Type/fn:data()
    let $value := partvalidation:trim($value)
    let $mandatory_ := fn:boolean((fn:lower-case($def/@Mandatory/fn:data()) eq "yes") or (fn:lower-case($def/@Mandatory/fn:data()) eq "true"))
    let $mandatory :=
        if(fn:empty($mandatory_) and fn:not(fn:exists($mandatory_))) then
            fn:false()
        else
           $mandatory_
    let $isToCheck :=
        if($mandatory_ = fn:true()) then fn:true()
        else if(fn:empty($value) or fn:not(fn:exists($value)) or $value eq "") then fn:false()
        else fn:true()
   
   return 
        if($isToCheck) then
            if(fn:not(fn:empty($type))) then
                let $type := fn:lower-case($type)
                return switch($type)
                    case 'alphanumeric' return
                        if (fn:matches($value, '^[a-zA-Z0-9]+$')) then ()
                        else 
                            map:entry(fn:replace($TYPE, "##", $type), $value)
                    case 'numeric' return
                        if (fn:matches($value, '^[0-9]+$')) then ()
                        else 
                            map:entry(fn:replace($TYPE, "##", $type), $value)
                    case 'alphabetic' return
                        if (fn:matches($value, '^[a-zA-Z]+$')) then ()
                        else 
                            map:entry(fn:replace($TYPE, "##", $type), $value)
                    case 'float' return 
                        if (fn:matches($value, '^[0-9]\d{0,9}(\.\d*)?%?$')) then ()
                        else 
                            map:entry(fn:replace($TYPE, "##", $type), $value)
                    case () return ()
                    default return 
                        fn:error(xs:QName("ERROR"), "unknown type: " || $type)
        else ()                
    else ()
};


declare function partvalidation:format-results($results as map:map, $part-id as xs:string, $part-source as xs:string?) as node()* {
    for $display-name-as-key in map:keys($results)
        let $validation := map:get($results, $display-name-as-key)
        let $overallMessage := ""
        let $values := 
            if (fn:count(map:keys($validation)) gt 0) then
                for $validation-type in $ALL_VALIDATIONS
                    return partvalidation:wrapCell(map:get($validation, $validation-type))
            else()
    return
        if(fn:count($values) gt 0) then (
            <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet"> {
                partvalidation:wrapCell($part-id),
                partvalidation:wrapCell($part-source),
                partvalidation:wrapCell($display-name-as-key),
                $values,
                partvalidation:wrapCell(partvalidation:getOverallStatus($results,""))
                }
            </Row>
        ) 
        else 
        ()
};

declare function partvalidation:getOverallStatus($results as map:map?, $overallMessage){
    for $display-name-as-key in map:keys($results)
        let $_tmpMap := map:get($results, $display-name-as-key)
        let $tmpKeys := map:keys($_tmpMap)
        
    return 
        if(fn:exists($tmpKeys)) then
            for $message-key in $tmpKeys
                let $overallMessage := $overallMessage || "&#13;" || $display-name-as-key ||":"|| $message-key
            return $overallMessage 
        else 
          ""
};

declare function partvalidation:wrapCell($str) {
    <Cell xmlns="urn:schemas-microsoft-com:office:spreadsheet"><Data ss:Type="String">{$str}</Data></Cell>
};

declare function partvalidation:wrapCData($valStr as xs:string) {
    "<![CDATA["||$valStr||"]>"
};

declare function partvalidation:wrap-xls-header($xml) {
    <?mso-application progid="Excel.Sheet"?>,
    <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:x="urn:schemas-microsoft-com:office:excel"
    xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:html="http://www.w3.org/TR/REC-html40">
    <Worksheet ss:Name="Parts">{$xml}</Worksheet>
    </Workbook>
};

declare function partvalidation:addHeaderRow() {
    <Row xmlns="urn:schemas-microsoft-com:office:spreadsheet">
        <Cell><Data ss:Type="String">Part</Data></Cell>
        <Cell><Data ss:Type="String">Source</Data></Cell>
        <Cell><Data ss:Type="String">Attribute</Data></Cell> {
            for $val in $ALL_VALIDATIONS 
                return <Cell><Data ss:Type="String">{$val}</Data></Cell>
            }
        <Cell><Data ss:Type="String">Overall Validation Message</Data></Cell> 
    </Row>
};

declare function partvalidation:validate-length($value, $def as element(validation)) as map:map? {
    let $length := $def/@Length/fn:data()
    return
        if (fn:string-length($length) gt 0) then
            if (fn:string-length($value) eq fn:number($length)) then () 
            else 
                map:entry(fn:replace($LENGTH, "##", fn:string(fn:string-length($value))) ! fn:replace(., "%%", fn:string($length)), $value)
        else ()
};

declare function partvalidation:createDataQualityAndMigrationComments($source as xs:string?, $valFieldIdentifier as xs:string, $valAttrValue as xs:string?, $specificFieldValidationMap as map:map) as map:map?{
    let $validation := cts:search (
        fn:doc($definationFile)/config/validation-definition/validation,
        cts:element-attribute-value-query(xs:QName("validation"),xs:QName("FieldIdentifier"), $valFieldIdentifier)
    )[1] (: To ensure 1 configuration is picked up:)
    return 
        if(fn:empty($validation) ) then ()
        else( let $defsource := fn:tokenize($validation/@source/string(),",")
              return if ($source = $defsource)
                     then 
                          (let $display-label := $validation/@DisplayLabel/fn:data()
                          let $validationMap := partvalidation:validate-attr($valAttrValue, $validation)
                          return 
                          if(fn:empty($validationMap)) then ()
                          else 
                              let $lstValidationMessagesAsKeys := map:keys($validationMap)
                              let $paddedSpace := fn:string-join(for $i in 1 to fn:string-length($display-label) return " ","")
                              let $strFormattedMessage := fn:string-join($lstValidationMessagesAsKeys, ("&#13;"||$paddedSpace))       
                              return 
                                  if(fn:empty($strFormattedMessage) or $strFormattedMessage eq "") then ()
                              else
                                  map:put($specificFieldValidationMap,$valFieldIdentifier, fn:concat($display-label, ": ", $strFormattedMessage))
                           )
                        else ()
              )
};

(:
    $fieldIdenfifier = FieldIdentifier value in Defination file
        This is matched to get the required validations
:)

declare function partvalidation:validate-attr($attrVal, $validation as element(validation)) as map:map {     
  map:new((
    partvalidation:validate-mandatory($attrVal, $validation),
    partvalidation:validate-format($attrVal, $validation),
    partvalidation:validate-length($attrVal, $validation),
    partvalidation:validate-max-length($attrVal, $validation),
    partvalidation:validate-min-length($attrVal, $validation),
    partvalidation:validate-allowed-values($attrVal, $validation),
    partvalidation:validate-type($attrVal, $validation),
    partvalidation:validate-characters($attrVal, $validation)
  ))
};

declare function partvalidation:getDataQualityAndValidationMessages($finalValidationMap as map:map) as map:map{
    let $valIdentifierSet_unsorted := map:keys($finalValidationMap)
    let $valIdentifierSet := partvalidation:sort($valIdentifierSet_unsorted)
    let $lstAttibutes := ()
    let $lstValues :=
        for $valIdntfr in  $valIdentifierSet
            let $tempValIdentifierMap_ := map:get($finalValidationMap, $valIdntfr)
            return 
                if(fn:empty($tempValIdentifierMap_)) then ()
                else 
                    let $validationAttributeKeySet_ := map:keys($tempValIdentifierMap_)
                    let $lstAttibutes := (xdmp:set($lstAttibutes, fn:insert-before($lstAttibutes, 1, $validationAttributeKeySet_)), $lstAttibutes)
                    let $lstValidationComemnts := 
                        for $key_ in $validationAttributeKeySet_
                            return map:get($tempValIdentifierMap_, $key_)
                    
        return 
            if(fn:count($lstValidationComemnts) gt 0) then 
                ($valIdntfr || "&#13;" || (fn:string-join($lstValidationComemnts, "&#13;") || "&#13;"))
            else ()    

    let $migrationComments :=  fn:string-join($lstValues, "&#13;") 
    let $lstComplianceStatus := 
        cts:search (fn:doc($definationFile)/config/validation-definition/validation,
            cts:element-attribute-value-query(xs:QName("validation"),xs:QName("FieldIdentifier"), $lstAttibutes)
        )/@ComplianceStatus/fn:data()
            
    let $dataQuality := 
        if("Non Compliant" = $lstComplianceStatus) then
            "Non Compliant"
        else if("Insufficient" = $lstComplianceStatus) then
            "Insufficient"
        else
            "Compliant"
   return map:entry($dataQuality, $migrationComments)  
};

declare function partvalidation:createDataQualityAndMigrationCommentsForListOfValues($source,$identifierString as xs:string, $values as xs:string*, $specificFieldValidationMap as map:map) {
    for $value in $values
      let  $validationResult := partvalidation:createDataQualityAndMigrationComments($source,$identifierString, $value, $specificFieldValidationMap)
    return $validationResult
  };