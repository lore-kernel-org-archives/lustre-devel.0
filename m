From: Joe Perches <joe@perches.com>
Date: Tue, 23 Jun 2015 15:03:45 -0700
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: fid: Use !x to
 check for kzalloc failure
In-Reply-To: <20150623095704.GO28762@mwanda>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<20150623092303.GN28762@mwanda>
	<alpine.DEB.2.10.1506231127120.2554@hadrien>
	<20150623095704.GO28762@mwanda>
Message-ID: <1435097025.2504.8.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2015-06-23 at 12:57 +0300, Dan Carpenter wrote:
> I've never seen a real life proof that (!foo) code is less
> buggy.

Nor have I.

> I should look through the kbuild mailbox...  Hm...  But my other
> idea of setting up code style readability testing website is also a good
> one.
> 
> Linux kernel style is based on Joe Perches finding that 80% of the code
> prefers one way or the other.  That's a valid method for determining
> code style.  I bet it normally picks the more readable style but it
> would be interesting to measure it more formally.

That might be hard to do well.

A code readability testing website is going to be
fundamentally biased by the experiences of the coder
that is tested.

Flashing code for millisecond type readability tests
has more correlation to quantity of white to black
than code content does of correctness to memorability.
