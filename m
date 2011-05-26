From: Eric Barton <eeb@whamcloud.com>
Date: Thu, 26 May 2011 18:40:45 +0100
Subject: [Lustre-devel] New test results for "ls -Ul"
In-Reply-To: <4DDE6567.4010708@whamcloud.com>
References: <4DCBA5D4.5010902@whamcloud.com>
	<012401cc1ba4$fc090da0$f41b28e0$@com>
	<4DDE6567.4010708@whamcloud.com>
Message-ID: <002201cc1bcc$0c6b2ad0$25418070$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nasf,

 

I agree that we have to be careful comparing 1.8 and patched 2.x since 1.8 is doing

no RPC pipelining to the MDS or OSSs - however I still think (unless you can show

me the hole in my reasoning) that comparing the slopes of the time v. # stripes graphs

is fair.  These slopes correspond to the additional time it takes to stat a file with more

stripes.  Although total per-file stat times in 1.8 are dominated by RPC round-trips

to the MDS and OSSes - the OSS RPCs are all sent concurrently, so the incremental

time per stripe should be the time it takes to traverse the stack for each stripe and

issue the RPC.  Similarly for 2.x, the incremental time per stripe should also be the

time it takes to traverse the stack for each strip and queue the async glimpse.

 

In any case, I think measurements of higher stripe counts on a larger server cluster

will be revealing.

 

Cheers,
                   Eric 

 

From: Fan Yong [mailto:yong.fan at whamcloud.com] 
Sent: 26 May 2011 3:36 PM
To: Eric Barton
Cc: 'Bryon Neitzel'; 'Ian Colle'; 'Liang Zhen'; lustre-devel at lists.lustre.org
Subject: Re: New test results for "ls -Ul"

 

Hi Eric,

Thanks very much for your comparison of the results. I want to give more explanation for the results:

1) I suspect the complex CLIO lock state machine and tedious iteration/repeat operations affect the performance of traversing
large-striped directory, means the overhead introduced by those factors are higher than original b1_8 I/O stack. To measure
per-stripe overhead, it is unfair that you compare the results between patched lustre-2.x and luster-1.8, because my AGL related
patches are async pipeline operations, they hide much of such overhead. But b1_8 is sync glimpse and non-per-fetched. If compare
between original lustre-2.x and lustre-1.8, you will find the overhead difference. In fact, such overhead difference can be seen in
your second graph also. Just as you said: "1.8 gets better with more stripes, patched 2.x gets worse".

2) Currently, the limitation for AGL #/RPC is statahead window. Originally, such window is only used for controlling MDS-side
statahead. So means, as long as item's MDS-side attributes is ready (per-fetched), then related OSS-side AGL RPC can be triggered.
The default statahead window size is 32. In my test, I just use the default value. I also tested with larger window size on Toro,
but it did not give much help. I am not sure whether it can be better if testing against more powerful nodes/network.

3) For large-striped directory, the test results maybe not represent the real cases, because in my test, there are 8 OSTs on each
OSS, but OSS CPU is 4-cores, which is much slower than client node (24-cores CPU). I found OSS's load was quite high for 32-striped
cases. In theory, there are at most 32 * 8 concurrent AGL RPCs for each OSS. If we can test on more powerful OSS nodes for
large-stripe directory, the improvement may be better than current results.

4) If OSS is the performance bottle neck, it also can explain why "1.8 gets better with more stripes, patched 2.x gets worse" on
some degree. Because for b1_8, the glimpse RPCs between two items are sync, so there are at most 8 concurrent glimpse RPCs for each
OSS, means less contention, so less overhead caused by those contention. I just guess from the experience of studying SMP scaling.


Cheers,
--
Nasf

On 5/26/11 9:01 PM, Eric Barton wrote: 

Nasf,

 

Interesting results.  Thank you - especially for graphing the results so thoroughly.

I'm attaching them here and cc-ing lustre-devel since these are of general interest.

 

I don't think your conclusion number (1), to say CLIO locking is slowing us down

is as obvious from these results as you imply.  If you just compare the 1.8 and

patched 2.x per-file times and how they scale with #stripes you get this.

 



 

The gradients of these lines should correspond to the additional time per stripe required

to stat each file and I've graphed these times below (ignoring the 0-stripe data for this

calculation because I'm just interested in the incremental per-stripe overhead).

 



They show per-stripe overhead for 1.8 well above patched 2.x for the lower stripe

counts, but whereas 1.8 gets better with more stripes, patched 2.x gets worse.  I'm

guessing that at high stripe counts, 1.8 puts many concurrent glimpses on the wire

and does it quite efficiently.  I'd like to understand better how you control the #

of glimpse-aheads you keep on the wire - is it a single fixed number, or a fixed

number per OST or some other scheme?  In any case, it will be interesting to see

measurements at higher stripe counts.

Cheers, 
                   Eric 

From: Fan Yong [mailto:yong.fan at whamcloud.com] 
Sent: 12 May 2011 10:18 AM
To: Eric Barton
Cc: Bryon Neitzel; Ian Colle; Liang Zhen
Subject: New test results for "ls -Ul"

 

I have improved statahead load balance mechanism to distribute statahead load to more CPU units on client. And adjusted AGL
according to CLIO lock state machine. After those improvement, 'ls -Ul' can run more fast than old patches, especially on large SMP
node.

On the other hand, as the increasing the degree of parallelism, the lower network scheduler is becoming performance bottleneck. So I
combine my patches together with Liang's SMP patches in the test.

	
client (fat-intel-4, 24 cores)

server (client-xxx, 4 OSSes, 8 OSTs on each OSS)


b2x_patched

my patches + SMP patches

my patches


b18

original b1_8

share the same server with "b2x_patched"


b2x_original

original b2_x

original b2_x


Some notes:

1) Stripe count affects traversing performance much, and the impact is more than linear. Even if with all the patches applied on
b2_x, the degree of stripe count impact is still larger than b1_8. It is related with the complex CLIO lock state machine and
tedious iteration/repeat operations. It is not easy to make it run as efficiently as b1_8.

2) Patched b2_x is much faster than original b2_x, for traversing 400K * 32-striped directory, it is 100 times or more improved.

3) Patched b2_x is also faster than b1_8, within our test, patched b2_x is at least 4X faster than b1_8, which matches the
requirement in ORNL contract.

4) Original b2_x is faster than b1_8 only for small striped cases, not more than 4-striped. For large striped cases, slower than
b1_8, which is consistent with ORNL test result.

5) The largest stripe count is 32 in our test. We have not enough resource to test more large striped cases. And I also wonder
whether it is worth to test more large striped directory or not. Because how many customers want to use large and full striped
directory? means contains 1M * 160-striped items in signal directory. If it is rare case, then wasting lots of time on that is
worthless.

We need to confirm with ORNL what is the last acceptance test cases and environment, includes:
a) stripe count
b) item count
c) network latency, w/o lnet router, suggest without router.
d) OST count on each OSS


Cheers,
--
Nasf

 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/3ee2ea5e/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: image/png
Size: 64417 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/3ee2ea5e/attachment.png>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: image/png
Size: 57471 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/3ee2ea5e/attachment-0001.png>
