From: Mark Hills <Mark.Hills@framestore.com>
Date: Fri, 29 Jul 2011 15:39:12 +0100 (BST)
Subject: [Lustre-devel] Hangs with cgroup memory controller
In-Reply-To: <E33CBAC5-08FA-49CA-970C-605A4DBE7B3B@whamcloud.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
	<BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
	<alpine.LFD.2.01.1107271922560.7176@sys880.ldn.framestore.com>
	<5DBD4462-2AAA-4657-9EBB-9633336DD972@whamcloud.com>
	<alpine.LFD.2.01.1107281415530.6411@sys880.ldn.framestore.com>
	<E33CBAC5-08FA-49CA-970C-605A4DBE7B3B@whamcloud.com>
Message-ID: <alpine.LFD.2.01.1107291504480.15112@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 28 Jul 2011, Andreas Dilger wrote:

> If you get another system in this hang there are some more things you 
> could check:
> 
> lctl get_param memused pagesused
> 
> This will print the count of all memory Lustre still thinks is 
> allocated.
> 
> Check the slab cache allocations (/proc/slabinfo) for Lustre slab 
> objects. Usually they are called ll_* or ldlm_* and are listed in 
> sequence.
> 
> Enable memory allocation tracing before applying memory pressure:
> 
> lctl set_param debug=+malloc
> 
> And then when the memory is freed dump the debug logs:
> 
> lctl dk /tmp/debug
> 
> And grep out the "free" lines.

I followed these steps. Neither /proc/slabinfo nor Lustre's own logs show 
activity at the point where the pages are forced out due to memory 
pressure.

(There's a certain amount of periodic noise in the debug logs, but looking 
beyond that I was able to force memory pressure, watch pages out, and 
Lustre logged nothing)

As before, dumping Lustre pagecache pages shows nothing.

So it looks like these aren't Lustre pages. Furthermore...
 
> The other thing that may free Lustre memory is to remove the modules, 
> but you need to keep libcfs loaded in order to be able to dump the debug 
> log.

I then unmounted the filesystem and removed all the modules, right the way 
down to libcfs.

On completion the cgroup still reported a certain amount of cached memory. 
And on memory pressure this was freed. Exactly the same as with the 
modules loaded.

I think this enforces the explanation above, that they aren't Lustre pages 
at all (though perhaps they used to be.)

But they are some side effect of Lustre activity; this whole problem only 
happens when Lustre disks are mounted and accessed.

Hosts with Lustre mounted via an NFS gateway perform flawlessly for months 
(and they still have Lustre modules loaded.) Whereas a host with Lustre 
mounted directly (and no other changes) fails -- it can be made to block a 
cgroup in 10 minutes or so.

The kernel seems to be able to handle these pages, rather than them being 
an inconsistency in data structures. Is there a reasonable explanation for 
pages like this in the kernel? One that could hopefully trace them back to 
their source.

Thanks

-- 
Mark



# echo 2 > /proc/sys/vm/drop_caches

# lctl get_param llite.*.dump_page_cache
llite.beta-ffff88040bdb9800.dump_page_cache=
gener |  llap  cookie  origin wq du wb | page inode index count [ page flags ]
llite.pi-ffff88040bde6000.dump_page_cache=
gener |  llap  cookie  origin wq du wb | page inode index count [ page flags ]

# cat /cgroup/d*/memory.usage_in_bytes
61440
1069056
1892352
92405760

# lctl get_param memused pagesused
lnet.memused=925199
memused=16609140

pagesused=0

# cat /proc/slabinfo | grep ll_
ll_import_cache        0      0   1248   26    8 : tunables    0    0    0 : slabdata      0      0      0
ll_obdo_cache        312    312    208   39    2 : tunables    0    0    0 : slabdata      8      8      0
ll_obd_dev_cache      45     45   5696    5    8 : tunables    0    0    0 : slabdata      9      9      0

# cat /proc/slabinfo | grep ldlm_
ldlm_locks           361    532    576   28    4 : tunables    0    0    0 : slabdata     19     19      0

<memory pressure>

# cat /cgroup/d*/memory.usage_in_bytes
0
0
0
12288

# cat /proc/slabinfo | grep ll_
ll_import_cache        0      0   1248   26    8 : tunables    0    0    0 : slabdata      0      0      0
ll_obdo_cache        312    312    208   39    2 : tunables    0    0    0 : slabdata      8      8      0
ll_obd_dev_cache      45     45   5696    5    8 : tunables    0    0    0 : slabdata      9      9      0

# cat /proc/slabinfo | grep ldlm_
ldlm_locks           361    532    576   28    4 : tunables    0    0    0 : slabdata     19     19      0

# lctl get_param memused pagesused
lnet.memused=925199
memused=16609140

pagesused=0

# umount /net/lustre
<in dmesg>
LustreError: 20169:0:(ldlm_request.c:1034:ldlm_cli_cancel_req()) Got rc -108 from cancel RPC: canceling anyway
LustreError: 20169:0:(ldlm_request.c:1592:ldlm_cli_cancel_list()) ldlm_cli_cancel_list: -108
LustreError: 20169:0:(ldlm_request.c:1034:ldlm_cli_cancel_req()) Got rc -108 from cancel RPC: canceling anyway
LustreError: 20169:0:(ldlm_request.c:1592:ldlm_cli_cancel_list()) ldlm_cli_cancel_list: -108

# rmmod mgc
# rmmod mdc
# rmmod osc
# rmmod lov
# rmmod lquota
# rmmod ptlrpc
# rmmod lvfs
# rmmod lnet
# rmmod obdclass
# rmmod ksocklnd
# rmmod libcfs

# echo 2 > /proc/sys/vm/drop_caches

# cat /cgroup/d*/memory.usage_in_bytes
0
0
0
12288

<memory pressure>

# cat /cgroup/d*/memory.usage_in_bytes
0
0
0
0
