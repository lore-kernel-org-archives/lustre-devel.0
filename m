From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:37 -0500
Subject: [lustre-devel] [PATCH 07/35] staging: lustre: lov: avoid infinite
	loop in lsm_alloc_plain()
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In lsm_alloc_plain() use a signed loop index to avoid an infinite loop
in the error path.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6872
Reviewed-on: http://review.whamcloud.com/15644
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_ea.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 218f275..ac0bf64 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -81,7 +81,7 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
 	size_t oinfo_ptrs_size, lsm_size;
 	struct lov_stripe_md *lsm;
 	struct lov_oinfo     *loi;
-	unsigned int i;
+	int i;
 
 	LASSERT(stripe_count <= LOV_MAX_STRIPE_COUNT);
 
-- 
1.7.1
