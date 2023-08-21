xquery version "1.0-ml";

module namespace search = "http://alstom.com/Search_Queries";
declare namespace es = "http://marklogic.com/entity-services";

declare function search:searchPart($partNumber as xs:string*){

let $search := cts:search(fn:collection("Orchestra"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"), $partNumber),
                                                cts:element-value-query(xs:QName("PartPropogationStatus"), "NotReplicated")
                                                )),(
                                                  cts:index-order(cts:element-reference(xs:QName("revisionLevel")),"descending")
                                                  )
                                                )[1]
let $searchDoc := $search/*:envelope/*:instance/*:Orchestra
return $searchDoc

};

declare function search:searchPartPublish($partNumber as xs:string*){

let $search := cts:search(fn:collection("Orchestra"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"), $partNumber),
                                                cts:element-value-query(xs:QName("PartPropogationStatus"), "NotReplicated")
                                                )),(
                                                  cts:index-order(cts:element-reference(xs:QName("revisionLevel")),"descending")
                                                  )
                                                )[1]
let $doc := $search/*:envelope/*:instance/*:Orchestra
let $part :=    $doc/part/partNumber/string()
let $partType := $doc/part/partTp/string()
let $systemMaster := $doc/part/systemMaster/string()
let $unitOfMeasure := $doc/part/unitOfMeasure/string()
let $serviceLevel := if (fn:empty($doc/part/PARTUSAGE/serviceLevel/string())) then () else $doc/part/PARTUSAGE/serviceLevel/string()
let $partLifecycleStatus := $doc/part/partLifecycleStatus/string()
let $dataQualityStatus :=  $doc/part/QUALITY/dataQualityStatus/string()
let $revisionLevel := $doc/part/revisionLevel/string()
let $shortDescription := $doc/part/shortDescription/string()
let $shortDescFrench := $doc/part/OTHERSHORTDESCRIPTION/shortDescFrench/string()
let $shortDescGerman := $doc/part/OTHERSHORTDESCRIPTION/shortDescGerman/string()
let $shortDescItalian := $doc/part/OTHERSHORTDESCRIPTION/shortDescItalian/string()
let $shortDescPolish := $doc/part/OTHERSHORTDESCRIPTION/shortDescPolish/string()
let $shortDescPortuguese := $doc/part/OTHERSHORTDESCRIPTION/shortDescPortuguese/string()
let $shortDescSpanish := $doc/part/OTHERSHORTDESCRIPTION/shortDescSpanish/string()
let $unspsc := $doc/part/unspsc/string()
let $familyNameEnglish := $doc/part/familyNameEnglish/string()
let $mass := $doc/part/mass/string()
let $designAuthority := $doc/part/designAuthority/string()
let $clampSequence := $doc/part/clampPartData/clampSequence/string()
return <Orchestra>
			<Part>
                  <partNumber>{$part}</partNumber>
                  <partTp>{$partType}</partTp>
                  <clampSequence>{$clampSequence}</clampSequence>
                  <revisionLevel>{$revisionLevel}</revisionLevel>
                  <shortDescription>{$shortDescription}</shortDescription>
                  <shortDescFrench>{$shortDescFrench}</shortDescFrench>
                  <shortDescGerman>{$shortDescGerman}</shortDescGerman>
                  <shortDescItalian>{$shortDescItalian}</shortDescItalian>
                  <shortDescPolish>{$shortDescPolish}</shortDescPolish>
                  <shortDescPortuguese>{$shortDescPortuguese}</shortDescPortuguese>
                  <shortDescSpanish>{$shortDescSpanish}</shortDescSpanish>
                  <systemMaster>{$systemMaster}</systemMaster>
                  <unitOfMeasure>{$unitOfMeasure}</unitOfMeasure>
                  <serviceLevel>{$serviceLevel}</serviceLevel>
                  <partLifecycleStatus>{$partLifecycleStatus}</partLifecycleStatus>
                  <dataQualityStatus>{$dataQualityStatus}</dataQualityStatus>
                  <unspsc>{$unspsc}</unspsc>
                  <familyNameEnglish>{$familyNameEnglish}</familyNameEnglish>
                  <mass>{$mass}</mass>
                  <designAuthority>{$designAuthority}</designAuthority>
				</Part>
            </Orchestra>


};

declare function search:searchPartOnly($partNumber as xs:string*){

let $search := cts:search(fn:collection("Orchestra"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"), $partNumber)
                                                )),(
                                                  cts:index-order(cts:element-reference(xs:QName("revisionLevel")),"descending")
                                                  )
                                                )[1]
return if (fn:exists($search)) then "Available" else "NotAvailable"
};
