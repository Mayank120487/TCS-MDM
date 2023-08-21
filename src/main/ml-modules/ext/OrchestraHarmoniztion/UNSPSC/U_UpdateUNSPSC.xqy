xquery version "1.0-ml";
declare variable $FINAL_DB := "smart-data-hub-FINAL";

let $step2parts :=
(xdmp:invoke-function
(
function() {
cts:search(fn:collection("Orchestra"),
cts:and-query((
cts:element-value-query(xs:QName("systemMaster"),"CLAMP"),
cts:element-value-query(xs:QName("unspsc"),"")
))
)//Orchestra/part/partNumber/text()
},
							<options xmlns="xdmp:eval">
                            <database>{xdmp:database($FINAL_DB)}</database>
                            </options>
)
)
return (fn:count($step2parts), $step2parts)