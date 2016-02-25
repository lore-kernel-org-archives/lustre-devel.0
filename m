From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:12 -0500
Subject: [lustre-devel] [PATCH v2 29/84] staging/lustre: Remove
	*_CONNECT_SUPPORTED defines
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-30-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

These defines are only used on the servers to determine
what connect flags corresponding servers support:
MDT_CONNECT_SUPPORTED
OST_CONNECT_SUPPORTED
MGS_CONNECT_SUPPORTED
ECHO_CONNECT_SUPPORTED

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      | 50 ++--------------------
 1 file changed, 4 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index eeb0542..26f1c43 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1248,61 +1248,19 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
  * submit a small patch against EVERY branch that ONLY adds the new flag,
  * updates obd_connect_names[] for lprocfs_rd_connect_flags(), adds the
  * flag to check_obd_connect_data(), and updates wiretests accordingly, so it
- * can be approved and landed easily to reserve the flag for future use. */
+ * can be approved and landed easily to reserve the flag for future use.
+ */
 
 /* The MNE_SWAB flag is overloading the MDS_MDS bit only for the MGS
  * connection.  It is a temporary bug fix for Imperative Recovery interop
  * between 2.2 and 2.3 x86/ppc nodes, and can be removed when interop for
- * 2.2 clients/servers is no longer needed.  LU-1252/LU-1644. */
+ * 2.2 clients/servers is no longer needed.  LU-1252/LU-1644.
+ */
 #define OBD_CONNECT_MNE_SWAB		 OBD_CONNECT_MDS_MDS
 
 #define OCD_HAS_FLAG(ocd, flg)  \
 	(!!((ocd)->ocd_connect_flags & OBD_CONNECT_##flg))
 
-#define LRU_RESIZE_CONNECT_FLAG OBD_CONNECT_LRU_RESIZE
-
-#define MDT_CONNECT_SUPPORTED  (OBD_CONNECT_RDONLY | OBD_CONNECT_VERSION | \
-				OBD_CONNECT_ACL | OBD_CONNECT_XATTR | \
-				OBD_CONNECT_IBITS | \
-				OBD_CONNECT_NODEVOH | OBD_CONNECT_ATTRFID | \
-				OBD_CONNECT_CANCELSET | OBD_CONNECT_AT | \
-				OBD_CONNECT_RMT_CLIENT | \
-				OBD_CONNECT_RMT_CLIENT_FORCE | \
-				OBD_CONNECT_BRW_SIZE | OBD_CONNECT_MDS_CAPA | \
-				OBD_CONNECT_OSS_CAPA | OBD_CONNECT_MDS_MDS | \
-				OBD_CONNECT_FID | LRU_RESIZE_CONNECT_FLAG | \
-				OBD_CONNECT_VBR | OBD_CONNECT_LOV_V3 | \
-				OBD_CONNECT_SOM | OBD_CONNECT_FULL20 | \
-				OBD_CONNECT_64BITHASH | OBD_CONNECT_JOBSTATS | \
-				OBD_CONNECT_EINPROGRESS | \
-				OBD_CONNECT_LIGHTWEIGHT | OBD_CONNECT_UMASK | \
-				OBD_CONNECT_LVB_TYPE | OBD_CONNECT_LAYOUTLOCK |\
-				OBD_CONNECT_PINGLESS | OBD_CONNECT_MAX_EASIZE |\
-				OBD_CONNECT_FLOCK_DEAD | \
-				OBD_CONNECT_DISP_STRIPE)
-
-#define OST_CONNECT_SUPPORTED  (OBD_CONNECT_SRVLOCK | OBD_CONNECT_GRANT | \
-				OBD_CONNECT_REQPORTAL | OBD_CONNECT_VERSION | \
-				OBD_CONNECT_TRUNCLOCK | OBD_CONNECT_INDEX | \
-				OBD_CONNECT_BRW_SIZE | OBD_CONNECT_OSS_CAPA | \
-				OBD_CONNECT_CANCELSET | OBD_CONNECT_AT | \
-				LRU_RESIZE_CONNECT_FLAG | OBD_CONNECT_CKSUM | \
-				OBD_CONNECT_RMT_CLIENT | \
-				OBD_CONNECT_RMT_CLIENT_FORCE | OBD_CONNECT_VBR | \
-				OBD_CONNECT_MDS | OBD_CONNECT_SKIP_ORPHAN | \
-				OBD_CONNECT_GRANT_SHRINK | OBD_CONNECT_FULL20 | \
-				OBD_CONNECT_64BITHASH | OBD_CONNECT_MAXBYTES | \
-				OBD_CONNECT_MAX_EASIZE | \
-				OBD_CONNECT_EINPROGRESS | \
-				OBD_CONNECT_JOBSTATS | \
-				OBD_CONNECT_LIGHTWEIGHT | OBD_CONNECT_LVB_TYPE|\
-				OBD_CONNECT_LAYOUTLOCK | OBD_CONNECT_FID | \
-				OBD_CONNECT_PINGLESS)
-#define ECHO_CONNECT_SUPPORTED (0)
-#define MGS_CONNECT_SUPPORTED  (OBD_CONNECT_VERSION | OBD_CONNECT_AT | \
-				OBD_CONNECT_FULL20 | OBD_CONNECT_IMP_RECOV | \
-				OBD_CONNECT_MNE_SWAB | OBD_CONNECT_PINGLESS)
-
 /* Features required for this version of the client to work with server */
 #define CLIENT_CONNECT_MDT_REQD (OBD_CONNECT_IBITS | OBD_CONNECT_FID | \
 				 OBD_CONNECT_FULL20)
-- 
2.1.0
