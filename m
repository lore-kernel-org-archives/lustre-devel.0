From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:14 -0400
Subject: [lustre-devel] [PATCH 015/124] staging: lustre: clio: lu_ref_del()
	mismatch ref add scope
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

'commit 77605e41a26f ("staging/lustre/clio: add pages into writeback cache
in batches")' adds a page to a list aggregate issuing them to writeback
cache; A page add is referenced in llite/vvp io scope, while writeback
cache commit de-refers it under osc sub io scope, and enabling -lu_ref
will detect this scope mismatch.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4503
Reviewed-on: http://review.whamcloud.com/8970
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/vvp_io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 94916dc..09ccd1f 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -821,7 +821,7 @@ static void write_commit_callback(const struct lu_env *env, struct cl_io *io,
 	cl_page_disown(env, io, page);
 
 	/* held in ll_cl_init() */
-	lu_ref_del(&page->cp_reference, "cl_io", io);
+	lu_ref_del(&page->cp_reference, "cl_io", cl_io_top(io));
 	cl_page_put(env, page);
 }
 
-- 
1.7.1
