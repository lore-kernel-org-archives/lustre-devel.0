From: Eric Barton <eeb@whamcloud.com>
Date: Thu, 26 May 2011 14:01:08 +0100
Subject: [Lustre-devel] New test results for "ls -Ul"
In-Reply-To: <4DCBA5D4.5010902@whamcloud.com>
References: <4DCBA5D4.5010902@whamcloud.com>
Message-ID: <012401cc1ba4$fc090da0$f41b28e0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/8ddd386d/attachment.htm>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: image/png
Size: 64417 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/8ddd386d/attachment.png>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: image/png
Size: 57471 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/8ddd386d/attachment-0001.png>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: result_20110512.xls
Type: application/vnd.ms-excel
Size: 61952 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110526/8ddd386d/attachment.xls>
