From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 14 Jun 2016 20:44:14 -0400
Subject: [lustre-devel] [PATCH 1/5] staging/lustre: Remove the "Please
	contact SUN for GPL" from headers
In-Reply-To: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
References: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465951458-847547-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

Since SUN is no longer around and there's no point in contacting them,
just remove that whole thing. Copy of GPL is available online anyway
(URLs to be updated in next patch).

This patch was generated with:
find drivers/staging/lustre -name "*.[ch]" -exec perl -0777 -i -pe 's/ \* Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,\n \* CA 95054 USA or visit www.sun.com if you need additional information or\n \* have any questions.\n \*\n//igs' {} \;

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Reported-by: Xose Vazquez Perez <xose.vazquez@gmail.com>
---
 drivers/staging/lustre/include/linux/libcfs/curproc.h                 | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs.h                  | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h            | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h             | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h            | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h             | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_private.h          | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_string.h           | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_time.h             | 4 ----
 drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h         | 4 ----
 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h            | 4 ----
 drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h        | 4 ----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c                   | 4 ----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h                   | 4 ----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c                | 4 ----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c         | 4 ----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c                   | 4 ----
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c               | 4 ----
 drivers/staging/lustre/lnet/libcfs/debug.c                            | 4 ----
 drivers/staging/lustre/lnet/libcfs/hash.c                             | 4 ----
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c                    | 4 ----
 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c              | 4 ----
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c                | 4 ----
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c               | 4 ----
 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c                 | 4 ----
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c            | 4 ----
 drivers/staging/lustre/lnet/libcfs/module.c                           | 4 ----
 drivers/staging/lustre/lnet/libcfs/prng.c                             | 4 ----
 drivers/staging/lustre/lnet/libcfs/tracefile.c                        | 4 ----
 drivers/staging/lustre/lnet/libcfs/tracefile.h                        | 4 ----
 drivers/staging/lustre/lnet/libcfs/workitem.c                         | 4 ----
 drivers/staging/lustre/lnet/lnet/acceptor.c                           | 4 ----
 drivers/staging/lustre/lnet/lnet/api-ni.c                             | 4 ----
 drivers/staging/lustre/lnet/lnet/config.c                             | 4 ----
 drivers/staging/lustre/lnet/lnet/lib-eq.c                             | 4 ----
 drivers/staging/lustre/lnet/lnet/lib-md.c                             | 4 ----
 drivers/staging/lustre/lnet/lnet/lib-me.c                             | 4 ----
 drivers/staging/lustre/lnet/lnet/lib-move.c                           | 4 ----
 drivers/staging/lustre/lnet/lnet/lib-msg.c                            | 4 ----
 drivers/staging/lustre/lnet/lnet/lo.c                                 | 4 ----
 drivers/staging/lustre/lnet/lnet/module.c                             | 4 ----
 drivers/staging/lustre/lnet/lnet/nidstrings.c                         | 4 ----
 drivers/staging/lustre/lnet/lnet/peer.c                               | 4 ----
 drivers/staging/lustre/lnet/selftest/brw_test.c                       | 4 ----
 drivers/staging/lustre/lnet/selftest/conctl.c                         | 4 ----
 drivers/staging/lustre/lnet/selftest/conrpc.c                         | 4 ----
 drivers/staging/lustre/lnet/selftest/conrpc.h                         | 4 ----
 drivers/staging/lustre/lnet/selftest/console.c                        | 4 ----
 drivers/staging/lustre/lnet/selftest/console.h                        | 4 ----
 drivers/staging/lustre/lnet/selftest/framework.c                      | 4 ----
 drivers/staging/lustre/lnet/selftest/module.c                         | 4 ----
 drivers/staging/lustre/lnet/selftest/ping_test.c                      | 4 ----
 drivers/staging/lustre/lnet/selftest/rpc.c                            | 4 ----
 drivers/staging/lustre/lnet/selftest/rpc.h                            | 4 ----
 drivers/staging/lustre/lnet/selftest/selftest.h                       | 4 ----
 drivers/staging/lustre/lnet/selftest/timer.c                          | 4 ----
 drivers/staging/lustre/lnet/selftest/timer.h                          | 4 ----
 drivers/staging/lustre/lustre/fid/fid_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/fid/fid_lib.c                           | 4 ----
 drivers/staging/lustre/lustre/fid/fid_request.c                       | 4 ----
 drivers/staging/lustre/lustre/fid/lproc_fid.c                         | 4 ----
 drivers/staging/lustre/lustre/fld/fld_cache.c                         | 4 ----
 drivers/staging/lustre/lustre/fld/fld_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/fld/fld_request.c                       | 4 ----
 drivers/staging/lustre/lustre/fld/lproc_fld.c                         | 4 ----
 drivers/staging/lustre/lustre/include/cl_object.h                     | 4 ----
 drivers/staging/lustre/lustre/include/interval_tree.h                 | 4 ----
 drivers/staging/lustre/lustre/include/linux/lustre_compat25.h         | 4 ----
 drivers/staging/lustre/lustre/include/linux/lustre_lite.h             | 4 ----
 drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h | 4 ----
 drivers/staging/lustre/lustre/include/linux/lustre_user.h             | 4 ----
 drivers/staging/lustre/lustre/include/lprocfs_status.h                | 4 ----
 drivers/staging/lustre/lustre/include/lu_object.h                     | 4 ----
 drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h              | 4 ----
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h             | 4 ----
 drivers/staging/lustre/lustre/include/lustre/lustre_user.h            | 4 ----
 drivers/staging/lustre/lustre/include/lustre_acl.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_cfg.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_debug.h                  | 4 ----
 drivers/staging/lustre/lustre/include/lustre_disk.h                   | 4 ----
 drivers/staging/lustre/lustre/include/lustre_dlm.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_eacl.h                   | 4 ----
 drivers/staging/lustre/lustre/include/lustre_export.h                 | 4 ----
 drivers/staging/lustre/lustre/include/lustre_fid.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_fld.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_ha.h                     | 4 ----
 drivers/staging/lustre/lustre/include/lustre_handles.h                | 4 ----
 drivers/staging/lustre/lustre/include/lustre_import.h                 | 4 ----
 drivers/staging/lustre/lustre/include/lustre_intent.h                 | 4 ----
 drivers/staging/lustre/lustre/include/lustre_lib.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_lite.h                   | 4 ----
 drivers/staging/lustre/lustre/include/lustre_log.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_mdc.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_mds.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_net.h                    | 4 ----
 drivers/staging/lustre/lustre/include/lustre_param.h                  | 4 ----
 drivers/staging/lustre/lustre/include/lustre_req_layout.h             | 4 ----
 drivers/staging/lustre/lustre/include/lustre_sec.h                    | 4 ----
 drivers/staging/lustre/lustre/include/obd.h                           | 4 ----
 drivers/staging/lustre/lustre/include/obd_cksum.h                     | 4 ----
 drivers/staging/lustre/lustre/include/obd_class.h                     | 4 ----
 drivers/staging/lustre/lustre/include/obd_support.h                   | 4 ----
 drivers/staging/lustre/lustre/ldlm/interval_tree.c                    | 4 ----
 drivers/staging/lustre/lustre/ldlm/l_lock.c                           | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c                      | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c                       | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c                   | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h                    | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c                         | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c                        | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c                       | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c                       | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c                        | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c                     | 4 ----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c                    | 4 ----
 drivers/staging/lustre/lustre/llite/dcache.c                          | 4 ----
 drivers/staging/lustre/lustre/llite/dir.c                             | 4 ----
 drivers/staging/lustre/lustre/llite/file.c                            | 4 ----
 drivers/staging/lustre/lustre/llite/glimpse.c                         | 4 ----
 drivers/staging/lustre/lustre/llite/lcommon_cl.c                      | 4 ----
 drivers/staging/lustre/lustre/llite/lcommon_misc.c                    | 4 ----
 drivers/staging/lustre/lustre/llite/llite_close.c                     | 4 ----
 drivers/staging/lustre/lustre/llite/llite_internal.h                  | 4 ----
 drivers/staging/lustre/lustre/llite/llite_lib.c                       | 4 ----
 drivers/staging/lustre/lustre/llite/llite_mmap.c                      | 4 ----
 drivers/staging/lustre/lustre/llite/llite_nfs.c                       | 4 ----
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c                    | 4 ----
 drivers/staging/lustre/lustre/llite/lproc_llite.c                     | 4 ----
 drivers/staging/lustre/lustre/llite/namei.c                           | 4 ----
 drivers/staging/lustre/lustre/llite/remote_perm.c                     | 4 ----
 drivers/staging/lustre/lustre/llite/rw.c                              | 4 ----
 drivers/staging/lustre/lustre/llite/rw26.c                            | 4 ----
 drivers/staging/lustre/lustre/llite/statahead.c                       | 4 ----
 drivers/staging/lustre/lustre/llite/super25.c                         | 4 ----
 drivers/staging/lustre/lustre/llite/symlink.c                         | 4 ----
 drivers/staging/lustre/lustre/llite/vvp_dev.c                         | 4 ----
 drivers/staging/lustre/lustre/llite/vvp_internal.h                    | 4 ----
 drivers/staging/lustre/lustre/llite/vvp_io.c                          | 4 ----
 drivers/staging/lustre/lustre/llite/vvp_lock.c                        | 4 ----
 drivers/staging/lustre/lustre/llite/vvp_object.c                      | 4 ----
 drivers/staging/lustre/lustre/llite/vvp_page.c                        | 4 ----
 drivers/staging/lustre/lustre/llite/xattr.c                           | 4 ----
 drivers/staging/lustre/lustre/lmv/lmv_fld.c                           | 4 ----
 drivers/staging/lustre/lustre/lmv/lmv_intent.c                        | 4 ----
 drivers/staging/lustre/lustre/lmv/lmv_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c                           | 4 ----
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c                         | 4 ----
 drivers/staging/lustre/lustre/lov/lov_cl_internal.h                   | 4 ----
 drivers/staging/lustre/lustre/lov/lov_dev.c                           | 4 ----
 drivers/staging/lustre/lustre/lov/lov_ea.c                            | 4 ----
 drivers/staging/lustre/lustre/lov/lov_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/lov/lov_io.c                            | 4 ----
 drivers/staging/lustre/lustre/lov/lov_lock.c                          | 4 ----
 drivers/staging/lustre/lustre/lov/lov_merge.c                         | 4 ----
 drivers/staging/lustre/lustre/lov/lov_obd.c                           | 4 ----
 drivers/staging/lustre/lustre/lov/lov_object.c                        | 4 ----
 drivers/staging/lustre/lustre/lov/lov_offset.c                        | 4 ----
 drivers/staging/lustre/lustre/lov/lov_pack.c                          | 4 ----
 drivers/staging/lustre/lustre/lov/lov_page.c                          | 4 ----
 drivers/staging/lustre/lustre/lov/lov_pool.c                          | 4 ----
 drivers/staging/lustre/lustre/lov/lov_request.c                       | 4 ----
 drivers/staging/lustre/lustre/lov/lovsub_dev.c                        | 4 ----
 drivers/staging/lustre/lustre/lov/lovsub_io.c                         | 4 ----
 drivers/staging/lustre/lustre/lov/lovsub_lock.c                       | 4 ----
 drivers/staging/lustre/lustre/lov/lovsub_object.c                     | 4 ----
 drivers/staging/lustre/lustre/lov/lovsub_page.c                       | 4 ----
 drivers/staging/lustre/lustre/lov/lproc_lov.c                         | 4 ----
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c                         | 4 ----
 drivers/staging/lustre/lustre/mdc/mdc_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/mdc/mdc_lib.c                           | 4 ----
 drivers/staging/lustre/lustre/mdc/mdc_locks.c                         | 4 ----
 drivers/staging/lustre/lustre/mdc/mdc_reint.c                         | 4 ----
 drivers/staging/lustre/lustre/mdc/mdc_request.c                       | 4 ----
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c                         | 4 ----
 drivers/staging/lustre/lustre/mgc/mgc_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/mgc/mgc_request.c                       | 4 ----
 drivers/staging/lustre/lustre/obdclass/acl.c                          | 4 ----
 drivers/staging/lustre/lustre/obdclass/cl_internal.h                  | 4 ----
 drivers/staging/lustre/lustre/obdclass/cl_io.c                        | 4 ----
 drivers/staging/lustre/lustre/obdclass/cl_lock.c                      | 4 ----
 drivers/staging/lustre/lustre/obdclass/cl_object.c                    | 4 ----
 drivers/staging/lustre/lustre/obdclass/cl_page.c                      | 4 ----
 drivers/staging/lustre/lustre/obdclass/class_obd.c                    | 4 ----
 drivers/staging/lustre/lustre/obdclass/debug.c                        | 4 ----
 drivers/staging/lustre/lustre/obdclass/genops.c                       | 4 ----
 drivers/staging/lustre/lustre/obdclass/kernelcomm.c                   | 4 ----
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c           | 4 ----
 drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c             | 4 ----
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c           | 4 ----
 drivers/staging/lustre/lustre/obdclass/llog.c                         | 4 ----
 drivers/staging/lustre/lustre/obdclass/llog_cat.c                     | 4 ----
 drivers/staging/lustre/lustre/obdclass/llog_internal.h                | 4 ----
 drivers/staging/lustre/lustre/obdclass/llog_obd.c                     | 4 ----
 drivers/staging/lustre/lustre/obdclass/llog_swab.c                    | 4 ----
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c               | 4 ----
 drivers/staging/lustre/lustre/obdclass/lu_object.c                    | 4 ----
 drivers/staging/lustre/lustre/obdclass/lu_ref.c                       | 4 ----
 drivers/staging/lustre/lustre/obdclass/lustre_handles.c               | 4 ----
 drivers/staging/lustre/lustre/obdclass/lustre_peer.c                  | 4 ----
 drivers/staging/lustre/lustre/obdclass/obd_config.c                   | 4 ----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c                    | 4 ----
 drivers/staging/lustre/lustre/obdclass/obdo.c                         | 4 ----
 drivers/staging/lustre/lustre/obdclass/statfs_pack.c                  | 4 ----
 drivers/staging/lustre/lustre/obdclass/uuid.c                         | 4 ----
 drivers/staging/lustre/lustre/obdecho/echo_client.c                   | 4 ----
 drivers/staging/lustre/lustre/osc/lproc_osc.c                         | 4 ----
 drivers/staging/lustre/lustre/osc/osc_cache.c                         | 4 ----
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h                   | 4 ----
 drivers/staging/lustre/lustre/osc/osc_dev.c                           | 4 ----
 drivers/staging/lustre/lustre/osc/osc_internal.h                      | 4 ----
 drivers/staging/lustre/lustre/osc/osc_io.c                            | 4 ----
 drivers/staging/lustre/lustre/osc/osc_lock.c                          | 4 ----
 drivers/staging/lustre/lustre/osc/osc_object.c                        | 4 ----
 drivers/staging/lustre/lustre/osc/osc_page.c                          | 4 ----
 drivers/staging/lustre/lustre/osc/osc_request.c                       | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/client.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/connection.c                     | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/events.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/import.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/layout.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c                    | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c                       | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c                   | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c                   | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/pers.c                           | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/pinger.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h                | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c                  | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c                        | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/recover.c                        | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec.c                            | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c                       | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c                     | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c                         | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c                      | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c                       | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c                      | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/service.c                        | 4 ----
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c                       | 4 ----
 240 files changed, 960 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index 1edfca5..c673dfc 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4141afb..c93d58e 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 455c54d..ae8175c 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 119986b..6a4387b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 4b9102b..9bdff3f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
index ac4e8cf..881aae0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 2fd2a96..c44e11d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index e02cde5..03939ce 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
index 2c7ec2d..3f0ec7a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
index f9b20c5..5ff23bb 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index a268ef7..3652119 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
index 7656b09..887811b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 4bb32f1..ebd1294 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 45bbe93..8567941 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 0f7e3a1..ddfda67 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index f8fdd4a..3e0e3a1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 406c0e7..e9152a4 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 964b4e3..d83b5bd 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 8c260c3..0079a4c 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index cc45ed8..db51124 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 50ac153..750691c 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
index 13d31e8..4fe58dd 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 638e4b3..808d09b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index d89f71e..8caee5b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index bbe19a6..c1152e6 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index 91c2ae8..6c9e3976 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index f2d0411..065f968 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
index c75ae9a..f2e8426 100644
--- a/drivers/staging/lustre/lnet/libcfs/prng.c
+++ b/drivers/staging/lustre/lnet/libcfs/prng.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index 7739b94..ba0e7c3 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index ac84e7f..ae1c614 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index 92236ae..c51f389 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 1452bb3..4456286 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fe0dbe7..7662c3b 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 480cc9c..358e5cf 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index adbcadb..d04c687 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 75d3121..51145f1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index e671aed..1c370f4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index c5d5bed..f5c6eac 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index f879d7f..77ae4e6 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 468eda6..6441ef3 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 246b5c1..40f3c52 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index ebf468f..74bfda1 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index b026fee..5fde05a 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index a63d86c..6e25e1a 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 408c614..9a22f33 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 6f68758..e649d37 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 90c3385..1d8bb63 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index a03e52d..31001f4 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index becd22e..b099946 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 30e4f71..0d53307 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index cc046b1..b6a3bdf 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index ad26fe9..3030c07 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 3c45a7c..e7aba01 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index c9b904c..3254f5d 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 4eac1c9..4a1d2b2 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -18,10 +18,6 @@
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  * copy of GPLv2].
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index b6c4aae..c73ded9 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lnet/selftest/timer.h b/drivers/staging/lustre/lnet/selftest/timer.h
index f1fbebd..e86e44e 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.h
+++ b/drivers/staging/lustre/lnet/selftest/timer.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index b79a813..d6aebb3 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index dd65159..ee7b272 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 9db21ba..00b19c7 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 1f0e786..0103af5 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 5a04e99..cb33d41 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 75d6a48..a85d86a 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 304c0ec..5f43af4 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index ca898be..1b96880 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index d4c33dd..a5a28f5 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index f6df3f3..64cab4b 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h b/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
index 79d8f93..7690fa7 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
index 3420cfd..abefa93 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
index c6c7f54..6d138b2 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_user.h b/drivers/staging/lustre/lustre/include/linux/lustre_user.h
index 9cc2849..7403139 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_user.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 4146c9c..4f5ab54 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 2816512..b7bfe39 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
index 07d45de..664f135 100644
--- a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
+++ b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 9c53c17..e5031b1 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 59ba48a..3b48ba5 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_acl.h b/drivers/staging/lustre/lustre/include/lustre_acl.h
index aa4cfa7..9773db7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_acl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_acl.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index e229e91..f532af6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
index 8a08941..bd531ff 100644
--- a/drivers/staging/lustre/lustre/include/lustre_debug.h
+++ b/drivers/staging/lustre/lustre/include/lustre_debug.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index b36821f..f30c601 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 9cade14..bdc1da7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_eacl.h b/drivers/staging/lustre/lustre/include/lustre_eacl.h
index 0b66593..caab6e3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_eacl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_eacl.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 3014d27..41b6a7c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 12e8b58..e3794d6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 4cf2b0e..6a91cbc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_ha.h b/drivers/staging/lustre/lustre/include/lustre_ha.h
index 5488a69..152b0ee 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ha.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ha.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 27f169d..c1906c2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 8325c82..d4f7680 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index c491d52..d5b15a4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 00b9767..f7b0ce8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index fcc5ebb..bd328e5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 49618e1..7a3940a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index f267ff8..cc4158c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 95d27dd..9bcd3cd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index a7973d5..ce31181 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index a42cf90..dc6f2b2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 0aac439..acbc310 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 01b4e67..7ca6204 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 2d926e0..6c94fa4 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index f6c18df..02705a5 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 32863bc..c7a71b2 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 60034d3..ce5be73 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index 3230606..59bb066 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index 621323f..c6f7dfd 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index cf1f178..16c1621 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 349bfcc..6c0dd7a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
index b1bed1e..d98243d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 32f227f..cc5e654 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index b6a90b0..1a7eee3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index bff94ea..88e9192 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 3303ffa..1da0eb2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
index 0c1965d..621a490 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index b913ba9..1d9ca31 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 107314e..f6b30f6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index e99c89c..771c1f8 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 1b6f82a..908bdc6 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 85c50e0..8854029a 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 26c6cd6..104129b 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index d8ea754..8788ee0 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 6c00715..28b7482 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index 12f3e71..e45bd6d 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 2df551d..2e2abc7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 7fb949a..f541634 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b260f60..f513b74 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 7610799..b569df3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index c1eef61..086e827 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
index 8509b07..bae3ff0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
+++ b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 55d62eb..2b3a777 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 95643bc..b7ec512 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/remote_perm.c b/drivers/staging/lustre/lustre/llite/remote_perm.c
index e9d2531..0b96175 100644
--- a/drivers/staging/lustre/lustre/llite/remote_perm.c
+++ b/drivers/staging/lustre/lustre/llite/remote_perm.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index fa42869..df6cb54 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 947a4f5..d45fdcb 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 6322f88..d533954 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 415750b..f7f8e23 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 3fc736c..12f945e 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index c63def9..da84d95 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 27b9b0a..6708841 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 763d336..2200d57 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index f5bd6c2..b5c307f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 18c9df7..11c3004 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 6cd2af7..ae36c75 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 608014b..a286635 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index 378691b..fcf1b1c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index e0958ea..bdf28cd 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 7007e4c..267deef 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 1d9875e..800033d 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index b39e364..aa68623 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index ac9744e..9a2e5e2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index dae8e89..21e3054 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 460f0fa..2f8972f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index eef9afa..55fb5bf 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 86cb3f8..cc70eeb 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 1b203d1..2d87cfa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 56ef41d..f020656 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index c179b31..9ca7e63 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 561d493..08f3d5c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 7636bfa..2f568b5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 0215ea5..69f4a68 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 0306f00..6c97e6f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 690292e..75660c5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see [sun.com URL with a
  * copy of GPLv2].
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 1be4b92..83cd6e4 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index 35f6b1d..cddf3d6 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_io.c b/drivers/staging/lustre/lustre/lov/lovsub_io.c
index 783ec68..c927406 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_io.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_io.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index e92edfb..06bfdf9 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index bcaae1e..a1a0f08 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
index 9badedc..e8e3475 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_page.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_page.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index 0dcb6b6..c5f7aac 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 5c7a15d..95a8fcd 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index c5519ae..cd57233 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 856c54e..8411729 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 3b1bc91..c14c9df 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 4ef3db1..8380c56 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 86b7445..e152429 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
index 8d5bc5a..c77e120 100644
--- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
+++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 82fb8f4..0eb31cc 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2311a43..2a80d85 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/acl.c b/drivers/staging/lustre/lustre/obdclass/acl.c
index 0e02ae9..9f4eaba 100644
--- a/drivers/staging/lustre/lustre/obdclass/acl.c
+++ b/drivers/staging/lustre/lustre/obdclass/acl.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
index 7eb0ad7..09a1884 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 583fb5f..dcc1b4e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 26a576b..737612a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 5940f30..14da4b1 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index b754f51..c014b69 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index f48816a..b8dd638 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index e4edfb2..0786683 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index d95f11d..2ec9eae 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 8405ecc..407c41e 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 2cd4522..e7beee4 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
index b41b65e..1d4a8d6 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index e6bf414..58d1a44 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 55a9755..e100ada 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index c27d4ec..e64a5e5 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index 7fb48dd..bce65fe 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 826623f..b06dfe3 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 967ba2e..b5281d8 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 5a1eae1..849deb1 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index e043857..1deaa2b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index 993697b..6363292 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 403ceea..6df2940 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index b1abe02..e0e3a46 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index cb1d65c..39cfbc51 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index bc4e1e4..7dbf40e 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 748e33f..a62bf2b 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
index fb4e3ae..d633e22 100644
--- a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
+++ b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
index b0b0157..0dfa444 100644
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ b/drivers/staging/lustre/lustre/obdclass/uuid.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 91ef06f..d92d85c 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 33a1132..f7bdd0a 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 2ca5045..4eb1f2af 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 7359fcb..78cab86 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index d4fe507..1d2938d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 7fad827..439118a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index d3bce45..79159d9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index d30ed2f..fef695b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 738ab10..2a8b3c2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 5a3e694..9ed91c4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 7b1fc7e..740c362 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 8336ed1..325cce1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index a14daff..a1f7d8c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index fdcde9b..af841cc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index a236e38..2930193 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index c0ecd16..f0dca8e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index a23ac5f..f335b1f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index fbccb62..ed3e88f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index ff40be2..8d67108 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 10b8fe8..17dd6ea 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 811acf6..e7187a4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index ec3af10..14608ef 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index d9d4ca2..8ae6fd1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 6ca26c9..52eda29 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index a8ec0e9..e7443f3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 76a355a..fd343819 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 30d9a16..5c69309 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 657b41f..9ec6417 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 02e6cda..34e2972 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index a51b18b..f7210c8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 9082da0..15d0586 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index e610a8d..bba4adf 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index af92e9e..04381af 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index ec8edbf..a2dd435 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 17c7b97..f369a5e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index aacc810..4b9a23e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -17,10 +17,6 @@
  * version 2 along with this program; If not, see
  * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
  *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
  * GPL HEADER END
  */
 /*
-- 
2.7.4
