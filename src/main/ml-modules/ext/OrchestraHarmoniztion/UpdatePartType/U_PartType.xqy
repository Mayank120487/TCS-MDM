xquery version "1.0-ml";

declare variable $FINAL_DB := "smart-data-hub-FINAL";




let $PartNumbers := (xdmp:invoke-function(
                            function() {
				cts:search(fn:doc(),cts:and-query((cts:collection-query("Orchestra"),
				cts:element-value-query(xs:QName("partTp"),"Part to Specification (CoS)"),
				cts:element-value-query(xs:QName("source"),"CLAMP"))))//part/partNumber/string()
										},
							<options xmlns="xdmp:eval">
                            <database>{xdmp:database($FINAL_DB)}</database>
                            </options>)
					)
					
					return (fn:count($PartNumbers),$PartNumbers)