public with sharing class RecordAccessUtility {

    private static Id userId;
    private static Set<Id> recordIdSet;
    private static Map<Id,UserRecordAccess> recordAccessMap = new Map<Id,UserRecordAccess>();
    

    public class RecordAccessRequest{
        @InvocableVariable(label='User Id' required=true)
        public Id userId;

        @InvocableVariable(label='Record Id' required=true)
        public Id recordId;

    }

    public class RecordAccessResponse{
        @InvocableVariable(label='User Id' required=true)
        public Id userId;
        
        @InvocableVariable(label='Record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Has Read Access')
        public boolean hasReadAccess;

        @InvocableVariable(label='Has Edit Access')
        public boolean hasEditAccess;

        @InvocableVariable(label='Has Delete Access')
        public boolean hasDeleteAccess;

        @InvocableVariable(label='Has Transfer Access')
        public boolean hasTransferAccess;

        @InvocableVariable(label='Has All Access')
        public boolean hasAllAccess;

    }

    @InvocableMethod(label='User Record Access Checker')
    public static List<RecordAccessResponse> checkRecordAccess(List<RecordAccessRequest> requests){
        List<RecordAccessResponse> responses = new List<RecordAccessResponse>();
        Set<Id> recordIdSet = getRecordsToCheck(requests);
        Id userId = getUserId(requests);
        Map<Id,UserRecordAccess> recordAccessMap = getRecordAccessMap(userId, recordIdSet);

        for(RecordAccessRequest request : requests){
            RecordAccessResponse response = new RecordAccessResponse();
            Id recordId = request.recordId;
            response.userId = request.userId;
            response.recordId = recordId;
            response.hasReadAccess = getAccess(recordId, 'hasReadAccess');
            response.hasEditAccess =  getAccess(recordId, 'hasEditAccess');
            response.hasDeleteAccess =  getAccess(recordId, 'hasDeleteAccess');
            response.hasTransferAccess =  getAccess(recordId, 'hasTransferAccess');
            response.hasAllAccess =  getAccess(recordId, 'hasAllAccess');
            responses.add(response);
        }
        
        return responses;
    }

    private static Map<Id,UserRecordAccess> getRecordAccessMap(Id userId, Set<Id> recordIdSet){
        for(UserRecordAccess accessRecord : [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasTransferAccess, HasAllAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId IN :recordIdSet]){
            recordAccessMap.put(accessRecord.recordid, accessRecord);
        }
        return recordAccessMap;
    }

    private static boolean getAccess(Id recordId, String accessType){
        return (boolean)recordAccessMap.get(recordId).get(accessType);
    }


    private static Set<Id> getRecordsToCheck(List<RecordAccessRequest> requests){
        if(recordIdSet == null){
            recordIdSet = new Set<Id>();
            for(RecordAccessRequest request : requests){
                recordIdSet.add(request.recordId);
            }
        }
        return recordIdSet;
    }

    private static Id getUserId(List<RecordAccessRequest> requests){
        if (userId == null){
            userId = requests[0].userId;
        }
        return userId;
    }

}
