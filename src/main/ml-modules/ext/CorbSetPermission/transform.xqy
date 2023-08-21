(: transform.xqy :)
xquery version "1.0-ml";
declare variable $URI as xs:string external; 
xdmp:document-add-permissions($URI,
(xdmp:permission("rest-reader", "read"),
xdmp:permission("rest-writer", "update")))