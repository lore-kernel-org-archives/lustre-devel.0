From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:14 -0400
Subject: [lustre-devel] [PATCH 42/43] staging/lustre/ldlm: revert changes to
	ldlm_cancel_aged_policy()
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-43-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Niu Yawei <yawei.niu@intel.com>

The changes to ldlm_cancel_aged_policy() introduced from LU-4300
was incorrect. This patch revert this part of changes.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-on: http://review.whamcloud.com/12448
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5727
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 2f12194..48e9828 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1240,10 +1240,8 @@ static ldlm_policy_res_t ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
 						 int unused, int added,
 						 int count)
 {
-	if (added >= count)
-		return LDLM_POLICY_KEEP_LOCK;
-
-	if (time_before(cfs_time_current(),
+	if ((added >= count) &&
+	    time_before(cfs_time_current(),
 			cfs_time_add(lock->l_last_used, ns->ns_max_age)))
 		return LDLM_POLICY_KEEP_LOCK;
 
-- 
2.1.0
