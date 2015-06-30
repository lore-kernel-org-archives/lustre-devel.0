From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 30 Jun 2015 17:01:03 +0200 (CEST)
Subject: [lustre-devel] LIBCFS_ALLOC
In-Reply-To: <d2c4fda0148a4e579b5636b586d32fbe@EXCHCS32.ornl.gov>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
	<20150628215408.GG28762@mwanda>
	<d2c4fda0148a4e579b5636b586d32fbe@EXCHCS32.ornl.gov>
Message-ID: <alpine.DEB.2.10.1506301657470.2330@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Tue, 30 Jun 2015, Simmons, James A. wrote:

> >Yeah.  You're right.  Doing a vmalloc() when kmalloc() doesn't have even
> >a tiny sliver of RAM isn't going to work.  It's easier to use
> >libcfs_kvzalloc() everywhere, but it's probably the wrong thing.
>
> The original  reason we have the vmalloc water mark wasn't so much the
> issue of memory exhaustion but to handle the case of memory fragmentation.
> Some sites had after a extended period of time started to see failures of
> allocating even 32K using kmalloc.  In our latest development branch we moved
> away from using a water mark to always try kmalloc first and if it fails then we
> try vmalloc. At ORNL we ran into severe performance issues when we entered
> vmalloc territory. It has been discussed before on what might replace vmalloc
> handling in the case of kmalloc fails but no solution has been worked out.

OK, but if a structure contains only 4 words, would it be better to just
use kzalloc?  Or does it not matter?  It would only save trying vmalloc in
a case that it is guaranteed to fail, but if a structure with 4 words
can't be allocatted, the system has other problems.  Another argument is
that kzalloc is a well known function that people and bug-finding tools
understand, so it is better to use it whenever possible.

Some of the other structures contain a lot more fields, as well as small
arrays.  They are probably acceptable for kzalloc too, but I wouldn't know
the exact dividing line.

julia
