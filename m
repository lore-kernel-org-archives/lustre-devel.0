From: Paul Nowoczynski <pauln@psc.edu>
Date: Tue, 06 Nov 2007 14:57:50 -0500
Subject: [Lustre-devel] Checksum Algorithm
In-Reply-To: <200711061130.32694.behlendorf1@llnl.gov>
References: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
	<200711061130.32694.behlendorf1@llnl.gov>
Message-ID: <4730C73E.3080606@psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Brian,
How does the crc mechanism work?  I assume that the crc is done at the 
client, does the server verify the crc?   Also are the crc's stored on disk?
thanks,
paul

Brian Behlendorf wrote:
> Roger,
>
>   We've been running with checksums enabled in our release for some time now
> and have seen the exact same impact on performance.  In our case single node
> performance is impacted but aggregate FS performance remains good when enough
> clients are involved.  We are tracking the performance issue under bug 13805
> and would love any input/insight you might have on the issue.
>
>   Bug13805 <https://bugzilla.lustre.org/show_bug.cgi?id=13805>
>
>   My view on the issue is that it is madness to run with checksums disabled
> and we need to investigate more efficient checksum algorithms.  The current
> crc32 algorithm may be too heavy weight but the simple XOR algorithm you
> propose I fear is not strong enough.  I've seen to many cases now of various
> network components corrupting data in all sorts of interesting ways.
> Happily we have a lot of other choices for algorithms to investigate.
>
>   If you have the time I'd encourage you to investigate an assortment of
> algorithms and see which work best.  Making this a runtime option via 
> proc I think is also an excellent idea.
>
>   
> ------------------------------------------------------------------------
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at clusterfs.com
> https://mail.clusterfs.com/mailman/listinfo/lustre-devel
>   
