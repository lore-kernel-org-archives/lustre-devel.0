From: Mark Hills <Mark.Hills@framestore.com>
Date: Wed, 27 Jul 2011 19:57:57 +0100 (BST)
Subject: [Lustre-devel] Hangs with cgroup memory controller
In-Reply-To: <BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
	<BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
Message-ID: <alpine.LFD.2.01.1107271922560.7176@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 27 Jul 2011, Andreas Dilger wrote:

[...] 
> Possibly you can correlate reproducer cases with Lustre errors on the 
> console?

I've managed to catch the bad state, on a clean client too -- there's no 
errors reported from Lustre in dmesg.

Here's the information reported by the cgroup. It seems that there's a 
discrepancy of 2x pages (the 'cache' field, pgpgin, pgpgout).

The process which was in the group terminated a long time ago.

I can leave the machine in this state until tomorrow, so any suggestions 
for data to capture that could help trace this bug would be welcomed. 
Thanks.

# cd /cgroup/p25321

# echo 1 > memory.force_empty
<hangs: the bug>

# cat tasks
<none>

# cat memory.max_usage_in_bytes 
1281351680

# cat memory.usage_in_bytes 
8192

# cat memory.stat 
cache 8192                   <--- two pages
rss 0
mapped_file 0
pgpgin 396369                <--- two pages higher than pgpgout
pgpgout 396367
swap 0
inactive_anon 0
active_anon 0
inactive_file 0
active_file 0
unevictable 0
hierarchical_memory_limit 8388608000
hierarchical_memsw_limit 10485760000
total_cache 8192
total_rss 0
total_mapped_file 0
total_pgpgin 396369
total_pgpgout 396367
total_swap 0
total_inactive_anon 0
total_active_anon 0
total_inactive_file 0
total_active_file 0
total_unevictable 0

# echo 1 > /proc/sys/vm/drop_caches
<success>

# echo 2 > /proc/sys/vm/drop_caches
<success>

# cat memory.stat
<same as above>

-- 
Mark
