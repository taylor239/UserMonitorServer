package com.datacollector;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Servlet implementation class TokenStatusServlet
 */
@WebServlet("/TokenStatus")
public class TokenStatusServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public TokenStatusServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		
		Gson gson = new GsonBuilder().create();
		
		String username = request.getParameter("username");
		String event = request.getParameter("event");
		String token = request.getParameter("token");
		String verify = request.getParameter("verifier");
		
		if(!verify.equals("for_revenge"))
		{
			System.out.println("Challenge unacceptable");
			return;
		}
		
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			TestingConnectionSource myConnectionSource = new TestingConnectionSource();
			
			Connection dbConn = myConnectionSource.getDatabaseConnection();
			
			String query = "SELECT * FROM `openDataCollectionServer`.`UploadToken` WHERE `event` = ? AND `username` = ? AND `token` = ?";
			
			PreparedStatement toInsert = dbConn.prepareStatement(query);
			toInsert.setString(1, event);
			toInsert.setString(2, username);
			toInsert.setString(3, token);
			ResultSet myResults = toInsert.executeQuery();
			if(!myResults.next())
			{
				System.out.println("no such token");
				HashMap outputMap = new HashMap();
				outputMap.put("result", "nokay");
				String output = gson.toJson(outputMap);
				response.getWriter().append(output);
				return;
			}
			int framesUploaded = myResults.getInt("framesUploaded");
			int totalFrames = myResults.getInt("framesRemaining");
			boolean isActive = myResults.getBoolean("active");
			boolean isContinuous = myResults.getBoolean("continuous");
			HashMap outputMap = new HashMap();
			outputMap.put("result", "ok");
			outputMap.put("framesUploaded", framesUploaded);
			outputMap.put("framesLeft", totalFrames);
			outputMap.put("isActive", isActive);
			outputMap.put("continuous", isContinuous);
			outputMap.put("username", username);
			outputMap.put("token", token);
			String output = gson.toJson(outputMap);
			response.getWriter().append(output);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		
		//response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
