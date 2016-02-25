From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:57 -0500
Subject: [lustre-devel] [PATCH v2 14/84] staging/lustre: Get rid of
	llog_op_type typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-15-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace with enum llog_op_type

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 27ee853..bb82a87 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2950,7 +2950,7 @@ struct llog_catid {
 #define LLOG_OP_MAGIC 0x10600000
 #define LLOG_OP_MASK  0xfff00000
 
-typedef enum {
+enum llog_op_type {
 	LLOG_PAD_MAGIC		= LLOG_OP_MAGIC | 0x00000,
 	OST_SZ_REC		= LLOG_OP_MAGIC | 0x00f00,
 	/* OST_RAID1_REC	= LLOG_OP_MAGIC | 0x01000, never used */
@@ -2970,7 +2970,7 @@ typedef enum {
 	HSM_AGENT_REC		= LLOG_OP_MAGIC | 0x80000,
 	LLOG_HDR_MAGIC		= LLOG_OP_MAGIC | 0x45539,
 	LLOG_LOGID_MAGIC	= LLOG_OP_MAGIC | 0x4553b,
-} llog_op_type;
+};
 
 #define LLOG_REC_HDR_NEEDS_SWABBING(r) \
 	(((r)->lrh_type & __swab32(LLOG_OP_MASK)) == __swab32(LLOG_OP_MAGIC))
-- 
2.1.0
