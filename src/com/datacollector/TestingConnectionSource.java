package com.datacollector;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.UUID;
import java.sql.Connection;

public class TestingConnectionSource
{
	private Connection myConnection;
	
	
	String userName = "dataCollectorServer";
	String password = "uBgiDDGhndviQeEZ";
	String address = "jdbc:mysql://localhost:3306/openDataCollectionServer";
	
	public TestingConnectionSource()
	{
		/*
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
		}
		catch (ClassNotFoundException e)
		{
			e.printStackTrace();
		}
		*/
	}
	
	public Connection getDatabaseConnection()
	{
		if(myConnection != null)
		{
			return myConnection;
		}
		try
		{
			Class.forName("com.mysql.jdbc.Driver");
			Connection newConnection = DriverManager.getConnection(address, userName, password);
			return newConnection;
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		return null;
	}
	
	public void returnConnection(Connection toReturn)
	{
		myConnection = toReturn;
		//try
		//{
		//	toReturn.close();
		//}
		//catch (SQLException e)
		//{
		//	e.printStackTrace();
		//}
	}

}