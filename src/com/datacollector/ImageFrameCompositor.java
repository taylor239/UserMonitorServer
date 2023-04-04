package com.datacollector;

import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.plugins.jpeg.JPEGImageWriteParam;
import javax.imageio.stream.ImageOutputStream;

public class ImageFrameCompositor
{
	private ArrayList<Thread> executingThreads;
	private ArrayList<CompositeWorker> workers;
	private Thread callbackThread;
	
	private int sleepInterval = 1000;
	
	
	private class SyncBufferedImageHolder
	{
		private BufferedImage toHold = null;
		private int width, height, type;
		private SyncBufferedImageHolder(int width, int height, int type)
		{
			this.width = width; this.height = height; this.type = type;
			//toHold = new BufferedImage(width, height, type);
		}
		
		private synchronized BufferedImage heldImage()
		{
			if(toHold == null)
			{
				toHold = new BufferedImage(width, height, type);
			}
			return toHold;
		}
	}
	
	//private boolean compositeDone = true;
	
	private class CompositeWorker implements Runnable
	{
		boolean isDone = true;
		int modulo;
		int total;
		
		
		boolean running = true;
		
		ArrayList frameList = null;
		
		private CompositeWorker(int modulo, int total)
		{
			this.modulo = modulo;
			this.total = total;
		}
		
		void composite(ArrayList toComposite)
		{
			//System.out.println("Worker composite: " + toComposite.size());
			isDone = false;
			frameList = toComposite;
		}

		@Override
		public void run()
		{
			while(running)
			{
				if(frameList != null)
				{
					for(int x = 1; x < frameList.size(); x++)
					{
						//System.out.println("Worker " + modulo + " frame " + x);
						ConcurrentHashMap curScreenshot = (ConcurrentHashMap) frameList.get(x);
						if(curScreenshot.containsKey("Calculated") && (Boolean)curScreenshot.get("Calculated") == true)
						{
							if(!curScreenshot.containsKey("ResultScreenshot"))
							{
								curScreenshot.put("ResultScreenshot", curScreenshot.get("ScreenshotImage"));
							}
							continue;
						}
						
						ConcurrentHashMap prevScreenshot = (ConcurrentHashMap) frameList.get(x - 1);
						
						if(curScreenshot.get("Type").equals("key"))
						{
							if(!curScreenshot.containsKey("ResultScreenshot"))
							{
								curScreenshot.put("ResultScreenshot", curScreenshot.get("ScreenshotImage"));
							}
							curScreenshot.put("Calculated", true);
							curScreenshot.put("Calculated_" + modulo, true);
						}
						else
						{
							curScreenshot.put("Calculated", false);
							curScreenshot.put("Calculated" + modulo, false);
							
							if(!prevScreenshot.containsKey("ResultScreenshot"))
							{
								prevScreenshot.put("ResultScreenshot", prevScreenshot.get("ScreenshotImage"));
							}
							
							BufferedImage prevImage = (BufferedImage) prevScreenshot.get("ResultScreenshot");
							BufferedImage curImage = (BufferedImage) curScreenshot.get("ScreenshotImage");
							
							BufferedImage resultImage = null;
							if(curScreenshot.containsKey("ResultScreenshotHolder"))
							{
								//resultImage = (BufferedImage) curScreenshot.get("ResultScreenshot");
							}
							else
							{
								curScreenshot.put("ResultScreenshotHolder", new SyncBufferedImageHolder(prevImage.getWidth(), prevImage.getHeight(), BufferedImage.TYPE_INT_ARGB));
								
								//resultImage = new BufferedImage(prevImage.getWidth(), prevImage.getHeight(), BufferedImage.TYPE_INT_ARGB);
								
								
								//curScreenshot.put("ResultScreenshot", resultImage);
							}
							SyncBufferedImageHolder resultImageHolder = (SyncBufferedImageHolder) curScreenshot.get("ResultScreenshotHolder");
							resultImage = resultImageHolder.heldImage();
							//if(curScreenshot.containsKey("ResultScreenshot"))
							//{
							//	
							//}
							//else
							//{
							curScreenshot.put("ResultScreenshot", resultImage);
							//}
							
							boolean firstTime = true;
							
							while(firstTime || resultImageHolder != curScreenshot.get("ResultScreenshotHolder"))
							{
							firstTime = false;
							if(resultImageHolder != curScreenshot.get("ResultScreenshotHolder"))
							{
								resultImageHolder = (SyncBufferedImageHolder) curScreenshot.get("ResultScreenshotHolder");
								resultImage = resultImageHolder.heldImage();
								curScreenshot.put("ResultScreenshot", resultImage);
							}
							if(curScreenshot.get("Type").equals("seg"))
							{
								int startX = Integer.parseInt((String) curScreenshot.get("X")) + modulo;
								int startY = Integer.parseInt((String) curScreenshot.get("Y")) + modulo;
								for(int xLoc = 0; xLoc < resultImage.getWidth(); xLoc += total)
								{
									for(int y = 0; y < resultImage.getHeight(); y++)
									{
										resultImage.setRGB(xLoc, y, prevImage.getRGB(xLoc, y));
									}
								}
								for(int xLoc = startX; xLoc < curImage.getWidth() + startX; xLoc += total)
								{
									for(int y = startY; y < curImage.getHeight() + startY; y++)
									{
										//System.out.println("Setting " + x + " from " + (x - startX));
										//System.out.println("And " + y + " from " + (y - startY));
										//System.out.println("Dimensions of changes: " + nextImage.getWidth() + ", " + nextImage.getHeight());
										resultImage.setRGB(xLoc, y, curImage.getRGB(xLoc - startX, y - startY));
									}
								}
							}
							else if(curScreenshot.get("Type").equals("diff"))
							{
								if(prevImage.getWidth() != curImage.getWidth() || prevImage.getHeight() != curImage.getHeight())
								{
									System.out.println("Warning: Diff image dimensions do not match");
								}
								else
								{
									for(int y = modulo; y < prevImage.getWidth(); y += total)
									{
										for(int z = 0; z < prevImage.getHeight(); z++)
										{
											if(curImage.getRGB(y, z) != 0)
											{
												resultImage.setRGB(y, z, curImage.getRGB(y, z));
											}
											else
											{
												resultImage.setRGB(y, z, prevImage.getRGB(y, z));
											}
										}
									}
								}
								
							}
							}
							
							curScreenshot.put("Calculated_" + modulo, true);
							
							boolean frameDone = true;
							for(int y = 0; y < total; y++)
							{
								if(!curScreenshot.containsKey("Calculated_" + y) || !(Boolean)curScreenshot.get("Calculated_" + y))
								{
									frameDone = false;
									break;
								}
							}
							if(frameDone)
							{
								
								//curScreenshot.put("Screenshot", resultImage);
								byte[] reconstructedImage = compressImageToBytes(resultImage, (String) curScreenshot.get("Encoding"));
								curScreenshot.put("ScreenshotBytes", reconstructedImage);
								curScreenshot.put("Screenshot", reconstructedImage);
								curScreenshot.remove("ResultScreenshotHolder");
								//System.out.println("Finished " + x);
								
								curScreenshot.put("Calculated", true);
							}
							
						}
					}
					//System.out.println("Done: " + modulo);
					frameList = null;
					isDone = true;
					if(callbackThread != null && callbackThread.getState() == Thread.State.WAITING || callbackThread.getState() == Thread.State.TIMED_WAITING)
					{
						callbackThread.interrupt();
					}
				}
				try
				{
					Thread.currentThread().sleep(sleepInterval);
				}
				catch(InterruptedException e)
				{
					
				}
			}
		}
		
		private byte[] compressImageToBytes(BufferedImage toCompress, String imageCompressionType)
		{
			//System.err.println("Compressing image with " + imageCompressionType + " of size: " + toCompress.getWidth() + ", " + toCompress.getHeight());
			//System.err.println(toCompress.getColorModel());
			/*
			for(int x = 0; x < toCompress.getWidth(); x++)
			{
				for(int y = 0; y < toCompress.getHeight(); y++)
				{
					System.err.print(":" + x + "," + y + "=" + toCompress.getRGB(x, y) + ":");
				}
				System.err.println();
			}
			*/
			try
			{
				float imageCompressionFactor = 0;
				ByteArrayOutputStream toByte = new ByteArrayOutputStream();
				ImageOutputStream imageOutput = ImageIO.createImageOutputStream(toByte);
				ImageWriter myWriter = ImageIO.getImageWritersByFormatName(imageCompressionType).next();
				myWriter.setOutput(imageOutput);
				if(imageCompressionType.equals("jpg"))
				{
					JPEGImageWriteParam jpegParams = new JPEGImageWriteParam(null);
					jpegParams.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
					jpegParams.setCompressionQuality((float) imageCompressionFactor);
					myWriter.write(null, new IIOImage((RenderedImage) toCompress, null, null), jpegParams);
				}
				else if(imageCompressionType.equals("png"))
				{
					ImageWriteParam pngParam = myWriter.getDefaultWriteParam();
					if(pngParam.canWriteCompressed())
					{
						pngParam.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
						pngParam.setCompressionQuality((float) imageCompressionFactor);
					}
					IIOImage toWrite = new IIOImage((RenderedImage) toCompress, null, null);
					//IIOImage toWrite = new IIOImage(toCompress.getRaster(), null, null);
					myWriter.write(null, toWrite, pngParam);
				}
				return toByte.toByteArray();
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
			return null;
		}
	}
	
	public void stop()
	{
		for(int x = 0; x < workers.size(); x++)
		{
			workers.get(x).running = false;
		}
		//restartThreads();
		for(int x = 0; x < executingThreads.size(); x++)
		{
			try
			{
				executingThreads.get(x).join(sleepInterval);
			}
			catch(InterruptedException e)
			{
				
			}
		}
	}
	
	public void restartThreads()
	{
		for(int x = 0; x < executingThreads.size(); x++)
		{
			if(executingThreads.get(x) != null && executingThreads.get(x).getState() == Thread.State.WAITING || executingThreads.get(x).getState() == Thread.State.TIMED_WAITING)
			{
				executingThreads.get(x).interrupt();
			}
		}
	}
	
	public ImageFrameCompositor(int numThreads)
	{
		executingThreads = new ArrayList<Thread>();
		workers = new ArrayList<CompositeWorker>();
		for(int x = 0; x < numThreads; x++)
		{
			CompositeWorker newWorker = new CompositeWorker(x, numThreads);
			workers.add(newWorker);
			Thread newThread = new Thread(newWorker);
			newThread.start();
			executingThreads.add(newThread);
		}
	}
	
	public synchronized ArrayList composite(ConcurrentHashMap startFrame, ArrayList frameList)
	{
		System.out.println("Compositing " + startFrame.size());
		callbackThread = Thread.currentThread();
		
		ArrayList totalList = new ArrayList();
		totalList.add(startFrame);
		totalList.addAll(frameList);
		
		for(int x = 0; x < totalList.size(); x++)
		{
			ConcurrentHashMap curImageMap = (ConcurrentHashMap) totalList.get(x);
			if(!curImageMap.containsKey("ScreenshotImage"))
			{
				curImageMap.put("ScreenshotImage", createImageFromBytes((byte[]) curImageMap.get("Screenshot")));
			}
		}
		
		//System.out.println("Done converting to images");
		
		boolean compositeDone = false;
		for(int x = 0; x < workers.size(); x++)
		{
			//System.out.println("Sending to " + x);
			workers.get(x).composite(totalList);
			if(executingThreads.get(x) != null && executingThreads.get(x).getState() == Thread.State.WAITING || executingThreads.get(x).getState() == Thread.State.TIMED_WAITING)
			{
				executingThreads.get(x).interrupt();
			}
		}
		//restartThreads();
		while(!compositeDone)
		{
			try
			{
				callbackThread.sleep(sleepInterval);
			}
			catch(InterruptedException e)
			{
				
			}
			compositeDone = checkDone();
		}
		
		callbackThread = null;
		for(int x = 0; x < totalList.size(); x++)
		{
			ConcurrentHashMap curImageMap = (ConcurrentHashMap) totalList.get(x);
			curImageMap.remove("ScreenshotBytes");
			curImageMap.remove("ScreenshotImage");
			curImageMap.remove("ResultScreenshot");
		}
		
		return frameList;
	}
	
	private BufferedImage createImageFromBytes(byte[] imageData)
	{
		ByteArrayInputStream bais = new ByteArrayInputStream(imageData);
		try
		{
			return ImageIO.read(bais);
		}
		catch(Exception e)
		{
			throw new RuntimeException(e);
		}
	}
	
	public boolean checkDone()
	{
		for(int x = 0; x < workers.size(); x++)
		{
			if(!workers.get(x).isDone)
			{
				//System.out.println("Not done yet...");
				return false;
			}
		}
		//System.out.println("Done.");
		return true;
	}
}
