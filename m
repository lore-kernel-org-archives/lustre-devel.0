From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:43 -0400
Subject: [lustre-devel] [PATCH 50/58] staging: lustre: lov: handle the case
	of stripe size is not power 2
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Calculate the end of current stripe correctly when the stripe size
is not power 2.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4860
Reviewed-on: http://review.whamcloud.com/9882
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_page.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
index c17026f..45b5ae9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_page.c
+++ b/drivers/staging/lustre/lustre/lov/lov_page.c
@@ -65,7 +65,9 @@ static int lov_raid0_page_is_under_lock(const struct lu_env *env,
 	pgoff_t index = *max_index;
 	unsigned int pps; /* pages per stripe */
 
-	CDEBUG(D_READA, "*max_index = %lu, nr = %d\n", index, r0->lo_nr);
+	CDEBUG(D_READA, DFID "*max_index = %lu, nr = %d\n",
+	       PFID(lu_object_fid(lov2lu(loo))), index, r0->lo_nr);
+
 	if (index == 0) /* the page is not covered by any lock */
 		return 0;
 
@@ -80,7 +82,12 @@ static int lov_raid0_page_is_under_lock(const struct lu_env *env,
 
 	/* calculate the end of current stripe */
 	pps = loo->lo_lsm->lsm_stripe_size >> PAGE_SHIFT;
-	index = ((slice->cpl_index + pps) & ~(pps - 1)) - 1;
+	index = slice->cpl_index + pps - slice->cpl_index % pps - 1;
+
+	CDEBUG(D_READA, DFID "*max_index = %lu, index = %lu, pps = %u, stripe_size = %u, stripe no = %u, page index = %lu\n",
+	       PFID(lu_object_fid(lov2lu(loo))), *max_index, index, pps,
+	       loo->lo_lsm->lsm_stripe_size, lov_page_stripe(slice->cpl_page),
+	       slice->cpl_index);
 
 	/* never exceed the end of the stripe */
 	*max_index = min_t(pgoff_t, *max_index, index);
-- 
1.7.1
