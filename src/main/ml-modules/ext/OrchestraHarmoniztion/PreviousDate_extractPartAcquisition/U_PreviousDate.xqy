xquery version "1.0-ml";

let $collection := fn:concat("/Orchestra/Delta/",
			fn:format-dateTime(xdmp:parse-dateTime("[Y0001]-[M01]-[D01]", xs:string(fn:current-dateTime()))-xs:dayTimeDuration("P1D"),"[D01]-[M01]-[Y0001]"))
 
let $uri :=  cts:uris((), (), cts:and-query((
                cts:collection-query($collection),
     			cts:not-query(cts:element-value-query(xs:QName("PartPropogationStatus"), "NotReplicated")),
				cts:not-query(cts:element-value-query(xs:QName("PartNumber"), "")),
                cts:element-value-query(xs:QName("PartAcquisitionStatus"), "NO"))))

return (fn:count($uri),$uri)