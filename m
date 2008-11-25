From: Wallior, Julien <Julien.Wallior@sig.com>
Date: Tue, 25 Nov 2008 11:12:34 -0500
Subject: [Lustre-devel] readahead performance improvement
In-Reply-To: <20081125073731.GN3186@webber.adilger.int>
References: <DDA5DF6A64A9A6418661A501B3B8465201F9959A2C@msgbal514.ds.susq.com>,
	<20081125073731.GN3186@webber.adilger.int>
Message-ID: <DDA5DF6A64A9A6418661A501B3B8465201F9B6304E@msgbal514.ds.susq.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> One of the problems with this change is that the first read of the file
> is at offset 0, but it should not invoke readahead.

In our case, we can do readahead starting at offset 0 because we assume
we'll be reading the whole file.

> The other problem is that this assumes the
> file striping is 1MB, but that isn't always the case.

I'm using the PTLRPC_MAX_BRW_SIZE for 1MB.

> Looking at the existing Lustre ll_readahead code I see:
>
>         /* Enlarge the RA window to encompass the full read */
>         if (bead != NULL && ras->ras_window_start +
>             ras->ras_window_len < bead->lrr_start + bead->lrr_count) {
>                 ras->ras_window_len = bead->lrr_start + bead->lrr_count -
>                         ras->ras_window_start;
>         }
>
> This is incorrect in my opinion.  The readahead window should be grown
> to the end of the first stripe boundary (usually 1MB, but it depends
> on striping), and then continue with aligned stripe sized reads (or
> multiples thereof to make full RPCs).  That can be determined by the
> readahead code correctly using the obd_extent_calc() method.

That would probably be a much better fix than mine. When we have a few
reading thread we get only 1MB IOs on the OSS. But when we have a lot
of thread (over 20), we see small IOs hitting the LUNs and that's what I'm
trying to prevent.

> I also see in two places the identical code:
>
>                 bead.lrr_start = *ppos >> CFS_PAGE_SHIFT;
>                 bead.lrr_count = (count + CFS_PAGE_SIZE - 1) >> CFS_PAGE_SHIFT;
>                 ll_ra_read_in(&bead);
>
> It also makes sense that this bead initialization is done in ll_ra_read_in(),
> and it should probably be renamed ll_ra_read_init().

That is probably a good idea. We are not using the path in ll_file_sendfile, so
I didn't change that.

> I'd be interested to see the patches, and I've CC'd lustre-devel for
> further discussion.

The patch is attached.

Julien

IMPORTANT: The information contained in this email and/or its attachments is confidential. If you are not the intended recipient, please notify the sender immediately by reply and immediately delete this message and all its attachments. Any review, use, reproduction, disclosure or dissemination of this message or any attachment by an unintended recipient is strictly prohibited. Neither this message nor any attachment is intended as or should be construed as an offer, solicitation or recommendation to buy or sell any security or other financial instrument. Neither the sender, his or her employer nor any of their respective affiliates makes any warranties as to the completeness or accuracy of any of the information contained herein or that this message or any of its attachments is free of viruses.
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: alignedio.patch
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081125/9edf3620/attachment.asc>
