From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:48 +1100
Subject: [lustre-devel] [PATCH 00/32] Another bunch of lustre patches.
Message-ID: <155252182126.26912.1842463462595601611.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There are two parts of this series worth highlighting.

Lustre's "memory descriptors" allow a payload to be described as
either a list of iov - virtual address based - or bvec - page based.
This results in lots of duplication at various levels of the stack.
At the bottom of the stack, the virtual addresses get mapped to
pages.  So it is cleaner to do that mapping at the top of the stack
and pass only pages down.

So this patchset results in lnet_libmd and lnet_msg only supporting
bvec.
ksock_tx still supports a single iov for the header, but otherwise
only handles bvec.
lnet_md supports a single virtual address or a list of bvec, as that
is all the client needs. When the server is added we can add back
support for a list of iov if it is still needed.

The other change involves CONFIG_FS_POSIX_ACL.
This is a config option that enables a library of support software.
While lustre is out-of-tree and being built to fit a pre-existing
config it makes sense to test that config option.
When lustre is in-tree, it does not.  lustre can select that config
option if it wants to.
The approach I have taken for now is to introduce
CONFIG_LUSTRE_FS_POSIX_ACL, and select CONFIG_FS_POSIX_ACL if the new
config is selected.
Possibly we should make Posix ACL support non-optional.  Some
filesystems do that, but most seem to have a config option.
I'd be interested in other people's thoughts on the pros and cons.

Thanks,
NeilBrown


---

NeilBrown (32):
      lustre: remove outdated comments about ->ap_* functions.
      lustre: ptlrpc: remove ptlrpc_prep_bulk_frag
      lustre: ptlrpc: make ptlrpc_bulk_frag_ops always const.
      lustre: ptlrpc: remove inline on non-inlined functions.
      lustre: ptlrpc: drop support for KVEC bulk descriptors.
      lustre: ptlrpc: discard BULK_BUF types
      lustre: ptlrpc: remove *GET*KIOV macros and fields.
      lustre: ptlrpc: simplify bd_vec access.
      lustre: lnet: discard LNET_MD_PHYS
      lustre: lnet: discard LNET_MD_IOVEC
      lustre: lnet: don't embed whole lnet_md in lnet_event
      lustre: lnet: merge lnet_md_alloc into lnet_md_build.
      lustre: lnet: always put a page list into struct lnet_libmd.
      lustre: lnet: discard kvec option from lnet_libmd.
      lustre: lnet: remove msg_iov from lnet_msg.
      lustre: lnet: simplify ksock_tx.
      lustre: socklnd: discard tx_iov.
      lustre: socklnd: don't fall-back to tcp_sendpage.
      lustre: socklnd: discard kiblnd_setup_rd_iov
      lustre: lnet: discard lnet_kvaddr_to_page
      lustre: ptlrpc: discard a server-only waitq.
      lustre: ptlrpc: simplify locking in ptlrpc_add_rqs_to_pool()
      lustre: ptlrpc: make ptlrpc_last_xid an atomic64_t
      lustre: ptlrpc: discard cb_list and ptlrpc_set_cbdata;
      lustre: incorporate BUILD_BUG_ON into ptlrpc_req_async_args()
      lustre: ptlrpc: don't use list_for_each_entry_safe unnecessarily.
      lustre: don't call unshare_fs_struct()
      lustre: don't declare extern variables in C files.
      lustre: introduce CONFIG_LUSTRE_FS_POSIX_ACL
      lustre: remove some "#ifdef CONFIG*" from .c files.
      lustre: mdc: create mdc_acl.c
      lustre: mgc: remove llog_process_lock


 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   29 ---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    6 -
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |   25 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  123 +----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   17 --
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   69 ++----
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   28 +--
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   17 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  220 +++++++-------------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   21 --
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    4 
 drivers/staging/lustre/lnet/lnet/lo.c              |   17 --
 drivers/staging/lustre/lnet/lnet/peer.c            |   10 -
 drivers/staging/lustre/lnet/lnet/router.c          |    2 
 drivers/staging/lustre/lnet/selftest/rpc.c         |    5 
 drivers/staging/lustre/lustre/Kconfig              |   11 +
 drivers/staging/lustre/lustre/include/lustre_acl.h |    6 -
 drivers/staging/lustre/lustre/include/lustre_net.h |   96 +--------
 drivers/staging/lustre/lustre/include/obd.h        |   32 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    3 
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    2 
 drivers/staging/lustre/lustre/llite/Makefile       |    2 
 .../staging/lustre/lustre/llite/llite_internal.h   |   33 +++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   39 +---
 drivers/staging/lustre/lustre/llite/xattr.c        |    4 
 drivers/staging/lustre/lustre/mdc/Makefile         |    1 
 drivers/staging/lustre/lustre/mdc/mdc_acl.c        |   48 ++++
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   10 +
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    7 -
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   67 +-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    8 -
 drivers/staging/lustre/lustre/obdclass/llog.c      |    3 
 drivers/staging/lustre/lustre/osc/osc_internal.h   |    4 
 drivers/staging/lustre/lustre/osc/osc_io.c         |    3 
 drivers/staging/lustre/lustre/osc/osc_page.c       |    4 
 drivers/staging/lustre/lustre/osc/osc_request.c    |   31 +--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  151 ++++----------
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   22 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   21 +-
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |   21 +-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    5 
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    6 -
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   14 +
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   18 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |   12 -
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 
 47 files changed, 450 insertions(+), 835 deletions(-)
 create mode 100644 drivers/staging/lustre/lustre/mdc/mdc_acl.c

--
Signature
