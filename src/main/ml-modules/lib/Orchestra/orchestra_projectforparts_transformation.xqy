xquery version "1.0-ml";
module namespace projectforparts = "projectforparts";

declare function projectforparts:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
    ""
  else 
    let $retVal := fn:replace($valStr,"&amp;","&amp;")
    let $retVal := fn:replace($retVal,"<","&lt;")
    let $retVal := fn:replace($retVal,">","&gt;")
   return $retVal
};

declare function projectforparts:transCheckValueForHypens($varVal) {
  if(fn:empty($varVal)) then
      ""
  else if($varVal eq "--") then
    ""
  else 
    $varVal 
};

  declare function projectforparts:transProjectId($ProjectIds)  {
   for $ProjectId in $ProjectIds
     let $res := projectforparts:transCheckValueForHypens($ProjectId)
  return $res
    };

 declare function projectforparts:transOriginate($Originate,$ProjectClampNames)
  {
 if(fn:not(fn:empty($ProjectClampNames)))
then
 (let $Res := 
                for $ProjectClampName in $ProjectClampNames
                                         return 
                                             if($ProjectClampName = $Originate) then
                                                "true"
                                         else
                                                "false"
               return $Res
               )
  else
     ""
  };

declare function projectforparts:getProjects($partResult) {
  let $Projects := $partResult/Projects/Project
  return $Projects  
};

(:======================================================================================================:)

declare function projectforparts:process($uri) {
  let $result := fn:doc($uri)/CLAMPPart
  let $Projects := projectforparts:getProjects($result)

 return (
     <PROJECTS>
 {
    for $Project in $Projects
        let $PartNumber := $result/Attribute[@CLAMP_ID="PartNumber"]/Value/text()

        let $Projectid := $result/$Project/Attribute[@CLAMP_ID="j5_NomPrj"]/Value/text()
        let $lst_ProjectId  := projectforparts:transProjectId($Projectid)
       
        let $Originate := projectforparts:transCheckValueForHypens($result/Attribute[@CLAMP_ID="j5_Projet"]/Value/text())
        let $Originate := projectforparts:transOriginate($Originate,$Projectid)

        return      
           <PROJECT> 
             <partNumber>{$PartNumber}</partNumber>
             <projectId>{$lst_ProjectId}</projectId>
             <safetyClassificationId>{}</safetyClassificationId>
             <safetyJustificationComment>{}</safetyJustificationComment>
             <attachment>{}</attachment>
             <traceability>{}</traceability>
             <originate>{$Originate}</originate>
           </PROJECT>
           }
      </PROJECTS>
       )
        
  };
