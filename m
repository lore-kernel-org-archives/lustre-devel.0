From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:20 -0500
Subject: [lustre-devel] [PATCH 032/622] lustre: obdecho: use vmalloc for lnb
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

When allocating the niobuf_local, if there are a large number of
(potential) fragments this allocation can be quite large. Use
kvmalloc_array() and kvfree() to avoid allocation errors and
console noise. This was causing sanity test_180c to fail in a
VM on occasion, and could also be problem in real use.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10903
Lustre-commit: 8878bab7ae5f ("LU-10903 obdecho: use OBD_ALLOC_LARGE for lnb")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31964
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdecho/echo_client.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 3984cb4..0735a5a 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1343,7 +1343,8 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	npages = batch >> PAGE_SHIFT;
 	tot_pages = count >> PAGE_SHIFT;
 
-	lnb = kcalloc(npages, sizeof(struct niobuf_local), GFP_NOFS);
+	lnb = kvmalloc_array(npages, sizeof(struct niobuf_local),
+			     GFP_NOFS | __GFP_ZERO);
 	if (!lnb) {
 		ret = -ENOMEM;
 		goto out;
@@ -1411,7 +1412,7 @@ static int echo_client_prep_commit(const struct lu_env *env,
 	}
 
 out:
-	kfree(lnb);
+	kvfree(lnb);
 	return ret;
 }
 
-- 
1.8.3.1
