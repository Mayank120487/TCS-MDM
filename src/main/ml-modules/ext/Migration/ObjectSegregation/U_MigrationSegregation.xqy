xquery version "1.0-ml";
declare variable $batch external ; (::= "orchestra_subscribed_by_33_trigrams_rv3";:)
let $uris := cts:uris((),(),cts:collection-query($batch))
return (count($uris), $uris)