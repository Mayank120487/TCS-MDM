xquery version "1.0-ml";
module namespace OrchestraCustomHarmonization = "http://marklogic.com/rest-api/resource/OrchestraCustomHarmonization";
declare namespace es = "http://marklogic.com/entity-services";
import module namespace json = "http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";
import module  namespace harmonizationstep2 = "http://alstom.com/harmonizationstep2" at "/ext/OrchestraHarmoniztion/Step2Hmnz/customStep2.xqy";
import module namespace queries = "http://alstom.com/Orchestra/Queries" at "/Orchestra/Queries.xqy";
declare variable $FINAL_DB := "smart-data-hub-FINAL";
declare  function OrchestraCustomHarmonization:post($context as map:map, $params  as map:map ,$input as document-node()*) as document-node()?
{
       xdmp:log("SERVICE-ENTRY: Harmonization Step 1"),
    let $Source   := fn:upper-case(map:get($params, "Source"))
    let $FlowName := if ($Source eq "CLAMP") then ("HarmonizeCLAMPDelta") 
                      else if ($Source eq "PLMSIG") then ("PLMSIGOrchestraDelta")
                      else ""

     let $URIS := document{(queries:RTH_PLM_UriCheck($input, $Source))}
    let $custom := let $config := json:config("custom")
           return 
             (
              map:put( $config, "whitespace", "ignore" ),
              map:put($config,"array-element-names",xs:QName("uris")),
              $config
             )

let $UriJson := json:transform-to-json-object($URIS,$custom)
    return document {(
           <Response>{(
                     if (($FlowName != ("")) and (fn:exists($URIS/URIS/uris/string()))) 
                            then (
                                let $step1 := json:transform-from-json(xdmp:invoke("/Orchestra/C_Harmonization/mlRunFLowCustom.sjs",
                                                               (xs:QName('URIS'),$UriJson,xs:QName('Pflow'),$FlowName)
                                                                      )
                                                               )
								let $error_count := $step1/*:errorCount/string()
								return
								if(xs:int($error_count) > xs:int(0)) then
									<STEP1_RESPONSE>
									<Step1_Status>{"Failed/Partial Failed - Failed"}</Step1_Status>
										{$step1}
									</STEP1_RESPONSE>
								else
									<STEP1_RESPONSE>
									<Step1_Status>{"Success"}</Step1_Status>
										{$step1}
									
                                   </STEP1_RESPONSE>
                                                                             )                          
                            else 
                            if($Source = "PLMSIG" and fn:empty($URIS/URIS/uris/string()) ) then
                            (<STEP1_RESPONSE>
                            <Step1_Status>{"Success"}</Step1_Status>
                            </STEP1_RESPONSE>)
                            else
                            (<Error>{"Service call require Source(rs:Source=[CLAMP/PLMSIG]) and URIS in Payload"}</Error>) 
                                   ,
                     
                     xdmp:log("SERVICE-EXIT: Harmonization Step 1"),

                     
					 let $step2_main := 
                                      for $uri in $URIS/URIS/uris/string()
											let $partNumber := if ($Source eq "CLAMP" and fn:not(fn:empty(fn:doc($uri)/CLAMPPart))) 
                                                   then (fn:doc($uri)/CLAMPPart/Attribute[@CLAMP_ID = "PartNumber"]/Value/string())
                                                    else if ($Source eq "PLMSIG" and fn:not(fn:empty(fn:doc($uri)/root)))
                                                    then (fn:doc($uri)/root/Name/string())
                                                   else ("No PartNumber")
					    
						let $step2 := if ($partNumber != ("No PartNumber") and $FlowName != (""))
                                          then (
                                                if ( fn:empty(xdmp:invoke-function(
					              function() {
								harmonizationstep2:step2Main($partNumber)
							       	} ,
							<options xmlns="xdmp:eval">
							<database>{xdmp:database($FINAL_DB)}</database>
							</options>))) 
						       then     
						       			<Result>
										<uri>{$uri}</uri>
										<partNumber>{$partNumber}</partNumber>
										<status>{"Step2-Processed"}</status>
										</Result>
						       else 
										<Result>
										<uri>{$uri}</uri>
										<partNumber>{$partNumber}</partNumber>
										<status>{"Step2-Failed"}</status>
										</Result>
                                               )
									else (	
										<Result>
											<uri>{$uri}</uri>
											<partNumber>{$partNumber}</partNumber>
											<status>{"Step2-No partNumber"}</status>
										</Result>
									)
						
						return 
							$step2
						 
						let $result := ("Step2-No partNumber", "Step2-Failed")
						return
						if( $result eq  $step2_main//status/string()) then 
						
						<STEP2_RESPONSE>
						<Step2_Status>{"Failed/Partial - Failed"}</Step2_Status>
							{$step2_main}
						</STEP2_RESPONSE>
						
						else
						
						<STEP2_RESPONSE>
						<Step2_Status>{"Success"}</Step2_Status>
							{$step2_main}
						</STEP2_RESPONSE>
						
							
						
                          
                                       
                     
                     )}
              </Response>
              )}
 
};