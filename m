From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: ldlm: use
 list_for_each_entry in ldlm_extent_shift_kms()
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956707.22133.18031734709320073959.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 2cc6dc2b281f..c9bf9ae40f7d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -63,7 +63,6 @@
 __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 {
 	struct ldlm_resource *res = lock->l_resource;
-	struct list_head *tmp;
 	struct ldlm_lock *lck;
 	__u64 kms = 0;
 
@@ -73,8 +72,7 @@ __u64 ldlm_extent_shift_kms(struct ldlm_lock *lock, __u64 old_kms)
 	 */
 	ldlm_set_kms_ignore(lock);
 
-	list_for_each(tmp, &res->lr_granted) {
-		lck = list_entry(tmp, struct ldlm_lock, l_res_link);
+	list_for_each_entry(lck, &res->lr_granted, l_res_link) {
 
 		if (ldlm_is_kms_ignore(lck))
 			continue;
