package com.datacollector;

import java.util.Date;
import java.util.Map;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

public class UploadMonitor implements Runnable
{
	private static UploadMonitor singletonMonitor = null;
	public static UploadMonitor getUploadMonitor()
	{
		if(singletonMonitor == null)
		{
			singletonMonitor = new UploadMonitor();
		}
		return singletonMonitor;
	}
	
	public static void shutDown()
	{
		if(singletonMonitor != null)
		{
			singletonMonitor.running = false;
		}
	}
	
	private ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>> adminMap;
	private Thread checkerThread = null;
	public UploadMonitor()
	{
		adminMap = new ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>>();
		checkerThread = new Thread(this);
		checkerThread.start();
	}
	
	public synchronized void activeUser(String admin, String event, String user, String token, ConcurrentHashMap<String, Object> metricValues)
	{
		if(!metricValues.containsKey("Insert Timestamp"))
		{
			long curTime = System.currentTimeMillis();
			metricValues.put("Insert Timestamp", curTime);
			metricValues.put("Formatted Timestamp", new Date(curTime));
			
		}
		
		ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>> eventMap = null;
		if(!adminMap.containsKey(admin))
		{
			eventMap = new ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>();
			adminMap.put(admin, eventMap);
		}
		
		ConcurrentHashMap<String, ConcurrentHashMap<String, Object>> userMap = null;
		if(!eventMap.containsKey(event))
		{
			userMap = new ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>();
			eventMap.put(event, userMap);
		}
		
		ConcurrentHashMap<String, Object> tokenMap = null;
		if(!userMap.containsKey(user))
		{
			tokenMap = new ConcurrentHashMap<String, Object>();
			userMap.put(user, tokenMap);
		}
		
		tokenMap.put(token, metricValues);
	}
	
	public synchronized int getNumAdminsActive()
	{
		return adminMap.size();
	}
	
	public synchronized int getNumEventsActive()
	{
		int totalCount = 0;
		for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>> entry : adminMap.entrySet())
		{
			totalCount += entry.getValue().size();
		}
		return totalCount;
	}
	
	public synchronized int getNumUsersActive()
	{
		int totalCount = 0;
		for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>> eventEntry : adminMap.entrySet())
		{
			for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>> userEntry : eventEntry.getValue().entrySet())
			{
				totalCount += userEntry.getValue().size();
			}
		}
		return totalCount;
	}
	
	public synchronized int getNumTokensActive()
	{
		int totalCount = 0;
		for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>> eventEntry : adminMap.entrySet())
		{
			for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>> userEntry : eventEntry.getValue().entrySet())
			{
				for(Entry<String, ConcurrentHashMap<String, Object>> tokenEntry : userEntry.getValue().entrySet())
				{
					totalCount += tokenEntry.getValue().size();
				}
			}
		}
		return totalCount;
	}
	
	public ConcurrentHashMap<String, ConcurrentHashMap<String, Object>> getEventMap(String admin, String event)
	{
		if(adminMap.containsKey(admin) && adminMap.get(admin).containsKey(event))
		{
			return adminMap.get(admin).get(event);
		}
		return null;
	}
	
	private boolean running = false;
	private int timeout = 10000;
	@Override
	public void run()
	{
		running = true;
		while(running)
		{
			//System.out.println(adminMap);
			for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>>> eventEntry : adminMap.entrySet())
			{
				for(Entry<String, ConcurrentHashMap<String, ConcurrentHashMap<String, Object>>> userEntry : eventEntry.getValue().entrySet())
				{
					for(Entry<String, ConcurrentHashMap<String, Object>> tokenEntry : userEntry.getValue().entrySet())
					{
						for(Entry<String, Object> dataEntry : tokenEntry.getValue().entrySet())
						{
							ConcurrentHashMap uploadMap = (ConcurrentHashMap) dataEntry.getValue();
							long insertTime = (long) uploadMap.get("Insert Timestamp");
							
							//System.out.println("Checking:");
							//System.out.println(uploadMap);
							
							// 5 minute check
							if(System.currentTimeMillis() - insertTime > (300000))
							{
								//System.out.println("Removing");
								((ConcurrentHashMap)tokenEntry.getValue()).remove(dataEntry.getKey());
							}
						}
						if(tokenEntry.getValue().isEmpty())
						{
							userEntry.getValue().remove(tokenEntry.getKey());
						}
					}
					if(userEntry.getValue().isEmpty())
					{
						eventEntry.getValue().remove(userEntry.getKey());
					}
				}
				if(eventEntry.getValue().isEmpty())
				{
					adminMap.remove(eventEntry.getKey());
				}
			}
			
			try
			{
				Thread.currentThread().sleep(timeout);
			}
			catch(InterruptedException e)
			{
				e.printStackTrace();
			}
		}
	}
}
