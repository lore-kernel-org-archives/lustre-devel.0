From: Anton Gerasimov <anton.gerasimov@openmailbox.org>
Date: Wed, 23 Sep 2015 00:41:51 +0300
Subject: [lustre-devel] [PATCH 3/3] staging: lustre: make non-exported
	functions static
In-Reply-To: <1442957713-14727-1-git-send-email-anton.gerasimov@openmailbox.org>
References: <1442957713-14727-1-git-send-email-anton.gerasimov@openmailbox.org>
Message-ID: <1442958111-15122-1-git-send-email-anton.gerasimov@openmailbox.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Declare non-exported functions in pack_generic.c as static.

Signed-off-by: Anton Gerasimov <anton.gerasimov@openmailbox.org>
---
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index f138061..dd31215 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -442,8 +442,8 @@ void *lustre_msg_buf(struct lustre_msg *m, int n, int min_size)
 }
 EXPORT_SYMBOL(lustre_msg_buf);
 
-int lustre_shrink_msg_v2(struct lustre_msg_v2 *msg, int segment,
-			 unsigned int newlen, int move_data)
+static int lustre_shrink_msg_v2(struct lustre_msg_v2 *msg, int segment,
+				unsigned int newlen, int move_data)
 {
 	char *tail = NULL, *newpos;
 	int tail_len = 0, n;
@@ -1929,7 +1929,7 @@ void lustre_swab_fid2path(struct getinfo_fid2path *gf)
 }
 EXPORT_SYMBOL(lustre_swab_fid2path);
 
-void lustre_swab_fiemap_extent(struct ll_fiemap_extent *fm_extent)
+static void lustre_swab_fiemap_extent(struct ll_fiemap_extent *fm_extent)
 {
 	__swab64s(&fm_extent->fe_logical);
 	__swab64s(&fm_extent->fe_physical);
@@ -2405,7 +2405,7 @@ void lustre_swab_hsm_state_set(struct hsm_state_set *hss)
 }
 EXPORT_SYMBOL(lustre_swab_hsm_state_set);
 
-void lustre_swab_hsm_extent(struct hsm_extent *extent)
+static void lustre_swab_hsm_extent(struct hsm_extent *extent)
 {
 	__swab64s(&extent->offset);
 	__swab64s(&extent->length);
-- 
2.5.1
