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
(:import module namespace test = "http://marklogic.com/test" at "/Part_Transformation.xqy";:)
import module namespace partstranformation = "partstranformation" at "/Orchestra/orchestra_parts_transformation.xqy";
import module namespace partsmanuftranformation = "partsmanuftranformation" at "/Orchestra/orchestra_parts_manuf_transformation.xqy";
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
  (: for delta load: "cts.uris(null,'limit=5000',cts.collectionQuery('/sources/CLAMP'))"
  let $DocUri := $content/uri
  for full load : "cts.uris(null,'limit=10000', cts.collectionQuery(['orchestra_all_ppl_parts_v2','orchestra_subscribed_by_PLM_EV6_NEO_CAO_v2','orchestra_subscribed_by_33_trigrams_v2','orchestra_all_gsi_parts_v2','orchestra_subscribed_railsys_v3']))"
   let $DocUri := fn:doc($content/uri)/URI/string()
   :)
 let $DocUri := $content/uri

  (: get the headers :)
  let $headers := custom:create-headers($DocUri,custom:create-instance-part($DocUri, $options), $options)

  (: get the triples :)
  let $triples := custom:create-triples($DocUri, $options)

  (: get the instance :)
  let $instance := map:get(custom:create-instance-part($DocUri, $options),"value")
                   
  let $URI_CLAMP := map:get(custom:create-instance-part($DocUri, $options),"uri")

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
declare function custom:create-instance-part(
  $content as item()?,
  $options as map:map) 
{
(: This code is meant for illustrative purpose. It has to be replaced with your code for creating instance:)

 let $uri := xs:string($content)
 let $content := json:object()
 let $_ := map:put($content,"value",partstranformation:process($uri,map:map()))
 let $uriKey := map:get($options,"urikey")
 (:let $uriKey := 
  if(fn:empty($uriKey)) then
    xdmp:random()
  else 
    $uriKey:)
 let $_ := map:put($content,"uri",(fn:concat("http://Alstom.com/Orchestra/CLAMP/",$uriKey,".xml")))
return $content
};

(:~
 : Create Headers
 :
 : @param $content  - the raw content
 : @param $options  - a map containing options
 :
 :)
declare function custom:create-headers($DocUri,
  $content as item()?,
  $options as map:map) as node()*
{
(: Code for creating headers:)
let $timestamp := fn:doc($DocUri)//Attribute[@CLAMP_ID eq "TIMESTAMP"]/Value/string()
let $URI_CLAMP  := map:get($content,"uri")
let $PartNumber := map:get($content,"value")/part/partNumber/string()
let $revisionLevel := map:get($content,"value")/part/revisionLevel/string()
let $clampSequence := map:get($content,"value")/part/clampPartData/clampSequence/string()
let $_ := map:put($options,"urikey",(fn:concat($PartNumber,"/",$revisionLevel,"/",$clampSequence,"/",$timestamp,"/",sem:uuid-string())))
let $_ := map:put($options,"uuid",sem:uuid-string())
(:let $partExistInOrchestra := if (fn:exists(cts:search(fn:collection("ReplicatedFromMigration"),cts:element-value-query(xs:QName("partNumber"),$PartNumber)))) then "ReplicatedFromMigration" else "NotReplicated"
:)
 return (
          element source{"CLAMP"},
          element Document_Timestamp {$timestamp},
          element Harmonized_Date {fn:format-date(fn:current-date(),"[D01]-[M01]-[Y0001]")},
         (: element uri {$URI_CLAMP},:)
          element PartNumber {$PartNumber},
          element PartPropogationStatus {queries:getPropogationStatusDelta($PartNumber,"CLAMP")}
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
