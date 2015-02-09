public class TGNS_Services {
    private String apiKey;
    private Decimal workspaceId;
    private String reportType = 'detail';

    public TGNS_Services() {
        //this.apiKey = apiKey;
        //this.workspaceId = workspaceId;
    }

    public Toggl__c getTogglConfig() {
        for (Toggl__c c : [select Id, Name, API_Token__c, Workspace_ID__c from Toggl__c 
                                WHERE Name = :UserInfo.getUsername() limit 1]) {
                this.apiKey = c.API_Token__c;
                this.workspaceId = c.Workspace_ID__c;
                System.Debug('Check:Inside'+ c);
                return c;
        }
        return null;
    }

    public CS_Toggl_URLs__c getTogglURL() {
        return CS_Toggl_URLs__c.getInstance();
    }

    public DetailedReportResult getTimeEntries(String entryDate) {
        try{
            System.Debug('Check:inside services:getTimeEntries');
            String url = (reportType.equals('summary')?
                            getTogglURL().Summary_Report__c:
                            (reportType.equals('weekly')?
                                getTogglURL().Weekly_Report__c:
                                getTogglURL().Detailed_Report__c
                            )
                        )                                
                        + '&workspace_id='+this.workspaceId 
                        + '&since='+entryDate 
                        + '&until='+entryDate;
            System.Debug('Check:url'+ url);
            //String url = 'https://www.toggl.com/reports/api/v2/details?user_agent=toggl_at_ccp.io&workspace_id='+this.workspaceId+'';
            DetailedReportResult result = (DetailedReportResult)
                                            JSON.deserialize(TGNS_Utility.sendHTTPRequest(url, apiKey), 
                                                            DetailedReportResult.class);
            result.baseUrl = url;
            //result.page = 1;
            result.toggl = this;
            System.Debug('Check:result'+ result);
            return result;
        }
        catch (Exception expn) {
            throw new ServiceException(expn.getMessage());
        }
        return null;
    }

    //public class TimeEntryTitle{
    //    public String time_entry;
    //}
    
    //public class ProjectTitle {
    //    public String project;
    //    public String client;
    //}
    
    //public class TimeEntry {
    //    public List<TimeEntryTitle> title;
    //    public Integer Time;
    //}

    //public class Project {
    //    public Integer id;
    //    public Decimal time;  
    //    public List<ProjectTitle> title;
    //    public List<TimeEntry> items;
    //}

    //public class SummaryReportResult {
    //    public Integer total_grand;
    //    public Integer total_billable; 
    //    public List<Project> data;       
    //}
    

   
    public class DetailedReportResult {
        public String baseUrl;
        
        public Integer total_count;
        public Integer page;
        public Integer per_page;
        public List<TimeEntry> data;
        public TGNS_Services toggl;
        public DetailedReportResult(){
            page=1;
            baseUrl = '';
        }
        
    }

    public class TimeEntry {
        //public List<TimeEntryTitle> title;
        //public Integer time;
        //not used
        public Integer id;
        public Integer pid;
        public Integer tid;
        public Integer uid;
        public String description;
        public Datetime start;
        // reserved word "end" public Datetime end;
        public Datetime updated;
        public Decimal dur;
        public String user;
        public Boolean use_stop;
        public String client;
        public String project;
        public String task;
        public Decimal billable;
        public Boolean is_billable;
        public String cur;
        public List<String> tags;
        //public Toggl_Time_Entry__c toSObject() {
        //    return new Toggl_Time_Entry__c(
        //        Toggl_ID__c = id,
        //        Name = description,
        //        Toggl_User__r = new Toggl_User__c(Toggl_ID__c=uid),
        //        Toggl_Project__r = new Toggl_Project__c(Toggl_ID__c=pid),
        //        Timer_Start__c = start,
        //        Full_Description__c = description,
        //        Toggl_Updated__c = updated,
        //        // duration comes through as microseconds but business people need hours
        //        Duration__c = dur == null ? null : dur/1000.0/60.0/60.0
        //    );
        //}
    }

    public class ServiceException extends Exception{}
}