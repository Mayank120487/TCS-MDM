'use strict';
const DataHubSingleton = require('/data-hub/5/datahub-singleton.sjs');
/*const options = {'uris':['/CLAMP/BatchLoad/Parts_53c5ddb0-9ed7-4588-b7aa-dc0957abd154_DTR0018351678,A,23.xml',
                         '/clamp-stage/6b2a7c82-e7f3-44db-8492-c07fa0840aca.xml']}*/
const options = URIS.URIS;
let params = {'uris':''}
let params1 = URIS.URIS;

let flowName = Pflow;
let stepNumber = 1;
  if (!fn.exists(flowName)) {
    fn.error(null, 'RESTAPI-SRVEXERR', Sequence.from([400, 'Bad Request', 'Invalid request - must specify a flowName']));
  } else {
    let options = params['options'] ? JSON.parse(params['options']) : {};
    const datahub = DataHubSingleton.instance({
      performanceMetrics: !!options.performanceMetrics
    });
    let jobId = flowName+'_'+fn.currentDateTime();
    let flow = datahub.flow.getFlow(flowName);
    let stepRef = flow.steps[stepNumber];
    let stepDetails = datahub.flow.step.getStepByNameAndType(stepRef.stepDefinitionName, stepRef.stepDefinitionType);
    let flowOptions = flow.options || {};
    let stepRefOptions = stepRef.options || {};
    let stepDetailsOptions = stepDetails.options || {};
    // build combined options
    let combinedOptions = Object.assign({}, stepDetailsOptions, flowOptions, stepRefOptions, options);
    let sourceDatabase = combinedOptions.sourceDatabase || datahub.flow.globalContext.sourceDatabase;
    let query = null;
    let uris = null;
    if (params1.uris || options.uris) {
      uris = datahub.hubUtils.normalizeToArray(params1.uris || options.uris);
      query = cts.documentQuery(uris);
    } else {
      let sourceQuery = combinedOptions.sourceQuery || flow.sourceQuery;
      query = sourceQuery ? cts.query(sourceQuery) : null;
    }
    let content;
    if (stepDetails.name === 'default-merging' && stepDetails.type === 'merging' && uris) {
      content = uris.map((uris) => { return { uris }; });
    } else if (!query && input && fn.count(input) === uris.length) {
      content = datahub.hubUtils.normalizeToArray(input).map((inputDoc, i) => { return { uris: uris[i],  value: inputDoc }; });
    } else {
      content = datahub.hubUtils.queryToContentDescriptorArray(query, combinedOptions, sourceDatabase);
    }
     datahub.flow.runFlow(flowName, jobId, content, options, stepNumber);
	 //[flowName,datahub.flow.getFlow(flowName),flow];
  };

