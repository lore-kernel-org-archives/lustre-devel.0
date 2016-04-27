From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:05 -0400
Subject: [lustre-devel] [PATCH 13/15] staging: lustre: osc: Track number of
	"unstable" pages per osc
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Prakash Surya <surya1@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Prakash Surya <surya1@llnl.gov>

This change adds simple accounting hooks for "unstable" pages on a per
OSC basis. Now, in addition to the per filesystem tracking, each OSC
will maintain a running total of its unstable pages. These counters are
exported through the proc interface, and can be read using the lctl
command.

For example:

	# Read number of unstable pages contained by each OSC
	lctl get_param osc.*.unstable_stats

The motivation for this change is in anticipation of implementing a
"soft sync" functionality, urging servers to commit these unstable
pages to stable storage. The per OSC accounting allows a client to
limit the soft sync request to only the OSCs which have outstanding
unstable pages.

Signed-off-by: Prakash Surya <surya1@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2139
Reviewed-on: http://review.whamcloud.com/4374
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h   |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c |    1 +
 drivers/staging/lustre/lustre/osc/lproc_osc.c |   18 ++++++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_cache.c |    6 ++++++
 4 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 3f24a5b..d0c0c26 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -325,6 +325,7 @@ struct client_obd {
 	atomic_t		 cl_lru_in_list;
 	struct list_head	 cl_lru_list; /* lru page list */
 	spinlock_t		 cl_lru_list_lock; /* page list protector */
+	atomic_t		 cl_unstable_count;
 
 	/* number of in flight destroy rpcs is limited to max_rpcs_in_flight */
 	atomic_t	     cl_destroy_in_flight;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index bc951c0..32486b2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -334,6 +334,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	atomic_set(&cli->cl_lru_in_list, 0);
 	INIT_LIST_HEAD(&cli->cl_lru_list);
 	spin_lock_init(&cli->cl_lru_list_lock);
+	atomic_set(&cli->cl_unstable_count, 0);
 
 	init_waitqueue_head(&cli->cl_destroy_waitq);
 	atomic_set(&cli->cl_destroy_in_flight, 0);
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 6e57f53..33a1132 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -593,6 +593,23 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(max_pages_per_rpc);
 
+static ssize_t unstable_stats_show(struct kobject *kobj,
+				   struct attribute *attr,
+				   char *buf)
+{
+	struct obd_device *dev = container_of(kobj, struct obd_device,
+					      obd_kobj);
+	struct client_obd *cli = &dev->u.cli;
+	int pages, mb;
+
+	pages = atomic_read(&cli->cl_unstable_count);
+	mb = (pages * PAGE_SIZE) >> 20;
+
+	return sprintf(buf, "unstable_pages: %8d\n"
+		       "unstable_mb:    %8d\n", pages, mb);
+}
+LUSTRE_RO_ATTR(unstable_stats);
+
 LPROC_SEQ_FOPS_RO_TYPE(osc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(osc, server_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(osc, conn_uuid);
@@ -802,6 +819,7 @@ static struct attribute *osc_attrs[] = {
 	&lustre_attr_max_pages_per_rpc.attr,
 	&lustre_attr_max_rpcs_in_flight.attr,
 	&lustre_attr_resend_count.attr,
+	&lustre_attr_unstable_stats.attr,
 	NULL,
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5cd8eef..7d1c2c5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1873,6 +1873,9 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 	atomic_sub(page_count, &cli->cl_cache->ccc_unstable_nr);
 	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
 
+	atomic_sub(page_count, &cli->cl_unstable_count);
+	LASSERT(atomic_read(&cli->cl_unstable_count) >= 0);
+
 	atomic_sub(page_count, &obd_unstable_pages);
 	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
 
@@ -1904,6 +1907,9 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req)
 	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
 	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
 
+	LASSERT(atomic_read(&cli->cl_unstable_count) >= 0);
+	atomic_add(page_count, &cli->cl_unstable_count);
+
 	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
 	atomic_add(page_count, &obd_unstable_pages);
 
-- 
1.7.1
