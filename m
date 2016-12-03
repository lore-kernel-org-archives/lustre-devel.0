From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:16 -0500
Subject: [lustre-devel] [PATCH 09/22] staging: lustre: llite: Add client
	mount opt to ignore suppress_pings
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Wally Wang <wang@cray.com>, James Simmons <jsimmons@infradead.org>

From: Wally Wang <wang@cray.com>

When Lustre servers enable 'suppress_pings', all clients will stop
pinging. However, some clients may not have external mechanism
to notify Lustre servers for node death and therefore need to
preserve the Lustre ping.

This patch provides a mount option 'always_ping' so that the
client will not stop pinging even if the server has enabled
'suppress_pings'.

Signed-off-by: Wally Wang <wang@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6391
Reviewed-on: http://review.whamcloud.com/14127
Reviewed-by: Li Wei <wei.g.li@intel.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    3 +++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   16 ++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index e37ba1f..2f46d47 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -391,6 +391,8 @@ enum stats_track_type {
 #define LL_SBI_USER_FID2PATH  0x40000 /* allow fid2path by unprivileged users */
 #define LL_SBI_XATTR_CACHE    0x80000 /* support for xattr cache */
 #define LL_SBI_NOROOTSQUASH	0x100000 /* do not apply root squash */
+#define LL_SBI_ALWAYS_PING	0x200000 /* always ping even if server
+					  * suppress_pings */
 
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
@@ -414,6 +416,7 @@ enum stats_track_type {
 	"user_fid2path",\
 	"xattr_cache",	\
 	"norootsquash",	\
+	"always_ping",	\
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 2a51efa..25f5aed 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -224,6 +224,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 	/* real client */
 	data->ocd_connect_flags |= OBD_CONNECT_REAL;
 
+	/* always ping even if server suppress_pings */
+	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
+		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
+
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
 	err = obd_connect(NULL, &sbi->ll_md_exp, obd, &sbi->ll_sb_uuid,
@@ -373,6 +377,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 
 	data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 
+	/* always ping even if server suppress_pings */
+	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
+		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
+
 	CDEBUG(D_RPCTRACE, "ocd_connect_flags: %#llx ocd_version: %d ocd_grant: %d\n",
 	       data->ocd_connect_flags,
 	       data->ocd_version, data->ocd_grant);
@@ -788,6 +796,11 @@ static int ll_options(char *options, int *flags)
 			*flags &= ~tmp;
 			goto next;
 		}
+		tmp = ll_set_opt("always_ping", s1, LL_SBI_ALWAYS_PING);
+		if (tmp) {
+			*flags |= tmp;
+			goto next;
+		}
 		LCONSOLE_ERROR_MSG(0x152, "Unknown option '%s', won't mount.\n",
 				   s1);
 		return -EINVAL;
@@ -2361,6 +2374,9 @@ int ll_show_options(struct seq_file *seq, struct dentry *dentry)
 	if (sbi->ll_flags & LL_SBI_USER_FID2PATH)
 		seq_puts(seq, ",user_fid2path");
 
+	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
+		seq_puts(seq, ",always_ping");
+
 	return 0;
 }
 
-- 
1.7.1
