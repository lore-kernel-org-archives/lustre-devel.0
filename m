From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:32 +1000
Subject: [lustre-devel] [PATCH 31/34] lnet: lnet_dyn_add_ni: fix ping_info
 count
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137248.8267.6726065772840936203.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Use the correct count of interfaces when calling
   lnet_ping_info_setup()
in lnet_dyn_add_ni()

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index cf0ffb8ac84b..2ce0a7212dc2 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -871,6 +871,18 @@ lnet_ping_info_create(int num_ni)
 	return ping_info;
 }
 
+static inline int
+lnet_get_net_ni_count_locked(struct lnet_net *net)
+{
+	struct lnet_ni	*ni;
+	int		count = 0;
+
+	list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
+		count++;
+
+	return count;
+}
+
 static inline int
 lnet_get_ni_count(void)
 {
@@ -1977,6 +1989,7 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 	struct list_head net_head;
 	struct lnet_remotenet *rnet;
 	int rc;
+	int			net_ni_count;
 	int			num_acceptor_nets;
 	__u32			net_type;
 	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
@@ -2014,7 +2027,19 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, struct lnet_ioctl_config_data *conf)
 		goto failed0;
 	}
 
-	rc = lnet_ping_info_setup(&pinfo, &md_handle, 1 + lnet_get_ni_count(),
+	/*
+	 * make sure you calculate the correct number of slots in the ping
+	 * info. Since the ping info is a flattened list of all the NIs,
+	 * we should allocate enough slots to accomodate the number of NIs
+	 * which will be added.
+	 *
+	 * We can use lnet_get_net_ni_count_locked() since the net is not
+	 * on a public list yet, so locking is not a problem
+	 */
+	net_ni_count = lnet_get_net_ni_count_locked(net);
+
+	rc = lnet_ping_info_setup(&pinfo, &md_handle,
+				  net_ni_count + lnet_get_ni_count(),
 				  false);
 	if (rc)
 		goto failed0;
