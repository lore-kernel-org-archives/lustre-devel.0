From: James Simmons <jsimmons@infradead.org>
Date: Wed, 28 Oct 2015 12:54:22 -0400
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: change
	cfs_hash_lock_ops_t to struct
In-Reply-To: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
References: <1446051271-25189-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446051271-25189-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Change cfs_hash_lock_ops_t to struct cfs_hash_lock_ops.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 ++--
 drivers/staging/lustre/lustre/libcfs/hash.c        |   12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index c408145..778feb6 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -272,7 +272,7 @@ struct cfs_hash {
 	char			hs_name[0];
 };
 
-typedef struct cfs_hash_lock_ops {
+struct cfs_hash_lock_ops {
 	/** lock the hash table */
 	void    (*hs_lock)(union cfs_hash_lock *lock, int exclusive);
 	/** unlock the hash table */
@@ -281,7 +281,7 @@ typedef struct cfs_hash_lock_ops {
 	void    (*hs_bkt_lock)(union cfs_hash_lock *lock, int exclusive);
 	/** unlock the hash bucket */
 	void    (*hs_bkt_unlock)(union cfs_hash_lock *lock, int exclusive);
-} cfs_hash_lock_ops_t;
+};
 
 typedef struct cfs_hash_hlist_ops {
 	/** return hlist_head of hash-head of @bd */
diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 6f4c7d4..b78feb0 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -159,7 +159,7 @@ cfs_hash_rw_unlock(union cfs_hash_lock *lock, int exclusive)
 }
 
 /** No lock hash */
-static cfs_hash_lock_ops_t cfs_hash_nl_lops = {
+static struct cfs_hash_lock_ops cfs_hash_nl_lops = {
 	.hs_lock	= cfs_hash_nl_lock,
 	.hs_unlock      = cfs_hash_nl_unlock,
 	.hs_bkt_lock    = cfs_hash_nl_lock,
@@ -167,7 +167,7 @@ static cfs_hash_lock_ops_t cfs_hash_nl_lops = {
 };
 
 /** no bucket lock, one spinlock to protect everything */
-static cfs_hash_lock_ops_t cfs_hash_nbl_lops = {
+static struct cfs_hash_lock_ops cfs_hash_nbl_lops = {
 	.hs_lock	= cfs_hash_spin_lock,
 	.hs_unlock      = cfs_hash_spin_unlock,
 	.hs_bkt_lock    = cfs_hash_nl_lock,
@@ -175,7 +175,7 @@ static cfs_hash_lock_ops_t cfs_hash_nbl_lops = {
 };
 
 /** spin bucket lock, rehash is enabled */
-static cfs_hash_lock_ops_t cfs_hash_bkt_spin_lops = {
+static struct cfs_hash_lock_ops cfs_hash_bkt_spin_lops = {
 	.hs_lock	= cfs_hash_rw_lock,
 	.hs_unlock      = cfs_hash_rw_unlock,
 	.hs_bkt_lock    = cfs_hash_spin_lock,
@@ -183,7 +183,7 @@ static cfs_hash_lock_ops_t cfs_hash_bkt_spin_lops = {
 };
 
 /** rw bucket lock, rehash is enabled */
-static cfs_hash_lock_ops_t cfs_hash_bkt_rw_lops = {
+static struct cfs_hash_lock_ops cfs_hash_bkt_rw_lops = {
 	.hs_lock	= cfs_hash_rw_lock,
 	.hs_unlock      = cfs_hash_rw_unlock,
 	.hs_bkt_lock    = cfs_hash_rw_lock,
@@ -191,7 +191,7 @@ static cfs_hash_lock_ops_t cfs_hash_bkt_rw_lops = {
 };
 
 /** spin bucket lock, rehash is disabled */
-static cfs_hash_lock_ops_t cfs_hash_nr_bkt_spin_lops = {
+static struct cfs_hash_lock_ops cfs_hash_nr_bkt_spin_lops = {
 	.hs_lock	= cfs_hash_nl_lock,
 	.hs_unlock      = cfs_hash_nl_unlock,
 	.hs_bkt_lock    = cfs_hash_spin_lock,
@@ -199,7 +199,7 @@ static cfs_hash_lock_ops_t cfs_hash_nr_bkt_spin_lops = {
 };
 
 /** rw bucket lock, rehash is disabled */
-static cfs_hash_lock_ops_t cfs_hash_nr_bkt_rw_lops = {
+static struct cfs_hash_lock_ops cfs_hash_nr_bkt_rw_lops = {
 	.hs_lock	= cfs_hash_nl_lock,
 	.hs_unlock      = cfs_hash_nl_unlock,
 	.hs_bkt_lock    = cfs_hash_rw_lock,
-- 
1.7.1
