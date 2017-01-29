From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:09 -0500
Subject: [lustre-devel] [PATCH 41/60] staging: lustre: osc: osc_match_base
	prototype differs from declaration
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Steve Guminski <stephenx.guminski@intel.com>, James Simmons <jsimmons@infradead.org>

From: Steve Guminski <stephenx.guminski@intel.com>

The patch updates the prototype in osc_internal.h to match the
enums used in the declaration.

The osc_match_base declaration in lustre/osc/osc_request.c uses
enums for stricter checking on the type and mode parameters:

int osc_match_base(struct obd_export *exp,
                   ...
-->                enum ldlm_type type,
                   union ldlm_policy_data *policy,
-->                enum ldlm_mode mode,
                   ...  int unref)

The prototype in lustre/osc/osc_internal.h instead used unsigned ints:

int osc_match_base(struct obd_export *exp,
                   ...
-->                __u32 type,
                       union ldlm_policy_data *policy,
-->                __u32 mode,
                   ...  int unref);

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8189
Reviewed-on: http://review.whamcloud.com/23167
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_internal.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 43a43e4..8abd83f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -114,9 +114,9 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		     struct ptlrpc_request_set *rqset, int async, int agl);
 
 int osc_match_base(struct obd_export *exp, struct ldlm_res_id *res_id,
-		   __u32 type, union ldlm_policy_data *policy, __u32 mode,
-		   __u64 *flags, void *data, struct lustre_handle *lockh,
-		   int unref);
+		   enum ldlm_type type, union ldlm_policy_data *policy,
+		   enum ldlm_mode mode, __u64 *flags, void *data,
+		   struct lustre_handle *lockh, int unref);
 
 int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		      obd_enqueue_update_f upcall, void *cookie,
-- 
1.8.3.1
