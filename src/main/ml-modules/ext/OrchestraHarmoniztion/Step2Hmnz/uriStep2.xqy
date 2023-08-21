xquery version "1.0-ml";
declare namespace es = "http://marklogic.com/entity-services";
let $deltaClampCollection :=  xs:string(fn:concat("/CLAMP/Delta/",fn:format-date(fn:current-date(),"[D01]-[M01]-[Y0001]")))
let $partNumber := cts:values(cts:path-reference("/es:envelope/*:headers/PartNumber"),(),(),cts:or-query((cts:collection-query("/final/Orchestra/CLAMP"),
                                                                                                             cts:collection-query("/final/Orchestra/PLMSIG"),
                                                                                                             cts:collection-query("/final/Orchestra/ONEDMA")
                       (: cts:element-value-query(xs:QName("clampControllingUnit"),"PLM"):)
                        ))
                        )

return (fn:count($partNumber),$partNumber)