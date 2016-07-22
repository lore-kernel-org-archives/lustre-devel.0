From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:43:56 -0400
Subject: [lustre-devel] [PATCH 03/58] staging: lustre: ptlrpc: remove
	wirecheck for struct lmv_stripe_md
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Remove the wiretest check for this data structure.

Signed-off-by: wang di <di.wang@intel.com>
Reviewed-on: http://review.whamcloud.com/7043
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3531
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c |   29 -----------------------
 1 files changed, 0 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 6cc2b2e..4c500a9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -2617,35 +2617,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lmv_desc *)0)->ld_uuid) == 40, "found %lld\n",
 		 (long long)(int)sizeof(((struct lmv_desc *)0)->ld_uuid));
 
-	/* Checks for struct lmv_stripe_md */
-	LASSERTF((int)sizeof(struct lmv_stripe_md) == 32, "found %lld\n",
-		 (long long)(int)sizeof(struct lmv_stripe_md));
-	LASSERTF((int)offsetof(struct lmv_stripe_md, mea_magic) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_stripe_md, mea_magic));
-	LASSERTF((int)sizeof(((struct lmv_stripe_md *)0)->mea_magic) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_stripe_md *)0)->mea_magic));
-	LASSERTF((int)offsetof(struct lmv_stripe_md, mea_count) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_stripe_md, mea_count));
-	LASSERTF((int)sizeof(((struct lmv_stripe_md *)0)->mea_count) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_stripe_md *)0)->mea_count));
-	LASSERTF((int)offsetof(struct lmv_stripe_md, mea_master) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_stripe_md, mea_master));
-	LASSERTF((int)sizeof(((struct lmv_stripe_md *)0)->mea_master) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_stripe_md *)0)->mea_master));
-	LASSERTF((int)offsetof(struct lmv_stripe_md, mea_padding) == 12, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_stripe_md, mea_padding));
-	LASSERTF((int)sizeof(((struct lmv_stripe_md *)0)->mea_padding) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_stripe_md *)0)->mea_padding));
-	CLASSERT(LOV_MAXPOOLNAME == 16);
-	LASSERTF((int)offsetof(struct lmv_stripe_md, mea_pool_name[16]) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_stripe_md, mea_pool_name[16]));
-	LASSERTF((int)sizeof(((struct lmv_stripe_md *)0)->mea_pool_name[16]) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_stripe_md *)0)->mea_pool_name[16]));
-	LASSERTF((int)offsetof(struct lmv_stripe_md, mea_ids[0]) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_stripe_md, mea_ids[0]));
-	LASSERTF((int)sizeof(((struct lmv_stripe_md *)0)->mea_ids[0]) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_stripe_md *)0)->mea_ids[0]));
-
 	/* Checks for struct lov_desc */
 	LASSERTF((int)sizeof(struct lov_desc) == 88, "found %lld\n",
 		 (long long)(int)sizeof(struct lov_desc));
-- 
1.7.1
