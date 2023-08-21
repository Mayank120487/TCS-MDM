xquery version "1.0-ml";
declare namespace createexcel = "http://marklogic.com/createexcel";
declare namespace xls = "urn:schemas-microsoft-com:office:spreadsheet";
declare namespace o = "urn:schemas-microsoft-com:office:office";
declare namespace x = "urn:schemas-microsoft-com:office:excel";
declare namespace ss = "urn:schemas-microsoft-com:office:spreadsheet";
declare option xdmp:mapping "false";
declare variable $nmsp := fn:namespace-uri(<xls:x/>);
declare variable $definationFile := "/orchestra_transformation/definition.xml";
declare variable $excelUri external;
declare variable $Batch external;
(:declare variable $excelIdentifier external;:)
declare variable $excelIdentifier external;
(:declare variable $excelIdentifier_parts external;
declare variable $excelIdentifier_familyattributevalue external;
declare variable $excelIdentifier_familyclassificationlink external;
declare variable $excelIdentifier_partcomposedby external;
declare variable $excelIdentifier_partscustomer external;
declare variable $excelIdentifier_partsmanufacturer external;
:)
declare function createexcel:wrapCData($valStr as xs:string){
    "<![CDATA["||$valStr||"]>"
};

declare function createexcel:wrap-xls-header($tableXml){
    <?mso-application progid="Excel.Sheet"?>,
    <Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:x="urn:schemas-microsoft-com:office:excel"
    xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
    xmlns:html="http://www.w3.org/TR/REC-html40">
    <Worksheet ss:Name="Sheet1">{$tableXml}</Worksheet>
    </Workbook>
};

declare function createexcel:generateXMLElement($valStr as xs:string?) {
    element {fn:QName($nmsp, "Cell")} {
        element {fn:QName($nmsp, "Data")} {
            attribute{"ss:Type"}{"String"}, text{createexcel:replaceForbiddenChars($valStr)}
        }
    }
};

declare function createexcel:addHeaderRow($valHeaders as xs:string*){
  let $rows := 
    for $header in $valHeaders
    return createexcel:generateXMLElement($header)
  return element {fn:QName($nmsp, "Row")}{$rows}
   
};

declare function createexcel:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
      ""
    else 
      let $retVal := fn:replace($valStr,"&amp;","&amp;")
      let $retVal := fn:replace($retVal,"<","&lt;")
      let $retVal := fn:replace($retVal,">","&gt;")
    return $retVal
};

declare function createexcel:checkAndCreateExcel($excelUri as xs:string, $valHeaders as xs:string*) {
    let $excelExist := fn:exists(fn:doc($excelUri))
    let $res := 
        if($excelExist) then ()
        else (
            let $tableXml := element {fn:QName($nmsp, "Table")}{createexcel:addHeaderRow($valHeaders)}
            return
            xdmp:invoke-function(
                function() { xdmp:document-insert($excelUri, document{createexcel:wrap-xls-header($tableXml)}, map:map() => map:with("collections", ("/w2_clamp_migration/ANOOP"))) },
                <options xmlns="xdmp:eval">
                    <update>auto</update>
                    <commit>auto</commit>
                </options>)
        )
    return fn:true()            
};

let $exist := if ($excelIdentifier = "parts") 
                    then (
                            let $strHeader_parts := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_parts := fn:tokenize($strHeader_parts, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"parts/parts.xml", $lstHeader_parts)
                    )

                else if ($excelIdentifier = "familyattributevalue") 
                    then (
                            let $strHeader_familyattributevalue := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_familyattributevalue := fn:tokenize($strHeader_familyattributevalue, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"familyattributevalue/familyattributevalue.xml", $lstHeader_familyattributevalue)
                    )

                else if ($excelIdentifier = "familyclassificationlink") 
                    then (
                            let $strHeader_familyclassificationlink := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_familyclassificationlink := fn:tokenize($strHeader_familyclassificationlink, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"familyclassificationlink/familyclassificationlink.xml", $lstHeader_familyclassificationlink)
                    )

                else if ($excelIdentifier = "partcomposedby") 
                    then (
                            let $strHeader_partcomposedby := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_partcomposedby := fn:tokenize($strHeader_partcomposedby, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"partcomposedby/partcomposedby.xml", $lstHeader_partcomposedby)
                    )

                else if ($excelIdentifier = "partscustomer") 
                    then (
                            let $strHeader_partscustomer := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_partscustomer := fn:tokenize($strHeader_partscustomer, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"partscustomer/partscustomer.xml", $lstHeader_partscustomer)
                    )

                else if ($excelIdentifier = "partsmanufacturer") 
                    then (
                            let $strHeader_partsmanufacturer := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_partsmanufacturer := fn:tokenize($strHeader_partsmanufacturer, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"partsmanufacturer/partsmanufacturer.xml", $lstHeader_partsmanufacturer)
                    )

                else if ($excelIdentifier = "partunits") 
                    then (
                            let $strHeader_partunits := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_partunits := fn:tokenize($strHeader_partunits, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"units/units.xml", $lstHeader_partunits)
                    )
                
                else if ($excelIdentifier = "projectforparts") 
                    then (
                            let $strHeader_projectforparts := fn:doc($definationFile)/config/migrationsheets/migrationsheet[@Identifier=$excelIdentifier]/@Excel-Headers/fn:data()
                            let $lstHeader_projectforparts := fn:tokenize($strHeader_projectforparts, ",")
                            return createexcel:checkAndCreateExcel($excelUri||$Batch||"/"||"PROJECTS/PROJECTS.xml", $lstHeader_projectforparts)
                    )

                else ()


return 
    ($exist)
