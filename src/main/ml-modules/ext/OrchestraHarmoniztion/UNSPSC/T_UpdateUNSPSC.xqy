xquery version "1.0-ml";
declare variable $FINAL_DB := "smart-data-hub-FINAL";
declare variable $URI external;

let $partswrongunspsc :=
for $uri in $URI
let $res :=
for $search in cts:search(fn:collection("/sources/CLAMP/BatchLoad"),
cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value","=",$uri)
)
let $revision := $search/CLAMPPart/Attribute[@CLAMP_ID="Revision"]/Value/string()
let $Sequence := $search/CLAMPPart/Attribute[@CLAMP_ID="Sequence"]/Value/string()
let $TIMESTAMP := $search/CLAMPPart/Attribute[@CLAMP_ID="TIMESTAMP"]/Value/string()
order by $revision descending, xs:int($Sequence) descending, $TIMESTAMP descending
return $search
return if ($res[1]/CLAMPPart/Attribute[@CLAMP_ID="j5_UNSPSC"]/Value/string() eq "####") then
$res[1]/CLAMPPart/Attribute[@CLAMP_ID='PartNumber'][1]/Value/text()
else ()

for $partwrongunspsc in $partswrongunspsc

return 
xdmp:invoke-function
(
function() {
let $nodereplace := 
cts:search(fn:collection("Orchestra"),
cts:element-value-query(xs:QName("partNumber"),$partwrongunspsc)
)
return (xdmp:node-replace($nodereplace/*:envelope/*:instance/*:Orchestra/part/unspsc,
	<unspsc>####</unspsc>),xdmp:commit())
},
							<options xmlns="xdmp:eval">
                            <database>{xdmp:database($FINAL_DB)}</database>
                            </options>
)