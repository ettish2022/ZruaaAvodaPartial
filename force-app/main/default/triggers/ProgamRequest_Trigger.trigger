trigger ProgamRequest_Trigger on ProgramRequest__c (before update) {
    new ProgramRequestHandler().run();
}