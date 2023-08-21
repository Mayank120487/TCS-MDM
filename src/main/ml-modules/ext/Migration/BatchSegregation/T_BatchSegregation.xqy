(: 
{
  "Database": "smart-data-hub-STAGING",
  "port"     : "8015",
  "Author"   : "Mayank Srivastav"
  "Vesion"  : "V1.0"
  "Description": "This module is used to segreegate data to variuos collections to avoid duplicate during migration "
}
:)
xquery version "1.0-ml";
declare namespace OrchestraMigData = "http://alstom.com/OrchestraMigData";
declare option xdmp:mapping "false";
declare variable $URI external;
declare variable $listOfValues_Mig6 := ("ABT","BCN","BGL","BLO","BLR","BPL","BTR","CIM","CSH","ELE","EV6","FBO","FLO","FST","GIB","HST","LHB",
"MOD","OFF","PPA","PTQ","REI","RID","SAV","SES","STO","TRA","TRO","TRT","TUS","UPA","VOF","WOV");
(:declare variable $listOfValues_Mig8 := ("BUD","CSY","ENL","ILI","MEA","NEH","NLI","PLF","PLG","PLI","PLK","PLO","ROI","ROS","SCL","SGS","SMX","SPL","SPN","SSE","SUS");:)
declare variable $listOfValues_Mig8 := ("BUD","ENL","NLI","ROI","ROS","SCL","SGS","SMX","SPL","SPN");
declare variable $listOfValues_Mig5 := ("PLM", "EV6", "CAO", "NEO");
declare variable $listOfExcludedProjectNames := ("PLM", "DMA");
declare variable $listOfOwnerNames := ("Local TIS Solution1", "Official data", "Pre-etude TIS", "Migration");
declare variable $queryLatestRevisionOnly := fn:true();

declare function OrchestraMigData:getMigData8($distinctPartNumbers as xs:string*) {
  for $partNumber in $distinctPartNumbers
  let $results :=
    for $i at $c in 
      cts:search(
        fn:doc(),
        (: A :)
        cts:and-query((
          (: 1a. Collection Names:)
          cts:or-query((
            cts:collection-query("/sources/CLAMP/BatchLoad")
            
          )), (: 1a :)
          (: 1b. PartNumbers :)
          cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value", "=", $partNumber), (: 1b :)
          (: 3. Owner Names :)
          cts:and-query((       
            cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"),"OwnerName"),
            cts:element-attribute-value-query(xs:QName("Label"), xs:QName("LANG"),"en_us"),
            cts:element-value-query(xs:QName("Label"),"Owner"),
            cts:element-value-query(xs:QName("Value"),$listOfOwnerNames)
          )),
          (: B :)
          cts:or-query((
            (: 4a. Units Project Name:)
            cts:element-query(
              xs:QName("Units"),
                cts:and-query((
                cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"), "ProjectName"),
                cts:element-value-query(xs:QName("Value"),$listOfValues_Mig8)
              ))
            ), (: 4a :)
            (: 4b j5_EtabdemandCreat :)
            cts:and-query ((
              cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"),"j5_EtabdemandCreat"),
              cts:element-value-query(xs:QName("Value"),$listOfValues_Mig8)
            ))(: 4b :)
          ))(: B :)
        )), (: A :)
        (
          cts:index-order(cts:path-reference("/CLAMPPart/Attribute[@CLAMP_ID='Revision']/Value"),"descending")
        )                  
      )
      order by xs:int($i/CLAMPPart/Attribute[@CLAMP_ID="Sequence"]/Value/string()) descending,
                      $i/CLAMPPart/Attribute[@CLAMP_ID="TIMESTAMP"]/Value/string() descending  
      return $i 
  return  $results[1]
};

declare function OrchestraMigData:getMigData6($distinctPartNumbers as xs:string*) {
  for $partNumber in $distinctPartNumbers
  let $results := 
    for $i at $c in
      cts:search(
        fn:doc(),
        (: A :)
        cts:and-query((
          (: 1a. Collection Names:)
          cts:or-query((
            cts:collection-query("/sources/CLAMP/BatchLoad")
          )), (: 1a :)
          (: 1b. PartNumbers :)
          cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value", "=", $partNumber), (: 1b :)
          (: 3. Owner Names :)
          cts:and-query((       
            cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"),"OwnerName"),
            cts:element-attribute-value-query(xs:QName("Label"), xs:QName("LANG"),"en_us"),
            cts:element-value-query(xs:QName("Label"),"Owner"),
            cts:element-value-query(xs:QName("Value"),$listOfOwnerNames)
          )),
          (: B :)
          cts:or-query((
            (: 4a. Units Project Name:)
            cts:element-query(
              xs:QName("Units"),
                cts:and-query((
                cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"), "ProjectName"),
                cts:element-value-query(xs:QName("Value"),$listOfValues_Mig6)
              ))
            ), (: 4a :)
            (: 4b j5_EtabdemandCreat :)
            cts:and-query ((
              cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"),"j5_EtabdemandCreat"),
              cts:element-value-query(xs:QName("Value"),$listOfValues_Mig6)                                           
            ))(: 4b :)
          ))(: B :)
        )), (: A :)
        (
          cts:index-order(cts:path-reference("/CLAMPPart/Attribute[@CLAMP_ID='Revision']/Value"),"descending")
        ) 
      )
      order by xs:int($i/CLAMPPart/Attribute[@CLAMP_ID="Sequence"]/Value/string()) descending,
                      $i/CLAMPPart/Attribute[@CLAMP_ID="TIMESTAMP"]/Value/string() descending  
      return $i 
    return  $results[1]  
};

declare function OrchestraMigData:getMigData5($distinctPartNumbers as xs:string*) {
  for $partNumber in $distinctPartNumbers
  let $results := 
    for $i at $c in
      cts:search(
        fn:doc(),
        (: A :)
        cts:and-query((
          (: 1a. Collection Names:)
          cts:or-query((
            cts:collection-query("/sources/CLAMP/BatchLoad")
          )), (: 1a :)
          (: 1b. PartNumbers :)
          cts:path-range-query("/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value", "=", $partNumber), (: 1b :)
          (: 3. Owner Names :)
          cts:and-query((       
            cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"),"OwnerName"),
            cts:element-attribute-value-query(xs:QName("Label"), xs:QName("LANG"),"en_us"),
            cts:element-value-query(xs:QName("Label"),"Owner"),
            cts:element-value-query(xs:QName("Value"),$listOfOwnerNames)
          )),
          (: B :)
          cts:or-query((
            (: 4a. Units Project Name:)
            cts:element-query(
              xs:QName("Units"),
                cts:and-query((
                cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"), "ProjectName"),
                cts:element-value-query(xs:QName("Value"),$listOfValues_Mig5)
              ))
            ), (: 4a :)
            (: 4b j5_EtabdemandCreat :)
            cts:and-query ((
              cts:element-attribute-value-query(xs:QName("Attribute"), xs:QName("CLAMP_ID"),"j5_EtabdemandCreat"),
              cts:element-value-query(xs:QName("Value"),$listOfValues_Mig5)                                           
            ))(: 4b :)
          ))(: B :)
        )),(: A :)
        (
          cts:index-order(cts:path-reference("/CLAMPPart/Attribute[@CLAMP_ID='Revision']/Value"),"descending")
        ) 
      )
      order by xs:int($i/CLAMPPart/Attribute[@CLAMP_ID="Sequence"]/Value/string()) descending,
                      $i/CLAMPPart/Attribute[@CLAMP_ID="TIMESTAMP"]/Value/string() descending  
      return $i 
    return  $results[1]  
};

let $partNumber := fn:doc($URI)/CLAMPPart/Attribute[@CLAMP_ID='PartNumber']/Value/string()
let $isPartProcessed := cts:search(fn:collection("temp_orchestra_distinct_partnum_rv3"),cts:element-value-query(xs:QName("PartNumber"),$partNumber))

return 
  
  if(fn:empty($isPartProcessed)) then

    let $partSearchPPLUri :=  cts:search(fn:collection("ppl_parts_lookup_collection_v3"),cts:element-value-query(xs:QName("PartNumber"),$partNumber))/document-uri()
    let $partSearchGSIUri := cts:search(fn:collection("gsi_parts_lookup_collection_v1"),cts:element-value-query(xs:QName("MATNR"),$partNumber))[1]/document-uri()
    
    let $mig5Uri := OrchestraMigData:getMigData5($partNumber)/document-uri()
    let $mig6Uri := OrchestraMigData:getMigData6($partNumber)/document-uri()
    let $mig8Uri := OrchestraMigData:getMigData8($partNumber)/document-uri()

    let $existIn_4 := fn:exists($partSearchPPLUri)
    let $existIn_7 := fn:exists($partSearchGSIUri)
    let $existIn_5 := fn:exists($mig5Uri)
    let $existIn_6 := fn:exists($mig6Uri)
    let $existIn_8 := fn:exists($mig8Uri)
   
    let $temp_ :=
      if ($existIn_4) then
        (xdmp:document-insert("/OrachestraMig"||$partSearchPPLUri, element URI {$partSearchPPLUri},map:map() => map:with("collections","orchestra_all_ppl_parts_rv3")),"Mig 4 - All PPL parts - MIG -4"||"--"||$partSearchPPLUri)
      else if ($existIn_5) then 
        (xdmp:document-insert("/OrachestraMig"||$mig5Uri, element URI {$mig5Uri},map:map() => map:with("collections","orchestra_subscribed_by_PLM_EV6_NEO_CAO_rv3")),"MIG 5 - parts subscribed by PLM EV6 NEO CAO") 
      else if ($existIn_6) then 
        (xdmp:document-insert("/OrachestraMig"||$mig6Uri, element URI {$mig6Uri},map:map() => map:with("collections","orchestra_subscribed_by_33_trigrams_rv3")),"MIG 6 - All parts subscribed by a unit used to propagate to a active DMA server. 33 trigrams")  
      else if ($existIn_8) then 
        (xdmp:document-insert("/OrachestraMig"||$mig8Uri, element URI {$mig8Uri},map:map() => map:with("collections","orchestra_subscribed_railsys_rv3")),"MIG 8 - subscribed to unit link to Railsys")
      else if ($existIn_7) then
        (xdmp:document-insert("/OrachestraMig"||$partSearchGSIUri, element URI {$partSearchGSIUri},map:map() => map:with("collections","orchestra_all_gsi_parts_rv3")),"Mig 7 - GSI Match - MIG -7"||"--"||$partSearchGSIUri)
      else 
        (xdmp:document-insert("/OrachestraMig"||$URI, element URI {$URI},map:map() => map:with("collections","orchestra_no_criretia_match_rv3")),"No Criteria Match"||"--"||$URI)

    let $_ := if ($existIn_4) then (xdmp:document-insert("/VolumetricPPLDataCount"||$partSearchPPLUri, element URI {$partSearchPPLUri},map:map() => map:with("collections","VOL_subscribed_by_PPL_rv3")),"MIG 4 - parts subscribed by PPL") 
      else ()
    let $_ := if ($existIn_5) then (xdmp:document-insert("/VolumetricPLMDataCount"||$mig5Uri, element URI {$mig5Uri},map:map() => map:with("collections","VOL_subscribed_by_PLM_EV6_NEO_CAO_rv3")),"MIG 5 - parts subscribed by PLM EV6 NEO CAO") 
      else ()
    let $_ := if ($existIn_6) then (xdmp:document-insert("/VolumetricTrigramsDataCount"||$mig6Uri, element URI {$mig6Uri},map:map() => map:with("collections","VOL_subscribed_by_33_trigrams_rv3")),"MIG 6 - All parts subscribed by a unit used to propagate to a active DMA server. 33 trigrams") 
      else ()
    let $_ := if ($existIn_8) then (xdmp:document-insert("/VolumetricRailsysDataCount"||$mig8Uri, element URI {$mig8Uri},map:map() => map:with("collections","VOL_subscribed_railsys_rv3")),"MIG 8 - subscribed to unit link to Railsys") 
      else ()
    let $_ := if ($existIn_7) then (xdmp:document-insert("/VolumetricGSIDataCount"||$partSearchGSIUri, element URI {$partSearchGSIUri},map:map() => map:with("collections","VOL_all_gsi_parts_rv3")),"Mig 7 - GSI Match") 
      else ()
    
    return (xdmp:document-insert("/Temp_OrachestraMig_rv3/"||$partNumber||".xml", element PartNumber {$partNumber},
                          map:map() => map:with("collections","temp_orchestra_distinct_partnum_rv3")),"Distinct Part Numbers"||"--"||$partNumber)  
  
  else
    (xdmp:document-insert("/OrachestraMigDuplicate_rv4"||$URI, element URI {$URI},map:map() => map:with("collections","temp_orchestra_duplicate_rv4")),"Duplicate Values"||"--"||$URI)