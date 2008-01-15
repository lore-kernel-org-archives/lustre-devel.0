From: Ricardo M. Correia <Ricardo.M.Correia@Sun.COM>
Date: Tue, 15 Jan 2008 15:18:08 +0000
Subject: [Lustre-devel] ZFS-DMU benchmark on Linux
In-Reply-To: <478C7B06.5020805@cea.fr>
References: <478C7B06.5020805@cea.fr>
Message-ID: <478CCEB0.2050301@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Thomas,

LEIBOVICI Thomas wrote:
> You will find in attachment to this mail some benchmarks we made on 
> Linux with pios over ZFS-DMU.
> There are some interesting things about ZFS tuning and some ideas for 
> breaking a bottleneck we identified in DMU.

Those are some very, very interesting benchmarks.

Regarding the "ZFS striping performance", you noticed that increasing 
the number of threads beyond a certain point didn't improve performance, 
in fact it actually decreased.
I think that was something expected due to the fact that the DMU already 
has a good streamlined I/O pipeline which already parallelizes I/O, and 
increasing the number of threads greatly beyond the number of cpus 
causes contention to increase which causes I/O throughput to decrease.

However, it is in fact unfortunate that more luns didn't improve 
performance. I wonder if you were hitting a CPU wall?
In a previous benchmark I ran, I noticed that PIOS was not getting 
improved throughput with more disks, even though there was still a 
significant percentage of available CPU time.
So I guess we still have opportunities to do good optimizations.

The "ZIO threads" is also something that I highly suspected had an 
impact in throughput, which is why when I benchmarked the DMU on the 
Thumper I increased them from 8 to 24. It is good to have hard data that 
confirms this.

The section about parallelizing checksums is something that the ZFS team 
appears to have solved already.
You can see this code section: 
http://www.wizy.org/mercurial/zfs-lustre/file/49c2aaa6a859/src/lib/libzfscommon/include/sys/zio_impl.h#101

If you take a look at the "ZIO_WRITE_COMMON_STAGES", you will notice 
that just before the "checksum generate" stage there is an "issue async" 
stage. This "issue async" stage basically consists in dispatching the 
I/O (ZIO) to the ZIO thread pool, which effectively causes them to be 
parallelized. The I/O dependencies are automatically tracked by the ZIO 
pipeline.

All in all, this was a very good report.

So far we have only done very limited benchmarking and optimization, but 
we are already starting to work on performance improvements. One of the 
tasks of our next development cycle will be doing this kind of analysis 
but, of course, the sooner we see this, the better :)

Great work and thanks for sharing this with us!

Best regards,
Ricardo

-- 
<http://www.sun.com> 	

*Ricardo Manuel Correia*

Lustre Engineering
*Sun Microsystems, Inc.*
Portugal

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080115/d043c2df/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 6g_top.gif
Type: image/gif
Size: 1257 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080115/d043c2df/attachment.gif>
