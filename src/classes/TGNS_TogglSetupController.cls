public class TGNS_TogglSetupController {
    
    public Toggl__c config {get; set;}

    public TGNS_TogglSetupController() {
        // only doing one token for now, but the list means we can do multiple workspaces later
        for (Toggl__c c : [select Id, Name, API_Token__c, Workspace_ID__c from Toggl__c WHERE Name= :UserInfo.getUsername()  limit 1]) {
            config = c;
        }
        if (config == null) {
            config = new Toggl__c();
        }
    }

    public void save() {
        config.Name = UserInfo.getUsername();
        upsert config;
    }
}