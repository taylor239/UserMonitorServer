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
 * Servlet implementation class TokensAvailableJSON
 */
@WebServlet("/openDataCollection/getUploadInfo.json")
public class GetUploadInfo extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public GetUploadInfo() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		Gson gson = new GsonBuilder().create();
		
		Connection dbConn = null;
		PreparedStatement stmt = null;
		ResultSet results = null;
		
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
			
			
			dbConn = myConnectionSource.getDatabaseConnection();
			
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
						stmt = queryStmt;
						queryStmt.setString(1, adminEmail);
						queryStmt.setString(2, password);
						ResultSet myResults = queryStmt.executeQuery();
						results = myResults;
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
				}
			}

			
			
			String admin = (String)session.getAttribute("admin");
			//eventName
			
			UploadMonitor uploadMonitor = UploadMonitor.getUploadMonitor();
			ConcurrentHashMap eventList = uploadMonitor.getEventMap(admin, eventName);
			if(eventList == null)
			{
				eventList = new ConcurrentHashMap();
			}
			
			//System.out.println("Sending:");
			//System.out.println(eventList);
			
			String output = gson.toJson(eventList);
			response.getWriter().append(output);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			if(dbConn != null) { try { dbConn.close(); } catch(Exception e) {}}
			if(stmt != null) { try { stmt.close(); } catch(Exception e) {}}
			if(results != null) { try { results.close(); } catch(Exception e) {}}
		}
		response.getWriter().close();
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
