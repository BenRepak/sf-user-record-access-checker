@isTest
public with sharing class ReordAccessUtility_TEST {
    public static final Id AG_MSIS_RT_ID = Schema.SObjectType.Application_Graduate__c.getRecordTypeInfosByDeveloperName().get('MSIS').getRecordTypeId();
    public static User mbaUser = [select id from user where lastname = 'Worsley' LIMIT 1][0];
    

    
    @TestSetup
    private static void makeData(){

        Account a = new Account();
        a.name = 'Test Account';
        a.BillingCity = 'SLC';
        a.billingstate = 'UT';
        Insert a;

        Contact msisCon = new Contact();
        msisCon.firstname = 'Ariana';
        msisCon.lastname = 'Grande';
        msisCon.email = 'salesforce@eccles.utah.edu';
        msisCon.birthdate = date.valueOf('1993-06-26');
        msisCon.student_id_number__c = 'u12345678';
        msisCon.accountid = a.id;
        msisCon.Years_of_Work_Experience__c = 2.4;
        msisCon.code_key__c = 'msiscon';
        insert msisCon;

        Application_Graduate__c msisApp = new Application_Graduate__c();
        msisApp.Disable_Auto_Email__c = true;
        msisApp.started__c = true;    
        msisApp.submitted__c = true;
        // msisApp.Graduate_Pipeline_Stage__c = 'Application Submitted';
        msisApp.decision_v2__c = 'Application Submitted';
        msisApp.Application_Submitted_Date__c = date.valueOf('1999-01-01');
        msisApp.Application_Created_Date__c = date.valueOf('1999-01-01');
        msisApp.Application_Last_Updated__c = date.valueOf('1999-01-01');
        msisApp.Application_Last_Accessed__c = date.valueOf('1999-01-01');
        msisApp.term_desired__c = 'Spring 2021';
        // msisApp.Graduate_Pipeline_Term__c = 'Spring 2021';
        // msisApp.Graduate_Pipeline_Stage_Category__c = 'Pending Completion';
        msisApp.program_desired__c = 'MSIS';
        msisApp.recordtypeid = AG_MSIS_RT_ID;
        msisApp.contact__c = msisCon.id;
        msisApp.Verified_Undergrad_GPA__c = '3.125';
        msisApp.Gender__c = 'Female';
        msisApp.Months_Work_Since_Bachelors__c = '120';
        msisApp.Applicant_ID_AY__c = 'msisapp';
        insert msisApp;
        
    }

    @isTest
    private static void testMbaUserOnMsisRecord(){
        Application_Graduate__c app = [select id from Application_Graduate__c WHERE recordtype.name = 'MSIS' LIMIT 1][0];
        
        System.runAs(mbaUser) {
            List<RecordAccessUtility.RecordAccessRequest> requests = new List<RecordAccessUtility.RecordAccessRequest>();
            RecordAccessUtility.RecordAccessRequest request = new RecordAccessUtility.RecordAccessRequest();
            request.recordId = app.id;
            request.userId = mbaUser.id;
            requests.add(request);
            
            List<RecordAccessUtility.RecordAccessResponse> responses = new List<RecordAccessUtility.RecordAccessResponse>();
            RecordAccessUtility.RecordAccessResponse response = new RecordAccessUtility.RecordAccessResponse();
            responses = RecordAccessUtility.checkRecordAccess(requests);
            response = responses[0];

            Boolean hasEditAccess;

            if(response.hasEditAccess){
                system.debug('can update');
                hasEditAccess = true;
            } else {
                system.debug('cannot update');
                hasEditAccess = false;
            }
    
            system.assertEquals(false,hasEditAccess,'Expect MSIS record to not be editable by MBA user');
        }
    }
        
        


}




    
    
