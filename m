From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:04 -0500
Subject: [lustre-devel] [PATCH 26/56] staging/lustre: Remove server-side
	changelog defines
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-27-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

CHANGELOG_MAGIC, CHANGELOG_MINMASK, CHANGELOG_ALLMASK,
CHANGELOG_DEFMASK and CHANGELOG_USER_PREFIX are all unused
on the client.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 90ff181..d2f05e3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3039,15 +3039,6 @@ struct llog_size_change_rec {
 	struct llog_rec_tail	lsc_tail;
 } __packed;
 
-#define CHANGELOG_MAGIC 0xca103000
-
-/** \a changelog_rec_type's that can't be masked */
-#define CHANGELOG_MINMASK (1 << CL_MARK)
-/** bits covering all \a changelog_rec_type's */
-#define CHANGELOG_ALLMASK 0XFFFFFFFF
-/** default \a changelog_rec_type mask */
-#define CHANGELOG_DEFMASK CHANGELOG_ALLMASK & ~(1 << CL_ATIME | 1 << CL_CLOSE)
-
 /* changelog llog name, needed by client replicators */
 #define CHANGELOG_CATALOG "changelog_catalog"
 
@@ -3069,8 +3060,6 @@ struct llog_changelog_ext_rec {
 	struct llog_rec_tail     cr_tail; /**< for_sizezof_only */
 } __packed;
 
-#define CHANGELOG_USER_PREFIX "cl"
-
 struct llog_changelog_user_rec {
 	struct llog_rec_hdr   cur_hdr;
 	__u32		 cur_id;
-- 
2.1.0
