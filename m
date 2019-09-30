From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:19 -0400
Subject: [lustre-devel] [PATCH 000/151] lustre: update to 2.11 support
Message-ID: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patchset covers 3 areas. The fix 6 patches resolves critical
bugs in the linux client. Mainly for handling of LNet with secondary
IP aliases as well as an RCU issue reported with debugging enabled.
This consoldation of IP handling makes any kernel API changes in the
future easier to handle.

The last 9 patches cover patches in the lustre-testing that landed
to the OpenSFS branch.

The rest of the patches cover all the patches missing from the
Lustre 2.11 release. I have done extentsive testing of these
patches (sanity, sanity-pfl, sanity-dom, sanity-pfl). Only
regression I saw was sanity-flr 200 which needs to be investiaged.
So we are in very good shape.

Alex Zhuravlev (1):
  lustre: support for gcc8

Alexander Boyko (2):
  lustre: hsm: don't release with wrong size
  lustre: obd: add check to obd_statfs

Amir Shehata (8):
  lnet: fix memory leak and lnet_interfaces_max
  lnet: decref on peer after use
  lnet: rediscover peer if it changed
  lnet: resolve unsafe list access
  lnet: don't discover loopback interface
  lnet: reduce logging severity
  lnet: safe access in debug print
  lnet: reduce discovery timeout

Andreas Dilger (11):
  lustre: seq: make seq_proc_write_common() safer
  lustre: llog: consolidate common error checking
  lustre: llite: increase whole-file readahead to RPC size
  lustre: ldlm: remove liblustre remnants
  lustre: misc: replace LASSERT() with BUILD_BUG_ON()
  lustre: lov: allow lov.*.stripe{size,count}=-1 param
  lustre: idl: clean up and document ptlrpc structures
  lustre: idl: remove obsolete RPC MSG flags
  lustre: misc: update Intel copyright messages for 2017
  lustre: idl: add PTLRPC definitions to enum
  lustre: uapi: rename LCM_FL_NOT_FLR to LCM_FL_NONE

Andriy Skulysh (1):
  lustre: llite: NULL pointer dereference in cl_object_top()

Ben Evans (2):
  lustre: jobstats: move jobstats code into separate file.
  lustre: llite: Add exit for filedata allocation failed

Bobi Jam (4):
  lustre: flr: instantiate component for truncate
  lustre: flr: split a mirror from mirrored file
  lustre: flr: layout truncate compatibility
  lustre: osc: add a bit to indicate osc_page in cache tree

Bruno Faccini (5):
  lnet: Allocate MEs and small MDs in own kmem_caches
  lustre: obd: free obd_svc_stats when all users are gone
  lustre: llite: avoid live-lock when concurrent mmap()s
  lustre: ptlrpc: allow to limit number of service's rqbds
  lnet: ensure peer put back on dc request queue

Dmitry Eremin (1):
  lnet: Fix lost lock

Dominique Martinet (1):
  lustre: lov: fill no-extent fiemap on object with no stripe.

Emoly Liu (1):
  lustre: fid: improve seq allocation error messages

Erich Focht (1):
  lustre: llite: enable readahead for small read_ahead_per_file

Fan Yong (3):
  lustre: scrub: general framework for OI scrub
  lustre: mdc: interruptable during RPC retry for EINPROGRESS
  lustre: acl: prepare small buffer for ACL RPC reply

Gregoire Pichon (1):
  lustre: ldlm: testcases for multiple modify RPCs feature

Hongchao Zhang (1):
  lustre: ldlm: fix export reference

James Simmons (20):
  lnet: fix needed headers for lnet headers
  lnet: ksocklnd: add secondary IP address handling
  lnet: o2iblnd: add secondary IP address handling
  lnet: consoldate secondary IP address handling
  lustre: all: remove all Sun license and URL references
  lustre: ptlrpc: change cr_sent_tv from timespec to ktime
  lustre: ldlm: don't use jiffies as sysfs parameter
  lustre: ptlrpc: migrate pinger to 64 bit time
  lustre: ldlm: migrate the rest of the code to 64 bit time
  lustre: llite: sync bdi sysfs name with lustre sysfs tree
  lnet: libcfs: call proper crypto algo when keys are passed in
  lustre: sec: migrate to 64 bit time
  lustre: llite: change lli_glimpse_time to ktime
  lustre: osc: migrate to 64 bit time
  lustre: libcfs: remove cfs_time_XXX_64 wrappers
  lustre: address issues raised by gcc7
  lustre: obd: remove s2dhms time function
  lustre: obd: fix statfs handling
  lustre: update version to 2.10.99
  lustre: ptlrpc: clarify 64 bit time usage

Jeremy Filizetti (1):
  lustre: ldlm: Don't check opcode with NULL rq_reqmsg

Jinshan Xiong (17):
  lustre: lov: take lov layout lock for I/O with ignore_layout
  lustre: lov: pack lsm_flags from layout
  lustre: clio: introduce CIT_GLIMPSE for glimpse
  lustre: flr: add infrastructure to create a new mirror
  lustre: clio: no glimpse for data immutable file
  lustre: flr: read support for flr
  lustre: lov: rework write intent on componect instantiation
  lustre: ptlrpc: use lu_extent in layout_intent
  lustre: flr: Send write intent RPC to mdt
  lustre: flr: extend DATA_VERSION API to read layout version
  lustre: lov: skip empty pages in lov_io_submit()
  lustre: flr: mirror read and write
  lustre: flr: resync support and test tool
  lustre: flr: randomize mirror pick
  lustre: flr: comp-flags support when creating mirrors
  lustre: flr: revise lease API
  lustre: llite: deny 2.10 clients to open mirrored files

John L. Hammond (5):
  lustre: ldlm: assume OBD_CONNECT_IBITS
  lustre: llite: assume OBD_CONNECT_ATTRFID
  lustre: llite: simplify ll_inode_revalidate()
  lustre: clio: remove unused cl_lock layers
  lustre: hsm: filter kkuc write by client UUID

Kit Westneat (1):
  lnet: fix contiguous range support

Lai Siyao (6):
  lustre: statahead: support striped directory
  lustre: readdir: improve striped readdir
  lustre: lmv: stripe dir page may be released mistakenly
  lustre: mdc: don't assert on name pack
  lustre: dne: allow mkdir with specific MDTs
  lustre: recovery: support setstripe replay

Li Wei (1):
  lustre: ptlrpc: Fix an rq_no_reply assertion failure

Matthew Sanderson (1):
  lustre: mdc: Add an additional set of 64 changelog flags

Mikhail Pershin (1):
  lustre: dom: support DATA_VERSION IO type

Mikhal Pershin (15):
  lustre: osc: prepare OSC code to be used from MDC
  lustre: mdc: add cl_device to the MDC
  lustre: lov: add MDT target to the LOV device
  lustre: mdt: IO request handling in MDT
  lustre: osc: common client setup/cleanup
  lustre: mdc: add IO methods to the MDC
  lustre: lvbo: pass lock as parameter to lvbo_update()
  lustre: mds: add IO locking to the MDC and MDT
  lustre: mdc: add IO stats in mdc
  lustre: lov: add Data-on-MDT tests and fixes
  lustre: mdc: use generic grant code at MDT
  lustre: mds: combine DoM bit with other IBITS
  lustre: llite: check layout size after cl_object_layout_get
  lustre: mdc: implement own mdc_io_fsync_start()
  lustre: mdc: high-priority request handling for DOM

NeilBrown (13):
  lustre: fix signal handling in abortable waits.
  lustre: ptlrpc: add watchdog for ptlrpc service threads.
  lustre: handles: discard h_owner in favour of h_ops
  lustre: ldlm: Remove use of SLAB_DESTROY_BY_RCU for ldlm lock slab
  lustre: ldlm: simplify lock_mode_to_index()
  lustre: ptlrpc: use list_move where appropriate.
  lustre: ptlrpc: simplify locking in ptlrpc_add_rqs_to_pool()
  lustre: ptlrpc: incorporate BUILD_BUG_ON into ptlrpc_req_async_args()
  lustre: introduce CONFIG_LUSTRE_FS_POSIX_ACL
  lustre: ptlrpc: discard a server-only waitq.
  lustre: llite: remove // comments.
  lustre: remove outdated comments about ->ap_* functions.
  lustre: clean up some comment alignment.

Olaf Weber (1):
  lnet: Handle ping buffer with only loopback NID

Patrick Farrell (8):
  lustre: ldlm: Use interval tree to update kms
  lustre: llite: Reduce overhead for ll_do_fast_read
  lustre: llite: Implement ladvise lockahead
  lustre: brw: add short io osc/ost transfer.
  lustre: vvp: Print discarded page warning on -EIO
  lustre: clio: Use readahead for partial page write
  lustre: llite: Add tiny write support
  lustre: llite: Disable tiny writes for append

Qian Yingjin (1):
  lustre: misc: Wrong checksum return value

Sebastien Buisson (8):
  lustre: ptlrpc: remove incorrect pid printing
  lustre: mdc: add uid/gid to Changelogs entries
  lustre: lustre: move LA_* flags to lustre_user.h
  lustre: mdc: add client NID to Changelogs entries
  lustre: mdc: implement CL_OPEN for Changelogs
  lustre: mdc: add CL_GETXATTR for Changelogs
  lustre: uapi: record denied OPEN in Changelogs
  lustre: uapi: replace FMODE_{READ,WRITE} with MDS_* equivs

Sonia Sharma (1):
  lnet: Remove LASSERT on userspace data

Steve Guminski (2):
  lustre: ptlrpc: Use C99 initializer in ptlrpc_register_rqbd()
  lnet: selftest: Use C99 struct initializer in framework.c

Vladimir Saveliev (2):
  lustre: llite: have ll_write_end to sync for DIO
  lustre: llite: fix mount error handing

Wang Di (4):
  lustre: fld: resend seq lookup RPC if it is on LWP
  lustre: fld: retry fld rpc even for ESHUTDOWN
  lustre: fld: retry fld rpc until the import is closed
  lustre: fld: fld client lookup should retry

 Documentation/lustre/ladvise_lockahead.txt         |  304 ++++
 fs/lustre/Kconfig                                  |   11 +
 fs/lustre/fid/fid_internal.h                       |    2 +-
 fs/lustre/fid/fid_request.c                        |   12 +-
 fs/lustre/fid/lproc_fid.c                          |   14 +-
 fs/lustre/fld/fld_request.c                        |   42 +-
 fs/lustre/include/cl_object.h                      |  106 +-
 fs/lustre/include/lprocfs_status.h                 |   28 +-
 fs/lustre/include/lu_object.h                      |   25 +-
 fs/lustre/include/lu_ref.h                         |    2 +-
 fs/lustre/include/lustre_acl.h                     |    8 +-
 fs/lustre/include/lustre_disk.h                    |    8 +-
 fs/lustre/include/lustre_dlm.h                     |   88 +-
 fs/lustre/include/lustre_dlm_flags.h               |   54 +-
 fs/lustre/include/lustre_export.h                  |   37 +-
 fs/lustre/include/lustre_fid.h                     |    9 +-
 fs/lustre/include/lustre_handles.h                 |    9 +-
 fs/lustre/include/lustre_import.h                  |   28 +-
 fs/lustre/include/lustre_kernelcomm.h              |   14 +-
 fs/lustre/include/lustre_lib.h                     |    8 +-
 fs/lustre/include/lustre_linkea.h                  |    2 +-
 fs/lustre/include/lustre_lmv.h                     |    2 +-
 fs/lustre/include/lustre_log.h                     |    2 +-
 fs/lustre/include/lustre_mdc.h                     |    2 +-
 fs/lustre/include/lustre_mds.h                     |    7 +-
 fs/lustre/include/lustre_net.h                     |   91 +-
 .../osc_cl_internal.h => include/lustre_osc.h}     |  440 +++++-
 fs/lustre/include/lustre_req_layout.h              |    8 +-
 fs/lustre/include/lustre_sec.h                     |    4 +-
 fs/lustre/include/lustre_swab.h                    |    3 +-
 fs/lustre/include/obd.h                            |   62 +-
 fs/lustre/include/obd_class.h                      |   45 +-
 fs/lustre/include/obd_support.h                    |   13 +-
 fs/lustre/ldlm/ldlm_extent.c                       |   71 +-
 fs/lustre/ldlm/ldlm_flock.c                        |    2 +-
 fs/lustre/ldlm/ldlm_inodebits.c                    |   22 +
 fs/lustre/ldlm/ldlm_internal.h                     |    9 +-
 fs/lustre/ldlm/ldlm_lib.c                          |   18 +-
 fs/lustre/ldlm/ldlm_lock.c                         |   30 +-
 fs/lustre/ldlm/ldlm_lockd.c                        |   14 +-
 fs/lustre/ldlm/ldlm_plain.c                        |    2 +-
 fs/lustre/ldlm/ldlm_pool.c                         |    6 +-
 fs/lustre/ldlm/ldlm_request.c                      |   90 +-
 fs/lustre/ldlm/ldlm_resource.c                     |   31 +-
 fs/lustre/llite/Makefile                           |    4 +-
 fs/lustre/llite/dcache.c                           |    2 +-
 fs/lustre/llite/dir.c                              |   25 +-
 fs/lustre/llite/file.c                             | 1104 +++++++++++----
 fs/lustre/llite/glimpse.c                          |   58 +-
 fs/lustre/llite/lcommon_cl.c                       |   12 +-
 fs/lustre/llite/lcommon_misc.c                     |    5 +-
 fs/lustre/llite/llite_internal.h                   |   60 +-
 fs/lustre/llite/llite_lib.c                        |  104 +-
 fs/lustre/llite/llite_mmap.c                       |   14 +-
 fs/lustre/llite/llite_nfs.c                        |    2 +-
 fs/lustre/llite/lproc_llite.c                      |   62 +-
 fs/lustre/llite/namei.c                            |   61 +-
 fs/lustre/llite/rw.c                               |   98 +-
 fs/lustre/llite/rw26.c                             |  157 ++-
 fs/lustre/llite/statahead.c                        |   14 +-
 fs/lustre/llite/vvp_dev.c                          |    6 -
 fs/lustre/llite/vvp_internal.h                     |   15 +-
 fs/lustre/llite/vvp_io.c                           |   89 +-
 fs/lustre/llite/vvp_lock.c                         |   87 --
 fs/lustre/llite/vvp_object.c                       |   10 +-
 fs/lustre/llite/vvp_page.c                         |   15 +-
 fs/lustre/llite/xattr.c                            |    6 +-
 fs/lustre/llite/xattr_cache.c                      |    2 +-
 fs/lustre/lmv/lmv_intent.c                         |    2 +-
 fs/lustre/lmv/lmv_internal.h                       |    2 +-
 fs/lustre/lmv/lmv_obd.c                            |  538 +++----
 fs/lustre/lmv/lproc_lmv.c                          |    2 +-
 fs/lustre/lov/Makefile                             |    2 +-
 fs/lustre/lov/lov_cl_internal.h                    |  273 +++-
 fs/lustre/lov/lov_dev.c                            |  284 +++-
 fs/lustre/lov/lov_ea.c                             |   24 +-
 fs/lustre/lov/lov_internal.h                       |   13 +-
 fs/lustre/lov/lov_io.c                             |  490 ++++++-
 fs/lustre/lov/lov_lock.c                           |   17 +-
 fs/lustre/lov/lov_merge.c                          |    2 +-
 fs/lustre/lov/lov_obd.c                            |   45 +-
 fs/lustre/lov/lov_object.c                         |  842 +++++++----
 fs/lustre/lov/lov_offset.c                         |    5 +-
 fs/lustre/lov/lov_pack.c                           |    4 +-
 fs/lustre/lov/lov_page.c                           |   17 +-
 fs/lustre/lov/lov_pool.c                           |    2 +-
 fs/lustre/lov/lov_request.c                        |    4 +-
 fs/lustre/lov/lovsub_lock.c                        |   81 --
 fs/lustre/lov/lovsub_object.c                      |    4 +-
 fs/lustre/lov/lproc_lov.c                          |    4 +-
 fs/lustre/mdc/Makefile                             |    1 +
 fs/lustre/mdc/lproc_mdc.c                          |  320 ++++-
 fs/lustre/mdc/mdc_changelog.c                      |   11 +-
 fs/lustre/mdc/mdc_dev.c                            | 1479 ++++++++++++++++++++
 fs/lustre/mdc/mdc_internal.h                       |   12 +-
 fs/lustre/mdc/mdc_lib.c                            |   45 +-
 fs/lustre/mdc/mdc_locks.c                          |  130 +-
 fs/lustre/mdc/mdc_reint.c                          |   78 +-
 fs/lustre/mdc/mdc_request.c                        |  206 ++-
 fs/lustre/mgc/lproc_mgc.c                          |    2 +-
 fs/lustre/mgc/mgc_internal.h                       |    2 +-
 fs/lustre/mgc/mgc_request.c                        |    4 +-
 fs/lustre/obdclass/Makefile                        |    3 +-
 fs/lustre/obdclass/cl_internal.h                   |    2 +-
 fs/lustre/obdclass/cl_io.c                         |   18 +-
 fs/lustre/obdclass/cl_lock.c                       |   11 +-
 fs/lustre/obdclass/cl_object.c                     |   14 +-
 fs/lustre/obdclass/cl_page.c                       |   15 +-
 fs/lustre/obdclass/class_obd.c                     |   45 +-
 fs/lustre/obdclass/genops.c                        |   36 +-
 fs/lustre/obdclass/jobid.c                         |   86 ++
 fs/lustre/obdclass/kernelcomm.c                    |   28 +-
 fs/lustre/obdclass/linkea.c                        |    2 +-
 fs/lustre/obdclass/llog.c                          |    4 +-
 fs/lustre/obdclass/llog_cat.c                      |   50 +-
 fs/lustre/obdclass/llog_internal.h                 |    2 +-
 fs/lustre/obdclass/llog_swab.c                     |    2 +-
 fs/lustre/obdclass/lprocfs_status.c                |  131 +-
 fs/lustre/obdclass/lu_object.c                     |    2 +-
 fs/lustre/obdclass/lu_ref.c                        |    2 +-
 fs/lustre/obdclass/lustre_handles.c                |    8 +-
 fs/lustre/obdclass/lustre_peer.c                   |    2 +-
 fs/lustre/obdclass/obd_config.c                    |   44 +-
 fs/lustre/obdclass/obd_mount.c                     |    2 +-
 fs/lustre/obdclass/obd_sysfs.c                     |    2 +-
 fs/lustre/obdclass/obdo.c                          |    2 +-
 fs/lustre/obdecho/debug.c                          |    2 +-
 fs/lustre/obdecho/echo_client.c                    |    4 +-
 fs/lustre/osc/lproc_osc.c                          |   11 +-
 fs/lustre/osc/osc_cache.c                          |   61 +-
 fs/lustre/osc/osc_dev.c                            |   40 +-
 fs/lustre/osc/osc_internal.h                       |  168 +--
 fs/lustre/osc/osc_io.c                             |  151 +-
 fs/lustre/osc/osc_lock.c                           |  190 +--
 fs/lustre/osc/osc_object.c                         |   90 +-
 fs/lustre/osc/osc_page.c                           |   97 +-
 fs/lustre/osc/osc_quota.c                          |    4 +-
 fs/lustre/osc/osc_request.c                        |  453 +++---
 fs/lustre/ptlrpc/client.c                          |   56 +-
 fs/lustre/ptlrpc/events.c                          |    2 +-
 fs/lustre/ptlrpc/import.c                          |   87 +-
 fs/lustre/ptlrpc/layout.c                          |   46 +-
 fs/lustre/ptlrpc/llog_net.c                        |    2 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c                    |   68 +-
 fs/lustre/ptlrpc/niobuf.c                          |   15 +-
 fs/lustre/ptlrpc/pack_generic.c                    |  125 +-
 fs/lustre/ptlrpc/pinger.c                          |   44 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h                 |    4 +-
 fs/lustre/ptlrpc/ptlrpc_module.c                   |    2 +-
 fs/lustre/ptlrpc/ptlrpcd.c                         |    4 +-
 fs/lustre/ptlrpc/recover.c                         |    2 +-
 fs/lustre/ptlrpc/sec.c                             |    3 +-
 fs/lustre/ptlrpc/sec_bulk.c                        |   24 +-
 fs/lustre/ptlrpc/sec_config.c                      |    2 +-
 fs/lustre/ptlrpc/sec_gc.c                          |    2 +-
 fs/lustre/ptlrpc/sec_null.c                        |    6 +-
 fs/lustre/ptlrpc/sec_plain.c                       |    8 +-
 fs/lustre/ptlrpc/service.c                         |  180 ++-
 fs/lustre/ptlrpc/wiretest.c                        |  271 +++-
 include/linux/libcfs/libcfs.h                      |    2 +-
 include/linux/libcfs/libcfs_cpu.h                  |    2 +-
 include/linux/libcfs/libcfs_debug.h                |    7 +-
 include/linux/libcfs/libcfs_fail.h                 |    1 +
 include/linux/libcfs/libcfs_hash.h                 |    2 +-
 include/linux/libcfs/libcfs_private.h              |    5 +-
 include/linux/libcfs/libcfs_string.h               |    2 +-
 include/linux/lnet/api.h                           |    2 +-
 include/linux/lnet/lib-lnet.h                      |   52 +-
 include/linux/lnet/lib-types.h                     |   16 +-
 include/uapi/linux/lnet/libcfs_debug.h             |    2 +-
 include/uapi/linux/lnet/libcfs_ioctl.h             |    2 +
 include/uapi/linux/lnet/lnet-dlc.h                 |    2 +-
 include/uapi/linux/lnet/lnet-types.h               |    2 +-
 include/uapi/linux/lnet/lnetctl.h                  |    3 +
 include/uapi/linux/lnet/lnetst.h                   |    2 +
 include/uapi/linux/lnet/nidstr.h                   |   10 +-
 include/uapi/linux/lustre/lustre_fid.h             |    2 +-
 include/uapi/linux/lustre/lustre_idl.h             |  384 ++---
 include/uapi/linux/lustre/lustre_ioctl.h           |    2 +-
 include/uapi/linux/lustre/lustre_ostid.h           |    2 +-
 include/uapi/linux/lustre/lustre_param.h           |   28 +-
 include/uapi/linux/lustre/lustre_user.h            |  608 +++++++-
 include/uapi/linux/lustre/lustre_ver.h             |    4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c                   |  173 +--
 net/lnet/klnds/o2iblnd/o2iblnd.h                   |   80 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c                |   89 +-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c         |    2 +-
 net/lnet/klnds/socklnd/socklnd.c                   |  140 +-
 net/lnet/klnds/socklnd/socklnd.h                   |    2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c                |   28 +-
 net/lnet/klnds/socklnd/socklnd_lib.c               |   10 +-
 net/lnet/klnds/socklnd/socklnd_proto.c             |    2 +-
 net/lnet/libcfs/debug.c                            |   11 +-
 net/lnet/libcfs/libcfs_cpu.c                       |    2 +-
 net/lnet/libcfs/libcfs_string.c                    |    2 +-
 net/lnet/libcfs/linux-crypto.c                     |   31 +-
 net/lnet/libcfs/module.c                           |   14 +-
 net/lnet/libcfs/tracefile.c                        |   10 +-
 net/lnet/libcfs/tracefile.h                        |    2 +-
 net/lnet/lnet/acceptor.c                           |    8 +-
 net/lnet/lnet/api-ni.c                             |  141 +-
 net/lnet/lnet/config.c                             |  129 +-
 net/lnet/lnet/lib-md.c                             |    4 +-
 net/lnet/lnet/lib-me.c                             |    2 +-
 net/lnet/lnet/lib-move.c                           |   38 +-
 net/lnet/lnet/lib-msg.c                            |    2 +-
 net/lnet/lnet/lib-ptl.c                            |    4 +-
 net/lnet/lnet/lib-socket.c                         |    2 +-
 net/lnet/lnet/lo.c                                 |    4 +-
 net/lnet/lnet/module.c                             |    2 +-
 net/lnet/lnet/net_fault.c                          |    2 +-
 net/lnet/lnet/nidstrings.c                         |  326 ++---
 net/lnet/lnet/peer.c                               |  128 +-
 net/lnet/lnet/router.c                             |   10 +-
 net/lnet/lnet/router_proc.c                        |    2 +-
 net/lnet/selftest/brw_test.c                       |    2 +-
 net/lnet/selftest/conrpc.c                         |    2 +-
 net/lnet/selftest/conrpc.h                         |   16 +-
 net/lnet/selftest/console.h                        |   96 +-
 net/lnet/selftest/framework.c                      |   58 +-
 net/lnet/selftest/rpc.c                            |    2 +-
 net/lnet/selftest/rpc.h                            |   28 +-
 net/lnet/selftest/selftest.h                       |   40 +-
 223 files changed, 10237 insertions(+), 4034 deletions(-)
 create mode 100644 Documentation/lustre/ladvise_lockahead.txt
 rename fs/lustre/{osc/osc_cl_internal.h => include/lustre_osc.h} (61%)
 delete mode 100644 fs/lustre/llite/vvp_lock.c
 delete mode 100644 fs/lustre/lov/lovsub_lock.c
 create mode 100644 fs/lustre/mdc/mdc_dev.c
 create mode 100644 fs/lustre/obdclass/jobid.c

-- 
1.8.3.1
