xquery version "1.0-ml";
module namespace partstranformation = "partstranformation";
import module namespace partvalidation="partvalidation" at "/Orchestra/orchestra_validation.xqy";
import module namespace partsmanuftranformation = "partsmanuftranformation" at "/Orchestra/orchestra_parts_manuf_transformation.xqy";
import module namespace partcomposedbytranformation = "partcomposedbytranformation" at "/Orchestra/orchestra_parts_composedby_transformation.xqy";
import module namespace partcustomertranformation = "partcustomertranformation" at "/Orchestra/orchestra_parts_coustomer_transformation.xqy";
import module namespace familyattributevaluetranformation = "familyattributevaluetranformation" at "/Orchestra/orchestra_parts_familyAttribute_transformation.xqy";
import module namespace familyclassificationlinktransformation = "familyclassificationlinktransformation" at "/Orchestra/orchestra_parts_familyClassificationLink_transformation.xqy";
import module namespace usingunits = "usingunits" at "/Orchestra/orchestra_parts_using_units.xqy";
import module namespace projectforparts = "projectforparts" at "/Orchestra/orchestra_projectforparts_transformation.xqy";
import module namespace queries = "http://alstom.com/Orchestra/Queries" at "/Orchestra/Queries.xqy";

declare variable $PartFormURL :=  "http://iww.clamp.alstom.com/POTW/POTW?Action=getCLAMPPartForm&amp;DTRCode=";
  

  declare function partstranformation:replaceForbiddenChars($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
      ""
    else 
      let $retVal := fn:replace($valStr,"&amp;","&amp;")
      let $retVal := fn:replace($retVal,"<","&lt;")
      let $retVal := fn:replace($retVal,">","&gt;")
    
    return $retVal
  };

  declare function partstranformation:replaceFirst($arg as xs:string? , $pattern as xs:string , $replacement as xs:string) as xs:string*{
    if(fn:empty($arg)) then 
      ""
    else
      fn:replace($arg, concat('(^.*?)', $pattern), concat('$1',$replacement))
  };

  declare function partstranformation:transRepairable($valStr as xs:string?) as xs:string {
    (: TransRule: True => Yes
                  False => No
                  Blank => Blank 
    :)  
    if(fn:empty($valStr)) then
      ""
    else if(fn:lower-case($valStr) = "true" or $valStr = "+" or fn:lower-case($valStr) = "yes") then
      "true"
    else if(fn:lower-case($valStr) = "false" or $valStr = "-" or fn:lower-case($valStr) = "no") then
      "false"
    else
      ""
  };

  declare function partstranformation:transDoesContainCombustible($valStr as xs:string?) as xs:string {
    (: TransRule: True => Yes
                  False => No
                  Blank => Blank 
    :)  
    if(fn:empty($valStr)) then
      ""
    else if(fn:lower-case($valStr) = "true" or $valStr = "+" or fn:lower-case($valStr) = "yes") then
      "true"
    else if(fn:lower-case($valStr) = "false" or $valStr = "-" or fn:lower-case($valStr) = "no") then
      "false"
    else
      ""
  };
  
  declare function partstranformation:convertDate($valStrDate as xs:string?) as xs:string {
    (: TransRule: 
      Change the date format to dd/mm/yyyy 
    :)
    if(fn:empty($valStrDate)) then
      ""
    else if($valStrDate = "" or $valStrDate = "--") then
      ""
    else 
      try{
        (
          let $timestamp-parsed := xdmp:parse-dateTime("[Y0001]/[M01]/[D01]", $valStrDate)
          return fn:format-dateTime($timestamp-parsed, "[M01]/[D01]/[Y0001]")
        )
      } catch($err) { 
       "invalid date format"
      }  
  };

  declare function partstranformation:transUnitOfMeasure($valStr as xs:string?) as xs:string {
    (:
      UN => EA
      F2 => FT2
      GL => GAL
      H87 - EA => EA
    :)
    if(fn:empty($valStr)) then
      ""
    else if(fn:lower-case($valStr) = "un") then
      "EA"
    else if(fn:lower-case($valStr) = "f2") then
      "FT2"
    else if(fn:lower-case($valStr) = "gl") then
      "GAL"
    else if(fn:lower-case($valStr) = "h87 - ea") then
      "EA"
    else
      $valStr     
  };

    declare function partstranformation:transMass($valStr as xs:string?) as xs:string {
        if(fn:empty($valStr)) then
          ""
        else if($valStr eq "--") then
          ""  
        else if (fn:not(fn:matches($valStr, '^[0-9]\d{0,9}(\.\d*)?%?$'))) then
          ""
        else
          $valStr
      };

    (: PartType --> "transPartType" Function has been changed, Removed "checkNull" Function and Added "isDocAttached" Function :)
    declare function partstranformation:transPartType($PartType as xs:string?, $MakeBuyIndicator as xs:string?, $docAttached as xs:string?,$Units) as xs:string? {
    (:
      Off-the-shelf : PsmIndBuy 
      Specific : PsmIndMake

      Off-the-shelf part : j5CmpLif
      Specific Part : j5Manuf
      Assembled  part : j5AsbPrt
      Spare or Smoke/Flame part : j5CmpRch
      Part CLAMP-DMA : j5PrtDMA
      Skeletal/Configurable: j5CmpPar
      Parametrized Part : j5CmpPaD
  
      Class                                   MakeBuyIndicator                        DocAttached                          Part Type
      ====================================================================================================================================================================
      Off-the-shelf part (j5CmpLif)           Off-the-Shelf (PsmIndBuy)                                                       Standard Part (COTS)
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Specific part (j5Manuf)                                                 Yes or (with subscription                      Part to Specification (CoS)    ( Changes as per new requirement 
                                                                              to these units PLM, DMA, NEO, EV6)                                               made on 09/12/2021 )                     
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Specific part (j5Manuf)                                                           No                                    Standard Part (COTS)
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Assembled part (j5AsbPrt)               Specific (Always Specific) (PsmIndMake)                                         ALSTOM Design Part
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Spare or Smoke/Flame part (j5CmpRch)    Off-the-Shelf (PsmIndBuy)                                                       Standard Part (COTS)
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Spare or Smoke/Flame part (j5CmpRch)    Specific (PsmIndMake)              Yes or (with subscription                     Part to Specification (CoS)   ( Changes as per new requirement
                                                                                to these units PLM, DMA, NEO, EV6)                                              made on 09/12/2021 )      
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Spare or Smoke/Flame part (j5CmpRch)    Specific (PsmIndMake)                    No                                     Standard Part (COTS)
      ------------------------------------------------------------------------------------------------------------------------------------------------
      CLAMP-DMA part (j5PrtDMA)                                                                                                 ALSTOM Design Part
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Skeletal/Configurable part(j5CmpPar)                                                                                       ALSTOM Design Part
      ------------------------------------------------------------------------------------------------------------------------------------------------
      Parametrized Part (j5CmpPaD)                                                                                                ALSTOM Design Part
      ------------------------------------------------------------------------------------------------------------------------------------------------
    :)
    let $strDocAttached :=
      if($docAttached eq "") then "no"
      else $docAttached

    return 
      if(fn:empty($MakeBuyIndicator) and fn:empty($PartType)) then
        ""
      else if($PartType eq "j5CmpLif" and $MakeBuyIndicator eq "PsmIndBuy") then
        "Standard Part (COTS)"
      else if($PartType eq "j5Manuf" and ($strDocAttached eq "yes" or $Units eq "PLM" or $Units eq "DMA" or $Units eq "EV6" or $Units eq "NEO" or $Units eq "NO1" or $Units eq "NO2" or $Units eq "NO3" or $Units eq "NO4" or $Units eq "NO5")) then
        "Part to Specification (CoS)"
      else if($PartType eq "j5Manuf" and $strDocAttached eq "no") then
        "Standard Part (COTS)"
      else if($PartType eq "j5AsbPrt" and $MakeBuyIndicator eq "PsmIndMake" ) then
        "ALSTOM Design Part"
      else if($PartType eq "j5CmpRch" and $MakeBuyIndicator eq "PsmIndBuy" ) then
        "Standard Part (COTS)"
      else if($PartType eq "j5CmpRch" and $MakeBuyIndicator eq "PsmIndMake" and ($strDocAttached eq "yes" or $Units eq "PLM" or $Units eq "DMA" or $Units eq "EV6" or $Units eq "NEO" or $Units eq "NO1" or $Units eq "NO2" or $Units eq "NO3" or $Units eq "NO4" or $Units eq "NO5")) then
        "Part to Specification (CoS)"
      else if($PartType eq "j5CmpRch" and $MakeBuyIndicator eq "PsmIndMake" and $strDocAttached eq "no") then
        "Standard Part (COTS)" 
      else if($PartType eq "j5PrtDMA" or $PartType eq "j5CmpPar" or $PartType eq "j5CmpPaD") then
        "ALSTOM Design Part"
      else ""
  };

declare function partstranformation:transNafp($result) {
    let $retNafp := $result/Attribute[@CLAMP_ID="j5NonAlstomFleetPrt"]/RealValue/text()
    return 
      if(fn:not(fn:exists($retNafp))) then
        "false"
        (: 17-09-2021 UAT Issue #12 :)
     (: else if(fn:not(fn:empty($retNafp))) then
        "false" :)
      else if($retNafp eq "--") then
        "false"
      else if(fn:lower-case($retNafp) eq "true" or $retNafp eq "+" or fn:lower-case($retNafp) eq "yes") then
        "true"
      else if(fn:lower-case($retNafp) eq "false" or $retNafp eq "-" or fn:lower-case($retNafp) eq "no") then
        "false"
        else ("false")
  };


 (: Make buy indicator :)
declare function partstranformation:transMakeOrBuy($PartType as xs:string?, $NAFP as xs:string?, $ProjectName as xs:string) as xs:string? { (:add NAFP:)
    (:
      $PartType:
      class 'Off-the-shelf'(j5CmpLif)    => "For Detailed Design"
      class 'specific'(j5Manuf) in CLAMP => "For Detailed Design"
      class 'Spare or Smoke/Flame Part'(j5CmpRch) and attribute NAFP not equal to FALSE/BLANK => "For Purchase Only" --- NAFP Not available + "For Purchase Only" invalid value
      class 'Spare or Smoke/Flame Part'(j5CmpRch) and attribute NAFP equal to TRUE => "Non Alstom Fleet Part" ------ NAFP Not available
      class 'Assembled Part'(j5AsbPrt) => empty or unidentified
	  
	  Drop - 2   (:newly added :)
			(System Master = DMA => should be ""for purchase only"")
			(System Master= CLAMP => should be ""for detailed design"")
			(System Master = PLM => should be ""for detailed design)

    :)
    if(fn:empty($PartType)) then
      ""
    else if($PartType = "j5CmpLif") then
      "For Detailed Design" 
    else if($PartType = "j5Manuf") then
      "For Detailed Design"
    else if($PartType = "j5CmpRch" and fn:lower-case($NAFP) = "false") then
      "For Purchase Only"
    else if($PartType = "j5CmpRch" and fn:lower-case($NAFP) = "true") then
      "Non ALSTOM Fleet Part"
    
	else if(($PartType = "j5CmpPaD" or $PartType = "j5CmpPar" or $PartType= "j5PrtDMA" or $PartType = "j5AsbPrt") and $ProjectName = "DMA") then
	  "For Purchase Only"
	else if(($PartType = "j5CmpPaD" or $PartType = "j5CmpPar" or $PartType= "j5PrtDMA" or $PartType = "j5AsbPrt") and $ProjectName = "CLAMP") then
	  "For Detailed Design"
	else if(($PartType = "j5CmpPaD" or $PartType = "j5CmpPar" or $PartType= "j5PrtDMA" or $PartType = "j5AsbPrt") and $ProjectName = "PLM") then
	  "For Detailed Design"
    else if($PartType = "j5AsbPrt") then
      ""
    else ""
  };

  declare function partstranformation:transRestrictedPart($valStr as xs:string?) as xs:string {
    (:TransRule:  Forbidden in new BOM's => Not permitted in new design
                  Absolute forbidden => Part Blocked to prevent Use
                  Use with restriction => Use with restriction
                  If blank/empty in CLAMP => No restrictions
    :)
    if(fn:empty($valStr)) then
        "No restrictions" 
      else if(fn:upper-case($valStr) = "FORBIDDEN IN NEW BOM'S") then
        "Not permitted in new design"
      else if(fn:upper-case($valStr) = "ABSOLUTE FORBIDDEN") then
        "Part Blocked to prevent Use" 
      else if(fn:upper-case($valStr) = "USE WITH RESTRICTION") then
        "Use with restriction"
      else if($valStr = "" or $valStr = "--") then
        "No restrictions"  
      else
        $valStr
  };

   (: Duplicate --> "transDuplicate" Function has been changed, 28/07/21: removed the check for other status type apart from Duplicate :)
  declare function partstranformation:transDuplicate($valStr as xs:string?) as xs:string {
    (:TransRule:
    If Calamp value is Duplicate,Current,End of Life,On Hold,In Introduction,Obsolete => true
    Else => false :)

    if(fn:empty($valStr)) then
      ""    
    else if(fn:upper-case($valStr) eq "DUPLICATE") then
      "true"
    else
      "false"
  };


     (: PartLifecycleStatus --> transPartLifeCycle has been changed :)
  declare function partstranformation:transPartLifeCycle ($ProdLifecycleStatus as xs:string?, $result) as xs:string {
    (:TransRule: If "Product Lifecycle" value available in CLAMP then set the same value. 
                  Else compute as per Part Lifecycle Status (j5_PartStatus)
    :)
    if(fn:empty($ProdLifecycleStatus) or $ProdLifecycleStatus = "" or $ProdLifecycleStatus = "--") then  
      let $j5_PartStatus := $result/Attribute[@CLAMP_ID="j5_PartStatus"]/Value[@LANG="en_us"]/text()
      return 
        if(fn:lower-case($j5_PartStatus) = "on hold") then
          "10" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Introduction"
        else if(fn:lower-case($j5_PartStatus)  = "current") then
          "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current"
        else if(fn:lower-case($j5_PartStatus)  = "end of life") then
          "70" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "End of Life"
        else if(fn:lower-case($j5_PartStatus)  = "obsolete") then
          "99" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Obsolete"
        else if(fn:lower-case($j5_PartStatus) = "duplicate") then
          "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current"  
        else
          "20" || fn:codepoints-to-string(32) || fn:codepoints-to-string(8211) || fn:codepoints-to-string(32) || "Current"
    else
       partstranformation:replaceJunkCharacters($ProdLifecycleStatus)
      
  };

  declare function partstranformation:replaceJunkCharacters($valStr as xs:string?) as xs:string?{
    if(fn:empty($valStr)) then
      ""
    else
      let $valStr := fn:replace($valStr, "�", "&#8211;")
      let $valStr := fn:replace($valStr, "&#150;", "&#8211;")
      let $valStr := fn:replace($valStr, "-", "&#8211;")
      return $valStr
  };

  declare function partstranformation:transProjectName($valStr) as xs:string {
    (: TransRule: ProjectName
        if PLM or DMA if <Attribute CLAMP_ID="ProjectName">
          <Label LANG="en_us">Control Unit</Label>
          <Value>DMA or PLM</Value>
          </Attribute>
        Else 
          CLAMP
    :)
    if(fn:empty($valStr)) then
      ""
    else if($valStr/Label[@LANG="en_us"]/text() = "Control Unit") then
      let $ProjectName :=  $valStr/Value/text() 
      return 
        if($ProjectName = "DMA" or $ProjectName = "PLM") then
          $ProjectName
        else
          "CLAMP"
    else
      "CLAMP"
  };
    
   (:ReasonForReplacement--> "transReasonForReplacement" Function has been changed:)
  declare function partstranformation:transReasonForReplacement($tmpCLAMPPartReplaceBy as xs:string?, $tmpCLAMPPartStatus as xs:string?, $tmpPartLifecycleStatus  as xs:string?) as xs:string? {
    (:NEW rules:
		  If  "Part Replaced By" is blank, then Reason for Replacement value is <empty>
    	Else as per the mapping/conditions mentioned below:
        - "Duplicate" = Yes in original part => Duplication
		    - "Part Life Cycle Status" = '70-End Of Life' or '80-End Of Life' '80-Extended Support' or '90 - After-Life' or '99-Obsolete' in original part=> Obsolescence
		    - Other cases => To be defined
    :)
    if(fn:empty($tmpCLAMPPartReplaceBy) or $tmpCLAMPPartReplaceBy = "") then
      ""
    else if(fn:lower-case($tmpPartLifecycleStatus) = "duplicate") then
      "Duplication"
    else if(fn:lower-case($tmpPartLifecycleStatus) = "obsolete" or fn:lower-case($tmpPartLifecycleStatus)  = "end of life") then
      "Obsolescence"
		(:else if(fn:lower-case($tmpPartLifecycleStatus) = "on hold" or  fn:lower-case($tmpPartLifecycleStatus) = "current" or fn:lower-case($tmpPartLifecycleStatus) = "in introduction") then
      "To be defined" 
    :) 
		else
      "To be defined"
  };
  
  (:transReachWorstCase function changed:)
  declare function partstranformation:transReachWorstCase($valStr) as xs:string {
    (:Orchestra expected values are
      Not Set
      Not complete
      Reach secured
      SVHC criteria
      Candidate
      Annex XIV
      
      and 

      j5REACHW00: <Not Set>      Not Set
      j5REACHW01: <Not Complet>  Not complete
      j5REACHW10: <REACH Secured>Reach secured
      j5REACHW20: <SVHC>         SVHC criteria
      j5REACHW30: <Candidate>    Candidate
      j5REACHW40: <Annexe XIV>   Annex XIV 
  :)
    if(fn:empty($valStr) or $valStr eq "" or $valStr eq "--") then
      "Not Set"
    else if(fn:upper-case($valStr) = "J5REACHW10") then
      "Reach secured"
    else if(fn:upper-case($valStr) = "J5REACHW01") then
      "Not complete"	   
    else if(fn:upper-case($valStr) = "J5REACHW20") then
      "SVHC criteria"
    else if(fn:upper-case($valStr) = "J5REACHW00") then
      "Not Set"
    else if(fn:upper-case($valStr) = "J5REACHW30") then
      "Candidate"
    else if(fn:upper-case($valStr) = "J5REACHW40") then
      "Annex XIV"
    else  
      $valStr
  };

  declare function partstranformation:transOMTECPDNStatus($valStr as xs:string?) {
    (:TransRule: 
      if $OMTECPDNStatus = "-" or "--", then blank
    :)
    if(fn:empty($valStr)) then
      ""
    else if(fn:lower-case($valStr) = "true" or $valStr = "+" or fn:lower-case($valStr) = "yes") then
      "true"
    else if(fn:lower-case($valStr) = "false" or $valStr = "-" or fn:lower-case($valStr) = "no") then
      "false"
    else if($valStr = "--") then
      "false"
    else
      $valStr
  };

  declare function partstranformation:transOMTECPDNLink($OMTECPDNStatus as xs:string?, $OMTECPDNLink  as xs:string?) as xs:string {
    (:TransRule:
      if(OMTECPDNStatus = false)
        ""
      else
      the link mentioned in XML
    :)
    if(fn:lower-case($OMTECPDNStatus) = "false") then ""
    else $OMTECPDNLink
  };

  declare function partstranformation:transCLAMPPartStatus($valStr) as xs:string {
     (: TransRule: The values received from Clamp has has to be Pascal case
    :)
    if(fn:empty($valStr)) then
      ""
    else if(fn:lower-case($valStr) = "current") then
      "Current"
    else if(fn:lower-case($valStr) = "duplicate") then
      "Duplicate"
    else if(fn:lower-case($valStr) = "end of life") then
      "End of Life"
    else if(fn:lower-case($valStr) = "in introduction") then
      "In Introduction"
    else if(fn:lower-case($valStr) = "obsolete") then
      "Obsolete"
    else if(fn:lower-case($valStr) = "on hold") then
      "On Hold"
    else 
      $valStr
  };

  declare function partstranformation:getReplacedByPartNumber($valStr as xs:string?) as xs:string {
    (:result is of format partnumber,revision number,sequence
    :)
    if(fn:empty($valStr)) then
        ""
      else 
        fn:tokenize($valStr, "[,]")[1]
  };

  declare function partstranformation:chkValidValues($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
        ""
    else if (fn:string-length($valStr) != 8) then 
        ""
    else if($valStr = "--") then
        ""
    (: 06-01-2021 PGLS Finding
    else if($valStr = "####") then
        ""
        :)
    else
        $valStr
  }; 
  
  (: PartFormURL --> Changed from () to "" for if(fn:empty($PartFormURL)) condition  :)
  declare function partstranformation:transPartFormURL($PartNumber as xs:string?) as xs:string? {    
    (:
      Suffix the part number to http://iww.clamp.alstom.com/POTW/POTW?Action=getCLAMPPartForm&DTRCode=<PartNumber>
    :)
    if(fn:empty($PartFormURL)) then 
      ""
    else     
      $PartFormURL || $PartNumber
  };

  (:declare function partstranformation:getFamilyName($valResult) as xs:string? {
    (:let $node := cts:path-range-query($valResult/PFMAttributes/Attribute[@LANG='en_us']/Label,"=","Family name (local)")
    return if(fn:exists($node)) then
      ""
    else 
      $node/Value/text() :)
      
    for $x in $valResult/PFMAttributes/Attribute[@LANG="en_us"]
    let $retVal :=  $x/Value/text()
    where $x/Label/text()="Family name (local)"
    return $retVal
  };:)

(:05-08-21:Nodified the function to get Faminly Name using UNSPSC and System Master:)
(: 23-09-2021 Removing this funtion as we are calling this from "Queries.xqy" for "CLAMP", "PLM", "ONEDMA" :)

(: declare function partstranformation:getFamilyName($systemMaster, $unspsc) {
 

let $systemMaster := if ($systemMaster = "CLAMP") then "Orchestra Branch"
                     else if ($systemMaster = "DMA") then "DMA Branch"
                     else if ($systemMaster = "PLM") then "PLM Branch"
                     else()

let $node := cts:search(fn:collection("familyid_lookup_collection"),cts:and-query((
                  cts:element-value-query(xs:QName("Branch_Family"), $systemMaster),
                  cts:element-value-query(xs:QName("UNSPSC_-_UNSPSC"), $unspsc),
                  cts:element-value-query(xs:QName("Type"),"Leaf Family")
                )))[1]
return
    if(fn:empty($node)) then
      ()     
    else if(fn:empty($node//Family_Name_English/string())) then
      () 
    else $node//Family_Name_English/string() 
               
}; :)


  declare function partstranformation:getPartRevison($valRes) as xs:string* {
    (: New TransRule 
        If TISIndex = Blank/"", use Revsion
        Else use TISIndex
    :)
    let $PartRevision := $valRes/Attribute[@CLAMP_ID="j5_IndiceTIS"]/Value/text()
    return 
      if(fn:empty($PartRevision) or $PartRevision ="" or $PartRevision="--") then
        $valRes/Attribute[@CLAMP_ID="Revision"]/Value/text()
      else
        $PartRevision
  };

  declare function partstranformation:transCLAMPPPLFlag($valRes) as xs:string {
    (:
      Check for j5_FamilyGrpUser (<PPLs><PPL> <Attribute CLAMP_ID="j5_FamilyGrpUser">) exists
        count is > 0 (i.e at least one)
        Clamp PPL = true (i.e Local PPL)
      OR
        Clamp PPL = False
        ### New logic to be added fotr Drop 2 
        if (subscribed by CMF AND attriute at Unit level is true) for preferred then True
        Else False
        ###
    :)
    let $countOfPPLs := fn:count($valRes/PPLs/PPL/Attribute[@CLAMP_ID='j5_FamilyGrpUser'])
    return 
      if ($countOfPPLs > 0) then
        "true" 
      else 
        let $isPreferred := 
          for $unit in $valRes/Units/Unit
          where $unit/Attribute[@CLAMP_ID = "ProjectName"]/Value/text() = 'CMF'
          return $unit/Attribute[@CLAMP_ID="j5_EtabPref"]/RealValue/text()
        return 
          if($isPreferred = "+") then
            "true"
          else 
            "false"
  };

  (:===========================================================================================
    DROP 2 ATTRIBUTE FUNCTIONS STARTS
  ============================================================================================:)
  declare function partstranformation:getSuppliers($valResult) {
    let $lstSuppliers := 
      for $supplier in $valResult/Suppliers/Supplier
      where $supplier/Attribute[@CLAMP_ID="j5_ChoixRelFourFab"]/RealValue/text()='j5Choix1'
      return $supplier
    return $lstSuppliers  
  };

  declare function partstranformation:checkNull($valStr){
    if(fn:empty($valStr)) then
      ""
    else
      $valStr
  };

(: clampMaterial--> replaced  "&#13;" to "," separating values:)
  declare function partstranformation:transClampMaterial($valRes) as xs:string {
    let $clampMaterial := $valRes/Materials/Material/Attribute[@CLAMP_ID="j5_TraductionEN"]/Value/text()
    return fn:string-join($clampMaterial,",")
  };

  declare function partstranformation:transClampProject($valRes) as xs:string {
    let $clampProject := $valRes/Projects/Project/Attribute[@CLAMP_ID="j5_NomPrj"]/Value/text()
    return fn:string-join($clampProject,"&#13;")
  };

  (:clampProtection--> replaced "&#13;" to "," separating values:)
  declare function partstranformation:transClampProtection($valRes) as xs:string {
    let $clampProtection := $valRes/Protections/Protection/Attribute[@CLAMP_ID="j5_TraductionEN"]/Value/text()
    return fn:string-join($clampProtection,",")
  };
  
  declare function partstranformation:transSupplierName($valSupplierRes) as xs:string {
    let $supplierName := $valSupplierRes/Attribute[@CLAMP_ID="j5_NomFournisseur"]/Value/text()
    return fn:string-join($supplierName,"&#13;")
  };

  declare function partstranformation:transSupplierPartRef($valSupplierRes) as xs:string {
    let $supplierPartRef := $valSupplierRes/Attribute[@CLAMP_ID="j5_RefArtFourn"]/Value/text()
    return fn:string-join($supplierPartRef,"&#13;")
  };

   (:standards--> replaced () with "" for else condition , 28/07/21: changed the CLAMP_ID to j5_Referencenorme:)
  declare function partstranformation:transStandard($valStr) {
    let $StandardElement := $valStr/Standards/Standard/Attribute[@CLAMP_ID = "j5_Referencenorme"]/Value/text()
    let $Standards :=
      for $s in $StandardElement
        return 
          if ($s ne "--") then $s
          else ""    
    (:return fn:string-join($Standards,"&#13;"):)
    return $Standards
  };

   (:PartLifecycleStatusMonitored--> replaced () to "" for else condition:)
  declare function partstranformation:transPartLifecycleStatusMonitored($resSuppliers, $PartType) {
(: Transrule: If value is -- or Blank ==> false
Else true
:)
  let $lstMpnMonitored :=
                        for $mpn in $resSuppliers/Attribute[@CLAMP_ID="j5_StatutReference"]/RealValue/text()
                        return
                                  if(($mpn eq "j5StRefTT") or ($mpn eq "j5StRefWP")) then
                                  "false"
                                  else if (($mpn eq 'j5StRefI') or ($mpn eq 'j5StRefS') or ($mpn eq 'j5StRefM') or ($mpn eq 'j5StRefOA') or ($mpn eq 'j5StRefOH') or ($mpn eq 'j5StRefR') or ($mpn eq 'j5StRefOF')) then
                                  "true"
                                  else
                                  ""
  return
          if("true" = $lstMpnMonitored) then
          "true"
          else if ($PartType eq "ALSTOM Design Part") then
          "true"
          else
          "false"
(:if(fn:contains($mpnMonitoredStrJoin, "true")) then "true" else "false" :)

};
  
  declare function partstranformation:transPartROHS($resSuppliers) as xs:string* {
    (: 
      Transrule: 
      If If no manufacturer linked to Part, then set.default value = "Not defined"
      Set ROHS flag = Yes if all Part-Manufacturer references have ROHS as Yes
      Set ROHS flag = False if NOT all Part-Manufacturer references have ROHS as Yes
      Set ROHS flag = "Not Defined" if all Part-Manufacturer references have ROHS as "Not defined".
    :)
    let $lstRohs := $resSuppliers/Attribute[@CLAMP_ID="LeadFree"]/RealValue/text()      
    return partstranformation:transManufROHS($lstRohs)   
  };
  
  declare function partstranformation:transManufROHS($lstValStr as xs:string*) as xs:string* {
    let $retRohs := 
      if(fn:count($lstValStr) eq 0) then
        "Not defined"
      else
        let $derivedValues := 
          for $i in $lstValStr
          return 
              if(fn:empty($i)) then
               "Not defined"
              else if($i = "+") then
               "Yes"
              else if($i = "-") then
                "No"
              else
                "Not defined"
         return
           if(fn:count(fn:index-of($derivedValues, "Yes")) eq fn:count($lstValStr)) then (:if All re Yes:)
              "Yes"
            else if(fn:count(fn:index-of($derivedValues, "Not defined")) eq fn:count($lstValStr)) then
              "Not defined"
            else 
              "No"
     return $retRohs  
  }; 

  declare function partstranformation:transReplacementComment($res)  {
    let $results := $res/ReplacedBy/Attribute[@CLAMP_ID = "j5_Commentaire"]
    return
      if(fn:empty($results)) then
      ""
      else
        fn:string-join($results/Value/text(),",")
  };

    (: perishablePartStatus function changed: if fn:empty($valStr) or $valStr eq "--" or $valStr eq "" ==> "" :)
  declare function partstranformation:perishablePartStatus($valStr as xs:string?){
    if(fn:empty($valStr) or $valStr eq "--" or $valStr eq "") then
      ""
    else if(fn:lower-case($valStr) = "true" or $valStr = "+" or fn:lower-case($valStr) = "yes") then
      "true"
    else if(fn:lower-case($valStr) = "false" or $valStr = "-" or fn:lower-case($valStr) = "no") then
      "false"    
    else
      $valStr
  };

  declare function partstranformation:transClampReflowMaxTempTime($valRes)  {    
    let $result := for $i in $valRes/PFMAttributes/Attribute[@CLAMP_ID = "j4i03988"][.[@LANG = "en_us"]]
                    return
                        if(fn:empty($i)) then
                          ""
                        else
                          $i/Value/text()
    return $result
        (:let $a := fn:string-join($result,",")
        return $a:)
        (:19/07/21 Issue identified during Migration :change as we need only one value from the list of same values coming from different languages.
        return fn:tokenize(($a),"," )[1]
        :)
  };

  declare function partstranformation:replaceDoubleDashWithBlank($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
      ""
    else if($valStr = "--") then
      ""
    else
      $valStr
  }; 

  declare function partstranformation:transBoolean($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
      ""
    else if(fn:lower-case($valStr) = "true" or $valStr = "+" or fn:lower-case($valStr) = "yes") then
      "true"
    else if(fn:lower-case($valStr) = "false" or $valStr = "-" or fn:lower-case($valStr) = "no") then
      "false"
    else
      ""
  };

  declare function partstranformation:transClampVaultOwner($valStr as xs:string?) as xs:string {
    if(fn:empty($valStr)) then
      ""
    else
      $valStr
  };

  declare function partstranformation:transReflowMaxTempTime($resSuppliers) {
    (: Trans Rule:
    Minimum of MaxTemp Â°C for Mimum of MaxTime s:)
    let $minOfMaxTemp := $resSuppliers/Attribute[@CLAMP_ID = "TempMax"]/Value/text()
    let $minOfMaxTime := $resSuppliers/Attribute[@CLAMP_ID = "MaxTime"]/Value/text()
    
    let $intMinOfMaxTemp := for $i in $minOfMaxTemp return if(string(number($i)) != 'NaN') then $i else()
    let $intMinOfMaxTime := for $i in $minOfMaxTime return if(string(number($i)) != 'NaN') then $i else()
    return 
    if(fn:not(fn:empty($intMinOfMaxTemp)) and $intMinOfMaxTemp ne ""
      and fn:not(fn:empty($intMinOfMaxTime)) and $intMinOfMaxTime ne "") then
        fn:min($intMinOfMaxTemp) || "&#176;C for " || fn:min($intMinOfMaxTime)||"s"
    else 
      ()
  };

  (:MSL worst case:)
declare function partstranformation:transMSLWorstCase($resSuppliers) 
{
    (: Trans Rule:
      "MSL Worst Case" at Part level should be the worst case of "MSL" values at Part-Manufacturer level
      L6 is the most worse value.  L1 is the least worse value.
      At Part level for "MSL Worst Case", take the highest value from all the MSL values at part-manufacturer links.
      In case when there are no manufacturers linked to the Part......do not set any value for "MSL Worst Case" at Part level.
    :)
    let $lstMSLWorstCase := $resSuppliers/Attribute[@CLAMP_ID="MSLLevel"]/RealValue/string()
    let $retVal := fn:max($lstMSLWorstCase)
    return
      if(fn:empty($retVal)) then
        ""
      else if($retVal eq "--") then
        ""
      else
        $retVal
	};
(:
 declare function partstranformation:transShelfLife($resSuppliers) {
    let $results := 
      for $i in $resSuppliers/Attribute[@CLAMP_ID="j5_ObsRefArtFourn"]/Value/text()
      (: 23-09-2021 Modified to remove "--" values :)
      return
        if(fn:empty($i) or $i = "--") then
          ()
        else
          $i
      let $a := fn:string-join($results,",")
      return $a 
    }; 
:)

declare function partstranformation:transShelfLife($resSuppliers) {
let $shelfLifeList := $resSuppliers/Attribute[@CLAMP_ID="j5_ObsRefArtFourn"]/Value/text()
let $shelfLifeVal :=
for $res in $shelfLifeList
return
if(fn:empty($res) or $res = "--") then
()
else
let $numeric := xs:decimal(fn:replace($res,'[^0-9,.]',''))
let $unit := fn:upper-case(fn:replace($res,'[^a-zA-Z]',''))
return
if($unit = "MONTH") then
$numeric
else if($unit = "MONTHS") then
$numeric
else if($unit = "YEARS") then
$numeric*12
else if($unit = "YEAR") then
$numeric*12
else ()
return fn:min($shelfLifeVal)
};

     (: DesignAuthority --> Added transDesignAuthority Function :)
    declare function partstranformation:transDesignAuthority($result,$PartType,$ProjectName) as xs:string? {
    (:
      For PLM Sig parts (identified based on value of attribute "System Master" = PLM) -  "Originate Project" captures Design Authority in CLAMP currently.
          Design Authority should not be defined for Standard parts managed in CLAMP (legacy and new) - Identified based on value of attribute ""System Master"" = CLAMP or Orchestra
          For Cos and Design parts managed in CLAMP (legacy and new) - Identified based on value of attribute ""System Master"" = CLAMP or Orchestra - Unit information 
    :)   
    if($PartType eq ""  or fn:empty($ProjectName)) then 
      ""
    else if($PartType ne "Standard Part (COTS)" and $ProjectName eq "PLM") then
        $result/Attribute[@CLAMP_ID = "j5_Projet"]/Value/text()
    else if($PartType eq "Standard Part (COTS)" and ($ProjectName eq  "CLAMP" or $ProjectName eq "Orchestra")) then 
      ""
    else if(($PartType eq "ALSTOM Design Part" or $PartType eq "Part to Specification (CoS)") and ($ProjectName eq "CLAMP" or $ProjectName eq "Orchestra")) then 
        $result/Attribute[@CLAMP_ID = "ProjectName"]/Value/text()
    else ""
  };

  declare function partstranformation:isDocAttached($valResult) {
       if(fn:count($valResult/Specifications/Specification/Attribute[@CLAMP_ID="DocumentName"]) gt 0
          or fn:count($valResult/Drawings/Drawing/Attribute[@CLAMP_ID="DocumentName"]) gt 0
          (:Invalid Statement PGLS 22-12-2021:)
          (:
          or fn:count($valResult/Customers/Customer/Attribute[@CLAMP_ID="j5_RefArtClient"]) gt 0
          :)
          or fn:count($valResult/CustomerSpecifications/CustomerSpecification/Attribute[@CLAMP_ID="DocumentName"]) gt 0) then
          "yes"
        else
          "no"
 };	

(:03-08-21: Code changed to create multiple Project under Parent Projects:)

 (: declare function partstranformation:transProjectId($ProjectIds)  {
   for $ProjectId in $ProjectIds
     let $res := partstranformation:replaceDoubleDashWithBlank($ProjectId)
  return $res
    };   :)

(:03-08-21: Code changed to create multiple Project under Parent Projects:)

 (: declare function partstranformation:transOriginate($Originate,$ProjectClampNames)
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
  };  :)
 
  (:===========================================================================================
    DROP 2 ATTRIBUTE FUNCTIONS ENDS
  ============================================================================================:)

  declare function partstranformation:process($uri,$finalMap as map:map) {
    let $result := fn:doc($uri)/CLAMPPart
    
    let $partsValidationMap := map:new(())
   
    let $suppliers := partstranformation:getSuppliers($result)

        let $PartNumber := $result/Attribute[@CLAMP_ID="PartNumber"]/Value/text()
        let $valIdentifier := "0.0 Parts - (" || $PartNumber || ")&#13;-----------------------------------------"        
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@PartNumber", $PartNumber, $partsValidationMap):)
            
        let $PartRevision := partstranformation:getPartRevison($result)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@Revision", $PartRevision, $partsValidationMap):)
                  
        let $ShortName := $result/AttrLocSel[@ATTRNAME="j5_DesignationAS400"]/Attribute[@CLAMP_ID="j5_DesignationAS400EN"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ShortName", $ShortName, $partsValidationMap):)

        let $LongName := $result/AttrLocSel[@ATTRNAME="j5_Designation2"]/Attribute[@CLAMP_ID="j5_Designation2EN"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","AttrLocSel_Attribute@j5_Designation2EN", $LongName, $partsValidationMap):)
            
        let $PartFormURL := partstranformation:transPartFormURL($PartNumber)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@PartFormURL", $PartFormURL, $partsValidationMap):)
                
        let $t_MakeBuyIndicator := $result/Attribute[@CLAMP_ID="MakeBuyIndicator"]/RealValue/text()
        let $t_PartType := $result/Attribute[@CLAMP_ID="Class"]/Value/text() 
 
        let $docAttached := partstranformation:isDocAttached($result) 
        (: changes made on 12/09/2021 for New UAT CR:)
        let $subscription_units := $result/Units/Unit/Attribute[@CLAMP_ID = "ProjectName"]/Value/string()
        let $PartType := partstranformation:transPartType($t_PartType, $t_MakeBuyIndicator, $docAttached, $subscription_units)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@Class", $PartType,$partsValidationMap) :)  
            
        let $UNPSC := $result/Attribute[@CLAMP_ID="j5_UNSPSC"]/Value/text()
        let $UNPSC := partstranformation:chkValidValues($UNPSC)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@UNPSC", $UNPSC,$partsValidationMap)  :)

        let $UnitOfMeasure := $result/Attribute[@CLAMP_ID="j5_UniteGestion"]/Value/text()
        (: let $UnitOfMeasure := partstranformation:transUnitOfMeasure($UnitOfMeasure) :)
        (: 23-09-2021 Modified to remove "--" values :)
        let $UnitOfMeasure := partstranformation:replaceDoubleDashWithBlank(partstranformation:transUnitOfMeasure($UnitOfMeasure))


        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_UniteGestion", $UnitOfMeasure, $partsValidationMap):)  
                
														
        (: Mass --> Changed to Conditional Validation :)
        let $Mass := $result/Attribute[@CLAMP_ID="j5_Masse"]/Value/text()
        let $Mass := partstranformation:transMass($Mass)
        (:let $validationResult := 
          if($Mass ne "") then
            partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_Masse", $Mass, $partsValidationMap)
          else "":)

																					 
        let $ReachWorstCase := $result/Attribute[@CLAMP_ID="j5_SynthWorstCase"]/RealValue/text()
        let $ReachWorstCase := partstranformation:transReachWorstCase($ReachWorstCase)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_SynthWorstCase", $ReachWorstCase, $partsValidationMap):)
            
												
           (: wrote validationResult at last:)  
        let $RestrictedPart := $result/Attribute[@CLAMP_ID="j5_Interdit"]/Value[@LANG="en_us"]/text()        
        let $RestrictedPart := partstranformation:transRestrictedPart($RestrictedPart)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_Interdit", $RestrictedPart, $partsValidationMap):)    
            
        let $Duplicate := $result/Attribute[@CLAMP_ID="j5_PartStatus"]/Value[@LANG="en_us"]/text()       
        let $Duplicate := partstranformation:transDuplicate($Duplicate)
		
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_PartStatus_duplicate", $Duplicate, $partsValidationMap):)
																																								
        let $ProdLifecycleStatus := $result/Attribute[@CLAMP_ID="j5_ProdLifeCycle"]/Value[@LANG="en_us"]/text()        
        let $PartLifecycleStatus := partstranformation:transPartLifeCycle($ProdLifecycleStatus, $result)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@PartLifecycleStatus", $PartLifecycleStatus, $partsValidationMap):)
            
        let $PartLifecycleStatusMonitored := partstranformation:transPartLifecycleStatusMonitored($suppliers, $PartType)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Supplier@PartLifecycleStatusMonitored", $PartLifecycleStatusMonitored, $partsValidationMap):)
                  
        let $OMTECPDNStatus := $result/Attribute[@CLAMP_ID="j5_PDN"]/Value/text()       
        let $OMTECPDNStatus := partstranformation:transOMTECPDNStatus($OMTECPDNStatus)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_PDN", $OMTECPDNStatus, $partsValidationMap):)
            
		(: OMTECPDNNumber--> added replaceDoubleDashWithBlank and validation for non-mandatory condition:)
        let $OMTECPDNNumber := partstranformation:replaceDoubleDashWithBlank($result/FichePDN/Attribute[@CLAMP_ID="j5_TextePDN"]/Value/text())
        (:let $validationResult := 
          if($OMTECPDNStatus eq "true") then
            partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_TextePDN_number_Mandatory", $OMTECPDNNumber, $partsValidationMap)
          else
            partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_TextePDN_number_NonMandatory", $OMTECPDNNumber, $partsValidationMap):)
              
            (:OMTECPDNLink--> changed from () to "" for else condition:)  			  
																				
        let $OMTECPDNLink := $result/FichePDN/URL/text()
        let $OMTECPDNLink := partstranformation:transOMTECPDNLink($OMTECPDNStatus, $OMTECPDNLink)
        (:let $validationResult := 
          if($OMTECPDNLink ne "") then 
            partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_TextePDN_link_Mandatory", $OMTECPDNLink, $partsValidationMap)
          else
            "" :) 
				
                    
        let $Repairable := $result/Attribute[@CLAMP_ID="j5_Repairable"]/RealValue/text()        
        let $Repairable := partstranformation:transRepairable($Repairable)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_Repairable", $Repairable, $partsValidationMap):)
            
        let $ProjectNameElement := $result/Attribute[@CLAMP_ID="ProjectName"]
        let $ProjectName := partstranformation:transProjectName($ProjectNameElement)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP", "Attribute@ProjectName", $ProjectName, $partsValidationMap):)

        let $Nafp := partstranformation:transNafp($result) 

        let $MakeBuyIndicator := partstranformation:transMakeOrBuy($t_PartType, $Nafp,$ProjectName)(: Usability :)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@MakeBuyIndicator", $MakeBuyIndicator,$partsValidationMap):)
  
        let $ClampSequence := $result/Attribute[@CLAMP_ID="Sequence"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@Sequence", $ClampSequence, $partsValidationMap):)
                
        (:let $ClampDate := $result/Attribute[@CLAMP_ID="CreationDate"]/Value/text()
        let $ClampDate := partstranformation:convertDate($ClampDate)
        let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampDate", $ClampDate, $partsValidationMap):)
          
        (: 23-09-2021 Modified to remove "--" values :)  
        let $CLAMPPartStatus := partstranformation:replaceDoubleDashWithBlank($result/Attribute[@CLAMP_ID="j5_PartStatus"]/Value[@LANG="en_us"]/text())
															
        let $CLAMPPartStatus := partstranformation:transCLAMPPartStatus($CLAMPPartStatus)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_PartStatus", $CLAMPPartStatus, $partsValidationMap):)
																																								
        let $CLAMPPartReplaceBy := $result/ReplacedBy/DTRCode/text() 
        let $CLAMPPartReplaceBy := partstranformation:getReplacedByPartNumber($CLAMPPartReplaceBy)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ReplacedBy", $CLAMPPartReplaceBy, $partsValidationMap):)

        let $CLAMPPPLFlag := partstranformation:transCLAMPPPLFlag($result)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@CLAMPPPLFlag", $CLAMPPPLFlag, $partsValidationMap):)

        let $tmpCLAMPPartStatus := $result/Attribute[@CLAMP_ID="j5_ProdLifeCycle"]/Value[@LANG="en_us"]/text()
        let $tmpPartLifecycleStatus := $result/Attribute[@CLAMP_ID="j5_PartStatus"]/Value[@LANG="en_us"]/text()
        let $ReasonForReplacement := partstranformation:transReasonForReplacement($CLAMPPartReplaceBy, $tmpCLAMPPartStatus, $tmpPartLifecycleStatus)
        (:let $validationResult := 
          if(fn:not(fn:empty($ReasonForReplacement)) and $ReasonForReplacement ne "") then
            partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ReasonForReplacement", $ReasonForReplacement, $partsValidationMap)
          else "" :)

        (: Wrote Validation at last :)
        (: Calling it directly from "Queries.xqy" :)
       (: let $FamilyName := partstranformation:getFamilyName($ProjectName,$UNPSC)     :)
        let $FamilyName := queries:getFamilyName($ProjectName,$UNPSC)   
        let $FamilyName := if(fn:empty($FamilyName)) then "" else $FamilyName
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@familyname", $FamilyName,$partsValidationMap):)
																																																							 

        (: ================================================================================================================ 
          DROP 2 ATTRIBUTES STARTS
        ================================================================================================================ :)
        
        (: alstomDescriptionEN --> Added "replaceDoubleDashWithBlank" Function :)
        let $alstomDescriptionEN := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation"]/Attribute[@CLAMP_ID="j5_DesignationEN"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@AlstomDescriptionEN", $alstomDescriptionEN, $partsValidationMap):)

        (: alstomDescriptionFR --> Added "replaceDoubleDashWithBlank" Function :)
        let $alstomDescriptionFR := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation"]/Attribute[@CLAMP_ID="j5_DesignationFR"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@AlstomDescriptionFR", $alstomDescriptionFR, $partsValidationMap):)

        (: alstomDescriptionAL --> Added "replaceDoubleDashWithBlank" Function :)
        let $alstomDescriptionAL := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation"]/Attribute[@CLAMP_ID="j5_DesignationAL"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@AlstomDescriptionAL", $alstomDescriptionAL, $partsValidationMap):)

        (: alstomDescriptionAU --> Added "replaceDoubleDashWithBlank" Function :)
        let $alstomDescriptionAU := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation"]/Attribute[@CLAMP_ID="j5_DesignationAU"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@AlstomDescriptionAU", $alstomDescriptionAU, $partsValidationMap):)

        (: alstomDescriptionES --> Added "replaceDoubleDashWithBlank" Function :)
        let $alstomDescriptionES := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation"]/Attribute[@CLAMP_ID="j5_DesignationES"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@AlstomDescriptionES", $alstomDescriptionES, $partsValidationMap):)
        
		    let $clampCommodityCode := partstranformation:replaceDoubleDashWithBlank($result/Attribute[@CLAMP_ID="j5_CodeProduit"]/Value/text() )
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampCommodityCodes", $clampCommodityCode, $partsValidationMap):)
       
        (: clampContainsCombustible--> added transDoesContainCombustible function:)
        let $clampContainsCombustible := $result/Attribute[@CLAMP_ID="j5_FeuFumee"]/RealValue/text()
		
        let $clampContainsCombustible := partstranformation:transDoesContainCombustible($clampContainsCombustible)
		
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampContainsCombustibleMat", $clampContainsCombustible, $partsValidationMap):)
        
        let $clampControllingUnit := partstranformation:replaceDoubleDashWithBlank($result/Attribute[@CLAMP_ID="ProjectName"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampControllingUnit", $clampControllingUnit, $partsValidationMap):)

        let $clampMaterial := partstranformation:replaceDoubleDashWithBlank(partstranformation:transClampMaterial($result))
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampMaterial", $clampMaterial, $partsValidationMap):)
        
        let $clampProject := partstranformation:transClampProject($result)

        let $clampProtection := partstranformation:replaceDoubleDashWithBlank(partstranformation:transClampProtection($result))
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampProtection", $clampProtection, $partsValidationMap):)        

        let $clampVaultOwner :=$result/Attribute[@CLAMP_ID="OwnerName"]/Value/text()
        let $clampVaultOwner := partstranformation:transClampVaultOwner($clampVaultOwner)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampVaultOwner", $clampVaultOwner, $partsValidationMap):)        

        let $hazardousGoods :=$result/Attribute[@CLAMP_ID="j5_UsageReglemente"]/Value[@LANG="en_us"]/text()   
        let $hazardousGoods := partstranformation:transBoolean($hazardousGoods)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@HazardousGoods", $hazardousGoods, $partsValidationMap):)

        let $isComposedBy :=$result/Attribute[@CLAMP_ID="j5_EstCompose"]/Value[@LANG="en_us"]/text()   
        let $isComposedBy := partstranformation:transBoolean($isComposedBy)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@IsComposedBy", $isComposedBy, $partsValidationMap):)
       
        (: shortDescriptionEN --> Added "replaceDoubleDashWithBlank" Function :)
        let $shortDescriptionEN := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_DesignationAS400"]/Attribute[@CLAMP_ID="j5_DesignationAS400EN"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ShortDescriptionEN", $shortDescriptionEN, $partsValidationMap):)
        
        let $shortDescriptionFR := $result/AttrLocSel[@ATTRNAME="j5_DesignationAS400"]/Attribute[@CLAMP_ID="j5_DesignationAS400FR"]/Value/text()
        let $shortDescriptionFR := partstranformation:replaceDoubleDashWithBlank($shortDescriptionFR)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ShortDescriptionFR", $shortDescriptionFR, $partsValidationMap):)

        let $shortDescriptionGE := $result/AttrLocSel[@ATTRNAME="j5_DesignationAS400"]/Attribute[@CLAMP_ID="j5_DesignationAS400AL"]/Value/text()
        let $shortDescriptionGE := partstranformation:replaceDoubleDashWithBlank($shortDescriptionGE)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ShortDescriptionAL", $shortDescriptionGE, $partsValidationMap):)

        let $shortDescriptionIT := $result/AttrLocSel[@ATTRNAME="j5_DesignationAS400"]/Attribute[@CLAMP_ID="j5_DesignationAS400AU"]/Value/text()
        let $shortDescriptionIT := partstranformation:replaceDoubleDashWithBlank($shortDescriptionIT)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ShortDescriptionAU", $shortDescriptionIT, $partsValidationMap):)
              
        let $shortDescriptionSP := $result/AttrLocSel[@ATTRNAME="j5_DesignationAS400"]/Attribute[@CLAMP_ID="j5_DesignationAS400ES"]/Value/text()
        let $shortDescriptionSP := partstranformation:replaceDoubleDashWithBlank($shortDescriptionSP)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ShortDescriptionES", $shortDescriptionSP, $partsValidationMap):)
																			
        (: longDescriptionEN --> Added $validationResult and "replaceDoubleDashWithBlank" Function:)
        let $longDescriptionEN := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation2"]/Attribute[@CLAMP_ID="j5_Designation2EN"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","AttrLocSel_Attribute@LongDescriptionEN", $longDescriptionEN, $partsValidationMap):)

        (:$longDescriptionFR --> Added "replaceDoubleDashWithBlank" Function:)        
        let $longDescriptionFR := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation2"]/Attribute[@CLAMP_ID="j5_Designation2FR"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","AttrLocSel_Attribute@LongDescriptionFR", $longDescriptionFR, $partsValidationMap):)
              
         (:$longDescriptionAL --> Added "replaceDoubleDashWithBlank" Function:)      
        let $longDescriptionAL := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation2"]/Attribute[@CLAMP_ID="j5_Designation2AL"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","AttrLocSel_Attribute@LongDescriptionAL", $longDescriptionAL, $partsValidationMap):)

         (:$longDescriptionAU --> Added "replaceDoubleDashWithBlank" Function:) 
        let $longDescriptionAU := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation2"]/Attribute[@CLAMP_ID="j5_Designation2AU"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","AttrLocSel_Attribute@LongDescriptionAU", $longDescriptionAU, $partsValidationMap):)
          
        (:$longDescriptionES --> Added "replaceDoubleDashWithBlank" Function:)   
        let $longDescriptionES := partstranformation:replaceDoubleDashWithBlank($result/AttrLocSel[@ATTRNAME="j5_Designation2"]/Attribute[@CLAMP_ID="j5_Designation2ES"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","AttrLocSel_Attribute@LongDescriptionES", $longDescriptionES, $partsValidationMap):)

        let $masse :=$result/Attribute[@CLAMP_ID="j5_Masse"]/Value/text()
        
        let $mslWorstCase := partstranformation:checkNull($result/PFMAttributes/Attribute[@LANG="en_us"][@CLAMP_ID="j4i03884"]/Value/text()) 
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@MSLWorstCase", $mslWorstCase, $partsValidationMap):)
            
        let $clampMSLWorstCase := partstranformation:replaceDoubleDashWithBlank($result/PFMAttributes/Attribute[@LANG="en_us"][@CLAMP_ID="j4i03884"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampMSLWorstCase", $clampMSLWorstCase, $partsValidationMap):)
              
										  
        (: Removed "checkNull" Function , 28-07-21:Added replaceDoubleDashWithBlank:)
        let $submitterUnit := partstranformation:replaceDoubleDashWithBlank($result/Attribute[@CLAMP_ID="j5_EtabdemandCreat"]/Value/text())
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@SubmitterUnit", $submitterUnit, $partsValidationMap):)
      
        let $supplierName := partstranformation:transSupplierName($suppliers)

        let $supplierPartRef := partstranformation:transSupplierPartRef($suppliers)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@SupplierPartReference", $supplierPartRef, $partsValidationMap):)        

        let $Perishable := $result/Attribute[@CLAMP_ID="j5_Perime"]/Value[@LANG ="en_us"]/text()
        let $Perishable := partstranformation:perishablePartStatus($Perishable)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@Perishable", $Perishable, $partsValidationMap):)        
        
        
        let $SuppliersLst :=
                   for $i in $suppliers
                   where ( $i/Attribute[@CLAMP_ID="MigrationDate"]/RealValue/text() = "j5shelflife" or
                   $i/Attribute[@CLAMP_ID="MigrationDate"]/RealValue/text() = "j5Regenerate" )
                   return $i

        let $ShelfLife :=
           if($Perishable eq "true") then
             let $a := partstranformation:transShelfLife($SuppliersLst)
             return $a
           else ""


        let $designAuthority := $result/Attribute[@CLAMP_ID="ProjectName"]/Value/text()
        let $designAuthority := partstranformation:transDesignAuthority($result, $PartType, $ProjectName)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@DesignAuthority", $designAuthority, $partsValidationMap):)										

        let $ClampReflowMaxTempTime := partstranformation:transClampReflowMaxTempTime($result)
        let $ClampReflowMaxTempTime := partstranformation:replaceDoubleDashWithBlank($ClampReflowMaxTempTime)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampReflowMaxTempTime", $ClampReflowMaxTempTime, $partsValidationMap):)        

        let $Standards := partstranformation:transStandard($result)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@Standards", $Standards, $partsValidationMap):)        

        (: material--> removed checkNull function:)
        let $material := $result/Materials/Material[1]/Attribute[@CLAMP_ID="j5_DesignationMat"]/Value/text()
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@Material", $material, $partsValidationMap):)   
       
       
        let $partROHS := partstranformation:transPartROHS($suppliers)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@PartROHS", $partROHS, $partsValidationMap):)        

        let $ReplacementComment := partstranformation:transReplacementComment($result)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@j5_Commentaire", $ReplacementComment, $partsValidationMap):)

        let $ReflowMaxTempTime := partstranformation:transReflowMaxTempTime($suppliers)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ReflowMaxTempTime", $ReflowMaxTempTime, $partsValidationMap):)

        let $MSLWorstCase := partstranformation:transMSLWorstCase($suppliers)
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@MSLWorstCase", $MSLWorstCase, $partsValidationMap):)
        
        let $CreationDate := $result/Attribute[@CLAMP_ID = "CreationDate"]/Value/text()
        let $ClampDate_ := $result/Attribute[@CLAMP_ID = "j5_InVaultDate"]/Value/text()
        let $Date := 
          if(fn:exists($ClampDate_))then 
            $ClampDate_ 
          else 
            $CreationDate
        let $ClampDate := partstranformation:convertDate($Date)        
        (:let $validationResult := partvalidation:createDataQualityAndMigrationComments("CLAMP","Attribute@ClampDate", $ClampDate, $partsValidationMap):)
        

        (: ================================================================================================================ 
          DROP 2 ATTRIBUTES ENDS
        ================================================================================================================ :)

    let $_ := map:put($finalMap, $valIdentifier, $partsValidationMap)

    (:Adding code for adding manufacturer Validation comment:)
    let $ManufacturerValidation := partsmanuftranformation:process($uri, $finalMap)
     
     (:Adding code for adding Composed By Validation comment:)
     let $PartsComposedByValidation := partcomposedbytranformation:process($uri, $finalMap)
     
     (:Adding code for adding Customer Validation comment:)
      let $PartsCustomerValidation := partcustomertranformation:process($uri, $finalMap)
     
     (:Adding code for adding Customer Validation comment:)   
     let $PartsFamilyAttributeValidation := familyattributevaluetranformation:process($uri, $finalMap)

     (:Adding code for adding Customer Validation comment:)   
     let $PartsFamilyClassificationLinkValidation := familyclassificationlinktransformation:process($uri, $finalMap)

     let $PartsUsingUnits := usingunits:process($uri)

     let $projectforparts := projectforparts:process($uri)

    let $dataQualityAndValidationMessageMap := partvalidation:getDataQualityAndValidationMessages($finalMap)
    let $dataQuality := 
      if(fn:empty($finalMap) and fn:empty($dataQualityAndValidationMessageMap)) then 
        ""
      else 
        map:keys($dataQualityAndValidationMessageMap)[1]

     let  $migrationComments := 
          if(fn:empty($finalMap) and fn:empty($dataQualityAndValidationMessageMap)) then 
            ""
          else
            map:get($dataQualityAndValidationMessageMap, map:keys($dataQualityAndValidationMessageMap)[1])

   (:------Generating Orchestra schema-----:)
  
  return 
(<Orchestra>
		<part>
			<partNumber>{$PartNumber}</partNumber>
			<revisionLevel>{$PartRevision}</revisionLevel>
			<clampPartData>
			  <clampControllingUnit>{$clampControllingUnit}</clampControllingUnit>
			  <clampCommodityCode>{$clampCommodityCode}</clampCommodityCode>
			  <clampDate>{$ClampDate}</clampDate>
			  <clampPartStatus>{$CLAMPPartStatus}</clampPartStatus>
			  <clampSequence>{$ClampSequence}</clampSequence>
        <clampPplFlag>{$CLAMPPPLFlag}</clampPplFlag>
		    <clampContainsCombustibleMaterial>{$clampContainsCombustible}</clampContainsCombustibleMaterial>
        <clampProtection>{$clampProtection}</clampProtection>
        <clampMaterial>{$clampMaterial}</clampMaterial>
        <clampVaultOwner>{$clampVaultOwner}</clampVaultOwner>
        <clampReflowMaxTempTime>{$ClampReflowMaxTempTime}</clampReflowMaxTempTime>
        <clampMSLWorstCase>{$clampMSLWorstCase}</clampMSLWorstCase>			  
			</clampPartData>
			<familyNameEnglish>{$FamilyName}</familyNameEnglish>
			<shortDescription>{$shortDescriptionEN}</shortDescription>
			<OTHERSHORTDESCRIPTION>
				<shortDescFrench>{$shortDescriptionFR}</shortDescFrench>
				<shortDescGerman>{$shortDescriptionGE}</shortDescGerman>
				<shortDescItalian>{$shortDescriptionIT}</shortDescItalian>
				<shortDescSpanish>{$shortDescriptionSP}</shortDescSpanish>
			</OTHERSHORTDESCRIPTION>
			<longDescription>{$longDescriptionEN}</longDescription>
			<OTHERLONGDESCRIPTION>
				<longDescFrench>{$longDescriptionFR}</longDescFrench>
				<longDescGerman>{$longDescriptionAL}</longDescGerman>
				<longDescItalian>{$longDescriptionAU}</longDescItalian>
				<longDescSpanish>{$longDescriptionES}</longDescSpanish>
			</OTHERLONGDESCRIPTION>
			<alstomDescription>{$alstomDescriptionEN}</alstomDescription>
      <OTHERALSTOMDESCRIPTION>
            <alstomDescFrench>{$alstomDescriptionFR}</alstomDescFrench>
            <alstomDescGerman>{$alstomDescriptionAL}</alstomDescGerman>
            <alstomDescItalian>{$alstomDescriptionAU}</alstomDescItalian>
            <alstomDescSpanish>{$alstomDescriptionES}</alstomDescSpanish>
      </OTHERALSTOMDESCRIPTION>
			<quickClampForm>{$PartFormURL}</quickClampForm>
			<usability>{$MakeBuyIndicator}</usability>
			<systemMaster>{$ProjectName}</systemMaster>
			<designAuthority>{$designAuthority}</designAuthority>
			<partTp>{$PartType}</partTp>
			<unspsc>{$UNPSC}</unspsc>
			<unitOfMeasure>{$UnitOfMeasure}</unitOfMeasure>
			<mass>{$Mass}</mass>
			<pplFlag>{}</pplFlag>
			<submitterUnit>{$submitterUnit}</submitterUnit>
			<reachWorstCase>{$ReachWorstCase}</reachWorstCase>
			<PARTUSAGE>
			  <restrictedPart>{$RestrictedPart}</restrictedPart>
			  <restrictedPartComment></restrictedPartComment>
			  <serviceLevel></serviceLevel>
			  <selleableSparePart></selleableSparePart>
			  <repairable>{$Repairable}</repairable>
			</PARTUSAGE>
			<partROHS>{$partROHS}</partROHS>
			<PARTFEATURE>
        <mslWorstCase>{$MSLWorstCase}</mslWorstCase>
        <reflowMaxTempTime>{$ReflowMaxTempTime}</reflowMaxTempTime>
				<rislWorstCase></rislWorstCase>
				<fireSmoke></fireSmoke>
				<fireSmokeComment></fireSmokeComment>
				<perishablePart>{$Perishable}</perishablePart>
				<perishablePartComment></perishablePartComment>
				<shelfLife>{$ShelfLife}</shelfLife>  
				<material>{$material}</material>
				<traceability></traceability>
				<hazardousGood>{$hazardousGoods}</hazardousGood>
				<alstomIPOwner></alstomIPOwner>
				<standards>{for $standard in $Standards
				  return 
				   <standard>{$standard}</standard>}</standards>
      </PARTFEATURE>
			<partLifecycleStatus>{$PartLifecycleStatus}</partLifecycleStatus>
			<PartLifecycleStatusMonitored>{$PartLifecycleStatusMonitored}</PartLifecycleStatusMonitored>
			<LIFECYCLE>
			 <monitored>{$PartLifecycleStatusMonitored}</monitored>
			 <CHANGENOTICE>
				<omtecPDNStatus>{$OMTECPDNStatus}</omtecPDNStatus>
				<omtecPDNNumber>{$OMTECPDNNumber}</omtecPDNNumber>
				<omtecPDNLink>{$OMTECPDNLink}</omtecPDNLink>
			 </CHANGENOTICE>
			</LIFECYCLE>
			<SUBSCRIPTION></SUBSCRIPTION>
   <PARTREPLACE>
			  <partReplaceBy>{$CLAMPPartReplaceBy}</partReplaceBy>
			  <reasonForReplacement>{$ReasonForReplacement}</reasonForReplacement>
			  <replacementComment>{$ReplacementComment}</replacementComment>
			</PARTREPLACE>
			<QUALITY>
			  <dataQualityStatus>{}</dataQualityStatus>
			  <commentOnMigration>{}
			  </commentOnMigration>
			  <duplicate>{$Duplicate}</duplicate>
			  <reachRefreshDate>{}</reachRefreshDate>
        <fireSmokeRefreshDate>{}</fireSmokeRefreshDate> 
		    </QUALITY>
		</part>
{$ManufacturerValidation[1]}
{$PartsComposedByValidation[1]}
{$PartsCustomerValidation[1]}
{$PartsFamilyAttributeValidation[1]}
{$PartsFamilyClassificationLinkValidation}
{$PartsUsingUnits}
{$projectforparts}
</Orchestra>)
  
};