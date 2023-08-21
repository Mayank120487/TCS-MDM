xquery version "1.0-ml";
module namespace searchPartInOrchestraView = "http://marklogic.com/rest-api/resource/searchPartInOrchestraView";
import module namespace search = "http://alstom.com/Search_Queries" at "/Orchestra/Search_Queries.xqy";

declare function searchPartInOrchestraView:get($context as map:map, $params  as map:map) as document-node()*
{
	xdmp:log("SERVICE-ENTRY: searchPartInOrchestraView"),

	let $output-type := map:put($context,"output-type","application/xml")
	let $partNumber  := map:get($params,"part")
	let $extractType    := map:get($params,"extract")
	return 
				if (($partNumber = "") and ($extractType = "")) 
				then document {<Result><Response>{"Failure"}</Response><Message>{"Service call require part(rs:part=PartNumber) and extractType(rs:extract=[Full/Publish])"}</Message></Result>}
				else (
					if (fn:exists(search:searchPart($partNumber)) and (fn:upper-case($extractType) eq "FULL")) 
					then document {<Result><Response>{"Success"}</Response><Orchestras>{search:searchPart($partNumber)}</Orchestras></Result>}
                    else( 
                         if (fn:exists(search:searchPart($partNumber)) and (fn:upper-case($extractType) eq "PUBLISH")) 
                         then document {<Result><Response>{"Success"}</Response><Message>{search:searchPartPublish($partNumber)}</Message></Result>}
                         else (
							 if ((search:searchPartOnly($partNumber) eq ("Available","NotAvailable")) and ($extractType = "")) 
							 then 
							 ( document {<Result><Response>{"Failure"}</Response><Message>{"Please pass extract Type [FULL/PUBLISH]"}</Message></Result>})
							 else (
								   if ((search:searchPartOnly($partNumber) eq ("Available")) and (fn:upper-case($extractType) eq ("FULL","PUBLISH")))
								   then ( document {<Result><Response>{"Failure"}</Response><Message>{$partNumber||" Part is already Published in orchestra"}</Message></Result>})
								   else ( 
											if (($partNumber != "") and (fn:upper-case($extractType) eq ("FULL","PUBLISH")))
											then document {<Result><Response>{"Failure"}</Response><Message>{$partNumber||" Part doesn't exist"}</Message></Result>}
											else (
													if (($partNumber != "") and (fn:upper-case($extractType) != ("FULL","PUBLISH")))
													then document {<Result><Response>{"Failure"}</Response><Message>{"Please pass correct extract Type [FULL/PUBLISH]"}</Message></Result>}
													else document {<Result><Response>{"Failure"}</Response><Message>{$partNumber||" Please Enter Part No. "}</Message></Result>}
                          
                              					 )		
                        				)
							      )
						  	  )
						
						)
          )
					 
	,
	xdmp:log("SERVICE-EXIT: searchPartInOrchestraView")
  
};