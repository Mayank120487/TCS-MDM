(:
  Copyright 2012-2019 MarkLogic Corporation

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
:)
xquery version "1.0-ml";

module namespace custom = "http://marklogic.com/data-hub/custom";
declare namespace es = "http://marklogic.com/entity-services";
import module namespace json="http://marklogic.com/xdmp/json"
at "/MarkLogic/json/json.xqy";
import module namespace queries = "http://alstom.com/Orchestra/Queries" at "/Orchestra/Queries.xqy";


(:~
 : Plugin Entry point
 :
 : @param $content     - the raw content
 : @param $options     - a map containing options
 :
 :)
 
 (:declare function custom:convertdate($Modifieddate as xs:string){
let $doc := $Modifieddate
let $date := fn:substring-before($Modifieddate, " ")
let $month := if (fn:string-length(fn:substring-before($date,"/")) = xs:int("1")) then "0"||fn:substring-before($date,"/") else fn:substring-before($date,"/")
let $DDYYYY := fn:substring-after($date,"/")
let $DATE := $month||"/"||$DDYYYY
let $len := fn:string-length(fn:substring-before($doc, " "))
let $time := fn:substring-before(fn:substring($doc,$len + xs:int("2") )," ")
let $hour := if (fn:string-length(fn:substring-before($time,":")) = xs:int("1")) then "0"||fn:substring-before($time,":") else fn:substring-before($time,":")
let $MISS := fn:substring-after($time,":")
let $TIME := "T"||$hour||":"||$MISS
let $DateTimestamp := $DATE||$TIME
return (fn:replace(fn:substring-before(xs:string(xdmp:parse-dateTime('[M01]/[D01]/[Y0001]T[h01]:[m01]:[s01]', $DateTimestamp)),"+"),'[^0-9]',""))
 
 };
 :)
 
declare function custom:main(
  $content as item()?,
  $options as map:map)
{
  (: get the source doc :)
  let $doc := if (xdmp:node-kind($content/value) eq "text") then xdmp:unquote($content/value) else $content/value

  (: get the headers :)
  let $headers := custom:create-headers($doc, $options)

  (: get the triples :)
  let $triples := custom:create-triples($doc, $options)

  (: get the instance :)
  let $instance := custom:create-instance($doc, $options)

  let $output-format := if(fn:empty(map:get($options, "outputFormat"))) then "json" else map:get($options, "outputFormat")

  (: get the envelope :)
  let $envelope := custom:make-envelope($instance, $headers, $triples, $output-format)
  

  return $envelope
};

(:~
 : Creates instance
 :
 : @param $content  - the raw content
 : @param $options  - a map containing options
 :
 :)

declare function custom:create-instance(
  $content as item()?,
  $options as map:map) as item()?
{
(: This code is meant for illustrative purpose. It has to be replaced with your code for creating instance:)
    if ($content/es:envelope) then
      $content/es:envelope/es:instance/node()
    else if ($content/envelope/instance) then
      $content/envelope/instance
	(: Place to update the source to target transformation code :) 
    else
	(
	     
		 let $_:= map:put($options,"urikey",$content/root/Name/string())
		 let $_:= map:put($options,"uuid",sem:uuid-string())		 
		 return
document
		 {
		    element partTp {"ALSTOM Design Part"},
			  element partNumber {$content/root/Name/string()},
			  (:element revisionLevel {$content/root/Revision/string()},:)
        element revisionLevel {
          fn:replace($content/root/Revision/string(),'[^a-zA-Z0-9]','')
        },
			  element shortDescription {if ($content/root/Description_EN/string() = "&#10;") then () else $content/root/Description_EN/string()},
			  element shortDescFrench {if ($content/root/Description_FR/string() = "&#10;") then () else $content/root/Description_FR/string()},
			  element shortDescGerman {if ($content/root/Description_GE/string() = "&#10;") then () else $content/root/Description_GE/string()},
			  element shortDescItalian {if ($content/root/Description_IT/string() = "&#10;") then () else $content/root/Description_IT/string()},
			  element shortDescSpanish {if ($content/root/Description_SP/string() = "&#10;") then () else $content/root/Description_SP/string()},
			  element shortDescPortuguese {if ($content/root/Description_PT/string() = "&#10;") then () else $content/root/Description_PT/string()},
			  element unspsc {fn:substring($content/root/UNSPSC_Code/string(),1,8)},
			  (: element familyNameEnglish {fn:substring-after($content/root/UNSPSC_Code/string(),fn:substring($content/root/UNSPSC_Code/string(),1,9))}, :)
			  (: 23-09-2021 Modified and import queries to get FamilyNameEnglish from lookup collection :)
        element familyNameEnglish {
                    let $unspsc := fn:substring($content/root/UNSPSC_Code/string(),1,8)
                    let $systemMaster := "PLM"
                   return queries:getFamilyName($systemMaster,$unspsc)
         },
        element mass {$content/root/Weight/string()},
			  element designAuthority {$content/root/Design_Responsibility/string()},
			  element clampControllingUnit {"PLM"},
			  element systemMaster {"PLM"},
			  (:element unitOfMeasure {$content/root/Unit_of_Measure/string()},:)
        element unitOfMeasure {
          if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "UN") then "EA"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "EA") then "EA"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "G") then "G"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "KG") then "KG"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "ML") then "ML"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "L") then "L"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "M") then "ML"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "M2") then "M2"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "M3") then "M3"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "OZ") then "OZ"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "GA") then "GL"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "FT") then "FT"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "F2") then "FT2"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "LB") then "LB"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "MM") then "MM"
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "NO") then ""
          else if(fn:upper-case(fn:substring-before($content/root/Unit_of_Measure/string()," ")) = "NO") then ""
          else $content/root/Unit_of_Measure/string()
        },
		    element clampDate {fn:substring-before($content/root/Modified/string()," ")},
			 (:
			  element serviceLevel {if (fn:empty($content/root/Service_Level/string()) )
                              then  ("Not Applicable")
                              else (if ($content/root/Service_Level/string() eq "N/A") then "Not Applicable"
                                    else ($content/root/Service_Level/string())
                                    )},
                       :)
        (:transformation change on 6-12-2021:)
        element serviceLevel {if (fn:empty($content/root/Service_Level/string()) )
            then ("Not Applicable")
                else (if ($content/root/Service_Level/string() eq "N/A") then "Not Applicable"
                  else if ($content/root/Service_Level/string() eq "Assembly") then "Assembly Eligible"
                  else $content/root/Service_Level/string()
            )},
                                    
        (: 01-10-2021 Newly added Attribute called PartLifecycleStatusMonitored :)
        element PartLifecycleStatusMonitored {
             let $partType :=
                if( $content/root/Type/string() = "AT_DesignPart" ) then
                "ALSTOM Design Part"
                 else ""
            return
             if($partType = "ALSTOM Design Part") then
                "true"
                  else
                  "false"
        },
        (:Changes made on 06-12-21 as per bussiness:)
        element usability {"For Detailed Design"},

			  element partLifecycleStatus {
				  if($content/root/PPL/string()) then  
                                          ( if(fn:lower-case($content/root/PPL/string()) = "10 - introduction") then
                                          "10" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Introduction"
                                        else if(fn:lower-case($content/root/PPL/string())  = "20 - current") then
                                          "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current"
                                        else if(fn:lower-case($content/root/PPL/string())  = "30 - mature") then
                                          "30" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Mature"
                                       else if(fn:lower-case($content/root/PPL/string())  = "50 - middle of life") then
                                          "50" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Middle of Life"
                                        else if(fn:lower-case($content/root/PPL/string())  = "70 - end of life") then
                                          "70" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "End of Life"
                                        else if(fn:lower-case($content/root/PPL/string())  = "80 - end of life extended support") then
                                        (:23-09-2021 modified to make it "80 – Extended Support" :)
                                        (:  "80" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "End of Life Extended Support" :)
                                        "80" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Extended Support"
                                        else if(fn:lower-case($content/root/PPL/string())  = "90 - restricted support") then
                                        (: 22-09-2021 Changed as per UAT Issue #60 :)
                                         (: "90" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Restricted Support" :)
                                          "90" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "After" || fn:codepoints-to-string(8211) || "Life"
                                        else if(fn:lower-case($content/root/PPL/string())  = "99 - obsolete") then
                                          "99" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Obsolete"
                                        else (if($content/root/Engineering_Maturity/string() = "AT_PrototypePart") then "10" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Introduction" 
                                          else if($content/root/Engineering_Maturity/string() = "AT_SerialPart") then "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current" 
                                          else if($content/root/Engineering_Maturity/string() = "AT_Serial &amp; State Dead") then "99" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Obsolete" 
                                        else ())
                                    )
                                      else (
                                        (:if($content/root/Engineering_Maturity/string() = "AT_PrototypePart") then "10 - Introduction" (:8211:)
                                        else if($content/root/Engineering_Maturity/string() = "AT_SerialPart") then "20 - Current"
                                        else if($content/root/Engineering_Maturity/string() = "AT_Serial &amp; State Dead") then "99 - Obsolete"
                                                else ():)
                                        if($content/root/Engineering_Maturity/string() = "AT_PrototypePart") then "10" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Introduction" 
                                          else if($content/root/Engineering_Maturity/string() = "AT_SerialPart") then "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current" 
                                          else if($content/root/Engineering_Maturity/string() = "AT_Serial &amp; State Dead") then "99" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Obsolete" 
                                        else ()                   
                                      )
			 } 
		  }			   
	  )       
};

(:~
 : Create Headers
 :
 : @param $content  - the raw content
 : @param $options  - a map containing options
 :
 :)
declare function custom:create-headers(
  $content as item()?,
  $options as map:map) as node()*
{
(: Code for creating headers:)
  (
		element source {"PLMSIG"},
    element Document_Timestamp {""},
		element Harmonized_Date {

let $Latestdates :=
let $dates :=
if($content/root/Modified/string() eq "") then fn:current-dateTime()
else if(fn:contains($content/root/Modified/string(),"PM"))
then ((xdmp:parse-dateTime('[M01]/[D01]/[Y0001] [h01]:[m01]:[s01]',$content/root/Modified/string()) + xs:dayTimeDuration("PT12H")))
else (xdmp:parse-dateTime('[M01]/[D01]/[Y0001] [h01]:[m01]:[s01]',$content/root/Modified/string()))
order by $dates descending
return $dates
return $Latestdates
    },
		element PartNumber {$content/root/Name/string()},
    element PartPropogationStatus  {queries:getPropogationStatus($content/root/Name/string())},
	    element sourceURI {cts:uris((),(),cts:and-query((
                                                                cts:collection-query("/sources/PLM/BatchLoad"),
                                                                cts:element-value-query(xs:QName("Name"),$content/root/Name/string()),
                                                                cts:element-value-query(xs:QName("Revision"),$content/root/Revision/string())
        												)))
        				   }
  )
 
};

(:~
 : Create Triples
 :
 : @param $content  - the raw content
 : @param $options  - a map containing options
 :
 :)
declare function custom:create-triples(
  $content as item()?,
  $options as map:map) as sem:triple*
{
(: Code for creating triples:)
  ()
};

(:~
 : Creates Envelope
 :
 : @param $content  - the raw content
 : @param $options  - a map containing options
 :
 :)
declare function custom:make-envelope($content as item()?, $headers, $triples, $output-format) as document-node()
{

  (: This code is meant for illustrative purpose. It has to be replaced with your code for creating envelope:)

  if ($output-format = "xml") then
    document {
      <envelope xmlns="http://marklogic.com/entity-services">
        <headers>{$headers}</headers>
        <triples>{$triples}</triples>
        <instance>{$content}</instance>
        <attachments>
          {
            if ($content instance of map:map and map:keys($content) = "$attachments") then
              if(map:get($content, "$attachments") instance of element() or
                map:get($content, "$attachments")/node() instance of element()) then
                map:get($content, "$attachments")
              else
                let $c := json:config("basic")
                let $_ := map:put($c,"whitespace" , "ignore" )
                return
                  json:transform-from-json(map:get($content, "$attachments"),$c)
            else
              ()
          }
        </attachments>
      </envelope>
    }
  else
    let $envelope :=
      let $o := json:object()
      let $_ := (
        map:put($o, "headers", $headers),
        map:put($o, "triples", $triples),
        map:put($o, "instance",$content),
        map:put($o, "attachments",
          if ($content instance of map:map and map:keys($content) = "$attachments") then
            map:get($content, "$attachments")
          else
            ()
        )
      )
      return
        $o
    let $wrapper := json:object()
    let $_ := map:put($wrapper, "envelope", $envelope)
    return
      xdmp:to-json($wrapper)

};
