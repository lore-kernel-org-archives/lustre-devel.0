From: Shreeya Patel <shreeya.patel23498@gmail.com>
Date: Sat, 22 Jul 2017 22:26:41 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: Place the open brace on
	previous line.
Message-ID: <1500742601-10733-1-git-send-email-shreeya.patel23498@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Cc: Shreeya Patel <shreeya.patel23498@gmail.com>

Remove errors by placing the open braces on previous line.
This saves the vertical space of the code.

Problem found by checkpatch.

Signed-off-by: Shreeya Patel <shreeya.patel23498@gmail.com>
---
 drivers/staging/lustre/lnet/libcfs/hash.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 5c2ce2e..a255e04 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1348,8 +1348,7 @@ cfs_hash_lookup(struct cfs_hash *hs, const void *key)
 EXPORT_SYMBOL(cfs_hash_lookup);
 
 static void
-cfs_hash_for_each_enter(struct cfs_hash *hs)
-{
+cfs_hash_for_each_enter(struct cfs_hash *hs) {
 	LASSERT(!cfs_hash_is_exiting(hs));
 
 	if (!cfs_hash_with_rehash(hs))
@@ -1375,8 +1374,7 @@ cfs_hash_for_each_enter(struct cfs_hash *hs)
 }
 
 static void
-cfs_hash_for_each_exit(struct cfs_hash *hs)
-{
+cfs_hash_for_each_exit(struct cfs_hash *hs) {
 	int remained;
 	int bits;
 
@@ -1407,8 +1405,7 @@ cfs_hash_for_each_exit(struct cfs_hash *hs)
  */
 static u64
 cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data, int remove_safe)
-{
+			void *data, int remove_safe) {
 	struct hlist_node *hnode;
 	struct hlist_node *pos;
 	struct cfs_hash_bd bd;
@@ -1501,8 +1498,7 @@ EXPORT_SYMBOL(cfs_hash_for_each);
 
 void
 cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-		       void *data)
-{
+		       void *data) {
 	cfs_hash_for_each_tight(hs, func, data, 1);
 }
 EXPORT_SYMBOL(cfs_hash_for_each_safe);
@@ -1551,8 +1547,7 @@ EXPORT_SYMBOL(cfs_hash_size_get);
  */
 static int
 cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data, int start)
-{
+			void *data, int start) {
 	struct hlist_node *hnode;
 	struct hlist_node *tmp;
 	struct cfs_hash_bd bd;
@@ -1629,8 +1624,7 @@ cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 
 int
 cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			 void *data, int start)
-{
+			 void *data, int start) {
 	if (cfs_hash_with_no_lock(hs) ||
 	    cfs_hash_with_rehash_key(hs) ||
 	    !cfs_hash_with_no_itemref(hs))
@@ -1661,8 +1655,7 @@ EXPORT_SYMBOL(cfs_hash_for_each_nolock);
  */
 int
 cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
-			void *data)
-{
+			void *data) {
 	unsigned int i = 0;
 
 	if (cfs_hash_with_no_lock(hs))
@@ -1718,8 +1711,7 @@ EXPORT_SYMBOL(cfs_hash_hlist_for_each);
  */
 void
 cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
-		      cfs_hash_for_each_cb_t func, void *data)
-{
+		      cfs_hash_for_each_cb_t func, void *data) {
 	struct hlist_node *hnode;
 	struct cfs_hash_bd bds[2];
 	unsigned int i;
-- 
2.7.4
