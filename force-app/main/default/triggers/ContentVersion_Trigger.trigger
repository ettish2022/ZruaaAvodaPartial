trigger ContentVersion_Trigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete) {

    if (trigger.isBefore){
        if (trigger.isUpdate){
        }
        else if (trigger.isInsert){
        }
    }
    else if (trigger.isAfter){
        if (trigger.isUpdate){
        }
        else if (trigger.isInsert){
			TH_Content_Version.addContentDocumentLink(trigger.new);
        }
    }
}