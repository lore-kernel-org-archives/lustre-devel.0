From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Thu, 17 Jan 2008 11:19:10 -0800
Subject: [Lustre-devel] batched integration
Message-ID: <478FAA2E.90401@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

http://arch.lustre.org/index.php?title=Windows

First of all the word "Windows" should be changed to "epochs" or 
"batches" - we are doing too many other things, like porting Lustre to 
Windows.

The architecture of this should be more closely related to the migration 
architecture documented elsewhere on the wiki.  A coordinator is 
required to start and close epochs that will be reintegrated and agents 
on the source/target nodes.

I hope this helps.

Peter
