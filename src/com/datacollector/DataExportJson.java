package com.datacollector;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
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
@WebServlet("/openDataCollection/jsonExport.json")
public class DataExportJson extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public DataExportJson() {
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
					try
					{
						PreparedStatement queryStmt = dbConn.prepareStatement(loginQuery);
						queryStmt.setString(1, adminEmail);
						queryStmt.setString(2, password);
						ResultSet myResults = queryStmt.executeQuery();
						if(myResults.next())
						{
							session.setAttribute("admin", myResults.getString("adminEmail"));
							session.setAttribute("adminName", myResults.getString("name"));
						}
					}
					catch(Exception e)
					{
						e.printStackTrace();
					}
				}
			}
			
			
			String admin = (String)session.getAttribute("admin");
			
			String toSelect = request.getParameter("datasources");
			
			String usersToSelect = request.getParameter("users");
			
			//ArrayList dataList = myConnector.getCollectedData(eventName, admin);
			ConcurrentHashMap headMap = new ConcurrentHashMap();
			if(toSelect.contains("io"))
			{
				ConcurrentHashMap dataMap = myConnector.getCollectedDataHierarchy(eventName, admin);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("processes"))
			{
				ConcurrentHashMap dataMap = myConnector.getProcessDataHierarchy(eventName, admin);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("windows"))
			{
				ConcurrentHashMap dataMap = myConnector.getWindowDataHierarchy(eventName, admin);
				headMap = myConnector.mergeMaps(headMap, dataMap);
			}
			if(toSelect.contains("events"))
			{
				ConcurrentHashMap eventMap = myConnector.getTasksHierarchy(eventName, admin);
				headMap = myConnector.mergeMaps(headMap, eventMap);
			}
			if(toSelect.contains("screenshots"))
			{
				ConcurrentHashMap screenshotMap = myConnector.getScreenshotsHierarchy(eventName, admin);
				headMap = myConnector.mergeMaps(headMap, screenshotMap);
			}
			headMap = myConnector.normalizeAllTime(headMap);
			Gson gson = new GsonBuilder().create();
			String output = gson.toJson(headMap);
			response.getWriter().append(output);
		}
		catch(Exception e)
		{
			
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
