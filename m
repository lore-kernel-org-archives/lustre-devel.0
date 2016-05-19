From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 19 May 2016 19:54:47 +0000
Subject: [lustre-devel] LWN article on kernel stats reveal upstream client
	progress.
Message-ID: <11629f7822674b1d872d078bcb422717@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


With all the work going into the upstream lustre  client Oleg and I showed up
in the linux kernel developments stats reported by LWN.

https://lwn.net/Articles/686393

As the article pointed out Oleg showed up 3rd for the number of patches submitted
as well as 5th for line changes. I showed up 16th. We both also showed up in the
most active reviewers list. Note the changes in kernel 4.6 where the changes
mostly done during the 4.5 development cycle. The staging tree work is merged
to the 4.X-rc1 branch so any work done after that remains in the staging tree until
the next merge window. The 4.6 version of the kernel contains the same LNet stack
as the Lustre 2.8.0 release and Oleg removed most of the code style violations in the
4.6 version.

When linux 4.7 is released it will contain the CLIO simplification work as well as new
LNet updates which brings it into line with the latest LNet stack. It will be interesting
to see what the new stats will be.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160519/4eeaa203/attachment.htm>
