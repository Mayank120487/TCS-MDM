xquery version "1.0-ml";
module namespace partAcquisitionStatus = "http://marklogic.com/rest-api/resource/updatePartAcquisitionStatus";
declare namespace es = "http://marklogic.com/entity-services";
declare namespace rapi = "http://marklogic.com/rest-api";

declare %rapi:transaction-mode("update") function partAcquisitionStatus:post($context as map:map, $params  as map:map,$input as document-node()*) as document-node()?
{
       xdmp:log("SERVICE-ENTRY: partAcquisitionStatus"),
    let $status                 := fn:upper-case(map:get($params, "Status"))
    return if (($status = "") or (fn:empty($status) = fn:true())) 
           then (document {<Error>{"Service call require Status(rs:Status=[WIP/YES/ERR])"}</Error>})                
           else if ($status = ("WIP")) then ( 
                  document {
                            <Results>{
                                      for $partNumber in $input/PartNumbers/PartNumber/string() 
                                      let $Searchdoc := cts:search(fn:collection("Orchestra"),cts:and-query((cts:element-value-query(xs:QName("PartNumber"),$partNumber))))
                                      return if (fn:exists($Searchdoc)) 
                                             then (
                                                   let $nodeReplace := (xdmp:node-replace($Searchdoc/*:envelope/*:headers/PartAcquisitionStatus,<PartAcquisitionStatus>{$status}</PartAcquisitionStatus>),xdmp:commit())
                                                   return  <Result><Response>{$partNumber||"- Success"}</Response><Message>{"Status Changed to "||$status}</Message></Result>)
                                             else <Result><Response>{$partNumber||"- Failure"}</Response><Message>{"Part Doesn't exist for PartAcquisitionStatus Change"}</Message></Result>	

                                      }
                            </Results>
                        }
                  )
                  
                  else if ($status = ("YES","ERR","NO")) then ( 
                  document {
                            <Results>{
                                      for $partNumber in $input/PartNumbers/PartNumber/string() 
                                      let $Searchdoc := cts:search(fn:collection("Orchestra"),cts:and-query((
                                      cts:element-value-query(xs:QName("PartNumber"),$partNumber),
                                     cts:element-value-query(xs:QName("PartAcquisitionStatus"),"WIP")
                                      ))
                                      )
                                      return if (fn:exists($Searchdoc)) 
                                             then (
                                                   let $nodeReplace := (xdmp:node-replace($Searchdoc/*:envelope/*:headers/PartAcquisitionStatus,<PartAcquisitionStatus>{$status}</PartAcquisitionStatus>),xdmp:commit())
                                                   return  <Result><Response>{$partNumber||"- Success"}</Response><Message>{"Status Changed to "||$status}</Message></Result>)
                                             else <Result><Response>{$partNumber||"- Failure"}</Response><Message>{"Part Doesn't exist for PartAcquisitionStatus Change with Status = WIP"}</Message></Result>	

                                      }
                            </Results>
                        }
                  )
                  
                 else (document {<Error>{"Service call require Correct Status(rs:Status=[WIP/YES/ERR])"}</Error>})
                 ,
    
    xdmp:log("SERVICE-EXIT: partAcquisitionStatus")
   
};