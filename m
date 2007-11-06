From: Brian Behlendorf <behlendorf1@llnl.gov>
Date: Tue, 6 Nov 2007 11:30:28 -0800
Subject: [Lustre-devel] Checksum Algorithm
In-Reply-To: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
References: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
Message-ID: <200711061130.32694.behlendorf1@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Roger,

  We've been running with checksums enabled in our release for some time now
and have seen the exact same impact on performance.  In our case single node
performance is impacted but aggregate FS performance remains good when enough
clients are involved.  We are tracking the performance issue under bug 13805
and would love any input/insight you might have on the issue.

  Bug13805 <https://bugzilla.lustre.org/show_bug.cgi?id=13805>

  My view on the issue is that it is madness to run with checksums disabled
and we need to investigate more efficient checksum algorithms.  The current
crc32 algorithm may be too heavy weight but the simple XOR algorithm you
propose I fear is not strong enough.  I've seen to many cases now of various
network components corrupting data in all sorts of interesting ways.
Happily we have a lot of other choices for algorithms to investigate.

  If you have the time I'd encourage you to investigate an assortment of
algorithms and see which work best.  Making this a runtime option via 
proc I think is also an excellent idea.

-- 
Thanks,
Brian


> Hi,
>
> We have seen a huge performance drop in 1.6.3, due to the checksum being
> enabled by default.  I looked at the algorithm being used, and it is
> actually a CRC32, which is a very strong algorithm for detecting all sorts
> of problems, such as single bit errors, swapped bytes, and missing bytes.
>
> I've been experimenting with using a simple XOR algorithm.  I've been able
> to recover most of the lost performance.  This algorithm will detected
> corrupted bytes and words.  This algorithm will not detect swapped bytes
> errors, but I think that these are pretty rare.  This algorithm will not
> detect missing bytes, but I suspect that other things in Lustre or LNET
> will detect this problem.  This algorithm will not detect two errors that
> offset each other, such as a single bit error in two words that are a
> multiple of 4 bytes apart.
>
> Should we consider using a more efficient checksum algorithm, in order to
> regain performance?  Should the algorithm be configurable?
>
> -Roger
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 189 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20071106/a8ce0ec3/attachment.pgp>
