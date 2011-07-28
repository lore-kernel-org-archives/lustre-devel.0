From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 28 Jul 2011 11:10:22 -0600
Subject: [Lustre-devel] Hangs with cgroup memory controller
In-Reply-To: <alpine.LFD.2.01.1107281415530.6411@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
	<BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
	<alpine.LFD.2.01.1107271922560.7176@sys880.ldn.framestore.com>
	<5DBD4462-2AAA-4657-9EBB-9633336DD972@whamcloud.com>
	<alpine.LFD.2.01.1107281415530.6411@sys880.ldn.framestore.com>
Message-ID: <E33CBAC5-08FA-49CA-970C-605A4DBE7B3B@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If you get another system in this hang there are some more things you could check:

lctl get_param memused pagesused

This will print the count of all memory Lustre still thinks is allocated. 

Check the slab cache allocations (/proc/slabinfo) for Lustre slab objects. Usually they are called ll_* or ldlm_* and are listed in sequence. 

Enable memory allocation tracing before applying memory pressure:

lctl set_param debug=+malloc

And then when the memory is freed dump the debug logs:

lctl dk /tmp/debug

And grep out the "free" lines. 

The other thing that may free Lustre memory is to remove the modules, but you need to keep libcfs loaded in order to be able to dump the debug log. 

Cheers, Andreas

On 2011-07-28, at 7:53 AM, Mark Hills <Mark.Hills@framestore.com> wrote:

> On Wed, 27 Jul 2011, Andreas Dilger wrote:
> 
>> On 2011-07-27, at 12:57 PM, Mark Hills wrote:
>>> On Wed, 27 Jul 2011, Andreas Dilger wrote:
>>> [...] 
>>>> Possibly you can correlate reproducer cases with Lustre errors on the 
>>>> console?
>>> 
>>> I've managed to catch the bad state, on a clean client too -- there's no 
>>> errors reported from Lustre in dmesg.
>>> 
>>> Here's the information reported by the cgroup. It seems that there's a 
>>> discrepancy of 2x pages (the 'cache' field, pgpgin, pgpgout).
>> 
>> To dump Lustre pagecache pages use "lctl get_param llite.*.dump_page_cache",
>> which will print the inode, page index, read/write access, and page flags.
> 
> So I lost the previous test case, but acquired another. This time there 
> are 147 pages of difference. But not listed by the lctl command, which 
> gives an empty list.
> 
> The cgroup reports approx. 600KiB used as 'cache' (memory.stat). Yet 
> /proc/meminfo does not; only 69KiB.
> 
> But, what caught my attention is that cgroup 'cache' value dropped 
> slightly a few minutes later. drop_caches method wasn't touching this 
> memory. But when I put the system under memory pressure, these pages were 
> discarded and 'cached' was reduced. Until eventually the the cgroup 
> unhangs.
> 
> So what I observed is that the pages cannot be forced out of the cache -- 
> only by memory pressure.
> 
> I did a quick test on the regular behaviour, and drop_caches normally 
> works fine with Lustre content, both in and out of a cgroup. So these 
> pages are 'special' in some way.
> 
> It is possible that some pages could not be in LRU, but would still be 
> seen by the memory pressure codepaths?
> 
> Thanks
> 
> # cd /group/p1243
> 
> # echo 1 > memory.force_empty
> <hangs>
> 
> # echo 2 > /proc/sys/vm/drop_caches
> 
> # lctl get_param llite.*.dump_page_cache
> llite.beta-ffff88042b186400.dump_page_cache=
> gener |  llap  cookie  origin wq du wb | page inode index count [ page flags ]
> 
> # cat memory.usage_in_bytes 
> 602112
> 
> # cat memory.stat
> cache 602112
> rss 0
> mapped_file 0
> pgpgin 1998315
> pgpgout 1998168
> swap 0
> inactive_anon 0
> active_anon 0
> inactive_file 0
> active_file 0
> unevictable 0
> hierarchical_memory_limit 16777216000
> hierarchical_memsw_limit 20971520000
> total_cache 602112
> total_rss 0
> total_mapped_file 0
> total_pgpgin 1998315
> total_pgpgout 1998168
> total_swap 0
> total_inactive_anon 0
> total_active_anon 0
> total_inactive_file 0
> total_active_file 0
> total_unevictable 0
> 
> # cat /proc/meminfo 
> MemTotal:       16464728 kB
> MemFree:        15875412 kB
> Buffers:             256 kB
> Cached:            69540 kB
> SwapCached:            0 kB
> Active:            59452 kB
> Inactive:          87736 kB
> Active(anon):      33072 kB
> Inactive(anon):    61224 kB
> Active(file):      26380 kB
> Inactive(file):    26512 kB
> Unevictable:         228 kB
> Mlocked:               0 kB
> SwapTotal:      16587072 kB
> SwapFree:       16587072 kB
> Dirty:                 0 kB
> Writeback:             0 kB
> AnonPages:         77620 kB
> Mapped:            26768 kB
> Shmem:             16676 kB
> Slab:              67120 kB
> SReclaimable:      29136 kB
> SUnreclaim:        37984 kB
> KernelStack:        3336 kB
> PageTables:        10292 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:    24819436 kB
> Committed_AS:     659876 kB
> VmallocTotal:   34359738367 kB
> VmallocUsed:      320240 kB
> VmallocChunk:   34359359884 kB
> HardwareCorrupted:     0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> DirectMap4k:        7488 kB
> DirectMap2M:    16764928 kB
> 
> <some time later>
> 
> # cat memory.stat | grep cache
> cache 581632
> 
> # echo 2 > /proc/sys/vm/drop_caches
> 
> # cat memory.stat | grep cache
> cache 581632
> 
> <put system under memory pressure>
> 
> # cat memory.stat | grep cache
> cache 118784
> 
> <keep going>
> 
> # cat memory.stat | grep cache
> cache 0
> 
> <memory.force_empty un-hangs>
> 
> -- 
> Mark
