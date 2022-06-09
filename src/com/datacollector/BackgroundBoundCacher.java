package com.datacollector;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;

public class BackgroundBoundCacher implements Runnable, DatabaseUpdateConsumer
{
	
	private Thread cacheThread;
	private boolean running = false;
	private int sleepDuration = 60000;
	
	private DatabaseConnector dedicatedConnector;
	
	private ConcurrentHashMap toCache;
	
	public BackgroundBoundCacher(DatabaseConnector myConn)
	{
		toCache = new ConcurrentHashMap();
		dedicatedConnector = myConn;
		cacheThread = new Thread(this);
		cacheThread.start();
	}
	
	public void addSession(String adminEmail, String event, String username, String session)
	{
		//System.out.println("Adding session to cache queue: " + session);
		if(!toCache.containsKey(adminEmail))
		{
			toCache.put(adminEmail, new ConcurrentHashMap());
		}
		ConcurrentHashMap adminEmailMap = (ConcurrentHashMap) toCache.get(adminEmail);
		
		if(!adminEmailMap.containsKey(event))
		{
			adminEmailMap.put(event, new ConcurrentHashMap());
		}
		ConcurrentHashMap eventMap = (ConcurrentHashMap) adminEmailMap.get(event);
		
		if(!eventMap.containsKey(username))
		{
			eventMap.put(username, new ConcurrentHashMap());
		}
		ConcurrentHashMap usernameMap = (ConcurrentHashMap) eventMap.get(username);
		
		if(!usernameMap.containsKey(session))
		{
			usernameMap.put(session, true);
		}
	}
	
	@Override
	public void run()
	{
		running = true;
		while(running)
		{
			//System.out.println("Running a round of cache on " + toCache.size() + " admins");
			ConcurrentHashMap lastMap = toCache;
			toCache = new ConcurrentHashMap();
			
			Iterator toCacheIterator = lastMap.entrySet().iterator();
			while(toCacheIterator.hasNext())
			{
				Entry adminEmailEntry = (Entry) toCacheIterator.next();
				String adminEmail = (String) adminEmailEntry.getKey();
				ConcurrentHashMap eventMap = (ConcurrentHashMap) adminEmailEntry.getValue();
				Iterator adminIterator = eventMap.entrySet().iterator();
				
				//System.out.println("Admin" + adminEmail + " Events: " + eventMap.size());
				
				while(adminIterator.hasNext())
				{
					Entry eventEntry = (Entry) adminIterator.next();
					String eventName = (String) eventEntry.getKey();
					ConcurrentHashMap userMap = (ConcurrentHashMap) eventEntry.getValue();
					Iterator eventIterator = userMap.entrySet().iterator();
					
					ArrayList finalSessionList = new ArrayList();
					
					//System.out.println("Users: " + userMap.size());
					
					while(eventIterator.hasNext())
					{
						Entry userEntry = (Entry) eventIterator.next();
						String userName = (String) userEntry.getKey();
						ConcurrentHashMap sessionMap = (ConcurrentHashMap) userEntry.getValue();
						Iterator userIterator = sessionMap.entrySet().iterator();
						
						//System.out.println("Sessions: " + sessionMap.size());
						
						while(userIterator.hasNext())
						{
							Entry sessionEntry = (Entry) userIterator.next();
							String sessionName = (String) sessionEntry.getKey();
							finalSessionList.add(sessionName);
						}
					}
					
					//System.out.println("Running cache round on:");
					//System.out.println(finalSessionList);
					dedicatedConnector.cacheBounds(eventName, adminEmail, this, null, finalSessionList);
				}
			}
			
			try
			{
				Thread.currentThread().sleep(sleepDuration);
			}
			catch(InterruptedException e)
			{
				e.printStackTrace();
			}
		}
	}
	
	public void stop()
	{
		running = false;
		if(cacheThread != null)
		{
			try {
				cacheThread.interrupt();
				cacheThread.join();
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	@Override
	public void consumeUpdate(Object update)
	{
		System.out.println("Cache bounds: " + update);
	}

	@Override
	public void endConsumption() {
		// TODO Auto-generated method stub
		
	}

}
