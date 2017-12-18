From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 13/15] staging: lustre: cfs_percpt_alloc: use
 kvmalloc(GFP_KERNEL)
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799068.6200.10665584403840611965.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

this allocation is called from several places, but all are
during initialization, so GFP_NOFS is not needed.
So use kvmalloc and GFP_KERNEL.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
index 23734cfb5d44..8e2b4f1db0a1 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
@@ -54,8 +54,7 @@ cfs_percpt_free(void *vars)
 			LIBCFS_FREE(arr->va_ptrs[i], arr->va_size);
 	}
 
-	LIBCFS_FREE(arr, offsetof(struct cfs_var_array,
-				  va_ptrs[arr->va_count]));
+	kvfree(arr);
 }
 EXPORT_SYMBOL(cfs_percpt_free);
 
@@ -79,7 +78,8 @@ cfs_percpt_alloc(struct cfs_cpt_table *cptab, unsigned int size)
 
 	count = cfs_cpt_number(cptab);
 
-	LIBCFS_ALLOC(arr, offsetof(struct cfs_var_array, va_ptrs[count]));
+	arr = kvzalloc(offsetof(struct cfs_var_array, va_ptrs[count]),
+		       GFP_KERNEL);
 	if (!arr)
 		return NULL;
 
