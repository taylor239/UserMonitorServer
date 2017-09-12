package com.datacollector;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.zip.GZIPInputStream;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

/**
 * Servlet implementation class UploadData
 */
@WebServlet("/UploadData")
public class UploadData extends HttpServlet
{
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UploadData()
    {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		System.out.println("Got a request");
		System.out.println("On server: " + ((double)request.getParameter("uploadData").length()) / 1000000.0);
		byte[] compressed = Base64.getDecoder().decode(request.getParameter("uploadData"));
		ByteArrayInputStream input = new ByteArrayInputStream(compressed);
		GZIPInputStream ungzip = new GZIPInputStream(input);
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		byte[] buffer = new byte[1024];
		int length = 0;
		while((length = ungzip.read(buffer)) > 0)
		{
			output.write(buffer, 0, length);
		}
		ungzip.close();
		byte[] uncompressed = output.toByteArray();
		String uncompressedString = new String(uncompressed);
		//System.out.println(uncompressedString);
		
		Gson gson = new GsonBuilder().create();
		HashMap fromJSON = gson.fromJson(uncompressedString, HashMap.class);
		System.out.println(fromJSON.keySet());
		
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
	{
		doGet(request, response);
	}

}
