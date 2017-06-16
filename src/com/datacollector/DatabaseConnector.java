package com.datacollector;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;

import javax.imageio.ImageIO;

public class DatabaseConnector
{
	private String totalQuery = "SELECT * FROM `MouseInput` INNER JOIN `WindowDetails` ON `MouseInput`.`username` = `WindowDetails`.`username` AND `MouseInput`.`user` = `WindowDetails`.`user` AND `MouseInput`.`pid` = `WindowDetails`.`pid` AND `MouseInput`.`start` = `WindowDetails`.`start` AND `MouseInput`.`xid` = `WindowDetails`.`xid` AND `MouseInput`.`timeChanged` = `WindowDetails`.`timeChanged` INNER JOIN `Window` ON `Window`.`username` = `WindowDetails`.`username` AND `Window`.`user` = `WindowDetails`.`user` AND `Window`.`pid` = `WindowDetails`.`pid` AND `Window`.`start` = `WindowDetails`.`start` AND `Window`.`xid` = `WindowDetails`.`xid` INNER JOIN `ProcessAttributes` ON `WindowDetails`.`username` = `ProcessAttributes`.`username` AND `WindowDetails`.`user` = `ProcessAttributes`.`user` AND `WindowDetails`.`pid` = `ProcessAttributes`.`pid` AND `WindowDetails`.`start` = `ProcessAttributes`.`start` AND `WindowDetails`.`timeChanged` = `ProcessAttributes`.`timestamp` INNER JOIN `Process` ON `Window`.`username` = `Process`.`username` AND `Window`.`user` = `Process`.`user` AND `Window`.`pid` = `Process`.`pid` AND `Window`.`start` = `Process`.`start` ORDER BY `MouseInput`.`username`, `MouseInput`.`inputTime`, `MouseInput`.`timeChanged`, `MouseInput`.`pid`, `MouseInput`.`xid`";
	private String userQuery = "SELECT * FROM `User`";
	
	private String taskQuery = "SELECT * FROM `Task` INNER JOIN `TaskEvent` ON `Task`.`username` = `TaskEvent`.`username` AND `Task`.`taskName` = `TaskEvent`.`taskName` ORDER BY `TaskEvent`.`username`, `TaskEvent`.`eventTime`";
	
	private String imageQuery = "SELECT * FROM `Screenshot` WHERE `username` = ? ORDER BY abs(UNIX_TIMESTAMP(?) - UNIX_TIMESTAMP(`taken`)) LIMIT 1";
	private TestingConnectionSource mySource;
	
	public DatabaseConnector()
	{
		mySource = new TestingConnectionSource();
	}
	
	public static void main(String[] args)
	{
		DatabaseConnector myConnector = new DatabaseConnector();
		ArrayList results = myConnector.getUsers();
		for(int x=0; x<results.size(); x++)
		{
			System.out.println(results.get(x));
			
		}
		System.out.println("\n");
		ArrayList filteredResults = myConnector.getStartNodes(results);
		for(int x=0; x<filteredResults.size(); x++)
		{
			System.out.println(filteredResults.get(x));
			
		}
		
		System.out.println(myConnector.toJSON(filteredResults));
	}
	
	public ArrayList getStartNodesTask(ArrayList fullData)
	{
		ArrayList myReturn = new ArrayList();
		
		HashMap prevNode = null;
		HashMap curNode = null;
		HashMap lastNode = null;
		String userName = "";
		
		for(int x=0; x<fullData.size(); x++)
		{
			curNode = (HashMap) fullData.get(x);
			if(prevNode != null)
			{
				if(!curNode.get("Username").equals(userName))
				{
					prevNode.put("End Time MS", lastNode.get("Event Time MS"));
				}
			}
			else
			{
				myReturn.add(curNode);
				prevNode = curNode;
				userName = (String) prevNode.get("Username");
				
			}
			lastNode = curNode;
		}
		
		
		return myReturn;
	}
	
	public ArrayList getStartNodes(ArrayList fullData)
	{
		ArrayList myReturn = new ArrayList();
		
		HashMap prevNode = null;
		
		HashMap curNode = null;
		
		HashMap lastNode = null;
		
		String userName = "";
		
		for(int x=0; x<fullData.size(); x++)
		{
			curNode = (HashMap) fullData.get(x);
			if(prevNode != null)
			{
				if(!curNode.get("Username").equals(userName))
				{
					prevNode.put("End Time", lastNode.get("Input Time"));
					prevNode.put("End Time MS", lastNode.get("Input Time MS"));
					myReturn.add(curNode);
					prevNode = curNode;
					userName = (String) prevNode.get("Username");
				}
				else if(!prevNode.get("XID").equals(curNode.get("XID")))
				{
					myReturn.add(curNode);
					prevNode.put("End Time", curNode.get("Start Time"));
					if(curNode.containsKey("Start Time MS"))
					{
						prevNode.put("End Time MS", curNode.get("Start Time MS"));
					}
					prevNode = curNode;
				}
			}
			else
			{
				myReturn.add(curNode);
				prevNode = curNode;
				userName = (String) prevNode.get("Username");
			}
			lastNode = curNode;
			userName = (String) curNode.get("Username");
		}
		
		prevNode.put("End Time", curNode.get("Input Time"));
		prevNode.put("End Time MS", curNode.get("Input Time MS"));
		
		return myReturn;
	}
	
	
	public ArrayList convertTime(ArrayList input)
	{
		for(int x=0; x<input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			curMap.put("Start Time MS", ((Date) curMap.get("Start Time")).getTime());
			curMap.put("Input Time MS", ((Date) curMap.get("Input Time")).getTime());
			if(curMap.containsKey("End Time"))
			{
				curMap.put("End Time MS", ((Date) curMap.get("End Time")).getTime());
			}
		}
		
		return input;
	}
	
	public ArrayList convertTimeTask(ArrayList input)
	{
		for(int x=0; x<input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			curMap.put("Event Time MS", ((Date) curMap.get("Event Time")).getTime());
		}
		
		return input;
	}
	
	public ArrayList normalizeTimeTasks(ArrayList input)
	{
		HashMap userMinMap = new HashMap();
		HashMap userMaxMap = new HashMap();
		for(int x=0; x<input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			if(userMinMap.containsKey(curMap.get("Username")))
			{
				if((long)userMinMap.get(curMap.get("Username")) > (long)curMap.get("Event Time MS"))
				{
					userMinMap.put(curMap.get("Username"), curMap.get("Event Time MS"));
				}
				if((long)userMaxMap.get(curMap.get("Username")) < (long)curMap.get("Event Time MS"))
				{
					userMaxMap.put(curMap.get("Username"), curMap.get("Event Time MS"));
				}
			}
			else
			{
				userMinMap.put(curMap.get("Username"), curMap.get("Event Time MS"));
				userMaxMap.put(curMap.get("Username"), curMap.get("Event Time MS"));
			}
		}
		
		for(int x=0; x<input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			curMap.put("Event Time MS", (long)curMap.get("Event Time MS") - (long)userMinMap.get(curMap.get("Username")));
		}
		
		return input;
	}
	
	public ArrayList normalizeTime(ArrayList input)
	{
		HashMap userMinMap = new HashMap();
		HashMap userMaxMap = new HashMap();
		for(int x=0; x<input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			if(userMinMap.containsKey(curMap.get("Username")))
			{
				if((long)userMinMap.get(curMap.get("Username")) > (long)curMap.get("Start Time MS"))
				{
					userMinMap.put(curMap.get("Username"), curMap.get("Start Time MS"));
				}
				if((long)userMaxMap.get(curMap.get("Username")) < (long)curMap.get("Input Time MS"))
				{
					userMaxMap.put(curMap.get("Username"), curMap.get("Input Time MS"));
				}
			}
			else
			{
				userMinMap.put(curMap.get("Username"), curMap.get("Start Time MS"));
				userMaxMap.put(curMap.get("Username"), curMap.get("Input Time MS"));
			}
		}
		
		for(int x=0; x<input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			curMap.put("Start Time MS", (long)curMap.get("Start Time MS") - (long)userMinMap.get(curMap.get("Username")));
			curMap.put("Input Time MS", (long)curMap.get("Input Time MS") - (long)userMinMap.get(curMap.get("Username")));
			if(curMap.containsKey("End Time"))
			{
				curMap.put("End Time MS", (long)curMap.get("End Time MS") - (long)userMinMap.get(curMap.get("Username")));
			}
		}
		
		return input;
	}
	
	public String toJSON(ArrayList input)
	{
		String myReturn = "{\n\t" + "\"windowEvents\":" + "\n\t[";
		
		for(int x=0; x <input.size(); x++)
		{
			HashMap curMap = (HashMap) input.get(x);
			String jsonString = "\n\t\t{";
			if(x > 0)
			{
				jsonString = "," + jsonString;
			}
			
			Iterator curIterator = curMap.entrySet().iterator();
			boolean first = true;
			while(curIterator.hasNext())
			{
				if(first)
				{
					first = false;
				}
				else
				{
					jsonString += ",";
				}
				Entry curEntry = (Entry) curIterator.next();
				jsonString += "\n\t\t\t\"" + curEntry.getKey() + "\": ";
				if(curEntry.getValue() instanceof Integer || curEntry.getValue() instanceof Long || curEntry.getValue() instanceof Double || curEntry.getValue() instanceof Float)
				{
					jsonString += curEntry.getValue();
				}
				else
				{
					jsonString += "\"" + curEntry.getValue() + "\"";
				}
			}
			
			jsonString += "\n\t\t}";
			myReturn += jsonString;
		}
		
		myReturn += "\n\t]\n}";
		
		return myReturn;
	}
	
	
	public ArrayList getUsers()
	{
		ArrayList myReturn = new ArrayList();
		
		Connection myConnector = mySource.getDatabaseConnection();
		try
		{
			PreparedStatement myStatement = myConnector.prepareStatement(userQuery);
			ResultSet myResults = myStatement.executeQuery();
			while(myResults.next())
			{
				HashMap nextRow = new HashMap();
				nextRow.put("Username", myResults.getString("username"));
				myReturn.add(nextRow);
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		return myReturn;
	}
	
	public ArrayList getTasks()
	{
		ArrayList myReturn = new ArrayList();
		
		Connection myConnector = mySource.getDatabaseConnection();
		try
		{
			PreparedStatement myStatement = myConnector.prepareStatement(taskQuery);
			ResultSet myResults = myStatement.executeQuery();
			while(myResults.next())
			{
				HashMap nextRow = new HashMap();
				
				nextRow.put("Username", myResults.getString("username"));
				nextRow.put("Task Name", myResults.getString("taskName"));
				nextRow.put("Completion", myResults.getString("completion"));
				nextRow.put("Event Time", myResults.getTimestamp("eventTime"));
				nextRow.put("Event", myResults.getString("event"));
				
				myReturn.add(nextRow);
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		return convertTimeTask(myReturn);
	}
	
	public ArrayList getCollectedData()
	{
		ArrayList myReturn = new ArrayList();
		
		Connection myConnector = mySource.getDatabaseConnection();
		try
		{
			PreparedStatement myStatement = myConnector.prepareStatement(totalQuery);
			ResultSet myResults = myStatement.executeQuery();
			while(myResults.next())
			{
				HashMap nextRow = new HashMap();
				
				String userName = myResults.getString("username");
				nextRow.put("Username", userName);
				
				
				String user = myResults.getString("user");
				nextRow.put("User", user);
				String pid = myResults.getString("pid");
				nextRow.put("PID", pid);
				String start = myResults.getString("start");
				nextRow.put("Start", start);
				//ArrayList processKey = new ArrayList();
				//processKey.add(user);
				//processKey.add(pid);
				//processKey.add(start);
				
				String command = myResults.getString("command");
				nextRow.put("Command", command);
				
				
				Date timeChanged = myResults.getTimestamp("timeChanged");
				nextRow.put("Start Time", timeChanged);
				
				double cpu = myResults.getDouble("cpu");
				nextRow.put("CPU", cpu);
				double mem = myResults.getDouble("mem");
				nextRow.put("Memory Use", mem);
				double vsz = myResults.getLong("vsz");
				nextRow.put("VSZ", vsz);
				double rss = myResults.getLong("rss");
				nextRow.put("RSS", rss);
				String tty = myResults.getString("tty");
				nextRow.put("TTY", tty);
				String stat = myResults.getString("stat");
				nextRow.put("Stat", stat);
				String time = myResults.getString("time");
				nextRow.put("Time", time);
				
				
				String xid = myResults.getString("xid");
				nextRow.put("XID", xid);
				
				String name = myResults.getString("name");
				nextRow.put("Window Name", name);
				String firstClass = myResults.getString("firstClass");
				nextRow.put("Window Class 1", firstClass);
				String secondClass = myResults.getString("secondClass");
				nextRow.put("Window Class 2", secondClass);
				
				
				String type = myResults.getString("type");
				nextRow.put("Input Type", type);
				int xLoc = myResults.getInt("xLoc");
				nextRow.put("Input Location X", xLoc);
				int yLoc = myResults.getInt("yLoc");
				nextRow.put("Input Location Y", yLoc);
				Date inputTime = myResults.getTimestamp("inputTime");
				nextRow.put("Input Time", inputTime);
				
				
				int x = myResults.getInt("x");
				nextRow.put("Window Location X", x);
				int y = myResults.getInt("y");
				nextRow.put("Window Location Y", y);
				int width = myResults.getInt("width");
				nextRow.put("Window Width", width);
				int height = myResults.getInt("height");
				nextRow.put("Window Height", height);
				
				
				
				myReturn.add(nextRow);
				
				
				
				/*
				HashMap userMap;
				if(myReturn.containsKey(userName))
				{
					userMap = (HashMap) myReturn.get(userName);
				}
				else
				{
					userMap = new HashMap();
				}
				
				HashMap processMap;
				if(userMap.containsKey(processKey))
				{
					processMap = (HashMap) userMap.get(processKey);
				}
				else
				{
					processMap = new HashMap();
				}
				
				processMap.put("command", command);
				
				
				
				
				
				userMap.put(processKey, processMap);
				myReturn.put(userMap, userMap);
				*/
			}
		}
		catch(SQLException e)
		{
			e.printStackTrace();
		}
		
		return convertTime(myReturn);
	}
	
	public byte[] getScreenshot(String username, String myTimestamp)
	{
		byte[] myReturn = null;
		
		Connection myConnector = mySource.getDatabaseConnection();
		try
		{
			PreparedStatement myStatement = myConnector.prepareStatement(imageQuery);
			myStatement.setString(1, username);
			myStatement.setString(2, myTimestamp);
			//myStatement.setString(3, myTimestamp);
			//System.err.println(myStatement.toString());
			ResultSet myResults = myStatement.executeQuery();
			while(myResults.next())
			{
				byte[] imageBytes = myResults.getBytes("screenshot");
				//BufferedImage img = ImageIO.read(new ByteArrayInputStream(imageBytes));
				myReturn = imageBytes;
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		return myReturn;
	}
}
