From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 5 Sep 2017 20:25:25 +0000
Subject: [lustre-devel] [PATCH] lustre: ptlrpc: kfree used instead of kvfree
Message-ID: <4F34B6C1-3A14-4F29-B241-A80F5A66E90B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Nadav Amit <namit@vmware.com>

rq_reqbuf is allocated using kvmalloc() but released in one occasion
using kfree() instead of kvfree().

The issue was found using grep based on a similar bug.

Fixes: d7e09d0397e8 ("add Lustre file system client support")
Fixes: ee0ec1946ec2 ("lustre: ptlrpc: Replace uses of OBD_{ALLOC,FREE}_LARGE")

Cc: Peng Tao <bergwolf@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: James Simmons <jsimmons@infradead.org>

Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
---
drivers/staging/lustre/lustre/ptlrpc/sec.c | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 366f2ce20f5e..2f1c9e15f47c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -847,7 +847,7 @@ void sptlrpc_request_out_callback(struct ptlrpc_request *req)
 	if (req->rq_pool || !req->rq_reqbuf)
 		return;
 
-	kfree(req->rq_reqbuf);
+	kvfree(req->rq_reqbuf);
 	req->rq_reqbuf = NULL;
 	req->rq_reqbuf_len = 0;
 }
-- 
2.11.0
