package com.datacollector;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.zip.GZIPInputStream;

import javax.servlet.http.HttpSession;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

@ServerEndpoint(value = "/UploadData", configurator = GetHttpSessionConfigurator.class)
public class UploadDataWebsocket
{
	private Session wsSession;
	private HttpSession httpSession;
	
	@OnOpen
	public void start(Session session, EndpointConfig config)
	{
		this.wsSession = session;
		this.httpSession = (HttpSession) config.getUserProperties().get(HttpSession.class.getName());
		System.out.println("Got new data upload");
		session.setMaxTextMessageBufferSize(200826410);
	}
	
	@OnClose
	public void end()
	{
		System.out.println("Server ended");
	}
	
	@OnMessage
	public void incoming(String message, Session session)
	{
		System.out.println("Got message:");
		System.out.println(message.length());
		if(message.equals("end"))
		{
			try {
				session.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			return;
		}
		
		byte[] compressed = Base64.getDecoder().decode(message);
		ByteArrayInputStream input = new ByteArrayInputStream(compressed);
		GZIPInputStream ungzip = null;
		try {
			ungzip = new GZIPInputStream(input);
		} catch (IOException e2) {
			// TODO Auto-generated catch block
			e2.printStackTrace();
		}
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		byte[] buffer = new byte[1024];
		int length = 0;
		try
		{
		while((length = ungzip.read(buffer)) > 0)
		{
			output.write(buffer, 0, length);
		}
		ungzip.close();
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
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
		String admin = (String) fromJSON.get("admin");
		
		Connection conn = null;
        Statement stmt = null;
        ResultSet rset = null;
		
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			//HttpSession session = request.getSession(true);
			DatabaseConnector myConnector=(DatabaseConnector)httpSession.getAttribute("connector");
			if(myConnector==null)
			{
				myConnector=new DatabaseConnector(httpSession.getServletContext());
				httpSession.setAttribute("connector", myConnector);
			}
			TestingConnectionSource myConnectionSource = myConnector.getConnectionSource();
			
			
			Connection dbConn = myConnectionSource.getDatabaseConnectionNoTimeout();
			conn = dbConn;
			
			String query = "SELECT * FROM `UploadToken` INNER JOIN `Event` ON `UploadToken`.`event` = `Event`.`event`  WHERE `username` = ? AND `token` = ? AND `UploadToken`.`event` = ? AND `UploadToken`.`adminEmail` = ?";
			
			PreparedStatement toInsert = dbConn.prepareStatement(query);
			stmt = toInsert;
			toInsert.setString(1, username);
			toInsert.setString(2, token);
			toInsert.setString(3, event);
			toInsert.setString(4, admin);
			ResultSet myResults = toInsert.executeQuery();
			rset = myResults;
			if(!myResults.next())
			{
				System.out.println("no such token: " + username + ", " + event + ", " + admin + ", " + token);
				HashMap outputMap = new HashMap();
				outputMap.put("result", "nokay");
				String toWrite = gson.toJson(outputMap);
				session.getBasicRemote().sendText(toWrite);
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
					HashMap outputMap = new HashMap();
					outputMap.put("result", "nokay");
					String toWrite = gson.toJson(outputMap);
					session.getBasicRemote().sendText(toWrite);
					return;
				}
				else if(isContinuous)
				{
					Date curDate = new Date();
					if(curDate.after(endDate))
					{
						System.out.println("after end date");
						HashMap outputMap = new HashMap();
						outputMap.put("result", "nokay");
						String toWrite = gson.toJson(outputMap);
						session.getBasicRemote().sendText(toWrite);
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
					
					String userInsert = "INSERT IGNORE INTO `User` " + headings + " VALUES ";
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
					stmt.close();
					stmt = insertStatement;
					
					int curEnt = 1;
					boolean broken = false;
					for(Map entry : userList)
					{
						if(!entry.get("username").equals(username))
						{
							System.out.println("Invalid user: " + entry.get("username") + ", " + username);
							broken = true;
							break;
						}
						//else if(!entry.get("session").equals(session))
						//{
						//	System.out.println("Invalid session: " + entry.get("username") + ", " + username);
						//	broken = true;
						//	break;
						//}
						else if(!entry.get("event").equals(event))
						{
							System.out.println("Invalid event: " + entry.get("username") + ", " + username);
							broken = true;
							break;
						}
						else if(!entry.get("adminEmail").equals(admin))
						{
							System.out.println("Invalid adminEmail: " + entry.get("username") + ", " + username);
							broken = true;
							break;
						}
						else for(String key : masterKeySet)
						{
							//System.out.println(entry.get(key).getClass());
							insertStatement.setString(curEnt, "" + entry.get(key));
							curEnt++;
						}
					}
					
					if(!broken)
					{
						insertStatement.execute();
					}
					insertStatement.close();
				}
				
				insertInto("Screenshot", fromJSON, dbConn, username, event, admin);
				insertInto("Process", fromJSON, dbConn, username, event, admin);
				insertInto("ProcessArgs", fromJSON, dbConn, username, event, admin);
				insertInto("ProcessAttributes", fromJSON, dbConn, username, event, admin);
				insertInto("Window", fromJSON, dbConn, username, event, admin);
				insertInto("WindowDetails", fromJSON, dbConn, username, event, admin);
				insertInto("MouseInput", fromJSON, dbConn, username, event, admin);
				insertInto("KeyboardInput", fromJSON, dbConn, username, event, admin);
				insertInto("Task", fromJSON, dbConn, username, event, admin);
				insertInto("TaskEvent", fromJSON, dbConn, username, event, admin);
				
				double totalDoneTmp = (Double) fromJSON.get("totalDone");
				double totalToDoTmp = (Double) fromJSON.get("totalToDo");
				int totalDone = (int)totalDoneTmp;
				int totalToDo = (int)totalToDoTmp;
				
				String updateNumQuery = "UPDATE `UploadToken` SET `framesUploaded` = ?, `framesRemaining` = ? WHERE `UploadToken`.`username` = ? AND `UploadToken`.`token` = ? AND `UploadToken`.`adminEmail` = ? AND `UploadToken`.`event` = ?";
				PreparedStatement toUpdate = dbConn.prepareStatement(updateNumQuery);
				toUpdate.setInt(1, totalDone);
				toUpdate.setInt(2, totalToDo);
				toUpdate.setString(3, username);
				toUpdate.setString(4, token);
				toUpdate.setString(5, admin);
				toUpdate.setString(6, event);
				toUpdate.execute();
				stmt = toUpdate;
				stmt.close();
				
				if(totalToDo <= 0)
				{
					String inactiveQuery = "UPDATE `UploadToken` SET `active` = '0' WHERE `UploadToken`.`username` = ? AND `UploadToken`.`token` = ?";
					PreparedStatement toInactive = dbConn.prepareStatement(inactiveQuery);
					toInactive.setString(1, username);
					toInactive.setString(2, token);
					toInactive.execute();
					stmt = toInactive;
					stmt.close();
				}
				//dbConn.commit();
				dbConn.close();
			}
			if (conn != null) conn.close();
		}
		catch(Exception e)
		{
			HashMap outputMap = new HashMap();
			outputMap.put("result", "nokay");
			String toWrite = gson.toJson(outputMap);
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			e.printStackTrace();
			return;
		}
		finally
		{
            try { if (rset != null) rset.close(); } catch(Exception e) { }
            try { if (stmt != null) stmt.close(); } catch(Exception e) { }
            try { if (conn != null) conn.close(); } catch(Exception e) { }
        }
		
		System.out.println(new Date());
		System.out.println("Done: " + fromJSON.get("totalDone") + "/" + fromJSON.get("totalToDo"));
		
		
		HashMap outputMap = new HashMap();
		outputMap.put("result", "ok");
		String toWrite = gson.toJson(outputMap);
		try {
			session.getBasicRemote().sendText(toWrite);
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		
		/*
		try
		{
			session.getBasicRemote().sendText("Hello Client " + session.getId() + "!");
			//session.close();
		}
		catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		*/
	}
	
	public void insertInto(String table, Map fromJSON, Connection dbConn, String username, String eventname, String adminemail) throws Exception
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
			
			String userInsert = "INSERT IGNORE INTO `" + table + "` " + headings + " VALUES ";
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
					System.out.println("Invalid username: " + entry.get("username") + ", " + username);
					return;
				}
				if(!entry.get("event").equals(eventname))
				{
					System.out.println("Invalid event: " + entry.get("event") + ", " + username);
					return;
				}
				if(!entry.get("adminEmail").equals(adminemail))
				{
					System.out.println("Invalid adminEmail: " + entry.get("adminEmail") + ", " + username);
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
			//dbConn.close();
		}
	}
	
	@OnError
	public void onError(Throwable t) throws Throwable
	{
		t.printStackTrace();
	}
}
