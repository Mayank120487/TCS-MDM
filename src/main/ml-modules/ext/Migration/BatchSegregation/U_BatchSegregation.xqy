(: 
{
  "Database": "smart-data-hub-STAGING",
  "port"     : "8015",
  "Author"   : "Mayank Srivastav"
  "Vession"  : "V1.0"
}
:)
xquery version "1.0-ml";
declare option xdmp:mapping "false";

let $allUri := 
  cts:uris("",(),
    cts:or-query((
      (:cts:collection-query("/sources/CLAMP"),
      cts:collection-query("/sources/CLAMP/processed"):)
      cts:collection-query("/sources/CLAMP/BatchLoad")
    ))
  )
return (fn:count($allUri), $allUri)