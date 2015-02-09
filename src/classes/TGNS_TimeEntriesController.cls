public class TGNS_TimeEntriesController {

    public Date testDate{get;set;}

    private String state = 'no';
    public String getState() {
        return state;
    }
    public void setState(String state) {
        this.state=state;
    }
    
    public PageReference setTaskOptions() {
        taskOptions = new List<SelectOption>();
        if(projectId!=null) {
            for(TGNS_Task__c task: [SELECT Id, Name FROM TGNS_Task__c 
                                WHERE TGNS_Project__c =:projectId ]) {
                taskOptions.add(new SelectOption(task.Id,task.Name));
            }  
        }
        return null;
    }

    //public String entryDate{get;set;}
    //public String endDate;
    private String entryDate;
    private TGNS_Services togglService = new TGNS_Services();
    public Toggl__c config {get;set;}//TOBEDELETED
    private TGNS_Services.DetailedReportResult result = new TGNS_Services.DetailedReportResult();
    private Map<Integer,ProjectWrapper> projectMap = new Map<Integer,ProjectWrapper>();
    public List<ProjectWrapper> projectList {get;set;}
    public List<SelectOption> projectOptions {get;set;}
    private List<SelectOption> taskOptions = new List<SelectOption>();
    public String projectId {get;set;}
    //public List<TimeEntryWrapper> timeEntryList;
    //public List<ProjectWrapper> projectList;
    //public Map<Sti

    public TGNS_TimeEntriesController() {
        config = togglService.getTogglConfig();
        setProjectOptions();
    }

    public void setProjectOptions() {
        projectOptions = new List<SelectOption>();
        for(TGNS_Project__c project: [SELECT Id, Name FROM TGNS_Project__c]) {
            projectOptions.add(new SelectOption(project.Id,project.Name));
        }
    }

    public PageReference methodOne() {
        return null;
    }
    
    
    public List<SelectOption> getTaskOptions() {
        taskOptions = new List<SelectOption>();
        if(projectId!=null) {
            for(TGNS_Task__c task: [SELECT Id, Name FROM TGNS_Task__c 
                                WHERE TGNS_Project__c =:projectId ]) {
                taskOptions.add(new SelectOption(task.Id,task.Name));
            }  
        }
        
        return taskOptions;
    }

    public void setTaskOptions(List<SelectOption> taskOptions) {
        this.taskOptions = taskOptions;
    }
    
    
    
    public void setEntryDate(String d) {
        this.entryDate= d;
    }
    
    
    public String getEntryDate() {
        return entryDate;
    }
    

    //button action to fetch the entries
    public PageReference fetch() {
        //TGNS_Services.DetailedReportResult result = new TGNS_Services.DetailedReportResult();
        projectMap.clear();
        PageReference pf = null;
        try{
            if (config!=null) {
                result=syncToggl();
                for(TGNS_Services.TimeEntry instance: result.data) {
                    if(projectMap.containsKey(instance.pid)) {
                        projectMap.get(instance.pid).entryList.add(new TimeEntryWrapper(instance));
                    }
                    else{
                        projectMap.put(instance.pid, new ProjectWrapper(instance));
                    }
                }
                System.Debug('Check:projectMap'+projectMap);
               // projectList.clear();
                projectList = projectMap.values();
            }
            else{
                throw new TogglSyncException('Toggl is not configured in your Org!');
            }
        }
        catch(Exception expn) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.Error, 
                                    expn.getMessage()
                                    )
            );
        }
        return pf;
    }

    //sync data from toggl
    public TGNS_Services.DetailedReportResult syncToggl() {
        System.Debug('Check:entryDate'+ entryDate);
        return togglService.getTimeEntries(entryDate);
    }

    public class TimeEntryWrapper {
        public String entryId {get;set;}
        public String userId;
        public String description {get;set;}
        public Boolean isStopped {get;set;}
        public Decimal duration {get;set;}
        public Boolean isBillable{get;set;}
        public Boolean isSelected {get;set;}
        public String projectId {get;set;}
        public String taskId {get;set;}
        //public ProjectWrapper project;
        //public String client;
      //  private Map<String,List<TGNS_Services.TimeEntry>> projectEntryMap = new Map<String,String>();
        public TimeEntryWrapper(TGNS_Services.TimeEntry entry) {
            entryId = String.valueOf(entry.Id);
            //entry.pid;
            userId= String.valueOf(entry.uid);
            description = entry.description;
            duration = entry.dur/3600000;
            isStopped = entry.use_stop;
            isBillable = entry.is_billable;
            isSelected = false;
            System.Debug('Check:entry made');
           // client = entry.client;
            //entry.project;
        }
    }

    public class ProjectWrapper {
        public String projectId;
        
        public String name {get;set;}
        public String clientName {get;set;}
        public List<TimeEntryWrapper> entryList {get;set;}
        public ProjectWrapper(TGNS_Services.TimeEntry entry) {
            projectId = String.valueOf(entry.pid);
            name = entry.project;
            clientName = entry.client;
            entryList = new List<TimeEntryWrapper>();
            entryList.add(new TimeEntryWrapper(entry));
            System.Debug('Check:entryList'+ entryList);
        }
    }

    public class TogglSyncException extends Exception{}

}