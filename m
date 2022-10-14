Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D24DDC4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0B31M20z1xJR;
	Fri, 14 Oct 2022 14:38:19 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq09z1MkDz1xJR
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DEB981006F17;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D3439DD535; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:51 -0400
Message-Id: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/20] lustre: backport OpenSFS work as of
 Oct 14, 2022
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

This covers the work done for the lastest Lustre.
Most of it is IPv6 work which is needed for merger
upstream.

Bobi Jam (1):
  lustre: osc: take ldlm lock when queue sync pages

Chris Horn (1):
  lnet: Router test interop check and aarch fix

Emoly Liu (1):
  lustre: obdclass: free inst_name correctly

Etienne AUJAMES (1):
  lustre: ptlrpc: add assert for ptlrpc_service_purge_all

James Simmons (1):
  lustre: obdclass: user netlink to collect devices information

Lei Feng (1):
  lustre: ptlrpc: protect rq_repmsg in ptlrpc_req_drop_rs()

Li Dongyang (1):
  lustre: obdclass: set OBD_MD_FLGROUP for ladvise RPC

Mikhail Pershin (1):
  lustre: llog: correct llog FID and path output

Mr NeilBrown (6):
  lnet: track pinginfo size in bytes, not nis.
  lnet: add iface index to struct lnet_inetdev
  lnet: ksocklnd: support IPv6 in ksocknal_ip2index()
  lnet: only use PUBLIC IP6 addresses for connections
  lnet: use %pISc for formatting IP addresses
  lnet: socklnd: remove remnants of tcp bonding

Patrick Farrell (1):
  lustre: osc: Remove oap_magic

Serguei Smirnov (4):
  lnet: o2iblnd: fix handling of RDMA_CM_EVENT_UNREACHABLE
  lnet: o2iblnd: fix deadline for tx on peer queue
  lnet: o2iblnd: detect link state to set fatal error on ni
  lnet: socklnd: limit retries on conns_per_peer mismatch

Yang Sheng (1):
  lustre: ptlrpc: lower the message level in no resend case

 fs/lustre/include/lustre_kernelcomm.h         |  37 ++-
 fs/lustre/include/lustre_net.h                |   9 +-
 fs/lustre/include/lustre_osc.h                |   4 +-
 fs/lustre/mdc/mdc_dev.c                       |   3 +
 fs/lustre/obdclass/class_obd.c                |  14 +-
 fs/lustre/obdclass/kernelcomm.c               | 257 +++++++++++++++++-
 fs/lustre/obdclass/llog.c                     |  11 +-
 fs/lustre/obdclass/llog_cat.c                 |  37 +--
 fs/lustre/obdclass/llog_swab.c                |   2 +-
 fs/lustre/obdclass/obd_config.c               |   5 +-
 fs/lustre/obdclass/obdo.c                     |   3 -
 fs/lustre/osc/osc_cache.c                     |  13 +-
 fs/lustre/osc/osc_io.c                        |   3 +-
 fs/lustre/osc/osc_lock.c                      |  19 ++
 fs/lustre/osc/osc_page.c                      |   7 +-
 fs/lustre/ptlrpc/client.c                     |   3 +-
 fs/lustre/ptlrpc/service.c                    |   2 +
 include/linux/lnet/lib-lnet.h                 |   7 +-
 include/linux/lnet/lib-types.h                |  13 +-
 include/uapi/linux/lnet/lnet-idl.h            |   8 +-
 include/uapi/linux/lustre/lustre_kernelcomm.h |  18 ++
 include/uapi/linux/lustre/lustre_user.h       |   1 +
 net/lnet/klnds/o2iblnd/o2iblnd.c              | 219 ++++++++++++---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c           |  34 ++-
 net/lnet/klnds/socklnd/socklnd.c              | 134 ++++-----
 net/lnet/klnds/socklnd/socklnd.h              |   8 +-
 net/lnet/klnds/socklnd/socklnd_cb.c           |  69 +++--
 net/lnet/klnds/socklnd/socklnd_proto.c        |  30 +-
 net/lnet/lnet/acceptor.c                      |  34 +--
 net/lnet/lnet/api-ni.c                        | 180 ++++++------
 net/lnet/lnet/config.c                        |   1 +
 net/lnet/lnet/lib-move.c                      |  10 +-
 net/lnet/lnet/lib-msg.c                       |  14 +-
 net/lnet/lnet/lib-socket.c                    |  13 +-
 net/lnet/lnet/peer.c                          |  58 ++--
 net/lnet/lnet/router.c                        |  24 +-
 36 files changed, 909 insertions(+), 395 deletions(-)

-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
