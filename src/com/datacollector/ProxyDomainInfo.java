package com.datacollector;

import java.io.File;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.ServletContext;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public class ProxyDomainInfo
{
	private static ProxyDomainInfo infoSource = null;
	
	private static String reportPath = null;
	
	public static String getProxiedDomain()
	{
		if(infoSource == null)
		{
			return "";
		}
		return infoSource.proxyDomain;
	}
	
	public static String getApplicationPath()
	{
		if(infoSource == null)
		{
			return "";
		}
		return infoSource.appLocation;
	}
	
	public static String getProxiedPort()
	{
		if(infoSource == null)
		{
			return "";
		}
		return infoSource.proxyPort;
	}
	
	private String proxyDomain = "";
	private String appLocation = "";
	private String proxyPort = "";
	
	protected ProxyDomainInfo(String prox, String app, String port)
	{
		proxyDomain = prox;
		appLocation = app;
		proxyPort = "";
	}
	
	public static void setupInfo(ServletContext sc, boolean overwrite)
	{
		if(infoSource == null || overwrite)
		{
			reportPath = sc.getRealPath("/WEB-INF/conf");
			reportPath += "/domain.xml";
			reloadInfo();
		}
	}
	
	public static void reloadInfo()
	{
		String tmpProxy = "";
		String tmpApp = "";
		String tmpPort = "";
		File tmp = new File(reportPath);
		DocumentBuilderFactory factory=DocumentBuilderFactory.newInstance();
		try
		{
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document doc=(Document)builder.parse(tmp);
			NodeList nodes=doc.getElementsByTagName("domain");
			Element ele;
			for(int x=0; x<nodes.getLength(); x++)
			{
				ele = (Element) nodes.item(x);
				String id = ele.getAttribute("id");
				if(id.equals("proxy"))
				{
					tmpProxy = ele.getElementsByTagName("address").item(0).getTextContent();
					tmpApp = ele.getElementsByTagName("application").item(0).getTextContent();
					tmpPort = ele.getElementsByTagName("port").item(0).getTextContent();
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		infoSource = new ProxyDomainInfo(tmpProxy, tmpApp, tmpPort);
	}
}
