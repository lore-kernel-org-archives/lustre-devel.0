From: office at hailoo.com <office@hailoo.com>
Date: Fri, 25 Sep 2009 15:49:03 -0400
Subject: [Lustre-devel] File offsets with multiple clients
Message-ID: <20090925194903.F379E20593C1@hailoo.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When a client obtains a file descriptor to a file on a Lustre file system, 
is the file offset pointer shared among any connected clients, or is it 
only meaningful to a single client? 

For example, given the file "foo.txt" on a Lustre file system, suppose 
there are 2 clients with an open file descriptor to "foo.txt".  If Client1 
calls lseek and then write, will this affect the file offset position of 
Client2?  Or is the application responsible for synchronizing file access 
in this case?
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090925/aeffb53c/attachment.htm>
