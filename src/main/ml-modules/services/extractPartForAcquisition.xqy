xquery version "1.0-ml";
module namespace extractPartForAcquisition = "http://marklogic.com/rest-api/resource/extractPartForAcquisition"; 
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
declare namespace search1 = "http://marklogic.com/appservices/search";
declare namespace es = "http://marklogic.com/entity-services";

declare function extractPartForAcquisition:removeBlankChars($node)
    {
         typeswitch($node)
        case document-node()
          return
          document
            {
              for $child in $node/node()
            return
                extractPartForAcquisition:removeBlankChars($child)
            } 
         case element()
            return
            if($node/node())then
                  element { node-name($node) } {
                    $node/attribute(),
                    for $child in $node/node()
              return
              extractPartForAcquisition:removeBlankChars($child)
        }
            else 
            element { node-name($node) }
          {"#@null@#"}
          
          default return $node
        };

declare function extractPartForAcquisition:get($context as map:map, $params as map:map) as document-node()*
{
	xdmp:log("SERVICE-ENTRY: extractPartForAcquisition"),
let $propagationDate := map:get($params,"Date")
let $StartIndex := xs:int(map:get($params,"StartIndex"))
let $pageSize := xs:int(map:get($params,"PageSize"))
let $qtext := 'collection:'||$propagationDate||' AND (PartPropogationStatus1:ReplicatedfromPublication OR PartPropogationStatus1:ReplicatedFromMigration OR 
PartPropogationStatus1:ReplicatedfromClamp) AND PartAcquisitionStatus1:NO AND PartNumber1:**'
let $search := search:search($qtext,
                                    <options xmlns="http://marklogic.com/appservices/search">
                                      <constraint name="collection">
                                        <collection prefix="/Orchestra/Delta/" facet="false" />
                                       </constraint>
                                        <constraint name="PartPropogationStatus1">
                                        <value>
                                          <element ns="" name="PartPropogationStatus"/>
                                        </value>
                                      </constraint>
                                      <constraint name="PartAcquisitionStatus1">
                                        <value>
                                          <element ns="" name="PartAcquisitionStatus"/>
                                        </value>
                                      </constraint>
                                      <constraint name="PartNumber1">
                                        <value>
                                          <element ns="" name="PartNumber"/>
                                          <term-option>punctuation-sensitive</term-option>
                                          <term-option>whitespace-sensitive</term-option>
                                        </value>
                                      </constraint>
                                      <transform-results apply="raw">
                                    </transform-results>
                                  </options>,$StartIndex,$pageSize)

(:Updated in PGL's Time 10-1-2021:)
(:
let $partNumber_Search :=
for $searchPart in $search//search:result
where $searchPart/*:envelope/*:headers/PartNumber/text() ne ""
return $searchPart
:)

return

if (fn:exists($propagationDate) and fn:exists($StartIndex) and fn:exists($pageSize))
then (document {
<OrchestraResult TotalRecords="{fn:count($search//search:result)}">
{
for $searchPart in $search//search:result
return extractPartForAcquisition:removeBlankChars(document{$searchPart//*:envelope/*:instance/*:Orchestra})
}
</OrchestraResult>
}
                        
              )
        else 
        (document {"Service Call require rs:Date:[Date of Extractions],rs:StartIndex:[StartIndex of Documents],rs:PageSize:[No. of Documents per Page]"})
	,
	xdmp:log("SERVICE-EXIT: extractPartForAcquisition")
  
};