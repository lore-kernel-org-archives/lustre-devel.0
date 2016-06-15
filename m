From: Oleg Drokin <green@linuxhacker.ru>
Date: Tue, 14 Jun 2016 20:44:15 -0400
Subject: [lustre-devel] [PATCH 2/5] staging/lustre: Replace sun.com GPLv2
	URL with gnu.org one.
In-Reply-To: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
References: <1465951458-847547-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465951458-847547-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

http://www.sun.com/software/products/lustre/docs/GPLv2.pdf is no
longer around, so replace it with (hopefully more permanent)
http://http://www.gnu.org/licenses/gpl-2.0.html

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Reported-by: Xose Vazquez Perez <xose.vazquez@gmail.com>
---
 drivers/staging/lustre/include/linux/libcfs/curproc.h                 | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs.h                  | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h            | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h             | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h            | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h             | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_private.h          | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_string.h           | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_time.h             | 2 +-
 drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h         | 2 +-
 drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h            | 2 +-
 drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h        | 2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c                   | 2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h                   | 2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c                | 2 +-
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c         | 2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c                   | 2 +-
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c               | 2 +-
 drivers/staging/lustre/lnet/libcfs/debug.c                            | 2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c                             | 2 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c                    | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c              | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c                | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c                  | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-module.c               | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c                 | 2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c            | 2 +-
 drivers/staging/lustre/lnet/libcfs/module.c                           | 2 +-
 drivers/staging/lustre/lnet/libcfs/prng.c                             | 2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.c                        | 2 +-
 drivers/staging/lustre/lnet/libcfs/tracefile.h                        | 2 +-
 drivers/staging/lustre/lnet/libcfs/workitem.c                         | 2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c                           | 2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c                             | 2 +-
 drivers/staging/lustre/lnet/lnet/config.c                             | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c                             | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c                             | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c                             | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c                           | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c                            | 2 +-
 drivers/staging/lustre/lnet/lnet/lo.c                                 | 2 +-
 drivers/staging/lustre/lnet/lnet/module.c                             | 2 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c                         | 2 +-
 drivers/staging/lustre/lnet/lnet/peer.c                               | 2 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c                       | 2 +-
 drivers/staging/lustre/lnet/selftest/conctl.c                         | 2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c                         | 2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h                         | 2 +-
 drivers/staging/lustre/lnet/selftest/console.c                        | 2 +-
 drivers/staging/lustre/lnet/selftest/console.h                        | 2 +-
 drivers/staging/lustre/lnet/selftest/framework.c                      | 2 +-
 drivers/staging/lustre/lnet/selftest/module.c                         | 2 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c                      | 2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c                            | 2 +-
 drivers/staging/lustre/lnet/selftest/rpc.h                            | 2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h                       | 2 +-
 drivers/staging/lustre/lnet/selftest/timer.c                          | 2 +-
 drivers/staging/lustre/lnet/selftest/timer.h                          | 2 +-
 drivers/staging/lustre/lustre/fid/fid_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c                           | 2 +-
 drivers/staging/lustre/lustre/fid/fid_request.c                       | 2 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c                         | 2 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c                         | 2 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c                       | 2 +-
 drivers/staging/lustre/lustre/fld/lproc_fld.c                         | 2 +-
 drivers/staging/lustre/lustre/include/cl_object.h                     | 2 +-
 drivers/staging/lustre/lustre/include/interval_tree.h                 | 2 +-
 drivers/staging/lustre/lustre/include/linux/lustre_compat25.h         | 2 +-
 drivers/staging/lustre/lustre/include/linux/lustre_lite.h             | 2 +-
 drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h | 2 +-
 drivers/staging/lustre/lustre/include/linux/lustre_user.h             | 2 +-
 drivers/staging/lustre/lustre/include/lprocfs_status.h                | 2 +-
 drivers/staging/lustre/lustre/include/lu_object.h                     | 2 +-
 drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h              | 2 +-
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h             | 2 +-
 drivers/staging/lustre/lustre/include/lustre/lustre_user.h            | 2 +-
 drivers/staging/lustre/lustre/include/lustre_acl.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_cfg.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_debug.h                  | 2 +-
 drivers/staging/lustre/lustre/include/lustre_disk.h                   | 2 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_eacl.h                   | 2 +-
 drivers/staging/lustre/lustre/include/lustre_export.h                 | 2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_ha.h                     | 2 +-
 drivers/staging/lustre/lustre/include/lustre_handles.h                | 2 +-
 drivers/staging/lustre/lustre/include/lustre_import.h                 | 2 +-
 drivers/staging/lustre/lustre/include/lustre_intent.h                 | 2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_lite.h                   | 2 +-
 drivers/staging/lustre/lustre/include/lustre_log.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h                    | 2 +-
 drivers/staging/lustre/lustre/include/lustre_param.h                  | 2 +-
 drivers/staging/lustre/lustre/include/lustre_req_layout.h             | 2 +-
 drivers/staging/lustre/lustre/include/lustre_sec.h                    | 2 +-
 drivers/staging/lustre/lustre/include/obd.h                           | 2 +-
 drivers/staging/lustre/lustre/include/obd_cksum.h                     | 2 +-
 drivers/staging/lustre/lustre/include/obd_class.h                     | 2 +-
 drivers/staging/lustre/lustre/include/obd_support.h                   | 2 +-
 drivers/staging/lustre/lustre/ldlm/interval_tree.c                    | 2 +-
 drivers/staging/lustre/lustre/ldlm/l_lock.c                           | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c                      | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c                       | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c                   | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h                    | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c                         | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c                        | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c                       | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c                       | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c                        | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c                     | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c                    | 2 +-
 drivers/staging/lustre/lustre/llite/dcache.c                          | 2 +-
 drivers/staging/lustre/lustre/llite/dir.c                             | 2 +-
 drivers/staging/lustre/lustre/llite/file.c                            | 2 +-
 drivers/staging/lustre/lustre/llite/glimpse.c                         | 2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c                      | 2 +-
 drivers/staging/lustre/lustre/llite/lcommon_misc.c                    | 2 +-
 drivers/staging/lustre/lustre/llite/llite_close.c                     | 2 +-
 drivers/staging/lustre/lustre/llite/llite_internal.h                  | 2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c                       | 2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c                      | 2 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c                       | 2 +-
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c                    | 2 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c                     | 2 +-
 drivers/staging/lustre/lustre/llite/namei.c                           | 2 +-
 drivers/staging/lustre/lustre/llite/remote_perm.c                     | 2 +-
 drivers/staging/lustre/lustre/llite/rw.c                              | 2 +-
 drivers/staging/lustre/lustre/llite/rw26.c                            | 2 +-
 drivers/staging/lustre/lustre/llite/statahead.c                       | 2 +-
 drivers/staging/lustre/lustre/llite/super25.c                         | 2 +-
 drivers/staging/lustre/lustre/llite/symlink.c                         | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c                         | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h                    | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c                          | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_lock.c                        | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c                      | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c                        | 2 +-
 drivers/staging/lustre/lustre/llite/xattr.c                           | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_fld.c                           | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c                        | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c                           | 2 +-
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c                         | 2 +-
 drivers/staging/lustre/lustre/lov/lov_cl_internal.h                   | 2 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c                           | 2 +-
 drivers/staging/lustre/lustre/lov/lov_ea.c                            | 2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/lov/lov_io.c                            | 2 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c                          | 2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c                         | 2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c                           | 2 +-
 drivers/staging/lustre/lustre/lov/lov_object.c                        | 2 +-
 drivers/staging/lustre/lustre/lov/lov_offset.c                        | 2 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c                          | 2 +-
 drivers/staging/lustre/lustre/lov/lov_page.c                          | 2 +-
 drivers/staging/lustre/lustre/lov/lov_request.c                       | 2 +-
 drivers/staging/lustre/lustre/lov/lovsub_dev.c                        | 2 +-
 drivers/staging/lustre/lustre/lov/lovsub_io.c                         | 2 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c                       | 2 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c                     | 2 +-
 drivers/staging/lustre/lustre/lov/lovsub_page.c                       | 2 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c                         | 2 +-
 drivers/staging/lustre/lustre/mdc/lproc_mdc.c                         | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c                           | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c                         | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c                         | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c                       | 2 +-
 drivers/staging/lustre/lustre/mgc/lproc_mgc.c                         | 2 +-
 drivers/staging/lustre/lustre/mgc/mgc_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/mgc/mgc_request.c                       | 2 +-
 drivers/staging/lustre/lustre/obdclass/acl.c                          | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_internal.h                  | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c                        | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c                      | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_object.c                    | 2 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c                      | 2 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c                    | 2 +-
 drivers/staging/lustre/lustre/obdclass/debug.c                        | 2 +-
 drivers/staging/lustre/lustre/obdclass/genops.c                       | 2 +-
 drivers/staging/lustre/lustre/obdclass/kernelcomm.c                   | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c           | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c             | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c           | 2 +-
 drivers/staging/lustre/lustre/obdclass/llog.c                         | 2 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c                     | 2 +-
 drivers/staging/lustre/lustre/obdclass/llog_internal.h                | 2 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c                     | 2 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c                    | 2 +-
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c               | 2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c                    | 2 +-
 drivers/staging/lustre/lustre/obdclass/lu_ref.c                       | 2 +-
 drivers/staging/lustre/lustre/obdclass/lustre_handles.c               | 2 +-
 drivers/staging/lustre/lustre/obdclass/lustre_peer.c                  | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_config.c                   | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c                    | 2 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c                         | 2 +-
 drivers/staging/lustre/lustre/obdclass/statfs_pack.c                  | 2 +-
 drivers/staging/lustre/lustre/obdclass/uuid.c                         | 2 +-
 drivers/staging/lustre/lustre/obdecho/echo_client.c                   | 2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c                         | 2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c                         | 2 +-
 drivers/staging/lustre/lustre/osc/osc_cl_internal.h                   | 2 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c                           | 2 +-
 drivers/staging/lustre/lustre/osc/osc_internal.h                      | 2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c                            | 2 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c                          | 2 +-
 drivers/staging/lustre/lustre/osc/osc_object.c                        | 2 +-
 drivers/staging/lustre/lustre/osc/osc_page.c                          | 2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c                       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c                     | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c                    | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c                       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c                   | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c                   | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/pers.c                           | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h                | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c                  | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c                        | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c                        | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c                            | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c                       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c                     | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c                         | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c                      | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c                       | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c                      | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c                        | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c                       | 2 +-
 240 files changed, 240 insertions(+), 240 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index c673dfc..2ab5002 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index c93d58e..8d6ad6a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index ae8175c..f6d2433 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 6a4387b..f1b5ad4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 9bdff3f..589dc83 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
index 881aae0..f6a993f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index c44e11d..509d76f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
index 03939ce..d963534 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
index 3f0ec7a..c0055b4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_time.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
index 5ff23bb..4171621 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_workitem.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
index 3652119..1aee201 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/libcfs.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
index 887811b..0f8876f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index ebd1294..ffc4d88 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 8567941..da8fa41 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index ddfda67..7307ec2 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 3e0e3a1..ade4a18 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index e9152a4..0334704 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index d83b5bd..7d6f18d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 0079a4c..836acce 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index db51124..d913bc3 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 750691c..e7b3f42 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
index 4fe58dd..b472981 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
index 808d09b..0b02a28 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-debug.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
index 86f32ff..9b0c0d4 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
@@ -11,7 +11,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  */
 /*
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
index 8caee5b..79873e0 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-module.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index c1152e6..32e12e2 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index 6c9e3976..e3d905f 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 065f968..17f71a8 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/prng.c b/drivers/staging/lustre/lnet/libcfs/prng.c
index f2e8426..c907378 100644
--- a/drivers/staging/lustre/lnet/libcfs/prng.c
+++ b/drivers/staging/lustre/lnet/libcfs/prng.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
index ba0e7c3..e8da3e8 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index ae1c614..95e41de 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index c51f389..76517ab 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 4456286..0c74a1c 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 7662c3b..5164f59 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 358e5cf..2882543 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index d04c687..6fc35e2 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 51145f1..3460545 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 1c370f4..f93e57d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index f5c6eac..c36761a 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 77ae4e6..4c5cd58 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 6441ef3..1087cbd 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 40f3c52..6a58726 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 74bfda1..a0d19de 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 5fde05a..64ed187 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 6e25e1a..c56b452 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 9a22f33..e53aa15 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index e649d37..bfeaad5 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 1d8bb63..8d375a2 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 31001f4..d25aee9 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index b099946..2360c06 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 0d53307..fd466fe 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index b6a3bdf..38f93c8 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 3030c07..7579b1f 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index e7aba01..08646b1 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 3254f5d..360fd23 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 4a1d2b2..8f47082 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  * copy of GPLv2].
  *
  * GPL HEADER END
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index c73ded9..445ee32 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lnet/selftest/timer.h b/drivers/staging/lustre/lnet/selftest/timer.h
index e86e44e..ef70a64 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.h
+++ b/drivers/staging/lustre/lnet/selftest/timer.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index d6aebb3..6edb2e5 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index ee7b272..1f96897 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 00b19c7..aef4b41 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index 0103af5..0d3757b 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index cb33d41..c4b3f97 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index a85d86a..985ad9b 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 5f43af4..ca81ae8 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
index 1b96880..5547473 100644
--- a/drivers/staging/lustre/lustre/fld/lproc_fld.c
+++ b/drivers/staging/lustre/lustre/fld/lproc_fld.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index a5a28f5..99db296 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
index 64cab4b..2d5d047 100644
--- a/drivers/staging/lustre/lustre/include/interval_tree.h
+++ b/drivers/staging/lustre/lustre/include/interval_tree.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h b/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
index 7690fa7..11160d4 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_compat25.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
index abefa93..6b7348b 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_lite.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
index 6d138b2..d7f3c53 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_user.h b/drivers/staging/lustre/lustre/include/linux/lustre_user.h
index 7403139..47a1485 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_user.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 4f5ab54..424d4c7 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index b7bfe39..5965b17 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
index 664f135..1b55b96 100644
--- a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
+++ b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index e5031b1..39037b8 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 3b48ba5..b1be028 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_acl.h b/drivers/staging/lustre/lustre/include/lustre_acl.h
index 9773db7..2103447 100644
--- a/drivers/staging/lustre/lustre/include/lustre_acl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_acl.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index f532af6..9213821 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
index bd531ff..606b4c0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_debug.h
+++ b/drivers/staging/lustre/lustre/include/lustre_debug.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index f30c601..4880cbb 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index bdc1da7..eb9384a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_eacl.h b/drivers/staging/lustre/lustre/include/lustre_eacl.h
index caab6e3..3a4b63f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_eacl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_eacl.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 41b6a7c..d908ade 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index e3794d6..d3cd5fa 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index 6a91cbc..c825178 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_ha.h b/drivers/staging/lustre/lustre/include/lustre_ha.h
index 152b0ee..9e6b619 100644
--- a/drivers/staging/lustre/lustre/include/lustre_ha.h
+++ b/drivers/staging/lustre/lustre/include/lustre_ha.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index c1906c2..26da740 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index d4f7680..046c925 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index d5b15a4..bdfe58a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index f7b0ce8..64a0428 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index bd328e5..e0e6024 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 7a3940a..91abf55 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index cc4158c..ba213f5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 9bcd3cd..690db1b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index ce31181..1b2ddd6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_param.h b/drivers/staging/lustre/lustre/include/lustre_param.h
index dc6f2b2..73dec02 100644
--- a/drivers/staging/lustre/lustre/include/lustre_param.h
+++ b/drivers/staging/lustre/lustre/include/lustre_param.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index acbc310..04270af 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 7ca6204..239f84f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6c94fa4..45c0acc 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index 02705a5..25e9b1c 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index c7a71b2..01415b5 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index ce5be73..a7243d3 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
index 59bb066..d624ca2 100644
--- a/drivers/staging/lustre/lustre/ldlm/interval_tree.c
+++ b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index c6f7dfd..d1ed72b 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 16c1621..9ac0638 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 6c0dd7a..33d314e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
index d98243d..997ef8a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index cc5e654..b73e803 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 1a7eee3..a2678f5 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 88e9192..af42233 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 1da0eb2..ad3dfcd 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
index 621a490..78d3a03 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 1d9ca31..0c9383d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f6b30f6..14261a0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 771c1f8..557d31e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 908bdc6..f66cf52 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 8854029a..a4c1c40 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 104129b..81fb288 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 8788ee0..b7d6337 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 28b7482..a4f81c3 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
index e45bd6d..ce0d528 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 2e2abc7..97d73da 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f541634..f706971 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index f513b74..0dae3ea 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index b569df3..407d2f1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 086e827..d1010dd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
index bae3ff0..a9c19b3 100644
--- a/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
+++ b/drivers/staging/lustre/lustre/llite/llite_rmtacl.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 2b3a777..9063b77 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index b7ec512..7d98593 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/remote_perm.c b/drivers/staging/lustre/lustre/llite/remote_perm.c
index 0b96175..4b462a2 100644
--- a/drivers/staging/lustre/lustre/llite/remote_perm.c
+++ b/drivers/staging/lustre/lustre/llite/remote_perm.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index df6cb54..2c13ec2 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index d45fdcb..17a4cf8 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index d533954..3dda677 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index f7f8e23..9ee298a 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 12f945e..1d8d21f 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index da84d95..0b53b0f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 6708841..db88573 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 2200d57..84dfe06 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
index b5c307f..9bdc95d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_lock.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 11c3004..6a382b8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index ae36c75..5819ff2 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index a286635..de6b166 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index fcf1b1c..d698345 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index bdf28cd..6306c4f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 267deef..2fd4de4 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 800033d..7bbc1f4 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
index aa68623..8038794 100644
--- a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
+++ b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 9a2e5e2..dbdd21e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index 21e3054..2fbbe64 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 2f8972f..79c2ce1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 55fb5bf..162e437 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index cc70eeb..70431e6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 2d87cfa..3591535 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index f020656..b6165ad 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9ca7e63..9485423 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 08f3d5c..fef4d33 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 2f568b5..e4cc0c5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 69f4a68..a77ef8f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index 6c97e6f..fe29de5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 83cd6e4..434f949 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index cddf3d6..f229ff7 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_io.c b/drivers/staging/lustre/lustre/lov/lovsub_io.c
index c927406..1ee2afd 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_io.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_io.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index 06bfdf9..9f20b7e 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index a1a0f08..05c92c2 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
index e8e3475..fcd5735 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_page.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_page.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
index c5f7aac..15de320 100644
--- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
+++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
index 95a8fcd..5ad1f9f 100644
--- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
+++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index cd57233..17e663f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 8411729..5e51014 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index c14c9df..fff10f28 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 8380c56..fcf17fc 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index e152429..111f2f5 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
index c77e120..503f581 100644
--- a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
+++ b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index 0eb31cc..dbe8c8b 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 2a80d85..ae53965 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/acl.c b/drivers/staging/lustre/lustre/obdclass/acl.c
index 9f4eaba..f969e90 100644
--- a/drivers/staging/lustre/lustre/obdclass/acl.c
+++ b/drivers/staging/lustre/lustre/obdclass/acl.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
index 09a1884..42a7983 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index dcc1b4e..b623956a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 737612a..768be65 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 14da4b1..27a396e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index c014b69..9f51996 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index b8dd638..d5897a9 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
index 0786683..d8734ca 100644
--- a/drivers/staging/lustre/lustre/obdclass/debug.c
+++ b/drivers/staging/lustre/lustre/obdclass/debug.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 2ec9eae..b51d500 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 407c41e..016be52 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index e7beee4..f527638 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
index 1d4a8d6..d46bb80 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-obdo.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 58d1a44..73e4a73 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index e100ada..b5198cb 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index e64a5e5..319c02d 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index bce65fe..99ab947 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index b06dfe3..f04502bf 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index b5281d8..267e93b 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 849deb1..124593f 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 1deaa2b..5e18f88 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
index 6363292..0e6b1ca 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_ref.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 6df2940..b7c15d4 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index e0e3a46..a39efd5 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 39cfbc51..8dc2704 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 7dbf40e..e3f2020 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index a62bf2b..77f838b 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
index d633e22..3ee0044 100644
--- a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
+++ b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
index 0dfa444..b03af35 100644
--- a/drivers/staging/lustre/lustre/obdclass/uuid.c
+++ b/drivers/staging/lustre/lustre/obdclass/uuid.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index d92d85c..dbc4c2e 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index f7bdd0a..0210f02 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 4eb1f2af..2f9688c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 78cab86..34d863b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index 1d2938d..7121be2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 439118a..5e5119c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 79159d9..6bc4c79 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index fef695b..55fc882 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index 2a8b3c2..47d71de 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 9ed91c4..07235c9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 740c362..280a646 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 325cce1..85a6c1b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index a1f7d8c..b91e5fb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index af841cc..d26d33c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 2930193..22868f4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index f0dca8e..69d1dca 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
index f335b1f..b33ea3b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
index ed3e88f..9011390 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 8d67108..82382b9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 17dd6ea..620a004 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index e7187a4..ce829a2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 14608ef..4ad1211 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 8ae6fd1..2e57065 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 52eda29..c327ff0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index e7443f3..cf75935 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index fd343819..4b5fd91 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 5c69309..a4c2da6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 9ec6417..b5143f5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 34e2972..c500754 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index f7210c8..df81c82 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 15d0586..928f7f4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index bba4adf..27e40a1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 04381af..7b0adaa 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index a2dd435..eb32b8c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index f369a5e..33818ac 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 4b9a23e..f5be068 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -15,7 +15,7 @@
  *
  * You should have received a copy of the GNU General Public License
  * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ * http://http://www.gnu.org/licenses/gpl-2.0.html
  *
  * GPL HEADER END
  */
-- 
2.7.4
