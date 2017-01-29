From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:36 -0500
Subject: [lustre-devel] [PATCH 08/60] staging: lustre: ldlm: Restore connect
	flags on failure
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jeremy Filizetti <jeremy.filizetti@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Jeremy Filizetti <jeremy.filizetti@gmail.com>

Restore connect flags on failure of ptlrpc_connect_import()
to prevent an LBUG due to flags mismatch.

Signed-off-by: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7185
Reviewed-on: http://review.whamcloud.com/16950
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Sebastien Buisson <sebastien.buisson@bull.net>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 95b8c76..3663c5c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -523,6 +523,8 @@ int client_connect_import(const struct lu_env *env,
 
 	rc = ptlrpc_connect_import(imp);
 	if (rc != 0) {
+		if (data && is_mdc)
+			data->ocd_connect_flags &= ~OBD_CONNECT_MULTIMODRPCS;
 		LASSERT(imp->imp_state == LUSTRE_IMP_DISCON);
 		goto out_ldlm;
 	}
-- 
1.8.3.1
