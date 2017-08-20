From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:32 -0400
Subject: [lustre-devel] [PATCH 38/64 v2] staging: lustre: lnet: remove
	userland function prototype in lnetctl.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Several function prototypes of the form jt_ptl_* are only needed
by userland so they can be removed.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/17643
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lnet/lnetctl.h       | 41 ----------------------
 1 file changed, 41 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index 2ce1c50..65b2bf8 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -131,45 +131,4 @@ struct lnet_fault_stat {
 #define SMFS_DEV_MAJOR 10
 #define SMFS_DEV_MINOR 242
 
-int ptl_initialize(int argc, char **argv);
-int jt_ptl_network(int argc, char **argv);
-int jt_ptl_list_nids(int argc, char **argv);
-int jt_ptl_which_nid(int argc, char **argv);
-int jt_ptl_print_interfaces(int argc, char **argv);
-int jt_ptl_add_interface(int argc, char **argv);
-int jt_ptl_del_interface(int argc, char **argv);
-int jt_ptl_print_peers(int argc, char **argv);
-int jt_ptl_add_peer(int argc, char **argv);
-int jt_ptl_del_peer(int argc, char **argv);
-int jt_ptl_print_connections(int argc, char **argv);
-int jt_ptl_disconnect(int argc, char **argv);
-int jt_ptl_push_connection(int argc, char **argv);
-int jt_ptl_print_active_txs(int argc, char **argv);
-int jt_ptl_ping(int argc, char **argv);
-int jt_ptl_mynid(int argc, char **argv);
-int jt_ptl_add_uuid(int argc, char **argv);
-int jt_ptl_add_uuid_old(int argc, char **argv); /* backwards compatibility  */
-int jt_ptl_close_uuid(int argc, char **argv);
-int jt_ptl_del_uuid(int argc, char **argv);
-int jt_ptl_add_route(int argc, char **argv);
-int jt_ptl_del_route(int argc, char **argv);
-int jt_ptl_notify_router(int argc, char **argv);
-int jt_ptl_print_routes(int argc, char **argv);
-int jt_ptl_fail_nid(int argc, char **argv);
-int jt_ptl_lwt(int argc, char **argv);
-int jt_ptl_testprotocompat(int argc, char **argv);
-int jt_ptl_memhog(int argc, char **argv);
-
-int dbg_initialize(int argc, char **argv);
-int jt_dbg_filter(int argc, char **argv);
-int jt_dbg_show(int argc, char **argv);
-int jt_dbg_list(int argc, char **argv);
-int jt_dbg_debug_kernel(int argc, char **argv);
-int jt_dbg_debug_daemon(int argc, char **argv);
-int jt_dbg_debug_file(int argc, char **argv);
-int jt_dbg_clear_debug_buf(int argc, char **argv);
-int jt_dbg_mark_debug_buf(int argc, char **argv);
-int jt_dbg_modules(int argc, char **argv);
-int jt_dbg_panic(int argc, char **argv);
-
 #endif
-- 
1.8.3.1
