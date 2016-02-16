From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:42 -0500
Subject: [lustre-devel] [PATCH 10/45] staging/lustre: Remove commented out
	lock_lock_multi_match
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-11-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

lock_lock_multi_match stayed commented out unused for ages now,
so let's just remove it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_lock.c | 39 ----------------------------
 1 file changed, 39 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index d866791..36615da 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -852,45 +852,6 @@ static int lov_lock_use(const struct lu_env *env,
 	return result;
 }
 
-#if 0
-static int lock_lock_multi_match()
-{
-	struct cl_lock	  *lock    = slice->cls_lock;
-	struct cl_lock_descr    *subneed = &lov_env_info(env)->lti_ldescr;
-	struct lov_object       *loo     = cl2lov(lov->lls_cl.cls_obj);
-	struct lov_layout_raid0 *r0      = lov_r0(loo);
-	struct lov_lock_sub     *sub;
-	struct cl_object	*subobj;
-	u64  fstart;
-	u64  fend;
-	u64  start;
-	u64  end;
-	int i;
-
-	fstart = cl_offset(need->cld_obj, need->cld_start);
-	fend   = cl_offset(need->cld_obj, need->cld_end + 1) - 1;
-	subneed->cld_mode = need->cld_mode;
-	cl_lock_mutex_get(env, lock);
-	for (i = 0; i < lov->lls_nr; ++i) {
-		sub = &lov->lls_sub[i];
-		if (sub->sub_lock == NULL)
-			continue;
-		subobj = sub->sub_descr.cld_obj;
-		if (!lov_stripe_intersects(loo->lo_lsm, sub->sub_stripe,
-					   fstart, fend, &start, &end))
-			continue;
-		subneed->cld_start = cl_index(subobj, start);
-		subneed->cld_end   = cl_index(subobj, end);
-		subneed->cld_obj   = subobj;
-		if (!cl_lock_ext_match(&sub->sub_got, subneed)) {
-			result = 0;
-			break;
-		}
-	}
-	cl_lock_mutex_put(env, lock);
-}
-#endif
-
 /**
  * Check if the extent region \a descr is covered by \a child against the
  * specific \a stripe.
-- 
2.1.0
