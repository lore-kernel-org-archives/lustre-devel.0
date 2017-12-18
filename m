From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:41:42 +1100
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: replace cfs_srand()
 calls with add_device_randomness().
In-Reply-To: <151356119565.24290.5570928075046338898.stgit@noble>
References: <151356119565.24290.5570928075046338898.stgit@noble>
Message-ID: <151356130240.24290.14619191557989403391.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The only places that cfs_srand is called, the random bits are
mixed with bits from get_random_bytes().  So it is equally effective
to add entropy to either pool.
So we can replace calls to cfs_srand() with calls that add the
entropy with add_device_randomness().  That function adds time-based
entropy, so we can discard the ktime_get_ts64 calls.

One location in lustre_handles.c only adds timebased
entropy.  This cannot improve the entropy provided by get_random_bytes(),
so just discard that call.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/router.c          |   15 ++++++---------
 drivers/staging/lustre/lustre/llite/super25.c      |   17 +++++++----------
 .../lustre/lustre/obdclass/lustre_handles.c        |    7 -------
 3 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index e5c9b29e199f..80a7e8a88acb 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -238,28 +238,25 @@ lnet_find_net_locked(__u32 net)
 static void lnet_shuffle_seed(void)
 {
 	static int seeded;
-	__u32 lnd_type, seed[2];
-	struct timespec64 ts;
 	struct lnet_ni *ni;
 
 	if (seeded)
 		return;
 
-	cfs_get_random_bytes(seed, sizeof(seed));
-
 	/*
 	 * Nodes with small feet have little entropy
 	 * the NID for this node gives the most entropy in the low bits
 	 */
 	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
-		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
+		__u32 lnd_type, seed;
 
-		if (lnd_type != LOLND)
-			seed[0] ^= (LNET_NIDADDR(ni->ni_nid) | lnd_type);
+		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
+		if (lnd_type != LOLND) {
+			seed = (LNET_NIDADDR(ni->ni_nid) | lnd_type);
+			add_device_randomness(&seed, sizeof(seed));
+		}
 	}
 
-	ktime_get_ts64(&ts);
-	cfs_srand(ts.tv_sec ^ seed[0], ts.tv_nsec ^ seed[1]);
 	seeded = 1;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 10105339790e..9b0bb3541a84 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -86,8 +86,7 @@ MODULE_ALIAS_FS("lustre");
 static int __init lustre_init(void)
 {
 	struct lnet_process_id lnet_id;
-	struct timespec64 ts;
-	int i, rc, seed[2];
+	int i, rc;
 
 	BUILD_BUG_ON(sizeof(LUSTRE_VOLATILE_HDR) !=
 		     LUSTRE_VOLATILE_HDR_LEN + 1);
@@ -126,22 +125,20 @@ static int __init lustre_init(void)
 		goto out_debugfs;
 	}
 
-	cfs_get_random_bytes(seed, sizeof(seed));
-
 	/* Nodes with small feet have little entropy. The NID for this
 	 * node gives the most entropy in the low bits
 	 */
 	for (i = 0;; i++) {
+		u32 seed;
+
 		if (LNetGetId(i, &lnet_id) == -ENOENT)
 			break;
-
-		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND)
-			seed[0] ^= LNET_NIDADDR(lnet_id.nid);
+		if (LNET_NETTYP(LNET_NIDNET(lnet_id.nid)) != LOLND) {
+			 seed = LNET_NIDADDR(lnet_id.nid);
+			 add_device_randomness(&seed, sizeof(seed));
+		}
 	}
 
-	ktime_get_ts64(&ts);
-	cfs_srand(ts.tv_sec ^ seed[0], ts.tv_nsec ^ seed[1]);
-
 	rc = vvp_global_init();
 	if (rc != 0)
 		goto out_sysfs;
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 71329adc0318..d1b6c2f134d7 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -181,8 +181,6 @@ EXPORT_SYMBOL(class_handle_free_cb);
 int class_handle_init(void)
 {
 	struct handle_bucket *bucket;
-	struct timespec64 ts;
-	int seed[2];
 
 	LASSERT(!handle_hash);
 
@@ -198,11 +196,6 @@ int class_handle_init(void)
 		spin_lock_init(&bucket->lock);
 	}
 
-	/** bug 21430: add randomness to the initial base */
-	cfs_get_random_bytes(seed, sizeof(seed));
-	ktime_get_ts64(&ts);
-	cfs_srand(ts.tv_sec ^ seed[0], ts.tv_nsec ^ seed[1]);
-
 	cfs_get_random_bytes(&handle_base, sizeof(handle_base));
 	LASSERT(handle_base != 0ULL);
 
