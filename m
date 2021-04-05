Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6237BC433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:21 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B29146138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B29146138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6352921F62F;
	Mon,  5 Apr 2021 00:51:20 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A1AC321F521
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:17 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8BC286B0;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7E62490AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:29 -0400
Message-Id: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/41] lustre: sync to OpenSFS branch as of
 March 1
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

Backport various patches for the start of 2.15 development cycle.
This covers the USDP feature landing. I did hold back the fake
symlink work as well as IPv6 LNet support. Newer kernels have
isses with the ports which I need to investigate.

Alex Zhuravlev (1):
  lustre: obdclass: try to skip corrupted llog records

Amir Shehata (9):
  lnet: UDSP storage and marshalled structs
  lnet: foundation patch for selection mod
  lnet: Preferred gateway selection
  lnet: Select NI/peer NI with highest prio
  lnet: select best peer and local net
  lnet: UDSP handling
  lnet: Apply UDSP on local and remote NIs
  lnet: Add the kernel level Marshalling API
  lnet: ioctl handler for get policy info

Andreas Dilger (4):
  lustre: lov: avoid NULL dereference in cleanup
  lustre: llite: quiet spurious ioctl warning
  lsutre: ldlm: return error from ldlm_namespace_new()
  lustre: llite: remove unused ll_teardown_mmaps()

Andrew Perepechko (1):
  lustre: llite: data corruption due to RPC reordering

Andriy Skulysh (1):
  lustre: lov: grant deadlock if same OSC in two components

Bobi Jam (1):
  lustre: lov: fix layout generation inc for mirror split

James Simmons (1):
  lnet: place wire protocol data int own headers

John L. Hammond (1):
  lustre: change EWOULDBLOCK to EAGAIN

Mr NeilBrown (11):
  lustre: lov: style cleanups in lov_set_osc_active()
  lustre: change various operations structs to const
  lustre: mark strings in char arrays as const
  lustre: convert snprintf to scnprintf as appropriate
  lustre: remove non-static 'inline' markings.
  lustre: llite: use is_root_inode()
  lnet: libcfs: discard cfs_firststr
  lnet: libcfs: use wait_event_timeout() in tracefiled().
  lnet: use init_wait() rather than init_waitqueue_entry()
  lnet: discard LNET_MD_PHYS
  lnet: o2iblnd: convert peers hash table to hashtable.h

Oleg Drokin (2):
  lustre: update version to 2.14.0
  lustre: update version to 2.14.50

Rahul Deshmkuh (1):
  lustre: lov: fixes bitfield in lod qos code

Sebastien Buisson (3):
  lustre: ptlrpc: do not output error when imp_sec is freed
  lustre: gss: handle empty reqmsg in sptlrpc_req_ctx_switch
  lustre: sec: file ioctls to handle encryption policies

Serguei Smirnov (1):
  lnet: modify assertion in lnet_post_send_locked

Sonia Sharma (3):
  lnet: Add the kernel level De-Marshalling API
  lnet: Add the ioctl handler for "add policy"
  lnet: ioctl handler for "delete policy"

Wang Shilong (1):
  lustre: llite: make readahead aware of hints

 fs/lustre/fld/fld_request.c                |    2 +-
 fs/lustre/include/cl_object.h              |   18 +-
 fs/lustre/include/lu_object.h              |   17 +-
 fs/lustre/include/lustre_log.h             |   10 +-
 fs/lustre/include/lustre_net.h             |    2 +-
 fs/lustre/include/lustre_osc.h             |    2 +
 fs/lustre/include/obd_cksum.h              |    2 +-
 fs/lustre/{llite => include}/range_lock.h  |    0
 fs/lustre/ldlm/ldlm_lib.c                  |   10 +-
 fs/lustre/ldlm/ldlm_resource.c             |   32 +-
 fs/lustre/llite/Makefile                   |    2 +-
 fs/lustre/llite/crypto.c                   |    8 +-
 fs/lustre/llite/file.c                     |   33 +-
 fs/lustre/llite/glimpse.c                  |    2 +-
 fs/lustre/llite/llite_internal.h           |    5 +-
 fs/lustre/llite/llite_mmap.c               |   59 +-
 fs/lustre/llite/lproc_llite.c              |   32 +-
 fs/lustre/llite/pcc.c                      |   38 +-
 fs/lustre/llite/rw.c                       |   20 +-
 fs/lustre/llite/super25.c                  |    2 +-
 fs/lustre/llite/vvp_page.c                 |    2 +-
 fs/lustre/lmv/lmv_obd.c                    |    2 +-
 fs/lustre/lmv/lproc_lmv.c                  |    6 +-
 fs/lustre/lov/lov_ea.c                     |    4 +-
 fs/lustre/lov/lov_io.c                     |    4 +
 fs/lustre/lov/lov_obd.c                    |   17 +-
 fs/lustre/lov/lov_object.c                 |    3 +-
 fs/lustre/lov/lov_pack.c                   |    8 -
 fs/lustre/mdc/mdc_dev.c                    |    3 +-
 fs/lustre/obdclass/Makefile                |    3 +-
 fs/lustre/obdclass/cl_io.c                 |   14 +-
 fs/lustre/obdclass/llog.c                  |   80 +-
 fs/lustre/obdclass/llog_cat.c              |   14 +-
 fs/lustre/obdclass/llog_internal.h         |    5 +
 fs/lustre/obdclass/llog_obd.c              |    2 +-
 fs/lustre/obdclass/lu_tgt_descs.c          |   38 +-
 fs/lustre/obdclass/obd_sysfs.c             |    6 +-
 fs/lustre/{llite => obdclass}/range_lock.c |    6 +-
 fs/lustre/osc/osc_io.c                     |   17 +-
 fs/lustre/osc/osc_lock.c                   |    2 +-
 fs/lustre/osc/osc_request.c                |    2 +-
 fs/lustre/ptlrpc/client.c                  |    2 +-
 fs/lustre/ptlrpc/errno.c                   |    4 +-
 fs/lustre/ptlrpc/llog_client.c             |    2 +-
 fs/lustre/ptlrpc/pers.c                    |    1 -
 fs/lustre/ptlrpc/sec.c                     |   14 +-
 include/linux/lnet/lib-lnet.h              |   45 +
 include/linux/lnet/lib-types.h             |   72 +-
 include/linux/lnet/udsp.h                  |  144 +++
 include/uapi/linux/lnet/libcfs_debug.h     |    1 +
 include/uapi/linux/lnet/libcfs_ioctl.h     |    8 +-
 include/uapi/linux/lnet/lnet-dlc.h         |   91 +-
 include/uapi/linux/lnet/lnet-idl.h         |  241 +++++
 include/uapi/linux/lnet/lnet-types.h       |  220 +---
 include/uapi/linux/lnet/lnetctl.h          |    1 +
 include/uapi/linux/lnet/lnetst.h           |    2 +
 include/uapi/linux/lnet/nidstr.h           |    5 +
 include/uapi/linux/lnet/socklnd.h          |    1 +
 include/uapi/linux/lustre/lustre_user.h    |    2 +-
 include/uapi/linux/lustre/lustre_ver.h     |    6 +-
 net/lnet/klnds/o2iblnd/o2iblnd-idl.h       |  157 +++
 net/lnet/klnds/o2iblnd/o2iblnd.c           |  267 +++--
 net/lnet/klnds/o2iblnd/o2iblnd.h           |  133 +--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |   18 +-
 net/lnet/klnds/socklnd/socklnd_cb.c        |    4 +-
 net/lnet/libcfs/libcfs_string.c            |   28 -
 net/lnet/libcfs/tracefile.c                |   37 +-
 net/lnet/lnet/Makefile                     |    2 +-
 net/lnet/lnet/api-ni.c                     |  278 ++++-
 net/lnet/lnet/config.c                     |    4 +
 net/lnet/lnet/lib-move.c                   |  399 ++++---
 net/lnet/lnet/nidstrings.c                 |   66 ++
 net/lnet/lnet/peer.c                       |  267 +++--
 net/lnet/lnet/udsp.c                       | 1553 ++++++++++++++++++++++++++++
 74 files changed, 3744 insertions(+), 865 deletions(-)
 rename fs/lustre/{llite => include}/range_lock.h (100%)
 rename fs/lustre/{llite => obdclass}/range_lock.c (96%)
 create mode 100644 include/linux/lnet/udsp.h
 create mode 100644 include/uapi/linux/lnet/lnet-idl.h
 create mode 100644 net/lnet/klnds/o2iblnd/o2iblnd-idl.h
 create mode 100644 net/lnet/lnet/udsp.c

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
