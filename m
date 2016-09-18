From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:16 -0400
Subject: [lustre-devel] [PATCH 017/124] staging: lustre: lov: adjust page
	bufsize after layout change
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Otherwise, the coh_page_bufsize keeps increasing when the file's
layout keeps changing in lov_init_raid0().

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5459
Reviewed-on: http://review.whamcloud.com/11394
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_object.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 2a52d0c..4f766e0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -195,6 +195,10 @@ static int lov_page_slice_fixup(struct lov_object *lov,
 	struct cl_object_header *hdr = cl_object_header(&lov->lo_cl);
 	struct cl_object *o;
 
+	if (!stripe)
+		return hdr->coh_page_bufsize - lov->lo_cl.co_slice_off -
+		       cfs_size_round(sizeof(struct lov_page));
+
 	cl_object_for_each(o, stripe)
 		o->co_slice_off += hdr->coh_page_bufsize;
 
@@ -720,6 +724,10 @@ static int lov_layout_change(const struct lu_env *unused,
 		LASSERT(atomic_read(&lov->lo_active_ios) == 0);
 
 		lov->lo_type = LLT_EMPTY;
+		/* page bufsize fixup */
+		cl_object_header(&lov->lo_cl)->coh_page_bufsize -=
+			lov_page_slice_fixup(lov, NULL);
+
 		result = new_ops->llo_init(env,
 					lu2lov_dev(lov->lo_cl.co_lu.lo_dev),
 					lov, conf, state);
-- 
1.7.1
