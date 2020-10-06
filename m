From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:57 -0400
Subject: [lustre-devel] [PATCH 18/42] lustre: llite: report client stats
 sumsq
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Commit 2eeb tries to account sumsq for every client operation, but
lprocfs_counter_init() did not init them properly, also add a test
case to verify new format of client stats.

Fixes: 2eeb6dba81bc ("lustre: obd: add new LPROCFS_TYPE_*")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13733
Lustre-commit: 8a1334626ec2f ("LU-13733 llite: report client stats sumsq")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/39223
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index a742200..54db7eb 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1673,19 +1673,16 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 	/* do counter init */
 	for (id = 0; id < LPROC_LL_FILE_OPCODES; id++) {
 		u32 type = llite_opcode_table[id].type;
-		void *ptr = NULL;
+		void *ptr = "unknown";
 
 		if (type & LPROCFS_TYPE_REQS)
 			ptr = "reqs";
 		else if (type & LPROCFS_TYPE_BYTES)
 			ptr = "bytes";
-		else if (type & LPROCFS_TYPE_PAGES)
-			ptr = "pages";
 		else if (type & LPROCFS_TYPE_USEC)
 			ptr = "usec";
 		lprocfs_counter_init(sbi->ll_stats,
-				     llite_opcode_table[id].opcode,
-				     (type & LPROCFS_CNTR_AVGMINMAX),
+				     llite_opcode_table[id].opcode, type,
 				     llite_opcode_table[id].opname, ptr);
 	}
 
-- 
1.8.3.1
