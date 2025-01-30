Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CFAFCC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:48:51 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLl81C8fz22SD;
	Thu, 30 Jan 2025 06:20:04 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLbF3D5sz1y6S
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:13:13 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 35B55899ADC;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 340B5106BE14; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:11 -0500
Message-ID: <20250130141115.950749-22-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 21/25] lnet: restore IOC_LIBCFS_GET_NI
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
Cc: Frank Sehr <fsehr@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Restore IOC_LIBCFS_GET_NI for compatibility until there have been
some releases with netlink support, so that older utilities just
work.

Fixes: fafd24988 ("lnet: use Netlink to support old and new NI APIs.")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16462
Lustre-commit: ae1ee11cea0a90631 ("LU-16462 utils: handle lack of newer nla_attrs")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49608
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/uapi/linux/lnet/libcfs_ioctl.h | 2 +-
 net/lnet/lnet/api-ni.c                 | 7 +++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index e012532fc88a..a77a736c1107 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -94,7 +94,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_MARK_DEBUG		_IOWR('e', 32, IOCTL_LIBCFS_TYPE)
 /* IOC_LIBCFS_MEMHOG obsolete in 2.8.0, was _IOWR('e', 36, IOCTL_LIBCFS_TYPE) */
 /* lnet ioctls */
-/* IOC_LIBCFS_GET_NI obsolete in 2.16, was _IOWR('e', 50, IOCTL_LIBCFS_TYPE) */
+#define IOC_LIBCFS_GET_NI		_IOWR('e', 50, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_FAIL_NID		_IOWR('e', 51, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_NOTIFY_ROUTER	_IOWR('e', 55, IOCTL_LIBCFS_TYPE)
 #define IOC_LIBCFS_UNCONFIGURE		_IOWR('e', 56, IOCTL_LIBCFS_TYPE)
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index f3f9aeef04dd..5ec6faa2da98 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4030,6 +4030,13 @@ LNetCtl(unsigned int cmd, void *arg)
 		     sizeof(struct lnet_ioctl_config_data));
 
 	switch (cmd) {
+	case IOC_LIBCFS_GET_NI: {
+		struct lnet_processid id = {};
+
+		rc = LNetGetId(data->ioc_count, &id);
+		data->ioc_nid = lnet_nid_to_nid4(&id.nid);
+		return rc;
+	}
 	case IOC_LIBCFS_FAIL_NID:
 		return lnet_fail_nid(data->ioc_nid, data->ioc_count);
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
