xquery version "1.0-ml";
declare namespace xls = "urn:schemas-microsoft-com:office:spreadsheet";
declare variable $excelUri external;
declare variable $collectionName external;

let $rows := fn:collection($collectionName)[1 to 20]/DATA/xls:Row

return 
    xdmp:invoke-function(
        function() {
			xdmp:node-insert-child(doc($excelUri)/xls:Workbook/xls:Worksheet/xls:Table, $rows)
		},
        <options xmlns="xdmp:eval">
			<update>auto</update>
            <commit>auto</commit>
        </options>
    )
