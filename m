From: Ravi <raviprakashdrbh@aol.com>
Date: Fri, 4 Mar 2011 20:30:26 -0500 (EST)
Subject: [Lustre-devel] LNetPoll  undefined
Message-ID: <8CDA8EC0A0C0017-A90-CEFA@webmail-d097.sysops.aol.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello 

I am using LNetWait (blocking call ) on a particular event .After i recevie this event i break from the loop which waits for this event and proceed  but when another event is added into the event queue the system crashes.I thought LNetPoll would be better as  i can just  poll for that particular event without disturbing the event queue but when i make i get undefined.Any thoughts .

 

 Thanks 
Ravi 



-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110304/64b7f91c/attachment.htm>
