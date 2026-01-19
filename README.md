  Patient Monitoring System
  
  Hospital Socket project is a project designed to help nurses monitor patient vitals in real time. It uses a Python server as a middleman to connect a mobile app to a database using TCP sockets. This allows for instant emergency alerts and routine data logging without giving the mobile app direct access to the database files.

Project Structure <br>
server/ Python socket server and database logic <br>
mobile/ Flutter mobile application (nurse terminal) <br>
database/ SQLite database file <br>

Setting up the Server <br>
Open your terminal and navigate to the server folder: <br>
		cd server <br><br>
Run the server script: <br>
		python main.py <br><br>
The server will start and show your local port. Keep this window open.<br><br>

Setting up the Mobile App <br>
	Before running the app on a physical phone, make sure of the following: <br>
		Android Permissions: We added
		<uses-permission android:name="android.permission.INTERNET" /> <br>
		to the android/app/src/main/AndroidManifest.xml file  <br>
		so the app can talk to the server over Wi-Fi. <br>
        
Developer Options: On your Android phone, <br> go to Settings > About Phone and tap "Build Number" seven times. <br>
Then, go to Developer Options and enable USB Debugging.
Navigate to the mobile folder: <br>
		cd mobile/hospital <br>
Run the command: <br>
		flutter run

How to connect
Make sure your phone and laptop are on the same Wi-Fi network. <br>
Find your laptop's IP address (type ipconfig in your Windows command prompt).<br>
Open the app on your phone.<br>
Enter the laptop's IP address in the input field at the top and press "Connect."<br>
If the connection is successful, you will see the list of patients fetched from the database.<br>

