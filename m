From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 12:41:42 +1100
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: replace
 cfs_get_random_bytes calls with get_random_byte()
In-Reply-To: <151356119565.24290.5570928075046338898.stgit@noble>
References: <151356119565.24290.5570928075046338898.stgit@noble>
Message-ID: <151356130244.24290.391082297032618393.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The cfs_get_random_bytes() interface adds nothing of value
to get_random_byte() (which it uses internally).  So just use the
standard interface.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd_class.h  |    2 +-
 .../lustre/lustre/obdclass/lustre_handles.c        |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 67c535c5aa98..25db7ec6ecd0 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1562,7 +1562,7 @@ int class_procfs_init(void);
 int class_procfs_clean(void);
 
 /* prng.c */
-#define ll_generate_random_uuid(uuid_out) cfs_get_random_bytes(uuid_out, sizeof(class_uuid_t))
+#define ll_generate_random_uuid(uuid_out) get_random_bytes(uuid_out, sizeof(class_uuid_t))
 
 /* statfs_pack.c */
 struct kstatfs;
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index d1b6c2f134d7..2d6da2431a09 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -196,7 +196,7 @@ int class_handle_init(void)
 		spin_lock_init(&bucket->lock);
 	}
 
-	cfs_get_random_bytes(&handle_base, sizeof(handle_base));
+	get_random_bytes(&handle_base, sizeof(handle_base));
 	LASSERT(handle_base != 0ULL);
 
 	return 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 2a9f2f2ebaa8..bac4b2304bad 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3067,7 +3067,7 @@ void ptlrpc_init_xid(void)
 
 	spin_lock_init(&ptlrpc_last_xid_lock);
 	if (now < YEAR_2004) {
-		cfs_get_random_bytes(&ptlrpc_last_xid, sizeof(ptlrpc_last_xid));
+		get_random_bytes(&ptlrpc_last_xid, sizeof(ptlrpc_last_xid));
 		ptlrpc_last_xid >>= 2;
 		ptlrpc_last_xid |= (1ULL << 61);
 	} else {
