From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 12/15] staging: lustre: use kmalloc for
 allocating ksock_tx
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799064.6200.14626350790590057942.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The size of the data structure is primarily controlled
by the iovec size, which is limited to 256.
Entries in this vector are 12 bytes, so the whole
will always fit in a page.
So it is safe to use kmalloc (kvmalloc not needed).
So replace LIBCFS_ALLOC with kmalloc.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index dc63ed2ceb97..7dba949a95a7 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2282,7 +2282,7 @@ ksocknal_free_buffers(void)
 
 		list_for_each_entry_safe(tx, temp, &zlist, tx_list) {
 			list_del(&tx->tx_list);
-			LIBCFS_FREE(tx, tx->tx_desc_size);
+			kfree(tx);
 		}
 	} else {
 		spin_unlock(&ksocknal_data.ksnd_tx_lock);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 994b6693c6b7..11fd3a36424f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -46,7 +46,7 @@ ksocknal_alloc_tx(int type, int size)
 	}
 
 	if (!tx)
-		LIBCFS_ALLOC(tx, size);
+		tx = kzalloc(size, GFP_NOFS);
 
 	if (!tx)
 		return NULL;
@@ -102,7 +102,7 @@ ksocknal_free_tx(struct ksock_tx *tx)
 
 		spin_unlock(&ksocknal_data.ksnd_tx_lock);
 	} else {
-		LIBCFS_FREE(tx, tx->tx_desc_size);
+		kfree(tx);
 	}
 }
 
