import com.sybase.jdbc4.jdbc.*;
import java.sql.*;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;

import org.json.JSONArray;
import org.json.JSONObject;

public class sybase {
	    public static void main(String[] args) {
	    	JSONObject data = new JSONObject();
	    	JSONArray memArray = new JSONArray();
	    	JSONArray userStatitistics = new JSONArray();
	    	JSONArray cacheStats = new JSONArray();
	    	 JSONObject tabs = new JSONObject();
	    	
	        try {
	            Class.forName("com.sybase.jdbc4.jdbc.SybDriver");
	            String url = "jdbc:sybase:Tds:localhost:5000/master?charset=utf8";
	            String username = "sa";
	            String password = "site24x7";
	            Connection connection = DriverManager.getConnection(url, username, password);
	            
	            
	            HashMap<String,String> memoryData = new HashMap<>();
	            memoryData.put("SHARED_MEMORY_ALLOCATED_SIZE", "shared memory allocated size");
	            memoryData.put("SHARED_MEMORY_USED_SIZE", "shared memory used size");
	            memoryData.put("COMPACTORS_ALLOCATED_SIZE", "compactors allocated size");
	            memoryData.put("COMPACTORS_FREEABLE_SIZE", "compactors freeable size");
	            memoryData.put("total logical memory", "total logical memory");
	            memoryData.put("total physical memory", "total physical memory");
	            memoryData.put("size of shared class heap","size of shared class heap");
	            
	            HashMap<String,String> userStat = new HashMap<>();
	            userStat.put("number of user connections", "number of user connections");
	            userStat.put("number of remote connections", "number of remote connections");
	            userStat.put("number of backup connections", "number of backup connections");
	            
	            HashMap<String,String> cacheStat = new HashMap<>();
	            cacheStat.put("user log cache size", "user log cache size");
	            cacheStat.put("user log cache spinlock ratio", "user log cache spinlock ratio");
	            cacheStat.put("extended cache size","extended cache size");
	            cacheStat.put("total data cache size","total data cache size");
	            cacheStat.put("procedure cache size","procedure cache size");
	            cacheStat.put("statement cache size","statement cache size");
	            cacheStat.put("user log cache queue size","user log cache queue size");
	            cacheStat.put("workload manager cache size","workload manager cache size");
	            cacheStat.put("permission cache entries","permission cache entries");
	            cacheStat.put("session tempdb log cache size","session tempdb log cache size");
	            
	            
	            List<String> metricNeed= new ArrayList<>();
	            metricNeed.add("max concurrently recovered db");
//	            metricNeed.add("number of checkpoint tasks");
	            metricNeed.add("number of dump load retries");
	            metricNeed.add("recovery interval in minutes");
	            metricNeed.add("extended cache size");
	            metricNeed.add("number of index trips");
	            metricNeed.add("total data cache size");
	            metricNeed.add("maximum dump conditions");
	            metricNeed.add("memory dump compression level");
	            metricNeed.add("number of dump threads");
	            metricNeed.add("disk i/o structures");
	            metricNeed.add("number of devices");
	            metricNeed.add("number of disk tasks");
	            metricNeed.add("number of large i/o buffers");
	            metricNeed.add("page utilization percent");
	            metricNeed.add("solaris async i/o mode");
	            metricNeed.add("number of java sockets");
	            metricNeed.add("size of global fixed heap");
	            metricNeed.add("size of process object heap");
	            metricNeed.add("size of shared class heap");
	            metricNeed.add("deadlock retries");
	            metricNeed.add("lock hashtable size");
	            metricNeed.add("lock spinlock ratio");
	            metricNeed.add("lock table spinlock ratio");
	            metricNeed.add("lock wait period");
	            metricNeed.add("number of locks");
	            metricNeed.add("read committed with lock");
	            metricNeed.add("messaging memory");
	            metricNeed.add("number of alarms");
	            metricNeed.add("number of mailboxes");
	            metricNeed.add("number of messages");
	            metricNeed.add("number of open databases");
//	            metricNeed.add("number of open indexes");
//	            metricNeed.add("number of open objects");
	            metricNeed.add("number of open partitions");
	            metricNeed.add("number of remote connections");
//	            metricNeed.add("number of remote logins");
	            metricNeed.add("number of remote sites");
	            metricNeed.add("number of user connections");
	            metricNeed.add("number of worker processes");
	            metricNeed.add("open index hash spinlock ratio");
	            metricNeed.add("open index spinlock ratio");
	            metricNeed.add("partition spinlock ratio");
	            metricNeed.add("procedure cache size");
	            metricNeed.add("process wait events");
	            metricNeed.add("remote server pre-read packets");
	            metricNeed.add("size of global fixed heap");
	            metricNeed.add("size of process object heap");
	            metricNeed.add("size of shared class heap");
	            metricNeed.add("stack size");
	            metricNeed.add("statement cache size");
	            metricNeed.add("statement pipe max messages");
	            metricNeed.add("threshold event max messages");
	            metricNeed.add("total data cache size");
	            metricNeed.add("total logical memory");
	            metricNeed.add("total physical memory");
	            metricNeed.add("user log cache size");
	            metricNeed.add("user log cache spinlock ratio");
	            metricNeed.add("workload manager cache size");
	            metricNeed.add("number of engines at startup");
	            metricNeed.add("number of network tasks");
	            metricNeed.add("default network packet size");
	            metricNeed.add("number of backup connections");
	            metricNeed.add("permission cache entries");
	            metricNeed.add("session tempdb log cache size");
	            metricNeed.add("stack guard size");
	            metricNeed.add("user log cache queue size");
	            
	            Statement statement = connection.createStatement();
	            int metricNeedSize = metricNeed.size();
	            for(int c=0; c<metricNeedSize;++c) {
	            	
	            	String query = "sp_configure"+" '"+metricNeed.get(c)+"'";
	            	
                  	ResultSet resultSet = statement.executeQuery(query);
	            	ResultSetMetaData metaData = resultSet.getMetaData();
	            	
	            	int columnCount = metaData.getColumnCount();
	            	String metric="";
	            	String dataValue="";
	            	if(memoryData.containsKey(metricNeed.get(c)) && resultSet.next()) {
	            		JSONObject memObj = new JSONObject();
	            		for(int i = 1; i <= columnCount; i++) {
	            			
	            			if(metaData.getColumnName(i).equals("Parameter Name")) {
	            				metric = (String)resultSet.getObject(i);
		            			metric = metric.replaceAll("\\s{2,}", " ");
	            			}
	            			else if(metaData.getColumnName(i).equals("Run Value") ) {
		            			dataValue = (String)resultSet.getObject(i);
		            			dataValue = dataValue.replaceAll("\\s{2,}", " ");
		            		}
	            			
	            		}
                    	memObj.put("value",dataValue);
                    	memObj.put("name",metric);
                    	memArray.put(memObj);
	            	}
	            	else if(userStat.containsKey(metricNeed.get(c)) && resultSet.next()) {
	            		JSONObject memObj = new JSONObject();
	            		for(int i = 1; i <= columnCount; i++) {
	            			
	            			if(metaData.getColumnName(i).equals("Parameter Name")) {
	            				metric = (String)resultSet.getObject(i);
		            			metric = metric.replaceAll("\\s{2,}", " ");
	            			}
	            			else if(metaData.getColumnName(i).equals("Run Value") ) {
		            			dataValue = (String)resultSet.getObject(i);
		            			dataValue = dataValue.replaceAll("\\s{2,}", " ");
		            		}
	            			
	            		}
	            		
                    	memObj.put("value",dataValue);
                    	memObj.put("name",metric);
                    	userStatitistics.put(memObj);
	            	}
	            	else if(cacheStat.containsKey(metricNeed.get(c)) && resultSet.next()) {
	            		JSONObject memObj = new JSONObject();
	            		for(int i = 1; i <= columnCount; i++) {
	            			
	            			if(metaData.getColumnName(i).equals("Parameter Name")) {
	            				metric = (String)resultSet.getObject(i);
		            			metric = metric.replaceAll("\\s{2,}", " ");
	            			}
	            			else if(metaData.getColumnName(i).equals("Run Value") ) {
		            			dataValue = (String)resultSet.getObject(i);
		            			dataValue = dataValue.replaceAll("\\s{2,}", " ");
		            		}
	            			
	            		}
                    	memObj.put("value",dataValue);
                    	memObj.put("name",metric);
                    	cacheStats.put(memObj);
                    	
	            	}
	            	else if(resultSet.next()) {
	            		
		            	for (int i = 1; i <= columnCount; i++) {
		            		if(metaData.getColumnName(i).equals("Parameter Name") ) {
		            			metric = (String)resultSet.getObject(i);
		            			metric = metric.replaceAll("\\s{2,}", " ");
		            		}
		            		else if(metaData.getColumnName(i).equals("Run Value") ) {
		            			dataValue = (String)resultSet.getObject(i);
		            			dataValue = dataValue.replaceAll("\\s{2,}", " ");
		            		}
		            	}
		            	
		            	data.put(metric, dataValue);
	            	}
	            }
	            memory_usage(connection,data,memoryData,memArray);
	            data.put("Memory_Usage",memArray);
	            data.put("User_Statistics",userStatitistics);
	            data.put("Cache_Statistics",cacheStats);
	            
	            JSONArray tabList1 = new JSONArray();
	            tabList1.put("User_Statistics");
	            tabList1.put("Cache_Statistics");
	            JSONObject  tabDetail1= new JSONObject();
	            tabDetail1.put("order", 1);
	            tabDetail1.put("tablist", tabList1);
	            
	            JSONArray tabList2 = new JSONArray();
	            tabList2.put("Memory_Usage");
	            JSONObject  tabDetail2= new JSONObject();
	            tabDetail2.put("order", 2);
	            tabDetail2.put("tablist", tabList2);
	            
	            tabs.put("Overview",tabDetail1 );
	            tabs.put("Memory_Details",tabDetail2 );
	            
	            data.put("tabs", tabs);
	            
	            
	            System.out.println(data);
	            
	            connection.close();
	        } catch (Exception e) {
	        	data.put("msg",e);
	        }
	    }
	    
	    private static void memory_usage(Connection connection,JSONObject data,HashMap<String,String> memoryData,JSONArray memArray) {
	    	
	    	try {
	    		Statement statement = connection.createStatement();
		    	ResultSet resultSet = statement.executeQuery("select * from ETSServiceMemoryView");
	        	ResultSetMetaData metaData = resultSet.getMetaData();
	            int columnCount = metaData.getColumnCount();
	            while (resultSet.next()) {
	                for (int i = 1; i <= columnCount; i++) {
	                	String columnName = metaData.getColumnName(i);
	                	if (memoryData.containsKey(columnName)) {
	                		JSONObject memObj = new JSONObject();
		                    Object columnValue = resultSet.getObject(i);
		                	memObj.put("name",memoryData.get(columnName));
	                    	memObj.put("value",columnValue);
	                    	memArray.put(memObj);
	                	}
	                }
	            }
	            
	    	}catch(Exception e) {
	    		data.put("msg",e);
	    	}
	    	
	    }
}

