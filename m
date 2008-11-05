From: emoly.liu <Emoly.Liu@Sun.COM>
Date: Wed, 05 Nov 2008 14:46:41 +0800
Subject: [Lustre-devel] [Lustre-discuss] a new Lustre ADIO driver
In-Reply-To: <49110B1A.5030201@sun.com>
References: <49110B1A.5030201@sun.com>
Message-ID: <49114151.10908@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Here is some description and performance results for the new Lustre ADIO 
driver. You might be interested.

The main purpose of the new lustre adio driver is to collect the small 
size I/O requests into fewer number of larger ones according to Lustre's 
striping feature with low overhead automatically. We also provide some 
hints for performance tuning.

In the following graph, the recent FLASH I/O benchmarking result shows 
that the new driver performs much better than the old one, especially 
for a large-scale system.
In this test, FLASH I/O blocksize is 4*4*4 that means each 3 clients 
write 40KB, 40.5KB and 42KB respectively. The I/O operation iteration 
(nvar) is set to 1024.



HTH,
LiuYing


emoly.liu wrote:
> sending to lustre-devel@ as well
>
> Hello,
>
> A new Lustre ADIO driver for MPICH2-1.0.7 is available now, which is 
> co-developed by SUN Lustre group and Oak Ridge National Lab. (The 
> patch is attached.)
>
> Any feedback and performance results are welcomed.
>
> Thanks,
> LiuYing
>
> ------------------------------------------------------------------------
>
> _______________________________________________
> Lustre-discuss mailing list
> Lustre-discuss at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-discuss


-- 
Best regards,

LiuYing
System Software Engineer, Lustre Group
Sun Microsystems ( China ) Co. Limited

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081105/5e7aa2f1/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: flashio_perf.png
Type: image/png
Size: 26625 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20081105/5e7aa2f1/attachment.png>
