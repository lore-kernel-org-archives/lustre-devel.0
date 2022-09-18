Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8AD50C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:53 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmY1zycz1y7W;
	Sat, 17 Sep 2022 22:22:53 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVbmB1q6Fz1yCq
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:34 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 142CC8F15;
 Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 11BDCE8B93; Sun, 18 Sep 2022 01:22:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:22:11 -0400
Message-Id: <1663478534-19917-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/24] lustre: ptlrpc: adds configurable ping
 interval
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Alexander Boyko <alexander.boyko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alexander Boyko <alexander.boyko@hpe.com>

The patch adds ability to change ping interval and eviction
mutliplier. A default values stay as before.
Example
lctl set_param ping_interval=10
lctl set_param evict_multiplier=5

HPE-bug-id: LUS-11054
WC-bug-id: https://jira.whamcloud.com/browse/LU-16002
Lustre-commit: 8e66f061c01e53cda ("LU-16002 ptlrpc: adds configurable ping interval")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/47982
Reviewed-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  6 ++++--
 fs/lustre/obdclass/class_obd.c  |  5 +++++
 fs/lustre/obdclass/obd_config.c |  1 +
 fs/lustre/obdclass/obd_sysfs.c  | 32 ++++++++++++++++++++++++++++++--
 4 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index c98c8a4..b58c1df 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -47,6 +47,8 @@
  * networking / disk / timings affected by load (use Adaptive Timeouts)
  */
 extern unsigned int obd_timeout;	/* seconds */
+extern unsigned int ping_interval;	/* seconds */
+extern unsigned int ping_evict_timeout_multiplier;
 extern unsigned int obd_timeout_set;
 extern unsigned int at_min;
 extern unsigned int at_max;
@@ -66,7 +68,7 @@
 /* Should be very conservative; must catch the first reconnect after reboot */
 #define OBD_RECOVERY_TIME_SOFT	(obd_timeout * 3)
 /* Change recovery-small 26b time if you change this */
-#define PING_INTERVAL		max(obd_timeout / 4, 1U)
+#define PING_INTERVAL		ping_interval
 /* a bit more than maximal journal commit time in seconds */
 #define PING_INTERVAL_SHORT	min(PING_INTERVAL, 7U)
 /* Client may skip 1 ping; we must wait at least 2.5. But for multiple
@@ -75,7 +77,7 @@
  * and there's no urgent need to evict a client just because it's idle, we
  * should be very conservative here.
  */
-#define PING_EVICT_TIMEOUT	(PING_INTERVAL * 6)
+#define PING_EVICT_TIMEOUT	(PING_INTERVAL * ping_evict_timeout_multiplier)
 #define DISK_TIMEOUT		50 /* Beyond this we warn about disk speed */
 #define CONNECTION_SWITCH_MIN	5U /* Connection switching rate limiter */
 /* Max connect interval for nonresponsive servers; ~50s to avoid building up
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index b30d941..f455ed7 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -63,6 +63,11 @@
 EXPORT_SYMBOL(obd_dirty_pages);
 unsigned int obd_timeout = OBD_TIMEOUT_DEFAULT;   /* seconds */
 EXPORT_SYMBOL(obd_timeout);
+unsigned int ping_interval = (OBD_TIMEOUT_DEFAULT > 4) ?
+			     (OBD_TIMEOUT_DEFAULT / 4) : 1;
+EXPORT_SYMBOL(ping_interval);
+unsigned int ping_evict_timeout_multiplier = 6;
+EXPORT_SYMBOL(ping_evict_timeout_multiplier);
 unsigned int obd_timeout_set;
 EXPORT_SYMBOL(obd_timeout_set);
 /* Adaptive timeout defs here instead of ptlrpc module for /sys/fs/ access */
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 4db7399..7d001ff 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -869,6 +869,7 @@ int class_process_config(struct lustre_cfg *lcfg)
 		CDEBUG(D_IOCTL, "changing lustre timeout from %d to %d\n",
 		       obd_timeout, lcfg->lcfg_num);
 		obd_timeout = max(lcfg->lcfg_num, 1U);
+		ping_interval = max(obd_timeout / 4, 1U);
 		obd_timeout_set = 1;
 		err = 0;
 		goto out;
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index 93d2abc..fc8debb 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -109,7 +109,6 @@ static ssize_t static_uintvalue_store(struct kobject *kobj,
 	{ __ATTR(name, 0644, static_uintvalue_show,			\
 		 static_uintvalue_store), value }
 
-LUSTRE_STATIC_UINT_ATTR(timeout, &obd_timeout);
 LUSTRE_STATIC_UINT_ATTR(debug_peer_on_timeout, &obd_debug_peer_on_timeout);
 LUSTRE_STATIC_UINT_ATTR(dump_on_timeout, &obd_dump_on_timeout);
 LUSTRE_STATIC_UINT_ATTR(dump_on_eviction, &obd_dump_on_eviction);
@@ -119,6 +118,8 @@ static ssize_t static_uintvalue_store(struct kobject *kobj,
 LUSTRE_STATIC_UINT_ATTR(at_early_margin, &at_early_margin);
 LUSTRE_STATIC_UINT_ATTR(at_history, &at_history);
 LUSTRE_STATIC_UINT_ATTR(lbug_on_eviction, &obd_lbug_on_eviction);
+LUSTRE_STATIC_UINT_ATTR(ping_interval, &ping_interval);
+LUSTRE_STATIC_UINT_ATTR(evict_multiplier, &ping_evict_timeout_multiplier);
 
 static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
@@ -311,6 +312,30 @@ static ssize_t jobid_this_session_store(struct kobject *kobj,
 	return ret ?: count;
 }
 
+static ssize_t timeout_show(struct kobject *kobj,
+			    struct attribute *attr,
+			    char *buf)
+{
+	return sprintf(buf, "%u\n", obd_timeout);
+}
+
+static ssize_t timeout_store(struct kobject *kobj,
+			     struct attribute *attr,
+			     const char *buffer,
+			     size_t count)
+{
+	unsigned int val;
+	int rc;
+
+	rc = kstrtouint(buffer, 10, &val);
+	if (rc)
+		return rc;
+	obd_timeout = val ?: 1U;
+	ping_interval = max(obd_timeout / 4, 1U);
+
+	return count;
+}
+
 /* Root for /sys/kernel/debug/lustre */
 struct dentry *debugfs_lustre_root;
 EXPORT_SYMBOL_GPL(debugfs_lustre_root);
@@ -321,6 +346,7 @@ static ssize_t jobid_this_session_store(struct kobject *kobj,
 LUSTRE_RW_ATTR(jobid_var);
 LUSTRE_RW_ATTR(jobid_name);
 LUSTRE_RW_ATTR(jobid_this_session);
+LUSTRE_RW_ATTR(timeout);
 
 static struct attribute *lustre_attrs[] = {
 	&lustre_attr_version.attr,
@@ -329,7 +355,7 @@ static ssize_t jobid_this_session_store(struct kobject *kobj,
 	&lustre_attr_jobid_name.attr,
 	&lustre_attr_jobid_var.attr,
 	&lustre_attr_jobid_this_session.attr,
-	&lustre_sattr_timeout.u.attr,
+	&lustre_attr_timeout.attr,
 	&lustre_attr_max_dirty_mb.attr,
 	&lustre_sattr_debug_peer_on_timeout.u.attr,
 	&lustre_sattr_dump_on_timeout.u.attr,
@@ -340,6 +366,8 @@ static ssize_t jobid_this_session_store(struct kobject *kobj,
 	&lustre_sattr_at_early_margin.u.attr,
 	&lustre_sattr_at_history.u.attr,
 	&lustre_sattr_lbug_on_eviction.u.attr,
+	&lustre_sattr_ping_interval.u.attr,
+	&lustre_sattr_evict_multiplier.u.attr,
 	NULL,
 };
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
