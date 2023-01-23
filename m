Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E18ABC05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:01:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Dy48v9z1wcB;
	Mon, 23 Jan 2023 15:01:06 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Dq2JSKz1wSM
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:00:59 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1674A6B8;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0E73A58987; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:13 -0500
Message-Id: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/42] lustre: sync to OpenSFS tree as of Jan
 22 2023
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

Merge the latest work from OpenSFS tree into the native Linux
client.

Alexander Boyko (1):
  lustre: ptlrpc: don't panic during reconnection

Alexander Zarochentsev (1):
  lnet: libcfs: cfs_hash_for_each_empty optimization

Alexey Lyashkov (1):
  lnet: selftest: lst read-outside of allocation

Andreas Dilger (4):
  lustre: misc: fix stats snapshot_time to use wallclock
  lustre: misc: rename lprocfs_stats functions
  lustre: ptlrpc: NUL terminate long jobid strings
  lustre: ldlm: remove obsolete LDLM_FL_SERVER_LOCK

Aurelien Degremont (2):
  lustre: llite: remove false outdated comment
  lnet: socklnd: clarify error message on timeout

Bobi Jam (1):
  lustre: llite: revert: "llite: clear stale page's uptodate bit"

Chris Horn (1):
  lnet: Drop LNet message if deadline exceeded

Cyril Bordage (2):
  lnet: handles unregister/register events
  lnet: increase transaction timeout

Etienne AUJAMES (2):
  lustre: pools: force creation of a component without a pool
  lustre: llite: replace selinux_is_enabled()

Frank Sehr (1):
  lnet: Allow IP specification

Gian-Carlo DeFazio (1):
  lnet: asym route inconsistency warning

James Simmons (5):
  lnet: change lnet_find_best_lpni to handle large NIDs
  lnet: selftest: migrate LNet selftest group handling to Netlink
  lnet: use Netlink to support LNet ping commands
  lnet: validate data sent from user land properly
  lnet: modify lnet_inetdev to work with large NIDS

Lai Siyao (3):
  lustre: llite: wake_up after cl_object_kill
  lustre: uapi: remove _GNU_SOURCE dependency in lustre_user.h
  lustre: llite: always enable remote subdir mount

Lei Feng (2):
  lustre: ldebugfs: add histogram to stats counter
  lustre: ldebugfs: make job_stats and rename_stats valid YAML

Li Dongyang (2):
  lustre: obdclass: fix T10PI prototypes
  lustre: obdclass: prefer T10 checksum if the target supports it

Mr NeilBrown (2):
  lnet: lnet_peer_merge_data to understand large addr
  lnet: router_discover - handle large addrs in ping

Oleg Drokin (1):
  lustre: update version to 2.15.53

Patrick Farrell (2):
  lustre: osc: pack osc_async_page better
  lustre: osc: Fix possible null pointer

Qian Yingjin (2):
  lustre: pcc: use two bits to indicate pcc type for attach
  lustre: llite: update statx size/ctime for fallocate

Sebastien Buisson (2):
  lustre: sec: reserve flag for fid2path for encrypted files
  lustre: enc: S_ENCRYPTED flag on OST objects for enc files

Serguei Smirnov (1):
  lnet: o2iblnd: reset hiw proportionally

Shaun Tancheff (3):
  lustre: ptlrpc: fiemap flexible array
  lustre: ptlrpc: Add LCME_FL_PARITY to wirecheck
  lustre: move to kobj_type default_groups

 fs/lustre/include/cl_object.h           |  15 +-
 fs/lustre/include/lprocfs_status.h      |  15 +-
 fs/lustre/include/lustre_dlm_flags.h    |   6 -
 fs/lustre/include/lustre_osc.h          |  41 +-
 fs/lustre/include/obd.h                 |   3 +-
 fs/lustre/include/obd_cksum.h           |  15 +-
 fs/lustre/include/obd_class.h           |  43 ++
 fs/lustre/include/obd_support.h         |   1 +
 fs/lustre/ldlm/ldlm_lib.c               |   1 +
 fs/lustre/ldlm/ldlm_pool.c              |   8 +-
 fs/lustre/ldlm/ldlm_resource.c          |   8 +-
 fs/lustre/llite/dir.c                   |  22 +-
 fs/lustre/llite/file.c                  |  10 +-
 fs/lustre/llite/lcommon_cl.c            |   5 +
 fs/lustre/llite/llite_internal.h        |  46 +-
 fs/lustre/llite/llite_lib.c             |  16 +
 fs/lustre/llite/lproc_llite.c           |  36 +-
 fs/lustre/llite/namei.c                 |  93 ++--
 fs/lustre/llite/rw.c                    |  10 +-
 fs/lustre/llite/vvp_io.c                | 136 +-----
 fs/lustre/llite/vvp_page.c              |   5 -
 fs/lustre/llite/xattr.c                 |  10 +-
 fs/lustre/llite/xattr_cache.c           |   6 +-
 fs/lustre/llite/xattr_security.c        | 193 +++++++--
 fs/lustre/lmv/lproc_lmv.c               |   4 +-
 fs/lustre/lov/lproc_lov.c               |   4 +-
 fs/lustre/mdc/lproc_mdc.c               |  14 +-
 fs/lustre/mdc/mdc_dev.c                 |  13 +-
 fs/lustre/obdclass/cl_page.c            |  37 +-
 fs/lustre/obdclass/genops.c             |   4 +-
 fs/lustre/obdclass/integrity.c          |  12 +-
 fs/lustre/obdclass/lprocfs_counters.c   |  13 +
 fs/lustre/obdclass/lprocfs_status.c     |  82 +++-
 fs/lustre/obdclass/lu_object.c          |   5 +-
 fs/lustre/obdclass/obd_config.c         |  15 +-
 fs/lustre/osc/lproc_osc.c               |  18 +-
 fs/lustre/osc/osc_cache.c               |  10 +-
 fs/lustre/osc/osc_dev.c                 |  17 +-
 fs/lustre/osc/osc_io.c                  |   5 +-
 fs/lustre/osc/osc_page.c                |   4 +-
 fs/lustre/osc/osc_request.c             |  14 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c         |  10 +-
 fs/lustre/ptlrpc/niobuf.c               |  19 +-
 fs/lustre/ptlrpc/pack_generic.c         |   6 +
 fs/lustre/ptlrpc/sec.c                  |  17 +-
 fs/lustre/ptlrpc/wiretest.c             |   6 +-
 include/linux/lnet/lib-lnet.h           |   6 +-
 include/linux/lnet/lib-types.h          |  46 ++
 include/uapi/linux/lnet/libcfs_ioctl.h  |   2 +-
 include/uapi/linux/lnet/lnet-dlc.h      |   2 +
 include/uapi/linux/lnet/lnet-types.h    |  27 +-
 include/uapi/linux/lnet/lnetst.h        |   2 +
 include/uapi/linux/lustre/lustre_idl.h  |   1 +
 include/uapi/linux/lustre/lustre_user.h |  55 ++-
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |  22 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h        |  30 +-
 net/lnet/klnds/socklnd/socklnd.c        |  87 ++--
 net/lnet/klnds/socklnd/socklnd_cb.c     |  10 +-
 net/lnet/libcfs/hash.c                  |  19 +-
 net/lnet/lnet/api-ni.c                  | 540 ++++++++++++++++++++----
 net/lnet/lnet/config.c                  |  58 ++-
 net/lnet/lnet/lib-move.c                |  73 ++--
 net/lnet/lnet/lib-msg.c                 |   2 +-
 net/lnet/lnet/nidstrings.c              |  24 ++
 net/lnet/lnet/peer.c                    |  84 ++--
 net/lnet/lnet/router.c                  |  19 +-
 net/lnet/selftest/conctl.c              | 421 ++++++++++++++----
 net/lnet/selftest/conrpc.c              |  22 +-
 net/lnet/selftest/console.c             |  27 +-
 net/lnet/selftest/console.h             |   4 +-
 net/lnet/selftest/selftest.h            |  60 ++-
 72 files changed, 1896 insertions(+), 824 deletions(-)

-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
