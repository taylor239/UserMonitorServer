package com.datacollector;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Servlet implementation class DataExportJson
 */
@WebServlet("/openDataCollection/logExport.json")
public class DataExportLog extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DataExportLog() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			HttpSession session = request.getSession(true);
			DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
			if(myConnector==null)
			{
				myConnector=new DatabaseConnector(getServletContext());
				session.setAttribute("connector", myConnector);
			}
			TestingConnectionSource myConnectionSource = myConnector.getConnectionSource();
			
			
			Connection dbConn = myConnectionSource.getDatabaseConnection();
			
			String eventName = request.getParameter("event");

			if(request.getParameter("email") != null)
			{
				session.removeAttribute("admin");
				session.removeAttribute("adminName");
				String adminEmail = request.getParameter("email");
				if(request.getParameter("password") != null)
				{
					String password = request.getParameter("password");
					String loginQuery = "SELECT * FROM `openDataCollectionServer`.`Admin` WHERE `adminEmail` = ? AND `adminPassword` = ?";
					
					PreparedStatement outerStmt = null;
					ResultSet outerSet = null;
					
					try
					{
						PreparedStatement queryStmt = dbConn.prepareStatement(loginQuery);
						outerStmt = queryStmt;
						queryStmt.setString(1, adminEmail);
						queryStmt.setString(2, password);
						ResultSet myResults = queryStmt.executeQuery();
						outerSet = myResults;
						if(myResults.next())
						{
							session.setAttribute("admin", myResults.getString("adminEmail"));
							session.setAttribute("adminName", myResults.getString("name"));
						}
						
						myResults.close();
						queryStmt.close();
						dbConn.close();
					}
					catch(Exception e)
					{
						e.printStackTrace();
					}
					finally
					{
						try { if (outerSet != null) outerSet.close(); } catch(Exception e) { }
			            try { if (outerStmt != null) outerStmt.close(); } catch(Exception e) { }
			            try { if (dbConn != null) dbConn.close(); } catch(Exception e) { }
					}
				}
			}
			
			
			String admin = (String)session.getAttribute("admin");
			
			String toSelect = request.getParameter("datasources");
			
			ArrayList userSelectList = new ArrayList();
			
			String usersToSelect = request.getParameter("users");
			
			System.out.println("Exporting: " + toSelect + " for " + usersToSelect);
			
			if(usersToSelect != null && !usersToSelect.isEmpty() && !usersToSelect.equals("null"))
			{
				String[] userSelectArray = usersToSelect.split(",");
				Collections.addAll(userSelectList, userSelectArray);
				System.out.println(userSelectList);
			}
			else
			{
				//userSelectList.add("%");
			}
			
			ArrayList dataTypes = new ArrayList();
			
			//ArrayList dataList = myConnector.getCollectedData(eventName, admin);
			ConcurrentHashMap headMap = new ConcurrentHashMap();
			if(toSelect.contains("events"))
			{
				dataTypes.add("events");
				ConcurrentHashMap eventMap = myConnector.getTasksHierarchy(eventName, admin, userSelectList);
				headMap = myConnector.mergeMaps(headMap, eventMap);
			}
			if(toSelect.contains("windows"))
			{
				dataTypes.add("windows");
				ConcurrentHashMap dataMap = myConnector.getWindowDataHierarchy(eventName, admin, userSelectList);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("processes"))
			{
				dataTypes.add("processes");
				ConcurrentHashMap dataMap = myConnector.getProcessDataHierarchy(eventName, admin, userSelectList);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("keystrokes"))
			{
				dataTypes.add("keystrokes");
				ConcurrentHashMap dataMap = myConnector.getKeystrokesHierarchy(eventName, admin, userSelectList);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("mouse"))
			{
				dataTypes.add("mouse");
				ConcurrentHashMap dataMap = myConnector.getMouseHierarchy(eventName, admin, userSelectList);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("screenshots"))
			{
				dataTypes.add("screenshots");
				ConcurrentHashMap screenshotMap = myConnector.getScreenshotsHierarchy(eventName, admin, userSelectList, false);
				headMap = myConnector.mergeMaps(headMap, screenshotMap);
			}
			if(toSelect.contains("screenshotindices"))
			{
				dataTypes.add("screenshots");
				ConcurrentHashMap screenshotMap = myConnector.getScreenshotsHierarchy(eventName, admin, userSelectList, true);
				headMap = myConnector.mergeMaps(headMap, screenshotMap);
			}
			headMap = myConnector.normalizeAllTime(headMap);
			
			//System.out.println("Exporting " + headMap.size());
			//System.out.println(dataTypes);
			
			HashMap finalMap = new HashMap();
			
			Iterator userIterator = headMap.entrySet().iterator();
			while(userIterator.hasNext())
			{
				Entry userEntry = (Entry) userIterator.next();
				String curUser = (String) userEntry.getKey();
				//System.out.println("User: " + curUser);
				//System.out.println(userEntry.getValue().getClass());
				ConcurrentHashMap sessionMap = (ConcurrentHashMap) userEntry.getValue();
				//System.out.println(sessionMap.size());
				Iterator sessionIterator = (Iterator) sessionMap.entrySet().iterator();
				while(sessionIterator.hasNext())
				{
					Entry sessionEntry = (Entry) sessionIterator.next();
					String curSession = (String) sessionEntry.getKey();
					//System.out.println("Sess: " + curSession);
					//System.out.println(sessionEntry.getValue().getClass());
					ConcurrentHashMap dataMap = (ConcurrentHashMap) sessionEntry.getValue();
					ArrayList timelineList = toTimeline(dataMap, dataTypes);
					
					HashMap finalUserMap = new HashMap();
					if(finalMap.containsKey(curUser))
					{
						finalUserMap = (HashMap) finalMap.get(curUser);
					}
					
					finalUserMap.put(curSession, timelineList);
					
					finalMap.put(curUser, finalUserMap);
				}
			}
			
			System.out.println("Encoding to JSON");
			
			Gson gson = new GsonBuilder().create();
			String output = gson.toJson(finalMap);
			
			System.out.println("Sending");
			
			response.getWriter().append(output);
			
			System.out.println("Done");
			//Gson gson = new GsonBuilder().create();
			//String output = gson.toJson(headMap);
			//response.getWriter().append(output);
		}
		catch(Exception e)
		{
			
		}
	}
	
	public ArrayList toTimeline(ConcurrentHashMap dataMap, ArrayList dataTypes)
	{
		//System.out.println(dataMap);
		//System.out.println(dataTypes);
		
		ArrayList myReturn = new ArrayList();
		
		ArrayList nextDataTypes = new ArrayList();
		
		for(int x=0; x<dataTypes.size(); x++)
		{
			if(dataMap.containsKey(dataTypes.get(x)))
			{
				nextDataTypes.add(dataTypes.get(x));
			}
		}
		
		dataTypes = nextDataTypes;
		
		//System.out.println(dataTypes);
		
		while(!dataTypes.isEmpty())
		{
			//System.out.println(dataTypes);
			//System.out.println(dataTypes.get(0));
			//System.out.println(dataMap.get(dataTypes.get(0)));
			ArrayList initList = (ArrayList) dataMap.get(dataTypes.get(0));
			//System.out.println(initList.get(0).getClass());
			ConcurrentHashMap curMap = (ConcurrentHashMap) initList.get(0);
			long minTime = (long) curMap.get("Index MS");
			int curSource = 0;
			
			for(int x=1; x<dataTypes.size(); x++)
			{
				initList = (ArrayList) dataMap.get(dataTypes.get(x));
				curMap = (ConcurrentHashMap) initList.get(0);
				long curTime = (long) curMap.get("Index MS");
				if(curTime < minTime)
				{
					minTime = curTime;
					curSource = x;
				}
			}
			
			initList = (ArrayList) dataMap.get(dataTypes.get(curSource));
			curMap = (ConcurrentHashMap) initList.get(0);
			initList.remove(0);
			curMap.put("DataType", dataTypes.get(curSource));
			myReturn.add(curMap);
			
			if(initList.isEmpty())
			{
				dataMap.remove(dataTypes.get(curSource));
				dataTypes.remove(curSource);
			}
		}
		
		return myReturn;
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
