Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 781A3C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:14:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMKZ4Q4Tz228x;
	Sun, 02 Feb 2025 12:53:22 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMGC4q0Cz214b
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:50:27 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 22852881AA2;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1F670106BE17; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:32 -0500
Message-ID: <20250202204633.1148872-33-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 32/33] lnet: ksocklnd:
 ksocklnd_ni_get_eth_intf_speed() must use only rtnl lock
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

A kernel with debug enable is reporting the following:

include/linux/inetdevice.h:221 suspicious rcu_dereference_check() usage!
other info that might help us debug this:
rcu_scheduler_active = 2, debug_locks = 1
5 locks held by lctl/42289:
 #0: ffffffffa04263f8 ((libcfs_ioctl_list).rwsem){++++}-{3:3}, at: __blocking_notifier_call_chain+0x44/0xa0
 #1: ffffffffa04fa7b0 (lnet_config_mutex){+.+.}-{3:3}, at: lnet_configure+0x1d/0xc0 [lnet]
 #2: ffffffffa04f06e8 (the_lnet.ln_api_mutex){+.+.}-{3:3}, at: LNetNIInit+0x4c/0x960 [lnet]
 #3: ffffffffa04f0788 (&the_lnet.ln_lnd_mutex){+.+.}-{3:3}, at: lnet_startup_lndnet+0x11e/0xa90 [lnet]
 #4: ffffffff834a0cd0 (rtnl_mutex){+.+.}-{3:3}, at: rtnl_lock+0x1b/0x30

stack backtrace:
CPU: 2 PID: 42289 Comm: lctl Kdump: loaded Tainted: G        W  O     --------- -  - 4.18.0rh8.5-debug #2
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  Call Trace:
  ? dump_stack+0x119/0x18e
  ? lockdep_rcu_suspicious+0x141/0x14f
  ? ksocklnd_ni_get_eth_intf_speed.isra.1+0x308/0x360 [ksocklnd]
  ? mark_held_locks+0x6a/0xc0
  ? ktime_get_with_offset+0x233/0x2b0
  ? trace_hardirqs_on+0x4e/0x220
  ? ksocknal_tunables_setup+0xed/0x200 [ksocklnd]
  ? ksocknal_startup+0x4ff/0x1180 [ksocklnd]

The function __ethtool_get_link_ksettings() has a hard requirement
to have the in_dev device protected by the rtnl mutex. At the
same time we are aquiring in_dev using the rcu lock. The in_dev
needs to be stabilized by the same lock. So use rtnl functions
instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16807
Lustre-commit: 65d664bff40590366 ("LU-16807 ksocklnd: ksocklnd_ni_get_eth_intf_speed() must use only rtnl lock")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51028
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Neil Brown <neilb@suse.de>
---
 net/lnet/klnds/socklnd/socklnd_modparams.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index 5eb58ca97c06..031fe13d2a38 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -183,11 +183,11 @@ static int ksocklnd_ni_get_eth_intf_speed(struct lnet_ni *ni)
 		if (!(flags & IFF_UP))
 			continue;
 
-		in_dev = __in_dev_get_rcu(dev);
+		in_dev = __in_dev_get_rtnl(dev);
 		if (!in_dev)
 			continue;
 
-		in_dev_for_each_ifa_rcu(ifa, in_dev) {
+		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
 			if (strcmp(ifa->ifa_label, ni->ni_interface) == 0)
 				intf_idx = dev->ifindex;
 		}
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
