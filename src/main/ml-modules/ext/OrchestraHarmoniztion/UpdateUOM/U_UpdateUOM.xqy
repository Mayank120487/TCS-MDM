xquery version "1.0-ml";
let $uri := cts:uris((),(),cts:and-query((cts:collection-query("Orchestra"),
                                            cts:element-value-query(xs:QName("unitOfMeasure"),"UN")
                                            )))

return (fn:count($uri),$uri)