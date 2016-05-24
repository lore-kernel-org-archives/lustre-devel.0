From: James Simmons <jsimmons@infradead.org>
Date: Tue, 24 May 2016 15:44:32 +0100 (BST)
Subject: [lustre-devel] LWN article on kernel stats reveal upstream
 client progress.
In-Reply-To: <924F1865-65B5-4DBE-85C3-982D0BAF99D7@intel.com>
References: <11629f7822674b1d872d078bcb422717@EXCHCS32.ornl.gov>
	<924F1865-65B5-4DBE-85C3-982D0BAF99D7@intel.com>
Message-ID: <alpine.LFD.2.20.1605241528380.4622@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> James,
> How close are we to getting LNet out of staging and into mainline? ?If we are getting close, should we consider
> ?separating? LNet from Lustre making it a standalone item? ?Considering how we have to propagate all LNet fixes to
> every active repo/version, I get the feeling that LNet should be separate anyway to make updating just LNet in the
> field easier.

Well that depends on Greg. Before Greg stated it was an all or nothing 
deal for destaging. Some people would like to see LNet leave destaging
first but we still need to resolve some things.

First we have some more checkpatch cleanups to do. Lots of typedefs are
left. I cleaned up the lnetself test ones but more are left. Other odds
and ends for checkpatch as well. Besides these cleanups Greg discovered
lnetself uses linux kernel list to pass data back and forth with the
ioctls. This gave Greg very bad heartburn. Other missing pieces are
moving from the obsolete socket api's to the netlink api. Another piece
of concern is the lack of IPv6 but that would require a massive rewrite
:-(. We might be able to avoid the lack of IPv6 to get out of staging.   
