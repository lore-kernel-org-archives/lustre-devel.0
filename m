From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:57 -0400
Subject: [lustre-devel] [PATCH 17/18] lustre: obd: add new LPROCFS_TYPE_*
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

Move LPROCFS_TYPE_LATENCY from llite later to lprocfs_status.h.
Create new LPROCFS_TYPE_BYTES_FULL settings.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13597
Lustre-commit: cd8fb1e8d300c ("LU-13597 ofd: add more information to job_stats")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38816
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h | 9 +++++++--
 fs/lustre/llite/lproc_llite.c      | 8 ++------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 0d90b31..759e66b 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -143,6 +143,13 @@ enum {
 	LPROCFS_TYPE_BYTES		= 0x0200,
 	LPROCFS_TYPE_PAGES		= 0x0400,
 	LPROCFS_TYPE_USEC		= 0x0800,
+
+	LPROCFS_TYPE_LATENCY		= LPROCFS_TYPE_USEC |
+					  LPROCFS_CNTR_AVGMINMAX |
+					  LPROCFS_CNTR_STDDEV,
+	LPROCFS_TYPE_BYTES_FULL		= LPROCFS_TYPE_BYTES |
+					  LPROCFS_CNTR_AVGMINMAX |
+					  LPROCFS_CNTR_STDDEV,
 };
 
 #define LC_MIN_INIT ((~(u64)0) >> 1)
@@ -364,8 +371,6 @@ enum {
 #define JOBSTATS_SESSION		"session"
 
 /* obd_config.c */
-void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg));
-
 int lprocfs_stats_alloc_one(struct lprocfs_stats *stats,
 			    unsigned int cpuid);
 int lprocfs_stats_lock(struct lprocfs_stats *stats,
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 4bce3a6..f5a1940 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1552,18 +1552,14 @@ static void sbi_kobj_release(struct kobject *kobj)
 	.release	= sbi_kobj_release,
 };
 
-#define LPROCFS_TYPE_LATENCY \
-	(LPROCFS_TYPE_USEC | LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV)
 static const struct llite_file_opcode {
 	u32		opcode;
 	u32		type;
 	const char	*opname;
 } llite_opcode_table[LPROC_LL_FILE_OPCODES] = {
 	/* file operation */
-	{ LPROC_LL_READ_BYTES,	LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
-		"read_bytes" },
-	{ LPROC_LL_WRITE_BYTES,	LPROCFS_CNTR_AVGMINMAX | LPROCFS_TYPE_BYTES,
-		"write_bytes" },
+	{ LPROC_LL_READ_BYTES,	LPROCFS_TYPE_BYTES_FULL, "read_bytes" },
+	{ LPROC_LL_WRITE_BYTES,	LPROCFS_TYPE_BYTES_FULL, "write_bytes" },
 	{ LPROC_LL_READ,	LPROCFS_TYPE_LATENCY,	"read" },
 	{ LPROC_LL_WRITE,	LPROCFS_TYPE_LATENCY,	"write" },
 	{ LPROC_LL_IOCTL,	LPROCFS_TYPE_REQS,	"ioctl" },
-- 
1.8.3.1
