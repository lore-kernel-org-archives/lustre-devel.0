From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 3 Jul 2015 11:52:06 +0000
Subject: [lustre-devel] LIBCFS_ALLOC
In-Reply-To: <9cb85b423527448db721927a35974317@EXCHCS32.ornl.gov>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
	<20150628215408.GG28762@mwanda>
	<d2c4fda0148a4e579b5636b586d32fbe@EXCHCS32.ornl.gov>
	<alpine.DEB.2.10.1506301657470.2330@hadrien>
	<9cb85b423527448db721927a35974317@EXCHCS32.ornl.gov>
Message-ID: <D1BBD1A4.FB638%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/07/02, 4:25 PM, "Simmons, James A." <simmonsja@ornl.gov> wrote:

>
>>> >Yeah.  You're right.  Doing a vmalloc() when kmalloc() doesn't have
>>>even
>>> >a tiny sliver of RAM isn't going to work.  It's easier to use
>>> >libcfs_kvzalloc() everywhere, but it's probably the wrong thing.
>>>
>>> The original  reason we have the vmalloc water mark wasn't so much the
>>> issue of memory exhaustion but to handle the case of memory
>>>fragmentation.
>>> Some sites had after a extended period of time started to see failures
>>>of
>>> allocating even 32K using kmalloc.  In our latest development branch
>>>we moved
>>> away from using a water mark to always try kmalloc first and if it
>>>fails then we
>>> try vmalloc. At ORNL we ran into severe performance issues when we
>>>entered
>>> vmalloc territory. It has been discussed before on what might replace
>>>vmalloc
>>> handling in the case of kmalloc fails but no solution has been worked
>>>out.
>>
>>OK, but if a structure contains only 4 words, would it be better to just
>>use kzalloc?  Or does it not matter?  It would only save trying vmalloc
>>in
>>a case that it is guaranteed to fail, but if a structure with 4 words
>>can't be allocated, the system has other problems.  Another argument is
>>that kzalloc is a well known function that people and bug-finding tools
>>understand, so it is better to use it whenever possible.
>>
>>Some of the other structures contain a lot more fields, as well as small
>>arrays.  They are probably acceptable for kzalloc too, but I wouldn't
>>know
>>the exact dividing line.
>
>The reason I bring this up is to discuss sorting this out. Once long ago
>we had just LIBCFS_ALLOC. For some reason before my time OBD_ALLOC got
> spawned off of that.  Currently LIBCFS_ALLOC is used just by the
>libcfs/LNet
> layer.

That is because there was (is?) interest from Cray and others to use LNet
independently from Lustre (Zest and DVS, for example) so LNet should be
self-contained and not depend on anything from Lustre.

> Now OBD_ALLOC in our development branch has moved to a try kmalloc first
>and
>if it fails try vmalloc for any size memory allocation.  LIBCFS_ALLOC
>still
> does the original approach.   So we have two possible solutions
>depending on if libcfs/LNet needs to ever do a vmalloc.
>
>One solution if libcfs/LNet never needs a vmalloc is remove LIBCFS_ALLOC
>and replace it with kzalloc everywhere. We can then move libcfs_kzvalloc
>to
> the lustre layer and port the change we did in the development branch to
> here of the try kmalloc then vmalloc approach.
>
>The other approach is if libcfs/LNet does in some case need to use vmalloc
> we could then update LIBCFS_ALLOC to first try kmalloc then vmalloc. Once
> this is implemented we can nuke the OBD_ALLOC system.

I don't agree.  I think there are a few places where vmalloc() makes sense
to try (if the allocation may be large), but in most places LIBCFS_ALLOC()
should only use kmalloc().

Unfortunately, there wasn't a separate LIBCFS_ALLOC_LARGE() like there was
for OBD_ALLOC_LARGE() that made it clear which callsites are (potentially)
large and which are small.  The macro approach allowed the compile-time
optimization of the small callsites, but that needs to be done by hand now.

>Either way I like to see it consolidated down to one system.

Given the proliferation of foo_kvmalloc() and foo_kvzalloc() helpers
(ext4_, kvm_, dm_, apparmor, ceph_, __aa_), maybe it it is time to move
these to common kernel code instead of introducing yet another new one?

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
