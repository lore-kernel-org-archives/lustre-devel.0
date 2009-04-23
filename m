From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Thu, 23 Apr 2009 22:42:58 +0800
Subject: [Lustre-devel] SMP scalability of our product
Message-ID: <49F07E72.6090306@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi there,

This week I got a chance to run our in-developing SMP scalable LNet on
some real good hardwares:
48 clients : 1 server, all of them are 2.5G HZ 16-cores, Mellanox IB HCA.

We want to know network performance on the server when all these clients
connect to the only server and send message or RDMA with it at the same
time. Result is a big surprise, our ping rate is about 700% of the best
number I have ever seen, 4K-sized read/write performance are 300% of
current small-size RDMA performance:
. Ping : 800,000K RPCs / Sec
. 4K READ : 900+MB / Sec
. 4K WRITE : 1200+MB / Sec

Basically, We made these changes:
. all global locks on hot logic path of LNet & LND are removed
. global data are replaced with per-CPU data, each CPU has it's own
lock, waitq, hashtable etc...
. hash different requests to different CPUs
. Try to avoid RPC bouncing between CPUs is possible
. Use CPU affinity threads if possible, to avoid data bouncing between
CPUs as well.

We don't expect performance can change so much before testing, but the
fact is, hardware can work much better if we program in the correct way.
However, these testing results are from lnet_selftest, which is improved
for SMP scalability as well, and it almost uses LNet in ideal way.

So I try to run obdecho, which almost does nothing but directly call
into ptlrpc, results make me fall back to real world, as you can see in
the attachment, it can only get about 6% of LNet's RPC rates and 20% of
LNet's small RDMA performance. Lockmeter and oprofile show that threads
of ptlrpc spent about 60% of all CPU time on spinlock... of course, it's
on 16-cores system and running insanity network testing, but SMP
machines are cheaper than ever, more customers will buy fat cores
machines, and customers always have more clients (network connections)
than us.

So, seems we still have a lot of work to do for SMP scalability, to make
better use of customers' hardware, and I would like to share what learnt
from this project in the recent future after I got time to write up.

PS, another attachment is lockmeter, which can be applied to our RHEL5
kernel (maybe there is newer version already), you can try if you are
intereste
d in.

Regards
Liang

-------------- next part --------------
A non-text attachment was scrubbed...
Name: Selftest_vs_Ptlrpc.pdf
Type: application/pdf
Size: 92284 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090423/edb22f2a/attachment.pdf>
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lockmeter-rhel5.tgz
Type: application/x-compressed
Size: 272819 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20090423/edb22f2a/attachment.bin>
