From: adilger at sun.com <adilger@sun.com>
Date: Tue, 25 Nov 2008 00:37:31 -0700
Subject: [Lustre-devel] readahead performance improvement
In-Reply-To: <DDA5DF6A64A9A6418661A501B3B8465201F9959A2C@msgbal514.ds.susq.com>
References: <DDA5DF6A64A9A6418661A501B3B8465201F9959A2C@msgbal514.ds.susq.com>
Message-ID: <20081125073731.GN3186@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 24, 2008  15:39 -0500, Wallior, Julien wrote:
> we are using Samba servers to share our Lustre out to the Windows world.
> We can make a few assumptions about our work load from Windows:
>
> - all the reads are sequential
> - we use 1MB IOs (which gets broken up into 64k IO by CIFS)
> - we read the whole file
> 
> I wrote a patch for lustre to help use get better performance. Basically,
> I disable the readahead algorithm and replace the initialization of the
> read-ahead window in ll_file_read by the following logic:
>
> If the read is aligned (to a 1MB boundary):
>         Bead.lrr_count=1MB
> Else
>         Do nothing

One of the problems with this change is that the first read of the file
is at offset 0, but it should not invoke readahead.  Only later reads from
the file will invoke the readahead, once a sequential access pattern is seen.
The problem is that it would take another (1MB/64kB - 1) = 15 64kB reads to
get to the next 1MB boundary.  The other problem is that this assumes the
file striping is 1MB, but that isn't always the case.


Looking at the existing Lustre ll_readahead code I see:

        /* Enlarge the RA window to encompass the full read */
	if (bead != NULL && ras->ras_window_start +
	    ras->ras_window_len < bead->lrr_start + bead->lrr_count) {
		ras->ras_window_len = bead->lrr_start + bead->lrr_count -
			ras->ras_window_start;
	}

This is incorrect in my opinion.  The readahead window should be grown
to the end of the first stripe boundary (usually 1MB, but it depends
on striping), and then continue with aligned stripe sized reads (or
multiples thereof to make full RPCs).  That can be determined by the
readahead code correctly using the obd_extent_calc() method.

It doesn't really make sense for Lustre clients to issue reads that are
less than a full stripe and/or full RPC in size.

I also see in two places the identical code:

		bead.lrr_start = *ppos >> CFS_PAGE_SHIFT;
		bead.lrr_count = (count + CFS_PAGE_SIZE - 1) >> CFS_PAGE_SHIFT;
		ll_ra_read_in(&bead);

It also makes sense that this bead initialization is done in ll_ra_read_in(),
and it should probably be renamed ll_ra_read_init().

> Therefore, when ll_readpage is called, it will prepopulate the cache
> and the LUNs will see 1MB IOs.
> 
> Would you be interested in patches like that? Should I start another
> bugzilla, or send an email to lustre-devel?

I'd be interested to see the patches, and I've CC'd lustre-devel for
further discussion.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
