From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 18/21] staging: lustre: fid: remove
 seq_fid_alloc_fini() and simplify
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341816.25814.6263195320580542505.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

seq_fid_alloc_fini() is tiny and only called
from two places in the one function.  We can move
both those calls earlier and merge them so only
one call is needed.  At that point, there is no
value added by having a separate function.

Also instead of using ++ and -- on ->lcs_update to
toggle between 0 and 1, explicitly set to 0 or 1
as appropriate.

Moving the locking earlier means that the code which updates
seq->lcs_fid is now protected, so
ldebugfs_fid_fid_seq_show() now cannot see a torn value.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index ef9ee5426151..6e0dfe18ef5f 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -192,14 +192,6 @@ static int seq_client_alloc_seq(const struct lu_env *env,
 	return rc;
 }
 
-static void seq_fid_alloc_fini(struct lu_client_seq *seq)
-{
-	LASSERT(seq->lcs_update == 1);
-	spin_lock(&seq->lcs_lock);
-	--seq->lcs_update;
-	wake_up(&seq->lcs_waitq);
-}
-
 /* Allocate new fid on passed client @seq and save it to @fid. */
 int seq_client_alloc_fid(const struct lu_env *env,
 			 struct lu_client_seq *seq, struct lu_fid *fid)
@@ -230,14 +222,18 @@ int seq_client_alloc_fid(const struct lu_env *env,
 		u64 seqnr;
 
 		LASSERT(seq->lcs_update == 0);
-		++seq->lcs_update;
+		seq->lcs_update = 1;
 		spin_unlock(&seq->lcs_lock);
 
 		rc = seq_client_alloc_seq(env, seq, &seqnr);
+
+		spin_lock(&seq->lcs_lock);
+		seq->lcs_update = 0;
+		wake_up(&seq->lcs_waitq);
+
 		if (rc) {
 			CERROR("%s: Can't allocate new sequence, rc %d\n",
 			       seq->lcs_name, rc);
-			seq_fid_alloc_fini(seq);
 			spin_unlock(&seq->lcs_lock);
 			return rc;
 		}
@@ -254,8 +250,6 @@ int seq_client_alloc_fid(const struct lu_env *env,
 		 * to setup FLD for it.
 		 */
 		rc = 1;
-
-		seq_fid_alloc_fini(seq);
 	}
 
 	*fid = seq->lcs_fid;
