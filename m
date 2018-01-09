From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 00/14] staging:lustre: convert most
 LIBCFS*ALLOC to k*malloc - V2
Message-ID: <151546052331.9776.7408338350463291753.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This is a revised version of my LIBCFS*ALLOC cleanup series.
- the compile error is fixed
- some cases of "if (x) kfree(x)" have been simplified
- LIBCFS_CPT_ALLOC() has been replaced as well.

This based on staging-testing (430505962765fc1).

Intro from original posting is below.

Thanks,
NeilBrown

==============
Lustre has some "convenience" macros for allocating and freeing
memory.
They:
 - warn if called from interrupt context
 - use kvmalloc
 - assume GFP_NOFS (which kvmalloc doesn't support)
 - print an error if the allocation fails
 - initialize the memory to zeroes.

though the _ATOMIC version skips the first three.

- kmalloc family functions already produce the warning.
- kvmalloc is best kept for allocations which might be large, and
  where GFP_KERNEL is permitted
- Assuming GFP_NOFS does hurt much for small allocation - though it
  increases the chance of failure a little - but is unnecessary
  in many cases and shouldn't be assumed.
- Giving an error on failure can be achieved with CONFIG_SLAB_DEBUG.
- Initializing to zeroes, where needed, can be done with __GFP_ZERO
  or kzalloc()

So having these "convenience" functions tends to obscure the intention
of the code by reducing the variety of calls (homogenising the code).

This series converts many of the calls to kmalloc or kvmalloc or
similar, and converts the corresponding LIBCFS_FREE() calls to kfree()
or kvfree().

The LIBCFS_CPT_ALLOC() calls have not been changed as they are a
little less straight forward, and deserve closer analysis before a
clean conversion is possible.

This series does not remove the zeroing in all cases where is isn't
needed, but does remove it in some.
Similarly GFP_NOFS is left is some cases where it might not be
necessary.  These omissions can be rectified later following proper
analysis.


---

NeilBrown (14):
      staging: lustre: replace simple cases of LIBCFS_ALLOC with kzalloc.
      staging: lustre: lnet: switch to cpumask_var_t
      staging: lustre: lnet: selftest: don't allocate small strings.
      staging: lustre: lnet: use kmalloc/kvmalloc in router_proc
      staging: lustre: change some LIBCFS_ALLOC calls to k?alloc(GFP_KERNEL)
      staging: lustre: Convert more LIBCFS_ALLOC allocation to direct GFP_KERNEL
      staging: lustre: more LIBCFS_ALLOC conversions to GFP_KERNEL allocations.
      staging: lustre: more conversions to GFP_KERNEL allocations.
      staging: lustre: lnet-route: use kmalloc for small allocation
      staging: lustre: use kmalloc for allocating ksock_tx
      staging: lustre: cfs_percpt_alloc: use kvmalloc(GFP_KERNEL)
      staging: lustre: opencode LIBCFS_ALLOC_ATOMIC calls.
      staging: lustre: replace LIBCFS_CPT_ALLOC()
      staging: lustre: remove LIBCFS_ALLOC, LIBCFS_FREE and related macros.


 .../lustre/include/linux/libcfs/libcfs_cpu.h       |    4 
 .../lustre/include/linux/libcfs/libcfs_private.h   |   60 +-----
 .../lustre/include/linux/libcfs/libcfs_string.h    |    4 
 .../lustre/include/linux/libcfs/linux/linux-cpu.h  |    4 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  155 +++++++---------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    4 
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   61 +++---
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    6 -
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    8 -
 drivers/staging/lustre/lnet/libcfs/hash.c          |   18 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    6 -
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |    6 -
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c    |   24 +--
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   12 +
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |  130 ++++++--------
 .../lustre/lnet/libcfs/linux/linux-module.c        |    4 
 drivers/staging/lustre/lnet/libcfs/module.c        |    9 -
 drivers/staging/lustre/lnet/libcfs/workitem.c      |    8 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   32 +--
 drivers/staging/lustre/lnet/lnet/config.c          |   43 ++---
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    9 -
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    6 -
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   14 +
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    6 -
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   14 +
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    8 -
 drivers/staging/lustre/lnet/lnet/peer.c            |   10 +
 drivers/staging/lustre/lnet/lnet/router.c          |   41 ++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   40 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c      |  191 ++++----------------
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   10 +
 drivers/staging/lustre/lnet/selftest/console.c     |   83 ++++-----
 drivers/staging/lustre/lnet/selftest/framework.c   |   26 +--
 drivers/staging/lustre/lnet/selftest/module.c      |    7 -
 drivers/staging/lustre/lnet/selftest/rpc.c         |   25 +--
 drivers/staging/lustre/lnet/selftest/selftest.h    |    2 
 .../lustre/lustre/obdclass/lprocfs_status.c        |   21 +-
 38 files changed, 431 insertions(+), 684 deletions(-)

--
Signature
