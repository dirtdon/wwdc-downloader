![](logo.png)

##Overview

---

WWDC Downloader is a simple bash script for downloading any of the developer conference videos Apple has made publicly available. 

###Usage

**Example #1**

The most basic usage is to call the script and pass in a required WWDC year. The default settings download all HD videos from the supplied year.

    ./wwdc.sh -y 2015

**Example #2**

Download the HD version of session 101 from WWDC 2015 

    ./wwdc.sh -y 2015 -f HD -s 101

**Example #3**

Download all standard definition videos from WWDC 2013

    ./wwdc.sh -y 2013 -f SD

**Example #4**

Output all or the HD video URLs to a file. This is extremely useful if you want to import a file of URLs to Synology Download Station which happens to be the reason I wrote this script.

    ./wwdc.sh -y 2015 -u >> /Users/Name/Desktop/videos.txt

---

##Contribute

Pull requests welcome!


