From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:16 -0400
Subject: [lustre-devel] [PATCH 00/20] staging: lustre: batch of fixes to
	decrease test failures
Message-ID: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

New batch of patches to reduce the number of the bugs we are
seeing in our testing of the upstream client. This set of
patches is order independent. Removal of some dead code in
the lov layer as well.

Andriy Skulysh (1):
  staging: lustre: ldlm: crash on umount in cleanup_resource

Bob Glosman (1):
  staging: lustre: ptlrpc: print times in microseconds

Bobi Jam (1):
  staging: lustre: osc: soft lock - osc_makes_rpc()

Dmitry Eremin (2):
  staging: lustre: llite: allow cached acls
  staging: lustre: llite: add xattr.h header to xattr.c

Fan Yong (1):
  staging: lustre: linkea: linkEA size limitation

James Simmons (6):
  staging: lustre: ldlm: restore interval_iterate_reverse function
  staging: lustre: lustre: fix all less than 0 comparison for unsigned values
  staging: lustre: ptlrpc: restore 64-bit time for struct ptlrpc_cli_req
  staging: lustre: ptlrpc: don't use CFS_DURATION_T for time64_t
  staging: lustre: libcfs: fix test for libcfs_ioctl_hdr minimum size
  staging: lustre: llite: set security xattr using __vfs_setxattr

John L. Hammond (4):
  staging: lustre: ldlm: restore missing newlines in ldlm sysfs files
  staging: lustre: lov: remove unused code
  staging: lustre: lmv: assume a real connection in lmv_connect()
  staging: lustre: ptlrpc: correct use of list_add_tail()

Nathaniel Clark (1):
  staging: lustre: lov: Ensure correct operation for large object sizes

Niu Yawei (1):
  staging: lustre: ptlrpc: no need to reassign mbits for replay

Robin Humble (1):
  staging: lustre: llite: Remove filtering of seclabel xattr

Sebastien Buisson (1):
  staging: lustre: lov: fix 'control flow' error in lov_io_init_released

 drivers/staging/lustre/lnet/libcfs/hash.c          |  47 ++++--
 .../lustre/lnet/libcfs/linux/linux-module.c        |   2 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 .../staging/lustre/lustre/include/interval_tree.h  |   4 +
 .../lustre/lustre/include/lustre/lustre_idl.h      |   7 +-
 .../staging/lustre/lustre/include/lustre_linkea.h  |  15 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  10 +-
 drivers/staging/lustre/lustre/include/obd.h        |   2 -
 drivers/staging/lustre/lustre/include/obd_class.h  |   9 +-
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |  40 +++++
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |   3 -
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  47 +-----
 drivers/staging/lustre/lustre/llite/file.c         |  61 +++++++-
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   6 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   6 +
 drivers/staging/lustre/lustre/llite/rw.c           |   2 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   1 +
 .../staging/lustre/lustre/llite/xattr_security.c   |  23 ++-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   5 -
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   2 -
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 161 +++------------------
 drivers/staging/lustre/lustre/lov/Makefile         |   2 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |  90 ------------
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  85 -----------
 drivers/staging/lustre/lustre/lov/lov_ea.c         |  23 +--
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  27 ----
 drivers/staging/lustre/lustre/lov/lov_io.c         | 146 ++++++-------------
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  11 --
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   3 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     |   8 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |   1 -
 drivers/staging/lustre/lustre/lov/lov_request.c    |  40 +----
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |   1 -
 drivers/staging/lustre/lustre/lov/lovsub_io.c      |  51 -------
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   2 -
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |   2 +-
 drivers/staging/lustre/lustre/obdclass/linkea.c    |  69 +++++++--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |  31 +++-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  35 +++--
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  15 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  15 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  16 +-
 44 files changed, 416 insertions(+), 718 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/lov/lovsub_io.c

-- 
1.8.3.1
