From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 07/14] staging: lustre: more LIBCFS_ALLOC
 conversions to GFP_KERNEL allocations.
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077841.9776.3578098217779896126.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

None of these need GFP_NOFS so allocate directly.
Change matching LIBCFS_FREE() to kfree() or kvfree().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   19 +++++++------------
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    9 ++++-----
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   14 +++++++-------
 drivers/staging/lustre/lnet/selftest/conctl.c      |   11 +++++------
 4 files changed, 23 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 51196fda2a32..c07165e0ad95 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -93,11 +93,7 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
 	int i;
 
-	if (cptab->ctb_cpu2cpt) {
-		LIBCFS_FREE(cptab->ctb_cpu2cpt,
-			    num_possible_cpus() *
-			    sizeof(cptab->ctb_cpu2cpt[0]));
-	}
+	kvfree(cptab->ctb_cpu2cpt);
 
 	for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
@@ -106,10 +102,7 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 		free_cpumask_var(part->cpt_cpumask);
 	}
 
-	if (cptab->ctb_parts) {
-		LIBCFS_FREE(cptab->ctb_parts,
-			    cptab->ctb_nparts * sizeof(cptab->ctb_parts[0]));
-	}
+	kvfree(cptab->ctb_parts);
 
 	kfree(cptab->ctb_nodemask);
 	free_cpumask_var(cptab->ctb_cpumask);
@@ -136,15 +129,17 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	    !cptab->ctb_nodemask)
 		goto failed;
 
-	LIBCFS_ALLOC(cptab->ctb_cpu2cpt,
-		     num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
+	cptab->ctb_cpu2cpt = kvmalloc_array(num_possible_cpus(),
+					    sizeof(cptab->ctb_cpu2cpt[0]),
+					    GFP_KERNEL);
 	if (!cptab->ctb_cpu2cpt)
 		goto failed;
 
 	memset(cptab->ctb_cpu2cpt, -1,
 	       num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
 
-	LIBCFS_ALLOC(cptab->ctb_parts, ncpt * sizeof(cptab->ctb_parts[0]));
+	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
+					  GFP_KERNEL);
 	if (!cptab->ctb_parts)
 		goto failed;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 7a4d1f7a693e..a173b69e2f92 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -95,7 +95,8 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 		return -ENOMEM;
 
 	if (count) {
-		LIBCFS_ALLOC(eq->eq_events, count * sizeof(struct lnet_event));
+		eq->eq_events = kvmalloc_array(count, sizeof(struct lnet_event),
+					       GFP_KERNEL | __GFP_ZERO);
 		if (!eq->eq_events)
 			goto failed;
 		/*
@@ -132,8 +133,7 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	return 0;
 
 failed:
-	if (eq->eq_events)
-		LIBCFS_FREE(eq->eq_events, count * sizeof(struct lnet_event));
+	kvfree(eq->eq_events);
 
 	if (eq->eq_refs)
 		cfs_percpt_free(eq->eq_refs);
@@ -202,8 +202,7 @@ LNetEQFree(struct lnet_handle_eq eqh)
 	lnet_eq_wait_unlock();
 	lnet_res_unlock(LNET_LOCK_EX);
 
-	if (events)
-		LIBCFS_FREE(events, size * sizeof(struct lnet_event));
+	kvfree(events);
 	if (refs)
 		cfs_percpt_free(refs);
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 7d49d4865298..fcd9d1b7c619 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -170,7 +170,7 @@ lnet_ipif_enumerate(char ***namesp)
 			      nalloc);
 		}
 
-		LIBCFS_ALLOC(ifr, nalloc * sizeof(*ifr));
+		ifr = kzalloc(nalloc * sizeof(*ifr), GFP_KERNEL);
 		if (!ifr) {
 			CERROR("ENOMEM enumerating up to %d interfaces\n",
 			       nalloc);
@@ -195,14 +195,14 @@ lnet_ipif_enumerate(char ***namesp)
 		if (nfound < nalloc || toobig)
 			break;
 
-		LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
+		kfree(ifr);
 		nalloc *= 2;
 	}
 
 	if (!nfound)
 		goto out1;
 
-	LIBCFS_ALLOC(names, nfound * sizeof(*names));
+	names = kzalloc(nfound * sizeof(*names), GFP_KERNEL);
 	if (!names) {
 		rc = -ENOMEM;
 		goto out1;
@@ -218,7 +218,7 @@ lnet_ipif_enumerate(char ***namesp)
 			goto out2;
 		}
 
-		LIBCFS_ALLOC(names[i], IFNAMSIZ);
+		names[i] = kmalloc(IFNAMSIZ, GFP_KERNEL);
 		if (!names[i]) {
 			rc = -ENOMEM;
 			goto out2;
@@ -235,7 +235,7 @@ lnet_ipif_enumerate(char ***namesp)
 	if (rc < 0)
 		lnet_ipif_free_enumeration(names, nfound);
 out1:
-	LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
+	kfree(ifr);
 out0:
 	return rc;
 }
@@ -249,9 +249,9 @@ lnet_ipif_free_enumeration(char **names, int n)
 	LASSERT(n > 0);
 
 	for (i = 0; i < n && names[i]; i++)
-		LIBCFS_FREE(names[i], IFNAMSIZ);
+		kfree(names[i]);
 
-	LIBCFS_FREE(names, n * sizeof(*names));
+	kfree(names);
 }
 EXPORT_SYMBOL(lnet_ipif_free_enumeration);
 
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 442a18ddd41f..34ba440b3c02 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -648,7 +648,7 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 		return -EINVAL;
 
 	if (args->lstio_tes_param) {
-		LIBCFS_ALLOC(param, args->lstio_tes_param_len);
+		param = kmalloc(args->lstio_tes_param_len, GFP_KERNEL);
 		if (!param)
 			goto out;
 		if (copy_from_user(param, args->lstio_tes_param,
@@ -678,8 +678,7 @@ static int lst_test_add_ioctl(struct lstio_test_args *args)
 		rc = (copy_to_user(args->lstio_tes_retp, &ret,
 				   sizeof(ret))) ? -EFAULT : 0;
 out:
-	if (param)
-		LIBCFS_FREE(param, args->lstio_tes_param_len);
+	kfree(param);
 
 	return rc;
 }
@@ -702,13 +701,13 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 	if (data->ioc_plen1 > PAGE_SIZE)
 		return -EINVAL;
 
-	LIBCFS_ALLOC(buf, data->ioc_plen1);
+	buf = kmalloc(data->ioc_plen1, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
 	/* copy in parameter */
 	if (copy_from_user(buf, data->ioc_pbuf1, data->ioc_plen1)) {
-		LIBCFS_FREE(buf, data->ioc_plen1);
+		kfree(buf);
 		return -EFAULT;
 	}
 
@@ -798,7 +797,7 @@ lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr)
 out:
 	mutex_unlock(&console_session.ses_mutex);
 
-	LIBCFS_FREE(buf, data->ioc_plen1);
+	kfree(buf);
 
 	return rc;
 }
