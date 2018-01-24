package com.datacollector;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class AddTokenServlet
 */
@WebServlet(name = "AddToken", urlPatterns = { "/AddToken" })
public class AddTokenServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AddTokenServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		String username = request.getParameter("username");
		String event = request.getParameter("event");
		String token = request.getParameter("token");
		String mode = request.getParameter("mode");
		String verify = request.getParameter("verifier");
		
		
		int isContinuous = 0;
		if(mode != null && mode.equals("continuous"))
		{
			isContinuous = 1;
		}
		
		if(event == null || event.isEmpty() || event.equalsIgnoreCase("null"))
		{
			event = "";
		}
		
		if(!verify.equals("for_revenge"))
		{
			System.out.println("Challenge unacceptable");
			return;
		}
		
		TestingConnectionSource myConnectionSource = new TestingConnectionSource();
		
		Connection dbConn = myConnectionSource.getDatabaseConnection();
		
		String query = "INSERT INTO `openDataCollectionServer`.`UploadToken` (`event`, `username`, `token`, `continuous`) VALUES (?, ?, ?, ?);";
		try
		{
			PreparedStatement toInsert = dbConn.prepareStatement(query);
			toInsert.setString(1, event);
			toInsert.setString(2, username);
			toInsert.setString(3, token);
			toInsert.setInt(4, isContinuous);
			toInsert.execute();
		}
		catch (SQLException e)
		{
			e.printStackTrace();
		}
		
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
