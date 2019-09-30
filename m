From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:55 -0400
Subject: [lustre-devel] [PATCH 096/151] lustre: fid: improve seq allocation
 error messages
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-97-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Emoly Liu <emoly@whamcloud.com>

When MDTs are waiting for MDT0000 to start the master sequence
server and be granted a meta sequence for the first time, in case
of "-EINPROGRESS", the limited console messages would be clearer
and better than many error messages.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10392
Lustre-commit: 6f86519b3483 ("LU-10392 fid: improve seq allocation error messages")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/30623
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Giuseppe Di Natale <dinatale2@llnl.gov>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/fid_request.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index 861ffbe..a54d1e5 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -171,8 +171,9 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 	if (lu_seq_range_is_exhausted(&seq->lcs_space)) {
 		rc = seq_client_alloc_meta(env, seq);
 		if (rc) {
-			CERROR("%s: Can't allocate new meta-sequence, rc %d\n",
-			       seq->lcs_name, rc);
+			if (rc != -EINPROGRESS)
+				CERROR("%s: Can't allocate new meta-sequence, rc = %d\n",
+				       seq->lcs_name, rc);
 			*seqnr = U64_MAX;
 			return rc;
 		}
@@ -232,8 +233,9 @@ int seq_client_alloc_fid(const struct lu_env *env,
 		wake_up(&seq->lcs_waitq);
 
 		if (rc) {
-			CERROR("%s: Can't allocate new sequence, rc %d\n",
-			       seq->lcs_name, rc);
+			if (rc != -EINPROGRESS)
+				CERROR("%s: Can't allocate new sequence, rc %d\n",
+				       seq->lcs_name, rc);
 			spin_unlock(&seq->lcs_lock);
 			return rc;
 		}
-- 
1.8.3.1
