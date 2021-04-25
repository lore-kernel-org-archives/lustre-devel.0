Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B258FC433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:45 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3788261288
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3788261288
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C1DC621F708;
	Sun, 25 Apr 2021 13:08:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 29FAC21F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 00DC21008484;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E8CD469A63; Sun, 25 Apr 2021 16:08:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:07 -0400
Message-Id: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
Subject: [lustre-devel] [PATCH 00/29] lustre: Update to OpenSFS tree as of
 April 25, 2020
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

Update the Linux lustre client to the lastes OpenSFS tree as of
April 25, 2020. Only thing missing is the fake symlink which needs
more work to make it function with newer kernels.

Andreas Dilger (5):
  lustre: lmv: reduce struct lmv_obd size
  lustre: uapi: remove obsolete ioctls
  lnet: libcfs: fix setting of debug_path
  lustre: osc: fall back to vmalloc for large RPCs
  lustre: misc: limit CDEBUG console message frequency

Arshad Hussain (1):
  lustre: fallocate: Add punch mode to fallocate

Chris Horn (3):
  lnet: o2iblnd: Use REMOTE_DROPPED for ECONNREFUSED
  lnet: Use lr_hops for avoid_asym_router_failure
  lnet: Leverage peer aliveness more efficiently

Lai Siyao (2):
  lustre: mdc: set fid2path RPC interruptible
  lustre: mdt: mkdir should return -EEXIST if exists

Li Dongyang (2):
  lnet: o2iblnd: don't resend if there's no listener
  lnet: obi2lnd: don't try to reconnect if there's no listener

Mikhail Pershin (1):
  lustre: llite: do fallocate() size checks under lock

Mr NeilBrown (10):
  lnet: socklnd: use sockaddr instead of u32 addresses.
  lnet: allow creation of IPv6 socket.
  lnet: allow lnet_connect() to use IPv6 addresses
  lnet: handle possiblity of IPv6 being unavailable.
  lustre: include: remove references to Sun Trademark.
  lustre: lmv: don't include struct lu_qos_rr in client
  lustre: ldlm: discard l_lock from struct ldlm_lock.
  lustre: various: only use wake_up_all() on exclusive waitqs
  lnet: remove references to Sun Trademark.
  lustre: remove references to Sun Trademark.

Serguei Smirnov (2):
  lnet: socklnd: remove tcp bonding
  lnet: socklnd: replace route construct

Wang Shilong (2):
  lustre: readahead: limit over reservation
  lustre: clio: fix hang on urgent cached pages

Yang Sheng (1):
  lustre: uapi: add mdt_hash_name

 fs/lustre/fid/fid_internal.h               |    1 -
 fs/lustre/fid/fid_lib.c                    |    1 -
 fs/lustre/fid/fid_request.c                |    1 -
 fs/lustre/fid/lproc_fid.c                  |    1 -
 fs/lustre/fld/fld_cache.c                  |    1 -
 fs/lustre/fld/fld_internal.h               |    1 -
 fs/lustre/fld/fld_request.c                |    1 -
 fs/lustre/fld/lproc_fld.c                  |    1 -
 fs/lustre/include/cl_object.h              |   18 +-
 fs/lustre/include/lprocfs_status.h         |    1 -
 fs/lustre/include/lu_object.h              |   31 +-
 fs/lustre/include/lustre_acl.h             |    1 -
 fs/lustre/include/lustre_disk.h            |    1 -
 fs/lustre/include/lustre_dlm.h             |   18 +-
 fs/lustre/include/lustre_export.h          |    1 -
 fs/lustre/include/lustre_fid.h             |    1 -
 fs/lustre/include/lustre_fld.h             |    1 -
 fs/lustre/include/lustre_ha.h              |    1 -
 fs/lustre/include/lustre_handles.h         |    2 -
 fs/lustre/include/lustre_import.h          |    2 -
 fs/lustre/include/lustre_intent.h          |    1 -
 fs/lustre/include/lustre_lib.h             |    1 -
 fs/lustre/include/lustre_log.h             |    1 -
 fs/lustre/include/lustre_mdc.h             |    1 -
 fs/lustre/include/lustre_net.h             |    5 +-
 fs/lustre/include/lustre_osc.h             |   11 +-
 fs/lustre/include/lustre_req_layout.h      |    1 -
 fs/lustre/include/lustre_sec.h             |    1 -
 fs/lustre/include/obd.h                    |    1 -
 fs/lustre/include/obd_cksum.h              |    1 -
 fs/lustre/include/obd_class.h              |    1 -
 fs/lustre/include/obd_support.h            |    1 -
 fs/lustre/include/obd_target.h             |    1 -
 fs/lustre/ldlm/l_lock.c                    |   28 +-
 fs/lustre/ldlm/ldlm_extent.c               |    1 -
 fs/lustre/ldlm/ldlm_flock.c                |    1 -
 fs/lustre/ldlm/ldlm_inodebits.c            |    1 -
 fs/lustre/ldlm/ldlm_internal.h             |    1 -
 fs/lustre/ldlm/ldlm_lib.c                  |    1 -
 fs/lustre/ldlm/ldlm_lock.c                 |   35 +-
 fs/lustre/ldlm/ldlm_lockd.c                |   23 +-
 fs/lustre/ldlm/ldlm_plain.c                |    1 -
 fs/lustre/ldlm/ldlm_pool.c                 |    1 -
 fs/lustre/ldlm/ldlm_request.c              |    1 -
 fs/lustre/ldlm/ldlm_resource.c             |   13 +-
 fs/lustre/llite/acl.c                      |    1 -
 fs/lustre/llite/dcache.c                   |    1 -
 fs/lustre/llite/dir.c                      |   15 +-
 fs/lustre/llite/file.c                     |   94 ++-
 fs/lustre/llite/glimpse.c                  |    1 -
 fs/lustre/llite/lcommon_cl.c               |    1 -
 fs/lustre/llite/lcommon_misc.c             |    1 -
 fs/lustre/llite/llite_internal.h           |    1 -
 fs/lustre/llite/llite_lib.c                |    3 +-
 fs/lustre/llite/llite_mmap.c               |    1 -
 fs/lustre/llite/llite_nfs.c                |    1 -
 fs/lustre/llite/lproc_llite.c              |   11 +-
 fs/lustre/llite/namei.c                    |    1 -
 fs/lustre/llite/pcc.c                      |    2 +-
 fs/lustre/llite/rw.c                       |   40 +-
 fs/lustre/llite/rw26.c                     |    1 -
 fs/lustre/llite/statahead.c                |    1 -
 fs/lustre/llite/super25.c                  |    1 -
 fs/lustre/llite/symlink.c                  |    1 -
 fs/lustre/llite/vvp_dev.c                  |    1 -
 fs/lustre/llite/vvp_internal.h             |    1 -
 fs/lustre/llite/vvp_io.c                   |   35 +-
 fs/lustre/llite/vvp_object.c               |    1 -
 fs/lustre/llite/vvp_page.c                 |    1 -
 fs/lustre/llite/xattr.c                    |    1 -
 fs/lustre/lmv/lmv_fld.c                    |    1 -
 fs/lustre/lmv/lmv_intent.c                 |    1 -
 fs/lustre/lmv/lmv_internal.h               |    1 -
 fs/lustre/lmv/lmv_obd.c                    |    1 -
 fs/lustre/lmv/lproc_lmv.c                  |    1 -
 fs/lustre/lov/lov_cl_internal.h            |    2 -
 fs/lustre/lov/lov_dev.c                    |    1 -
 fs/lustre/lov/lov_ea.c                     |    1 -
 fs/lustre/lov/lov_internal.h               |    1 -
 fs/lustre/lov/lov_io.c                     |   86 ++-
 fs/lustre/lov/lov_lock.c                   |    1 -
 fs/lustre/lov/lov_merge.c                  |    1 -
 fs/lustre/lov/lov_obd.c                    |   11 +-
 fs/lustre/lov/lov_object.c                 |    1 -
 fs/lustre/lov/lov_offset.c                 |    1 -
 fs/lustre/lov/lov_pack.c                   |    1 -
 fs/lustre/lov/lov_page.c                   |    1 -
 fs/lustre/lov/lov_pool.c                   |    1 -
 fs/lustre/lov/lov_request.c                |    1 -
 fs/lustre/lov/lovsub_dev.c                 |    1 -
 fs/lustre/lov/lovsub_object.c              |    1 -
 fs/lustre/lov/lproc_lov.c                  |    1 -
 fs/lustre/mdc/lproc_mdc.c                  |    1 -
 fs/lustre/mdc/mdc_changelog.c              |    8 +-
 fs/lustre/mdc/mdc_dev.c                    |   13 +-
 fs/lustre/mdc/mdc_internal.h               |    1 -
 fs/lustre/mdc/mdc_lib.c                    |    6 +-
 fs/lustre/mdc/mdc_locks.c                  |    1 -
 fs/lustre/mdc/mdc_reint.c                  |    1 -
 fs/lustre/mdc/mdc_request.c                |   13 +-
 fs/lustre/mgc/lproc_mgc.c                  |    1 -
 fs/lustre/mgc/mgc_internal.h               |    1 -
 fs/lustre/mgc/mgc_request.c                |    6 +-
 fs/lustre/obdclass/cl_internal.h           |    1 -
 fs/lustre/obdclass/cl_io.c                 |   31 +-
 fs/lustre/obdclass/cl_lock.c               |    1 -
 fs/lustre/obdclass/cl_object.c             |    1 -
 fs/lustre/obdclass/cl_page.c               |    1 -
 fs/lustre/obdclass/class_obd.c             |    1 -
 fs/lustre/obdclass/genops.c                |    1 -
 fs/lustre/obdclass/kernelcomm.c            |    1 -
 fs/lustre/obdclass/llog.c                  |    1 -
 fs/lustre/obdclass/llog_cat.c              |    1 -
 fs/lustre/obdclass/llog_internal.h         |    1 -
 fs/lustre/obdclass/llog_obd.c              |    1 -
 fs/lustre/obdclass/llog_swab.c             |    1 -
 fs/lustre/obdclass/lprocfs_counters.c      |    1 -
 fs/lustre/obdclass/lprocfs_status.c        |    1 -
 fs/lustre/obdclass/lu_object.c             |    3 +-
 fs/lustre/obdclass/lu_ref.c                |    1 -
 fs/lustre/obdclass/lu_tgt_descs.c          |   16 +-
 fs/lustre/obdclass/lu_tgt_pool.c           |    2 -
 fs/lustre/obdclass/lustre_handles.c        |    1 -
 fs/lustre/obdclass/lustre_peer.c           |    1 -
 fs/lustre/obdclass/obd_config.c            |    1 -
 fs/lustre/obdclass/obd_mount.c             |    1 -
 fs/lustre/obdclass/obd_sysfs.c             |    1 -
 fs/lustre/obdclass/obdo.c                  |    1 -
 fs/lustre/obdclass/statfs_pack.c           |    1 -
 fs/lustre/obdecho/debug.c                  |    1 -
 fs/lustre/obdecho/echo_client.c            |    6 +-
 fs/lustre/obdecho/echo_internal.h          |    1 -
 fs/lustre/osc/lproc_osc.c                  |    1 -
 fs/lustre/osc/osc_cache.c                  |    1 -
 fs/lustre/osc/osc_dev.c                    |    1 -
 fs/lustre/osc/osc_internal.h               |    1 -
 fs/lustre/osc/osc_io.c                     |  132 ++--
 fs/lustre/osc/osc_lock.c                   |    1 -
 fs/lustre/osc/osc_object.c                 |    1 -
 fs/lustre/osc/osc_page.c                   |   45 +-
 fs/lustre/osc/osc_request.c                |   18 +-
 fs/lustre/ptlrpc/client.c                  |   44 +-
 fs/lustre/ptlrpc/connection.c              |    1 -
 fs/lustre/ptlrpc/events.c                  |   17 +-
 fs/lustre/ptlrpc/import.c                  |    1 -
 fs/lustre/ptlrpc/layout.c                  |    1 -
 fs/lustre/ptlrpc/llog_client.c             |    1 -
 fs/lustre/ptlrpc/llog_net.c                |    1 -
 fs/lustre/ptlrpc/lproc_ptlrpc.c            |    1 -
 fs/lustre/ptlrpc/niobuf.c                  |    1 -
 fs/lustre/ptlrpc/pack_generic.c            |    1 -
 fs/lustre/ptlrpc/pers.c                    |    1 -
 fs/lustre/ptlrpc/pinger.c                  |    1 -
 fs/lustre/ptlrpc/ptlrpc_internal.h         |    1 -
 fs/lustre/ptlrpc/ptlrpc_module.c           |    1 -
 fs/lustre/ptlrpc/ptlrpcd.c                 |    1 -
 fs/lustre/ptlrpc/recover.c                 |    1 -
 fs/lustre/ptlrpc/sec.c                     |    1 -
 fs/lustre/ptlrpc/sec_bulk.c                |    3 +-
 fs/lustre/ptlrpc/sec_config.c              |    1 -
 fs/lustre/ptlrpc/sec_gc.c                  |    1 -
 fs/lustre/ptlrpc/sec_lproc.c               |    1 -
 fs/lustre/ptlrpc/sec_null.c                |    1 -
 fs/lustre/ptlrpc/sec_plain.c               |    1 -
 fs/lustre/ptlrpc/service.c                 |    3 +-
 fs/lustre/ptlrpc/wiretest.c                |    1 -
 include/linux/libcfs/libcfs_debug.h        |    2 +-
 include/linux/lnet/lib-lnet.h              |   24 +-
 include/linux/lnet/lib-types.h             |    7 +-
 include/uapi/linux/lnet/libcfs_debug.h     |    1 -
 include/uapi/linux/lnet/libcfs_ioctl.h     |    1 -
 include/uapi/linux/lnet/lnet-dlc.h         |    5 +-
 include/uapi/linux/lnet/lnet-idl.h         |    1 -
 include/uapi/linux/lnet/socklnd.h          |    1 -
 include/uapi/linux/lustre/lustre_cfg.h     |    1 -
 include/uapi/linux/lustre/lustre_fiemap.h  |    1 -
 include/uapi/linux/lustre/lustre_idl.h     |    3 +-
 include/uapi/linux/lustre/lustre_ioctl.h   |   28 +-
 include/uapi/linux/lustre/lustre_param.h   |    1 -
 include/uapi/linux/lustre/lustre_user.h    |   13 +-
 net/lnet/klnds/o2iblnd/o2iblnd-idl.h       |    1 -
 net/lnet/klnds/o2iblnd/o2iblnd.c           |   21 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h           |    3 -
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        |   41 +-
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c |    1 -
 net/lnet/klnds/socklnd/socklnd.c           | 1123 ++++++++--------------------
 net/lnet/klnds/socklnd/socklnd.h           |   53 +-
 net/lnet/klnds/socklnd/socklnd_cb.c        |  320 ++++----
 net/lnet/klnds/socklnd/socklnd_lib.c       |    8 +-
 net/lnet/klnds/socklnd/socklnd_proto.c     |   52 +-
 net/lnet/libcfs/debug.c                    |   18 +-
 net/lnet/lnet/acceptor.c                   |  115 ++-
 net/lnet/lnet/api-ni.c                     |   59 +-
 net/lnet/lnet/config.c                     |   59 +-
 net/lnet/lnet/lib-md.c                     |    1 -
 net/lnet/lnet/lib-me.c                     |    1 -
 net/lnet/lnet/lib-move.c                   |   38 +-
 net/lnet/lnet/lib-msg.c                    |    1 -
 net/lnet/lnet/lib-ptl.c                    |    1 -
 net/lnet/lnet/lib-socket.c                 |  113 ++-
 net/lnet/lnet/lo.c                         |    1 -
 net/lnet/lnet/module.c                     |    1 -
 net/lnet/lnet/nidstrings.c                 |    1 -
 net/lnet/lnet/peer.c                       |    3 +-
 net/lnet/lnet/router.c                     |   39 +-
 net/lnet/selftest/brw_test.c               |    1 -
 net/lnet/selftest/conctl.c                 |    1 -
 net/lnet/selftest/conrpc.c                 |    1 -
 net/lnet/selftest/conrpc.h                 |    1 -
 net/lnet/selftest/console.c                |    1 -
 net/lnet/selftest/console.h                |    1 -
 net/lnet/selftest/framework.c              |    1 -
 net/lnet/selftest/module.c                 |    1 -
 net/lnet/selftest/ping_test.c              |    1 -
 net/lnet/selftest/rpc.c                    |    1 -
 net/lnet/selftest/rpc.h                    |    1 -
 net/lnet/selftest/selftest.h               |    1 -
 net/lnet/selftest/timer.c                  |    1 -
 net/lnet/selftest/timer.h                  |    1 -
 219 files changed, 1369 insertions(+), 1787 deletions(-)

-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
