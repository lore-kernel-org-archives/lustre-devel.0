From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:52 -0400
Subject: [lustre-devel] [PATCH 15/45] lustre: mgc: protect from NULL exp in
 mgc_enqueue()
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Return an error in mgc_enqueue() is exp parameter is NULL.
Otherwise, it might crash in class_exp2cliimp().

WC-bug-id: https://jira.whamcloud.com/browse/LU-13466
Lustre-commit: 83906f97c1d3b ("LU-13466 mgc: protect from NULL exp in mgc_enqueue()")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38280
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mgc/mgc_request.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 81f3873..cc3c82e 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -875,6 +875,9 @@ static int mgc_enqueue(struct obd_export *exp, u32 type,
 	int short_limit = cld_is_sptlrpc(cld);
 	int rc;
 
+	if (!exp)
+		return -EBADR;
+
 	CDEBUG(D_MGC, "Enqueue for %s (res %#llx)\n", cld->cld_logname,
 	       cld->cld_resid.name[0]);
 
-- 
1.8.3.1
