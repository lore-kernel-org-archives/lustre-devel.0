Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 21AEBC43219
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:17:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXf23b0Yz1y2p;
	Sun, 20 Nov 2022 06:17:14 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXdy5sHpz1wM4
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:17:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A892B1006F2A;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9EE44E8B84; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:46 -0500
Message-Id: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/22] lustre: backport OpenSFS work as of
 Nov 20, 2022
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Merge the next batch of work from the OpenSFS tree to the Linux
native client. Most of the IPv6 ping work is now merged.

Alex Zhuravlev (1):
  lustre: llite: remove linefeed from LDLM_DEBUG

Bobi Jam (1):
  lustre: llite: clear stale page's uptodate bit

Chris Horn (2):
  lnet: Don't modify uptodate peer with temp NI
  lnet: Signal completion on ping send failure

James Simmons (3):
  lnet: use Netlink to support old and new NI APIs.
  lnet: fix build issue when IPv6 is disabled.
  lnet: selftest: migrate LNet selftest session handling to Netlink

Lei Feng (1):
  lustre: obdclass: fill jobid in a safe way

Mikhail Pershin (1):
  lustre: llog: skip bad records in llog

Mr NeilBrown (7):
  lustre: obdclass: improve precision of wakeups for mod_rpcs
  lnet: allow ping packet to contain large nids
  lnet: extend lnet_is_nid_in_ping_info()
  lnet: find correct primary for peer
  lnet: change lnet_notify() to take struct lnet_nid
  lnet: discard lnet_nid2ni_*()
  lnet: change lnet_debug_peer() to struct lnet_nid

Patrick Farrell (1):
  lustre: osc: Remove oap lock

Serguei Smirnov (2):
  lnet: o2iblnd: add verbose debug prints for rx/tx events
  lnet: fix debug message in lnet_discovery_event_reply

Shaun Tancheff (1):
  lustre: llite: Explicitly support .splice_write

Vitaly Fertman (2):
  lustre: clio: append to non-existent component
  lustre: ldlm: group lock unlock fix

 fs/lustre/include/cl_object.h          |  15 +-
 fs/lustre/include/lustre_dlm.h         |   1 +
 fs/lustre/include/lustre_osc.h         |  17 -
 fs/lustre/include/obd.h                |   1 -
 fs/lustre/ldlm/ldlm_lib.c              |   1 -
 fs/lustre/ldlm/ldlm_lock.c             |  28 +-
 fs/lustre/llite/file.c                 |  79 ++-
 fs/lustre/llite/llite_internal.h       |   3 +
 fs/lustre/llite/llite_lib.c            |   3 +
 fs/lustre/llite/namei.c                |   2 +-
 fs/lustre/llite/rw.c                   |  10 +-
 fs/lustre/llite/vvp_io.c               | 124 ++++-
 fs/lustre/llite/vvp_page.c             |   5 +
 fs/lustre/lov/lov_page.c               |   2 +
 fs/lustre/mdc/mdc_dev.c                |  58 +-
 fs/lustre/obdclass/cl_page.c           |  37 +-
 fs/lustre/obdclass/genops.c            | 158 +++---
 fs/lustre/obdclass/jobid.c             |  13 +-
 fs/lustre/obdclass/llog.c              |  86 +--
 fs/lustre/osc/osc_cache.c              |  11 -
 fs/lustre/osc/osc_io.c                 |   8 +-
 fs/lustre/osc/osc_lock.c               | 157 +-----
 fs/lustre/osc/osc_object.c             |  16 -
 fs/lustre/osc/osc_page.c               |   5 -
 fs/lustre/osc/osc_request.c            |  14 +-
 include/linux/lnet/lib-lnet.h          |  23 +-
 include/linux/lnet/lib-types.h         | 142 +++++
 include/uapi/linux/lnet/libcfs_ioctl.h |   2 +-
 include/uapi/linux/lnet/lnet-dlc.h     |  23 +
 include/uapi/linux/lnet/lnet-idl.h     |  58 +-
 include/uapi/linux/lnet/lnet-types.h   |  15 +
 include/uapi/linux/lnet/lnetst.h       |  21 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c       |  88 ++-
 net/lnet/klnds/o2iblnd/o2iblnd.h       |  94 +++-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c    | 136 +++--
 net/lnet/klnds/socklnd/socklnd.c       |  39 +-
 net/lnet/klnds/socklnd/socklnd.h       |   9 +
 net/lnet/lnet/api-ni.c                 | 961 ++++++++++++++++++++++++++++-----
 net/lnet/lnet/config.c                 |   6 +-
 net/lnet/lnet/lib-msg.c                |   2 +-
 net/lnet/lnet/module.c                 |  42 +-
 net/lnet/lnet/peer.c                   | 144 ++++-
 net/lnet/lnet/router.c                 |  15 +-
 net/lnet/selftest/conctl.c             | 349 +++++++++---
 net/lnet/selftest/conrpc.c             |  28 +-
 net/lnet/selftest/console.c            |  81 +--
 net/lnet/selftest/console.h            |  68 +--
 net/lnet/selftest/framework.c          |  43 +-
 net/lnet/selftest/selftest.h           |  78 ++-
 49 files changed, 2427 insertions(+), 894 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
