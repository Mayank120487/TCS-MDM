xquery version "1.0-ml";

declare variable $URI external;

let $collection := fn:concat("/Orchestra/Delta/",fn:format-dateTime(fn:current-dateTime(),"[D01]-[M01]-[Y0001]"))

for $uri in $URI 
			            
return xdmp:document-add-collections($uri, $collection)
   
   
  
