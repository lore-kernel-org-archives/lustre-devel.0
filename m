From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:15 -0400
Subject: [lustre-devel] [PATCH 05/30] lustre: osc: GPF while doing ELC with
 no_wait_policy
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

osc_ldlm_weigh_ast() uses osc_object from ldlm_lock
without taking a reference.

It should take a reference like osc_ldlm_glimpse_ast()/
osc_dlm_blocking_ast0() does.

Signed-off-by: Andriy Skulysh <c17819@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9171
Seagate-bug-id: MRP-4179
Reviewed-on: https://review.whamcloud.com/25700
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_lock.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index d6a275f..6059dba 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -701,7 +701,12 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 		return 1;
 
 	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT);
+	lock_res_and_lock(dlmlock);
 	obj = dlmlock->l_ast_data;
+	if (obj)
+		cl_object_get(osc2cl(obj));
+	unlock_res_and_lock(dlmlock);
+
 	if (!obj) {
 		weight = 1;
 		goto out;
@@ -725,6 +730,9 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 	weight = osc_lock_weight(env, obj, &dlmlock->l_policy_data.l_extent);
 
 out:
+	if (obj)
+		cl_object_put(env, osc2cl(obj));
+
 	cl_env_put(env, &refcheck);
 	return weight;
 }
-- 
1.8.3.1
