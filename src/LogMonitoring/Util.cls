/// 
Class LogMonitoring.Util
{

/// d ##class(LogMonitoring.Util).Deployment()
ClassMethod Deployment() As %Status
{
	
	 Set $namespace ="%sys"
	 new $namespace
	 Set props("Database")="USER",sc=##Class(Config.MapPackages).Create("%ALL","LogMonitoring",.props)
	 Set property("AutheEnabled")=64,property("IsNameSpaceDefault")=0,property("MatchRoles")="%All:%All,:%All",property("GroupById")="%ISCMgtPortal",property("NameSpace")="USER",property("DeepSeeEnabled")=1,property("DispatchClass")="LogMonitoring.API.Rest"
	 Set tSC=##Class(Security.Applications).Create("/LogMonitor",.property)
	 quit
}

}

