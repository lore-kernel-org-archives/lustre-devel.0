Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 67168C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ED50221CA90;
	Sun, 20 Mar 2022 06:31:10 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E68C421CA87
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E208F6B9;
 Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D2B57E0D4D; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:14 -0400
Message-Id: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/50] lustre: update to OpenSFS tree as of
 March 20, 2022
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

Backport the patches that landed to OpenSFS tree that have landed
as of March 20, 2022.

Alexey Lyashkov (2):
  lnet: o2iblnd: avoid static allocation for msg tx
  lnet: o2iblnd: avoid memory copy for short msg

Andriy Skulysh (2):
  lustre: fld: don't obtain a slot for fld request
  lustre: osc: osc_extent_wait() deadlock

Chris Horn (5):
  lnet: Avoid peer NI recovery for local interface
  lnet: Check LNET_NID_IS_ANY in LNET_NID_NET
  lnet: lnet_peer_data_present() memory leak
  lnet: Don't use pref NI for reserved portal
  lnet: Stop discovery on deleted peer NI

Hongchao Zhang (1):
  lustre: quota: delete unused quota ID

James Simmons (2):
  lustre: type cleanups and remove debug statements
  lustre: osc: Fix grant test for ARM

John L. Hammond (1):
  lustre: osc: add OBD_IOC_GETATTR support for osc

Lai Siyao (3):
  lustre: llite: deadlock in ll_new_node()
  lustre: llite: LL_IOC_LMV_GETSTRIPE 'default' shows inherit layout
  lustre: llite: set default LMV hash type with 2.12 MDS

Mr NeilBrown (19):
  lnet: extend nids in struct lnet_msg
  lnet: Change lnet_send() to take large-addr nids
  lnet: use large nids in struct lnet_event
  lnet: socklnd: prepare for new KSOCK_MSG type
  lnet: socklnd: don't deref lnet_hdr in LNDs
  lnet: separate lnet_hdr in msg from that in lnd.
  lnet: change lnet_hdr to store large nids.
  lnet: change lnet_prep_send to take net_processid
  lnet: convert to struct lnet_process_id in lib-move
  lnet: convert LNetGetID to return an large-addr pid
  lnet: alter lnd_notify_peer_down() to take lnet_nid
  lnet: socklnd: move lnet_hdr unpack into ->pro_unpack
  lnet: socklnd: Change ksock_hello_msg to struct lnet_nid
  lnet: socklnd: add hello message version 4
  lnet: Convert ping to support 16-bytes address
  lnet: convert nids in lnet_parse to lnet_nid
  lnet: change src_nid arg to lnet_parse() to 16byte
  lnet: Fix NULL-deref in lnet_nidstr_r()
  lnet: change lnet_del_route() to take lnet_nid

Oleg Drokin (2):
  lustre: update version to 2.14.57
  lustre: llite: Delay dput in ll_dirty_page_discard_warn

Patrick Farrell (4):
  lustre: llite: Move free user pages
  lustre: llite: Do not get/put DIO pages
  lustre: llite: Remove unnecessary page get/put
  lnet: libcfs: Use FAIL_CHECK_QUIET for fake i/o

Qian Yingjin (1):
  lustre: hsm: update size upon completion of data version

Sebastien Buisson (4):
  lustre: sec: make client encryption compatible with ext4
  lustre: sec: allow subdir mount of encrypted dir
  lustre: sec: present .fscrypt in subdir mount
  lustre: sec: fix DIO for encrypted files

Serguei Smirnov (1):
  lnet: improve hash distribution across CPTs

Shaun Tancheff (1):
  lustre: ptlrpc: Use after free of 'conn' in rhashtable retry

Vladimir Saveliev (2):
  lustre: fld: repeat rpc in fld_client_rpc after EAGAIN
  lustre: llite: clear async errors on write commit sync

 fs/lustre/fld/fld_request.c             |  22 +-
 fs/lustre/include/cl_object.h           |  21 +-
 fs/lustre/include/lustre_dlm.h          |   2 +-
 fs/lustre/include/lustre_net.h          |   6 +-
 fs/lustre/include/lustre_osc.h          |   2 +-
 fs/lustre/include/obd.h                 |   3 +
 fs/lustre/include/obd_class.h           |   4 +-
 fs/lustre/include/obd_support.h         |   1 +
 fs/lustre/ldlm/ldlm_lib.c               |   6 +-
 fs/lustre/ldlm/ldlm_request.c           |   2 +-
 fs/lustre/llite/crypto.c                |  51 ++-
 fs/lustre/llite/dir.c                   |  68 +++-
 fs/lustre/llite/file.c                  |   8 +-
 fs/lustre/llite/llite_internal.h        |  16 +-
 fs/lustre/llite/llite_lib.c             | 102 ++++--
 fs/lustre/llite/namei.c                 |  13 +-
 fs/lustre/llite/rw26.c                  |  52 +--
 fs/lustre/llite/vvp_io.c                |   5 +
 fs/lustre/llite/vvp_page.c              |  36 +-
 fs/lustre/llite/xattr.c                 |  65 ++--
 fs/lustre/lmv/lmv_obd.c                 |  12 +-
 fs/lustre/lov/lov_pack.c                |   5 +-
 fs/lustre/mdc/mdc_dev.c                 |   1 +
 fs/lustre/mdc/mdc_request.c             |  28 +-
 fs/lustre/obdclass/cl_io.c              |  25 +-
 fs/lustre/obdclass/cl_page.c            |   9 +-
 fs/lustre/obdclass/lprocfs_status.c     |   8 +-
 fs/lustre/obdclass/lu_object.c          |   8 +-
 fs/lustre/osc/osc_cache.c               |  39 ++-
 fs/lustre/osc/osc_io.c                  |  30 +-
 fs/lustre/osc/osc_page.c                |   1 -
 fs/lustre/osc/osc_request.c             | 122 ++++---
 fs/lustre/ptlrpc/client.c               |   6 +-
 fs/lustre/ptlrpc/connection.c           |  26 +-
 fs/lustre/ptlrpc/events.c               |  10 +-
 fs/lustre/ptlrpc/import.c               |   6 +-
 fs/lustre/ptlrpc/layout.c               |   5 +-
 fs/lustre/ptlrpc/niobuf.c               |  10 +-
 fs/lustre/ptlrpc/pack_generic.c         |  10 +-
 fs/lustre/ptlrpc/ptlrpc_internal.h      |   2 +-
 fs/lustre/ptlrpc/sec.c                  |   4 +-
 fs/lustre/ptlrpc/sec_config.c           |   9 +-
 fs/lustre/ptlrpc/service.c              |   2 +-
 include/linux/libcfs/libcfs_fail.h      |   6 +-
 include/linux/lnet/api.h                |   4 +-
 include/linux/lnet/lib-lnet.h           |  77 ++++-
 include/linux/lnet/lib-types.h          |  12 +-
 include/linux/lnet/socklnd.h            |  67 ++--
 include/uapi/linux/lnet/lnet-idl.h      |  40 ++-
 include/uapi/linux/lnet/lnet-types.h    |  17 +-
 include/uapi/linux/lustre/lustre_idl.h  |   5 +-
 include/uapi/linux/lustre/lustre_user.h |   6 +-
 include/uapi/linux/lustre/lustre_ver.h  |   4 +-
 net/lnet/klnds/o2iblnd/o2iblnd-idl.h    |   6 +-
 net/lnet/klnds/o2iblnd/o2iblnd.c        |   8 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h        |   5 +-
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c     | 154 ++++++---
 net/lnet/klnds/socklnd/socklnd.c        |  47 ++-
 net/lnet/klnds/socklnd/socklnd.h        |  11 +-
 net/lnet/klnds/socklnd/socklnd_cb.c     | 134 ++++----
 net/lnet/klnds/socklnd/socklnd_proto.c  | 307 ++++++++++++++---
 net/lnet/lnet/api-ni.c                  | 168 +++++-----
 net/lnet/lnet/lib-move.c                | 564 ++++++++++++++++----------------
 net/lnet/lnet/lib-msg.c                 |  43 ++-
 net/lnet/lnet/lib-ptl.c                 |   6 +-
 net/lnet/lnet/lo.c                      |   3 +-
 net/lnet/lnet/net_fault.c               |  12 +-
 net/lnet/lnet/nidstrings.c              |   6 +-
 net/lnet/lnet/peer.c                    |  86 +++--
 net/lnet/lnet/router.c                  |  33 +-
 net/lnet/selftest/console.c             |   4 +-
 net/lnet/selftest/rpc.c                 |   6 +-
 72 files changed, 1632 insertions(+), 1072 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
