From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:31 -0400
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: lnet: enable
	configuration per NI interface
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Add the ability to configure each NI interface at bring up.
Also give the ability for user land utilities to query the
configuration of each NI interface.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   42 +++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 01e1808..fe0dbe7 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1217,6 +1217,7 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
 static int
 lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 {
+	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
 	int rc = -EINVAL;
 	int lnd_type;
 	lnd_t *lnd;
@@ -1274,6 +1275,21 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 
 	ni->ni_lnd = lnd;
 
+	if (conf && conf->cfg_hdr.ioc_len > sizeof(*conf))
+		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
+
+	if (lnd_tunables) {
+		LIBCFS_ALLOC(ni->ni_lnd_tunables,
+			     sizeof(*ni->ni_lnd_tunables));
+		if (!ni->ni_lnd_tunables) {
+			mutex_unlock(&the_lnet.ln_lnd_mutex);
+			rc = -ENOMEM;
+			goto failed0;
+		}
+		memcpy(ni->ni_lnd_tunables, lnd_tunables,
+		       sizeof(*ni->ni_lnd_tunables));
+	}
+
 	rc = lnd->lnd_startup(ni);
 
 	mutex_unlock(&the_lnet.ln_lnd_mutex);
@@ -1653,7 +1669,9 @@ EXPORT_SYMBOL(LNetNIFini);
 static void
 lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
 {
+	struct lnet_ioctl_config_lnd_tunables *lnd_cfg = NULL;
 	struct lnet_ioctl_net_config *net_config;
+	size_t min_size, tunable_size = 0;
 	int i;
 
 	if (!ni || !config)
@@ -1691,6 +1709,30 @@ lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_data *config)
 
 		config->cfg_ncpts = num_cpts;
 	}
+
+	/*
+	 * See if user land tools sent in a newer and larger version
+	 * of struct lnet_tunables than what the kernel uses.
+	 */
+	min_size = sizeof(*config) + sizeof(*net_config);
+
+	if (config->cfg_hdr.ioc_len > min_size)
+		tunable_size = config->cfg_hdr.ioc_len - min_size;
+
+	/* Don't copy to much data to user space */
+	min_size = min(tunable_size, sizeof(*ni->ni_lnd_tunables));
+	lnd_cfg = (struct lnet_ioctl_config_lnd_tunables *)net_config->cfg_bulk;
+
+	if (ni->ni_lnd_tunables && lnd_cfg && min_size) {
+		memcpy(lnd_cfg, ni->ni_lnd_tunables, min_size);
+		config->cfg_config_u.cfg_net.net_interface_count = 1;
+
+		/* Tell user land that kernel side has less data */
+		if (tunable_size > sizeof(*ni->ni_lnd_tunables)) {
+			min_size = tunable_size - sizeof(ni->ni_lnd_tunables);
+			config->cfg_hdr.ioc_len -= min_size;
+		}
+	}
 }
 
 static int
-- 
1.7.1
