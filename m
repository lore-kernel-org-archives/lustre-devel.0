From: Andreas Dilger <adilger@sun.com>
Date: Tue, 10 Mar 2009 13:07:42 -0600
Subject: [Lustre-devel] statahead_performance.pdf
In-Reply-To: <49B632CE.4040500@sun.com>
References: <070201c9a0c4$d6fe8b50$84fba1f0$@com> <49B544FA.9020009@sun.com>
	<002901c9a0dd$22249850$666dc8f0$@com> <49B632CE.4040500@sun.com>
Message-ID: <20090310190742.GS3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 10, 2009  17:28 +0800, Yong Fan wrote:
> Sorry, some test resources budgeting limit delayed the test
> a little. This is the last test result:
> TCP2, IB and Routed IB were tested on the same cluster
> with the same scale. TPC1 was tested on another cluster.

Fan Yong,
thanks for the updated numbers.  These are MUCH easier to understand
than without the graphs.

Minor note - the graphs should be "X-Y" graphs, with the first column
(% files) as the X axis instead of a label.  That makes it clear in
the first case that the files vs. directories performance is in fact
linear with the percentage of files in the directory.

What else this exposes is that the statahead performance is really
limited by the lack of OST statahead and/or SOM.  The 100% files
case (as I expected) is limited by the need to do the OST stat before
returning anything to userspace, so Amdahl's law says it can take at
minimum 50% as long as without statahead.  For the 0% files case
(all subdirs), and when SOM is available, there is no such limitation
and the stat rate can increase significantly more.

> Regards,
> --
> Fan Yong
> > Fan Yong,
> >
> > I don't think the factor of ~2 can be explained simply by node
> > performance.  But why debate the point when it will be simpler
> > to repeat the measurements (i.e. repeating the tests exactly
> > with the same parameters e.g. # dirents) using 1GigE on the
> > same nodes that were used to measure IB.
> >
> >     Cheers,
> >               Eric
> >
> >   
> >> -----Original Message-----
> >> From: Yong.Fan at Sun.COM [mailto:Yong.Fan at Sun.COM]
> >> Sent: 09 March 2009 4:34 PM
> >> To: Eric Barton
> >> Cc: lustre-devel at lists.lustre.org
> >> Subject: Re: statahead_performance.pdf - Adobe Reader
> >>
> >> Eric Barton ??:
> >>     
> >>> Fan Yong,
> >>>
> >>> The attached PDF shows the results you gathered in a form
> >>> that makes it easier to understand the results and helps
> >>> comparison.  Please could you review it for correctness.
> >>>
> >>>
> >>>       
> >> Yes, it is much help to understand the performance improvement
> >> by statahead with the chart.
> >>
> >> But I think the first chart for "Statahead Dirents/second" maybe
> >> some misguide, since the TCP result and IB result are from different
> >> hardware environment (I mean the CPU and memory), that the speed
> >> of stating under IB is faster than TCP case is meaningless.
> >>
> >> Relatively, the second chart for "Statahead Speedup" is more useful,
> >> which is relatively independent from hardware (CPU and memory).
> >> It gives the trend of upper bound on performance improvement from
> >> statahead under different network configure, and different dir/file ratio.
> >>
> >>
> >> Thanks!
> >> --
> >> Fan Yong
> >>     
> >>>     Cheers,
> >>>               Eric
> >>>
> >>>
> >>>       
> >
> >
> >   
> 


> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
