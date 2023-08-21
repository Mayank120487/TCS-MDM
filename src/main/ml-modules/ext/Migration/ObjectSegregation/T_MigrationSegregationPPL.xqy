xquery version "1.0-ml";
import module namespace Migration = "Migration" at "/Orchestra/Migration/M_ObjectSegregation.xqy";
declare variable $batch external;      (:"orchestra_all_ppl_parts_rv3";:)
declare variable $URI external;
declare variable $FINAL_DB := "smart-data-hub-FINAL";

for $partNumber in fn:doc(fn:doc($URI(:$uris batch URI:))/URI)/root/PartNumber/string()
let $objects := xdmp:invoke-function(
                                function() { 
                                    let $uri := cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partNumber))/document-uri()
                                    let $part := document {
                                <DATA>
                                      {
                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processPart($uri)
                                      }
                                </DATA>
                                             }

                        let $partManufacturer := document {
                                <DATA>
                                      {
                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processManufacturer($uri)
                                      }
                                </DATA>               
                                                          }


                        let $partcomposedby := document {
                                <DATA>
                                        {

                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processComposedby($uri)
                                        }
                               </DATA>                  }


                               let $partcustomer := document {
                                <DATA>{

                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processCustomer($uri)
                                        }
                                        </DATA>}

                               let $familyparts := document {
                                <DATA>{

                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processFamily($uri)
                                        }
                                        </DATA>}

                              let $familyclassification := document {
                                <DATA>{

                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processFamilyClassification($uri)
                                        }
                                        </DATA>}
                              
                              let $units := document {
                                  <DATA>{

                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processUnits($uri)
                                        }
                                        </DATA>}

                               let $projectforparts := document {
                                  <DATA>{

                                        let $partfrombatch := $partNumber
                                        return 
                                        for $uri in cts:search(fn:collection("Orchestra"),cts:element-value-query(xs:QName("PartNumber"),$partfrombatch))/document-uri()
                                        return Migration:processProjects($uri)
                                        }
                                        </DATA>}
                              


                        return (:
                        xdmp:document-insert("Migration/"||$batch||"/parts"||$uri,$part,map:map() => map:with("collections","M_"||$batch||"_parts")),
                        xdmp:document-insert("Migration/"||$batch||"/partManufacturer"||$uri,$partManufacturer,map:map() => map:with("collections","M_"||$batch||"_partManufacturer")),
                        xdmp:document-insert("Migration/"||$batch||"/partcomposedby"||$uri,$partcomposedby,map:map() => map:with("collections","M_"||$batch||"_partcomposedby")),
                        xdmp:document-insert("Migration/"||$batch||"/partcustomer"||$uri,$partcustomer,map:map() => map:with("collections","M_"||$batch||"_partcustomer")),
                        xdmp:document-insert("Migration/"||$batch||"/familyparts"||$uri,$familyparts,map:map() => map:with("collections","M_"||$batch||"_familyparts")),
                        xdmp:document-insert("Migration/"||$batch||"/familyclassification"||$uri,$familyclassification,map:map() => map:with("collections","M_"||$batch||"_familyclassification"))
                        :)
                        ($uri[1],$part,$partManufacturer,$partcomposedby,$partcustomer,$familyparts,$familyclassification,$units,$projectforparts)
                        },
                            <options xmlns="xdmp:eval">
                            <database>{xdmp:database($FINAL_DB)}</database>
                            </options>
                            )
return 
      let $uri := $objects[1]
      let $part := $objects[2]
      let $partManufacturer := $objects[3]
      let $partcomposedby := $objects[4]
      let $partcustomer := $objects[5]
      let $familyparts := $objects[6]
      let $familyclassification := $objects[7]
      let $units := $objects[8]
      let $projectforparts := $objects[9]
      return(
      xdmp:document-insert("Migration/"||$batch||"/parts"||$uri,$part,map:map() => map:with("collections","M_"||$batch||"_parts")),
      xdmp:document-insert("Migration/"||$batch||"/partManufacturer"||$uri,$partManufacturer,map:map() => map:with("collections","M_"||$batch||"_partManufacturer")),
      xdmp:document-insert("Migration/"||$batch||"/partcomposedby"||$uri,$partcomposedby,map:map() => map:with("collections","M_"||$batch||"_partcomposedby")),
      xdmp:document-insert("Migration/"||$batch||"/partcustomer"||$uri,$partcustomer,map:map() => map:with("collections","M_"||$batch||"_partcustomer")),
      xdmp:document-insert("Migration/"||$batch||"/familyparts"||$uri,$familyparts,map:map() => map:with("collections","M_"||$batch||"_familyparts")),
      xdmp:document-insert("Migration/"||$batch||"/familyclassification"||$uri,$familyclassification,map:map() => map:with("collections","M_"||$batch||"_familyclassification")),
      xdmp:document-insert("Migration/"||$batch||"/units"||$uri,$units,map:map() => map:with("collections","M_"||$batch||"_units")),
      xdmp:document-insert("Migration/"||$batch||"/projectforparts"||$uri,$projectforparts,map:map() => map:with("collections","M_"||$batch||"_projectforparts"))

)
