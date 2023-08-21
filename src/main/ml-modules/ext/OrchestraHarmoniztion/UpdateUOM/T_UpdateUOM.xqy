xquery version "1.0-ml";

declare namespace es = "http://marklogic.com/entity-services";
declare variable $URI external;

xdmp:node-replace(fn:doc($URI)/*:envelope/*:instance/Orchestra/part/unitOfMeasure,<unitOfMeasure xmlns="">EA</unitOfMeasure>)