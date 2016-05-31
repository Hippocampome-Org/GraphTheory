package hippocampome;

import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.io.InputStream;
import java.net.*;

import javax.swing.*;

import static java.lang.Math.*;
import java.util.Scanner;

import java.awt.Desktop;


public class TypeConnectivityWithListeners {
	public static void main(String[] argv) {
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                try {
        			createAndShowGUI();	
				} catch (URISyntaxException e) {
					e.printStackTrace();
				}
            }
        });
	}
	
	
	private static void createAndShowGUI() throws URISyntaxException {
		//Create and set up the window.
        frame = new JFrame("ConnectivityMapSwing");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        
        GraphicsDevice gd = GraphicsEnvironment.getLocalGraphicsEnvironment().getDefaultScreenDevice();
        int screenHeight = gd.getDisplayMode().getHeight();
        
        int windowHeight, windowWidth;
        boolean useSmallWindow;
		if (screenHeight == 768) {
        	windowHeight = 650;
        	windowWidth = 1000;
        	useSmallWindow = true;
		}
		else if (screenHeight == 800) {
        	windowHeight = 650;
        	windowWidth = 1000;
        	useSmallWindow = true;
		}
        else {
        	windowHeight = 800;
        	windowWidth = 1178;
        	useSmallWindow = false;
        }
        
 
        //Display the window
        frame.pack();
        frame.setVisible(true);
		frame.setSize(new Dimension(windowWidth, windowHeight));
		//frame.setResizable(false);
		frame.setTitle("Hippocampome.org - Potential Connectivity Map");		
		
		// set up left panel
		leftPanel = new javax.swing.JPanel();
		leftPanel.setBackground(new java.awt.Color(152,175,199));
		leftPanel.setPreferredSize(new Dimension(241, windowHeight));
		leftPanel.setMaximumSize(new Dimension(300, screenHeight));
		leftPanel.setLayout(new BoxLayout(leftPanel, BoxLayout.PAGE_AXIS));
		leftPanel.add(Box.createVerticalStrut(30));
		
		logoPanel = new ImagePanel("/resources/hippo_logo.png", "http://www.hippocampome.org");
		logoPanel.setBackground(new java.awt.Color(152,175,199));
		logoPanel.setMinimumSize(new Dimension(235, 30));
		leftPanel.add(logoPanel);
		leftPanel.add(Box.createVerticalGlue());
		
		toggleAllConnections.setMaximumSize(new Dimension(210,35));
		leftPanel.add(toggleAllConnections);
		leftPanel.add(Box.createVerticalStrut(20));
		
		toggleBgCellsAndPaths.setMaximumSize(new Dimension(210,35));
		leftPanel.add(toggleBgCellsAndPaths);
		leftPanel.add(Box.createVerticalStrut(120));
		leftPanel.add(Box.createVerticalGlue());
		
		legendPanel = new ImagePanel("/resources/legend.png", null);
		legendPanel.setBackground(new java.awt.Color(152,175,199));
		legendPanel.setPreferredSize(new Dimension(160, 224));		
		leftPanel.add(legendPanel);
		leftPanel.add(Box.createVerticalStrut(30));
        
		
        // set up main panel
        mainPanel = new javax.swing.JPanel();
        mainPanel.setPreferredSize(new Dimension(937, windowHeight));
        mainPanel.setLayout(new BoxLayout(mainPanel, BoxLayout.PAGE_AXIS));        
        ConnexionMap cm = new ConnexionMap(useSmallWindow, screenHeight);
        mainPanel.add(cm);
        
        
        // arrange panels on frame
        frame.getContentPane().setLayout(new BoxLayout(frame.getContentPane(), BoxLayout.LINE_AXIS));
        frame.add(leftPanel);
        frame.add(mainPanel);

        
		// Register listeners
        ActionListener leftPanelActionListener = new ActionListener() {
        	@Override
    		public void actionPerformed(ActionEvent e) {
	    		if (e.getSource() == toggleAllConnections) {		
	    			if (showAllLines) {
	    				showAllLines = false;
	    				toggleAllConnections.setLabel("Show All Connections");
	    			}
	    			else {
	    				showAllLines = true;
	    				toggleAllConnections.setLabel("Hide All Connections");
	    			}
	    			cm.setShowAllLines(showAllLines);
	    			mainPanel.repaint();
	    		}
	    		else if (e.getSource() == toggleBgCellsAndPaths) {
	    			if (showBgCellsAndPaths) {
	    				showBgCellsAndPaths = false;
	    				URL imagePath = getClass().getResource("/resources/hippoForm_subreg-labels.png");
	    				hippoImage = Toolkit.getDefaultToolkit().createImage(imagePath);
	    				toggleBgCellsAndPaths.setLabel("Show BG Cells and Pathways");
	    			}
	    			else {
	    				showBgCellsAndPaths = true;
	    				URL imagePath = getClass().getResource("/resources/hippoForm_cells-paths.png");
	    				hippoImage = Toolkit.getDefaultToolkit().createImage(imagePath);
	    				toggleBgCellsAndPaths.setLabel("Hide BG Cells and Pathways");
	    			}
	    			cm.setNewBgImage(hippoImage);
	    			mainPanel.repaint();
	    		}
    		}
        };
        
        toggleAllConnections.addActionListener(leftPanelActionListener);
		toggleBgCellsAndPaths.addActionListener(leftPanelActionListener);        
	}
	
	
	// variables section
	private static JFrame frame;
	private static javax.swing.JPanel leftPanel;
	private static javax.swing.JPanel mainPanel;
	private static ImagePanel logoPanel;
	private static ImagePanel legendPanel;
	
	
	// declare form variables
	private static Button toggleAllConnections = new Button("Show All Connections");
	private static Button toggleBgCellsAndPaths = new Button("Hide BG Cells & Pathways");
		
	static boolean showAllLines = false;
	static boolean showBgCellsAndPaths = true;
	static Image hippoImage;
}



class ConnexionMap extends JPanel implements MouseListener, ComponentListener {
	
	//////////////////////////// variables section ////////////////////////////
	
	static final long serialVersionUID=0;
	
	// declare local parameters from left panel	
	boolean showBgCellsAndPaths;
	boolean showAllLines;
	boolean hovering;
	Image hippoImage;
	
	// declare input file variables
	java.io.File nodesFile;
	java.io.File linesFile;
	
	Color excitatoryColor = new Color(0,0,0);
	Color inhibitoryColor = new Color(0,0,255);
	Color allInhibitoryColor = new Color(135,206,250);	
	Font font;
	FontMetrics fontmetrics;
	String defaultUrlText = "http://www.hippocampome.org";
	BoxedText BT;
	static URI uriToNeuronPage;

	boolean initialDrawing;
	int origMapWidth;
	int origMapHeight;	
	int mapWidth;
	int mapHeight;
	
	//Declare node variables
	int nodeCircleSize = 22;
	int numNodes;
	int nodeUniqueId[];
	String subregionArray[];
	String nodeStrLabel[];
	String nodeAxDePattern[];
	String EorI[];
	int nodeOrigXcoord[];
	int nodeOrigYcoord[];
	int nodeXcoord[];
	int nodeYcoord[];	
	int theNodeClicked = -1;
	int theNodeHoverded = -1;	
	MapNode mapNodeArray[];
	
	//Declare line connection variables
	int lineWidth = 3;
	int numLines;
	int lineFromNodeId[];
	int lineFromNode[];
	int lineToNodeId[];
	int lineToNode[];
	boolean arrowOnDestSide;
	boolean excitatory;
	
	//////////////////////////// end variables section ////////////////////////////
	
	
	public ConnexionMap(boolean useSmallWindow, int screenHeight) throws URISyntaxException {
		// Read input data
		try {
			readNodesFile(useSmallWindow, screenHeight);
		}
		catch (Exception e) {
			System.out.println("Problems reading data in data file:\n");
			System.out.println("Does it exist? " + nodesFile.exists());
			System.out.println("The file has " + nodesFile.length() + " bytes");
			System.out.println("Can it be read? " + nodesFile.canRead());	
			System.out.println("Absolute path is " + nodesFile.getAbsolutePath());
			e.printStackTrace();
		}
		
		try {
			readLinesFile();
		}
		catch (Exception e) {
			System.out.println("Problems reading data in data file:\n");
			System.out.println("Does it exist? " + linesFile.exists());
			System.out.println("The file has " + linesFile.length() + " bytes");
			System.out.println("Can it be read? " + linesFile.canRead());	
			System.out.println("Absolute path is " + linesFile.getAbsolutePath());
			e.printStackTrace();
		}
		
		// initialize variables
		initialDrawing = true;
		
  		showBgCellsAndPaths = true;
  		showAllLines = false;
  		URL imagePath = getClass().getResource("/resources/hippoForm_cells-paths.png");
  		hippoImage = Toolkit.getDefaultToolkit().createImage(imagePath);
  		
  		
  		// add nodes to ConnexionMap to initialize their listeners
  		this.setLayout(null);
  		mapNodeArray = new MapNode[numNodes];
  		
  		for (int i=0; i<numNodes; i++) {
  			MapNode aMapNode = new MapNode(this, i, nodeUniqueId[i], subregionArray[i], nodeStrLabel[i], nodeAxDePattern[i], EorI[i],
  					nodeXcoord[i], nodeYcoord[i]);
  			mapNodeArray[i] = aMapNode;
  			
  			this.add(aMapNode);
  			aMapNode.setSize(nodeCircleSize, nodeCircleSize);
  			aMapNode.setLocation(nodeXcoord[i]-nodeCircleSize/2, nodeYcoord[i]-nodeCircleSize/2);
  		}
  		
  		font = getFont();
  		fontmetrics = getFontMetrics(font);
  		BT = new BoxedText(10, 50, "Click to view neuron page", defaultUrlText, fontmetrics);		
  		
  		// Register listeners
    	addMouseListener(this);
    	addComponentListener(this);
	}


	public void paintComponent(Graphics g) {		
		super.paintComponent(g);				
		g.drawImage(hippoImage, 0,0,this.getWidth(),this.getHeight(),this);
		
		if (initialDrawing) {
			origMapWidth = super.getWidth();
			origMapHeight = super.getHeight();			
			initialDrawing = false;
		}
		
		mapWidth = super.getWidth();
		mapHeight = super.getHeight();

		if (theNodeClicked >= 0) {			
			MapNode clickedNode = mapNodeArray[theNodeClicked];
			
			//int clickedId = clickedNode.getNodeId();
			String clickedSubreg = clickedNode.getNodeSubreg();
			String clickedLabel = clickedNode.getNodeLabel();
			String clickedAD = clickedNode.getNodeAD();
			String clickedEI = clickedNode.getNodeEI();
			String clickedHCurl = clickedNode.getHCurl();						
			
			int numInDeg = 0;
			int numOutDeg = 0;
			String selfConn = "No";
			
			for (int iConn=0; iConn<numLines; iConn++) {
				if (lineFromNode[iConn] == theNodeClicked)
					numOutDeg++;
				if (lineToNode[iConn] == theNodeClicked)
					numInDeg++;
				if ((lineFromNode[iConn] == lineToNode[iConn]) && (lineFromNode[iConn] == theNodeClicked))
					selfConn = "Yes";
			}			
			
			g.setFont(new Font("default", Font.BOLD, 14));
			if (clickedSubreg.equals(clickedLabel.substring(0, clickedSubreg.length())))
				g.drawString(clickedLabel, 10, 30);
			else
				g.drawString(clickedSubreg + " " + clickedLabel, 10, 30);
			
			g.setFont(new Font("default", Font.PLAIN, 14));
			BT.setURLaddress(clickedHCurl);			
			BT.drawStringAndBox(g);
			
			if (clickedEI.equals("E"))
				g.drawString("Glutamatergic", 10, 75);
			else
				g.drawString("GABAergic", 10, 75);			
			
			g.drawString("Axon-dendrite pattern: " + clickedAD, 10, 90);			
			g.drawString("Number of connections: " + (numInDeg+numOutDeg), 10, 120);
			g.drawString("In-degree: " + numInDeg, 30, 135);
			g.drawString("Out-degree: " + numOutDeg, 30, 150);
			g.drawString("Self-connection: " + selfConn, 30, 165);
			
			g.drawString("(Click on an empty part of the map to clear selected connections)", 30, mapHeight-20);
		}
		else
			g.drawString("Click on a neuron type to view its connectivity...", 10, 30);
				
		
		int n=nodeCircleSize;
		int offsetX=0, offsetY=0;
		
		//Draw all lines between nodes
		for(int iLine=0; iLine<lineFromNode.length; iLine++) {
			if (showAllLines) {
				Graphics2D g2=(Graphics2D)g;
				
				// draw the ring for self-connections
				if (lineFromNode[iLine] == lineToNode[iLine]) {
					offsetX=nodeXcoord[lineFromNode[iLine]]-n/2;
					offsetY=nodeYcoord[lineFromNode[iLine]]-n/2;
					if(offsetX<0)offsetX=0;
					if(offsetY<0)offsetY=0;
					
					if (EorI[lineFromNode[iLine]].contains("E"))
						g2.setColor(excitatoryColor);
					else
						g2.setColor(allInhibitoryColor);
											
					g2.drawArc(offsetX+0, offsetY+0, n, n, 0, 360);
				}
			
				// draw the line
				else {
					if (showAllLines) {
						if (EorI[lineFromNode[iLine]].contains("E"))
							g2.setColor(excitatoryColor);						
						else
							g2.setColor(allInhibitoryColor);
	
						g2.setStroke(new BasicStroke(1.0f, BasicStroke.CAP_ROUND, BasicStroke.JOIN_MITER, 10f, new float[] {(float) 10.0,(float) 10.0}, 5.0f));
						g2.drawLine(nodeXcoord[lineFromNode[iLine]], nodeYcoord[lineFromNode[iLine]], nodeXcoord[lineToNode[iLine]], nodeYcoord[lineToNode[iLine]]);				
					}
				}
			}
		}
		
		for(int iLine=0; iLine<lineFromNode.length; iLine++) {
			Graphics2D g3=(Graphics2D)g;
			
			// draw the ring for self-connections
			if ((lineFromNode[iLine]==theNodeClicked) && (lineFromNode[iLine] == lineToNode[iLine])) {
				offsetX=nodeXcoord[lineFromNode[iLine]]-n/2;
				offsetY=nodeYcoord[lineFromNode[iLine]]-n/2;
				if(offsetX<0)offsetX=0;
				if(offsetY<0)offsetY=0;
				
				if (EorI[lineFromNode[iLine]].contains("E"))
					g3.setColor(excitatoryColor);
				else
					g3.setColor(inhibitoryColor);
										
				g3.drawArc(offsetX+0, offsetY+0, n, n, 0, 360);
			}
			
			g3.setStroke(new BasicStroke(lineWidth));
			
			if(lineFromNode[iLine]==theNodeClicked) {
				if(EorI[lineFromNode[iLine]].contains("E")) { 
					g3.setColor(excitatoryColor);
					excitatory = true;
				}
				else {
					g3.setColor(inhibitoryColor);
					excitatory = false;
				}
				
				arrowOnDestSide = true;
				paintArrow(g3, nodeXcoord[lineFromNode[iLine]], nodeYcoord[lineFromNode[iLine]], nodeXcoord[lineToNode[iLine]], nodeYcoord[lineToNode[iLine]], arrowOnDestSide, excitatory);
			}
			else if (lineToNode[iLine]==theNodeClicked) {
				if(EorI[lineFromNode[iLine]].contains("E")) { 	
					g3.setColor(excitatoryColor);
					excitatory = true;
				}
				else {
					g3.setColor(inhibitoryColor);
					excitatory = false;
				}
				
				arrowOnDestSide = false;
				paintArrow(g3, nodeXcoord[lineFromNode[iLine]], nodeYcoord[lineFromNode[iLine]], nodeXcoord[lineToNode[iLine]], nodeYcoord[lineToNode[iLine]], arrowOnDestSide, excitatory);
			}
		}
				
		
		int theNodeHovered = -1;
		for(int iNode=0; iNode<numNodes; iNode++) {
			offsetX=nodeXcoord[iNode]-n/2;
			offsetY=nodeYcoord[iNode]-n/2;
			if(offsetX<0)offsetX=0;
			if(offsetY<0)offsetY=0;
			
			// draw the interior
			g.setColor(getBackground());
			g.fillArc(offsetX+6, offsetY+6, n - 13, n - 13, 0, 360);
	      
			// draw the circumference
			if (EorI[iNode].contains("E"))
				g.setColor(getBackground().darker().darker().darker().darker());
			else
				g.setColor(getBackground().darker().darker());
			g.drawArc(offsetX+6, offsetY+6, n - 13, n - 13, 0, 360);
			
			if (mapNodeArray[iNode].getHovered()) {
				theNodeHovered = iNode;
			}
		}
		
		if (theNodeHovered >= 0) {
			MapNode hoverNode = mapNodeArray[theNodeHovered];
			String hoverStr = hoverNode.getNodeLabel();
			int hoverXPos = hoverNode.getXcoord();
			int hoverYPos = hoverNode.getYcoord();
			
			int boxXPadding = 3;
			int boxYPadding = 2;
			int labelXShift = 0;
			int labelYShift = -5 - n/2;
			int spaceBtwLines = 1;
			
			Font font = getFont();
			FontMetrics fontmetrics = getFontMetrics(font);
			
			
			if (font != null) {
				if(hoverStr.contains(" ") && hoverStr.length() > 12) {
					int spacePos = hoverStr.indexOf(' ');
					String hoverStr_1 = hoverStr.substring(0, spacePos);
					String hoverStr_2 = hoverStr.substring(spacePos+1, hoverStr.length());
					String strWithMaxWidth;
					
					if (hoverStr_1.length() > hoverStr_2.length())
						strWithMaxWidth = hoverStr_1;
					else
						strWithMaxWidth = hoverStr_2;
					
					g.setColor(Color.white);
					g.fillRect(hoverXPos + labelXShift - fontmetrics.stringWidth(strWithMaxWidth)/2 - boxXPadding, 
							hoverYPos + labelYShift - 2*fontmetrics.getMaxAscent() - spaceBtwLines - boxYPadding/2, 
							2*boxXPadding + fontmetrics.stringWidth(strWithMaxWidth),
							2*boxYPadding + 2*fontmetrics.getMaxAscent() + spaceBtwLines);
					
					g.setColor(Color.black);
					g.drawString(hoverStr_1, 
							hoverXPos + labelXShift - fontmetrics.stringWidth(hoverStr_1)/2,
							hoverYPos + labelYShift - fontmetrics.getMaxAscent() - spaceBtwLines);
					g.drawString(hoverStr_2, 
							hoverXPos + labelXShift - fontmetrics.stringWidth(hoverStr_2)/2,
							hoverYPos + labelYShift);
				}
				else {
					g.setColor(Color.white);
					g.fillRect(hoverXPos + labelXShift - fontmetrics.stringWidth(hoverStr)/2 - boxXPadding, 
							hoverYPos + labelYShift - fontmetrics.getMaxAscent() - boxYPadding/2, 
							2*boxXPadding + fontmetrics.stringWidth(hoverStr),
							2*boxYPadding + fontmetrics.getMaxAscent());
					
					g.setColor(Color.black);
					g.drawString(hoverStr, 
							hoverXPos + labelXShift - fontmetrics.stringWidth(hoverStr)/2,
							hoverYPos + labelYShift);
				}
			}
		}
	}
	
	private void paintArrow(Graphics g, int x0, int y0, int x1, int y1, boolean arrowOnDestSide, boolean Excitatory){
		double len = 16;
		double angle = 10;
	
		double cos_angle = cos(angle);
		double sin_angle = sin(angle);
	
		double r = len/sqrt((x0-x1)*(x0-x1) + (y0-y1)*(y0-y1));	// the ratio of the length of arrow side to the distance between the two points
		
		double p1_x, p1_y, p2_x, p2_y, p3_x, p3_y;
		
		if (arrowOnDestSide) {
			p1_x = x1;
			p1_y = y1;
			
	    	p2_x = x1 - r*(cos_angle*(x0-x1) - sin_angle*(y0-y1));
	    	p2_y = y1 - r*(cos_angle*(y0-y1) + sin_angle*(x0-x1));
	    	p3_x = x1 - r*(cos_angle*(x0-x1) + sin_angle*(y0-y1));
	    	p3_y = y1 - r*(cos_angle*(y0-y1) - sin_angle*(x0-x1));
		}
			else { // arrow on origin side
				p1_x = x0;
				p1_y = y0;
				
		    	p2_x = x0 + r*(cos_angle*(x1-x0) + sin_angle*(y1-y0));
		    	p2_y = y0 + r*(cos_angle*(y1-y0) - sin_angle*(x1-x0));
		    	p3_x = x0 + r*(cos_angle*(x1-x0) - sin_angle*(y1-y0));
		    	p3_y = y0 + r*(cos_angle*(y1-y0) + sin_angle*(x1-x0));
			}
		
		    
		g.drawLine(x0,y0,x1,y1);
		
		if (excitatory)
			g.setColor(excitatoryColor);
		else
			g.setColor(inhibitoryColor);
		
		//g.drawLine((int)p1_x, (int)p1_y, (int)p2_x, (int)p2_y);
		//g.drawLine((int)p1_x, (int)p1_y, (int)p3_x, (int)p3_y);
		//g.drawLine((int)p2_x, (int)p2_y, (int)p3_x, (int)p3_y);
		int xpoints[] = {(int)p1_x, (int)p2_x, (int)p3_x};
	    int ypoints[] = {(int)p1_y, (int)p2_y, (int)p3_y};
		g.fillPolygon(xpoints, ypoints, 3);
	}

	
	public void setShowAllLines(boolean newShowAllLines) { showAllLines = newShowAllLines; }
	public void setNewBgImage(Image newHippoImage) { hippoImage = newHippoImage; }
	public void setTheNodeClicked(int someNode) { theNodeClicked = someNode; }
	public void setNewNodeCoords(int someNode, int x, int y) {
		nodeXcoord[someNode] = x;
		nodeYcoord[someNode] = y;
	}
	
	
	public void readNodesFile(boolean useSmallWindow, int screenHeight) throws Exception {
		InputStream nodesStream;
		if (useSmallWindow && screenHeight==768)
			nodesStream = getClass().getResourceAsStream("/resources/nodes_smallWindow_768.txt");
		else if (useSmallWindow && screenHeight==800)
			nodesStream = getClass().getResourceAsStream("/resources/nodes_smallWindow_800.txt");
		else
			nodesStream = getClass().getResourceAsStream("/resources/nodes.txt");
		
		Scanner inputNodes = new Scanner(nodesStream);

		
		// read in projTitle and numNodes
		inputNodes.nextLine();	// read title
		inputNodes.nextLine();
		inputNodes.nextLine();
		
		numNodes = inputNodes.nextInt();
		inputNodes.nextLine();
		inputNodes.nextLine();
		inputNodes.nextLine();
		inputNodes.nextLine();

		nodeUniqueId = new int[numNodes];
		subregionArray = new String[numNodes];
		nodeStrLabel = new String[numNodes];
		nodeAxDePattern = new String[numNodes];
		nodeOrigXcoord = new int[numNodes];
		nodeOrigYcoord = new int[numNodes];
		nodeXcoord = new int[numNodes];
		nodeYcoord = new int[numNodes];
		EorI = new String[numNodes];
		
		for(int iLoop=0; iLoop<numNodes; iLoop++) {		
			inputNodes.useDelimiter("\t");
			nodeUniqueId[iLoop] = inputNodes.nextInt();
			subregionArray[iLoop] = inputNodes.next();
			nodeStrLabel[iLoop] = inputNodes.next();			
			nodeAxDePattern[iLoop] = inputNodes.next();
			nodeXcoord[iLoop] = inputNodes.nextInt();
			nodeOrigXcoord[iLoop] = nodeXcoord[iLoop];
			nodeYcoord[iLoop] = inputNodes.nextInt();
			nodeOrigYcoord[iLoop] = nodeYcoord[iLoop];
			EorI[iLoop] = inputNodes.nextLine().trim();			
		}

		// Close the file
		inputNodes.close();
	}	

	
	public void readLinesFile() throws Exception {
		InputStream linesStream = getClass().getResourceAsStream("/resources/lines.txt");
		Scanner inputLines = new Scanner(linesStream);
		
		// read in numLines
		inputLines.nextLine();	// read title
		inputLines.nextLine();
		inputLines.nextLine();
		
		numLines = inputLines.nextInt();
		inputLines.nextLine();
		inputLines.nextLine();
		inputLines.nextLine();
		inputLines.nextLine();
				
		lineFromNodeId=new int[numLines];
		lineFromNode=new int[numLines];
		lineToNodeId=new int[numLines];
		lineToNode=new int[numLines];
		
		for(int iLoop=0; iLoop<numLines; iLoop++) {
			lineFromNodeId[iLoop]=inputLines.nextInt();
			lineFromNode[iLoop]=inputLines.nextInt();
			lineToNodeId[iLoop]=inputLines.nextInt();
			lineToNode[iLoop]=inputLines.nextInt();
			inputLines.nextLine();
		}
		
		// Close the file
		inputLines.close();
	}

	
	
	public void mouseClicked(MouseEvent e) {
		if (BT.getDrawn() && BT.rectangleContainsClickedPoint(e.getPoint())) {
			String thisURLaddress = BT.getURLaddress();
			uriToNeuronPage = URI.create(thisURLaddress);
			
			if (Desktop.isDesktopSupported()) {
		        try {
					Desktop.getDesktop().browse(uriToNeuronPage);
				} catch (IOException e1) {
					System.out.println("Could not navigate to " + thisURLaddress);				
				}
	    	}
		}
		else {
			BT.undrawStringAndBox();
			setTheNodeClicked(-1);
			repaint();
		}
	}

	public void mousePressed(MouseEvent e) {}

	public void mouseReleased(MouseEvent e) {}

	public void mouseEntered(MouseEvent e) {}

	public void mouseExited(MouseEvent e) {}

	public void componentResized(ComponentEvent e) {
		double newWidthScaling = (double) mapWidth/(double) origMapWidth;
		double newHeightScaling = (double) mapHeight/(double) origMapHeight;
		
		for(int iNode=0; iNode<numNodes; iNode++) {
			int newX = (int) (nodeOrigXcoord[iNode]*newWidthScaling);
			int newY = (int) (nodeOrigYcoord[iNode]*newHeightScaling);
			setNewNodeCoords(iNode, newX, newY);
			
			mapNodeArray[iNode].setXcoord(newX);
			mapNodeArray[iNode].setYcoord(newY);			
			mapNodeArray[iNode].setSize(nodeCircleSize, nodeCircleSize);
			mapNodeArray[iNode].setLocation(nodeXcoord[iNode]-nodeCircleSize/2, nodeYcoord[iNode]-nodeCircleSize/2);
			this.add(mapNodeArray[iNode]);
		}
		
		repaint();
	}

	public void componentMoved(ComponentEvent e) {}

	public void componentShown(ComponentEvent e) {}

	public void componentHidden(ComponentEvent e) {}
	
}



class MapNode extends JComponent implements MouseListener {
	static final long serialVersionUID=0;
    
	private ConnexionMap theMap;
	private int nodeNum;
	private int nodeId;
	private String nodeSubreg;
	private String nodeLabel;
	private String nodeAD;
	private String nodeEI;
	private int xCoord;
	private int yCoord;
	private String HCurl;
	boolean hoveredOver;

    public MapNode(ConnexionMap cm, int i, int id, String sub, String lab, String ad, String ei, int x, int y) {              
    	theMap = cm;
    	
    	nodeNum = i;
    	nodeId = id;
    	nodeSubreg = sub;
    	nodeLabel = lab;
    	nodeAD = ad;
    	nodeEI = ei;
    	xCoord = x;
    	yCoord = y;
    	
    	HCurl = "http://hippocampome.org/php/neuron_page.php?id=" + id;
    	
    	hoveredOver = false;
    	
    	// Register listener
    	addMouseListener(this);
    }
    
    public int getNodeId() { return nodeId; }
    public String getNodeSubreg() { return nodeSubreg; }
    public String getNodeLabel() { return nodeLabel; }
    public String getNodeAD() { return nodeAD; }
    public String getNodeEI() { return nodeEI; }
    public int getXcoord() { return xCoord; }
    public int getYcoord() { return yCoord; }
    public String getHCurl() { return HCurl; }
    public boolean getHovered() { return hoveredOver; }
    
    public void setXcoord(int x) { xCoord = x; }
    public void setYcoord(int y) { yCoord = y; }
    
    
	public void mouseClicked(MouseEvent e) {
		theMap.setTheNodeClicked(nodeNum);
		getParent().repaint();
	}
	public void mouseEntered(MouseEvent e) {
		Cursor cursor = Cursor.getPredefinedCursor(Cursor.HAND_CURSOR); 
		setCursor(cursor);
		
		hoveredOver = true;
		getParent().repaint();
	}
	public void mouseExited(MouseEvent e) {
		Cursor cursor = Cursor.getDefaultCursor();
		setCursor(cursor);
		
		hoveredOver = false;
		getParent().repaint();
	}
	public void mousePressed(MouseEvent e) {}
	public void mouseReleased(MouseEvent e) {}
}



class BoxedText {
	private Color BGcolor = new Color(238,238,238);
	
	private String theText;
    private String theURLaddress;
    
    private Font font;
    
    private Rectangle boundingRect; // rectangle bounding the Text
    
    private int xTextOffset;
    private int yTextOffset;

    private static final int GAP = 0;
    
    private boolean drawn;
    
    private Graphics g;
    
    public BoxedText(int x, int y, String thisStr, String thisAdd, FontMetrics thisFontMetrics) {
    	theText = thisStr;
    	theURLaddress = thisAdd;
    	
    	boundingRect = new Rectangle (0, 0, 0, 0);
        
    	boundingRect.width = 2 * GAP + thisFontMetrics.stringWidth(theText);
    	boundingRect.height = 2 * GAP + thisFontMetrics.getAscent() + thisFontMetrics.getDescent();
        
    	boundingRect.x = x;
    	boundingRect.y = y - boundingRect.height;
        
        xTextOffset = GAP;
        yTextOffset = thisFontMetrics.getAscent();
        
        drawn = false;
    }    

	public void drawStringAndBox(Graphics thisG) {  
		g = thisG;
    	int x = boundingRect.x + xTextOffset;
        int y = boundingRect.y + yTextOffset;
        
        g.setFont(font);
        y = boundingRect.y + yTextOffset;
        
    	g.setColor(Color.blue);
        g.drawString(theText, x, y);
        g.setColor(BGcolor);
        g.drawRect(boundingRect.x, boundingRect.y, boundingRect.width, boundingRect.height);
        
        drawn = true;
        
        g.setColor(Color.black);
    }
	
	public void undrawStringAndBox() {
		drawn = false;
	}
    
    public boolean rectangleContainsClickedPoint(Point p) {
        return boundingRect.contains (p);
    }
    
    public void setURLaddress(String clickedHCurl) { theURLaddress = clickedHCurl; }
    public String getURLaddress() { return theURLaddress; }
    public boolean getDrawn() { return drawn; }
}



class ImagePanel extends JPanel implements MouseListener {
	int imagePanelWidth;
	int imagePanelHeight;
	
	static final long serialVersionUID=0;
    private Image bgImage;
    static URI uri;
    boolean linked;
    

    public ImagePanel(String imgFileName, String urlString) throws URISyntaxException {
    	URL imagePath = getClass().getResource(imgFileName);
    	bgImage = Toolkit.getDefaultToolkit().createImage(imagePath);
    	
    	if (urlString != null) {
    		uri = new URI(urlString);
    		linked = true;
    	}
    	else {
    		linked = false;
    	}
    	
    	// Register listener
    	addMouseListener(this);
    }
    
	private static void followLink() {
		if (Desktop.isDesktopSupported()) {			
	        try {
				Desktop.getDesktop().browse(uri);
			} catch (IOException e) {
				System.out.println("Could not navigate to " + uri.toString());			
			}
    	}
	}
	

    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        imagePanelWidth = super.getWidth();
        imagePanelHeight = super.getHeight();

        g.drawImage(bgImage, (this.getWidth()-bgImage.getWidth(this))/2, 0, bgImage.getWidth(this), bgImage.getHeight(this), this);
    }
    
    public int getImagePanelWidth() { return imagePanelWidth; }
    public int getImagePanelHeight() { return imagePanelHeight; }

	public void mouseClicked(MouseEvent e) {
		if (linked)
			followLink();
	}

	public void mousePressed(MouseEvent e) {}

	public void mouseReleased(MouseEvent e) {}

	public void mouseEntered(MouseEvent e) {
		if (linked) {
			Cursor cursor = Cursor.getPredefinedCursor(Cursor.HAND_CURSOR); 
			setCursor(cursor);
		}
	}

	public void mouseExited(MouseEvent e) {
		if (linked) {
			Cursor cursor = Cursor.getDefaultCursor();
			setCursor(cursor);
		}
	}

}



//System.out.println("theVar = " + theVar);
