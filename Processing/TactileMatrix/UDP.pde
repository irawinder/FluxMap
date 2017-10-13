// Principally, this script ensures that a string is "caught" via UDP and coded into principal inputs of:
// - tablePieceInput[][] or tablePieceInput[][][2] (rotation)
// - UMax, VMax

// Data Extents Parameters

  // Display Matrix Size (cells rendered to screen)
  int U_MAX = 18;
  int V_MAX = 22;
  int ID_MAX = 15;
    
// Arrays that holds current ID information of rectilinear tile arrangement.
int tablePieceInput[][][] = new int[U_MAX][V_MAX][2];

void initInputData() {
  for (int u=0; u<U_MAX; u++) {
    for (int v=0; v<V_MAX; v++) {
      tablePieceInput[u][v][0] = -1; // ID
      tablePieceInput[u][v][1] = 0; //Rotation
    }
  }
}

// Arraylist for storing table input values for each previous turns
ArrayList<int[][][]> tableHistory = new ArrayList<int[][][]>();

int portIN = 6152;
import hypermedia.net.*;
UDP udp;  // define the UDP object

boolean connection = false;
boolean busyImporting = false;
boolean changeDetected = false;
boolean outputReady = false;

void initUDP() {
  udp = new UDP( this, portIN );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );
  
  // Initialize tablePieceInput
  initInputData();
}

void ImportData(String inputStr[]) {
  if (inputStr[0].equals("COLORTIZER")) {
    if (!connection) connection = true;
    parseColortizerStrings(inputStr);
  } 
  busyImporting = false;
}

void parseColortizerStrings(String data[]) {

  for (int i=0 ; i<data.length;i++) {

    String[] split = split(data[i], "\t");

    // Checks maximum possible ID value
    if (split.length == 2 && split[0].equals("IDMax")) {
      ID_MAX = int(split[1]);
    }

    // Checks if row format is compatible with piece recognition.  3 columns for ID, U, V; 4 columns for ID, U, V, rotation
    if (split.length == 3 || split.length == 4) {

      //Finds UV values of Lego Grid:
      int u_temp = int(split[1]);
      int v_temp = tablePieceInput.length - int(split[2]) - 1;

      if (split.length == 3 && !split[0].equals("gridExtents")) { // If 3 columns

        // detects if different from previous value
        if ( v_temp < tablePieceInput.length && u_temp < tablePieceInput[0].length ) {
          if ( tablePieceInput[v_temp][u_temp][0] != int(split[0]) ) {
            // Sets ID
            tablePieceInput[v_temp][u_temp][0] = int(split[0]);
            changeDetected = true;
            loop();
          }
        }

      } else if (split.length == 4) {   // If 4 columns

        // detects if different from previous value
        if ( v_temp < tablePieceInput.length && u_temp < tablePieceInput[0].length ) {
          if ( tablePieceInput[v_temp][u_temp][0] != int(split[0]) || tablePieceInput[v_temp][u_temp][1] != int(split[3])/90 ) {
            // Sets ID
            tablePieceInput[v_temp][u_temp][0] = int(split[0]);
            //Identifies rotation vector of piece [WARNING: Colortizer supplies rotation in degrees (0, 90, 180, and 270)]
            tablePieceInput[v_temp][u_temp][1] = int(split[3])/90;
            changeDetected = true;
            loop();
          }
        }
      }
    }
  }
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler
  // get the "real" message =
  String message = new String( data );
  //println("catch!");
  //println(message);
  //saveStrings("data.txt", split(message, "\n"));
  String[] split = split(message, "\n");

  if (!busyImporting) {
    busyImporting = true;
    ImportData(split);
  }
  
  // Updates Screen whenever Webcam Update Received
  loop();
}

void sendCommand(String command, int port) {
  String dataToSend = "";
  dataToSend += command;
  udp.send( dataToSend, "localhost", port );
}
