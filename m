From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:32 -0400
Subject: [lustre-devel] [PATCH 073/151] lustre: mdc: don't assert on name
 pack
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-74-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

For old version of MDTs which don't support ATTRFID, open will pack
dentry name in the request, but this name may change if there is
concurrent rename, as a result an assertion will be triggerred.

It's inconvenient to copy name in advance or take dentry lock in the
call chain, so It's better to remove this assert, which is safe.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5024
Lustre-commit: dd9d7cc845df ("LU-5024 mdc: don't assert on name pack")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29161
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_lib.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 3601e17..d0ae6f2 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -107,7 +107,11 @@ static void mdc_pack_name(struct ptlrpc_request *req,
 
 	cpy_len = strlcpy(buf, name, buf_size);
 
-	LASSERT(cpy_len == name_len && lu_name_is_valid_2(buf, cpy_len));
+	LASSERT(lu_name_is_valid_2(buf, cpy_len));
+	if (cpy_len != name_len)
+		CDEBUG(D_DENTRY, "%s: %s len %zd != %zd, concurrent rename?\n",
+		       req->rq_export->exp_obd->obd_name, buf, name_len,
+		       cpy_len);
 }
 
 void mdc_file_secctx_pack(struct ptlrpc_request *req, const char *secctx_name,
-- 
1.8.3.1
