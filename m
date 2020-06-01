From: James Simmons <jsimmons@infradead.org>
Date: Mon, 1 Jun 2020 23:52:19 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/45] lustre: merged OpenSFS client
 patches from April 30 to today
In-Reply-To: <87sgfj6ypq.fsf@notabene.neil.brown.name>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
 <87sgfj6ypq.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.2006012345440.1967@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > Merge the client side patches that landed to the OpenSFS
> > tree since Apirl 30 to today. Include a fid missing patches
> > as well and one patch to fix issues with 2 patches from the
> > earlier 600+ patch set. Please review to ensure their correctness.
> 
> Hi James,
> I tried applying these and hit lots of conflicts.
> What tree are they on top of?

This is based off the top of my tree. Currently I'm using my tree as the 
OpenSFS version of the Linux client so I only add things that land. Your
tree is more the development / prototype tree since it has not yet landed
things. So most likely its the LNet LU-13004 work that is conflicting.
I also run the patches by checkpatch which has the LNET comment change 
that  wasn't in the OpenSFS branch until just recently; OpenSFS commit
d3f1ceeb123da9603cd5ee3acbd4ee638a995f10. That should reduce the conflicts
going forward. We are getting to the point in which both our trees are
almost in sync ;-) 

> Thanks,
> NeilBrown
> 
> 
> >
> > Alexander Boyko (1):
> >   lustre: llog: allow delete of zero size llog
> >
> > Amir Shehata (2):
> >   lnet: restrict gateway selection
> >   lnet: use the same src nid for discovery
> >
> > Andreas Dilger (5):
> >   lustre: llite: verify truncated xattr is handled
> >   lustre: obd: fix printing of client connection UUID
> >   lustre: llite: restore ll_dcompare()
> >   lustre: ldlm: use proper units for timeouts
> >   lustre: lmv: do not print MDTs that are inactive
> >
> > Andriy Skulysh (1):
> >   lustre: ptlrpc: connect to MDT stucks
> >
> > Bobi Jam (2):
> >   lustre: lov: lov_io_sub_init()) ASSERTION
> >   lustre: llite: do not flush COW pages from mapping
> >
> > Chris Horn (2):
> >   lnet: Introduce constant for the lolnd NID
> >   lnet: Add MD options for response tracking
> >
> > James Simmons (2):
> >   lustre: cleanups and bug fixes
> >   lnet: stop using struct timeval
> >
> > Lai Siyao (3):
> >   lustre: uapi: add OBD_CONNECT2_FIDMAP
> >   lustre: dne: support directory restripe
> >   lustre: dne: improve temp file name check
> >
> > Mr NeilBrown (13):
> >   lnet: merge lnet_md_alloc into lnet_md_build.
> >   lnet: always put a page list into struct lnet_libmd
> >   lnet: discard kvec option from lnet_libmd.
> >   lnet: remove msg_iov from lnet_msg.
> >   lnet: o2iblnd: discard kiblnd_setup_rd_iov
> >   lustre: Remove inappropriate uses of BIT() macro.
> >   lnet: libcfs: use BIT() macro where appropriate
> >   lustre: llite: clean up pcc_layout_wait()
> >   lustre: misc: declare static chars as const where possible.
> >   lnet: use kmem_cache_zalloc as appropriate.
> >   lnet: remove lnet_extract_iov()
> >   lnet: simplify ksock_tx.
> >   lnet: socklnd: discard tx_iov.
> >
> > NeilBrown (2):
> >   lustre: fid: revert seq_client_rpc patch.
> >   lustre: fld: convert cache_flush file to LPROC_SEQ_FOPS
> >
> > Oleg Drokin (3):
> >   lustre: ptlrpc: return proper write count from ping_store
> >   lustre: osc: Do not wait for grants for too long
> >   lustre: osc: Ensure immediate departure of sync write pages
> >
> > Qian Yingjin (1):
> >   lustre: Send file creation time to clients
> >
> > Sebastien Buisson (2):
> >   lustre: sec: check permissions for changelogs access
> >   lustre: mgc: protect from NULL exp in mgc_enqueue()
> >
> > Sergey Cheremencev (1):
> >   lustre: quota: quota pools for OSTs
> >
> > Shaun Tancheff (1):
> >   lustre: all: Cleanup LASSERTF uses missing newlines
> >
> > Swapnil Pimpale (1):
> >   lustre: fallocate: Implement fallocate preallocate operation
> >
> > Wang Shilong (3):
> >   lustre: llite: fix to make jobstats work for async ra
> >   lustre: llite: fix possible divide zero in ll_use_fast_io()
> >   lustre: llite: check if page truncated in ll_write_begin()
> >
> >  fs/lustre/fid/fid_request.c             |  12 +--
> >  fs/lustre/fld/fld_cache.c               |  40 --------
> >  fs/lustre/fld/fld_internal.h            |   7 --
> >  fs/lustre/fld/lproc_fld.c               |  31 +++---
> >  fs/lustre/include/cl_object.h           |  44 ++++++++-
> >  fs/lustre/include/lu_object.h           |  16 +--
> >  fs/lustre/include/lustre_dlm.h          |  17 ++--
> >  fs/lustre/include/lustre_import.h       |   4 +-
> >  fs/lustre/include/lustre_lmv.h          |  94 ++++++++++++++++--
> >  fs/lustre/include/lustre_req_layout.h   |   3 +
> >  fs/lustre/include/lustre_swab.h         |   2 +-
> >  fs/lustre/include/obd_support.h         |   5 +-
> >  fs/lustre/include/obd_target.h          |  54 ++++++++++
> >  fs/lustre/ldlm/ldlm_lockd.c             |   3 +-
> >  fs/lustre/ldlm/ldlm_request.c           |   1 +
> >  fs/lustre/ldlm/ldlm_resource.c          |  11 ++-
> >  fs/lustre/llite/dcache.c                |  56 ++++++++---
> >  fs/lustre/llite/dir.c                   |  33 +++++--
> >  fs/lustre/llite/file.c                  |  84 +++++++++++++++-
> >  fs/lustre/llite/lcommon_cl.c            |   2 +
> >  fs/lustre/llite/llite_internal.h        |   6 +-
> >  fs/lustre/llite/llite_lib.c             |   6 +-
> >  fs/lustre/llite/llite_mmap.c            |   2 +-
> >  fs/lustre/llite/lproc_llite.c           |  19 ++--
> >  fs/lustre/llite/namei.c                 |   5 +-
> >  fs/lustre/llite/pcc.c                   |  17 ++--
> >  fs/lustre/llite/rw.c                    |  13 ++-
> >  fs/lustre/llite/rw26.c                  |  16 ++-
> >  fs/lustre/llite/statahead.c             |   2 +-
> >  fs/lustre/llite/vvp_io.c                |  19 ++--
> >  fs/lustre/llite/vvp_object.c            |   2 +-
> >  fs/lustre/llite/xattr.c                 |  15 ++-
> >  fs/lustre/lmv/lmv_obd.c                 |  66 +++++++++----
> >  fs/lustre/lov/lov_cl_internal.h         |   6 +-
> >  fs/lustre/lov/lov_io.c                  |  31 ++++--
> >  fs/lustre/mdc/mdc_changelog.c           |   1 +
> >  fs/lustre/mdc/mdc_request.c             |  41 +++++---
> >  fs/lustre/mgc/mgc_request.c             |  11 ++-
> >  fs/lustre/obdclass/cl_page.c            |   1 -
> >  fs/lustre/obdclass/class_obd.c          |  35 +++----
> >  fs/lustre/obdclass/llog.c               |   9 +-
> >  fs/lustre/obdclass/llog_cat.c           |   3 +-
> >  fs/lustre/obdclass/lprocfs_status.c     |   8 +-
> >  fs/lustre/obdclass/obd_mount.c          |   2 +-
> >  fs/lustre/osc/osc_cache.c               |  33 ++++++-
> >  fs/lustre/osc/osc_internal.h            |   3 +
> >  fs/lustre/osc/osc_io.c                  |  56 +++++++++--
> >  fs/lustre/osc/osc_request.c             |  70 ++++++++++++-
> >  fs/lustre/ptlrpc/client.c               |   2 +-
> >  fs/lustre/ptlrpc/events.c               |   2 +-
> >  fs/lustre/ptlrpc/import.c               |   4 +-
> >  fs/lustre/ptlrpc/layout.c               |  26 ++++-
> >  fs/lustre/ptlrpc/llog_client.c          |   4 +
> >  fs/lustre/ptlrpc/lproc_ptlrpc.c         |   4 +-
> >  fs/lustre/ptlrpc/pack_generic.c         |  16 ++-
> >  fs/lustre/ptlrpc/ptlrpc_internal.h      |  19 ++++
> >  fs/lustre/ptlrpc/wiretest.c             |  16 ++-
> >  include/linux/lnet/lib-lnet.h           |  56 +----------
> >  include/linux/lnet/lib-types.h          |  15 +--
> >  include/uapi/linux/lnet/lnet-types.h    |  11 +++
> >  include/uapi/linux/lnet/lnetst.h        |   8 +-
> >  include/uapi/linux/lustre/lustre_idl.h  |  28 ++++--
> >  include/uapi/linux/lustre/lustre_user.h |  51 +++++++++-
> >  net/lnet/klnds/o2iblnd/o2iblnd_cb.c     | 122 +++--------------------
> >  net/lnet/klnds/socklnd/socklnd.h        |  16 +--
> >  net/lnet/klnds/socklnd/socklnd_cb.c     |  68 +++++--------
> >  net/lnet/klnds/socklnd/socklnd_lib.c    |  32 +++---
> >  net/lnet/klnds/socklnd/socklnd_proto.c  |  10 +-
> >  net/lnet/libcfs/debug.c                 |   2 +-
> >  net/lnet/libcfs/libcfs_string.c         |   4 +-
> >  net/lnet/libcfs/module.c                |  17 ++--
> >  net/lnet/lnet/api-ni.c                  |  16 +--
> >  net/lnet/lnet/config.c                  |  16 +--
> >  net/lnet/lnet/lib-md.c                  | 168 ++++++++++++++++----------------
> >  net/lnet/lnet/lib-me.c                  |   2 +-
> >  net/lnet/lnet/lib-move.c                | 167 ++++++++++++++-----------------
> >  net/lnet/lnet/lib-msg.c                 |   5 +-
> >  net/lnet/lnet/lib-socket.c              |  34 ++-----
> >  net/lnet/lnet/lo.c                      |  17 +---
> >  net/lnet/lnet/peer.c                    |  17 +++-
> >  net/lnet/lnet/router.c                  |   2 +-
> >  net/lnet/selftest/conctl.c              |   1 -
> >  net/lnet/selftest/conrpc.c              |   6 +-
> >  net/lnet/selftest/conrpc.h              |   1 -
> >  net/lnet/selftest/console.h             |   1 -
> >  85 files changed, 1201 insertions(+), 802 deletions(-)
> >  create mode 100644 fs/lustre/include/obd_target.h
> >
> > -- 
> > 1.8.3.1
> 
