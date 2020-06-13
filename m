From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:03 -0400
Subject: [lustre-devel] [PATCH 07/20] lustre: SEL: Add flag & setstripe
 support
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <paf@cray.com>

The self-extending layouts feature adds a new layout flag
and also uses the stripe size field differently.

This patch implements this basic functionality, to be used
in subsequent patches.

Cray-bug-id: LUS-2528
WC-bug-id: https://jira.whamcloud.com/browse/LU-10070
Lustre-commit: fed241911f61b ("LU-10070 lod: SEL: Add flag & setstripe support")
Signed-off-by: Patrick Farrell <paf@cray.com>
Reviewed-on: https://review.whamcloud.com/33782
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             | 1 +
 include/uapi/linux/lustre/lustre_user.h | 8 ++++----
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index dc1d0af..719d73b 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1659,6 +1659,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LCME_FL_OFFLINE != 0x00000008);
 	BUILD_BUG_ON(LCME_FL_INIT != 0x00000010);
 	BUILD_BUG_ON(LCME_FL_NOSYNC != 0x00000020);
+	BUILD_BUG_ON(LCME_FL_EXTENSION != 0x00000040);
 	BUILD_BUG_ON(LCME_FL_NEG != 0x80000000);
 
 	/* Checks for struct lov_comp_md_v1 */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index b255f14..004d373 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -548,17 +548,17 @@ enum lov_comp_md_entry_flags {
 	LCME_FL_OFFLINE		= 0x00000008,	/* Not used */
 	LCME_FL_INIT		= 0x00000010,	/* instantiated */
 	LCME_FL_NOSYNC		= 0x00000020,	/* FLR: no sync for the mirror */
+	LCME_FL_EXTENSION	= 0x00000040,	/* extension comp, never init */
 	LCME_FL_NEG		= 0x80000000,	/* used to indicate a negative
 						 * flag, won't be stored on disk
 						 */
 };
 
 #define LCME_KNOWN_FLAGS	(LCME_FL_NEG | LCME_FL_INIT | LCME_FL_STALE | \
-				 LCME_FL_PREF_RW | LCME_FL_NOSYNC)
-/* The flags can be set by users at mirror creation time. */
-#define LCME_USER_FLAGS		(LCME_FL_PREF_RW)
+				 LCME_FL_PREF_RW | LCME_FL_NOSYNC | \
+				 LCME_FL_EXTENSION)
 
-/* The flags are for mirrors */
+/* The mirror flags sent by client */
 #define LCME_MIRROR_FLAGS	(LCME_FL_NOSYNC)
 
 /* the highest bit in obdo::o_layout_version is used to mark if the file is
-- 
1.8.3.1
