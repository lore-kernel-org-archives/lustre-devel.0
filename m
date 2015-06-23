From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Jun 2015 12:57:04 +0300
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: fid: Use !x to
 check for kzalloc failure
In-Reply-To: <alpine.DEB.2.10.1506231127120.2554@hadrien>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<20150623092303.GN28762@mwanda>
	<alpine.DEB.2.10.1506231127120.2554@hadrien>
Message-ID: <20150623095704.GO28762@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yes.  I know Al's thoughts and kernel style.

But Alan Cox and Andreas have both said they think (x == NULL) can help
you avoid some kind of boolean vs pointer bugs.  I've had co-workers who
did massive seds changing !foo to foo == NULL on our code base.  But
I've never seen a real life example of a bug this fixes.

To be honest, I've never seen a real life proof that (!foo) code is less
buggy.  I should look through the kbuild mailbox...  Hm...  But my other
idea of setting up code style readability testing website is also a good
one.

Linux kernel style is based on Joe Perches finding that 80% of the code
prefers one way or the other.  That's a valid method for determining
code style.  I bet it normally picks the more readable style but it
would be interesting to measure it more formally.

regards,
dan carpenter
