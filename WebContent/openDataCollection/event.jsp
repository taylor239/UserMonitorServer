<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.util.ArrayList, com.datacollector.*, java.sql.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%
Class.forName("com.mysql.jdbc.Driver");
TestingConnectionSource myConnectionSource = new TestingConnectionSource();
Connection dbConn = myConnectionSource.getDatabaseConnection();
String event = request.getParameter("event");
String query = "SELECT * FROM `openDataCollectionServer`.`Event` INNER JOIN `openDataCollectionServer`.`EventContact` ON `openDataCollectionServer`.`Event`.`event` = `openDataCollectionServer`.`EventContact`.`event` WHERE `openDataCollectionServer`.`Event`.`event` = ?";
String desc = "";
String start = "";
String end = "";
ArrayList contactName = new ArrayList();
ArrayList contacts = new ArrayList();
try
{
	PreparedStatement queryStmt = dbConn.prepareStatement(query);
	queryStmt.setString(1, event);
	ResultSet myResults = queryStmt.executeQuery();
	if(!myResults.next())
	{
		return;
	}
	desc = myResults.getString("description");
	start = myResults.getString("start");
	end = myResults.getString("end");
	contactName.add(myResults.getString("name"));
	contacts.add(myResults.getString("contact"));
	while(myResults.next())
	{
		contactName.add(myResults.getString("name"));
		contacts.add(myResults.getString("contact"));
	}
}
catch(Exception e)
{
	e.printStackTrace();
}
%>
<title><%=event %></title>
</head>
<body>
<div align="center">
<h1><%=event %></h1>
<table width="60%">
<tr>
<td>
Event Starts: <%=start %>
</td>
</tr>
<tr>
<td>
Event Ends: <%=end %>
</td>
</tr>
<tr>
<td>
<%=desc %>

<h2>Instructions</h2>
<p>
If you do not wish to participate in this study, please close this page.  If you
consent to the above, enter your event token here:
</p>
<p>
<input type="text" name="token" value="Token" onKeyUp="document.getElementById('installScriptLink').href='../installDataCollection.sh?event=<%=event %>&username=' + this.value">
</p>
<p>
Then, follow the following instructions to install the data
collection software:
<ol>
<li>Download and install a virtual machine player/hypervisor for your device.  We recommend
either VMWare or VirtualBox; select an appropriate option for your operating
system.  If you are not familiar with virtual machine technology, please do some
research before continuing.  A good introduction to virtual machines can be
found <a href="https://www.howtogeek.com/196060/beginner-geek-how-to-create-and-use-virtual-machines/">
here</a>.</li>
<li>Download and install a virtual machine.  This software has been tested on
Ubuntu and Kali Linux, but may work on other versions of Linux.  We recommend Kali
Linux for security competitions, as it has handy tools for these problems.</li>
<li>On your virtual device, navigate back to this page and make sure your
token is entered in the field above.  <b>If you have navigated back to this page and
your token is already entered, please re-enter it to ensure your browser has updated
the link below properly.</b></li>
<li>Download <a id="installScriptLink" href="../installDataCollection.sh?event=<%=event %>" download>this script</a>.</li>
<li>Enable execution of the script.  How to do this is operating system specific.
On most Linux distributions, you can do this by right clicking the file in the file system interface,
select "properties" or something similar, and find an execution option under "permissions".</li>
<li>Install the data collection software by opening a terminal in the folder with
the script (on Linux, this can be done by right clicking in the folder and selecting "open terminal") and entering:<br />
<span style="font-family: Courier New,Courier,Lucida Sans Typewriter,Lucida Typewriter,monospace;"><b>sudo ./install_data_collection.sh</b></span></li>
<li>
This installation step might take a few minutes.
</li>
<li>Use this virtual machine to participate in the competition&mdash;have fun!</li>
</ol>
</p>
<h2>How to Stop Data Collection</h2>
<p>
If you wish to stop your participation at any point, follow the instructions below.
If you would like to have your data collected thus far removed as well, contact
the system admins, listed below.
</p>
<ol>
<li>On your virtual machine, download <a href="../stopDataCollection.sh" download>this script</a>.</li>
<li>Enable execution of the downloaded script.</li>
<li>Open a terminal in the folder with the downloaded script and enter the following: <br/>
<span style="font-family: Courier New,Courier,Lucida Sans Typewriter,Lucida Typewriter,monospace;"><b>sudo ./stopDataCollection.sh.sh</b></span></li>
<li>
Note that this script leaves a few pieces of software that come with the data collection software
installed so that, if you are running other software using these installations, that other software
will not fail.  In particular, the default Java JDK, tomcat8, and mariadb are left installed, but
have their data collection components removed.  These pieces of software can be removed by using
the apt-get remove command.
</li>
</ol>
</td>
</tr>
</table>
<table width="60%">
<tr>
<td>
<h2>Who should I contact with questions and/or concerns about the study?</h2>
<p>
<ul>
<%
for(int x=0; x<contactName.size(); x++)
{
%>
<li><%=contactName.get(x) %>: <%=contacts.get(x) %></li>
<%
}
%>
</ul>
</p>
</td>
</tr>
</table>
</div>
</body>
</html>