From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 02/12] staging: lustre: ldlm: use
 list_for_each_entry in ldlm_extent_shift_kms()
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495483.27582.774362475681930674.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Using list_for_each_entry() means we don't need 'tmp'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index fac9d19d50b6..11b11b5f3216 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -64,7 +64,6 @@
 __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 {
 	struct ldlm_resource *res = lock->l_resource;
-	struct list_head *tmp;
 	struct ldlm_lock *lck;
 	__u64 kms = 0;
 
@@ -74,8 +73,7 @@ __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 	 */
 	ldlm_set_kms_ignore(lock);
 
-	list_for_each(tmp, &res->lr_granted) {
-		lck = list_entry(tmp, struct ldlm_lock, l_res_link);
+	list_for_each_entry(lck, &res->lr_granted, l_res_link) {
 
 		if (ldlm_is_kms_ignore(lck))
 			continue;
