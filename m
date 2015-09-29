From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:03 -0400
Subject: [lustre-devel] [PATCH 20/29] staging/lustre/fid: Remove server fid
	function declarations
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-21-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Those functions are not present anywhere in the client code.

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/include/lustre_fid.h | 24 ----------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index abc9345..1b50e66 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -425,30 +425,6 @@ struct lu_server_seq {
 	struct seq_server_site  *lss_site;
 };
 
-/* Server methods */
-
-int seq_server_init(struct lu_server_seq *seq,
-		    struct dt_device *dev,
-		    const char *prefix,
-		    enum lu_mgr_type type,
-		    struct seq_server_site *ss,
-		    const struct lu_env *env);
-
-void seq_server_fini(struct lu_server_seq *seq,
-		     const struct lu_env *env);
-
-int seq_server_alloc_super(struct lu_server_seq *seq,
-			   struct lu_seq_range *out,
-			   const struct lu_env *env);
-
-int seq_server_alloc_meta(struct lu_server_seq *seq,
-			  struct lu_seq_range *out,
-			  const struct lu_env *env);
-
-int seq_server_set_cli(struct lu_server_seq *seq,
-		       struct lu_client_seq *cli,
-		       const struct lu_env *env);
-
 /* Client methods */
 int seq_client_init(struct lu_client_seq *seq,
 		    struct obd_export *exp,
-- 
2.1.0
