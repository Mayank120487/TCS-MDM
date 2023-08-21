(: uris.xqy :) 
xquery version "1.0-ml";
let $uris := cts:uris((),(),cts:collection-query("GoldenPart"))
return (count($uris), $uris)
