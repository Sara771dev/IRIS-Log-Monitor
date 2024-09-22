Class LogMonitoring.API.Rest Extends %CSP.REST
{

Parameter HandleCorsRequest = "true";

ClassMethod GetStatus(ser As %String) As %Status
{
     Quit $$$OK
}

ClassMethod Monitor(Method As %String) As %Status
{
	Do %response.SetHeader("Content-Type", "application/json;charset=UTF-8")
	Try{
		
		Set content="",message=""
		Set:$L(%request.Content)'=0 content=$zcvt(%request.Content.Read(),"I","UTF8")
		if Method = "Log"{
			
			Set message = ##class(LogMonitoring.Chart.Operate).LogMonitor()
		}
		elseif Method ="Task"{
			
			Set message = ##class(LogMonitoring.Chart.Operate).Task()
		}
		elseif Method ="Process"{
			
			Set message = ##class(LogMonitoring.Chart.Operate).Process()
		}elseif Method ="LogList"{
			Set message = ##class(LogMonitoring.Chart.Operate).LogList({}.%FromJSON(content).type)
		}
		
	   	
	}Catch(e){
		
		Set message=e.DisplayString()
	}
    w $zcvt(message,"O","UTF8")
    Quit $$$OK
}

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
 <Route Url="/*" Method="OPTIONS" Call="Status"/>
  <Route Url="/Monitor/:Method" Method="POST" Call="Monitor"/>
</Routes>
}

}

