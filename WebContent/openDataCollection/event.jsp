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
<input type="text" name="token" value="Token" onKeyUp="document.getElementById('installScriptLink').href='../installDataCollection.sh?event=<%=event %>&username=' + this.value">
</p>
<p>
Then, follow the following instructions to install the data
collection software:
<ol>
<li>Download and install a virtual machine player for your device.  We recommend
either VMWare or VirtualBox; select an appropriate option for your operating
system.</li>
<li>Download and install a virtual machine.  This software has been tested on
Ubuntu and Kali Linux, but may work on other versions of Linux.  We recommend Kali
Linux for this competition, as it has handy tools for these problems.</li>
<li>On your virtual device, navigate back to this page and make sure your
token is entered in the field above.</li>
<li>Download <a id="installScriptLink" href="../installDataCollection.sh?event=<%=event %>">this script</a>.</li>
<li>Enable execution of the script (how to do this is operating system specific).</li>
<li>Install the data collection software by opening a terminal in the folder with
the script and entering:<br />
sudo ./install_data_collection.sh</li>
<li>Use this virtual machine to participate in the competition---have fun!</li>
</ol>
</p>
<h2>How to Stop Data Collection</h2>
<p>
If you wish to stop your participation at any point, follow the instructions below.
If you would like to have your data collected thus far removed as well, contact
the system admins, listed below.
</p>
<ol>
<li>On your virtual machine, download <a href="stopscript.jsp">this script</a>.</li>
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