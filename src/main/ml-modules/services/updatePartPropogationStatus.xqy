xquery version "1.0-ml";

module namespace publishPartInOrchestraView = "http://marklogic.com/rest-api/resource/updatePartPropogationStatus";
declare namespace es = "http://marklogic.com/entity-services";

declare function publishPartInOrchestraView:put($context as map:map, $params  as map:map,$input as document-node()*) as document-node()?
{
    xdmp:log("SERVICE-ENTRY: publishPartInOrchestraView"),
 
    let $output-type            := map:put($context,"output-type","application/xml")
    let $partNumber             := map:get($params,"part")
    let $clampSequence          := if (map:get($params,"clampSequence") = "") then "0" else map:get($params,"clampSequence")
    let $content as element()*  :=  $input/PartPropogationStatus
    let $searchDoc              := cts:search(fn:collection("Orchestra"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                                    (:,cts:element-range-query(xs:QName("clampSequence"),"=",xs:int($clampSequence)):)
                                                     ))
                                                     )
    let $CLAMPSearch := let $res := for $i at $c in cts:search(fn:collection("/final/Orchestra/CLAMP"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber)
                                                                  )),(cts:index-order(cts:element-reference(xs:QName("revisionLevel")),"descending")
                                    )
                                    )
                                    order by xs:int($i//clampSequence/string()) descending , $i//Document_Timestamp/string() descending
                                    return $i
                        return $res[1]

            
    let $docUri                 :=  $searchDoc/document-uri()  
    let $collections            :=  xs:string(fn:concat("/Orchestra/Delta/",fn:format-date(fn:current-date(),"[D01]-[M01]-[Y0001]")))
    (:let $nodeReplace :=     (xdmp:node-replace($searchDoc/es:envelope/es:headers/PartPropogationStatus,$content),xdmp:commit()):)
    return if (($partNumber = "") (:and (xs:string($clampSequence) = ""):))
            then (document {<Error>{"Service call require part(rs:part=PartNumber) and clampSequence(rs:clampSequence=clampSequence)"}</Error>})
            else(
                  if (fn:exists($searchDoc)) 
                  then (
                        let $nodeReplace := (xdmp:node-replace($searchDoc/*:envelope/*:headers/PartPropogationStatus,<PartPropogationStatus>ReplicatedfromPublication</PartPropogationStatus>),xdmp:commit())
                        let $_ :=(xdmp:node-replace($CLAMPSearch/*:envelope/*:headers/*:PartPropogationStatus,<PartPropogationStatus>ReplicatedfromPublication</PartPropogationStatus>),xdmp:commit())
                        let $addSubscriptionDateCollection := xdmp:document-add-collections($docUri, $collections)
                        return document { <Result><Response>{"Success"}</Response><Message>{"Status Changed"}</Message></Result>}  
                        )
                  else document {<Result><Response>{"Failure"}</Response><Message>{"Part Doesn't exist for Propagation Status Change"}</Message></Result>}	
                  )
	,
	xdmp:log("SERVICE-EXIT: publishPartInOrchestraView")
  
};