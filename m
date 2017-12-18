From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 06/15] staging: lustre: lnet: use
 kmalloc/kvmalloc in router_proc
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799042.6200.15576640392787632589.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The buffers allocated in router_proc are to temporarily
hold strings created for procfs files.
So they do not need to be zeroed and are safe to use
GFP_KERNEL.
So use kmalloc() directly except in two cases where it
isn't trivial to confirm that the size is always small.
In those cases, use kvmalloc().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/router_proc.c |   34 ++++++++++++------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 06e20b314520..8d6d6b4d6619 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -95,7 +95,7 @@ static int __proc_lnet_stats(void *data, int write,
 	if (!ctrs)
 		return -ENOMEM;
 
-	LIBCFS_ALLOC(tmpstr, tmpsiz);
+	tmpstr = kmalloc(tmpsiz, GFP_KERNEL);
 	if (!tmpstr) {
 		kfree(ctrs);
 		return -ENOMEM;
@@ -118,7 +118,7 @@ static int __proc_lnet_stats(void *data, int write,
 		rc = cfs_trace_copyout_string(buffer, nob,
 					      tmpstr + pos, "\n");
 
-	LIBCFS_FREE(tmpstr, tmpsiz);
+	kfree(tmpstr);
 	kfree(ctrs);
 	return rc;
 }
@@ -151,7 +151,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 	if (!*lenp)
 		return 0;
 
-	LIBCFS_ALLOC(tmpstr, tmpsiz);
+	tmpstr = kmalloc(tmpsiz, GFP_KERNEL);
 	if (!tmpstr)
 		return -ENOMEM;
 
@@ -183,7 +183,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 
 		if (ver != LNET_PROC_VERSION(the_lnet.ln_remote_nets_version)) {
 			lnet_net_unlock(0);
-			LIBCFS_FREE(tmpstr, tmpsiz);
+			kfree(tmpstr);
 			return -ESTALE;
 		}
 
@@ -248,7 +248,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 		}
 	}
 
-	LIBCFS_FREE(tmpstr, tmpsiz);
+	kfree(tmpstr);
 
 	if (!rc)
 		*lenp = len;
@@ -275,7 +275,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 	if (!*lenp)
 		return 0;
 
-	LIBCFS_ALLOC(tmpstr, tmpsiz);
+	tmpstr = kmalloc(tmpsiz, GFP_KERNEL);
 	if (!tmpstr)
 		return -ENOMEM;
 
@@ -303,7 +303,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		if (ver != LNET_PROC_VERSION(the_lnet.ln_routers_version)) {
 			lnet_net_unlock(0);
 
-			LIBCFS_FREE(tmpstr, tmpsiz);
+			kfree(tmpstr);
 			return -ESTALE;
 		}
 
@@ -385,7 +385,7 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 		}
 	}
 
-	LIBCFS_FREE(tmpstr, tmpsiz);
+	kfree(tmpstr);
 
 	if (!rc)
 		*lenp = len;
@@ -418,7 +418,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 		return 0;
 	}
 
-	LIBCFS_ALLOC(tmpstr, tmpsiz);
+	tmpstr = kmalloc(tmpsiz, GFP_KERNEL);
 	if (!tmpstr)
 		return -ENOMEM;
 
@@ -448,7 +448,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 		if (ver != LNET_PROC_VERSION(ptable->pt_version)) {
 			lnet_net_unlock(cpt);
-			LIBCFS_FREE(tmpstr, tmpsiz);
+			kfree(tmpstr);
 			return -ESTALE;
 		}
 
@@ -556,7 +556,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 			*ppos = LNET_PROC_POS_MAKE(cpt, ver, hash, hoff);
 	}
 
-	LIBCFS_FREE(tmpstr, tmpsiz);
+	kfree(tmpstr);
 
 	if (!rc)
 		*lenp = len;
@@ -579,7 +579,7 @@ static int __proc_lnet_buffers(void *data, int write,
 
 	/* (4 %d) * 4 * LNET_CPT_NUMBER */
 	tmpsiz = 64 * (LNET_NRBPOOLS + 1) * LNET_CPT_NUMBER;
-	LIBCFS_ALLOC(tmpstr, tmpsiz);
+	tmpstr = kvmalloc(tmpsiz, GFP_KERNEL);
 	if (!tmpstr)
 		return -ENOMEM;
 
@@ -618,7 +618,7 @@ static int __proc_lnet_buffers(void *data, int write,
 		rc = cfs_trace_copyout_string(buffer, nob,
 					      tmpstr + pos, NULL);
 
-	LIBCFS_FREE(tmpstr, tmpsiz);
+	kvfree(tmpstr);
 	return rc;
 }
 
@@ -643,7 +643,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 	if (!*lenp)
 		return 0;
 
-	LIBCFS_ALLOC(tmpstr, tmpsiz);
+	tmpstr = kvmalloc(tmpsiz, GFP_KERNEL);
 	if (!tmpstr)
 		return -ENOMEM;
 
@@ -744,7 +744,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 			*ppos += 1;
 	}
 
-	LIBCFS_FREE(tmpstr, tmpsiz);
+	kvfree(tmpstr);
 
 	if (!rc)
 		*lenp = len;
@@ -795,7 +795,7 @@ static int __proc_lnet_portal_rotor(void *data, int write,
 	int rc;
 	int i;
 
-	LIBCFS_ALLOC(buf, buf_len);
+	buf = kmalloc(buf_len, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -843,7 +843,7 @@ static int __proc_lnet_portal_rotor(void *data, int write,
 	}
 	lnet_res_unlock(0);
 out:
-	LIBCFS_FREE(buf, buf_len);
+	kfree(buf);
 	return rc;
 }
 
