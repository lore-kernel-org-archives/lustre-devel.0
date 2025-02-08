Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 84396C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:32:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw62DJwz1xdK;
	Fri, 07 Feb 2025 16:30:46 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWvx6K0Tz1x5M
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:37 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E5B4C17B5B8;
 Fri,  7 Feb 2025 19:30:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id DA3EF106BE17; Fri,  7 Feb 2025 19:30:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:08 -0500
Message-ID: <20250208003027.180076-3-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 02/21] lnet: report actual timeout used by lnd
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
Cc: Frank Sehr <fsehr@whamcloud.com>, Cyril Bordage <cbordage@whamcloud.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Frank Sehr <fsehr@whamcloud.com>

lnd_timeout value reported by lnetctl may be different
from what is actually used.
There's an lnd_timeout calculated as a function of transaction
timeout and retry_count. This is the value displayed by
"lnetctl global show". However, each LND may define its own
timeout by setting timeout module parameter to a positive value,
which overrides the higher-level lnd_timeout defined by LNet.
lnetctl net show -v will show the timeout value in the
lnd_tunables section.
The timeout for socklnd and o2iblnd is implemented.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16548
Lustre-commit: 56097c490465cb67a ("LU-16548 lnet: report actual timeout used by lnd")
Signed-off-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50620
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/lnet-dlc.h         | 2 ++
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c | 2 ++
 net/lnet/klnds/socklnd/socklnd_modparams.c | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index d7592f3fd1f8..b4851b193a90 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -105,12 +105,14 @@ struct lnet_ioctl_config_o2iblnd_tunables {
 	__u32 lnd_fmr_cache;
 	__u16 lnd_conns_per_peer;
 	__u16 lnd_ntx;
+	__u32 lnd_timeout;
 };
 
 struct lnet_ioctl_config_socklnd_tunables {
 	__u32 lnd_version;
 	__u16 lnd_conns_per_peer;
 	__u16 lnd_pad;
+	__u32 lnd_timeout;
 };
 
 struct lnet_lnd_tunables {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 04286e18c7ba..e26bedee00ba 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -316,6 +316,8 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 			conns_per_peer : 1;
 	}
 
+	tunables->lnd_timeout = kiblnd_timeout();
+
 	return 0;
 }
 
diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index 031fe13d2a38..ed6c60e88c84 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -332,4 +332,6 @@ void ksocknal_tunables_setup(struct lnet_ni *ni)
 	if (!tunables->lnd_conns_per_peer)
 		tunables->lnd_conns_per_peer =
 			ksocklnd_lookup_conns_per_peer(ni);
+
+	tunables->lnd_timeout = ksocknal_timeout();
 }
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
