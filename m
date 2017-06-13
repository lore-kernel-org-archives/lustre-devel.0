From: Roman Storozhenko <romeusmeister@gmail.com>
Date: Tue, 13 Jun 2017 12:29:31 +0300
Subject: [lustre-devel] [PATCH v2] staging: lustre: fid: Fixes debug output
	style problem
Message-ID: <20170613092931.GA14635@home>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fixes a style problems. Replaces non-standard 'Lx' specifier with a
standard 'llx'.

Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 999f250..cd84b42 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -259,7 +259,7 @@ int seq_client_alloc_fid(const struct lu_env *env,
 			return rc;
 		}
 
-		CDEBUG(D_INFO, "%s: Switch to sequence [0x%16.16Lx]\n",
+		CDEBUG(D_INFO, "%s: Switch to sequence [0x%16.16llx]\n",
 		       seq->lcs_name, seqnr);
 
 		seq->lcs_fid.f_oid = LUSTRE_FID_INIT_OID;
-- 
2.7.4
