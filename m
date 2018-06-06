From: NeilBrown <neilb@suse.com>
Date: Wed, 06 Jun 2018 16:05:18 +1000
Subject: [lustre-devel] [md PATCH 00/11] staging: More lustre cleanup -
 particularly interval-trees
Message-ID: <152826510267.16761.14361003167157833896.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Hi all,
 here is my next batch of cleanups for lustre.
 Note that this series conflicts with a patch that Greg posted recently
 but that has not yet landed in staging-next (it is in
 staging-testing).
 Up to Greg which gets into staging-next first of course.

 I started with the last 5 patches but noticed interval-tree and
 decided I should deal with that first.  So I added the
 interval-tree clean-up.  That set is more work to review,
 so I put it first.

 Comments welcome,

Thanks,
NeilBrown

---

NeilBrown (11):
      staging: lustre: simplify use of interval-tree.
      staging: lustre: change lock_matches() to return bool.
      staging: lustre: move interval_insert call from ldlm_lock to ldlm_extent
      staging: lustre: convert range_lock to linux interval_trees.
      staging: lustre: convert ldlm extent locks to linux extent-tree
      staging: lustre: remove interval_tree
      staging: lustre: fold lprocfs_call_handler functionality into lnet_debugfs_*
      staging: lustre: obdclass: move linux/linux-foo.c to foo.c
      staging: lustre: discard WIRE_ATTR
      staging: lustre: move ldlm into ptlrpc
      staging: lustre: centralize setting of subdir-ccflags-y


 drivers/staging/lustre/Makefile                    |    3 
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 
 .../staging/lustre/include/linux/lnet/socklnd.h    |    8 
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   28 
 .../lustre/include/uapi/linux/lnet/lnetst.h        |    4 
 drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile |    2 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   22 
 drivers/staging/lustre/lnet/klnds/socklnd/Makefile |    2 
 drivers/staging/lustre/lnet/libcfs/Makefile        |    2 
 drivers/staging/lustre/lnet/libcfs/module.c        |   84 -
 drivers/staging/lustre/lnet/lnet/Makefile          |    2 
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   41 
 drivers/staging/lustre/lnet/selftest/Makefile      |    2 
 drivers/staging/lustre/lnet/selftest/rpc.h         |   48 
 drivers/staging/lustre/lustre/fid/Makefile         |    2 
 drivers/staging/lustre/lustre/fld/Makefile         |    2 
 .../staging/lustre/lustre/include/interval_tree.h  |  119 -
 drivers/staging/lustre/lustre/include/lustre_dlm.h |   19 
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |  599 ------
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |   73 -
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |  258 --
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  486 -----
 .../staging/lustre/lustre/ldlm/ldlm_inodebits.c    |   69 -
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  342 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  842 --------
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 2135 --------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 1163 -----------
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c    |   68 -
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     | 1013 ---------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 2033 -------------------
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 1318 ------------
 drivers/staging/lustre/lustre/llite/Makefile       |    2 
 drivers/staging/lustre/lustre/llite/file.c         |    8 
 drivers/staging/lustre/lustre/llite/range_lock.c   |  141 -
 drivers/staging/lustre/lustre/llite/range_lock.h   |   25 
 drivers/staging/lustre/lustre/lmv/Makefile         |    2 
 drivers/staging/lustre/lustre/lov/Makefile         |    2 
 drivers/staging/lustre/lustre/mdc/Makefile         |    2 
 drivers/staging/lustre/lustre/mgc/Makefile         |    2 
 drivers/staging/lustre/lustre/obdclass/Makefile    |    4 
 .../lustre/lustre/obdclass/linux/linux-module.c    |  514 -----
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |  162 --
 drivers/staging/lustre/lustre/obdclass/module.c    |  514 +++++
 drivers/staging/lustre/lustre/obdclass/sysctl.c    |  162 ++
 drivers/staging/lustre/lustre/obdecho/Makefile     |    2 
 drivers/staging/lustre/lustre/osc/Makefile         |    2 
 drivers/staging/lustre/lustre/ptlrpc/Makefile      |   17 
 drivers/staging/lustre/lustre/ptlrpc/l_lock.c      |   73 +
 drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c |  206 ++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c  |  486 +++++
 .../staging/lustre/lustre/ptlrpc/ldlm_inodebits.c  |   69 +
 .../staging/lustre/lustre/ptlrpc/ldlm_internal.h   |  329 +++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c    |  842 ++++++++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c   | 2103 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c  | 1154 +++++++++++
 drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c  |   68 +
 drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c   | 1013 +++++++++
 .../staging/lustre/lustre/ptlrpc/ldlm_request.c    | 2033 +++++++++++++++++++
 .../staging/lustre/lustre/ptlrpc/ldlm_resource.c   | 1318 ++++++++++++
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    2 
 60 files changed, 10527 insertions(+), 11523 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/include/interval_tree.h
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/interval_tree.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/l_lock.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_request.c
 delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
 delete mode 100644 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
 create mode 100644 drivers/staging/lustre/lustre/obdclass/module.c
 create mode 100644 drivers/staging/lustre/lustre/obdclass/sysctl.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/l_lock.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_extent.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_flock.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_inodebits.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_internal.h
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_lib.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_lock.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_lockd.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_plain.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_pool.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_request.c
 create mode 100644 drivers/staging/lustre/lustre/ptlrpc/ldlm_resource.c

--
Signature
