<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.ArrayList, java.util.HashMap, com.datacollector.*, java.sql.*"%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" type="text/css" href="Design.css">
<script src="./sha_func.js"></script>
<script src="./clonedeep.js"></script>
<script src="./pathFunctions.js"></script>
<script src="./d3.v4.min.js"></script>
<script src="./d3-scale-chromatic.v0.3.min.js"></script>
<script src="./pageFunctions.js"></script>
<meta charset="UTF-8">
<title>Data Collection Visualization</title>
</head>
<%
Class.forName("com.mysql.jdbc.Driver");
DatabaseConnector myConnector=(DatabaseConnector)session.getAttribute("connector");
if(myConnector==null)
{
	myConnector=new DatabaseConnector(getServletContext());
	session.setAttribute("connector", myConnector);
}
TestingConnectionSource myConnectionSource = myConnector.getConnectionSource();

String eventName = request.getParameter("event");

String eventPassword = request.getParameter("eventPassword");

if(eventPassword != null)
{
	session.setAttribute("eventPassword", eventPassword);
}

String eventAdmin = request.getParameter("eventAdmin");

if(eventAdmin != null)
{
	session.setAttribute("eventAdmin", eventAdmin);
}

if(request.getParameter("email") != null)
{
	session.removeAttribute("admin");
	session.removeAttribute("adminName");
	String adminEmail = request.getParameter("email");
	if(request.getParameter("password") != null)
	{
		String password = request.getParameter("password");
		
		String loginQuery = "SELECT * FROM `openDataCollectionServer`.`Admin` WHERE `adminEmail` = ? AND `adminPassword` = ?";
		
		Connection dbConn = myConnectionSource.getDatabaseConnection();
		try
		{
			PreparedStatement queryStmt = dbConn.prepareStatement(loginQuery);
			queryStmt.setString(1, adminEmail);
			queryStmt.setString(2, password);
			ResultSet myResults = queryStmt.executeQuery();
			if(myResults.next())
			{
				session.setAttribute("admin", myResults.getString("adminEmail"));
				session.setAttribute("adminName", myResults.getString("name"));
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}
}

%>
<body>
<table width="100%" style="border:0">
	<tr>
		<td class="layoutTableSide" style="border:0">
		<div align="left">
			<span id="leftHide" style="cursor: pointer" onclick="toggleLeft();">⊟</span>
		</div>
		</td>
		<td class="layoutTableCenter" style="border:0">
		
		</td>
		<td class="layoutTableSide" style="border:0">
		<div align="right">
			Lost? <button type="button" onclick="tutorial()">Info</button><button type="button" onclick="back()">Back</button>
		</div>
		</td>
	</tr>
</table>
<table id="bodyTable">
	<tr>
		<td id="optionFilterCell" class="layoutTableSide leftCol" style="height:100%">
			<table id="optionFilterTable" width="100%" height="100%" style="display:block; overflow-y:scroll">
					<tr>
						<td colspan="5">
								<div align="center">
									Options
								</div>
						</td>
					</tr>
					<tr>
						<td colspan="5">
									Playback Speed
						</td>
					</tr>
					<tr>
						<td colspan="5">
									<input type="text" size="4" id="playbackSpeed" name="playbackSpeed" value="10">x
						</td>
					</tr>
					
					<tr>
						<td colspan="5">
									Timeline Zoom
						</td>
					</tr>
					<tr>
						<td colspan="5">
									<span width="50%"><input type="text" size="4" id="timelineZoom" name="timelineZoom" value="1">x horizontal</span>
									<span width="50%"><input type="text" size="4" id="timelineZoomVert" name="timelineZoomVert" value="1">x vertical</span>
						</td>
					</tr>
					<tr>
						<td colspan="5">
									<div align="center"><button type="button" onclick="start(true)">Apply</button></div>
						</td>
					</tr>
					<tr>
						<td colspan="5">
									<input type="checkbox" id="processAutoSelect" name="processAutoSelect">Process Tooltip Details
						</td>
					</tr>
					<tr id="taskTitle1">
						<td colspan="5">
							<div align="center">
									Task Analysis
							</div>
						</td>
					</tr>
					<tr id="taskTitle1">
						<td colspan="5">
							<div align="center">
									<button type="button" onclick="viewPetriNets()">Petri Net View</button>
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="5">
							<div align="center">
									Petri Nets to Visualize<br />
									<select style="width: 100%;" name="petriNets" id="petriNets" multiple>
									</select>
							</div>
						</td>
					</tr>
					<tr id="filterTitle1">
						<td colspan="5">
							<div align="center">
									Filters
							</div>
						</td>
					</tr>
					<tr>
						<td colspan="2">
						<div align="center">
						<button type="button" onclick="saveFilters()">Save</button>
						</div>
						</td>
						<td colspan="3">
						<div align="center">
						<input type="text" size="15" id="saveFilter" name="saveFilter" value="Name">
						</div>
						</td>
					</tr>
					<tr>
						<td colspan="5">
						<div align="center">
						<button type="button" onclick="loadFilter(true)">Load</button>
						<button type="button" onclick="loadFilter(false)">Append</button>
						<button type="button" onclick="deleteFilter()">Delete</button>
						</div>
						</td>
					</tr>
					<tr>
						<td colspan="5">
						<div align="center">
						<select name="savedFilters" id="savedFilters">
							<option value="default">Default</option>
						</select>
						</div>
						</td>
					</tr>
					<tr id="filterTitle2">
						<td width="20%">
						Level
						</td>
						<td width="20%">
						Field
						</td>
						<td width="40%">
						Value
						</td>
						<td width="20%">
						Server
						</td>
						<td>
						
						</td>
					</tr>
					<tr id = "filter_add">
						<td id = "filter_add_level">
						<input type="text" size="2" id="filter_add_level_field" name="filter_add_level_field" value="3">
						</td>
						<td id = "filter_add_field">
						<input type="text" size="6" id="filter_add_field_field" name="filter_add_field_field" value="FirstClass">
						</td>
						<td id = "filter_add_value">
						<input type="text" size="11" id="filter_add_value_field" name="filter_add_value_field" value="!= 'com-datacollectorloc'">
						</td>
						<td>
						
						</td>
						<td id = "filter_add_add" class="clickableHover" onclick="addFilter()">
						<div align="center">
						+
						</div>
						</td>
					</tr>

			</table>
		</td>
		<td class="layoutTableCenter centerCol" id="mainVisContainer">
			<table style="overflow-x:auto" id="visTable">
			<tr><td>
			<div align="center" id="title">User Timelines for <%=eventName %></div>
			</td></tr>
			<tr><td id="visRow">
			<div align="center" id="mainVisualization">
			</div>
			</td></tr>
			</table>
		</td>
		<td id="legendTable" class="layoutTableSide rightCol">
			<table width="100%" height="100%">
					<tr id="legendTitle">
						<td>
							<div align="center">Legend</div>
						</td>
					</tr>
					<tr>
						<td style="height:100%" id="legendCell">
							<div style="overflow-y: scroll; max-height: 100%" align="left" id="legend">
							
							</div>
						</td>
					</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="layoutTableSide leftCol">
			<table id="screenshotTable" width="100%" class="dataTable">
				<tr>
					<td colspan=1>
					<div align="center">Screenshot</div>
					</td>
				</tr>
				<tr>
					<td colspan=1>
							<div align="center" id="screenshotDiv">
							
							</div>
					</td>
				</tr>
			</table>
		</td>
		<td class="layoutTableCenter centerCol", id="graphCell">
			<table id="graphTable" width="100%" class="dataTable">
				<tr>
					<td>
					<div align="center">Details</div>
					</td>
				</tr>
			</table>
			<table id="infoTable" width="100%" class="dataTable">
				
			</table>
			<table id="extraInfoTable" width="100%" class="dataTable">
				
			</table>
		</td>
			</div>	
		</td>
		<td class="layoutTableSide rightCol">
			<table id="highlightTable" width="100%" class="dataTable" style="overflow-y: scroll">
				<tr>
					<td colspan=1>
					<div align="center">Highlights</div>
					</td>
				</tr>
				<tr height="100%">
					<td colspan=1>
							<div align="center" id="highlightDiv">
							
							</div>
					</td>
				</tr>
				<tr>
					<td colspan=1>
							<div align="center" id="extraHighlightDiv">
							
							</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>

<script>
	var showLeft = true;
	function toggleLeft()
	{
		showLeft = !(showLeft);
		toDisplay = "none";
		if(showLeft)
		{
			document.getElementById("leftHide").innerHTML = "⊟";
			toDisplay = "";
			d3.selectAll(".leftCol").style("display", toDisplay);
			visWidthParent -= d3.select(".leftCol").node().offsetWidth;
		}
		else
		{
			
			document.getElementById("leftHide").innerHTML = "⊞";
			visWidthParent += d3.select(".leftCol").node().offsetWidth;
			d3.selectAll(".leftCol").style("display", toDisplay);
		}
		start(true);
	}
	
	var filters = [];
	var filtersTitle = [];
	var startFilters = 0;
	
	var firstFilter = {}
	firstFilter["Level"] = 1;
	firstFilter["Field"] = "";
	firstFilter["Value"] = "== 'Aggregated'";
	//firstFilter["id"] = "filter_0"
	filters.push(firstFilter);

	

	var containingTableRow = document.getElementById("mainVisContainer");
	var visTable = document.getElementById("visTable");
	var visRow = document.getElementById("visRow");
	
	var windowWidth = window.innerWidth;
	var windowHeight = window.innerHeight;
	
	console.log(windowHeight + ", " + windowWidth);
	
	var visPadding = 20;
	
	var visWidth = containingTableRow.offsetWidth - visPadding;
	var visWidthParent = containingTableRow.offsetWidth - visPadding;
	var visHeight = windowHeight * .5;
	var bottomVisHeight = windowHeight * .25;
	var sidePadding = 24;
	
	var barHeight = visHeight / 10;
	var xAxisPadding = 3 * barHeight;
	//var xAxisPadding = .2 * visWidth;
	
	var eventName = "<%=eventName %>";
	var adminName = "<%=request.getParameter("email") %>";
	var eventAdmin = "<%=eventAdmin %>";
	
	var svg;
	var userOrdering;
	
	var keySlots = 200;
	var keyMap;
	
	var overlayText = true;
	
	var lookupTable;
	
	var processMap;
	
	var curStroke;
	var sessionStroke;
	var curHighlight = [];
	
	var curPlayButton;
	var curPlayLabel;
	
	var tickWidth = 4;
	
	var userSessionAxisY = {};
	
	var legendWidth = 25;
	var legendHeight = visHeight / 25;
	
	var timeMode = "Session";
	
	var highlightMap = {};
	highlightMap["TaskName"] = true;
	highlightMap["FirstClass"] = true;
	
	function deleteFilter()
	{
		var toDelete = document.getElementById("savedFilters").value;
		var urlToPost = "deleteFilter.json?event=" + eventName + "&deleteName=" + toDelete;
		d3.json(urlToPost, function(error, data)
				{
					if(data["result"] == "okay")
					{
						savedFilters = document.getElementById("savedFilters");
						savedFilters.remove(savedFilters.selectedIndex);
					}
					else
					{
						showLightbox("<tr><td><div width=\"100%\">Error deleting filter set.</div></td></tr>");
					}
				});
	}
	
	function loadFilter(removeOld)
	{
		if(removeOld)
		{
			filters = [];
		}
		var toLoad = document.getElementById("savedFilters").value;
		var filtersToLoad = savedFilters[toLoad];
		for(toAdd in filtersToLoad)
		{
			var filterToAdd = {}
			filterToAdd["Level"] = filtersToLoad[toAdd]["Level"];
			filterToAdd["Field"] = filtersToLoad[toAdd]["Field"];
			filterToAdd["Value"] = filtersToLoad[toAdd]["Value"];
			//firstFilter["id"] = "filter_0"
			filters.push(filterToAdd);
		}
		rebuildFilters();
		start(true);
	}
	
	function saveFilters()
	{
		
		var saveAs = document.getElementById("saveFilter").value;
		var urlToPost = "addFilters.json?event=" + eventName + "&saveName=" + saveAs;
		var x=0;
		for(entry in filters)
		{
			urlToPost += "&filterLevel" + x + "=" + filters[entry]["Level"];
			urlToPost += "&filterValue" + x + "=" + filters[entry]["Value"];
			urlToPost += "&filterField" + x + "=" + filters[entry]["Field"];
			x++;
		}
		d3.json(urlToPost, function(error, data)
				{
					if(data["result"] == "okay")
					{
						newOption = new Option(saveAs, saveAs);
						document.getElementById("savedFilters").add(newOption,undefined);
					}
					else
					{
						showLightbox("<tr><td><div width=\"100%\">Error saving filter set.</div></td></tr>");
					}
				});
	}
	
	function rebuildFilters()
	{
		var tableData = filtersTitle.concat(filters);
		d3.select("#optionFilterTable")
			.selectAll("tr")
			//.data(tableData)
			//.exit()
			.remove();
		d3.select("#optionFilterTable")
			.selectAll("tr")
			.data(tableData)
			.enter()
			.append("tr")
			.style("height", function(d, i)
					{
						//return "100%";
						if(i <= startFilters)
						{
							return legendHeight + "px";
						}
						return 3 * legendHeight + "px";
					})
			.html(function(d, i)
					{
						if(i <= startFilters)
						{
							return d.innerHTML;
						}
						d["id"] = "filter_" + (i - startFilters)
						return "<td id = \"filter_" + (i - startFilters) + "_level\">"
						+d["Level"]
						+"</td>"
						+"<td id = \"filter_" + (i - startFilters) + "_field\">"
						+d["Field"]
						+"</td>"
						+"<td style=\"overflow-x:auto; overflow-y:auto; word-break:break-all; height:100%;\" id = \"filter_" + (i - startFilters) + "_value\">"
						+d["Value"]
						+"</td>"
						+"<td class=\"clickableHover\" id = \"filter_" + (i - startFilters) + "_remove\">"
						+"<div align=\"center\">"
						+"<input type=\"checkbox\" id=\"filter_server_" + (i - startFilters) + "\" name=\"filter_server_" + (i - startFilters) + "\" value=\"filter_server_" + (i - startFilters) + "\">"
						+"</div>"
						+"</td>"
						+"<td class=\"clickableHover\" id = \"filter_" + (i - startFilters) + "_remove\">"
						+"<div align=\"center\" onclick=\"removeFilter(" + (i - startFilters) + ")\">"
						+"X"
						+"</div>"
						+"</td>";
					});
		
		rebuildPetriMenu();
	}
	
	//rebuildFilters();

	function removeFilter(filterNum)
	{
		
		filters.splice(filterNum - 1, 1);
		rebuildFilters();
		start(true);
	}
	function addFilter()
	{
		levelVal = document.getElementById("filter_add_level_field").value;
		fieldVal = document.getElementById("filter_add_field_field").value;
		valueVal = document.getElementById("filter_add_value_field").value;
		var newFilter = {}
		newFilter["Level"] = Number(levelVal);
		newFilter["Field"] = fieldVal;
		newFilter["Value"] = valueVal;
		filters.push(newFilter);
		
		rebuildFilters();
		start(true);
	}
	
	function addFilterDirect(levelVal, fieldVal, valueVal)
	{
		//levelVal = document.getElementById("filter_add_level_field").value;
		//fieldVal = document.getElementById("filter_add_field_field").value;
		//valueVal = document.getElementById("filter_add_value_field").value;
		var newFilter = {}
		newFilter["Level"] = Number(levelVal);
		newFilter["Field"] = fieldVal;
		newFilter["Value"] = valueVal;
		filters.push(newFilter);
		
		rebuildFilters();
		start(true);
	}
	
	async function getProcessData()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_processes");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}
	
	async function getProcessDataFiltered()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_processes_filtered");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}
	
	async function storeProcessDataFiltered(toStore)
	{
		if(this.session == "Aggregated")
		{
			
		}
		else
		{
			var isDone = false;
			while(!isDone)
			{
				var hashVal = SHA256(this.user + this.session + "_processes_filtered");
				isDone = await persistData(hashVal, toStore);
			}
		}
	}
	
	async function getMouseData()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_mouse");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}
	
	async function getMouseDataFiltered()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_mouse_filtered");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}
	
	async function storeMouseDataFiltered(toStore)
	{
		if(this.session == "Aggregated")
		{
			
		}
		else
		{
			var isDone = false;
			while(!isDone)
			{
				var hashVal = SHA256(this.user + this.session + "_mouse_filtered");
				isDone = await persistData(hashVal, toStore);
			}
		}
	}
	
	async function getKeystrokesData()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_keystrokes");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}
	
	async function getKeystrokesDataFiltered()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_keystrokes_filtered");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}
	
	async function storeKeystrokesDataFiltered(toStore)
	{
		if(this.session == "Aggregated")
		{
			
		}
		else
		{
			var isDone = false;
			while(!isDone)
			{
				var hashVal = SHA256(this.user + this.session + "_keystrokes_filtered");
				isDone = await persistData(hashVal, toStore);
			}
		}
	}

	
	var startedDownload = {};
	
	async function downloadUser(user)
	{
		let theNormDataInit = ((await retrieveData("indexdata")).value);
		console.log(theNormDataInit);
		console.log(user);
		for(session in theNormDataInit[user])
		{
			if(Object.keys(theNormDataInit[user][session]).length < 3)
			{
				delete theNormDataInit[user][session];
				continue;
			}
			
			var hashValDownload = SHA256(user + session + "_download");
			if(!startedDownload[hashValDownload])
			{
				console.log("Starting first download " + user + ":" + session);
				startedDownload[hashValDownload] = true;
				downloadImages(user, session, theNormDataInit[user][session]["screenshots"], 0);
				downloadProcesses(user, session, 0);
				downloadMouse(user, session, 0);
				downloadKeystrokes(user, session, 0);
			}
		}
	}
	
	function preprocess(dataToModify)
	{
		totalSessions = 0;
		for(user in dataToModify)
		{
			aggregateSession = {}
			listsToAdd = {}
			newSession = {}
			for(session in dataToModify[user])
			{
				if(Object.keys(dataToModify[user][session]).length < 3)
				{
					delete dataToModify[user][session];
					continue;
				}
				
				totalSessions++;
				
				for(entry in dataToModify[user][session]["screenshots"])
				{
					var hashVal = SHA256(user + session + dataToModify[user][session]["screenshots"][entry]["Index MS"]);
					dataToModify[user][session]["screenshots"][entry]["ImageHash"] = hashVal;
				}
				
				var hashValDownload = SHA256(user + session + "_download");
				if(!startedDownload[hashValDownload])
				{
					colorButtons(user, session);
				}
				else
				{
					console.log("Already downloaded " + user + ":" + session);
				}
				
				if(dataToModify[user][session]["windows"])
				{
					var activeWindows = [];
					for(curWindow in dataToModify[user][session]["windows"])
					{
						
						if(dataToModify[user][session]["windows"][curWindow]["Active"] == "1")
						{
							activeWindows.push(dataToModify[user][session]["windows"][curWindow]);
						}
					}
					dataToModify[user][session]["allWindows"] = dataToModify[user][session]["windows"];
					dataToModify[user][session]["windows"] = activeWindows;
				}
				
				for(data in dataToModify[user][session])
				{
					if(!(data in listsToAdd))
					{
						listsToAdd[data] = [];
					}
					listsToAdd[data].push(dataToModify[user][session][data]);
					for(entry in dataToModify[user][session][data])
					{
						dataToModify[user][session][data][entry]["Original Session"] = session;
					}
				}
			}
			listsToAdd = JSON.parse(JSON.stringify(listsToAdd));
			for(data in listsToAdd)
			{
				newDataList = [];
				if(listsToAdd[data] == null)
				{
					listsToAdd[data] = [];
				}
				listsToAdd[data] = listsToAdd[data].sort(function(a, b)
							{
								return a[0]["Index MS User"] - b[0]["Index MS User"];
							});
				for(curList in listsToAdd[data])
				{
					newDataList = newDataList.concat(listsToAdd[data][curList]);
				}
				newDataList = newDataList.sort(function(a, b)
						{
							return a["Index MS User"] - b["Index MS User"];
						});
				for(element in newDataList)
				{
					newDataList[element]["Index MS Session"] = newDataList[element]["Index MS User"];
				}
				newSession[data] = newDataList;
			}
			dataToModify[user]["Aggregated"] = newSession;
		}
		
		return dataToModify;
	}
	
	var summaryProcStats = {};
	var summaryProcStatsArray = [];
	var measureBy = "session";
	async function filter(dataToFilter, filters)
	{

		summaryProcStats = {};
		summaryProcStatsArray = [];
		var filterMap = {};
		for(entry in filters)
		{
			if(!(filters[entry]["Level"] in filterMap))
			{
				filterMap[filters[entry]["Level"]] = [];
			}
			filterMap[filters[entry]["Level"]].push(filters[entry]);
		}
		
		console.log(filterMap);
		
		for(user in dataToFilter)
		{
			var userProcFound = {};
			
			toFilter = filterMap[0];
			if(toFilter)
			{
				for(curFilter in toFilter)
				{
					if(!(eval(("'" + user + "'" + toFilter[curFilter]["Value"]))))
					{
						delete dataToFilter[user];
					}
				}
			}
			for(session in dataToFilter[user])
			{
				
				if(measureBy = "session")
				{
					var userProcFound = {};
				}
				toFilter = filterMap[1];
				if(toFilter)
				{
					for(curFilter in toFilter)
					{
						if(!(eval("'" + session + "'" + toFilter[curFilter]["Value"])))
						{
							delete dataToFilter[user][session];
						}
					}
				}

				
				for(data in dataToFilter[user][session])
				{
					var isAsync = false;
					var dataSource = dataToFilter[user][session][data];
					if(!dataSource)
					{
						console.log("No data source for " + user + ":" + session + ":" + data)
						continue;
					}
					if(dataToFilter[user][session][data]["data"] && (typeof dataToFilter[user][session][data]["data"]) == "function")
					{
						dataSource = (await dataToFilter[user][session][data]["data"]());
						if(!dataSource)
						{
							console.log("No data source for " + user + ":" + session + ":" + data)
							continue;
						}
						dataSource = dataSource.value;
						if(!dataSource)
						{
							console.log("No data source for " + user + ":" + session + ":" + data)
							continue;
						}
						isAsync = true;
					}
					toFilter = filterMap[2];
					if(toFilter)
					{
						for(curFilter in toFilter)
						{
							if(!(eval("'" + data + "'" + toFilter[curFilter]["Value"])))
							{
								dataSource = [];
							}
						}
					}
					toSplice = [];
					entry = 0;
					if(!dataSource)
					{
						console.log("No data source for " + user + ":" + session + ":" + data)
						continue;
					}
					curLength = dataSource.length;
					while(entry < curLength)
					//for(entry in dataToFilter[user][session][data])
					{
						toFilter = filterMap[3];
						var filteredOut = false;
						if(toFilter)
						{
							for(curFilter in toFilter)
							{
								if(toFilter[curFilter]["Field"] in dataSource[entry])
								{
									if(!(eval("'" + dataSource[entry][toFilter[curFilter]["Field"]] + "'" + toFilter[curFilter]["Value"])))
									{
										dataSource.splice(entry, 1);
										entry--;
										curLength = dataSource.length;
										//toSplice.push(entry);
										filteredOut = true;
										break;
									}
								}
							}
						}
						if(!filteredOut)
						{
							if(data == "processes")
							{
								if(!(dataSource[entry]["Command"] in userProcFound))
								{
									if(dataSource[entry]["Command"] in summaryProcStats)
									{
										summaryProcStats[dataSource[entry]["Command"]]["count"]++;
									}
									else
									{
										procStatMap = {};
										procStatMap["Command"] = dataSource[entry]["Command"];
										procStatMap["count"] = 1;
										summaryProcStats[dataSource[entry]["Command"]] = procStatMap;
									}
									userProcFound[dataSource[entry]["Command"]] = 0
								}
							}
						}
						entry++;
					}
					
					if(isAsync)
					{
						dataSource = await dataToFilter[user][session][data]["storefiltered"](dataSource);
					}
				}
			}
			}
			
		var minProc = Number.POSITIVE_INFINITY;
		var maxProc = 0;
		summaryProcStatsArray = Object.values(summaryProcStats).sort(function(a, b)
				{
					if(a["count"] > maxProc)
					{
						maxProc = a["count"];
					}
					if(a["count"] < minProc)
					{
						minProc = a["count"];
					}
					if(b["count"] > maxProc)
					{
						maxProc = b["count"];
					}
					if(b["count"] < minProc)
					{
						minProc = b["count"];
					}
					return b["count"] - a["count"];
				});
		summaryProcStats["Max"] = maxProc;
		summaryProcStats["Min"] = minProc;
		return dataToFilter;
	}
	
	var theNormData;
	var theNormDataClone;
	var theNormDataDone = false;
	var origTitle = d3.select("#title").text();
	
	var savedFilters = {};
	d3.json("Filters.json?event=" + eventName, function(error, data)
			{
				saveNames = [];
				
				for(entry in data)
				{
					curEntry = {};
					if(!(data[entry]["SaveName"] in savedFilters))
					{
						savedFilters[data[entry]["SaveName"]] = [];
						saveNames.push(data[entry]["SaveName"]);
					}
					curEntry["Level"] = data[entry]["Level"];
					curEntry["Field"] = data[entry]["Field"];
					curEntry["Value"] = data[entry]["Value"];
					curEntry["Server"] = data[entry]["Server"];
					savedFilters[data[entry]["SaveName"]].push(curEntry);
				}

				d3.select("#savedFilters")
					.selectAll("option")
					.remove();
				d3.select("#savedFilters")
					.selectAll("option")
					.data(saveNames)
					.enter()
					.append("option")
					.attr("value", function(d, i)
							{
								console.log(d);
								return d;
							})
					.html(function(d, i)
							{
								return d;
							});
					
				d3.select("#optionFilterTable")
				.selectAll("tr")
				.each(function(d, i)
						{
							filtersTitle.push(this);
							startFilters = i;
						});
				rebuildFilters();
				downloadData();
			})

	var db;
	var objectStore;
	
	var curQueue = [];
	
	var persistWriting = false;

	
	async function persistData(key, value)
	{
		var args = {};
		args["key"] = key;
		args["value"] = value;
		curQueue.push(args);
		if(!persistWriting)
		{
			writePersist();
		}
		return new Promise(async function (resolve, reject)
		{
			resolve(true);
		})
	}
	
	async function writePersist()
	{
		var myReturn = false;
		persistWriting = true;
		console.log("Starting write worker");
		curWrite = curQueue.pop();
		while(curWrite)
		{
			d3.select("body").style("cursor", "wait");
			myReturn = await wrappedPersistData(curWrite["key"], curWrite["value"]);
			curWrite = curQueue.pop();
		}
		persistWriting = false;
		d3.select("body").style("cursor", "");
		return(myReturn);
	}
	
	function sleep(ms)
	{
		return new Promise(resolve => setTimeout(resolve, ms));
	}
	
	async function persistDataAndWait(key, value)
	{
		var args = {};
		args["key"] = key;
		args["value"] = value;
		curQueue.push(args);
		var myReturn = await writePersist();

		//if(curQueue.length > 0)
		//{
		//	console.log("Waiting on write...")
		//	console.log(curQueue.length);
		//	console.log(curQueue[0]);
		//	await sleep(150000);
		//}
		return new Promise(async function (resolve, reject)
		{
			resolve(myReturn);
		})
	}
	
	Function.prototype.clone = function() {
	var that = this;
	var temp = function temporary() { return that.apply(this, arguments); };
	for(var key in this) {
		if (this.hasOwnProperty(key)) {
			temp[key] = this[key];
		}
	}
	return temp;
	};
	
	var blockingPersist = false;
	//async function persistData(key, value)
	//{
	//	return await toClonePersistData.clone()(key, value);
	//}
	
	async function wrappedPersistData(key, value)
	{
		// In the following line, you should include the prefixes of implementations you want to test.
		window.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
		// DON'T use "var indexedDB = ..." if you're not in a function.
		// Moreover, you may need references to some window.IDB* objects:
		window.IDBTransaction = window.IDBTransaction || window.webkitIDBTransaction || window.msIDBTransaction || {READ_WRITE: "readwrite"}; // This line should only be needed if it is needed to support the object's constants for older browsers
		window.IDBKeyRange = window.IDBKeyRange || window.webkitIDBKeyRange || window.msIDBKeyRange;
		
		return new Promise(async function (resolve, reject)
		{
			if(!db)
			{
				var request = window.indexedDB.open("LocalStore", 4);
				request.onerror = function(event)
				{
					// Do something with request.errorCode!
					console.log(request.errorCode);
					return;
				};
				request.onupgradeneeded = function(event)
				{
					db = event.target.result;
					if (!db.objectStoreNames.contains("objects"))
					{
						objectStore = db.createObjectStore("objects", { keyPath: "key" });
					}
				};
				request.onsuccess = async function(event)
				{
					db = event.target.result;
					try
					{
						var theReturn = await (nestedStoreData(key, value));
						resolve(theReturn);
					}
					catch(err)
					{
						console.log(err);
						reject(err);
					}
				}
			}
			else
			{
				try
				{
					var theReturn = await (nestedStoreData(key, value));
					resolve(theReturn);
				}
				catch(err)
				{
					reject(err);
				}
			}
		})
	}
	async function nestedStoreData(key, value)
	{
		return new Promise(function (resolve, reject)
		{
			var transaction = db.transaction(["objects"], "readwrite");
			transaction.oncomplete = function(event)
			{
				resolve(true);
			};
	
			transaction.onerror = function(event)
			{
				reject(event);
			};
			objectStore = transaction.objectStore("objects");
			
			var toPersist = {};
			toPersist["key"] = key;
			toPersist["value"] = value;
			var request = objectStore.put(toPersist);
		})
	}
	
	async function retrieveData(key)
	{
		d3.select("body").style("cursor", "wait");
		var toReturn = await retrieveDataWrapper(key);
		d3.select("body").style("cursor", "");
		return toReturn;
	}
	
	async function hasData(key)
	{
		d3.select("body").style("cursor", "wait");
		var toReturn = await nestedCountData(key);
		d3.select("body").style("cursor", "");
		if(toReturn > 0)
		{
			return true;
		}
		return false;
	}
	
	async function retrieveDataWrapper(key)
	{
		try
		{
			var value = await nestedRetrieveData(key);
			
			return await value;
		}
		catch (err)
		{
			console.log(err);
		}
	}
	
	async function nestedRetrieveData(key)
	{
		// In the following line, you should include the prefixes of implementations you want to test.
		window.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
		// DON'T use "var indexedDB = ..." if you're not in a function.
		// Moreover, you may need references to some window.IDB* objects:
		window.IDBTransaction = window.IDBTransaction || window.webkitIDBTransaction || window.msIDBTransaction || {READ_WRITE: "readwrite"}; // This line should only be needed if it is needed to support the object's constants for older browsers
		window.IDBKeyRange = window.IDBKeyRange || window.webkitIDBKeyRange || window.msIDBKeyRange;
		
		if(!db)
		{
			
		}
		else
		{
			return new Promise(function (resolve, reject)
			{
				var transaction = db.transaction(["objects"]);
				var objectStore = transaction.objectStore("objects");
				var request = objectStore.get(key);
				request.onerror = function(event)
				{
					reject(event);
				};
				request.onsuccess = function(event)
				{
					resolve(event.target.result);
				};
			})
			
		}

	}
	
	async function nestedCountData(key)
	{
		// In the following line, you should include the prefixes of implementations you want to test.
		window.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
		// DON'T use "var indexedDB = ..." if you're not in a function.
		// Moreover, you may need references to some window.IDB* objects:
		window.IDBTransaction = window.IDBTransaction || window.webkitIDBTransaction || window.msIDBTransaction || {READ_WRITE: "readwrite"}; // This line should only be needed if it is needed to support the object's constants for older browsers
		window.IDBKeyRange = window.IDBKeyRange || window.webkitIDBKeyRange || window.msIDBKeyRange;
		
		if(!db)
		{
			
		}
		else
		{
			return new Promise(function (resolve, reject)
			{
				var transaction = db.transaction(["objects"]);
				var objectStore = transaction.objectStore("objects");
				var request = objectStore.count(key);
				request.onerror = function(event)
				{
					reject(event);
				};
				request.onsuccess = function(event)
				{
					resolve(event.target.result);
				};
			})
			
		}

	}
	
	async function getScreenshotData()
	{
		var hashVal = this["ImageHash"];
		var toReturn = (await retrieveData(hashVal));
		return toReturn.value;
	}
	
	async function hasScreenshot(entry)
	{
		var hashVal = entry["ImageHash"];
		var toReturn = (await hasData(hashVal));
		return toReturn;
	}
	
	var downloadedImageSize = 0;
	var downloadedProcessSize = 0;
	var downloadedMouseSize = 0;
	var downloadedKeystrokesSize = 0;
	var downloadedSize = 0;
	
	var updating = false;
	
	async function refreshData()
	{
		console.log("Refreshing data");
		if(updating)
		{
			console.log("Refresh already underway");
			return;
		}
		updating = true;
		start(true);
		
		updating = false;
	}
	
	var usersToQuery = [];
	var sessionsToQuery = [];
	var autoDownload = false;
	
	function processParameters()
	{
		var theUrl = window.location.href;
		var url = new URL(theUrl);
		var usersString = url.searchParams.get("users");
		if(usersString)
		{
			usersToQuery = usersString.split(",");
		}
		var sessionsString = url.searchParams.get("sessions");
		if(sessionsString)
		{
			sessionsToQuery = sessionsString.split(",");
		}
		autoDownload = (url.searchParams.get("autodownload") == "true");
	}
	
	var searchTerms = [];
	
	async function downloadData()
	{
		var needsUpdate = false;
		d3.select("body").style("cursor", "wait");
		lastEvent = (await retrieveData("event").value)
		//if(eventName != lastEvent)
		if(true)
		{
			persistData("event", eventName);
			persistData("time", new Date());
			needsUpdate = true;
		}
		lastTime = (await retrieveData("time"));
		//origTitle += ", last visit on " + lastTime;
		
		d3.select("#title")
			.html(origTitle);

		if(needsUpdate)
		{
			d3.select("#title")
				.html(origTitle + "<br />Starting download...");
			d3.json("getTags.json?event=" + eventName, async function(error, data)
			{
				searchTerms = data;
			});
			
			processParameters();
			var userSessionFilter = "";
			
			if(usersToQuery && usersToQuery.length > 0)
			{
				var first = true;
				userSessionFilter += "&users=";
				for(userEntry in usersToQuery)
				{
					if(!first)
					{
						userSessionFilter += ",";
					}
					userSessionFilter += usersToQuery[userEntry];
					first = false;
				}
			}
			
			if(sessionsToQuery && sessionsToQuery.length > 0)
			{
				var first = true;
				userSessionFilter += "&sessions=";
				for(sessionEntry in sessionsToQuery)
				{
					if(!first)
					{
						userSessionFilter += ",";
					}
					userSessionFilter += sessionsToQuery[sessionEntry];
					first = false;
				}
			}

			d3.json("logExport.json?event=" + eventName + "&datasources=windows,events,environment,screenshotindices&normalize=none" + userSessionFilter, async function(error, data)
				{
					try
					{
						var isDone = false;
						while(!isDone)
						{
							isDone = await persistDataAndWait("indexdata", data);
						}
					}
					catch(err)
					{
						console.log(err);
					}
					theNormData = preprocess(data);
					try
					{
						var isDone = false;
						while(!isDone)
						{
							isDone = await persistDataAndWait("data", theNormData);
						}
					}
					catch(err)
					{
						console.log(err);
					}
					
					theNormDataDone = true;
					
					d3.select("#title")
						.html(origTitle + "<br />Index data: <b>" + downloadedSize + "</b> bytes; new image data: <b>" + downloadedImageSize + "</b> bytes; new process data: <b>" + downloadedProcessSize + "</b> bytes; finished " + downloadedSessions + " of " + totalSessions + " sessions.")

					d3.select("body").style("cursor", "");
					start(true);
				})
				.on("progress", function(d, i)
						{
							downloadedSize = d["loaded"];
							d3.select("#title")
									.html(origTitle + "<br />Data Size: <b>" + d["loaded"] + "</b> bytes")
						});
		}
		else
		{
			theNormDataDone = true;
			d3.select("body").style("cursor", "");
			start(true);
		}
	}
	
	var sessionDownloadCount = {};
	var numAsync = 4;
	
	function addDownloadCount(userName, sessionName)
	{
		if(!(userName in sessionDownloadCount))
		{
			sessionDownloadCount[userName] = {};
		}
		if(!(sessionName in sessionDownloadCount[userName]))
		{
			sessionDownloadCount[userName][sessionName] = 0;
		}
		sessionDownloadCount[userName][sessionName] = sessionDownloadCount[userName][sessionName] + 1;
		return sessionDownloadCount[userName][sessionName];
	}
	
	var downloadedSessions = 0;
	var downloadedProcessSessions = 0;
	var downloadedMouseSessions = 0;
	var downloadedKeystrokesSessions = 0;
	var totalSessions = 0;
	
	var processChunkSize = 500000;
	
	var downloadedSessionProcesses = 0;
	
	var maxDownloadingProcesses = 4;
	var curDownloadingProcesses = 0;
	var maxDownloadingProcessesCeil = 8;
	var processDownloadQueue = [];
	
	async function downloadProcesses(userName, sessionName, nextCount, sheet)
	{
		console.log("Downloading process data for: " + userName + ":" + sessionName + ", index " + nextCount);
		if(curDownloadingProcesses >= maxDownloadingProcesses)
		{
			console.log("Already downloading max, put in queue.");
			var argList = [userName, sessionName, nextCount, sheet];
			processDownloadQueue.push(argList);
			return;
			
		}
		curDownloadingProcesses++;
		if(!sheet)
		{
			var hashVal = SHA256(user + session + "_processes");
			var hasStored = ((await hasData(hashVal)))
			if(hasStored)
			{
				var curProcArray = ((await retrieveData(hashVal)).value);
				//nextCount = curProcArray.length;
				var isDone = false;
				while(!isDone)
				{
					isDone = await persistData(hashVal, []);
				}
				
			}
			
			var sheet = document.getElementById("style_" + SHA256(userName + sessionName));
			if(!sheet)
			{
				var sheet = document.createElement('style');
				sheet.id = "style_" + SHA256(userName + sessionName);
			}
		}
		
		sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Yellow;}";
		document.body.appendChild(sheet);
		
		var curCount = nextCount;
		
		var curSelect = "&users=" + userName + "&sessions=" + sessionName + "&first=" + curCount + "&count=" + processChunkSize;
		
		var failed = true;
	
		await d3.json("logExport.json?event=" + eventName + "&datasources=processes&normalize=none" + curSelect, async function(error, data)
		{
			if(error)
			{
				maxDownloadingProcesses = maxDownloadingProcesses / 2;
				if(maxDownloadingProcesses < 1)
				{
					maxDownloadingProcesses = 1;
				}
				curDownloadingProcesses--;
				failed = true;
				console.log("Error, retrying...");
				console.log(error);
				downloadProcesses(userName, sessionName, curCount, sheet);
				return;
			}
			else
			{
				maxDownloadingProcesses = maxDownloadingProcesses * 2;
				if(maxDownloadingProcesses > maxDownloadingProcessesCeil)
				{
					maxDownloadingProcesses = maxDownloadingProcessesCeil;
				}
				if(processDownloadQueue.length > 0)
				{
					var nextArgs = processDownloadQueue.pop();
					downloadProcesses(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
				}
			}
			failed = false;
			//for(user in data)
			//if(data[userName])
			{
				//for(session in data[user])
				//if(data[userName][sessionName])
				{
					var curProcessList;
					if(!data[userName][sessionName])
					{
						
					}
					else
					{
						curProcessList = data[userName][sessionName]["processes"];
					}
					if(curProcessList)
					{
						var hashVal = SHA256(userName + sessionName + "_processes");
						
						for(entry in curProcessList)
						{
							curProcessList[entry]["Original Session"] = sessionName;
						}
						
						try
						{
							var hasStored = ((await hasData(hashVal)))
							var curProcArray = curProcessList;
							if(hasStored)
							{
								curProcArray = ((await retrieveData(hashVal)).value);
								curProcArray = curProcArray.concat(curProcessList);
							}
							
							var isDone = false;
							while(!isDone)
							{
								isDone = await persistData(hashVal, curProcArray);
							}
						}
						catch(err)
						{
							failed = true;
							console.log(err);
						}
						curDownloadingProcesses--;
						downloadProcesses(userName, sessionName, curCount + processChunkSize, sheet);
					}
					else
					{
						curDownloadingProcesses--;
						downloadedProcessSessions++;
						console.log("Done downloading processes for " + userName + ":" + sessionName);
						//start(true);
						d3.select("#title")
						.html(origTitle + "<br />Index data: <b>"
								+ downloadedSize
								+ "</b> bytes; new image data: <b>"
								+ downloadedImageSize
								+ "</b> bytes; new process data: <b>"
								+ downloadedProcessSize
								+ "</b> bytes; new keystrokes data: <b>"
								+ downloadedKeystrokesSize
								+ "</b> bytes; new mouse data: <b>"
								+ downloadedMouseSize + "</b> bytes; finished "
								+ downloadedSessions
								+ " screenshot, "
								+ downloadedProcessSessions + " process, "
								+ downloadedKeystrokesSessions + " keystrokes, and "
								+ downloadedMouseSessions + " mouse sessions of "
								+ totalSessions
								+ " total sessions.")
						if(addDownloadCount(userName, sessionName) >= numAsync)
						{
							sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Chartreuse;}";
							if(downloadedMouseSessions == totalSessions && downloadedKeystrokesSessions == totalSessions && downloadedProcessSessions == totalSessions && downloadedSessions == totalSessions)
							{
								removeFilter(1);
							}
						}
						
						if(processDownloadQueue.length > 0)
						{
							var nextArgs = processDownloadQueue.pop();
							downloadProcesses(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
						}
					}
					
				}
			}
		})
		.on("progress", async function(d, i)
		{
			//downloadedSize = d["loaded"];
			downloadedProcessSize += d["loaded"];
			d3.select("#title")
			.html(origTitle + "<br />Index data: <b>"
					+ downloadedSize
					+ "</b> bytes; new image data: <b>"
					+ downloadedImageSize
					+ "</b> bytes; new process data: <b>"
					+ downloadedProcessSize
					+ "</b> bytes; new keystrokes data: <b>"
					+ downloadedKeystrokesSize
					+ "</b> bytes; new mouse data: <b>"
					+ downloadedMouseSize + "</b> bytes; finished "
					+ downloadedSessions
					+ " screenshot, "
					+ downloadedProcessSessions + " process, "
					+ downloadedKeystrokesSessions + " keystrokes, and "
					+ downloadedMouseSessions + " mouse sessions of "
					+ totalSessions
					+ " total sessions.")
		});
	}
	
	var mouseChunkSize = 1000000;
	
	var downloadedSessionMouse = 0;
	
	var maxDownloadingMouse = 2;
	var curDownloadingMouse = 0;
	var mouseDownloadQueue = [];
	var maxDownloadingMouseCeil = 4;
	
	async function downloadMouse(userName, sessionName, nextCount, sheet)
	{
		console.log("Downloading mouse data for: " + userName + ":" + sessionName + ", index " + nextCount);
		if(curDownloadingMouse >= maxDownloadingMouse)
		{
			console.log("Already downloading max, put in queue.");
			var argList = [userName, sessionName, nextCount, sheet];
			mouseDownloadQueue.push(argList);
			return;
			
		}
		curDownloadingMouse++;
		if(!sheet)
		{
			var hashVal = SHA256(user + session + "_mouse");
			var hasStored = ((await hasData(hashVal)))
			if(hasStored)
			{
				var curMouseArray = ((await retrieveData(hashVal)).value);
				//nextCount = curProcArray.length;
				var isDone = false;
				while(!isDone)
				{
					isDone = await persistData(hashVal, []);
				}
				
			}
			
			var sheet = document.getElementById("style_" + SHA256(userName + sessionName));
			if(!sheet)
			{
				var sheet = document.createElement('style');
				sheet.id = "style_" + SHA256(userName + sessionName);
			}
		}
		
		sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Yellow;}";
		document.body.appendChild(sheet);
		
		var curCount = nextCount;
		
		var curSelect = "&users=" + userName + "&sessions=" + sessionName + "&first=" + curCount + "&count=" + mouseChunkSize;
		
		var failed = true;
	
		await d3.json("logExport.json?event=" + eventName + "&datasources=mouse&normalize=none" + curSelect, async function(error, data)
		{
			if(error)
			{
				maxDownloadingMouse = maxDownloadingMouse / 2;
				if(maxDownloadingMouse < 1)
				{
					maxDownloadingMouse = 1;
				}
				curDownloadingMouse--;
				failed = true;
				console.log("Error, retrying...");
				console.log(error);
				downloadMouse(userName, sessionName, curCount, sheet);
				return;
			}
			else
			{
				maxDownloadingMouse = maxDownloadingMouse * 2;
				if(maxDownloadingMouse > maxDownloadingMouseCeil)
				{
					maxDownloadingMouse = maxDownloadingMouseCeil;
				}
				if(mouseDownloadQueue.length > 0)
				{
					var nextArgs = mouseDownloadQueue.pop();
					downloadMouse(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
				}
			}
			failed = false;
			//for(user in data)
			//if(data[userName])
			{
				//for(session in data[user])
				//if(data[userName][sessionName])
				{
					var curMouseList;
					if(!(data[userName][sessionName]))
					{
						
					}
					else
					{
						curMouseList = data[userName][sessionName]["mouse"];
					}
					if(curMouseList)
					{
						var hashVal = SHA256(userName + sessionName + "_mouse");
						
						for(entry in curMouseList)
						{
							curMouseList[entry]["Original Session"] = sessionName;
						}
						
						try
						{
							var hasStored = ((await hasData(hashVal)))
							var curMouseArray = curMouseList;
							if(hasStored)
							{
								curMouseArray = ((await retrieveData(hashVal)).value);
								curMouseArray = curMouseArray.concat(curMouseList);
							}
							
							var isDone = false;
							while(!isDone)
							{
								isDone = await persistData(hashVal, curMouseArray);
							}
						}
						catch(err)
						{
							failed = true;
							console.log(err);
						}
						curDownloadingMouse--;
						downloadMouse(userName, sessionName, curCount + mouseChunkSize, sheet);
					}
					else
					{
						curDownloadingMouse--;
						downloadedMouseSessions++;
						console.log("Done downloading mouse for " + userName + ":" + sessionName);
						//start(true);
						d3.select("#title")
						.html(origTitle + "<br />Index data: <b>"
								+ downloadedSize
								+ "</b> bytes; new image data: <b>"
								+ downloadedImageSize
								+ "</b> bytes; new process data: <b>"
								+ downloadedProcessSize
								+ "</b> bytes; new keystrokes data: <b>"
								+ downloadedKeystrokesSize
								+ "</b> bytes; new mouse data: <b>"
								+ downloadedMouseSize + "</b> bytes; finished "
								+ downloadedSessions
								+ " screenshot, "
								+ downloadedProcessSessions + " process, "
								+ downloadedKeystrokesSessions + " keystrokes, and "
								+ downloadedMouseSessions + " mouse sessions of "
								+ totalSessions
								+ " total sessions.")
						if(addDownloadCount(userName, sessionName) >= numAsync)
						{
							sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Chartreuse;}";
							if(downloadedMouseSessions == totalSessions && downloadedKeystrokesSessions == totalSessions && downloadedProcessSessions == totalSessions && downloadedSessions == totalSessions)
							{
								removeFilter(1);
							}
						}
						
						if(mouseDownloadQueue.length > 0)
						{
							var nextArgs = mouseDownloadQueue.pop();
							downloadMouse(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
						}
					}
					
				}
			}
		})
		.on("progress", async function(d, i)
		{
			//downloadedSize = d["loaded"];
			downloadedMouseSize += d["loaded"];
			d3.select("#title")
			.html(origTitle + "<br />Index data: <b>"
					+ downloadedSize
					+ "</b> bytes; new image data: <b>"
					+ downloadedImageSize
					+ "</b> bytes; new process data: <b>"
					+ downloadedProcessSize
					+ "</b> bytes; new keystrokes data: <b>"
					+ downloadedKeystrokesSize
					+ "</b> bytes; new mouse data: <b>"
					+ downloadedMouseSize + "</b> bytes; finished "
					+ downloadedSessions
					+ " screenshot, "
					+ downloadedProcessSessions + " process, "
					+ downloadedKeystrokesSessions + " keystrokes, and "
					+ downloadedMouseSessions + " mouse sessions of "
					+ totalSessions
					+ " total sessions.")
		});
	}
	
	var keystrokesChunkSize = 1000000;
	
	var downloadedSessionKeystrokes = 0;
	
	var maxDownloadingKeystrokes = 2;
	var curDownloadingKeystrokes = 0;
	var keystrokesDownloadQueue = [];
	var maxDownloadingKeystrokesCeil = 4;
	
	async function downloadKeystrokes(userName, sessionName, nextCount, sheet)
	{
		console.log("Downloading keystrokes data for: " + userName + ":" + sessionName + ", index " + nextCount);
		if(curDownloadingKeystrokes >= maxDownloadingKeystrokes)
		{
			console.log("Already downloading max, put in queue.");
			var argList = [userName, sessionName, nextCount, sheet];
			keystrokesDownloadQueue.push(argList);
			return;
			
		}
		curDownloadingKeystrokes++;
		if(!sheet)
		{
			var hashVal = SHA256(user + session + "_keystrokes");
			var hasStored = ((await hasData(hashVal)))
			if(hasStored)
			{
				var curKeystrokesArray = ((await retrieveData(hashVal)).value);
				//nextCount = curProcArray.length;
				var isDone = false;
				while(!isDone)
				{
					isDone = await persistData(hashVal, []);
				}
				
			}
			
			var sheet = document.getElementById("style_" + SHA256(userName + sessionName));
			if(!sheet)
			{
				var sheet = document.createElement('style');
				sheet.id = "style_" + SHA256(userName + sessionName);
			}
		}
		
		sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Yellow;}";
		document.body.appendChild(sheet);
		
		var curCount = nextCount;
		
		var curSelect = "&users=" + userName + "&sessions=" + sessionName + "&first=" + curCount + "&count=" + keystrokesChunkSize;
		
		var failed = true;
	
		await d3.json("logExport.json?event=" + eventName + "&datasources=keystrokes&normalize=none" + curSelect, async function(error, data)
		{
			if(error)
			{
				maxDownloadingKeystrokes = maxDownloadingKeystrokes / 2;
				if(maxDownloadingKeystrokes < 1)
				{
					maxDownloadingKeystrokes = 1;
				}
				curDownloadingKeystrokes--;
				failed = true;
				console.log("Error, retrying...");
				console.log(error);
				downloadKeystrokes(userName, sessionName, curCount, sheet);
				return;
			}
			else
			{
				maxDownloadingKeystrokes = maxDownloadingKeystrokes * 2;
				if(maxDownloadingKeystrokes > maxDownloadingKeystrokesCeil)
				{
					maxDownloadingKeystrokes = maxDownloadingKeystrokesCeil;
				}
				if(keystrokesDownloadQueue.length > 0)
				{
					var nextArgs = keystrokesDownloadQueue.pop();
					downloadKeystrokes(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
				}
			}
			failed = false;
			//for(user in data)
			//if(data[userName])
			{
				//for(session in data[user])
				//if(data[userName][sessionName])
				{
					var curKeystrokesList;
					if(!data[userName][sessionName])
					{
						
					}
					else
					{
						curKeystrokesList = data[userName][sessionName]["keystrokes"];
					}
					if(curKeystrokesList)
					{
						var hashVal = SHA256(userName + sessionName + "_keystrokes");
						
						for(entry in curKeystrokesList)
						{
							curKeystrokesList[entry]["Original Session"] = sessionName;
						}
						
						try
						{
							var hasStored = ((await hasData(hashVal)))
							var curKeystrokesArray = curKeystrokesList;
							if(hasStored)
							{
								curKeystrokesArray = ((await retrieveData(hashVal)).value);
								curKeystrokesArray = curKeystrokesArray.concat(curKeystrokesList);
							}
							
							var isDone = false;
							while(!isDone)
							{
								isDone = await persistData(hashVal, curKeystrokesArray);
							}
						}
						catch(err)
						{
							failed = true;
							console.log(err);
						}
						curDownloadingKeystrokes--;
						downloadKeystrokes(userName, sessionName, curCount + keystrokesChunkSize, sheet);
					}
					else
					{
						curDownloadingKeystrokes--;
						downloadedKeystrokesSessions++;
						console.log("Done downloading mouse for " + userName + ":" + sessionName);
						//start(true);
						d3.select("#title")
						.html(origTitle + "<br />Index data: <b>"
								+ downloadedSize
								+ "</b> bytes; new image data: <b>"
								+ downloadedImageSize
								+ "</b> bytes; new process data: <b>"
								+ downloadedProcessSize
								+ "</b> bytes; new keystrokes data: <b>"
								+ downloadedKeystrokesSize
								+ "</b> bytes; new mouse data: <b>"
								+ downloadedMouseSize + "</b> bytes; finished "
								+ downloadedSessions
								+ " screenshot, "
								+ downloadedProcessSessions + " process, "
								+ downloadedKeystrokesSessions + " keystrokes, and "
								+ downloadedMouseSessions + " mouse sessions of "
								+ totalSessions
								+ " total sessions.")
						if(addDownloadCount(userName, sessionName) >= numAsync)
						{
							sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Chartreuse;}";
							if(downloadedMouseSessions == totalSessions && downloadedKeystrokesSessions == totalSessions && downloadedProcessSessions == totalSessions && downloadedSessions == totalSessions)
							{
								removeFilter(1);
							}
						}
						
						if(keystrokesDownloadQueue.length > 0)
						{
							var nextArgs = keystrokesDownloadQueue.pop();
							downloadKeystrokes(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
						}
					}
					
				}
			}
		})
		.on("progress", async function(d, i)
		{
			//downloadedSize = d["loaded"];
			downloadedKeystrokesSize += d["loaded"];
			d3.select("#title")
			.html(origTitle + "<br />Index data: <b>"
					+ downloadedSize
					+ "</b> bytes; new image data: <b>"
					+ downloadedImageSize
					+ "</b> bytes; new process data: <b>"
					+ downloadedProcessSize
					+ "</b> bytes; new keystrokes data: <b>"
					+ downloadedKeystrokesSize
					+ "</b> bytes; new mouse data: <b>"
					+ downloadedMouseSize + "</b> bytes; finished "
					+ downloadedSessions
					+ " screenshot, "
					+ downloadedProcessSessions + " process, "
					+ downloadedKeystrokesSessions + " keystrokes, and "
					+ downloadedMouseSessions + " mouse sessions of "
					+ totalSessions
					+ " total sessions.")
		});
	}
	
	async function colorButtons(userName, sessionName)
	{
		var sheet = document.createElement('style');
		sheet.id = "style_" + SHA256(userName + sessionName);
		sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Yellow;}";
		document.body.appendChild(sheet);
	}
	
	var chunkSize = 50;
	
	var maxDownloadingImages = 4;
	var curDownloadingImages = 0;
	var imageDownloadQueue = [];
	var maxDownloadingImagesCeil = 4;
	
	async function downloadImages(userName, sessionName, imageArray, nextCount, sheet)
	{
		console.log("Downloading image data for: " + userName + ":" + sessionName + ", index " + nextCount);
		
		if(curDownloadingImages >= maxDownloadingImages)
		{
			console.log("Already downloading max images, put in queue.");
			var argList = [userName, sessionName, imageArray, nextCount, sheet];
			console.log(argList);
			imageDownloadQueue.push(argList);
			return;
			
		}
		
		if(!imageArray)
		{
			console.log("No images: " + userName + ": " + sessionName);
			if(imageDownloadQueue.length > 0)
			{
				var nextArgs = imageDownloadQueue.pop();
				downloadImages(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3], nextArgs[4]);
			}
			else
			{
				curDownloadingImages--;
			}
			return;
		}
		
		curDownloadingImages++;
		if(!sheet)
		{
			var sheet = document.getElementById("style_" + SHA256(userName + sessionName));
			if(!sheet)
			{
				var sheet = document.createElement('style');
				sheet.id = "style_" + SHA256(userName + sessionName);
			}
		}
		sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Yellow;}";
		document.body.appendChild(sheet);

		var curCount = nextCount;
		
		while(curCount < imageArray.length)
		{
			if(!imageArray[curCount]["ImageHash"])
			{
				imageArray[curCount]["ImageHash"] = SHA256(user + session + imageArray[curCount]["Index MS"]);
			}
			var entry = curCount;
			var curScreenshot = (await hasScreenshot(imageArray[curCount]));
			if(curScreenshot)
			{
				curCount = entry + 1;
				//break;
			}
			else
			{
				break;
			}
		}
		if(curCount < imageArray.length)
		{
			var curSelect = "&users=" + userName + "&sessions=" + sessionName + "&first=" + curCount + "&count=" + chunkSize;
			await d3.json("logExport.json?event=" + eventName + "&datasources=screenshots&normalize=none" + curSelect, async function(error, data)
			{
				if(error)
				{
					maxDownloadingImages = maxDownloadingImages / 2;
					if(maxDownloadingImages < 1)
					{
						maxDownloadingImages = 1;
					}
					failed = true;
					console.log("Error, retrying...");
					console.log(error);
					curDownloadingImages--;
					downloadImages(userName, sessionName, imageArray, curCount, sheet);
					return;
				}
				else
				{
					maxDownloadingImages = maxDownloadingImages * 2;
					if(maxDownloadingImages > maxDownloadingImagesCeil)
					{
						maxDownloadingImages = maxDownloadingImagesCeil;
					}
					if(imageDownloadQueue.length > 0)
					{
						var nextArgs = imageDownloadQueue.pop();
						downloadImages(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3], nextArgs[4]);
					}
				}
				//for(user in data)
				{
					//for(session in data[user])
					{
						
						var curScreenshotList = data[userName][sessionName]["screenshots"];
						
						for(screenshot in curScreenshotList)
						{
							var hashVal = SHA256(userName + sessionName + curScreenshotList[screenshot]["Index MS"]);
							try
							{
								var isDone = false;
								while(!isDone)
								{
									isDone = await persistData(hashVal, curScreenshotList[screenshot]["Screenshot"]);
								}
							}
							catch(err)
							{
								console.log(err);
							}
							curCount++;
						}
					}
				}
				
				d3.select("#title")
				.html(origTitle + "<br />Index data: <b>"
						+ downloadedSize
						+ "</b> bytes; new image data: <b>"
						+ downloadedImageSize
						+ "</b> bytes; new process data: <b>"
						+ downloadedProcessSize
						+ "</b> bytes; new keystrokes data: <b>"
						+ downloadedKeystrokesSize
						+ "</b> bytes; new mouse data: <b>"
						+ downloadedMouseSize + "</b> bytes; finished "
						+ downloadedSessions
						+ " screenshot, "
						+ downloadedProcessSessions + " process, "
						+ downloadedKeystrokesSessions + " keystrokes, and "
						+ downloadedMouseSessions + " mouse sessions of "
						+ totalSessions
						+ " total sessions.")

				if(curCount < imageArray.length)
				{
					console.log("Continuing screenshots from " + userName + ", " + sessionName + ": " + curCount + " : " + chunkSize + " of " + imageArray.length);
					curDownloadingImages--;
					downloadImages(userName, sessionName, imageArray, curCount, sheet);
				}
				else
				{
					curDownloadingImages--;
					downloadedSessions++;
					d3.select("#title")
					.html(origTitle + "<br />Index data: <b>"
							+ downloadedSize
							+ "</b> bytes; new image data: <b>"
							+ downloadedImageSize
							+ "</b> bytes; new process data: <b>"
							+ downloadedProcessSize
							+ "</b> bytes; new keystrokes data: <b>"
							+ downloadedKeystrokesSize
							+ "</b> bytes; new mouse data: <b>"
							+ downloadedMouseSize + "</b> bytes; finished "
							+ downloadedSessions
							+ " screenshot, "
							+ downloadedProcessSessions + " process, "
							+ downloadedKeystrokesSessions + " keystrokes, and "
							+ downloadedMouseSessions + " mouse sessions of "
							+ totalSessions
							+ " total sessions.")
					if(addDownloadCount(userName, sessionName) >= numAsync)
					{
						sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Chartreuse;}";
						if(downloadedMouseSessions == totalSessions && downloadedKeystrokesSessions == totalSessions && downloadedProcessSessions == totalSessions && downloadedSessions == totalSessions)
						{
							removeFilter(1);
						}
					}
					if(imageDownloadQueue.length > 0)
					{
						var nextArgs = imageDownloadQueue.pop();
						downloadImages(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
					}
				}
				
			})
			.on("progress", async function(d, i)
					{
						//downloadedSize = d["loaded"];
						downloadedImageSize += d["loaded"];
						d3.select("#title")
						.html(origTitle + "<br />Index data: <b>"
								+ downloadedSize
								+ "</b> bytes; new image data: <b>"
								+ downloadedImageSize
								+ "</b> bytes; new process data: <b>"
								+ downloadedProcessSize
								+ "</b> bytes; new keystrokes data: <b>"
								+ downloadedKeystrokesSize
								+ "</b> bytes; new mouse data: <b>"
								+ downloadedMouseSize + "</b> bytes; finished "
								+ downloadedSessions
								+ " screenshot, "
								+ downloadedProcessSessions + " process, "
								+ downloadedKeystrokesSessions + " keystrokes, and "
								+ downloadedMouseSessions + " mouse sessions of "
								+ totalSessions
								+ " total sessions.")
					});
		}
		else
		{
			curDownloadingImages--;
			downloadedSessions++;
			d3.select("#title")
			.html(origTitle + "<br />Index data: <b>"
					+ downloadedSize
					+ "</b> bytes; new image data: <b>"
					+ downloadedImageSize
					+ "</b> bytes; new process data: <b>"
					+ downloadedProcessSize
					+ "</b> bytes; new keystrokes data: <b>"
					+ downloadedKeystrokesSize
					+ "</b> bytes; new mouse data: <b>"
					+ downloadedMouseSize + "</b> bytes; finished "
					+ downloadedSessions
					+ " screenshot, "
					+ downloadedProcessSessions + " process, "
					+ downloadedKeystrokesSessions + " keystrokes, and "
					+ downloadedMouseSessions + " mouse sessions of "
					+ totalSessions
					+ " total sessions.")
			if(addDownloadCount(userName, sessionName) >= numAsync)
			{
				sheet.innerHTML = "#playbutton_" + SHA256(userName + sessionName) + " {fill:Chartreuse;}";
				if(downloadedMouseSessions == totalSessions && downloadedKeystrokesSessions == totalSessions && downloadedProcessSessions == totalSessions && downloadedSessions == totalSessions)
				{
					removeFilter(1);
				}
			}
			if(imageDownloadQueue.length > 0)
			{
				var nextArgs = imageDownloadQueue.pop();
				downloadImages(nextArgs[0], nextArgs[1], nextArgs[2], nextArgs[3]);
			}
		}
	}
	
	function sleep(seconds)
	{
		var e = new Date().getTime + (seconds * 1000);
		while(new Date().getTime() < e) {}
	}

	
	function setTimeScale(type)
	{
		timeMode = type;
		if(theNormDataDone)
		{
			start(false);
		}
	}
	
	async function getProcessMapData()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_processes_map");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}

	async function storeProcessDataMap(toStore)
	{
		if(this.session == "Aggregated")
		{
			
		}
		else
		{
			var isDone = false;
			//while(!isDone)
			{
				var hashVal = SHA256(this.user + this.session + "_processes_map");
				isDone = await persistDataAndWait(hashVal, toStore);
			}
		}
	}
	
	async function getProcessLookupData()
	{
		if(this.session == "Aggregated")
		{
			return [];
		}
		else
		{
			var hashVal = SHA256(this.user + this.session + "_processes_lookup");
			var toReturn = (await retrieveData(hashVal));
			return toReturn;
		}
	}

	async function storeProcessDataLookup(toStore)
	{
		if(this.session == "Aggregated")
		{
			
		}
		else
		{
			var isDone = false;
			while(!isDone)
			{
				var hashVal = SHA256(this.user + this.session + "_processes_lookup");
				isDone = await persistDataAndWait(hashVal, toStore);
			}
		}
	}
	
	var colorScale = d3.scaleOrdinal(d3.schemeCategory20);
	var colorScaleAccent = d3.scaleOrdinal(d3["schemeAccent"]);
	
	var processToWindow = {};
	var windowToProcess = {};

	var timelineTick;
	var timelineText;

	var visWidthParent = (containingTableRow.offsetWidth - visPadding);
	var refreshingStart = false;
	async function start(needsUpdate)
	{
		if(refreshingStart)
		{
			console.log("Already restarting");
			return;
		}
		refreshingStart = true;
		d3.select(visRow).style("max-width", (visWidthParent + visPadding) + "px");
		d3.select(visTable).style("max-width", (visWidthParent + visPadding) + "px");
		
		var timelineZoom = Number(document.getElementById("timelineZoom").value);
		var timelineZoomVert = Number(document.getElementById("timelineZoomVert").value);
		visWidth = (visWidthParent) * timelineZoom;
		var visHeightNew = windowHeight * .5 * timelineZoomVert;
		barHeight = visHeightNew / 10;
		legendHeight = visHeightNew / 25;

		if(needsUpdate)
		{
			d3.select("#mainVisualization").selectAll("*").remove();
			//d3.select("#mainVisualization").html("");
			d3.select("#legend").selectAll("*").remove();
			
			//d3.select("#legend").html("");
			clearWindow();
			
			let theNormDataInit = ((await retrieveData("data")).value);
			
			for(user in theNormDataInit)
			{
				for(session in theNormDataInit[user])
				{
					if(!theNormDataInit[user][session]["processes"])
					{
						var processDataObject = {};
						processDataObject["user"] = user;
						processDataObject["session"] = session;
						processDataObject["data"] = getProcessData;
						processDataObject["getfiltered"] = getProcessDataFiltered;
						processDataObject["storefiltered"] = storeProcessDataFiltered;
						theNormDataInit[user][session]["processes"] = processDataObject;
					}
					if(!theNormDataInit[user][session]["mouse"])
					{
						var mouseDataObject = {};
						mouseDataObject["user"] = user;
						mouseDataObject["session"] = session;
						mouseDataObject["data"] = getMouseData;
						mouseDataObject["getfiltered"] = getMouseDataFiltered;
						mouseDataObject["storefiltered"] = storeMouseDataFiltered;
						theNormDataInit[user][session]["mouse"] = mouseDataObject;
					}
					if(!theNormDataInit[user][session]["keystrokes"])
					{
						var keystrokesDataObject = {};
						keystrokesDataObject["user"] = user;
						keystrokesDataObject["session"] = session;
						keystrokesDataObject["data"] = getKeystrokesData;
						keystrokesDataObject["getfiltered"] = getKeystrokesDataFiltered;
						keystrokesDataObject["storefiltered"] = storeKeystrokesDataFiltered;
						theNormDataInit[user][session]["keystrokes"] = keystrokesDataObject;
					}
				}
			}
			var filteredData = await filter(theNormDataInit, filters);
			console.log("Filtered:");
			console.log(filteredData);
			
			theNormData = filteredData//((await filter(theNormDataInit, filters)).value);
			showDefault();
		}
		console.log("Starting Main Vis")
		lookupTable = {};
		//Prepare data with sorting and finding mins, maxes
		
		var curWindowNum = 0;
		var windowColorNumber = {};
		var windowLegend = [];
		
		if(needsUpdate)
		{
			processMap = {};
			lookupTable = {};
			userOrderMap = {};
			for(user in theNormData)
			{
				sessionOrderMap = {};
				maxTimeUser = 0;
				minTimeUser = Number.POSITIVE_INFINITY;
				minTimeUserAbsolute = Number.POSITIVE_INFINITY;
				maxTimeUserDate = "";
				minTimeUserDate = "";
				minTimeUserUniversal = Number.POSITIVE_INFINITY;
				for(session in theNormData[user])
				{
					maxTimeSession = 0;
					minTimeSession = Number.POSITIVE_INFINITY;
					minTimeSessionUniversal = Number.POSITIVE_INFINITY;
					minTimeUserSession = Number.POSITIVE_INFINITY;
					maxTimeSessionDate = "";
					minTimeSessionDate = "";
					theCurData = theNormData[user][session];
					for(dataType in theCurData)
					{
						thisData = theCurData[dataType];
						
						if(!(user in lookupTable))
						{
							lookupTable[user] = {};
						}
						if(!(session in lookupTable[user]))
						{
							lookupTable[user][session] = {};
						}
						
						var isAsync = false;
						
						if(thisData["data"] && (typeof thisData["data"]) == "function")
						{
							thisData = (await thisData["getfiltered"]());
							if(!thisData)
							{
								console.log("No data for " + user + ":" + session + ":" + dataType)
								continue;
							}
							thisData = thisData.value;
							isAsync = true;
						}
						
						if(!thisData)
						{
							console.log("No data for " + user + ":" + session + ":" + dataType)
							continue;
						}
						
						var curUserSessionMap;
						if(dataType == "processes")
						{
							var curLookupTable = {};
							if(!("Processes" in lookupTable[user][session]))
							{
								lookupTable[user][session]["Processes"] = {};
								lookupTable[user][session]["Processes"]["user"] = user;
								lookupTable[user][session]["Processes"]["session"] = session;
								lookupTable[user][session]["Processes"]["data"] = getProcessLookupData;
								lookupTable[user][session]["Processes"]["storedata"] = storeProcessDataLookup;
								await lookupTable[user][session]["Processes"]["storedata"](curLookupTable);
							}
							curLookupTable = (await (lookupTable[user][session]["Processes"]["data"]())).value;
							
							if(!(user in processMap))
							{
								processMap[user] = {};
							}
							if(!(session in processMap[user]))
							{
								//processMap[user][session] = {};
								var processMapDataObject = {};
								processMapDataObject["user"] = user;
								processMapDataObject["session"] = session;
								processMapDataObject["data"] = getProcessMapData;
								processMapDataObject["storedata"] = storeProcessDataMap;
								await processMapDataObject["storedata"]({});
								processMap[user][session] = processMapDataObject;
							}
							curUserSessionMap = (await (processMap[user][session]["data"]())).value;
						}
						
						for(x=0; x<thisData.length; x++)
						{
							if(dataType == "screenshots")
							{
								thisData[x]["Hash"] = SHA256(user + session + thisData[x]["Index MS"]);
								thisData[x]["Screenshot"] = getScreenshotData;
							}
							
							if(dataType == "windows")
							{
								if(!(thisData[x]["FirstClass"] in windowColorNumber))
								{
									windowColorNumber[thisData[x]["FirstClass"]] = curWindowNum % 20;
									curWindowNum++;
									windowLegend.push(thisData[x]["FirstClass"])
								}
							}
							
							if(dataType == "processes")
							{

								thisData[x]["Owning User"] = user;
								thisData[x]["Owning Session"] = session;
								thisData[x]["Hash"] = SHA256(thisData[x]["User"] + thisData[x]["Start"] + thisData[x]["PID"])

								curLookupTable[thisData[x]["Hash"]] = thisData[x];
								//lookupTable[user][session]["Processes"][thisData[x]["Hash"]] = thisData[x];

								
								
								curPid = thisData[x]["PID"]
								curOSUser = thisData[x]["User"]
								curStart = thisData[x]["Start"]
								thisData[x]["CPU"] = Number(thisData[x]["CPU"])
								curCPU = thisData[x]["CPU"]
								thisData[x]["Mem"] = Number(thisData[x]["Mem"])
								curMem = thisData[x]["Mem"]
								
								if(!(curOSUser in curUserSessionMap))
								{
									curUserSessionMap[curOSUser] = {};
								}
								if(!(curStart in curUserSessionMap[curOSUser]))
								{
									curUserSessionMap[curOSUser][curStart] = {};
								}
								if(!(curPid in curUserSessionMap[curOSUser][curStart]))
								{
									thisData[x]["Aggregate CPU"] = curCPU
									thisData[x]["Aggregate Mem"] = curMem
									curUserSessionMap[curOSUser][curStart][curPid] = [];
									curUserSessionMap[curOSUser][curStart][curPid].push(thisData[x]);
								}
								else
								{
									curList = curUserSessionMap[curOSUser][curStart][curPid];
									thisData[x]["Aggregate CPU"] = curCPU + curList[curList.length - 1]["Aggregate CPU"]
									thisData[x]["Aggregate Mem"] = curMem + curList[curList.length - 1]["Aggregate Mem"]
									thisData[x]["Prev"] = curList[curList.length - 1];
									curList[curList.length - 1]["Next"] = thisData[x];
									curList.push(thisData[x]);
								}
								
							}
							
							thisData[x]["Index MS Universal"] = Number(thisData[x]["Index MS Universal"]);
							thisData[x]["Index MS"] = Number(thisData[x]["Index MS"]);
							thisData[x]["Index MS User"] = Number(thisData[x]["Index MS User"]);
							thisData[x]["Index MS Session"] = Number(thisData[x]["Index MS Session"]);
						}
						
						if(dataType == "processes")
						{
							if(curUserSessionMap)
							{
								console.log(user + ": " + session);
								console.log(curUserSessionMap);
								await processMap[user][session]["storedata"](curUserSessionMap);
							}
							await lookupTable[user][session]["Processes"]["storedata"](curLookupTable);
						}
						
						if(thisData.length > 0 && !(dataType == "environment"))
						{
							lastTimeSession = thisData[thisData.length - 1]["Index MS Session"];
							lastTimeUser = thisData[thisData.length - 1]["Index MS User"];
							lastTimeDate = thisData[thisData.length - 1]["Index"];
							firstTimeSession = thisData[0]["Index MS Session"];
							firstTimeUser = thisData[0]["Index MS User"];
							firstTimeUserAbsolute = thisData[0]["Index MS"];
							firstTimeDate = thisData[0]["Index"];
							
							if(lastTimeSession > maxTimeSession)
							{
								maxTimeSession = lastTimeSession;
								maxTimeSessionDate = lastTimeDate;
							}
							if(firstTimeSession < minTimeSession)
							{
								minTimeSession = firstTimeSession;
								minTimeSessionUniversal = firstTimeUserAbsolute;
								minTimeSessionDate = firstTimeDate;
							}
							if(firstTimeUser < minTimeUserSession)
							{
								minTimeUserSession = firstTimeUser;
							}
							if(lastTimeUser > maxTimeUser)
							{
								maxTimeUser = lastTimeUser;
								maxTimeUserDate = lastTimeDate;
							}
							if(firstTimeUser < minTimeUser)
							{
								minTimeUser = firstTimeUser;
								minTimeUserAbsolute = firstTimeUserAbsolute;
								minTimeUserDate = firstTimeDate;
								
							}
							firstTimeUniversal = thisData[0]["Index MS Universal"];
							if(firstTimeUniversal < minTimeUserUniversal)
							{
								minTimeUserUniversal = firstTimeUniversal;
							}
						}
						
						if(isAsync)
						{
							await theCurData[dataType]["storefiltered"](thisData);
						}
						
					}
					theCurData["Index MS Session Max"] = maxTimeSession;
					theCurData["Index MS Session Min"] = minTimeSession;
					theCurData["Index MS Session Min Universal"] = minTimeSessionUniversal;
					theCurData["Index MS Session Max Date"] = maxTimeSessionDate;
					theCurData["Index MS Session Min Date"] = minTimeSessionDate;
					
					theCurData["Index MS User Session Min"] = minTimeUserSession;
					
					theCurData["Time Adjustment"] = 0;
					if(session == "Aggregated")
					{
						theCurData["Time Adjustment"] = theCurData["Time Adjustment"] - 1;
						minTimeUserSession = -1;
					}
					while(minTimeUserSession in sessionOrderMap)
					{
						if(session == "Aggregated")
						{
							theCurData["Time Adjustment"] = theCurData["Time Adjustment"] - 1;
							minTimeUserSession--;
						}
						else
						{
							theCurData["Time Adjustment"] = theCurData["Time Adjustment"] + 1;
							minTimeUserSession++;
						}
					}
					
					sessionOrderMap[minTimeUserSession] = session;
					
					timeScale = d3.scaleLinear();
					timeScale.domain
								(
									[0, maxTimeSession]
								)
					timeScale.range
								(
									[0, visWidth - xAxisPadding]
								);
					theCurData["Time Scale"] = timeScale;
				}
				
				theNormData[user]["Index MS Universal Min"] = minTimeUserUniversal;
				userOrderMap[minTimeUserUniversal] = user;
				
				sessionOrderArray = Object.keys(sessionOrderMap).sort(function(a, b) {return a - b;});
				sessionOrderMap["Order List"] = sessionOrderArray;
				theNormData[user]["Session Ordering"] = sessionOrderMap;
				
				theNormData[user]["Index MS User Max"] = maxTimeUser;
				theNormData[user]["Index MS User Min"] = minTimeUser;
				theNormData[user]["Index MS User Max Date"] = maxTimeUserDate;
				theNormData[user]["Index MS User Min Date"] = minTimeUserDate;
				theNormData[user]["Index MS User Min Absolute"] = minTimeUserAbsolute;
				
				timeScale = d3.scaleLinear();
				timeScale.domain
							(
								[0, maxTimeUser]
							)
				timeScale.range
							(
								[0, visWidth - xAxisPadding]
							);
				theNormData[user]["Time Scale"] = timeScale;
			}
			userOrderArray = Object.keys(userOrderMap).sort(function(a, b) {return a - b;});
			userOrderMap["Order List"] = userOrderArray;
		}
		
		console.log(theNormData);
		
		//Paint legend
		
		var legendSVG = d3.selectAll("#legend")
				.append("svg")
				.attr("width", "100%")
				//.attr("height", getInnerHeight("legendCell"))
				.attr("class", "svg")
				.style('overflow', 'scroll');
		
		legendSVG = legendSVG.append("g");
		
		var legendTitle = legendSVG.append("text")
				.attr("x", "50%")
				.attr("y", .5 * legendHeight)
				.attr("alignment-baseline", "central")
				.attr("dominant-baseline", "middle")
				.attr("text-anchor", "middle")
				//.attr("font-weight", "bolder")
				.text("Active Windows:");
		
		var legend = legendSVG.append("g")
				.selectAll("rect")
				.data(windowLegend)
				.enter()
				.append("rect")
				.attr("x", 0)
				.attr("width", "100%")
				//.attr("width", legendWidth)
				.attr("y", function(d, i)
						{
							return legendHeight * (i + 1);
						})
				.attr("height", legendHeight)
				.attr("stroke", "black")
				.attr("stroke-width", 0)
				.attr("fill", function(d, i)
						{
							return colorScale(windowColorNumber[d]);
						})
				.attr("initFill", function(d, i)
						{
							return colorScale(windowColorNumber[d]);
						})
				.attr("id", function(d, i)
						{
							return "legend_" + SHA256(d);
						})
				.attr("initStrokeWidth", 0)
				.on("click", function(d, i)
				{
					if(curStroke)
					{
						d3.select(curStroke).attr("stroke", "black").attr("stroke-width", d3.select(curStroke).attr("initStrokeWidth"));d3.select(curStroke).attr("stroke", "black").attr("stroke", d3.select(curStroke).attr("initStroke"));
					}
					if(curStroke == this)
					{
						d3.select(curStroke).attr("stroke-width", 0)
						clearWindow(); curStroke = null;
						showDefault();
						return;
					}
					d3.select(this).attr("initStrokeWidth", d3.select(this).attr("stroke-width"));d3.select(this).attr("initStroke", d3.select(this).attr("stroke"));
					d3.select(this).attr("stroke", "#ffff00").attr("stroke-width", xAxisPadding / 50);
					curStroke = this;
					highlightItems("select_" + SHA256(d));
				})
		.classed("clickableBar", true);

		var legendText = legendSVG.append("g")
				.selectAll("text")
				.data(windowLegend)
				.enter()
				.append("text")
				//.attr("font-size", 11)
				.attr("x", 0)
				.attr("y", function(d, i)
						{
							//return legendHeight * (i + 1);
							//return legendHeight * (i) + legendHeight;
							return legendHeight * (i + 1) + legendHeight * .5;
						})
				.attr("height", legendHeight * .75)
				.text(function(d, i)
						{
							return d;
						})
				.attr("fill", function(d, i)
						{
							if(i % 2 == 0)
							{
								return "#FFF";
							}
							else
							{
								return "#000";
							}
						})
				.attr("font-weight", "bolder")
				.style("pointer-events", "none")
				.attr("dominant-baseline", "middle")
				.attr("stroke", function(d, i)
						{
							if(i % 2 == 0)
							{
								return "none";
							}
							else
							{
								return "none";
							}
						});
		
		var legendFilter = legendSVG.append("g")
		.selectAll("rect")
		.data(windowLegend)
		.enter()
		.append("rect")
		.attr("x", "90%")
		.attr("width", "10%")
		//.attr("width", legendWidth)
		.attr("y", function(d, i)
				{
					return legendHeight * (i + 1);
				})
		.attr("height", legendHeight)
		.attr("stroke", "black")
		.style("cursor", "pointer")
		.attr("fill", function(d, i)
				{
					return "Crimson";
				})
		.on("click", function(d, i)
		{
			addFilterDirect(3, "FirstClass", "!= '" + d + "'");
		});
		
		var legendFilterText = legendSVG.append("g")
		.selectAll("text")
		.data(windowLegend)
		.enter()
		.append("text")
		//.attr("font-size", 11)
		.attr("x", "95%")
		.attr("y", function(d, i)
				{
					//return legendHeight * (i + 1);
					//return legendHeight * (i) + legendHeight;
					return legendHeight * (i + 1) + legendHeight * .5;
				})
		.attr("height", legendHeight * .75)
		.text(function(d, i)
				{
					return "X";
				})
		.attr("fill", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "#FFF";
					}
					else
					{
						return "#000";
					}
				})
		.attr("font-weight", "bolder")
		.style("pointer-events", "none")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.attr("stroke", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "none";
					}
					else
					{
						return "none";
					}
				});
		
		//Get the SVG for the main viz timeline
		svg = d3.selectAll("#mainVisualization")
		.style("height", visHeight + "px")
		.style('overflow-y', 'scroll')
		.append("svg")
		.attr("width", visWidth)
		.attr("height", visHeight)
		.attr("class", "svg");
		
		origSvg = svg;
		svg = svg.append("g");
		
		var finalTimelineHeight = 0;

		//Paint main vis timeline
		var curSessionCount = 0;
		backgroundG = svg.append("g")
		var backgroundRects = backgroundG
		.selectAll("rect")
		.data(userOrderArray)
		.enter()
		.append("rect")
		.attr("x",  0)
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount;
					curSessionCount += numSessions;
					return toReturn;
				})
		.attr("width", visWidth)
		.attr("height", function(d, i)
				{
					if(i == 0)
					{
						finalTimelineHeight = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					finalTimelineHeight += barHeight * 2 * numSessions + barHeight;
					return barHeight * 2 * numSessions + barHeight;
				})
		.attr("stroke", "#000000")
		.attr("fill", function(d, i)
				{
					if(i % 2 == 1)
					{
						return "#ffffff"
					}
					else
					{
						return "#b7d2ff"
					}
				})
		.attr("opacity", 0.2)
		.attr("z", 1);
		
		origSvg.attr("height", finalTimelineHeight);
		
		var timelineStarts = svg.append("g")
		.selectAll("rect")
		.data(userOrderArray)
		.enter()
		.append("rect")
		.attr("x",  xAxisPadding - xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount;
					curSessionCount += numSessions;
					return toReturn + barHeight;
				})
		.attr("width", xAxisPadding / 25)
		.attr("height", function(d, i)
				{
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					return barHeight * 2 * numSessions;
				})
		.attr("stroke", "#000000")
		.attr("fill", function(d)
				{
					return "#000000"
				})
		.attr("opacity", 1)
		.attr("z", 2);

		var userLabels = svg.append("g")
		.selectAll("text")
		.data(userOrderArray)
		.enter()
		.append("text")
		.attr("x",  0)
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount + barHeight / 4;
					curSessionCount += numSessions;
					return toReturn;
				})
		.attr("width", visWidth - 2)
		.attr("height", function(d, i)
				{
					return barHeight;
				})
		.attr("stroke", "none")
		.attr("fill", function(d)
				{
					return "#000000";
				})
		.attr("opacity", 1)
		.attr("z", 2)
		.attr("font-weight", "bolder")
		.attr("dominant-baseline", "middle")		
		.text(function(d, i)
				{
					return userOrderMap[d] + ": " + theNormData[userOrderMap[d]]["Index MS User Min Date"] + " to " + theNormData[userOrderMap[d]]["Index MS User Max Date"];
				})
		.style("font-size", barHeight/4 + "px");
		
		var filterButtonsUser = svg.append("g")
		.selectAll("rect")
		.data(userOrderArray)
		.enter()
		.append("rect")
		.attr("x", visWidth - (xAxisPadding / 2 - xAxisPadding / 20))
		.attr("width", xAxisPadding / 2 - xAxisPadding / 20)
		.attr("height", barHeight - (xAxisPadding / 25))
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount;
					curSessionCount += numSessions;
					return toReturn;
				})
		.attr("fill", "Crimson")
		.attr("initFill", "Crimson")
		.attr("stroke", "black")
		.attr("initStroke", "black")
		.attr("stroke-width", "0")
		.attr("initStrokeWidth", "0")
		.attr("z", 2)
		.classed("clickableBar", true)
		.attr("id", function(d, i)
				{
					return("filterbuttonuser_" + SHA256(userOrderMap[d]));
				})
		.on("click", function(d, i)
				{
					addFilterDirect(0, "", "!= '" + userOrderMap[d] + "'");
				});

		var filterLabelsUser = svg.append("g")
		.selectAll("text")
		.data(userOrderArray)
		.enter()
		.append("text")
		.attr("x", visWidth - (xAxisPadding / 2 - xAxisPadding / 20) + xAxisPadding / 4 - xAxisPadding / 40)
		.attr("width", xAxisPadding / 2)
		.attr("height", barHeight - 2 * (xAxisPadding / 25))
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount + barHeight / 2 - (xAxisPadding / 50);
					curSessionCount += numSessions;
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("z", 2)
		.attr("font-weight", "bolder")
		.attr("font-family", "monospace")
		.attr("alignment-baseline", "central")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.text("Filter")
		.attr("initText", "Filter")
		.style("pointer-events", "none")
		.attr("id", function(d, i)
				{
					return("filterbuttonuser_label_" + SHA256(userOrderMap[d]));
				})
		.classed("clickableBar", true);
		
		var downloadButtonsUser = svg.append("g")
		.selectAll("rect")
		.data(userOrderArray)
		.enter()
		.append("rect")
		.attr("x", visWidth - (xAxisPadding / 1.75 - xAxisPadding / 20) - (barHeight - (xAxisPadding / 25)) * 2)
		.attr("width", xAxisPadding / 1.5 - xAxisPadding / 20)
		.attr("height", barHeight - (xAxisPadding / 25))
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount;
					curSessionCount += numSessions;
					return toReturn;
				})
		.attr("fill", "Pink")
		.attr("initFill", "Pink")
		.attr("stroke", "black")
		.attr("initStroke", "black")
		.attr("stroke-width", "0")
		.attr("initStrokeWidth", "0")
		.attr("z", 2)
		.classed("clickableBar", true)
		.attr("id", function(d, i)
				{
					if(autoDownload)
					{
						downloadUser(userOrderMap[d]);
					}
					
					return("downloadbuttonuser_" + SHA256(userOrderMap[d]));
				})
		.on("click", function(d, i)
				{
					downloadUser(userOrderMap[d]);
				});

		var downloadLabelsUser = svg.append("g")
		.selectAll("text")
		.data(userOrderArray)
		.enter()
		.append("text")
		.attr("x", visWidth - (xAxisPadding / 2 - xAxisPadding / 20) + xAxisPadding / 4 - xAxisPadding / 40 - (barHeight - (xAxisPadding / 25)) * 2)
		.attr("width", xAxisPadding / 2)
		.attr("height", barHeight - 2 * (xAxisPadding / 25))
		.attr("y", function(d, i)
				{
					if(i == 0)
					{
						curSessionCount = 0;
					}
					numSessions = Object.keys(theNormData[userOrderMap[d]]["Session Ordering"]["Order List"]).length;
					toReturn = barHeight * i + barHeight * 2 * curSessionCount + barHeight / 2 - (xAxisPadding / 50);
					curSessionCount += numSessions;
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("z", 2)
		.attr("font-weight", "bolder")
		.attr("font-family", "monospace")
		.attr("alignment-baseline", "central")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.text("Download")
		.attr("initText", "Filter")
		.style("pointer-events", "none")
		.attr("id", function(d, i)
				{
					return("filterbuttonuser_label_" + SHA256(userOrderMap[d]));
				})
		.classed("clickableBar", true);
		
		var windowTimeline;
		var sessionList = [];
		var foregroundRects = svg.append("g")
		.selectAll("rect")
		.data(function()
				{
					var toReturn = [];
					var userNum = 0;
					var sessionNum = 0;
					for(var x of userOrderArray)
					{
						var theUser = userOrderMap[x];
						var userSessionOrdering = theNormData[theUser]["Session Ordering"]
						var userSessionList = userSessionOrdering["Order List"];
						for(var y in userSessionList)
						{
							var curSession = userSessionOrdering[userSessionList[y]];
							var userSession = {}
							userSession["User"] = theUser;
							userSession["User Number"] = userNum;
							userSession["Session"] = curSession;
							sessionList.push(userSession);
							var windowList = theNormData[theUser][curSession]["windows"];
							var firstEntry = true;
							for(var z in windowList)
							{
								windowList[z]["User Order"] = userNum;
								windowList[z]["Session Order"] = sessionNum;
								windowList[z]["Owning User"] = theUser;
								windowList[z]["Owning Session"] = curSession;
								if(!firstEntry)
								{
									toReturn[toReturn.length - 1]["End MS Universal"] = windowList[z]["Index MS Universal"];
									toReturn[toReturn.length - 1]["End MS User"] = windowList[z]["Index MS User"];
									toReturn[toReturn.length - 1]["End MS Session"] = windowList[z]["Index MS Session"];
									toReturn[toReturn.length - 1]["Next"] = windowList[z];
								}
								firstEntry = false;
								if(timeMode == "Session")
								{
									windowList[z]["Time Scale Session"] = theNormData[theUser][curSession]["Time Scale"];
								}
								else if(timeMode == "User")
								{
									windowList[z]["Time Scale User"] = theNormData[theUser]["Time Scale"];
								}
								else if(timeMode == "Universal")
								{
									windowList[z]["Time Scale Universal"] = theNormData["Time Scale"];
								}
								toReturn.push(windowList[z]);
								if(!(theUser in lookupTable))
								{
									lookupTable[theUser] = {};
								}
								if(!(curSession in lookupTable[theUser]))
								{
									lookupTable[theUser][curSession] = {};
									lookupTable[theUser][curSession]["Windows"] = {};
								}
								if(!("Windows" in lookupTable[theUser][curSession]))
								{
									lookupTable[theUser][curSession]["Windows"] = {};
								}
								lookupTable[theUser][curSession]["Windows"][windowList[z]["Index MS"]] = windowList[z];
							}
							toReturn[toReturn.length - 1]["End MS Session"] = theNormData[theUser][curSession]["Index MS Session Max"];
							toReturn[toReturn.length - 1]["End MS User"] = theNormData[theUser][curSession]["Index MS Session Max"] + theNormData[theUser][curSession]["Index MS User Session Min"];
							toReturn[toReturn.length - 1]["End MS Universal"] = theNormData[theUser][curSession]["Index MS Session Max"] + theNormData[theUser][curSession]["Index MS User Session Min"] + theNormData[theUser]["Index MS Universal Min"];							sessionNum++;
						}
						userNum++;
					}
					windowTimeline = toReturn;
					return toReturn;
				})
		.enter()
		.append("rect")
		.attr("x", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["Index MS Session"]) + xAxisPadding;
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["Index MS User"]) + xAxisPadding;
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["Index MS Universal"]) + xAxisPadding;
					}
					return 0;
				})
		.attr("width", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["End MS Session"] - d["Index MS Session"]);
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["End MS User"] - d["Index MS User"]);
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["End MS Universal"] - d["Index MS Universal"]);
					}
					return timeScale(d["End Time MS"] - d["Start Time MS"]) -1;
				})
		.attr("y", function(d, i)
				{
					
					return d["Session Order"] * barHeight * 2 + d["User Order"] * barHeight + barHeight;
				})
		.attr("height", barHeight)
		.attr("stroke", "black")
		.attr("stroke-width", xAxisPadding / 100)
		.attr("fill", function(d, i)
				{
					return colorScale(windowColorNumber[d["FirstClass"]]);
				})
		.attr("initFill", function(d, i)
				{
					return colorScale(windowColorNumber[d["FirstClass"]]);
				})
		.attr("opacity", 1)
		.on("click", function(d, i)
				{
					var backgroundRect = d3.select("#background_rect_" + SHA256(d["Owning User"] + d["Owning Session"]));
					if(!sessionStroke || sessionStroke.node() != backgroundRect.node())
					{
						var e = document.createEvent('UIEvents');
						e.initUIEvent('click', true, true, /* ... */);
						backgroundRect.node().dispatchEvent(e);
					}
					
					if(curStroke)
					{
						d3.select(curStroke).attr("stroke", "black").attr("stroke-width", d3.select(curStroke).attr("initStrokeWidth"));d3.select(curStroke).attr("stroke", "black").attr("stroke", d3.select(curStroke).attr("initStroke"));
					}
					if(curStroke == this)
					{
						if(sessionStroke)
						{
							sessionStroke.attr("stroke", "black").attr("stroke-width", sessionStroke.attr("initStrokeWidth"));sessionStroke.attr("stroke", "black").attr("stroke", sessionStroke.attr("initStroke"));
						}
						clearWindow(); curStroke = null; sessionStroke = null;
						showDefault();
						return;
					}
					
					d3.select(this).attr("initStrokeWidth", d3.select(this).attr("stroke-width"));d3.select(this).attr("initStroke", d3.select(this).attr("stroke"));
					d3.select(this).attr("stroke", "#ffff00").attr("stroke-width", xAxisPadding / 50);
					curStroke = this;
					showWindow(d["Owning User"], d["Owning Session"], "Windows", d["Index MS"]);
				})
		.attr("class", function(d)
			{
				processToWindow[SHA256(d["User"] + d["Start"] + d["PID"])] = SHA256(d["FirstClass"]);
				if(!(SHA256(d["FirstClass"]) in windowToProcess))
				{
					windowToProcess[SHA256(d["FirstClass"])] = [];
				}
				windowToProcess[SHA256(d["FirstClass"])].push(SHA256(d["User"] + d["Start"] + d["PID"]));
				return "clickableBar " + "select_" + SHA256(d["FirstClass"]) + " " + "window_process_" + SHA256(d["User"] + d["Start"] + d["PID"]);
			})
		
		.attr("z", 2);
		
		var foregroundTextG = svg.append("g");

		
		var eventTimeline;
		var eventTypeNumbers = {};
		var eventTypeArray = [];
		var taskRects = svg.append("g")
		.selectAll("rect")
		.data(function()
				{
					function binarySearchArray(items, value){
						var firstIndex  = 0,
							lastIndex   = items.length - 1,
							middleIndex = Math.floor((lastIndex + firstIndex)/2);
		
						while(items[middleIndex] != value && firstIndex < lastIndex)
						{
						   if (value < items[middleIndex])
							{
								lastIndex = middleIndex - 1;
							} 
						  else if (value > items[middleIndex])
							{
								firstIndex = middleIndex + 1;
							}
							middleIndex = Math.floor((lastIndex + firstIndex)/2);
						}
		
					 return middleIndex;
					}
					var toReturn = [];
					var userNum = 0;
					var sessionNum = 0;
					for(var x of userOrderArray)
					{
						var theUser = userOrderMap[x];
						var userSessionOrdering = theNormData[theUser]["Session Ordering"]
						var userSessionList = userSessionOrdering["Order List"];
						for(var y in userSessionList)
						{
							var openSpots = [];
							openSpots.push(0);
							
							var maxNumActive = 1;
							var curSession = userSessionOrdering[userSessionList[y]];
							var userSession = {}
							userSession["User"] = theUser;
							userSession["User Number"] = userNum;
							userSession["Session"] = curSession;
							
							//sessionList.push(userSession);
							var eventsList = theNormData[theUser][curSession]["events"];

							var curActiveMap = {};
							var curSessionList = [];
							
							for(var z in eventsList)
							{
								if(timeMode == "Session")
								{
									eventsList[z]["Time Scale Session"] = theNormData[theUser][curSession]["Time Scale"];
								}
								else if(timeMode == "User")
								{
									eventsList[z]["Time Scale User"] = theNormData[theUser]["Time Scale"];
								}
								else if(timeMode == "Universal")
								{
									eventsList[z]["Time Scale Universal"] = theNormData["Time Scale"];
								}
								eventsList[z]["User Order"] = userNum;
								eventsList[z]["Session Order"] = sessionNum;
								
								if(!(eventsList[z]["Source"] in eventTypeNumbers))
								{
									var eventType = {};
									eventType["Source"] = eventsList[z]["Source"];
									eventType["Number"] = Object.keys(eventTypeNumbers).length % 8;
									eventTypeNumbers[eventType["Source"]] = eventType;
									eventTypeArray.push(eventType);
								}
								
								if(eventsList[z]["Description"] == "start" || !(eventsList[z]["TaskName"] in curActiveMap))
								{
									//var placeholder = {};
									//placeholder["Index MS Session"] = theNormData[theUser][curSession]["Index MS Session Max"];
									//placeholder["Index MS User"] = theNormData[theUser]["Index MS User Max"];
									
									//eventsList[z]["Next"] = placeholder;
									//if(openSpots.length == 0)
									//{
									//	eventsList[z]["Active Row"] = Object.keys(curActiveMap).length;
									//}
									//else
									//{
									if(eventsList[z]["Description"] == "start")
									{
									}
									if(openSpots.length == 0)
									{
										openSpots.push(Object.keys(curActiveMap).length)
										if(Object.keys(curActiveMap).length + 1 > maxNumActive)
										{
											maxNumActive = Object.keys(curActiveMap).length + 1;
										}
									}
									eventsList[z]["Active Row"] = openSpots.shift();
									//}
									if(!(eventsList[z]["Description"] == "start"))
									{
										//maxNumActive++;
										//eventsList[z]["Active Row"] = maxNumActive;
										var cloned = JSON.parse(JSON.stringify(eventsList[z]));
										cloned["Time Scale Session"] = eventsList[z]["Time Scale Session"];
										cloned["Description"] = "Default";
										cloned["Next"] = eventsList[z];
										if(!(cloned["Description"] in eventTypeNumbers))
										{
											var eventType = {};
											eventType["Description"] = cloned["Description"];
											eventType["Number"] = Object.keys(eventTypeNumbers).length % 8;
											eventTypeNumbers[eventType["Description"]] = eventType;
											eventTypeArray.push(eventType);
										}
										toReturn.push(cloned);
										
										if(!(theUser in lookupTable))
										{
											lookupTable[theUser] = {};
										}
										if(!(curSession in lookupTable[theUser]))
										{
											lookupTable[theUser][curSession] = {};
											lookupTable[theUser][curSession]["Events"] = {};
										}
										if(!("Events" in lookupTable[theUser][curSession]))
										{
											lookupTable[theUser][curSession]["Events"] = {};
										}
										cloned["Owning User"] = theUser;
										cloned["Owning Session"] = curSession;
										lookupTable[theUser][curSession]["Events"][cloned["Index MS"]] = cloned;
										
										curSessionList.unshift(cloned);
									}
									if(!(eventsList[z]["Description"] == "end"))
									{
										curActiveMap[eventsList[z]["TaskName"]] = eventsList[z];
									}
									//if(Object.keys(curActiveMap).length > maxNumActive)
									//{
									//	maxNumActive = Object.keys(curActiveMap).length;
									//}
								}
								else
								{
									eventsList[z]["Active Row"] = curActiveMap[eventsList[z]["TaskName"]]["Active Row"];
									curActiveMap[eventsList[z]["TaskName"]]["Next"] = eventsList[z];
									curActiveMap[eventsList[z]["TaskName"]] = eventsList[z];
									if(eventsList[z]["Description"] == "end")
									{
										delete curActiveMap[eventsList[z]["TaskName"]];
										openRow = eventsList[z]["Active Row"];
										if(openSpots.length == 0)
										{
											openSpots.push(openRow);
										}
										else
										{
											closestVal = binarySearchArray(openSpots, openRow)
											if(openSpots[closestVal] > openRow)
											{
												openSpots.splice(closestVal - 1, 0, openRow);
											}
											else
											{
												openSpots.splice(closestVal, 0, openRow);
											}
										}
									}
								}
								
								if(eventsList[z]["Description"] != "end")
								{
									toReturn.push(eventsList[z]);
									
									if(!(theUser in lookupTable))
									{
										lookupTable[theUser] = {};
									}
									if(!(curSession in lookupTable[theUser]))
									{
										lookupTable[theUser][curSession] = {};
										lookupTable[theUser][curSession]["Events"] = {};
									}
									if(!("Events" in lookupTable[theUser][curSession]))
									{
										lookupTable[theUser][curSession]["Events"] = {};
									}
									eventsList[z]["Owning User"] = theUser;
									eventsList[z]["Owning Session"] = curSession;
									lookupTable[theUser][curSession]["Events"][eventsList[z]["Index MS"]] = eventsList[z];
									
									curSessionList.push(eventsList[z]);
								}
							}
							for(z in curSessionList)
							{
								curSessionList[z]["Max Active"] = maxNumActive;
								if(!("Next" in curSessionList[z]))
								{
									var cloned = JSON.parse(JSON.stringify(curSessionList[z]));
									cloned["Description"] = "Default";
									cloned["Index MS Session"] = theNormData[theUser][curSession]["Index MS Session Max"];
									cloned["Index MS User"] = theNormData[theUser][curSession]["Index MS Session Max"] + theNormData[theUser][curSession]["Index MS User Session Min"];
									cloned["Index MS Universal"] = theNormData[theUser][curSession]["Index MS Session Max"] + theNormData[theUser][curSession]["Index MS User Session Min"] + theNormData[theUser]["Index MS Universal Min"];
									curSessionList[z]["Next"] = cloned;
								}
							}
							sessionNum++;
						}
						userNum++;
					}
					eventTimeline = toReturn;
					return toReturn;
				})
		.enter()
		.append("rect")
		.attr("x", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["Index MS Session"]) + xAxisPadding;
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["Index MS User"]) + xAxisPadding;
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["Index MS Universal"]) + xAxisPadding;
					}
					return 0;
				})
		.attr("width", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["Next"]["Index MS Session"] - d["Index MS Session"]);
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["Next"]["Index MS User"] - d["Index MS User"]);
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["Next"]["Index MS Universal"] - d["Index MS Universal"]);
					}
					return timeScale(d["End Time MS"] - d["Start Time MS"]) -1;
				})
		.attr("y", function(d, i)
				{
					var totalHeight =  (barHeight - xAxisPadding / 25) / d["Max Active"];
					return d["Session Order"] * barHeight * 2 + d["User Order"] * barHeight + barHeight * 2 + d["Active Row"] * totalHeight;
				})
		.attr("height", function(d, i)
				{
					var totalHeight =  (barHeight - xAxisPadding / 25) / d["Max Active"];
					return totalHeight;
				})
		.attr("stroke", "black")
		.attr("stroke-width", xAxisPadding / 100)
		.attr("fill", function(d, i)
				{
					return colorScaleAccent(eventTypeNumbers[d["Source"]]["Number"]);
				})
		.attr("opacity", 1)
		.on("click", function(d, i)
				{
					var backgroundRect = d3.select("#background_rect_" + SHA256(d["Owning User"] + d["Owning Session"]));
					if(!sessionStroke || sessionStroke.node() != backgroundRect.node())
					{
						var e = document.createEvent('UIEvents');
						e.initUIEvent('click', true, true, /* ... */);
						backgroundRect.node().dispatchEvent(e);
					}
					
					if(curStroke)
					{
						d3.select(curStroke).attr("stroke", "black").attr("stroke-width", d3.select(curStroke).attr("initStrokeWidth"));d3.select(curStroke).attr("stroke", "black").attr("stroke", d3.select(curStroke).attr("initStroke"));
					}
					if(curStroke == this)
					{
						clearWindow(); curStroke = null;
						showDefault();
						return;
					}
					d3.select(this).attr("initStrokeWidth", d3.select(this).attr("stroke-width"));d3.select(this).attr("initStroke", d3.select(this).attr("stroke"));
					d3.select(this).attr("stroke", "#ffff00").attr("stroke-width", xAxisPadding / 50);
					curStroke = this;
					showWindow(d["Owning User"], d["Owning Session"], "Events", d["Index MS"]);
				})
		.classed("clickableBar", true)
		.attr("z", 3);
		
		var taskText = svg.append("g")
		.selectAll("text")
		.data(eventTimeline)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		.attr("x", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["Index MS Session"]) + xAxisPadding;
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["Index MS User"]) + xAxisPadding;
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["Index MS Universal"]) + xAxisPadding;
					}
					return 0;
				})
		.attr("y", function(d, i)
				{
					var totalHeight =  (barHeight - xAxisPadding / 25) / d["Max Active"];
					//totalHeight = totalHeight * 2;
					return d["Session Order"] * barHeight * 2 + d["User Order"] * barHeight + barHeight * 2 + d["Active Row"] * totalHeight + (totalHeight * .5) + xAxisPadding / 100;
				})
		.attr("dominant-baseline", "middle")
		.style("font-size", function(d, i)
				{
					var totalWidth = 0;
					if(timeMode == "Session")
					{
						totalWidth = .75 * (d["Time Scale Session"](d["Next"]["Index MS Session"] - d["Index MS Session"]));
					}
					else if(timeMode == "User")
					{
						totalWidth = .75 * (d["Time Scale User"](d["Next"]["Index MS User"] - d["Index MS User"]));
					}
					else if(timeMode == "Universal")
					{
						totalWidth = .75 * (d["Time Scale Universal"](d["Next"]["Index MS Universal"] - d["Index MS Universal"]));
					}
					else
					{
						totalWidth = .75 *  (timeScale(d["End Time MS"] - d["Start Time MS"]) -1);
					}
					var totalHeight =  (barHeight - xAxisPadding / 25) / d["Max Active"];
					if(totalHeight < totalWidth)
					{
						return totalHeight;
					}
					return totalWidth;
				})
		.text(function(d, i)
				{
					return d["TaskName"];
				});
		
		var sessionLabelFontSize = (barHeight - xAxisPadding / 25) / 5;
		var sessionLabelFontWidth = sessionLabelFontSize *.6;
		//var sessionList;
		var sessionBarG = svg.append("g")
		var sessionBars = sessionBarG
		.selectAll("rect")
		.data(sessionList)
		.enter()
		.append("rect")
		.attr("x", "0")
		.attr("width", visWidth)
		.attr("height", xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * i;
					toReturn -= (xAxisPadding / 25);
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("z", 3);
		
		var sessionBackgroundBars = svg.append("g").lower()
		.selectAll("rect")
		.data(sessionList)
		.enter()
		.append("rect")
		.attr("x", "0")
		.attr("width", visWidth)
		.attr("height", barHeight * 2 - xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * i;
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("fill-opacity", function(d, i)
				{
					if(i % 2 == 0)
					{
						return ".2";
					}
					return "0";
				})
		.attr("stroke-opacity", ".75")
		.attr("z", 0)
		.attr("stroke", "black")
		.attr("stroke-width", xAxisPadding / 100)
		.classed("clickableBarHelp", true)
		.attr("id", function(d, i)
				{
					return "background_rect_" + SHA256(d["User"] + d["Session"]);
				})
		.on("click", function(d, i)
				{
					
					if(curStroke)
					{
						d3.select(curStroke).attr("stroke", "black").attr("stroke-width", d3.select(curStroke).attr("initStrokeWidth"));d3.select(curStroke).attr("stroke", "black").attr("stroke", d3.select(curStroke).attr("initStroke"));
					}
					if(sessionStroke)
					{
						sessionStroke.attr("stroke", "black").attr("stroke-width", sessionStroke.attr("initStrokeWidth"));sessionStroke.attr("stroke", "black").attr("stroke", sessionStroke.attr("initStroke"));
					}
					if(sessionStroke && sessionStroke.node() == d3.select(this).node())
					{
						clearWindow(); curStroke = null; sessionStroke = null;
						showDefault();
						return;
					}
					d3.select(this).attr("initStrokeWidth", d3.select(this).attr("stroke-width"));d3.select(this).attr("initStroke", d3.select(this).attr("stroke"));
					d3.select(this).attr("stroke", "#ff0000").attr("stroke-width", xAxisPadding / 50);
					sessionStroke = d3.select(this);
					showSession(d["User"], d["Session"]);
				});
		
		var playButtons = svg.append("g")
		.selectAll("rect")
		.data(sessionList)
		.enter()
		.append("rect")
		.attr("x", xAxisPadding / 2)
		.attr("width", xAxisPadding / 2 - xAxisPadding / 20)
		.attr("height", barHeight - 2 * (xAxisPadding / 25) - (xAxisPadding / 50))
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * i + barHeight + (xAxisPadding / 25) + (xAxisPadding / 50);
					return toReturn;
				})
		.attr("fill", "Chartreuse")
		.attr("initFill", "Chartreuse")
		.attr("stroke", "black")
		.attr("initStroke", "black")
		.attr("stroke-width", "0")
		.attr("initStrokeWidth", "0")
		.attr("z", 2)
		.classed("clickableBar", true)
		.attr("id", function(d, i)
				{
					return("playbutton_" + SHA256(d["User"] + d["Session"]));
				})
		.on("click", function(d, i)
				{
					if(curStroke)
					{
						d3.select(curStroke).attr("stroke", "black").attr("stroke-width", d3.select(curStroke).attr("initStrokeWidth"));d3.select(curStroke).attr("stroke", "black").attr("stroke", d3.select(curStroke).attr("initStroke"));
					}
					if(curStroke == this)
					{
						clearWindow(); curStroke = null;
						showDefault();
						return;
					}
					//d3.select(this).attr("initStrokeWidth", d3.select(this).attr("stroke-width"));d3.select(this).attr("initStroke", d3.select(this).attr("stroke"));
					//d3.select(this).attr("stroke", "#ff0000").attr("stroke-width", xAxisPadding / 50);
					//curStroke = this;
					showSession(d["User"], d["Session"]);
					
					//curPlayButton = d3.select(("#playbutton_" + SHA256(d["User"] + d["Session"]))).attr("fill", "red");
					//curPlayLabel = d3.select(("#playbutton_label_" + SHA256(d["User"] + d["Session"]))).text("Pause");
					playAnimation(d["User"], d["Session"]);
				});
		
		var filterButtons = svg.append("g")
		.selectAll("rect")
		.data(sessionList)
		.enter()
		.append("rect")
		.attr("x", 0)
		.attr("width", xAxisPadding / 2 - xAxisPadding / 20)
		.attr("height", barHeight - 2 * (xAxisPadding / 25) - (xAxisPadding / 50))
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * i + barHeight + (xAxisPadding / 25) + (xAxisPadding / 50);
					return toReturn;
				})
		.attr("fill", "Crimson")
		.attr("initFill", "Crimson")
		.attr("stroke", "black")
		.attr("initStroke", "black")
		.attr("stroke-width", "0")
		.attr("initStrokeWidth", "0")
		.attr("z", 2)
		.classed("clickableBar", true)
		.attr("id", function(d, i)
				{
					return("filterbutton_" + SHA256(d["User"] + d["Session"]));
				})
		.on("click", function(d, i)
				{
					addFilterDirect(1, "", "!= '" + d["Session"] + "'");
				});
		
		var playLabels = svg.append("g")
		.selectAll("text")
		.data(sessionList)
		.enter()
		.append("text")
		.attr("x", 3 * xAxisPadding / 4 - xAxisPadding / 40)
		.attr("width", xAxisPadding / 2)
		.attr("height", barHeight - 2 * (xAxisPadding / 25))
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * i + (1.5 * barHeight) + (xAxisPadding / 50);
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("z", 2)
		.attr("font-weight", "bolder")
		.attr("font-family", "monospace")
		.attr("alignment-baseline", "central")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.text("Play")
		.attr("initText", "Play")
		.style("pointer-events", "none")
		.attr("id", function(d, i)
				{
					return("playbutton_label_" + SHA256(d["User"] + d["Session"]));
				})
		.classed("clickableBar", true);
		
		var filterLabels = svg.append("g")
		.selectAll("text")
		.data(sessionList)
		.enter()
		.append("text")
		.attr("x", xAxisPadding / 4 - xAxisPadding / 40)
		.attr("width", xAxisPadding / 2)
		.attr("height", barHeight - 2 * (xAxisPadding / 25))
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * i + (1.5 * barHeight) + (xAxisPadding / 50);
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("z", 2)
		.attr("font-weight", "bolder")
		.attr("font-family", "monospace")
		.attr("alignment-baseline", "central")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.text("Filter")
		.attr("initText", "Filter")
		.style("pointer-events", "none")
		.attr("id", function(d, i)
				{
					return("filterbutton_label_" + SHA256(d["User"] + d["Session"]));
				})
		.classed("clickableBar", true);
		
		var screenshotTimeline;
		var sessionList = [];
		var screenshotRects = svg.append("g")
		.selectAll("rect")
		.data(function()
				{
					var toReturn = [];
					var userNum = 0;
					var sessionNum = 0;
					for(var x of userOrderArray)
					{
						var theUser = userOrderMap[x];
						var userSessionOrdering = theNormData[theUser]["Session Ordering"]
						var userSessionList = userSessionOrdering["Order List"];
						for(var y in userSessionList)
						{
							var curSession = userSessionOrdering[userSessionList[y]];
							var userSession = {}
							userSession["User"] = theUser;
							userSession["User Number"] = userNum;
							userSession["Session"] = curSession;
							sessionList.push(userSession);
							var windowList = theNormData[theUser][curSession]["screenshots"];
							var firstEntry = true;
							for(var z in windowList)
							{
								windowList[z]["User Order"] = userNum;
								windowList[z]["Session Order"] = sessionNum;
								windowList[z]["Owning User"] = theUser;
								windowList[z]["Owning Session"] = curSession;
								if(!firstEntry)
								{
									toReturn[toReturn.length - 1]["End MS Universal"] = windowList[z]["Index MS Universal"];
									toReturn[toReturn.length - 1]["End MS User"] = windowList[z]["Index MS User"];
									toReturn[toReturn.length - 1]["End MS Session"] = windowList[z]["Index MS Session"];
									toReturn[toReturn.length - 1]["Next"] = windowList[z];
								}
								firstEntry = false;
								if(timeMode == "Session")
								{
									windowList[z]["Time Scale Session"] = theNormData[theUser][curSession]["Time Scale"];
								}
								else if(timeMode == "User")
								{
									windowList[z]["Time Scale User"] = theNormData[theUser]["Time Scale"];
								}
								else if(timeMode == "Universal")
								{
									windowList[z]["Time Scale Universal"] = theNormData["Time Scale"];
								}
								toReturn.push(windowList[z]);
								if(!(theUser in lookupTable))
								{
									lookupTable[theUser] = {};
								}
								if(!(curSession in lookupTable[theUser]))
								{
									lookupTable[theUser][curSession] = {};
									lookupTable[theUser][curSession]["Screenshots"] = {};
								}
								if(!("Screenshots" in lookupTable[theUser][curSession]))
								{
									lookupTable[theUser][curSession]["Screenshots"] = {};
								}
								lookupTable[theUser][curSession]["Screenshots"][windowList[z]["Index MS"]] = windowList[z];
							}
							toReturn[toReturn.length - 1]["End MS Session"] = theNormData[theUser][curSession]["Index MS Session Max"];
							toReturn[toReturn.length - 1]["End MS User"] = theNormData[theUser][curSession]["Index MS Session Max"] + theNormData[theUser][curSession]["Index MS User Session Min"];
							toReturn[toReturn.length - 1]["End MS Universal"] = theNormData[theUser][curSession]["Index MS Session Max"] + theNormData[theUser][curSession]["Index MS User Session Min"] + theNormData[theUser]["Index MS Universal Min"];
							sessionNum++;
						}
						userNum++;
					}
					screenshotTimeline = toReturn;
					return toReturn;
				})
		.enter()
		.append("rect")
		.attr("x", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["Index MS Session"]) + xAxisPadding;
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["Index MS User"]) + xAxisPadding;
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["Index MS Universal"]) + xAxisPadding;
					}
					return 0;
				})
		.attr("width", function(d, i)
				{
					if(timeMode == "Session")
					{
						return d["Time Scale Session"](d["End MS Session"] - d["Index MS Session"]);
					}
					else if(timeMode == "User")
					{
						return d["Time Scale User"](d["End MS User"] - d["Index MS User"]);
					}
					else if(timeMode == "Universal")
					{
						return d["Time Scale Universal"](d["End MS Universal"] - d["Index MS Universal"]);
					}
					return timeScale(d["End Time MS"] - d["Start Time MS"]) -1;
				})
		.attr("y", function(d, i)
				{
					
					return d["Session Order"] * barHeight * 2 + d["User Order"] * barHeight + barHeight + barHeight / 2;
				})
		.attr("height", barHeight / 2)
		.attr("stroke", "black")
		.attr("stroke-width", xAxisPadding / 100)
		.attr("fill", function(d, i)
				{
					return colorScale(i % 20);
				})
		.attr("initFill", function(d, i)
				{
					return colorScale(i % 20);
				})
		.attr("id", function(d, i)
				{
					return "screenshot_" + d["Hash"];
				})
		.attr("opacity", .9);

		//Tick for animation
		timelineTick = svg.append("rect").style("pointer-events", "none");
		timelineText = svg.append("text")
			.style("fill", "Crimson")
			.style("pointer-events", "none")
			.style("font-size", barHeight / 4)
			.style("dominant-baseline", "hanging");
		
		var axisBars = svg.append("g")
		.selectAll("rect")
		.data(sessionList)
		.enter()
		.append("rect")
		.style("cursor", "pointer")
		.attr("x", xAxisPadding)
		.attr("width", visWidth - xAxisPadding)
		.attr("height", barHeight / 2)
		.attr("y", function(d, i)
				{
					if(!(d["User"] in userSessionAxisY))
					{
						userSessionAxisY[d["User"]] = {}
					}
					if(!(d["Session"] in userSessionAxisY[d["User"]]))
					{
						userSessionAxisY[d["User"]][d["Session"]] = {};
					}
					toReturn = d["User Number"] * barHeight;
					toReturn += barHeight * 2 * i;
					toReturn -= barHeight / 2;
					toReturn += barHeight * 2;
					
					userSessionAxisY[d["User"]][d["Session"]]["y"] = toReturn;
					
					return toReturn;
				})
		.attr("fill", "#FFF")
		.attr("opacity", ".75")
		.attr("z", 2)
		.on("click", async function(d, i)
				{
					var curX = d3.mouse(this)[0];
					var curY = d3.mouse(this)[1];
					scale = d3.scaleLinear();
					scale.range([0, maxSession / 60000]);
					scale.domain([xAxisPadding, visWidth]);
					var seekTo = scale(curX) * 60000
					playAnimation(d["User"], d["Session"], seekTo);
				})
		.on("mousemove", async function(d, i)
				{
					var curX = d3.mouse(this)[0];
					var curY = d3.mouse(this)[1];
					timelineTick.attr("x", curX)
								.attr("y", function()
										{
											return userSessionAxisY[d["User"]][d["Session"]]["y"];
										})
								.attr("height", barHeight / 4)
								.attr("width",  xAxisPadding / 50);
					timelineTick.raise();
					timelineText.attr("x", curX + xAxisPadding / 50)
							.attr("y", function()
							{
								return userSessionAxisY[d["User"]][d["Session"]]["y"];
							})
							.text(function()
									{
										userName = d["User"];
										sessionName = d["Session"];
										//var scale = theNormData[userName][sessionName]["Time Scale"];
										maxSession = Number(theNormData[userName][sessionName]["Index MS Session Max"]);
										minSession = theNormData[userName][sessionName]["Index MS Session Min Universal"];
										scale = d3.scaleLinear();
										scale.range([0, maxSession / 60000]);
										scale.domain([xAxisPadding, visWidth]);
										d3.select("#screenshotDiv")
												.selectAll("*")
												.remove();
										async function updateScreenshot()
										{
											d3.select("#screenshotDiv")
												.append("img")
												.attr("width", "100%")
												.attr("src", "data:image/jpg;base64," + (await getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Screenshot"]()))
												//.attr("src", "./getScreenshot.jpg?username=" + userName + "&timestamp=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Index MS"] + "&session=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Original Session"] + "&event=" + eventName)
												.attr("style", "cursor:pointer;")
												.on("click", async function()
														{
															//showLightbox("<tr><td><div width=\"100%\"><img src=\"./getScreenshot.jpg?username=" + userName + "&timestamp=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Index MS"] + "&session=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Original Session"] + "&event=" + eventName + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
															showLightbox("<tr><td><div width=\"100%\"><img src=\""+ "data:image/jpg;base64," + (await getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Screenshot"]()) + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
														});
										}
										updateScreenshot();
										//showLightbox("<tr><td><div width=\"100%\"><img src=\"./getScreenshot.jpg?username=" + userName + "&timestamp=" + getScreenshot(userName, sessionName, screenshotIndex)["Index MS"] + "&session=" + sessionName + "&event=" + eventName + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
										return scale(curX)
									});
					timelineText.raise();
				});
		
		var axisUnits = svg.append("g");
		var minuteLog = axisUnits.selectAll("text")
		.data(sessionList)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		.style("font-size", (barHeight / 8) + "px")
		.style("font-weight", "bolder")
		.attr("font-size", (barHeight / 8) + "px")
		.attr("dominant-baseline", "middle")
		.attr("x", xAxisPadding + xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight;
					toReturn += barHeight * 2 * i;
					toReturn -= barHeight / 16;
					toReturn += barHeight * 2;
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("opacity", "1")
		.text("Minutes")
		.attr("z", 2);
		
		var screenshotLabel = svg.append("g")
		.selectAll("text")
		.data(sessionList)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		.style("font-size", (barHeight / 8) + "px")
		.style("font-weight", "bolder")
		.attr("font-size", (barHeight / 8) + "px")
		.attr("dominant-baseline", "middle")
		.attr("x", xAxisPadding + xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight;
					toReturn += barHeight * 2 * i;
					toReturn -= barHeight / 16;
					toReturn += barHeight * 2;
					toReturn -= barHeight / 4;
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("opacity", "1")
		.text("Screenshots")
		.attr("z", 2);
		
		var windowLabel = svg.append("g")
		.selectAll("text")
		.data(sessionList)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		.style("font-size", (barHeight / 8) + "px")
		.style("font-weight", "bolder")
		.attr("font-size", (barHeight / 8) + "px")
		.attr("dominant-baseline", "middle")
		.attr("x", xAxisPadding + xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight;
					toReturn += barHeight * 2 * i;
					toReturn -= barHeight / 16;
					toReturn += barHeight * 2;
					toReturn -= barHeight / 2;
					return toReturn;
				})
		.attr("fill", "#000")
		.attr("opacity", "1")
		.text("Active Window")
		.attr("z", 2);

		var sessionAxes = svg.append("g")
		.selectAll("g")
		.data(sessionList)
		.enter()
		.append("g")
		.style("font-size", (barHeight / 8) + "px")
		.attr("font-size", (barHeight / 8) + "px")
		.attr("x", xAxisPadding)
		.attr("width", visWidth - xAxisPadding)
		.attr("height", xAxisPadding / 25)
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight;
					toReturn += barHeight * 2 * i;
					//toReturn += barHeight;
					toReturn -= (xAxisPadding / 25);
					return toReturn;
				})
		.attr("fill", "#FFF")
		.attr("z", 2)
		.style("pointer-events", "none")
		.attr("transform", function(d, i)
				{
					toReturn = d["User Number"] * barHeight;
					toReturn += barHeight * 2 * (i + 1);
					return "translate("+ xAxisPadding + ", " + toReturn + ")";
				})
		.each(function(d, i)
				{
					userName = d["User"];
					sessionName = d["Session"];
					//var scale = theNormData[userName][sessionName]["Time Scale"];
					maxSession = Number(theNormData[userName][sessionName]["Index MS Session Max"]);
					scale = d3.scaleLinear();
					scale.domain([0, maxSession / 60000]);
					scale.range([0, visWidth - xAxisPadding]);
					
					axis = d3.axisTop()
						.scale(scale).tickSize(barHeight / 16);
					
					axis(d3.select(this));
					d3.selectAll(this).select("*").style("pointer-events", "none");
				});

		
		
		var sessionLabels = svg.append("g")
		.selectAll("text")
		.data(function()
			{
				var myReturn = [];
				
				var fontWidth = sessionLabelFontWidth;
				var areaWidth = xAxisPadding - xAxisPadding / 25;
				
				sessNum = 0;
				for(sess in sessionList)
				{
					var normEntry = theNormData[sessionList[sess]["User"]][sessionList[sess]["Session"]]
					var minDate = normEntry["Index MS Session Min Date"];
					var maxDate = normEntry["Index MS Session Max Date"];
					var sessionName = sessionList[sess]["Session"];
					
					sessionName += '\n';
					//sessionName += "Fr:"
					//sessionName += '\n';
					sessionName += minDate;
					sessionName += '\nTo\n';
					//sessionName += "To:"
					//sessionName += '\n';
					sessionName += maxDate;
					if(sessionList[sess]["Session"] != "Aggregated")
					{
						sessionName += '\n';
						sessionName += normEntry["environment"][0]["Environment"].substring(0, 20) + "...";
						sessionName += '\n';
						sessionName += 'Up:';
						sessionName += normEntry["environment"][0]["UploadTime"];
					}
					var line = 0;
					var position = 0;
					for(var i = 0; i < sessionName.length; i++)
					{
						if(sessionName[i] == '\n')
						{
							line++;
							position = 0;
							continue;
						}
						var nextEntry = {}
						nextEntry["User Number"] = sessionList[sess]["User Number"]
						nextEntry["Session Number"] = sessNum;
						nextEntry["Char"] = sessionName[i];
						nextEntry["Line"] = line;
						nextEntry["Position"] = position;
						position++;
						if(position * fontWidth + fontWidth > areaWidth)
						{
							line++;
							position = 0;
						}
						myReturn.push(nextEntry);
					}
					sessNum++;
				}
				return myReturn;
			}	
		)
		.enter()
		.append("text")
		.attr("x", function(d, i)
				{
					return d["Position"] * sessionLabelFontWidth;
				})
		.attr("y", function(d, i)
				{
					toReturn = d["User Number"] * barHeight + barHeight;
					toReturn += barHeight * 2 * d["Session Number"];
					toReturn += sessionLabelFontSize/2;
					toReturn += d["Line"] * sessionLabelFontSize;
					return toReturn;
				})
		.attr("width", sessionLabelFontWidth)
		.attr("height", function(d, i)
				{
					return sessionLabelFontSize;
				})
		.attr("stroke", "none")
		.attr("fill", function(d)
				{
					return "#000000";
				})
		.attr("opacity", 1)
		.attr("z", 2)
		.attr("font-weight", "bolder")
		.attr("font-family", "monospace")
		.attr("dominant-baseline", "middle")		
		.text(function(d, i)
				{
					return d["Char"];
				})
		.style("font-size", sessionLabelFontSize + "px");
		
		var eventLegendBaseline = (windowLegend.length + 1) * legendHeight
		var legendTitleEvents = legendSVG.append("text")
		.attr("x", "50%")
		.attr("y", .5 * legendHeight + eventLegendBaseline)
		.attr("alignment-baseline", "central")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.style("pointer-events", "none")
		//.attr("font-weight", "bolder")
		.text("Task Annotation Source:");

		var legendEvents = legendSVG.append("g")
		.selectAll("rect")
		.data(eventTypeArray)
		.enter()
		.append("rect")
		.attr("x", 0)
		.attr("width", "100%")
		//.attr("width", legendWidth)
		.attr("y", function(d, i)
				{
					return legendHeight * (i + 1) + eventLegendBaseline;
				})
		.attr("height", legendHeight)
		.attr("stroke", "none")
		.attr("fill", function(d, i)
				{
					return colorScaleAccent(d["Number"]);
				});

		var legendTextEvents = legendSVG.append("g")
		.selectAll("text")
		.data(eventTypeArray)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		.attr("x", 0)
		.attr("y", function(d, i)
				{
					//return legendHeight * (i + 1);
					//return legendHeight * (i) + legendHeight;
					return legendHeight * (i + 1) + legendHeight * .5 + eventLegendBaseline;
				})
		.attr("height", legendHeight * .75)
		.text(function(d, i)
				{
					return d["Source"];
				})
		.attr("fill", function(d, i)
				{
					return "#000";
				})
		.attr("font-weight", "bolder")
		.attr("dominant-baseline", "middle")
		.attr("stroke", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "none";
					}
					else
					{
						return "none";
					}
				});
		
		var legendFilter = legendSVG.append("g")
			.selectAll("rect")
			.data(eventTypeArray)
			.enter()
			.append("rect")
			.attr("x", "90%")
			.attr("width", "10%")
			//.attr("width", legendWidth)
			.attr("y", function(d, i)
					{
						return legendHeight * (i + 1) + eventLegendBaseline;
					})
			.on("click", function(d, i)
					{
						addFilterDirect(3, "Source", "!= '" + d["Source"] + "'");
					})
			.attr("height", legendHeight)
			.style("cursor", "pointer")
			.attr("stroke", "Black")
			.attr("fill", function(d, i)
					{
						return "Crimson";
					});
		
		var legendFilterText = legendSVG.append("g")
		.selectAll("text")
		.data(eventTypeArray)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		.attr("x", "95%")
		.attr("y", function(d, i)
				{
					//return legendHeight * (i + 1);
					//return legendHeight * (i) + legendHeight;
					return legendHeight * (i + 1) + legendHeight * .5 + eventLegendBaseline;
				})
		.attr("height", legendHeight * .75)
		.text(function(d, i)
				{
					return "X";
				})
		.attr("fill", function(d, i)
				{
					return "#000";
				})
		.attr("font-weight", "bolder")
		.attr("dominant-baseline", "middle")
		.attr("text-anchor", "middle")
		.attr("stroke", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "none";
					}
					else
					{
						return "none";
					}
				});

		sessionBarG.lower();
		backgroundG.lower();
		
		var visTableHeight = d3.select("#mainVisContainer").node().getBoundingClientRect().height;
		
		d3.select("#optionFilterTable").attr("height", getInnerHeight("optionFilterCell") + "px");
		
		d3.select("#legend").select("svg").style("height", (legendHeight * (2 + windowLegend.length + eventTypeArray.length)) + "px");
		//d3.select("#legend").style("height", getInnerHeight("legendCell") + "px");
		refreshingStart = false;
	}
	
	function getInnerHeight(elementID)
	{
		var toReturn = 0;
		toReturn = document.getElementById(elementID).getBoundingClientRect().height;
		toReturn -= parseInt(getComputedStyle(document.getElementById(elementID), null).getPropertyValue('border-top-width'), 10);
		toReturn -= parseInt(getComputedStyle(document.getElementById(elementID), null).getPropertyValue('border-bottom-width'), 10);
		toReturn -= parseInt(getComputedStyle(document.getElementById(elementID), null).getPropertyValue('padding-bottom'), 10);
		toReturn -= parseInt(getComputedStyle(document.getElementById(elementID), null).getPropertyValue('padding-top'), 10)
		return toReturn;
	}

	
	var lastHighlighted;
	
	function highlightItems(className)
	{
		clearWindow();
		lastHighlighted = className;
		d3.selectAll("." + className)
			.attr("initStrokeWidth", function()
					{
						return this.getAttribute("stroke-width")
					})
			.attr("stroke", "#ffff00").attr("stroke-width", xAxisPadding / 50);
	}
	
	function clearWindow()
	{
		if(curPlayButton)
		{
			curPlayButton.attr("fill", curPlayButton.attr("initFill"));
			curPlayLabel.text(curPlayLabel.attr("initText"));
		}
		curPlayButton = null;
		curPlayLabel = null;
		
		for(selection in curSelElements)
		{
			if(curSelElements[selection] && !(curSelElements[selection].empty()) && curSelElements[selection].attr("initFill"))
			{
				curSelElements[selection].attr("fill", function(){ return this.getAttribute("initFill"); });
			}
		}
		curSelElements = [];
		
		if(curSelectProcess && curSelectProcess != null)
		{
			curLabel = d3.select("#process_legend_" + curSelectProcess[0]["Hash"])
			curLabel.attr("fill", curLabel.attr("initFill"));
		}
		curSelectProcess = null;
		
		if(lastHighlighted)
		{
			d3.selectAll("." + lastHighlighted)
			.attr("stroke-width", function()
					{
						return this.getAttribute("initStrokeWidth")
					})
			.attr("stroke", "black");
		}
		lastHighlighted = null;
		d3.select("#extraInfoTable")
			.selectAll("tr")
			.remove();
		d3.select("#infoTable")
			.selectAll("tr")
			.remove();
		d3.select("#screenshotDiv")
			.selectAll("*")
			.remove();
		d3.select("#highlightDiv")
			.selectAll("*")
			.remove();
		d3.select("#highlightDiv").style('overflow-y', 'auto').style("height", "auto")
		d3.select("#extraHighlightDiv")
			.selectAll("*")
			.remove();
		d3.select("#extraHighlightDiv").style('overflow-y', 'auto').style("height", "auto")
		
		for(element in curHighlight)
		{
			curHighlight[element].attr("stroke-width", 0);
		}
		curHighlight = [];
		
		if(theNormDataDone)
		{
			
		}
	}
	
	async function showDefault()
	{
		
		var addTaskRow = d3.select("#infoTable").append("tr").append("td")
		.attr("width", visWidthParent + "px")
		.html("<td><div align=\"center\">Process Occurances in Sessions</div></td>");
	
		var newSVG = d3.select("#infoTable").append("tr").append("td").append("div").style("max-width", visWidthParent + "px").style("overflow-x", "scroll").append("svg")
			.attr("width", ((visWidthParent / 15) * summaryProcStatsArray.length)  + "px")
			.attr("height", bottomVisHeight  + "px")
			.append("g");
		
		var processTooltip = newSVG.append("g")
		.append("text")
		.attr("y", "0px")
		.attr("x", "0px")
		.attr("font-size", xAxisPadding / 10)
		.attr("alignment-baseline", "auto")
		.attr("dominant-baseline", "auto")
		.attr("text-anchor", "left")
		.style("font-weight", "bold")
		.text("");
		
		var barRects = newSVG.append("g").selectAll("rect")
			.data(summaryProcStatsArray)
			.enter()
			.append("rect")
					.attr("x", function(d, i)
							{
								return i * (visWidthParent / 15) + (visWidthParent / 60);
							})
					.attr("width", function(d, i)
							{
								return (visWidthParent / 20);
							})
					.attr("y", function(d, i)
							{
								return bottomVisHeight - d["count"] / summaryProcStats["Max"] * bottomVisHeight + (xAxisPadding / 10);
							})
					.attr("height", function(d, i)
							{
								return d["count"] / summaryProcStats["Max"] * bottomVisHeight - (xAxisPadding / 10);
							})
					.attr("stroke", "none")
					.attr("fill", function(d, i)
							{
								return colorScale(i % 20);
							})
					.on("mouseenter", function(d, i)
					{
						processTooltip.text(d["Command"] + ": " + d["count"])
								.attr("y", (bottomVisHeight - d["count"] / summaryProcStats["Max"] * bottomVisHeight + (xAxisPadding / 10)) + "px")
								.attr("x", i * (visWidthParent / 15) + (visWidthParent / 60) + "px");
					});

		var barLabels = newSVG.append("g").selectAll("text")
		.data(summaryProcStatsArray)
		.enter()
		.append("text")
				.attr("x", function(d, i)
						{
							return i * (visWidthParent / 15) + (visWidthParent / 60) + (visWidthParent / 40);
						})
				.attr("y", function(d, i)
						{
							return bottomVisHeight - d["count"] / summaryProcStats["Max"] * bottomVisHeight + (xAxisPadding / 10) + (bottomVisHeight / 40);
						})
				.text(function(d, i)
						{
							charsAllowed = ((d["count"] / summaryProcStats["Max"] * bottomVisHeight) - ((xAxisPadding / 10) + (bottomVisHeight / 40))) / ((bottomVisHeight) / 40);
							return d["Command"].substring(0, Math.round(charsAllowed));
						})
				.style("font-size", bottomVisHeight / 20)
				.attr("text-anchor", "start")
				.attr("dominant-baseline", "auto")
				.attr("stroke", "none")
				.style("writing-mode", "vertical-lr")
				.attr("fill", function(d, i)
						{
							if(i % 2 == 1)
							{
								return "black";
							}
							return "white";
						});
			
		var barNames = newSVG.append("g").selectAll("text")
		.data(summaryProcStatsArray)
		.enter()
		.append("text")
				.attr("x", function(d, i)
						{
							return i * (visWidthParent / 15) + (visWidthParent / 60) + (visWidthParent / 40);
						})
				.attr("y", function(d, i)
						{
							return bottomVisHeight - (xAxisPadding / 25);
						})
				.text(function(d, i)
						{
							return d["count"];
						})
				.attr("text-anchor", "middle")
				.attr("dominant-baseline", "auto")
				.attr("stroke", "none")
				.attr("fill", function(d, i)
						{
							if(i % 2 == 1)
							{
								return "black";
							}
							return "white";
						});

	}
	
	
	
	var processTooltip;
	var processTooltipRect;
	var lastMouseOver;
	var lastMouseHash;
	
	var curSelectUser = "";
	var curSelectSession = "";
	
	function addTask(userName, sessionName, isUpdate, fromAni)
	{
		var startTask = "";
		var endTask = "";
		var taskName = "";
		var taskTags = "";
		var taskGoal = "";
		if(fromAni)
		{
			startTask = Number(document.getElementById("addTaskAniStart").value) + theNormData[userName][sessionName]["Index MS Session Min Universal"];
			endTask = Number(document.getElementById("addTaskAniEnd").value) + theNormData[userName][sessionName]["Index MS Session Min Universal"];
			taskName = document.getElementById("addTaskAniName").value;
			taskTags = encodeURIComponent(document.getElementById("tagsAni").value);
			taskGoal = document.getElementById("addTaskAniGoal").value;
		}
		else if(isUpdate)
		{
			startTask = Number(document.getElementById("updateTaskStart").value) + theNormData[userName][sessionName]["Index MS Session Min Universal"];
			endTask = Number(document.getElementById("updateTaskEnd").value) + theNormData[userName][sessionName]["Index MS Session Min Universal"];
			taskName = document.getElementById("updateTaskName").value;
			taskTags = encodeURIComponent(document.getElementById("updateTags").value);
			taskGoal = document.getElementById("updateTaskGoal").value;
		}
		else
		{
			startTask = Number(document.getElementById("addTaskStart").value) + theNormData[userName][sessionName]["Index MS Session Min Universal"];
			endTask = Number(document.getElementById("addTaskEnd").value) + theNormData[userName][sessionName]["Index MS Session Min Universal"];
			taskName = document.getElementById("addTaskName").value;
			taskTags = encodeURIComponent(document.getElementById("tags").value);
			taskGoal = document.getElementById("addTaskGoal").value;
		}
		
		var taskUrl = "addTask.json?event=" + eventName + "&userName=" + userName + "&sessionName=" + sessionName + "&start=" + startTask + "&end=" + endTask + "&taskName=" + taskName + "&taskGoal=" + taskGoal + "&taskTags=" + taskTags;
		
		d3.json(taskUrl, function(error, data)
					{
						if(data["result"] == "okay")
						{
							console.log("Added task, now refreshing")
							var curSelect = "&users=" + userName + "&sessions=" + sessionName;
							d3.json("logExport.json?event=" + eventName + "&datasources=events&normalize=none" + curSelect, async function(error, data)
							{
								console.log("Downloaded")
								console.log(data);
								let theNormDataInit = ((await retrieveData("indexdata")).value);
								console.log("Adding to")
								console.log(theNormDataInit);
								
								theNormDataInit[userName][sessionName]["events"] = data[userName][sessionName]["events"];
								try
								{
									var isDone = false;
									while(!isDone)
									{
										isDone = await persistDataAndWait("indexdata", theNormDataInit);
									}
								}
								catch(err)
								{
									console.log(err);
								}
								
								theNormData = preprocess(theNormDataInit);
								console.log("New norm data")
								console.log(theNormData)
								try
								{
									var isDone = false;
									while(!(isDone == true))
									{
										isDone = (await (persistDataAndWait("data", theNormData)));
									}
									if(fromAni)
									{
										document.getElementById("addTaskAniStart").value = "Start (MS Session Time)";
										document.getElementById("addTaskAniEnd").value = "End (MS Session Time)";
										document.getElementById("addTaskAniName").value = "";
										document.getElementById("tagsAni").value = "";
										document.getElementById("addTaskAniGoal").value = "";
									}
									start(true);
								}
								catch(err)
								{
									console.log(err);
								}
								
							});
						}
						
					});
	}
	
	var searchTerms = ["Reverse", "Engineering", "Produces", "Resuls"];
	function filterTags()
	{
		var input = document.getElementById("searchTags");
		var filter = input.value.toUpperCase();
		var selected = document.getElementById("storedTags");
		var items = selected.getElementsByTagName("option");
		for (i = 0; i < items.length; i++)
		{
			var txtValue = items[i].textContent || items[i].innerText;
			if(txtValue.toUpperCase().indexOf(filter) > -1)
			{
				items[i].style.display = "";
			}
			else
			{
				items[i].style.display = "none";
				items[i].selected = false;
			}
		}
	}
	
	function delBlankLines(isAni)
	{
		 var tagEle = document.getElementById('tags');
		 if(isAni)
		 {
			 tagEle = document.getElementById('tagsAni');
		 }
		 var stringArray = tagEle.value.split('\n');
		 var temp = [""];
		 var x = 0;
		 for (var i = 0; i < stringArray.length; i++)
		 {
		   if (stringArray[i].trim() != "")
		   {
		     temp[x] = stringArray[i];
		     x++;
		   }
		 }

		 temp = temp.join('\n');
		 tagEle.value = temp;
	}
	
	function addTag(isAni)
	{
		var tagbox = document.getElementById("tags");
		var selected = document.getElementById("storedTags");
		if(isAni)
		{
			tagbox = document.getElementById("tagsAni");
			selected = document.getElementById("storedTagsAni");
		}
		var items = selected.getElementsByTagName("option");
		for (i = 0; i < items.length; i++)
		{
			if(items[i].selected)
			{
				var txtValue = items[i].textContent || items[i].innerText;
				tagbox.value = tagbox.value + "\n" + txtValue;
			}
		}
		delBlankLines(isAni);
	}

	var selectRect;
	var timeScaleAni;
	
	async function showSession(owningUser, owningSession)
	{
		
		curSelectUser = owningUser;
		curSelectSession = owningSession;
		bottomVizFontSize = bottomVisHeight / 25;
		clearWindow();
		
		curSessionMap = theNormData[owningUser][owningSession];
		
		d3.select("#screenshotDiv")
		.selectAll("*")
		.remove();
		
		screenshotIndex = theNormData[owningUser][owningSession]["screenshots"][0]["Index MS"];
		screenshotSession = theNormData[owningUser][owningSession]["screenshots"][0]["Original Session"];

		d3.select("#screenshotDiv")
		.append("img")
		.attr("width", "100%")
		.attr("src", "data:image/jpg;base64," + (await (theNormData[owningUser][owningSession]["screenshots"][0]["Screenshot"]())))
		//.attr("src", "./getScreenshot.jpg?username=" + owningUser + "&timestamp=" + getScreenshot(owningUser, screenshotSession, screenshotIndex)["Index MS"] + "&session=" + screenshotSession + "&event=" + eventName)
		.attr("style", "cursor:pointer;")
		.on("click", function()
				{
					//showLightbox("<tr><td><div width=\"100%\"><img src=\"./getScreenshot.jpg?username=" + owningUser + "&timestamp=" + getScreenshot(owningUser, screenshotSession, screenshotIndex)["Index MS"] + "&session=" + screenshotSession + "&event=" + eventName + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
					showLightbox("<tr><td><div width=\"100%\"><img src=\"data:image/jpg;base64," + (await (theNormData[owningUser][owningSession]["screenshots"][0]["Screenshot"]())) + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
				});

		curProcessMap = (await processMap[owningUser][owningSession]["data"]()).value;
		
		var timeScale;
		if(timeMode == "Universal")
		{
			timeScale = theNormData["Time Scale"];
		}
		else if(timeMode == "User")
		{
			timeScale = theNormData[owningUser]["Time Scale"];
		}
		else
		{
			timeScale = theNormData[owningUser][owningSession]["Time Scale"];
		}
		
		var addTaskRow = d3.select("#infoTable").append("tr").append("td")
			.attr("width", visWidthParent + "px")
			.html("<td><div id=\"addTaskTitle\" align=\"center\">Add Task</div></td>");
		
		var selectEntries = "";
		for(var x = 0; searchTerms && x < searchTerms.length; x++)
		{
			selectEntries = selectEntries + "<option value=\"" + searchTerms[x] + "\">" + searchTerms[x] + "</option>";
		}
		
		var addTagRow = d3.select("#infoTable").append("tr").append("td")
		.attr("width", visWidthParent + "px")
				.append("table").attr("width", visWidthParent + "px").append("tr").attr("width", visWidthParent + "px")
					.html(	"<td colspan=\"2\" width=\"50%\"><div align=\"center\"><b>Search Tags:</b></div><div align=\"center\"><input type=\"text\" style=\"width:75%\" id=\"searchTags\" name=\"searchTags\" value=\"Search/New\" onkeyup=\"filterTags()\"><button type=\"button\" style=\"width:20%\" onclick=\"addTag()\">Add</button></div>" +
							"<div align=\"center\"><select style=\"width:100%\" name=\"storedTags\" id=\"storedTags\" size=\"3\" multiple>" + selectEntries + "</select></div></td>" +
							"<td colspan=\"2\" width=\"50%\"><div align=\"center\"><b>Task Tags:</b></div><div align=\"center\"><textarea id=\"tags\" name=\"tags\" rows=\"5\" cols=\"50\"></textarea></div></td>");
		
		var addGoalRow = d3.select("#infoTable").append("tr").append("td")
		.attr("width", visWidthParent + "px")
				.append("table").attr("width", visWidthParent + "px").append("tr").attr("width", visWidthParent + "px")
					.html(	"<td colspan=\"4\" width=\"100%\"><div align=\"center\"><b>Task Goal:</b></div><div align=\"center\"><textarea id=\"addTaskGoal\" name=\"addTaskGoal\" rows=\"2\" cols=\"100\"></textarea></div></td>");
		
		var addTaskRow = d3.select("#infoTable").append("tr").append("td")
		.attr("width", visWidthParent + "px")
				.append("table").attr("width", visWidthParent + "px").append("tr").attr("width", visWidthParent + "px")
					.html("<td width=\"25%\"><div align=\"center\"><input type=\"text\" id=\"addTaskStart\" name=\"addTaskStart\" value=\"Start (MS Session Time)\"></div></td>" +
							"<td width=\"25%\"><div align=\"center\"><input type=\"text\" id=\"addTaskEnd\" name=\"addTaskEnd\" value=\"End (MS Session Time)\"></div></td>" +
							"<td width=\"25%\"><div align=\"center\"><input type=\"text\" id=\"addTaskName\" name=\"addTaskName\" value=\"Task Name\"></div></td>" +
							"<td width=\"25%\"><div align=\"center\"><button type=\"button\" onclick=\"addTask('" + owningUser + "', '" + owningSession + "')\">Submit</button></div></td>");
		
		var newAxis = d3.axisTop(timeScale);
		
		var initX = 0;
		
		timeScaleAni = timeScale;
		
		var dragAddTask = d3.drag()
			.on("drag", dragmoveAddTask)
			.on("start", function(d)
					{
						initX = d3.mouse(this)[0];
						if(initX < xAxisPadding)
						{
							initX = xAxisPadding;
						}
						selectRect.attr("x", initX);
						selectRect.attr("width", 0);
						document.getElementById("addTaskStart").value = "Start (MS Session Time)";
						document.getElementById("addTaskEnd").value = "End (MS Session Time)";
					});
		
		function dragmoveAddTask(d)
		{
			//var x = d3.event.x;
			//var y = d3.event.y;
			//console.log(d3.event);
			var x = d3.mouse(this)[0];
			var y = d3.mouse(this)[1];
			var startPoint = 0;
			var endPoint = 0;
			if(x < initX)
			{
				selectRect.attr("x", x);
				selectRect.attr("width", initX - x);
				startPoint = timeScale.invert(x - xAxisPadding);
				endPoint = timeScale.invert(initX - xAxisPadding);
			}
			else
			{
				selectRect.attr("x", initX);
				selectRect.attr("width", x - initX);
				startPoint = timeScale.invert(initX - xAxisPadding);
				endPoint = timeScale.invert(x - xAxisPadding);
			}
			document.getElementById("addTaskStart").value = startPoint;
			document.getElementById("addTaskEnd").value = endPoint;
			
			timelineTick.attr("x", x)
			.attr("y", function()
					{
						return userSessionAxisY[owningUser][owningSession]["y"];
					})
			.attr("height", barHeight / 4)
			.attr("width",  xAxisPadding / 50);
			timelineTick.raise();
			
			timelineText.attr("x", x + xAxisPadding / 50)
			.attr("y", function()
			{
				return userSessionAxisY[owningUser][owningSession]["y"];
			})
			.text(function()
					{
						userName = owningUser;
						sessionName = owningSession;
						//var scale = theNormData[userName][sessionName]["Time Scale"];
						maxSession = Number(theNormData[userName][sessionName]["Index MS Session Max"]);
						minSession = theNormData[userName][sessionName]["Index MS Session Min Universal"];
						scale = d3.scaleLinear();
						scale.range([0, maxSession / 60000]);
						scale.domain([xAxisPadding, visWidth]);
						d3.select("#screenshotDiv")
								.selectAll("*")
								.remove();
						async function updateScreenshot()
						{
							d3.select("#screenshotDiv")
								.append("img")
								.attr("width", "100%")
								.attr("src", "data:image/jpg;base64," + (await getScreenshot(userName, sessionName, (scale(x) * 60000) + minSession)["Screenshot"]()))
								//.attr("src", "./getScreenshot.jpg?username=" + userName + "&timestamp=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Index MS"] + "&session=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Original Session"] + "&event=" + eventName)
								.attr("style", "cursor:pointer;")
								.on("click", async function()
										{
											//showLightbox("<tr><td><div width=\"100%\"><img src=\"./getScreenshot.jpg?username=" + userName + "&timestamp=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Index MS"] + "&session=" + getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Original Session"] + "&event=" + eventName + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
											showLightbox("<tr><td><div width=\"100%\"><img src=\""+ "data:image/jpg;base64," + (await getScreenshot(userName, sessionName, (scale(curX) * 60000) + minSession)["Screenshot"]()) + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
										});
						}
						updateScreenshot();
						//showLightbox("<tr><td><div width=\"100%\"><img src=\"./getScreenshot.jpg?username=" + userName + "&timestamp=" + getScreenshot(userName, sessionName, screenshotIndex)["Index MS"] + "&session=" + sessionName + "&event=" + eventName + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
						return scale(x)
					});
			timelineText.raise();
		}
		
		var axisRow = d3.select("#infoTable").append("tr").append("td")
				.attr("width", visWidthParent)
				.style("max-width", visWidthParent + "px")
				.style("overflow-x", "auto");
		
		var addTaskAxisSVG = axisRow.append("svg")
				.attr("class", "clickableBar")
				.attr("width", visWidth + "px")
				.attr("height", (barHeight / 1.75) + "px")
				.call(dragAddTask);
		
		selectRect = addTaskAxisSVG.append("g")
				.append("rect")
				.attr("x", 0)
				.attr("y", 0)
				.attr("width", 0)
				.attr("height", barHeight / 1.75)
				.attr("fill", "cyan")
				.attr("pointer-events", "none");
		
		var addTableAxis = addTaskAxisSVG.append("g")
				.attr("transform", "translate(" + xAxisPadding + "," + (barHeight / 2) + ")")
				.attr("pointer-events", "none")
				.call(newAxis);
		var addTableAxisLabel = addTaskAxisSVG.append("g")
				.append("text")
				.attr("x", xAxisPadding / 2)
				.attr("y", barHeight / 3.5)
				.attr("text-anchor", "middle")
				.attr("dominant-baseline", "middle")
				.attr("font-size", bottomVizFontSize * 2)
				.text("Select Time:")
				.attr("pointer-events", "none");

		//var newRow = d3.select("#infoTable").append("tr").append("td")
		//	.attr("width", visWidthParent)
		//	.style("max-width", visWidthParent + "px")
		//	.style("overflow-x", "auto");
			
		var newSVG = axisRow.append("svg")
			.attr("width", visWidth + "px")
			.attr("height", bottomVisHeight + "px")
			.attr("id", "processGraphSvg")
			.append("g");

		cpuSortedList = [];
		var maxCPU = 0;
		for(osUser in curProcessMap)
		{
			for(started in curProcessMap[osUser])
			{
				for(pid in curProcessMap[osUser][started])
				{
					curProcList = curProcessMap[osUser][started][pid]
					totalAverage = curProcList[curProcList.length-1]["Aggregate CPU"] / curProcList.length;
					curProcList[0]["Average CPU"] = totalAverage;
					for(entry in curProcList)
					{
						if(curProcList[entry]["CPU"] > maxCPU)
						{
							maxCPU = curProcList[entry]["CPU"];
						}
						curProcList[entry]["Hash"] = SHA256(osUser + started + pid);
					}
					cpuSortedList.push(curProcList);
				}
			}
		}

		cpuSortedList.sort(function(a, b)
		{
			if(a[0]["Average CPU"] > b[0]["Average CPU"]) { return -1; }
			if(a[0]["Average CPU"] < b[0]["Average CPU"]) { return 1; }
			return 0;
		})

		var cpuScale = d3.scaleLinear();
		cpuScale.domain([0, maxCPU]);
		cpuScale.range([bottomVisHeight, 0]);

		
		var finalProcList = [];
		
		var lineFormattedData = []

		for(entry in cpuSortedList)
		{
			for(subEntry in cpuSortedList[entry])
			{
				cpuSortedList[entry][subEntry]["Process Order"] = entry;
			}
			
			name = cpuSortedList[entry][0]["User"] + cpuSortedList[entry][0]["Start"] + cpuSortedList[entry][0]["PID"];
			value = cpuSortedList[entry];
			lineEntry = {};
			lineEntry["name"] = name;
			lineEntry["values"] = value;
			lineFormattedData.push(lineEntry);
			
			finalProcList = finalProcList.concat(cpuSortedList[entry]);
		}
		
		cpuSortedList = cpuSortedList.reverse();
		
		finalProcList = finalProcList.reverse();

		var procPoints = newSVG.selectAll("circle")
			.data(finalProcList)
			.enter()
			.append("circle")
			.attr("cx", function(d, i)
					{
						if(timeMode == "Universal")
						{
							return xAxisPadding +  timeScale(d["Index MS Universal"]);
						}
						else if(timeMode == "User")
						{
							return xAxisPadding + timeScale(d["Index MS User"]);
						}
						else
						{
							return xAxisPadding +  timeScale(d["Index MS Session"]);
						}
					})
			.attr("cy", function(d, i)
					{
						return cpuScale(d["CPU"]);
					})
			.attr("class", function(d, i)
					{
						return "clickableBarPreise process_" + d["Hash"];
					})
			.attr("r", bottomVisHeight / 50)
			.attr("initR", bottomVisHeight / 50)
			//.attr("r", 5)
			.attr("fill", function(d, i)
					{
						return colorScale(d["Process Order"] % 20);
					})
			.attr("initFill", function(d, i)
					{
						return colorScale(d["Process Order"] % 20);
					})
			.on("mouseenter", function(d, i)
					{
							if(lastMouseOver == d)
							{
								return;
							}
							lastMouseOver = d;
						if(document.getElementById("processAutoSelect").checked)
						{
							showWindow(owningUser, owningSession, "Processes", d["Hash"], d["Index MS"]);
						}
						x = 0;
						if(timeMode == "Universal")
						{
							x = xAxisPadding +  timeScale(d["Index MS Universal"]);
						}
						else if(timeMode == "User")
						{
							x = xAxisPadding + timeScale(d["Index MS User"]);
						}
						else
						{
							x = xAxisPadding +  timeScale(d["Index MS Session"]);
						}
						if(cpuScale(d["CPU"]) > bottomVisHeight / 2)
						{
							processTooltipRect.attr("x", x + bottomVisHeight / 50)
									.attr("y", cpuScale(d["CPU"]) - bottomVisHeight / 100);
							processTooltip.attr("x", x + bottomVisHeight / 50)
									.attr("y", cpuScale(d["CPU"]) - bottomVisHeight / 50 - bottomVizFontSize * 6 - ("Arguments" in d) * bottomVizFontSize)
									.attr("alignment-baseline", "auto")
									.attr("dominant-baseline", "auto")
									.text(d["Index"]);
						}
						else
						{
							processTooltipRect.attr("x", x + bottomVisHeight / 50)
									.attr("y", cpuScale(d["CPU"]) + bottomVisHeight / 100);
							processTooltip.attr("x", x + bottomVisHeight / 50)
									.attr("y", cpuScale(d["CPU"]) + bottomVisHeight / 50)
									.attr("alignment-baseline", "hanging")
									.attr("dominant-baseline", "hanging")
									.text(d["Index"]);
						}
						
						processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text(d["Command"]);
						if("Arguments" in d)
						{
							processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text(d["Arguments"].substring(0, 50));
						}
						processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text("User: " + d["User"]);
						processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text("Start: " +d["Start"] + ", Time: " +d["Time"] + ", Stat: " +d["Stat"]);
						processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text("PID: " +d["PID"]);
						processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text("CPU: " +d["CPU"]);
						processTooltip.append("tspan")
									.attr("x", x + bottomVisHeight / 50)
									.attr("dy", bottomVizFontSize)
									.text("Mem: " +d["Mem"] + ", RSS: " + d["RSS"] + ", VSZ: " +d["VSZ"]);
						
						if(cpuScale(d["CPU"]) > bottomVisHeight / 2)
						{
							processTooltipRect.attr("width", processTooltip.node().getBoundingClientRect().width)
									.attr("y", processTooltipRect.attr("y") - processTooltip.node().getBoundingClientRect().height)
									.attr("height", (processTooltip.node().getBoundingClientRect().height));
						}
						else
						{
							processTooltipRect.attr("width", processTooltip.node().getBoundingClientRect().width)
							.attr("height", (processTooltip.node().getBoundingClientRect().height));
						}
						
						if(processTooltipRect.attr("x") > visWidthParent / 2)
						{
							processTooltipRect.attr("x", processTooltipRect.attr("x") - (bottomVisHeight / 25) - (processTooltipRect.attr("width") + (0)));
							processTooltip.selectAll("*").attr("x", processTooltip.attr("x") - (bottomVisHeight / 25) - (processTooltipRect.attr("width") + (0)));
							processTooltip.attr("x", processTooltip.attr("x") - (bottomVisHeight / 25) - (processTooltipRect.attr("width") + (0)));
						}
						
						if(lastMouseHash == d["Hash"])
						{
							return;
						}
						lastMouseHash = d["Hash"]
						var e = document.createEvent('UIEvents');
						e.initUIEvent('click', true, true, /* ... */);
						g = d3.select("#process_legend_" + d["Hash"]);
						g.node().dispatchEvent(e);
						
					});

		
		var line = d3.line()
				.x
				(
					function(d, i)
					{
						if(timeMode == "Universal")
						{
							return xAxisPadding +  timeScale(d["Index MS Universal"]);
						}
						else if(timeMode == "User")
						{
							return xAxisPadding + timeScale(d["Index MS User"]);
						}
						else
						{
							return xAxisPadding +  timeScale(d["Index MS Session"]);
						}
					}
				)
				.y
				(
					function(d, i)
					{
						return cpuScale(d["CPU"]);
					}
				)
				.curve(d3.curveMonotoneX);
		
		var enterExit = [];

		var procLines = newSVG.selectAll("path")
				.data(lineFormattedData)
				.enter()
				.append("path")
				.attr('d', d => line(d.values))
				.attr("fill", "none")
				.attr("class", function(d, i)
						{
							return "clickableBarPreise processPaths process_" + colorScale(d["values"][0]["Hash"] % 20);
						})
				.style("stroke-width", bottomVisHeight / 100)
				.attr("initStrokeWidth", bottomVisHeight / 100)
				.style("stroke", function(d, i)
						{
							return colorScale(d["values"][0]["Process Order"] % 20);
						})
				.attr("initStroke", function(d, i)
						{
							return colorScale(d["values"][0]["Process Order"] % 20);
						})
				.each(function(d, i)
						{
							var windowsToSelect = d["values"][0]["Hash"];
							if(windowsToSelect)
							{
								var outerThis = this;
								var outerD = d;
								d3.selectAll(".window_process_" + windowsToSelect)
										.each(function(d, i)
												{
													if(d["Owning User"] != owningUser || d["Owning Session"] != owningSession)
													{
														
													}
													else
													{
													var newEntry = JSON.parse(JSON.stringify(d));
													if(d["Next"])
													{
														var newEntryNext = JSON.parse(JSON.stringify(d["Next"]));
														newEntryNext["Process Path"] = outerThis;
														newEntryNext["Process"] = outerD;
														newEntryNext["Type"] = "Unfocus";
														enterExit.push(newEntryNext)
													}
													newEntry["Process Path"] = outerThis;
													newEntry["Process"] = outerD;
													newEntry["Type"] = "Focus";
													
													enterExit.push(newEntry)
													}
												})
										
							}
						});

		var procPointsWindow = newSVG.append("g").selectAll("circle")
		.data(enterExit)
		.enter()
		.append("circle")
		.style("pointer-events", "none")
		.attr("cx", function(d, i)
				{
					if(timeMode == "Universal")
					{
						return xAxisPadding +  timeScale(d["Index MS Universal"]);
					}
					else if(timeMode == "User")
					{
						return xAxisPadding + timeScale(d["Index MS User"]);
					}
					else
					{
						return xAxisPadding +  timeScale(d["Index MS Session"]);
					}
				})
		.attr("cy", function(d, i)
				{
					var x = 0;
					if(timeMode == "Universal")
					{
						x = xAxisPadding +  timeScale(d["Index MS Universal"]);
					}
					else if(timeMode == "User")
					{
						x = xAxisPadding + timeScale(d["Index MS User"]);
					}
					else
					{
						x = xAxisPadding +  timeScale(d["Index MS Session"]);
					}
					return findY(d["Process Path"], x);
				})
		.attr("class", function(d, i)
				{
					return "clickableBarPreise process_" + d["Hash"];
				})
		.attr("r", (bottomVisHeight / 50) * 1.25)
		.attr("initR", (bottomVisHeight / 50) * 1.25)
		//.attr("r", 5)
		.attr("fill", function(d, i)
				{
					if(d["Type"] == "Focus")
					{
						return "green";
					}
					return "red";
					//return colorScale(d["Process Order"] % 20);
				})
		.attr("initFill", function(d, i)
				{
					if(d["Type"] == "Focus")
					{
						return "green";
					}
					return "red";
					//return colorScale(d["Process Order"] % 20);
				});

		var yAxis = d3.axisLeft().scale(cpuScale)
		
		var cpuAxis = newSVG.append("g")
				.attr("transform", "translate(" + xAxisPadding + ", 0)")
				.call(yAxis);

		var axisLabel = newSVG.append("g")
				.append("text")
				.attr("y", bottomVisHeight / 2 + "px")
				.attr("x", xAxisPadding / 2 + "px")
				//.attr("width", xAxisPadding + "px")
				//.attr("height", bottomVisHeight + "px")
				.attr("alignment-baseline", "central")
				.attr("dominant-baseline", "middle")
				.attr("font-size", bottomVizFontSize * 2)
				.attr("text-anchor", "middle")
				.text("% CPU");
		
		var visLabel = newSVG.append("g")
		.append("text")
		.attr("y", "0px")
		.attr("x", "0px")
		//.attr("width", xAxisPadding + "px")
		//.attr("height", bottomVisHeight + "px")
		.attr("font-size", bottomVizFontSize * 2)
		.attr("alignment-baseline", "hanging")
		.attr("dominant-baseline", "hanging")
		.attr("text-anchor", "left")
		.style("font-weight", "bolder")
		.text("Processes");
		
		processTooltipRect = newSVG.append("g")
		.append("rect")
		.attr("y", "0px")
		.attr("x", "0px")
		.attr("width", "0px")
		.attr("height", "0px")
		.attr("fill", "yellow")
		.attr("opacity", ".75");
		
		processTooltip = newSVG.append("g")
		.append("text")
		.attr("y", "0px")
		.attr("x", "0px")
		//.attr("width", xAxisPadding + "px")
		//.attr("height", bottomVisHeight + "px")
		.attr("font-size", bottomVizFontSize)
		.attr("alignment-baseline", "auto")
		.attr("dominant-baseline", "auto")
		.attr("text-anchor", "left")
		.style("font-weight", "bold")
		.text("");

		//var highlightTable = d3.select("#highlightDiv").style('overflow-y', 'scroll').style("height", bottomVisHeight + "px");
		var highlightTable = d3.select("#highlightDiv").style("height", bottomVisHeight + "px");

		var legendSVGProcess = highlightTable
				.append("svg")
				.attr("width", "100%")
				.attr("height", (legendHeight * cpuSortedList.length * 2 + legendHeight) + "px");

		
		legendSVGProcess = legendSVGProcess.append("g");
		
		var legendTitleProcess = legendSVGProcess.append("text")
				.attr("x", "50%")
				.attr("y", .5 * legendHeight)
				.attr("alignment-baseline", "central")
				.attr("dominant-baseline", "middle")
				.attr("text-anchor", "middle")
				//.attr("font-weight", "bolder")
				.text("Processes:");
		
		cpuSortedList = cpuSortedList.reverse();
		var legendProcess = legendSVGProcess.append("g")
				.selectAll("rect")
				.data(cpuSortedList)
				.enter()
				.append("rect")
				.attr("x", 0)
				.attr("width", "100%")
				//.attr("width", legendWidth)
				.attr("y", function(d, i)
						{
							return legendHeight * (2 * i + 1);
						})
				.attr("height", 2 * legendHeight)
				.attr("stroke", "black")
				.attr("stroke-width", 0)
				.attr("initStrokeWidth", 0)
				.attr("fill", function(d, i)
						{
							return colorScale(d[0]["Process Order"] % 20);
						})
				.attr("initFill", function(d, i)
						{
							return colorScale(d[0]["Process Order"] % 20);
						})
				.attr("id", function(d, i)
						{
							return "process_legend_" + d[0]["Hash"];
						})
				.on("click", function(d, i)
				{
					for(selection in curSelElements)
					{
						if(curSelElements[selection] && !(curSelElements[selection].empty()) && curSelElements[selection].attr("initFill"))
						{
							//curSelElements[selection].attr("fill", curSelElements[selection].attr("initFill"));
							curSelElements[selection].attr("fill", function(){ return this.getAttribute("initFill"); });
							curSelElements[selection].attr("r", function()
								{
									if(this.getAttribute("initR"))
									{
										return this.getAttribute("initR");
									}
									return 0;
								});
						}
					}
					curSelElements = [];
					
					if(curSelectProcess)
					{
						curLabel = d3.select("#process_legend_" + curSelectProcess[0]["Hash"])
						curLabel.attr("fill", curLabel.attr("initFill"));
					}
					
					if(curSelectProcess == d)
					{
						curSelectProcess = null;
						return;
					}
					
					curHash = d[0]["Hash"];
					
					windowBars = d3.selectAll(".window_process_" + d[0]["Hash"])
					windowLegendBars = d3.select("#legend_" + processToWindow[d[0]["Hash"]])
					legendBars = d3.selectAll(".legend_" + d[0]["Hash"]);
					processCircles = d3.selectAll(".process_" + d[0]["Hash"])
					curLabel = d3.select("#process_legend_" + d[0]["Hash"])
					
					highlightColor = "#ffff00";
					
					windowBars.attr("fill", highlightColor);
					windowLegendBars.attr("fill", highlightColor);
					legendBars.attr("fill", highlightColor);
					processCircles.attr("fill", highlightColor).attr("r", bottomVisHeight / 25);
					curLabel.attr("fill", highlightColor);
					
					curSelElements.push(windowBars);
					curSelElements.push(windowLegendBars);
					curSelElements.push(legendBars);
					curSelElements.push(processCircles);
					
					curSelectProcess = d;
				})
				.attr("class", "clickableBar")
				.attr("initStrokeWidth", 0);

		var legendTextProcess = legendSVGProcess.append("g")
		.selectAll("text")
		.data(cpuSortedList)
		.enter()
		.append("text")
		//.attr("font-size", 11)
		.attr("x", 0)
		.style("pointer-events", "none")
		.attr("y", function(d, i)
				{
					//return legendHeight * (i + 1);
					//return legendHeight * (i) + legendHeight;
					return legendHeight * (2 * i + 1) + legendHeight * .5;
				})
		.attr("height", legendHeight * .75)
		.text(function(d, i)
				{
					return d[0]["User"] + ":" + d[0]["Start"] + ":" + d[0]["PID"];
				})
		.attr("fill", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "#FFF";
					}
					else
					{
						return "#000";
					}
				})
		.attr("font-weight", "bolder")
		.attr("dominant-baseline", "middle")
		.attr("stroke", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "none";
					}
					else
					{
						return "none";
					}
				});

		var legendTextProcessCmd = legendSVGProcess.append("g")
		.selectAll("text")
		.data(cpuSortedList)
		.enter()
		.append("text")
		.style("pointer-events", "none")
		//.attr("font-size", 11)
		.attr("x", 0)
		.attr("y", function(d, i)
				{
					//return legendHeight * (i + 1);
					//return legendHeight * (i) + legendHeight;
					return legendHeight * (2 * i + 2) + legendHeight * .5;
				})
		.attr("height", legendHeight * .75)
		.text(function(d, i)
				{
					return d[0]["Command"];
				})
		.attr("fill", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "#FFF";
					}
					else
					{
						return "#000";
					}
				})
		.attr("font-weight", "bolder")
		.attr("dominant-baseline", "middle")
		.attr("stroke", function(d, i)
				{
					if(i % 2 == 0)
					{
						return "none";
					}
					else
					{
						return "none";
					}
				});

	}
	

	
	var prevScreenshot;
	
	function getScreenshot(userName, sessionName, indexMS)
	{
		var screenshotIndexArray = theNormData[userName][sessionName]["screenshots"];
		var finalScreenshot = screenshotIndexArray[closestIndexMSBinary(screenshotIndexArray, indexMS)];
		var curHash = SHA256(userName + sessionName + finalScreenshot["Index MS"])
		var nextScreenshot = d3.select("#" + "screenshot_" + curHash);
		if(prevScreenshot)
		{
			if(prevScreenshot.attr("id") == nextScreenshot.attr("id"))
			{
				return finalScreenshot;
			}
			prevScreenshot.attr("fill", prevScreenshot.attr("initFill"));
			prevScreenshot.attr("stroke", "Black");
		}
		nextScreenshot.attr("stroke", "Crimson");
		nextScreenshot.attr("fill", "Black");
		prevScreenshot = nextScreenshot;
		return finalScreenshot;
	}
	
	function updateTask(userName, sessionName, taskName, startTime, tagger)
	{
		var taskUrl = "deleteTask.json?event=" + eventName + "&userName=" + userName + "&sessionName=" + sessionName + "&taskName=" + taskName + "&startTime=" + startTime + "&tagger=" + tagger;
		d3.json(taskUrl, function(error, data)
				{
					if(data["result"] == "okay")
					{
						addTask(userName, sessionName, true);
					}
				});
	}
	
	function deleteTask(userName, sessionName, taskName, startTime, tagger)
	{
		var taskUrl = "deleteTask.json?event=" + eventName + "&userName=" + userName + "&sessionName=" + sessionName + "&taskName=" + taskName + "&startTime=" + startTime + "&tagger=" + tagger;
		d3.json(taskUrl, function(error, data)
				{
					if(data["result"] == "okay")
					{
						if(data["result"] == "okay")
						{
							console.log("Added task, now refreshing")
							var curSelect = "&users=" + userName + "&sessions=" + sessionName;
							d3.json("logExport.json?event=" + eventName + "&datasources=events&normalize=none" + curSelect, async function(error, data)
							{
								let theNormDataInit = ((await retrieveData("indexdata")).value);
								
								theNormDataInit[userName][sessionName]["events"] = data[userName][sessionName]["events"];
								if(!theNormDataInit[userName][sessionName]["events"])
								{
									delete theNormDataInit[userName][sessionName]["events"];
								}
								
								try
								{
									var isDone = false;
									while(!isDone)
									{
										isDone = await persistDataAndWait("indexdata", theNormDataInit);
									}
								}
								catch(err)
								{
									console.log(err);
								}
								
								theNormData = preprocess(theNormDataInit);
								console.log("New norm data")
								console.log(theNormData)
								try
								{
									var isDone = false;
									while(!(isDone == true))
									{
										isDone = (await (persistDataAndWait("data", theNormData)));
									}
									start(true);
								}
								catch(err)
								{
									console.log(err);
								}
								
							});
						}
						
					}
				});
	}
	
	var objectCacheMap = {};
	
	var curSelectProcess;
	var curSelElements = [];
	
	async function showWindow(username, session, type, timestamp, lookupIndex)
	{
		if(username != curSelectUser || session != curSelectSession)
		{
			clearWindow();
		}
		var curSlot
		
		curSlot = lookupTable[username][session][type];
		
		if(curSlot["data"])
		{
			curSlot = ((await (curSlot["data"]())).value)[timestamp];
			//This does a linear search but only on the subset of the data that can be marked "Prev"
			//IE the previous entries for the same process.  If this needs to be optimized then the
			//the curSlot entry can be converted to an array of entries rather than the current
			//linked list style.  Doing so should not incur a memory penalty, though this can also
			//be further optimized for memory by storing "Prev" and "Next" in persistence as well.
			if(lookupIndex)
			{
				while(lookupIndex != curSlot["Index MS"] && curSlot["Prev"])
				{
					curSlot = curSlot["Prev"];
				}
			}
		}
		else
		{
			curSlot = curSlot[timestamp];
		}
		
		curSlot["Hash"] = SHA256(curSlot["User"] + curSlot["Original Session"] + curSlot["Index MS"]);
		
		var formattedSlot = [];
		var finalFormattedSlot = [];
		
		var highlights = [];
		
		var count = 0;
		for(key in curSlot)
		{
			if(key == "Next" || key == "Prev")
			{
				formattedSlot[count] = {"key":"Next Index MS", "value":curSlot[key]["Index MS"]};
				count++;
				formattedSlot[count] = {"key":"Next Index", "value":curSlot[key]["Index"]};
			}
			else
			{
				formattedSlot[count] = {"key":key, "value":curSlot[key]};
			}
			count++;
		}
		
		formattedSlot = formattedSlot.sort(function(a, b)
		{
			if(a.key < b.key) { return -1; }
			if(a.key > b.key) { return 1; }
			return 0;
		})

		for(x=0; x<formattedSlot.length; x+=2)
		{
			if(formattedSlot[x]["key"] in highlightMap)
			{
				highlights.push({"key1":formattedSlot[x]["key"], "value1":formattedSlot[x]["value"]});
				
				var toHighlight = d3.select("#legend_" + SHA256(formattedSlot[x]["value"]));
				toHighlight.attr("stroke", "#ffff00").attr("stroke-width", xAxisPadding / 50);
				curHighlight.push(toHighlight);
			}
			if(x+1 >= formattedSlot.length)
			{
				finalFormattedSlot[x/2] = {"key1":formattedSlot[x]["key"], "value1":formattedSlot[x]["value"], "key2":"", "value2":""};
			}
			else
			{
				finalFormattedSlot[x/2] = {"key1":formattedSlot[x]["key"], "value1":formattedSlot[x]["value"], "key2":formattedSlot[x+1]["key"], "value2":formattedSlot[x+1]["value"]};
				if(formattedSlot[x + 1]["key"] in highlightMap)
				{
					highlights.push({"key1":formattedSlot[x + 1]["key"], "value1":formattedSlot[x + 1]["value"]});
					
					var toHighlight = d3.select("#legend_" + SHA256(formattedSlot[x + 1]["value"]));
					toHighlight.attr("stroke", "#ffff00").attr("stroke-width", xAxisPadding / 50);
					curHighlight.push(toHighlight);
				}
			}
		}
		
		d3.select("#extraInfoTable")
				.selectAll("tr")
				.remove();

		if(type == "Events")
		{
			
			if(curSlot["Original Session"] != "User")
			{
				var delRow = d3.select("#extraInfoTable")
					.append("tr");
				delRow.append("td")
					.attr("colspan", "2")
					.attr("width", "50%")
					.html("<button type=\"button\" onclick=\"deleteTask('" + curSlot["Owning User"] + "', '" + curSlot["Original Session"] + "', '" + curSlot["TaskName"] + "', '" + curSlot["Index MS"] + "','" + curSlot["Source"] + "')\">Delete</button>");
				delRow.append("td")
					.attr("colspan", "2")
					.attr("width", "50%")
					.html("<button type=\"button\" onclick=\"updateTask('" + curSlot["Owning User"] + "', '" + curSlot["Original Session"] + "', '" + curSlot["TaskName"] + "', '" + curSlot["Index MS"] + "','" + curSlot["Source"] + "')\">Update</button>");
			
				var updateRow = d3.select("#extraInfoTable")
					.append("tr");
				updateRow.append("td")
					.attr("colspan", "4")
					.html("<div align='center'>New Values</div>");
				
				updateRow = d3.select("#extraInfoTable")
					.append("tr");
				updateRow.append("td")
					.attr("colspan", "2")
					.attr("width", "50%")
					.html("<div align='center'>Task Name</div><div align='center'><input type=\"text\" id=\"updateTaskName\" name=\"updateTaskName\" value=\"" + curSlot["TaskName"] + "\"></div>");
				
				var curTags = "";
				if(curSlot["Tags"])
				{
					curTags = curSlot["Tags"].join('\n');
				}	
				updateRow.append("td")
					.attr("colspan", "2")
					.attr("width", "50%")
					.html("<div align='center'>Tags</div><div align='center'><textarea id=\"updateTags\" name=\"updateTags\" rows=\"5\" cols=\"50\">" + curTags + "</textarea></div>");
				
				updateRow = d3.select("#extraInfoTable")
					.append("tr");
				updateRow.append("td")
					.attr("colspan", "4")
					.html("<div align='center'>Goal</div><div align='center'><textarea id=\"updateTaskGoal\" name=\"updateTaskGoal\" rows=\"2\" cols=\"100\">" + curSlot["Goal"] + "</textarea></div>");
				
				updateRow = d3.select("#extraInfoTable")
					.append("tr");
				updateRow.append("td")
					.attr("colspan", "2")
					.html("<div align='center'>Start Time (MS)</div><div align='center'><input type=\"text\" id=\"updateTaskStart\" name=\"updateTaskStart\" value=\"" + curSlot["Index MS Session"] + "\"></div>");
				updateRow.append("td")
					.attr("colspan", "2")
					.html("<div align='center'>End Time (MS)</div><div align='center'><input type=\"text\" id=\"updateTaskEnd\" name=\"updateTaskEnd\" value=\"" + curSlot["Next"]["Index MS Session"] + "\"></div>");
				
			}
			
			objectCacheMap[curSlot["Hash"]] = curSlot;
			
			d3.select("#extraInfoTable")
				.append("tr")
				.html("<td colspan=\"2\"><button type=\"button\" onclick=\"buildTaskMapTop('" + curSlot["Owning User"] + "', '" + curSlot["Original Session"] + "', '" + curSlot["Hash"] + "', true)\">Build Attack Graph Session Limited</button></td>"
						+ "<td colspan=\"2\"><button type=\"button\" onclick=\"buildTaskMapTop('" + curSlot["Owning User"] + "', '" + curSlot["Original Session"] + "', '" + curSlot["Hash"] + "', false)\">Build Attack Graph User Limited</button></td>");
		}
		
		var infoTitleRow = d3.select("#extraInfoTable")
			.append("tr");
		infoTitleRow.append("td")
			.attr("colspan", "4")
			.html("<div align='center'><b>Selected Data Attributes</b></div>");
		
		d3.select("#extraInfoTable").append("tr").append("td").attr("colspan", "4").append("table").attr("width", "100%")
				.selectAll("tr")
				.data(finalFormattedSlot)
				.enter()
				.append("tr")
				.html(function(d, i)
						{
							return "<td width=\"12.5%\" style=\" max-width:" + (.125 * visWidthParent) + "px\">" + d["key1"] + "</td>" + "<td width=\"37.5%\" style=\" max-width:" + (.375 * visWidthParent) + "px; overflow-x:auto;\">" + d["value1"] + "</td>" + "<td width=\"12.5%\" style=\" max-width:" + (.125 * visWidthParent) + "px\">" + d["key2"] + "</td>" + "<td width=\"37.5%\" style=\" max-width:" + (.375 * visWidthParent) + "px; overflow-x:auto;\">" + d["value2"] + "</td>";
						});

		d3.select("#screenshotDiv")
				.selectAll("*")
				.remove();

		d3.select("#screenshotDiv")
				.append("img")
				.attr("width", "100%")
				.attr("src", "data:image/jpg;base64," + (await (getScreenshot(curSlot["Owning User"], curSlot["Original Session"], curSlot["Index MS"])["Screenshot"]())))
				.attr("style", "cursor:pointer;")
				.on("click", async function()
						{
							showLightbox("<tr><td><div width=\"100%\"><img src=\"data:image/jpg;base64," + (await (getScreenshot(curSlot["Owning User"], curSlot["Original Session"], curSlot["Index MS"])["Screenshot"]())) + "\" style=\"max-height: " + (windowHeight * .9) + "px; max-width:100%\"></div></td></tr>");
							
						});
		
		d3.select("#extraHighlightDiv")
			.selectAll("*")
			.remove();

		highlightTable = d3.select("#extraHighlightDiv")
			.selectAll("p")
			.data(highlights)
			.enter()
			.append("p")
			.html(function(d, i)
					{
						return "<b>" + d["key1"] + ":</b><br />" + d["value1"];
					});
		
	}
	

	
	function back()
	{
		var baseURL = "vissplash.jsp?event=" + eventName + "&eventAdmin=" + eventAdmin;
		window.location.replace(baseURL);
	}

</script>
<script src="./search.js"></script>
<script src="./playAnimation.js"></script>
<script src="./petriNetGenerator.js"></script>
</html>
