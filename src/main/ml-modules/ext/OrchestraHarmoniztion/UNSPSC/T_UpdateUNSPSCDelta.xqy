xquery version "1.0-ml";
declare variable $URI external;
declare variable $FINAL_DB := "smart-data-hub-FINAL";
  

 

let $partswrongunspsc := 
		for $partNumber in $URI
				let $res :=
					for $search in cts:search(fn:doc(),cts:and-query((cts:or-query((
                                         cts:and-query(((cts:collection-query("/sources/CLAMP"),
                                         cts:or-query((cts:collection-query(cts:collection-match("2021-12-06*")),
                                                       cts:collection-query(cts:collection-match("2021-12-07*")),
                                                       cts:collection-query(cts:collection-match("2021-12-08*")),
                                                       cts:collection-query(cts:collection-match("2021-12-09*")),
                                                       cts:collection-query(cts:collection-match("2021-12-10*")),
                                                       cts:collection-query(cts:collection-match("2021-12-11*")),
                                                       cts:collection-query(cts:collection-match("2021-12-12*")),
                                                       cts:collection-query(cts:collection-match("2021-12-13*")),
                                                       cts:collection-query(cts:collection-match("2021-12-14*")),
                                                       cts:collection-query(cts:collection-match("2021-12-15*")),
                                                       cts:collection-query(cts:collection-match("2021-12-16*")),
                                                       cts:collection-query(cts:collection-match("2021-12-17*")),
                                                       cts:collection-query(cts:collection-match("2021-12-18*")),
                                                       cts:collection-query(cts:collection-match("2021-12-19*")),
                                                       cts:collection-query(cts:collection-match("2021-12-20*")),
                                                       cts:collection-query(cts:collection-match("2021-12-21*")),
                                                       cts:collection-query(cts:collection-match("2021-12-22*")),
                                                       cts:collection-query(cts:collection-match("2021-12-23*")),
													   cts:collection-query(cts:collection-match("2021-12-24*")),
													   cts:collection-query(cts:collection-match("2021-12-25*")),
													   cts:collection-query(cts:collection-match("2021-12-26*")),
													   cts:collection-query(cts:collection-match("2021-12-27*")),
													   cts:collection-query(cts:collection-match("2021-12-28*")),
													   cts:collection-query(cts:collection-match("2021-12-29*")),
													   cts:collection-query(cts:collection-match("2021-12-30*")),
													   cts:collection-query(cts:collection-match("2021-12-31*")),
													   cts:collection-query(cts:collection-match("2022-01-*"))
													   
                                                     ))
)))
)),
cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value","=",$partNumber)
))
)
let $revision := $search/CLAMPPart/Attribute[@CLAMP_ID="Revision"]/Value/string()
let $Sequence := $search/CLAMPPart/Attribute[@CLAMP_ID="Sequence"]/Value/string()
let $TIMESTAMP := $search/CLAMPPart/Attribute[@CLAMP_ID="TIMESTAMP"]/Value/string()
order by $revision descending,xs:int($Sequence) descending ,$TIMESTAMP descending
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

