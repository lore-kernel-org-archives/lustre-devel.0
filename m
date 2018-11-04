From: James Simmons <jsimmons@infradead.org>
Date: Sun, 4 Nov 2018 21:37:22 +0000 (GMT)
Subject: [lustre-devel] Limitations of kernel read ahead
In-Reply-To: <E8183EB7-961B-4FC0-B223-7671E9502F87@whamcloud.com>
References: <alpine.LFD.2.21.1810291532100.21751@casper.infradead.org>
 <62D5855B-8FE1-4157-858C-01B182D759AD@ddn.com>
 <E8183EB7-961B-4FC0-B223-7671E9502F87@whamcloud.com>
Message-ID: <alpine.LFD.2.21.1811042136490.27308@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> One other enhancement that would be good to make for the readahead is to add opportunistic readahead for random access of smaller files (as determined by file size and client RAM) as discussed in LU-11416.  This has shown significant improvement for random access (about 40x speedup when doing random read IOPS on a 1GB file).

Has anyone created patches for the kernels read ahead to get this work 
started?
 
> On Oct 29, 2018, at 20:00, Li Xi <lixi@ddn.com> wrote:
> > 
> > Thank you for summarize this, James!
> > 
> > I think everyone agrees that the current readahead algorithm of Lustre needs to be improved. And evidences show that the readahead algorithm of Linux kernel would not suitable for Lustre either. There are several reasons for this. In general, the readahead algorithm of kernel is designed for local file system with small readahead window. It is single thread, synchronous readahead, only usable for sequential read. Because the read operation of Lustre is has longer latency than local file system, while its bandwidth is typically higher than local file system, we need totally different algorithm for Lustre readahead. The readahead algorithm needs to be 1) asynchronous to hide latency for application 2) multiple threaded to utilize the high bandwidth 3) use big readahead window to align with the big RPC size 4) work for sequential read, stride read and potentially small & random read.
> > 
> > The work of LU-8709 was started with these targets and got pretty good numbers even without detailed tuning. We (the Whamcloud team) would like to rework on it with a goal of merging it in the next releases of Lustre.
> > 
> > Regards,
> > Li Xi
> > 
> > ?? 2018/10/30 ??2:06??James Simmons?<jsimmons@infradead.org> ??:
> >> 
> >> 
> >>    Currently the lustre client has its own read ahead handling in the CLIO 
> >>    layer. The reason for this is due to some limitations in the read ahead
> >>    code for the linux kernel. Some work to use the kernel's read ahead was 
> >>    attempted for the LU-8964 work but the general work for LU-8964 had other
> >>    issues. Alternative work to LU-8964 has emerged under ticket
> >> 
> >>    https://jira.whamcloud.com/browse/LU-8709
> >> 
> >>    with early code at:
> >> 
> >>    https://review.whamcloud.com/#/c/23552
> >> 
> >>    Also I have included a link to a presentation of this work and it gives
> >>    insight on how lustre does its own read ahead.
> >> 
> >>    https://www.eofs.eu/_media/events/lad16/19_parallel_readahead_framework_li_xi.pdf
> >> 
> >>    Now that this seems to be the targeted work for read ahead the discussion
> >>    has come up about why this new work doesn't use the kernel read ahead 
> >>    again. I wasn't involved in the discussion about the limitations but I 
> >>    have included the people interested in this work so progress can be done
> >>    to imporve the linux kernels version of read ahead.
> >> 
> >> 
> 
> Cheers, Andreas
> ---
> Andreas Dilger
> CTO Whamcloud
> 
> 
> 
> 
> 
