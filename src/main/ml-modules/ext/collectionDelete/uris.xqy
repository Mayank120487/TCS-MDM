xquery version "1.0-ml";
declare variable $deleteCollection as xs:string external;

let $uris := cts:uris((), (), cts:collection-query($deleteCollection))
return(count($uris),$uris)
