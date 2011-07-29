From: Robin Humble <robin.humble+lustre@anu.edu.au>
Date: Fri, 29 Jul 2011 03:15:16 -0400
Subject: [Lustre-devel] Hangs with cgroup memory controller
In-Reply-To: <alpine.LFD.2.01.1107271922560.7176@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
	<BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
	<alpine.LFD.2.01.1107271922560.7176@sys880.ldn.framestore.com>
Message-ID: <20110729071516.GA15971@grizzly.cita.utoronto.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jul 27, 2011 at 07:57:57PM +0100, Mark Hills wrote:
>On Wed, 27 Jul 2011, Andreas Dilger wrote:
>> Possibly you can correlate reproducer cases with Lustre errors on the 
>> console?
>I've managed to catch the bad state, on a clean client too -- there's no 
>errors reported from Lustre in dmesg.
>
>Here's the information reported by the cgroup. It seems that there's a 
>discrepancy of 2x pages (the 'cache' field, pgpgin, pgpgout).
>
>The process which was in the group terminated a long time ago.
>
>I can leave the machine in this state until tomorrow, so any suggestions 
>for data to capture that could help trace this bug would be welcomed. 
>Thanks.

maybe try
  vm.zone_reclaim_mode=0
with zone_reclaim_mode=1 (even without memcg) we saw ~infinite scanning
for pages when doing Lustre i/o + memory pressure, which also hung up a
core in 100% system time. the scanning can be seen with
  grep scan /proc/zoneinfo

that zone_reclaim_mode=0 helps our problem could be related to your
memcg semi-missing pages, or perhaps it's a workaround for a core
kernel problem with zones - we only have Lustre so can't distinguish.

secondly, and even more of a long shot - I presume slab isn't accounted
as part of memcg, but you could also try clearing the ldlm locks. Linux
is reluctant to drop inodes caches until the locks are cleared first
  lctl set_param ldlm.namespaces.*.lru_size=clear

cheers,
robin
