From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 17/21] staging: lustre: fid: use
 wait_event_cmd()
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341813.25814.17831255008034562097.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Rather than open-coding a wait event loop twice,
use wait_event_cmd() to wait, dropping the spinlock
over schedule().
This does require duplicating part of the wait
condition, but that is just three tests on values that
are in registers or in cache, so the cost is small
and the increased readability is large.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c |   68 +++++++----------------
 1 file changed, 20 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 6b9d024bd27b..ef9ee5426151 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -192,26 +192,6 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 	return rc;
 }
 
-static int seq_fid_alloc_prep(struct lu_client_seq *seq,
-			      wait_queue_entry_t *link)
-{
-	if (seq->lcs_update) {
-		add_wait_queue(&seq->lcs_waitq, link);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		spin_unlock(&seq->lcs_lock);
-
-		schedule();
-
-		spin_lock(&seq->lcs_lock);
-		remove_wait_queue(&seq->lcs_waitq, link);
-		set_current_state(TASK_RUNNING);
-		return -EAGAIN;
-	}
-	++seq->lcs_update;
-	spin_unlock(&seq->lcs_lock);
-	return 0;
-}
-
 static void seq_fid_alloc_fini(struct lu_client_seq *seq)
 {
 	LASSERT(seq->lcs_update == 1);
@@ -224,32 +204,34 @@ static void seq_fid_alloc_fini(struct lu_client_seq *seq)
 int seq_client_alloc_fid(const struct lu_env *env,
 			 struct lu_client_seq *seq, struct lu_fid *fid)
 {
-	wait_queue_entry_t link;
 	int rc;
 
 	LASSERT(seq);
 	LASSERT(fid);
 
-	init_waitqueue_entry(&link, current);
 	spin_lock(&seq->lcs_lock);
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_SEQ_EXHAUST))
 		seq->lcs_fid.f_oid = seq->lcs_width;
 
-	while (1) {
+	wait_event_cmd(seq->lcs_waitq,
+		       (!fid_is_zero(&seq->lcs_fid) &&
+			fid_oid(&seq->lcs_fid) < seq->lcs_width) ||
+		       !seq->lcs_update,
+		       spin_unlock(&seq->lcs_lock),
+		       spin_lock(&seq->lcs_lock));
+
+	if (!fid_is_zero(&seq->lcs_fid) &&
+	    fid_oid(&seq->lcs_fid) < seq->lcs_width) {
+		/* Just bump last allocated fid and return to caller. */
+		seq->lcs_fid.f_oid += 1;
+		rc = 0;
+	} else {
 		u64 seqnr;
 
-		if (!fid_is_zero(&seq->lcs_fid) &&
-		    fid_oid(&seq->lcs_fid) < seq->lcs_width) {
-			/* Just bump last allocated fid and return to caller. */
-			seq->lcs_fid.f_oid += 1;
-			rc = 0;
-			break;
-		}
-
-		rc = seq_fid_alloc_prep(seq, &link);
-		if (rc)
-			continue;
+		LASSERT(seq->lcs_update == 0);
+		++seq->lcs_update;
+		spin_unlock(&seq->lcs_lock);
 
 		rc = seq_client_alloc_seq(env, seq, &seqnr);
 		if (rc) {
@@ -274,7 +256,6 @@ int seq_client_alloc_fid(const struct lu_env *env,
 		rc = 1;
 
 		seq_fid_alloc_fini(seq);
-		break;
 	}
 
 	*fid = seq->lcs_fid;
@@ -292,23 +273,14 @@ EXPORT_SYMBOL(seq_client_alloc_fid);
  */
 void seq_client_flush(struct lu_client_seq *seq)
 {
-	wait_queue_entry_t link;
 
 	LASSERT(seq);
-	init_waitqueue_entry(&link, current);
 	spin_lock(&seq->lcs_lock);
 
-	while (seq->lcs_update) {
-		add_wait_queue(&seq->lcs_waitq, &link);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		spin_unlock(&seq->lcs_lock);
-
-		schedule();
-
-		spin_lock(&seq->lcs_lock);
-		remove_wait_queue(&seq->lcs_waitq, &link);
-		set_current_state(TASK_RUNNING);
-	}
+	wait_event_cmd(seq->lcs_waitq,
+		       !seq->lcs_update,
+		       spin_unlock(&seq->lcs_lock),
+		       spin_lock(&seq->lcs_lock));
 
 	fid_zero(&seq->lcs_fid);
 	/**
