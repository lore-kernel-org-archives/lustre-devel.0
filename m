From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 14 Jun 2016 20:44:13 -0400
Subject: [lustre-devel] [PATCH 0/5] Lustre: Remove defunct SUN addresses
Message-ID: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

This patch removes a paragraph about contacting SUN Microsystems from
a lot of Lustre files since there's no more SUN Microsystems.

A pointer to GPLv2 URL is also switched from defunct sun.com to
gnu.org.

For a good measure a couple of places that refer to "Please contact Oracle"
are also removed since Oracle has nothing to do with Lustre anymore.

This patchset does not switch any trademarks or copyrights around since
I don't really work for the (assumed) current trademark holder and
if they care, they can submit a corrective patch themselves.
The copyrights are an even bigger mess I assume.

Oleg Drokin (5):
  staging/lustre: Remove the "Please contact SUN for GPL" from headers
  staging/lustre: Replace sun.com GPLv2 URL with gnu.org one.
  staging/lustre/lov: Fix gpl URL in lov_pool.c
  staging/lustre: Remove stray line from selftest/selftest.h
  staging/lustre/libcfs: Remove "Please contact Oracle" from header

 drivers/staging/lustre/include/linux/libcfs/curproc.h             | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs.h              | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h        | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h         | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h         | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h        | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h         | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_private.h      | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_string.h       | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_time.h         | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h     | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h        | 6 +-----
 drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h    | 6 +-----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c               | 6 +-----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h               | 6 +-----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c            | 6 +-----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c     | 6 +-----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c               | 6 +-----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c           | 6 +-----
 drivers/staging/lustre/lnet/libcfs/debug.c                        | 6 +-----
 drivers/staging/lustre/lnet/libcfs/fail.c                         | 4 ----
 drivers/staging/lustre/lnet/libcfs/hash.c                         | 6 +-----
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c                | 6 +-----
 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c          | 6 +-----
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c            | 6 +-----
 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c              | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c           | 6 +-----
 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c             | 6 +-----
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c        | 6 +-----
 drivers/staging/lustre/lnet/libcfs/module.c                       | 6 +-----
 drivers/staging/lustre/lnet/libcfs/prng.c                         | 6 +-----
 drivers/staging/lustre/lnet/libcfs/tracefile.c                    | 6 +-----
 drivers/staging/lustre/lnet/libcfs/tracefile.h                    | 6 +-----
 drivers/staging/lustre/lnet/libcfs/workitem.c                     | 6 +-----
 drivers/staging/lustre/lnet/lnet/acceptor.c                       | 6 +-----
 drivers/staging/lustre/lnet/lnet/api-ni.c                         | 6 +-----
 drivers/staging/lustre/lnet/lnet/config.c                         | 6 +-----
 drivers/staging/lustre/lnet/lnet/lib-eq.c                         | 6 +-----
 drivers/staging/lustre/lnet/lnet/lib-md.c                         | 6 +-----
 drivers/staging/lustre/lnet/lnet/lib-me.c                         | 6 +-----
 drivers/staging/lustre/lnet/lnet/lib-move.c                       | 6 +-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c                        | 6 +-----
 drivers/staging/lustre/lnet/lnet/lo.c                             | 6 +-----
 drivers/staging/lustre/lnet/lnet/module.c                         | 6 +-----
 drivers/staging/lustre/lnet/lnet/nidstrings.c                     | 6 +-----
 drivers/staging/lustre/lnet/lnet/peer.c                           | 6 +-----
 drivers/staging/lustre/lnet/selftest/brw_test.c                   | 6 +-----
 drivers/staging/lustre/lnet/selftest/conctl.c                     | 6 +-----
 drivers/staging/lustre/lnet/selftest/conrpc.c                     | 6 +-----
 drivers/staging/lustre/lnet/selftest/conrpc.h                     | 6 +-----
 drivers/staging/lustre/lnet/selftest/console.c                    | 6 +-----
 drivers/staging/lustre/lnet/selftest/console.h                    | 6 +-----
 drivers/staging/lustre/lnet/selftest/framework.c                  | 6 +-----
 drivers/staging/lustre/lnet/selftest/module.c                     | 6 +-----
 drivers/staging/lustre/lnet/selftest/ping_test.c                  | 6 +-----
 drivers/staging/lustre/lnet/selftest/rpc.c                        | 6 +-----
 drivers/staging/lustre/lnet/selftest/rpc.h                        | 6 +-----
 drivers/staging/lustre/lnet/selftest/selftest.h                   | 7 +------
 drivers/staging/lustre/lnet/selftest/timer.c                      | 6 +-----
 drivers/staging/lustre/lnet/selftest/timer.h                      | 6 +-----
 drivers/staging/lustre/lustre/fid/fid_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/fid/fid_lib.c                       | 6 +-----
 drivers/staging/lustre/lustre/fid/fid_request.c                   | 6 +-----
 drivers/staging/lustre/lustre/fid/lproc_fid.c                     | 6 +-----
 drivers/staging/lustre/lustre/fld/fld_cache.c                     | 6 +-----
 drivers/staging/lustre/lustre/fld/fld_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/fld/fld_request.c                   | 6 +-----
 drivers/staging/lustre/lustre/fld/lproc_fld.c                     | 6 +-----
 drivers/staging/lustre/lustre/include/cl_object.h                 | 6 +-----
 drivers/staging/lustre/lustre/include/interval_tree.h             | 6 +-----
 drivers/staging/lustre/lustre/include/linux/lustre_compat25.h     | 6 +-----
 drivers/staging/lustre/lustre/include/linux/lustre_lite.h         | 6 +-----
 .../staging/lustre/lustre/include/linux/lustre_patchless_compat.h | 6 +-----
 drivers/staging/lustre/lustre/include/linux/lustre_user.h         | 6 +-----
 drivers/staging/lustre/lustre/include/lprocfs_status.h            | 6 +-----
 drivers/staging/lustre/lustre/include/lu_object.h                 | 6 +-----
 drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h          | 6 +-----
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h         | 6 +-----
 drivers/staging/lustre/lustre/include/lustre/lustre_user.h        | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_acl.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_cfg.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_debug.h              | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_disk.h               | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_dlm.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_eacl.h               | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_export.h             | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_fid.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_fld.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_ha.h                 | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_handles.h            | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_import.h             | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_intent.h             | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_lib.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_lite.h               | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_log.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_mdc.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_mds.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_net.h                | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_param.h              | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_req_layout.h         | 6 +-----
 drivers/staging/lustre/lustre/include/lustre_sec.h                | 6 +-----
 drivers/staging/lustre/lustre/include/obd.h                       | 6 +-----
 drivers/staging/lustre/lustre/include/obd_cksum.h                 | 6 +-----
 drivers/staging/lustre/lustre/include/obd_class.h                 | 6 +-----
 drivers/staging/lustre/lustre/include/obd_support.h               | 6 +-----
 drivers/staging/lustre/lustre/ldlm/interval_tree.c                | 6 +-----
 drivers/staging/lustre/lustre/ldlm/l_lock.c                       | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c                  | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c                   | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c               | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h                | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c                     | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c                    | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c                   | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c                   | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c                    | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c                 | 6 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c                | 6 +-----
 drivers/staging/lustre/lustre/llite/dcache.c                      | 6 +-----
 drivers/staging/lustre/lustre/llite/dir.c                         | 6 +-----
 drivers/staging/lustre/lustre/llite/file.c                        | 6 +-----
 drivers/staging/lustre/lustre/llite/glimpse.c                     | 6 +-----
 drivers/staging/lustre/lustre/llite/lcommon_cl.c                  | 6 +-----
 drivers/staging/lustre/lustre/llite/lcommon_misc.c                | 6 +-----
 drivers/staging/lustre/lustre/llite/llite_close.c                 | 6 +-----
 drivers/staging/lustre/lustre/llite/llite_internal.h              | 6 +-----
 drivers/staging/lustre/lustre/llite/llite_lib.c                   | 6 +-----
 drivers/staging/lustre/lustre/llite/llite_mmap.c                  | 6 +-----
 drivers/staging/lustre/lustre/llite/llite_nfs.c                   | 6 +-----
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c                | 6 +-----
 drivers/staging/lustre/lustre/llite/lproc_llite.c                 | 6 +-----
 drivers/staging/lustre/lustre/llite/namei.c                       | 6 +-----
 drivers/staging/lustre/lustre/llite/remote_perm.c                 | 6 +-----
 drivers/staging/lustre/lustre/llite/rw.c                          | 6 +-----
 drivers/staging/lustre/lustre/llite/rw26.c                        | 6 +-----
 drivers/staging/lustre/lustre/llite/statahead.c                   | 6 +-----
 drivers/staging/lustre/lustre/llite/super25.c                     | 6 +-----
 drivers/staging/lustre/lustre/llite/symlink.c                     | 6 +-----
 drivers/staging/lustre/lustre/llite/vvp_dev.c                     | 6 +-----
 drivers/staging/lustre/lustre/llite/vvp_internal.h                | 6 +-----
 drivers/staging/lustre/lustre/llite/vvp_io.c                      | 6 +-----
 drivers/staging/lustre/lustre/llite/vvp_lock.c                    | 6 +-----
 drivers/staging/lustre/lustre/llite/vvp_object.c                  | 6 +-----
 drivers/staging/lustre/lustre/llite/vvp_page.c                    | 6 +-----
 drivers/staging/lustre/lustre/llite/xattr.c                       | 6 +-----
 drivers/staging/lustre/lustre/lmv/lmv_fld.c                       | 6 +-----
 drivers/staging/lustre/lustre/lmv/lmv_intent.c                    | 6 +-----
 drivers/staging/lustre/lustre/lmv/lmv_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c                       | 6 +-----
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c                     | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_cl_internal.h               | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_dev.c                       | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_ea.c                        | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_io.c                        | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_lock.c                      | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_merge.c                     | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_obd.c                       | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_object.c                    | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_offset.c                    | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_pack.c                      | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_page.c                      | 6 +-----
 drivers/staging/lustre/lustre/lov/lov_pool.c                      | 8 ++------
 drivers/staging/lustre/lustre/lov/lov_request.c                   | 6 +-----
 drivers/staging/lustre/lustre/lov/lovsub_dev.c                    | 6 +-----
 drivers/staging/lustre/lustre/lov/lovsub_io.c                     | 6 +-----
 drivers/staging/lustre/lustre/lov/lovsub_lock.c                   | 6 +-----
 drivers/staging/lustre/lustre/lov/lovsub_object.c                 | 6 +-----
 drivers/staging/lustre/lustre/lov/lovsub_page.c                   | 6 +-----
 drivers/staging/lustre/lustre/lov/lproc_lov.c                     | 6 +-----
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c                     | 6 +-----
 drivers/staging/lustre/lustre/mdc/mdc_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/mdc/mdc_lib.c                       | 6 +-----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c                     | 6 +-----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c                     | 6 +-----
 drivers/staging/lustre/lustre/mdc/mdc_request.c                   | 6 +-----
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c                     | 6 +-----
 drivers/staging/lustre/lustre/mgc/mgc_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c                   | 6 +-----
 drivers/staging/lustre/lustre/obdclass/acl.c                      | 6 +-----
 drivers/staging/lustre/lustre/obdclass/cl_internal.h              | 6 +-----
 drivers/staging/lustre/lustre/obdclass/cl_io.c                    | 6 +-----
 drivers/staging/lustre/lustre/obdclass/cl_lock.c                  | 6 +-----
 drivers/staging/lustre/lustre/obdclass/cl_object.c                | 6 +-----
 drivers/staging/lustre/lustre/obdclass/cl_page.c                  | 6 +-----
 drivers/staging/lustre/lustre/obdclass/class_obd.c                | 6 +-----
 drivers/staging/lustre/lustre/obdclass/debug.c                    | 6 +-----
 drivers/staging/lustre/lustre/obdclass/genops.c                   | 6 +-----
 drivers/staging/lustre/lustre/obdclass/kernelcomm.c               | 6 +-----
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c       | 6 +-----
 drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c         | 6 +-----
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c       | 6 +-----
 drivers/staging/lustre/lustre/obdclass/llog.c                     | 6 +-----
 drivers/staging/lustre/lustre/obdclass/llog_cat.c                 | 6 +-----
 drivers/staging/lustre/lustre/obdclass/llog_internal.h            | 6 +-----
 drivers/staging/lustre/lustre/obdclass/llog_obd.c                 | 6 +-----
 drivers/staging/lustre/lustre/obdclass/llog_swab.c                | 6 +-----
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c           | 6 +-----
 drivers/staging/lustre/lustre/obdclass/lu_object.c                | 6 +-----
 drivers/staging/lustre/lustre/obdclass/lu_ref.c                   | 6 +-----
 drivers/staging/lustre/lustre/obdclass/lustre_handles.c           | 6 +-----
 drivers/staging/lustre/lustre/obdclass/lustre_peer.c              | 6 +-----
 drivers/staging/lustre/lustre/obdclass/obd_config.c               | 6 +-----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c                | 6 +-----
 drivers/staging/lustre/lustre/obdclass/obdo.c                     | 6 +-----
 drivers/staging/lustre/lustre/obdclass/statfs_pack.c              | 6 +-----
 drivers/staging/lustre/lustre/obdclass/uuid.c                     | 6 +-----
 drivers/staging/lustre/lustre/obdecho/echo_client.c               | 6 +-----
 drivers/staging/lustre/lustre/osc/lproc_osc.c                     | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_cache.c                     | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h               | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_dev.c                       | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_internal.h                  | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_io.c                        | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_lock.c                      | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_object.c                    | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_page.c                      | 6 +-----
 drivers/staging/lustre/lustre/osc/osc_request.c                   | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/client.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/connection.c                 | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/events.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/import.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/layout.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c                | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c                   | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c               | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c               | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/pers.c                       | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/pinger.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h            | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c              | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c                    | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/recover.c                    | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec.c                        | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c                   | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c                 | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c                     | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c                  | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c                   | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c                  | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/service.c                    | 6 +-----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c                   | 6 +-----
 243 files changed, 242 insertions(+), 1211 deletions(-)

-- 
2.7.4
