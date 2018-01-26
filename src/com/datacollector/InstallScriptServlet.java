package com.datacollector;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.HashMap;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;

/**
 * Servlet implementation class InstallScriptServlet
 */
@WebServlet("/installDataCollection.sh")
public class InstallScriptServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public InstallScriptServlet()
    {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		HttpSession session = request.getSession(true);
		
		String curEmail = request.getParameter("username");
		String curEvent = request.getParameter("event");
		
		boolean foundOK = false;
		String myNewToken = "";
		Gson myGson = new Gson();
		try
		{
			myNewToken = UUID.randomUUID().toString();
			String verifierURL = "http://localhost:8080/DataCollectorServer/UserEventStatus?username=" + curEmail + "&event=" + curEvent + "&verifier=for_revenge";
			URL myURL = new URL(verifierURL);
			InputStream in = myURL.openStream();
			String reply = org.apache.commons.io.IOUtils.toString(in);
			org.apache.commons.io.IOUtils.closeQuietly(in);
			System.out.println(reply);
			HashMap replyMap = myGson.fromJson(reply, HashMap.class);
			if(reply.isEmpty() || replyMap.get("result").equals("nokay"))
			{
				return;
			}
			
			
			while(!foundOK)
			{
				myNewToken = UUID.randomUUID().toString();
				verifierURL = "http://localhost:8080/DataCollectorServer/TokenStatus?username=" + curEmail + "&event=" + curEvent + "&token=" + myNewToken + "&verifier=for_revenge";
				myURL = new URL(verifierURL);
				in = myURL.openStream();
				reply = org.apache.commons.io.IOUtils.toString(in);
				org.apache.commons.io.IOUtils.closeQuietly(in);
				System.out.println(reply);
				replyMap = myGson.fromJson(reply, HashMap.class);
				if(replyMap.get("result").equals("nokay"))
				{
					foundOK = true;
				}
			}
			
			String addTokenURL = "http://localhost:8080/DataCollectorServer/AddToken?username=" + curEmail + "&event=" + curEvent + "&token=" + myNewToken + "&mode=continuous&verifier=for_revenge";
			myURL = new URL(addTokenURL);
			in = myURL.openStream();
			reply = org.apache.commons.io.IOUtils.toString(in);
			org.apache.commons.io.IOUtils.closeQuietly(in);
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		
		
		
		String serverName = "revenge.cs.arizona.edu";
		String port = "80";
		
		String output = "#!/bin/bash" 
		+ "\nclear" 
		+ "\n" 
		+ "\necho \"You are about to install the data collection suite from the Catalyst Open Data Collection engine.  Please review the documentation for this software at the location you downloaded it.  Generalized documentation for this software and information about your particular event can also be found at the following locations:\"" 
		+ "\n" 
		+ "\necho \"\"" 
		+ "\n" 
		+ "\necho \"http://localhost:8080/DataCollectorServer/openDataCollection/index.jsp\"" 
		+ "\necho \"http://localhost:8080/DataCollectorServer/openDataCollection/event.jsp?event=" + curEvent + "\"" 
		+ "\n" 
		+ "\necho \"\"" 
		+ "\n" 
		+ "\necho \"When you downloaded this software, you were given and agreed to a consent document.  Do you agree to the appropriate consent document?  Please enter yes or no.  If you enter yes, you agree that you have read and agree to the appropriate consent agreement.  To confirm, do you agree to the appropriate consent terms located at the links above?  Entering yes will install the data collection software suite.\"" 
		+ "\n" 
		+ "\nread CONSENT" 
		+ "\n" 
		+ "\nCONSENT=${CONSENT,,}" 
		+ "\necho $CONSENT" 
		+ "\n" 
		+ "\nif [ \"$CONSENT\" != \"yes\" ]" 
		+ "\nthen" 
		+ "\n\techo \"You did not enter yes.  Exiting now.\"" 
		+ "\n\texit 1" 
		+ "\nfi" 
		+ "\n" 
		+ "\necho \"Starting data collection install\"" 
		+ "\n" 
		+ "\nsudo apt-get update && sudo apt-get -y upgrade" 
		+ "\nsudo apt-get -y install default-jre" 
		+ "\nsudo apt-get -y install tomcat8" 
		//+ "\nsudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password " + mySqlPassword + "'" 
		//+ "\nsudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password " + mySqlPassword + "'" 
		//+ "\nsudo apt-get -y install mysql-server" 
		//+ "\nsudo apt-get -y install mysql-client" 
		+ "\n\nservice mysql start"
		+ "\nmkdir -p /opt/dataCollector/" 
		+ "\n\nwget http://" + serverName + ":" + port + "/DataCollectorServer/endpointSoftware/dataCollection.sql -O /opt/dataCollector/dataCollection.sql"
		+ "\n\nmariadb -u root < /opt/dataCollector/dataCollection.sql"
		+ "\nmariadb -u root -e \"CREATE USER 'dataCollector'@'localhost' IDENTIFIED BY 'LFgVMrQ8rqR41StN';\""
		+ "\nmariadb -u root -e \"GRANT USAGE ON *.* TO 'dataCollector'@'localhost' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;\""
		+ "\nmariadb -u root -e \"GRANT ALL PRIVILEGES ON dataCollection.* TO 'dataCollector'@'localhost';\""
		+ "\n"
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/endpointSoftware/CybercraftDataCollectionConnector.war -O /var/lib/tomcat8/webapps/CybercraftDataCollectionConnector.war"
		+ "\n"
		+ "\n# Copy jar to install dir" 
		+ "\n" 
		+ "\n#mv ./DataCollector.jar /opt/dataCollector/" 
		+ "\nwget http://" + serverName + ":" + port + "/DataCollectorServer/endpointSoftware/DataCollector.jar -O /opt/dataCollector/DataCollector.jar" 
		+ "\nchmod +777 /opt/dataCollector/DataCollector.jar" 
		+ "\nchmod +x /opt/dataCollector/DataCollector.jar" 
		+ "\n" 
		+ "\n" 
		+ "\ntee /opt/dataCollector/DataCollectorStart.sh > /dev/null <<'EOF'" 
		+ "\n#!/bin/bash" 
		+ "\nwhile true;" 
		+ "\ndo" 
		+ "\nservice mysql start" 
		+ "\nservice tomcat8 start"
		+ "\npkill -f \"/usr/bin/java -jar /opt/dataCollector/DataCollector.jar\"" 
		+ "\n/usr/bin/java -Xmx1536m -jar /opt/dataCollector/DataCollector.jar -user " + curEmail + " -server " + serverName + ":" + port + " -event " + curEvent + " -continuous "+ myNewToken + " http://revenge.cs.arizona.edu/DataCollectorServer/UploadData" + " >> /opt/dataCollector/log.log 2>&1" 
		+ "\necho \"Got a crash: $(date)\" >> /opt/dataCollector/log.log" 
		+ "\nsleep 2" 
		+ "\ndone" 
		+ "\nEOF" 
		+ "\n" 
		+ "\nchmod +777 /opt/dataCollector/DataCollectorStart.sh" 
		+ "\nchmod +x /opt/dataCollector/DataCollectorStart.sh" 
		+ "\n" 
		+ "\ntouch /opt/dataCollector/log.log" 
		+ "\nchmod +777 /opt/dataCollector/log.log" 
		+ "\n" 
		+ "\n# Launch script" 
		+ "\n" 
		+ "\nmkdir ~/.config/autostart/"
		+ "\ntee ~/.config/autostart/DataCollector.desktop > /dev/null <<'EOF'" 
		+ "\n[Desktop Entry]" 
		+ "\nType=Application" 
		+ "\nExec=\"/opt/dataCollector/DataCollectorStart.sh\"" 
		+ "\nHidden=false" 
		+ "\nNoDisplay=false" 
		+ "\nX-GNOME-Autostart-enabled=true" 
		+ "\nName[en_IN]=DataCollector" 
		+ "\nName=DataCollector" 
		+ "\nComment[en_IN]=Collects data" 
		+ "\nComment=Collects data" 
		+ "\nEOF" 
		+ "\n" 
		+ "\nservice mysql start" 
		+ "\nservice tomcat8 start"
		+ "\n"
		+ "\n/opt/dataCollector/DataCollectorStart.sh & disown" ;
		response.getWriter().append(output);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

}
