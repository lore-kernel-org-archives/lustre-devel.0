From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:56 -0400
Subject: [lustre-devel] [PATCH 17/22] lnet: Add lnet_lnd_timeout to sysfs
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Allow lnet_lnd_timeout to be read (only) from sysfs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13510
Lustre-commit: 17802b329cdea ("LU-13510 lnet: Add lnet_lnd_timeout to sysfs")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38482
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 1 +
 net/lnet/lnet/router_proc.c   | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a7825f9..def0923 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -417,6 +417,7 @@ struct lnet_ni *
 
 extern unsigned int lnet_transaction_timeout;
 extern unsigned int lnet_retry_count;
+extern unsigned int lnet_lnd_timeout;
 extern unsigned int lnet_numa_range;
 extern unsigned int lnet_health_sensitivity;
 extern unsigned int lnet_recovery_interval;
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 180bbde..7fe8d33 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -881,6 +881,13 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 		.proc_handler	= &proc_lnet_portal_rotor,
 	},
 	{
+		.procname	= "lnet_lnd_timeout",
+		.data		= &lnet_lnd_timeout,
+		.maxlen		= sizeof(lnet_lnd_timeout),
+		.mode		= 0444,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
 	}
 };
 
-- 
1.8.3.1
