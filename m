From: Alexander Zarochentsev <alexander.zarochentsev@seagate.com>
Date: Wed, 3 Jun 2015 10:44:59 +0300
Subject: [lustre-devel] how to fix unfair cpu_parttions load distribution?
Message-ID: <CAHtKf-ZZPTSSEPZ6v+TMGSNtO+uZsjC2FS3Kdd4a1pp2nVxBrQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

FPP IOR tests with 8-16 clients  show difference in write speed between clients:
for example result files after  60 sec stonewalling write test:

-rw-r--r-- 1 root root  11G Apr 22 15:03 out.00000000.0
-rw-r--r-- 1 root root  22G Apr 22 15:03 out.00000001.0
-rw-r--r-- 1 root root 6.4G Apr 22 15:03 out.00000002.0
-rw-r--r-- 1 root root 9.8G Apr 22 15:03 out.00000003.0
-rw-r--r-- 1 root root 6.5G Apr 22 15:03 out.00000004.0
-rw-r--r-- 1 root root 6.7G Apr 22 15:03 out.00000005.0
-rw-r--r-- 1 root root 9.9G Apr 22 15:03 out.00000006.0
-rw-r--r-- 1 root root  11G Apr 22 15:03 out.00000007.0
-rw-r--r-- 1 root root  11G Apr 22 15:03 out.00000008.0
-rw-r--r-- 1 root root  21G Apr 22 15:03 out.00000009.0
-rw-r--r-- 1 root root 6.8G Apr 22 15:03 out.00000010.0
-rw-r--r-- 1 root root  11G Apr 22 15:03 out.00000011.0
-rw-r--r-- 1 root root 6.7G Apr 22 15:03 out.00000012.0
-rw-r--r-- 1 root root 6.6G Apr 22 15:03 out.00000013.0
-rw-r--r-- 1 root root  11G Apr 22 15:03 out.00000014.0
-rw-r--r-- 1 root root  11G Apr 22 15:03 out.00000015.0

the fastest client was able to write 22GB and the slowest one only 6.7GB.

The funny thing that file size distribution depends on clients and
sometimes (rare) all clients write at the same speed.

LNET provides a mapping  between client NIDs and CPU partitions
calculated as a hash of 64bit NID. The mapping is often not fair for
small number of clients and I guess may be not so good for larger
client pool too (depends on how client nids are assigned).

Unfair mapping causes uneven load on cpu partitions and that different
client speed. Disabling cpu partitions in libcfs restores equal client
write speed with some cost of performance.

Currently there is no mechanism to balance load between CPs. NRS might
be a solution but it is not, it works on each CP individually
(correct?). At least no effects from non-default NRS policies were
observed.

I think better load distribution may gave some performance gain. Also
NRS does not work as expected with CPs.

Replacing NID->CP mapping by RR looks not easy. Any ideas how it the
load distribution can be improved ?

Thanks,
-- 
Alexander Zarochentsev
Seagate Technology, LLC
www.seagate.com
