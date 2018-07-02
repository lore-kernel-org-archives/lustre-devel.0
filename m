From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:27 -0400
Subject: [lustre-devel] [PATCH 10/18] lustre: ladvise: Add willread advice
 support for ladvise
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

This patch adds WILLREAD advice to ladvise framework. OSS will
prefetch data into memory when this hint is provided. It is not
garanteed how long the cached pages will be kept in memory.

Signed-off-by: Li Xi <lixi@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4931
Reviewed-on: http://review.whamcloud.com/12458
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h | 2 ++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c                | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 063a7db..02b51ca 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -1325,9 +1325,11 @@ struct hsm_copy {
 
 enum lu_ladvise_type {
 	LU_LADVISE_INVALID	= 0,
+	LU_LADVISE_WILLREAD	= 1,
 };
 
 #define LU_LADVISE_NAMES {				\
+	[LU_LADVISE_WILLREAD]	= "willread",		\
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index a1895cb..aa17d01 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -4243,6 +4243,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lu_ladvise, lla_value4));
 	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_value4) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_value4));
+	LASSERTF(LU_LADVISE_WILLREAD == 1, "found %lld\n",
+		 (long long)LU_LADVISE_WILLREAD);
 
 	/* Checks for struct ladvise_hdr */
 	LASSERTF(LADVISE_MAGIC == 0x1ADF1CE0, "found 0x%.8x\n",
@@ -4277,4 +4279,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ladvise_hdr, lah_advise));
 	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_advise) == 0, "found %lld\n",
 		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_advise));
+	LASSERTF(LF_ASYNC == 0x00000001UL, "found 0x%.8xUL\n",
+		 (unsigned int)LF_ASYNC);
 }
-- 
1.8.3.1
