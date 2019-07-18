package com.datacollector;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.GZIPInputStream;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Servlet implementation class UploadData
 */
@WebServlet("/UploadData")
public class UploadData extends HttpServlet
{
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UploadData()
    {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		System.out.println("Got a request");
		System.out.println("On server: " + ((double)request.getParameter("uploadData").length()) / 1000000.0);
		byte[] compressed = Base64.getDecoder().decode(request.getParameter("uploadData"));
		ByteArrayInputStream input = new ByteArrayInputStream(compressed);
		GZIPInputStream ungzip = new GZIPInputStream(input);
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		byte[] buffer = new byte[1024];
		int length = 0;
		while((length = ungzip.read(buffer)) > 0)
		{
			output.write(buffer, 0, length);
		}
		ungzip.close();
		byte[] uncompressed = output.toByteArray();
		String uncompressedString = new String(uncompressed);
		if(uncompressedString.length() > 200)
		{
			System.out.println(uncompressedString.substring(0, 200));
		}
		else
		{
			System.out.println(uncompressedString);
		}
		
		Gson gson = new GsonBuilder().create();
		HashMap fromJSON = gson.fromJson(uncompressedString, HashMap.class);
		//System.out.println(fromJSON.keySet());
		System.out.println(fromJSON.get("username"));
		System.out.println(fromJSON.get("token"));
		String username = (String) fromJSON.get("username");
		String token = (String) fromJSON.get("token");
		String event = (String) fromJSON.get("event");
		
		Connection conn = null;
        Statement stmt = null;
        ResultSet rset = null;
		
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			TestingConnectionSource myConnectionSource = new TestingConnectionSource();
			
			Connection dbConn = myConnectionSource.getDatabaseConnection();
			conn = dbConn;
			
			String query = "SELECT * FROM `openDataCollectionServer`.`UploadToken` INNER JOIN `openDataCollectionServer`.`Event` ON `openDataCollectionServer`.`UploadToken`.`event` = `openDataCollectionServer`.`Event`.`event`  WHERE `username` = ? AND `token` = ? AND `openDataCollectionServer`.`UploadToken`.`event` = ?";
			
			PreparedStatement toInsert = dbConn.prepareStatement(query);
			stmt = toInsert;
			toInsert.setString(1, username);
			toInsert.setString(2, token);
			toInsert.setString(3, event);
			ResultSet myResults = toInsert.executeQuery();
			rset = myResults;
			if(!myResults.next())
			{
				System.out.println("no such token");
				return;
			}
			else
			{
				boolean isActive = myResults.getBoolean("active");
				boolean isContinuous = myResults.getBoolean("continuous");
				Timestamp endDate = myResults.getTimestamp("end");
				if(!isActive && !isContinuous)
				{
					System.out.println("inactive");
					return;
				}
				else if(isContinuous)
				{
					Date curDate = new Date();
					if(curDate.after(endDate))
					{
						System.out.println("after end date");
						return;
					}
				}
				
				
				if(fromJSON.containsKey("User") && ((List)fromJSON.get("User")).size() > 0)
				{
					List<Map> userList = (List) fromJSON.get("User");
					Map<String, Object> firstUser = (Map) userList.get(0);
					int listSize = userList.size();
					
					String headings = "(";
					String values = "(";
					boolean first = true;
					Set<String> masterKeySet = firstUser.keySet();
					for(String heading : masterKeySet)
					{
						if(first)
						{
							
						}
						else
						{
							values += ", ";
							headings += ", ";
						}
						values += "?";
						headings += heading;
						first = false;
					}
					values += ")";
					headings += ")";
					
					String userInsert = "INSERT IGNORE INTO `openDataCollectionServer`.`User` " + headings + " VALUES ";
					StringBuilder totalQuery = new StringBuilder();
					totalQuery.append(userInsert);
					first = true;
					for(int x=0; x<listSize; x++)
					{
						if(first)
						{
							
						}
						else
						{
							totalQuery.append(", ");
						}
						totalQuery.append(values);
						first = false;
					}
					userInsert = totalQuery.toString();
					System.out.println(userInsert);
					//System.out.println(userList);
					
					PreparedStatement insertStatement = dbConn.prepareStatement(userInsert);
					stmt.close();
					stmt = insertStatement;
					
					int curEnt = 1;
					for(Map entry : userList)
					{
						if(!entry.get("username").equals(username))
						{
							System.out.println("Invalid: " + entry.get("username") + ", " + username);
						}
						for(String key : masterKeySet)
						{
							System.out.println(entry.get(key).getClass());
							insertStatement.setString(curEnt, "" + entry.get(key));
							curEnt++;
						}
					}
					
					insertStatement.execute();
					insertStatement.close();
				}
				
				insertInto("Screenshot", fromJSON, dbConn, username);
				insertInto("Process", fromJSON, dbConn, username);
				insertInto("ProcessArgs", fromJSON, dbConn, username);
				insertInto("ProcessAttributes", fromJSON, dbConn, username);
				insertInto("Window", fromJSON, dbConn, username);
				insertInto("WindowDetails", fromJSON, dbConn, username);
				insertInto("MouseInput", fromJSON, dbConn, username);
				insertInto("KeyboardInput", fromJSON, dbConn, username);
				insertInto("Task", fromJSON, dbConn, username);
				insertInto("TaskEvent", fromJSON, dbConn, username);
				
				double totalDoneTmp = (Double) fromJSON.get("totalDone");
				double totalToDoTmp = (Double) fromJSON.get("totalToDo");
				int totalDone = (int)totalDoneTmp;
				int totalToDo = (int)totalToDoTmp;
				
				String updateNumQuery = "UPDATE `openDataCollectionServer`.`UploadToken` SET `framesUploaded` = ?, `framesRemaining` = ? WHERE `UploadToken`.`username` = ? AND `UploadToken`.`token` = ?";
				PreparedStatement toUpdate = dbConn.prepareStatement(updateNumQuery);
				toUpdate.setInt(1, totalDone);
				toUpdate.setInt(2, totalToDo);
				toUpdate.setString(3, username);
				toUpdate.setString(4, token);
				toUpdate.execute();
				stmt = toUpdate;
				stmt.close();
				
				if(totalToDo <= 0)
				{
					String inactiveQuery = "UPDATE `openDataCollectionServer`.`UploadToken` SET `active` = '0' WHERE `UploadToken`.`username` = ? AND `UploadToken`.`token` = ?";
					PreparedStatement toInactive = dbConn.prepareStatement(inactiveQuery);
					toInactive.setString(1, username);
					toInactive.setString(2, token);
					toInactive.execute();
					stmt = toInactive;
					stmt.close();
				}
			}
			if (conn != null) conn.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
            try { if (rset != null) rset.close(); } catch(Exception e) { }
            try { if (stmt != null) stmt.close(); } catch(Exception e) { }
            try { if (conn != null) conn.close(); } catch(Exception e) { }
        }
		
		System.out.println(new Date());
		System.out.println("Done: " + fromJSON.get("totalDone") + "/" + fromJSON.get("totalToDo"));
		
		
		
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}
	
	public void insertInto(String table, Map fromJSON, Connection dbConn, String username) throws Exception
	{
		if(fromJSON.containsKey(table) && ((List)fromJSON.get(table)).size() > 0)
		{
			List<Map> userList = (List) fromJSON.get(table);
			Map<String, Object> firstUser = (Map) userList.get(0);
			int listSize = userList.size();
			
			String headings = "(";
			String values = "(";
			boolean first = true;
			Set<String> masterKeySet = firstUser.keySet();
			for(String heading : masterKeySet)
			{
				if(first)
				{
					
				}
				else
				{
					values += ", ";
					headings += ", ";
				}
				values += "?";
				headings += heading;
				first = false;
			}
			values += ")";
			headings += ")";
			
			String userInsert = "INSERT IGNORE INTO `openDataCollectionServer`.`" + table + "` " + headings + " VALUES ";
			StringBuilder totalQuery = new StringBuilder();
			totalQuery.append(userInsert);
			first = true;
			for(int x=0; x<listSize; x++)
			{
				if(first)
				{
					
				}
				else
				{
					totalQuery.append(", ");
				}
				totalQuery.append(values);
				first = false;
			}
			userInsert = totalQuery.toString();
			//System.out.println(userInsert);
			//System.out.println(userList);
			
			PreparedStatement insertStatement = dbConn.prepareStatement(userInsert);
			
			int curEnt = 1;
			for(Map entry : userList)
			{
				if(!entry.get("username").equals(username))
				{
					System.out.println("Invalid: " + entry.get("username") + ", " + username);
					return;
				}
				for(String key : masterKeySet)
				{
					//System.out.println(entry.get(key).getClass());
					if(key.equals("screenshot"))
					{
						String toDecode = (String) entry.get(key);
						byte[] decoded = Base64.getDecoder().decode(toDecode);
						insertStatement.setBytes(curEnt, decoded);
					}
					else
					{
						insertStatement.setString(curEnt, "" + entry.get(key));
					}
					curEnt++;
				}
			}
			
			insertStatement.execute();
			insertStatement.close();
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

}
