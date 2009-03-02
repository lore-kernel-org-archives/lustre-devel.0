From: Andreas Dilger <adilger@sun.com>
Date: Mon, 02 Mar 2009 13:45:01 -0700
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
Message-ID: <20090302204501.GQ3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 02, 2009  20:04 +0300, Vitaly Fertman wrote:
>    RAM: enough to have a tmpfs for MDS;
 
Note that strictly speaking we need to use ldiskfs on a ramdisk, not
tmpfs, because we don't have an fsfilt_tmpfs.

> Q:  which raid?
> A: raid5, as it seems to be the most popular.

I would propose:
- for MDT it needs to be RAID-1+0, because of small, random IO sizes
- for OST it needs to be RAID-6, because of double-failure risk (see
  Lustre Manual "RAID" section for discussion)

> **** Statistics ****
> 
> During all the tests the following is supposed to be running on all  
> the servers:
> 1) vmstat
> 2) iostat, if there is some disk activity.
> smth else?

I would propose either LLNL's LMT or HP's collectl, which both also
collect Lustre stats.  Those both provide more information than the
above, and having the IO/CPU load correlated to Lustre RPC counts is
very useful.

> MDST3
> 
> Q: do we want to test stat(2) with other then tmpfs disk on OST?
> what journal should it have if so?

I would be quite interested in the performance numbers from just
the ramdisk MDT+OST, to see what the upper limit of the protocol
and network are.

> 9. find
> Q: despite the fact we currently have a large downgrade with
> "find -f type", do we want to have this test in the general test set?

Some of that performance loss should have been fixed recently.  We
should continue to test it.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
