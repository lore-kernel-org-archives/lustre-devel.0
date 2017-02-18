From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Feb 2017 16:47:05 -0500
Subject: [lustre-devel] [PATCH 04/14] staging: lustre: lov: cleanup when
	cl_io_iter_init() fails
In-Reply-To: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1487454435-4895-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In lov_io_iter_init(), if cl_io_iter_init() against sub io fails,
it should call cl_io_iter_fini() to cleanup leftover information;

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6271
Reviewed-on: http://review.whamcloud.com/16456
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_io.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index e0f0756..df77b25 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -424,21 +424,23 @@ static int lov_io_iter_init(const struct lu_env *env,
 
 		end = lov_offset_mod(end, 1);
 		sub = lov_sub_get(env, lio, stripe);
-		if (!IS_ERR(sub)) {
-			lov_io_sub_inherit(sub->sub_io, lio, stripe,
-					   start, end);
-			rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
-			lov_sub_put(sub);
-			CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
-			       stripe, start, end);
-		} else {
+		if (IS_ERR(sub)) {
 			rc = PTR_ERR(sub);
+			break;
 		}
 
-		if (!rc)
-			list_add_tail(&sub->sub_linkage, &lio->lis_active);
-		else
+		lov_io_sub_inherit(sub->sub_io, lio, stripe, start, end);
+		rc = cl_io_iter_init(sub->sub_env, sub->sub_io);
+		if (rc)
+			cl_io_iter_fini(sub->sub_env, sub->sub_io);
+		lov_sub_put(sub);
+		if (rc)
 			break;
+
+		CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
+		       stripe, start, end);
+
+		list_add_tail(&sub->sub_linkage, &lio->lis_active);
 	}
 	return rc;
 }
-- 
1.8.3.1
