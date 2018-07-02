From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:29 -0400
Subject: [lustre-devel] [PATCH 12/18] lustre: ladvise: Add dontneed advice
 support for ladvise
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

This patch addds DONTNEED advice to ladvise framework. OSS will
cleanup the page cache of the file when this hint is provided.

Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Gu Zheng <gzheng@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4931
Reviewed-on: http://review.whamcloud.com/20203
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h | 2 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c                | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 02b51ca..4fa7796 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -1326,10 +1326,12 @@ struct hsm_copy {
 enum lu_ladvise_type {
 	LU_LADVISE_INVALID	= 0,
 	LU_LADVISE_WILLREAD	= 1,
+	LU_LADVISE_DONTNEED	= 2,
 };
 
 #define LU_LADVISE_NAMES {				\
 	[LU_LADVISE_WILLREAD]	= "willread",		\
+	[LU_LADVISE_DONTNEED]	= "dontneed",		\
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index aa17d01..61995c3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -4245,6 +4245,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_value4));
 	LASSERTF(LU_LADVISE_WILLREAD == 1, "found %lld\n",
 		 (long long)LU_LADVISE_WILLREAD);
+	LASSERTF(LU_LADVISE_DONTNEED == 2, "found %lld\n",
+		 (long long)LU_LADVISE_DONTNEED);
 
 	/* Checks for struct ladvise_hdr */
 	LASSERTF(LADVISE_MAGIC == 0x1ADF1CE0, "found 0x%.8x\n",
-- 
1.8.3.1
