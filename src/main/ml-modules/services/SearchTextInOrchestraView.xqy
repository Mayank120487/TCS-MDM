xquery version "1.0-ml";

module namespace SearchTextInOrchestraView = "http://marklogic.com/rest-api/resource/SearchTextInOrchestraView";
import module namespace search = "http://marklogic.com/appservices/search" at "/MarkLogic/appservices/search/search.xqy";
declare namespace es = "http://marklogic.com/entity-services";

declare function SearchTextInOrchestraView:post($context as map:map, $params  as map:map,$input as document-node()*) as document-node()?
{
    xdmp:log("SERVICE-ENTRY: SearchTextInOrchestraView"),
 
    let $output-type    := map:put($context,"output-type","application/xml")
    let $StartIndex     := xs:int(map:get($params,"StartIndex"))
    let $pageSize       := xs:int(map:get($params,"PageSize"))
    let $qtext          := document {$input/SearchRequest/*:qtext}
    let $options as element()       := $input/SearchRequest/*:options
    return if ($qtext = "" or fn:exists($qtext) = fn:false())
           then (document{<Error>{"No Search input provided"}</Error>})
           else (document {<Success>{ 
                                     let $searchs := search:search($qtext,$options) (:,$StartIndex,$pageSize):)
                                      return <SearchResponse MatchedCount = "{$searchs/@total}">{  for $search at $c in $searchs//search:result
                                                                     return  <MatchResult Index="{$c}">{
                                                                                 (:<URI>{$search/@uri}</URI>,:)
                                                                                 <MatchXML>{fn:doc($search/@uri/string())//*:Orchestra/part/partNumber/string()}</MatchXML>(:,
                                                                                 <MatchCriteria>{ for $matches in $search//search:snippet/search:match
                                                                                                  return (<MatchedElement Field = '{fn:substring-after($matches/@path/string(),"instance/Orchestra")}'>{$matches/search:highlight/string()}</MatchedElement>)
                                                                                 }</MatchCriteria>:)
                                                                             }</MatchResult>
                                            }</SearchResponse>
      }</Success>}),
	xdmp:log("SERVICE-EXIT: SearchTextInOrchestraView")
      
      
      };