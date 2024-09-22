Class LogMonitoring.Chart.Operate
{

/// d ##class(LogMonitoring.Chart.Operate).Run()
ClassMethod Run()
{
	Set a=..LogMonitor()
	zw a
}

/// d ##class(LogMonitoring.Util).test()
ClassMethod LogList(type) As %Status
{

	Set data=[]
	Set sql="SELECT ID,  Job,SourceMethod,Text, TimeLogged,Type FROM Ens_Util.Log "
	if $L(type)'=0 Set sql=sql_" where Type ='"_type_"'" 
	set sql=sql_" order by id desc"
	
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(sql)
	Set rest  = statement.%Execute()
	while rest.%Next(){
		Set obj={}
		Set obj.ID=rest.%Get("ID")
		Set obj.Job=rest.%Get("Job")
		Set obj.Method=rest.%Get("SourceMethod")
		Set obj.Text=rest.%Get("Text")
		Set obj.Text=rest.%Get("Text")
		Set obj.TimeLogged=rest.%Get("TimeLogged")
		Set obj.Type=rest.%Get("Type")
		
		
		Do data.%Push(obj)

	}
    set pOutput=data.%ToJSON()
    Quit pOutput
}

ClassMethod Task() As %Status
{
	s Rset=##class(%ResultSet).%New("%SYS.Task.UpcomingTasksFilter")
    s r=Rset.Execute(,,,,5)
    set resultArray=##class(%DynamicArray).%New()
	while (Rset.%Next()) {      
      set tempOb=##class(%DynamicObject).%New()
      set tempOb.ID=Rset.Get("ID")
      set tempOb.Name=Rset.Get("Name")
       IF (Rset.Get("Suspended")=0){
	       set tempOb.Status= "Normal"
	    }ELSE{set tempOb.Status="Hang up"}
      
      set tempOb.time=$zt(Rset.Get("Time"),1)
      Do resultArray.%Push(tempOb)
   }
	
    set pOutput=resultArray.%ToJSON()
    Quit pOutput
}

ClassMethod Process() As %Status
{
	Set sqlStr2="call %Library.Global_Get('%sys','^IRIS.Temp.SysMetrics(Processes)',,,,)"
	Set statement2 = ##class(%SQL.Statement).%New()
	Set qStatus2 = statement2.%Prepare(sqlStr2)
    set total=0
	#dim rset2 As %SQL.StatementResult = statement2.%Execute()
	while rset2.%Next(){
		set total=rset2.%Get("Value")+0
	}
	Set sqlStr="call %Library.Global_Get('%sys','^IRIS.Temp.SysMetrics(Processes,)',,,,)"
	Set statement = ##class(%SQL.Statement).%New()
	Set qStatus = statement.%Prepare(sqlStr)
    set i=1
    set resultArray=##class(%DynamicArray).%New()
	#dim rset As %SQL.StatementResult = statement.%Execute()
	while rset.%Next(){
	   if (i<=5){
		   set resultObjece=##class(%DynamicObject).%New()
			set resultObjece.pID=$p(rset.%Get("Value"),";",1)
			set resultObjece.CommandsExecuted=$p(rset.%Get("Value"),";",2)
			&sql(SELECT NameSpace into :NameSpace FROM %SYS.ProcessQuery where pID=:resultObjece.pID)
			
			set resultObjece.NameSpace=NameSpace
			Do resultArray.%Push(resultObjece)
		    set i=i+1
		}else{Quit}
	   
	}
	set resultOb=##class(%DynamicObject).%New()
	SET resultOb.total=total
	SET resultOb.ProcessArray=resultArray
    set pOutput=resultOb.%ToJSON()
    Quit pOutput
}

ClassMethod SystemInfo() As %Status
{
	
	  set S=$zversion(1) //  2:windows  3:linux
      if (S=3){
	        set a1=##class(%Library.File).GetDirectorySpace("",.a,.b)
	        
	        set file=##class(%File).%New()
	        set file=file.CopyFile("/proc/meminfo",$System.Util.InstallDirectory()_"JhdqsSystemInfo.txt",0,.c)
	        Set stream1=##class(%FileCharacterStream).%New()
            set stream1.Filename=$System.Util.InstallDirectory()_"JhdqsSystemInfo.txt"
           
            set MemAvailable=0
            set MemTotal=1
            set memUse=0
            while 'stream1.AtEnd{
	           
	           set read=stream1.ReadLine()
	           if $l(read,"MemTotal")>1{set MemTotal=$replace($p($p(read,":",2),"kB",1)," ","")+0 }
	           if $l(read,"MemAvailable")>1{set MemAvailable=$replace($p($p(read,":",2),"kB",1)," ","")+0  Quit}
	        }
	        set memUse=(MemTotal-MemAvailable)/MemTotal*100
	        set pOutput=b_","_a_","_memUse
	     }else{
		    
		    set total=0
		    set used=0
		s stmt = ##class(%SQL.Statement).%New()
    	s status = stmt.%PrepareClassQuery("%File","DriveList")
    	if 'status { SET Row = $LISTBUILD("error","")}
    	s resultSet = stmt.%Execute(1) 
   		while resultSet.%Next() {
	   	  set re=##class(%Library.File).GetDirectorySpace(resultSet.%Get("Drive"),.a,.b)
	   	  set total=total+b
	   	  set used=used+a
    	} 
		  set pOutput=total_","_used   
		}
	
	
	
    
    Quit pOutput
}

ClassMethod LogMonitor()
{
	Set stream1=##class(%FileCharacterStream).%New()
    if ($l($zv,"UNIX")>1){
	      set stream1.Filename=$System.Util.InstallDirectory()_"/mgr/alerts.log"
	}ELSE{
		  set stream1.Filename=$System.Util.InstallDirectory()_"\mgr\alerts.log"
	}
	set n1=0
    set n2=0
	set resultArray=##class(%DynamicArray).%New()
	WHILE ('stream1.AtEnd) {      
          set content=stream1.ReadLine()
          SET ErrorInfo=##class(%DynamicObject).%New()
          set ErrorInfo.TimeAndPid=$p(content," ",1,2)
          set ErrorInfo.Type=$p(content," ",3)
          set ErrorInfo.Info=$replace($replace($p(content," ",4,*),"Utility.Event","Application Events"),"Generic.Event","General events")
          Do resultArray.%Push(ErrorInfo)
          if (ErrorInfo.Type=2){set ErrorInfo.Type="WARNING" set n1=n1+1}else{set ErrorInfo.Type="ERROR" set n2=n2+1}
    }
    set result1=##class(%DynamicObject).%New()
	set result1.ErrorNum=n2
	set result1.AlertNum=n1
	set newArray=##class(%DynamicArray).%New()
	set l=resultArray.%Size()
	set i=1
	for i=1:1:l{
	Do newArray.%Push(resultArray.%Pop())
    }
	
	
	set result1.Info=newArray
    set pOutput=result1.%ToJSON()

    Quit pOutput
}

}

