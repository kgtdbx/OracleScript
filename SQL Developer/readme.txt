--this folder from C:\Users\serhiib\AppData\Roaming\SQL Developer

I'm at the end of a very long day of dealing with a lot of Oracle B.S.  I'll get into that in another post but I hope to save some other poor sap at least some frustration.  
I was lucky enough to get a nice new i7 at work this week and started migrating over my stuff.  Most of the time its a pst here or a folder there.  But of course, not Sql Developer.  
Sql Developer spreads its config over a myriad of xml files in C:\Users\<user>\AppData\Roaming\SQL Developer\systemX.X.X.X.  (or C:\Documents and Settings\<user>\Application Data\SQL Developer\systemX.X.X.X in XP).  
I suppose you could search for all xml files and drop them in their respective folders but I'm not sure it's save and I'm certain it's a total pain in the ass.  
I tried myself and started with connections.xml which was easy enough but quickly abandoned this when I realized things like the folders for the connections were IN A SEPARATE CONFIG FILE!!!  

Instead do the following:

Delete your existing systemY.Y.Y.Y folder from C:\Users\<user>\AppData\Roaming\SQL Developer
Copy your old systemX.X.X.X into C:\Users\<user>\AppData\Roaming\SQL Developer
Start up Sql Developer
This time Sql Developer should ask you if you'd like migrate your settings.


------------------------------------
SQL-Developer: Migrate settings files (settings, code templates, snippets, connections etc.)
3
If you, like me, have a lot of personal settings, code templates, snippets, connections etc. in SQL-Developer, you may want to migrate them to a new version or another computer from time to time. 
Here are the most important configuration files of SQL-Developer for migrations and backup:

User dependent files
Code templates:
%USERPROFILE%\Application Data\SQL Developer\CodeTemplate.xml
Snippets:
%USERPROFILE%\Application Data\SQL Developer\UserSnippets.xml
SQL history:
%USERPROFILE%\Application Data\SQL Developer\SqlHistory.xml
SQL-Developer version dependent files
The numbers in the following paths vary with the version of SQL-Developer you have installed!
Please look for the appropriate directories of your installation.

Accelerators:
%USERPROFILE%\Application Data\SQL Developer\system3.0.04.34\o.ide.11.1.1.4.37.59.31\settings.xml
Connections:
%USERPROFILE%\Application Data\SQL Developer\system3.0.04.34\o.jdeveloper.db.connection.11.1.1.4.37.59.31\connections.xml
Syntax highlights:
%USERPROFILE%\Application Data\SQL Developer\system3.0.04.34\o.sqldeveloper.11.1.2.4.34\product-preferences.xml