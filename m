From: NeilBrown <neilb@suse.com>
Date: Wed, 04 Jul 2018 14:43:50 +1000
Subject: [lustre-devel] [PATCH 06/11] lustre: mdc: change memcpy to strcpy.
In-Reply-To: <153067941050.30111.13691201276059352926.stgit@noble>
References: <153067941050.30111.13691201276059352926.stgit@noble>
Message-ID: <153067943076.30111.10766325427125150068.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We may not actually *need* to set the trailing nul here,
but space as allocate for it (req_capsule_set_size above)
so it is tidiest to just use strcpy.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 893a370dc763..bfa07d72d875 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -122,7 +122,7 @@ static int mdc_get_root(struct obd_export *exp, const char *fileset,
 	if (fileset) {
 		char *name = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
 
-		memcpy(name, fileset, strlen(fileset));
+		strcpy(name, fileset);
 	}
 	lustre_msg_add_flags(req->rq_reqmsg, LUSTRE_IMP_FULL);
 	req->rq_send_state = LUSTRE_IMP_FULL;
