From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:38 +1100
Subject: [lustre-devel] [PATCH 20/21] staging: lustre: fid: perform sanity
 checks before commiting
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341823.25814.12569503440862267846.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

When fid fetches a new range from the server, it commits
to it (*output = *out) *before* performing sanity checks.
This looks backwards.
Don't commit to a value until it has been found to be sane.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 6e0dfe18ef5f..fa23423eb8b3 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -118,22 +118,22 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 		goto out_req;
 
 	out = req_capsule_server_get(&req->rq_pill, &RMF_SEQ_RANGE);
-	*output = *out;
 
-	if (!lu_seq_range_is_sane(output)) {
+	if (!lu_seq_range_is_sane(out)) {
 		CERROR("%s: Invalid range received from server: "
-		       DRANGE "\n", seq->lcs_name, PRANGE(output));
+		       DRANGE "\n", seq->lcs_name, PRANGE(out));
 		rc = -EINVAL;
 		goto out_req;
 	}
 
-	if (lu_seq_range_is_exhausted(output)) {
+	if (lu_seq_range_is_exhausted(out)) {
 		CERROR("%s: Range received from server is exhausted: "
-		       DRANGE "]\n", seq->lcs_name, PRANGE(output));
+		       DRANGE "]\n", seq->lcs_name, PRANGE(out));
 		rc = -EINVAL;
 		goto out_req;
 	}
 
+	*output = *out;
 	CDEBUG_LIMIT(debug_mask, "%s: Allocated %s-sequence " DRANGE "]\n",
 		     seq->lcs_name, opcname, PRANGE(output));
 
