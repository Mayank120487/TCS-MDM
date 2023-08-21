xquery version "1.0-ml";

declare namespace xls = "urn:schemas-microsoft-com:office:spreadsheet";
declare variable $excelUri external;
(:declare variable $collectionName external;:)

declare variable $collectionName_parts  external;
declare variable $collectionName_partsmanufacturer external;
declare variable $collectionName_partcomposedby external;
declare variable $collectionName_partcustomer external;
declare variable $collectionName_familyparts external;
declare variable $collectionName_familyclassification external;

(:let $rows := fn:collection($collectionName)/DATA/xls:Row:)

let $rows_parts := fn:collection($collectionName_parts)/DATA/*:Row
let $rows_partsmanufacturer := fn:collection($collectionName_partsmanufacturer)/DATA/*:Row
let $rows_partcomposedby := fn:collection($collectionName_partcomposedby)/DATA/*:Row
let $rows_partcustomer := fn:collection($collectionName_partcustomer)/DATA/*:Row
let $rows_familyparts := fn:collection($collectionName_familyparts)[1 to 400000]/DATA/*:Row
let $rows_familyclassification := fn:collection($collectionName_familyclassification)/DATA/*:Row
let $rows_projectforparts := fn:collection($collectionName_projectforparts)/DATA/*:Row

return
    ( 
        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"parts/parts.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_parts)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        ),

        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"partsmanufacturer/partsmanufacturer.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_partsmanufacturer)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        ),

        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"partcomposedby/partcomposedby.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_partcomposedby)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        ),

        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"partscustomer/partscustomer.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_partcustomer)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        ),

        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"familyattributevalue/familyattributevalue.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_familyparts)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        )
        ,

        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"familyclassificationlink/familyclassificationlink.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_familyclassification)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        ),

        xdmp:invoke-function(
            function() {
                xdmp:node-insert-child(doc($excelUri||"projectforparts/projectforparts.xml")/xls:Workbook/xls:Worksheet/xls:Table, $rows_projectforparts)
            },
            <options xmlns="xdmp:eval">
                <update>auto</update>
                <commit>auto</commit>
            </options>
        )
        
    )