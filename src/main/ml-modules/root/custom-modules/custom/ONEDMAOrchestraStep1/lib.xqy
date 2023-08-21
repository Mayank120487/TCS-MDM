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
    else
    	(

    		 let $_:= map:put($options,"urikey",$content/root/PART_NUMBER/string())
    		 let $_:= map:put($options,"uuid",sem:uuid-string())
    		 let $PLMCheck := cts:uris((),(),cts:and-query((
                                                            cts:collection-query("/sources/PLM/BatchLoad"),
                                                            cts:element-value-query(xs:QName("Name"),$content/root/PART_NUMBER/string()),
                                                            cts:not-query(cts:element-value-query(xs:QName("Design_Responsibility"),"CLAMP"))
                                        				)))
    		 return if(fn:exists($PLMCheck) = xs:boolean("false")) then
    		 (
                     document
                     {

                          element partTp
                          {
                            if($content/root/PART_TYPE/string() = "BOUGHT ASSY") then "Part to Specification (CoS)"
                            else ("ALSTOM Design Part")
                          },
                          element partNumber {$content/root/PART_NUMBER/string()},
                          (:element revisionLevel {$content/root/PART_REVISION/string()},:)
                          element revisionLevel {
                            fn:replace($content/root/PART_REVISION/string(),'[^a-zA-Z0-9]','')
                          },
                          element shortDescription {if (fn:lower-case($content/root/DESCRIPTION/string()) = "null") then () else $content/root/DESCRIPTION/string()},
                          element shortDescFrench {if (fn:lower-case($content/root/DESCRIPTION_FR/string()) = "null") then () else $content/root/DESCRIPTION_FR/string()},
                          element shortDescGerman {if (fn:lower-case($content/root/DESCRIPTION_GE/string()) = "null") then () else $content/root/DESCRIPTION_GE/string()},
                          element shortDescItalian {if (fn:lower-case($content/root/DESCRIPTION_IT/string()) = "null") then () else $content/root/DESCRIPTION_IT/string()},
                          element shortDescSpanish {if (fn:lower-case($content/root/DESCRIPTION_SP/string()) = "null") then () else $content/root/DESCRIPTION_SP/string()},
                          element unspsc {if (fn:lower-case($content/root/UNSPSC_Code/string()) = "null") then () else $content/root/UNSPSC_Code/string()},
                          (: 23-09-2021 Added new attribute called FamilyNameEnglish and import a "Queries.xqy" Module :)
                          element familyNameEnglish {
                          let $unspsc := fn:substring($content/root/UNSPSC_Code/string(),1,8)
                          let $systemMaster := "DMA"
                          return queries:getFamilyName($systemMaster,$unspsc)
                          },
                          element mass {if (fn:lower-case($content/root/COMPUTED_MASS/string()) = "null") then () else $content/root/COMPUTED_MASS/string()},
                          (: element designAuthority {$content/root/SITE/string()} :)
                          (: 23-09-2021 Modified to remove "null" values :)
                          element designAuthority {if (fn:lower-case($content/root/SITE/string()) = "null") then () else $content/root/SITE/string()},
                          element clampControllingUnit {"DMA"},
                          element systemMaster {"DMA"},
                          (:element unitOfMeasure {$content/root/UOM/string()}:)
                          element unitOfMeasure {
                            if(fn:empty($content/root/UOM/string())) then "EA"
                            else if(fn:upper-case($content/root/UOM/string()) = "UN") then "EA"
                            else if(fn:upper-case($content/root/UOM/string()) = "P") then "EA"
                            else if(fn:lower-case($content/root/UOM/string()) = "G") then "G"
                            else if(fn:lower-case($content/root/UOM/string()) = "KG") then "KG"
                            else if(fn:lower-case($content/root/UOM/string()) = "ML") then "ML"
                            else if(fn:lower-case($content/root/UOM/string()) = "L") then "L"
                            else if(fn:lower-case($content/root/UOM/string()) = "M") then "ML"
                            else if(fn:lower-case($content/root/UOM/string()) = "M2") then "M2"
                            else if(fn:lower-case($content/root/UOM/string()) = "M3") then "M3"
                            else if(fn:lower-case($content/root/UOM/string()) = "FO") then "FO"
                            else if(fn:lower-case($content/root/UOM/string()) = "OZ") then "OZ"
                            else if(fn:lower-case($content/root/UOM/string()) = "GL") then "GL"
                            else if(fn:lower-case($content/root/UOM/string()) = "FT") then "FT"
                            else if(fn:lower-case($content/root/UOM/string()) = "F2") then "FT2"
                            else if(fn:lower-case($content/root/UOM/string()) = "LB") then "LB"
                            else if(fn:lower-case($content/root/UOM/string()) = "MM") then "MM"
                            else if(fn:lower-case($content/root/UOM/string()) = "QT") then "QT"
                            else if(fn:lower-case($content/root/UOM/string()) = "PT") then "PT"
                            else if(fn:lower-case($content/root/UOM/string()) = "Any other") then "Any other"
                            else $content/root/UOM/string()
                          },
                          (: 01-10-2021 Newly added Attribute called PartLifecycleStatusMonitored :)
                          element PartLifecycleStatusMonitored {
                             let $partType := if($content/root/PART_TYPE/string() = "BOUGHT ASSY") then "Part to Specification (CoS)"
                                 else ("ALSTOM Design Part")
                              return
                                  if($partType = "ALSTOM Design Part") then
                                      "true"
                                         else
                                          "false"
                          },
                          (: Added as UAT comments : Defau;t lifecycle status is 20 Current:)
                          element partLifecycleStatus {"20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current" },
                          (: Added as UAT comments : Default usability = "For Purchase Only" & serviceLevel = "N/A" :)
                          element usability {"For Purchase Only"},
                          element serviceLevel {"Not Applicable"}
                      }
              )
              else (document{"null"})

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
  	element source {"ONEDMA"},
    element Document_Timestamp {""},
  	element Harmonized_Date {fn:format-date(fn:current-date(),"[D01]-[M01]-[Y0001]")},
		element PartNumber {$content/root/PART_NUMBER/string()},
    element PartPropogationStatus  {queries:getPropogationStatus($content/root/PART_NUMBER/string())},
  	    element sourceURI {cts:uris((),(),cts:and-query((
                                                        cts:collection-query("/sources/OneDMA/BatchLoad"),
                                                        cts:element-value-query(xs:QName("PART_NUMBER"),$content/root/PART_NUMBER/string()),
                                                        cts:element-value-query(xs:QName("PART_REVISION"),$content/root/PART_REVISION/string())
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

  if($content != "null") then
  (
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
   )
   else (document {()})
};