From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:23 -0400
Subject: [lustre-devel] [PATCH 29/64 v2] staging: lustre: uapi: style
	cleanup of lustre_cfg.h
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Some style and white space cleanups to make lustre_cfg.h
easy to read.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/26966
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_cfg.h  | 110 +++++++++++----------
 1 file changed, 60 insertions(+), 50 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index 4208d61..2d37d1b 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -57,48 +57,61 @@
  * in order to mount the filesystem. If it does not understand
  * a REQUIRED command the client mount will fail.
  */
-#define LCFG_REQUIRED	 0x0001000
+#define LCFG_REQUIRED	0x0001000
 
 enum lcfg_command_type {
-	LCFG_ATTACH	     = 0x00cf001, /**< create a new obd instance */
-	LCFG_DETACH	     = 0x00cf002, /**< destroy obd instance */
-	LCFG_SETUP	      = 0x00cf003, /**< call type-specific setup */
-	LCFG_CLEANUP	    = 0x00cf004, /**< call type-specific cleanup */
-	LCFG_ADD_UUID	   = 0x00cf005, /**< add a nid to a niduuid */
-	LCFG_DEL_UUID	   = 0x00cf006, /**< remove a nid from a niduuid */
-	LCFG_MOUNTOPT	   = 0x00cf007, /**< create a profile (mdc, osc) */
-	LCFG_DEL_MOUNTOPT       = 0x00cf008, /**< destroy a profile */
-	LCFG_SET_TIMEOUT	= 0x00cf009, /**< set obd_timeout */
-	LCFG_SET_UPCALL	 = 0x00cf00a, /**< deprecated */
-	LCFG_ADD_CONN	   = 0x00cf00b, /**< add a failover niduuid to an obd */
-	LCFG_DEL_CONN	   = 0x00cf00c, /**< remove a failover niduuid */
-	LCFG_LOV_ADD_OBD	= 0x00cf00d, /**< add an osc to a lov */
-	LCFG_LOV_DEL_OBD	= 0x00cf00e, /**< remove an osc from a lov */
-	LCFG_PARAM	      = 0x00cf00f, /**< set a proc parameter */
-	LCFG_MARKER	     = 0x00cf010, /**< metadata about next cfg rec */
-	LCFG_LOG_START	  = 0x00ce011, /**< mgc only, process a cfg log */
-	LCFG_LOG_END	    = 0x00ce012, /**< stop processing updates */
-	LCFG_LOV_ADD_INA	= 0x00ce013, /**< like LOV_ADD_OBD, inactive */
-	LCFG_ADD_MDC	    = 0x00cf014, /**< add an mdc to a lmv */
-	LCFG_DEL_MDC	    = 0x00cf015, /**< remove an mdc from a lmv */
-	LCFG_SPTLRPC_CONF       = 0x00ce016, /**< security */
-	LCFG_POOL_NEW	   = 0x00ce020, /**< create an ost pool name */
-	LCFG_POOL_ADD	   = 0x00ce021, /**< add an ost to a pool */
-	LCFG_POOL_REM	   = 0x00ce022, /**< remove an ost from a pool */
-	LCFG_POOL_DEL	   = 0x00ce023, /**< destroy an ost pool name */
-	LCFG_SET_LDLM_TIMEOUT   = 0x00ce030, /**< set ldlm_timeout */
-	LCFG_PRE_CLEANUP	= 0x00cf031, /**< call type-specific pre
-					      * cleanup cleanup
-					      */
-	LCFG_SET_PARAM		= 0x00ce032, /**< use set_param syntax to set
-					      * a proc parameters
-					      */
+	LCFG_ATTACH		  = 0x00cf001, /**< create a new obd instance */
+	LCFG_DETACH		  = 0x00cf002, /**< destroy obd instance */
+	LCFG_SETUP		  = 0x00cf003, /**< call type-specific setup */
+	LCFG_CLEANUP		  = 0x00cf004, /**< call type-specific cleanup
+						 */
+	LCFG_ADD_UUID		  = 0x00cf005, /**< add a nid to a niduuid */
+	LCFG_DEL_UUID		  = 0x00cf006, /**< remove a nid from
+						 *  a niduuid
+						 */
+	LCFG_MOUNTOPT		  = 0x00cf007, /**< create a profile
+						 * (mdc, osc)
+						 */
+	LCFG_DEL_MOUNTOPT	  = 0x00cf008, /**< destroy a profile */
+	LCFG_SET_TIMEOUT	  = 0x00cf009, /**< set obd_timeout */
+	LCFG_SET_UPCALL		  = 0x00cf00a, /**< deprecated */
+	LCFG_ADD_CONN		  = 0x00cf00b, /**< add a failover niduuid to
+						 *  an obd
+						 */
+	LCFG_DEL_CONN		  = 0x00cf00c, /**< remove a failover niduuid */
+	LCFG_LOV_ADD_OBD	  = 0x00cf00d, /**< add an osc to a lov */
+	LCFG_LOV_DEL_OBD	  = 0x00cf00e, /**< remove an osc from a lov */
+	LCFG_PARAM		  = 0x00cf00f, /**< set a proc parameter */
+	LCFG_MARKER		  = 0x00cf010, /**< metadata about next
+						 *  cfg rec
+						 */
+	LCFG_LOG_START		  = 0x00ce011, /**< mgc only, process a
+						 *  cfg log
+						 */
+	LCFG_LOG_END		  = 0x00ce012, /**< stop processing updates */
+	LCFG_LOV_ADD_INA	  = 0x00ce013, /**< like LOV_ADD_OBD,
+						 *  inactive
+						 */
+	LCFG_ADD_MDC		  = 0x00cf014, /**< add an mdc to a lmv */
+	LCFG_DEL_MDC		  = 0x00cf015, /**< remove an mdc from a lmv */
+	LCFG_SPTLRPC_CONF	  = 0x00ce016, /**< security */
+	LCFG_POOL_NEW		  = 0x00ce020, /**< create an ost pool name */
+	LCFG_POOL_ADD		  = 0x00ce021, /**< add an ost to a pool */
+	LCFG_POOL_REM		  = 0x00ce022, /**< remove an ost from a pool */
+	LCFG_POOL_DEL		  = 0x00ce023, /**< destroy an ost pool name */
+	LCFG_SET_LDLM_TIMEOUT	  = 0x00ce030, /**< set ldlm_timeout */
+	LCFG_PRE_CLEANUP	  = 0x00cf031, /**< call type-specific pre
+						 * cleanup cleanup
+						 */
+	LCFG_SET_PARAM		  = 0x00ce032, /**< use set_param syntax to set
+						 * a proc parameters
+						 */
 };
 
 struct lustre_cfg_bufs {
-	void    *lcfg_buf[LUSTRE_CFG_MAX_BUFCOUNT];
-	__u32    lcfg_buflen[LUSTRE_CFG_MAX_BUFCOUNT];
-	__u32    lcfg_bufcount;
+	void  *lcfg_buf[LUSTRE_CFG_MAX_BUFCOUNT];
+	__u32 lcfg_buflen[LUSTRE_CFG_MAX_BUFCOUNT];
+	__u32 lcfg_bufcount;
 };
 
 struct lustre_cfg {
@@ -115,40 +128,37 @@ struct lustre_cfg {
 };
 
 enum cfg_record_type {
-	PORTALS_CFG_TYPE = 1,
-	LUSTRE_CFG_TYPE = 123,
+	PORTALS_CFG_TYPE	= 1,
+	LUSTRE_CFG_TYPE		= 123,
 };
 
-#define LUSTRE_CFG_BUFLEN(lcfg, idx)	    \
-	((lcfg)->lcfg_bufcount <= (idx)	 \
-	 ? 0				    \
-	 : (lcfg)->lcfg_buflens[(idx)])
+#define LUSTRE_CFG_BUFLEN(lcfg, idx)					\
+	((lcfg)->lcfg_bufcount <= (idx) ? 0 : (lcfg)->lcfg_buflens[(idx)])
 
 static inline void lustre_cfg_bufs_set(struct lustre_cfg_bufs *bufs,
-				       __u32		   index,
-				       void		   *buf,
-				       __u32		   buflen)
+				       __u32 index, void *buf, __u32 buflen)
 {
 	if (index >= LUSTRE_CFG_MAX_BUFCOUNT)
 		return;
+
 	if (!bufs)
 		return;
 
 	if (bufs->lcfg_bufcount <= index)
 		bufs->lcfg_bufcount = index + 1;
 
-	bufs->lcfg_buf[index]    = buf;
+	bufs->lcfg_buf[index] = buf;
 	bufs->lcfg_buflen[index] = buflen;
 }
 
 static inline void lustre_cfg_bufs_set_string(struct lustre_cfg_bufs *bufs,
-					      __u32 index,
-					      char *str)
+					      __u32 index, char *str)
 {
 	lustre_cfg_bufs_set(bufs, index, str, str ? strlen(str) + 1 : 0);
 }
 
-static inline void lustre_cfg_bufs_reset(struct lustre_cfg_bufs *bufs, char *name)
+static inline void lustre_cfg_bufs_reset(struct lustre_cfg_bufs *bufs,
+					 char *name)
 {
 	memset((bufs), 0, sizeof(*bufs));
 	if (name)
-- 
1.8.3.1
