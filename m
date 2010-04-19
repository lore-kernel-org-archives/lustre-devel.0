From: Andrew Perepechko <Andrew.Perepechko@Sun.COM>
Date: Mon, 19 Apr 2010 22:30:46 +0400
Subject: [Lustre-devel] Flush on file close
Message-ID: <201004192230.48196.andrew.perepechko@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Some applications expect non-zero errno on close() for any errors that may 
happen during flushing dirty cached data/metadata even though linux manual 
page for close(2) suggests that fsync(2) should be used prior to close(2) in 
order to detect problems like those.

Since syncing may degrade performance to a large extent, what do you think is 
the best/most convenient/least intrusive way to switch to that behaviour? 
Should it be a mount option for the client or anything else?

Andrew.
