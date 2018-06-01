From: Andreas Dilger <adilger@dilger.ca>
Date: Fri, 1 Jun 2018 14:30:49 -0400
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <20180601091133.GA27521@kroah.com>
References: <20180601091133.GA27521@kroah.com>
Message-ID: <6A5E4E02-AE72-4068-BF93-38791BF38B4F@dilger.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linuxfoundation.org>, lustre-devel <lustre-devel@lists.lustre.org>, fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, selinux@tycho.nsa.gov

On Jun 1, 2018, at 5:11 AM, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> The Lustre filesystem has been in the kernel tree for over 5 years now.
> While it has been an endless source of enjoyment for new kernel
> developers learning how to do basic codingstyle cleanups, as well as an
> semi-entertaining source of bewilderment from the vfs developers any
> time they have looked into the codebase to try to figure out how to port
> their latest api changes to this filesystem, it has not really moved
> forward into the "this is in shape to get out of staging" despite many
> half-completed attempts.

I am happy to submit a patch that moves Lustre out of staging and into
the mainline.  I'm just about to board a flight, but it could be done
later today.  Then we can avoid the constant churn of kernel newbies
submitting patches that break the code.

Lustre has been in use at large sites around the world for 18 years now.
Over 70% of the largest 100 systems in the world use Lustre.  It runs at
universities, oil companies, weather bureaus around the world, etc.

I know Andrew has long been a supporter of getting code into the kernel
that users are using.  This is code that thousands of large computers
are using with exabytes of storage, a lot more than orangefs, exofs, and
random other filesystems that seem to get into the kernel easily.

It's true the code is not as pretty as it could be, but the same is true
of code that has been in the kernel for ages.  We've spent years cleaning
it up in staging, and it has gotten a lot better.  Getting the client into
the mainline kernel will accelerate the development and cleanup, and
Christoph will no longer be able to submit patches that break the code
because it is only in staging.  This will also (finally) allow us to get
this code in sync with the out-of-tree code and converge on a single tree.

Cheers, Andreas

> And getting code out of staging is the main goal of that portion of the
> kernel tree.  Code should not stagnate and it feels like having this
> code in staging is only causing the development cycle of the filesystem
> to take longer than it should.  There is a whole separate out-of-tree
> copy of this codebase where the developers work on it, and then random
> changes are thrown over the wall at staging at some later point in time.
> This dual-tree development model has never worked, and the state of this
> codebase is proof of that.
> 
> So, let's just delete the whole mess.  Now the lustre developers can go
> off and work in their out-of-tree codebase and not have to worry about
> providing valid changelog entries and breaking their patches up into
> logical pieces.  They can take the time they have spend doing those
> types of housekeeping chores and get the codebase into a much better
> shape, and it can be submitted for inclusion into the real part of the
> kernel tree when ready.
> 
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> MAINTAINERS                                   |    9 -
> drivers/staging/Kconfig                       |    2 -
> drivers/staging/Makefile                      |    1 -
> drivers/staging/lustre/Kconfig                |    3 -
> drivers/staging/lustre/Makefile               |    2 -
> drivers/staging/lustre/README.txt             |   83 -
> drivers/staging/lustre/TODO                   |  302 --
> .../lustre/include/linux/libcfs/libcfs.h      |   76 -
> .../lustre/include/linux/libcfs/libcfs_cpu.h  |  434 --
> .../include/linux/libcfs/libcfs_crypto.h      |  208 -
> .../include/linux/libcfs/libcfs_debug.h       |  207 -
> .../lustre/include/linux/libcfs/libcfs_fail.h |  194 -
> .../lustre/include/linux/libcfs/libcfs_hash.h |  869 ----
> .../include/linux/libcfs/libcfs_private.h     |  200 -
> .../include/linux/libcfs/libcfs_string.h      |  102 -
> .../staging/lustre/include/linux/lnet/api.h   |  212 -
> .../lustre/include/linux/lnet/lib-lnet.h      |  652 ---
> .../lustre/include/linux/lnet/lib-types.h     |  666 ---
> .../lustre/include/linux/lnet/socklnd.h       |   87 -
> .../include/uapi/linux/lnet/libcfs_debug.h    |  149 -
> .../include/uapi/linux/lnet/libcfs_ioctl.h    |  141 -
> .../lustre/include/uapi/linux/lnet/lnet-dlc.h |  150 -
> .../include/uapi/linux/lnet/lnet-types.h      |  669 ---
> .../lustre/include/uapi/linux/lnet/lnetctl.h  |  123 -
> .../lustre/include/uapi/linux/lnet/lnetst.h   |  556 ---
> .../lustre/include/uapi/linux/lnet/nidstr.h   |  119 -
> .../lustre/include/uapi/linux/lnet/socklnd.h  |   44 -
> .../include/uapi/linux/lustre/lustre_cfg.h    |  261 -
> .../include/uapi/linux/lustre/lustre_fid.h    |  293 --
> .../include/uapi/linux/lustre/lustre_fiemap.h |   72 -
> .../include/uapi/linux/lustre/lustre_idl.h    | 2690 -----------
> .../include/uapi/linux/lustre/lustre_ioctl.h  |  229 -
> .../uapi/linux/lustre/lustre_kernelcomm.h     |   94 -
> .../include/uapi/linux/lustre/lustre_ostid.h  |  236 -
> .../include/uapi/linux/lustre/lustre_param.h  |   94 -
> .../include/uapi/linux/lustre/lustre_user.h   | 1327 ------
> .../include/uapi/linux/lustre/lustre_ver.h    |   27 -
> drivers/staging/lustre/lnet/Kconfig           |   46 -
> drivers/staging/lustre/lnet/Makefile          |    1 -
> drivers/staging/lustre/lnet/klnds/Makefile    |    1 -
> .../lustre/lnet/klnds/o2iblnd/Makefile        |    5 -
> .../lustre/lnet/klnds/o2iblnd/o2iblnd.c       | 2958 ------------
> .../lustre/lnet/klnds/o2iblnd/o2iblnd.h       | 1048 ----
> .../lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c    | 3763 ---------------
> .../lnet/klnds/o2iblnd/o2iblnd_modparams.c    |  296 --
> .../lustre/lnet/klnds/socklnd/Makefile        |    6 -
> .../lustre/lnet/klnds/socklnd/socklnd.c       | 2921 ------------
> .../lustre/lnet/klnds/socklnd/socklnd.h       |  704 ---
> .../lustre/lnet/klnds/socklnd/socklnd_cb.c    | 2586 ----------
> .../lustre/lnet/klnds/socklnd/socklnd_lib.c   |  534 ---
> .../lnet/klnds/socklnd/socklnd_modparams.c    |  184 -
> .../lustre/lnet/klnds/socklnd/socklnd_proto.c |  810 ----
> drivers/staging/lustre/lnet/libcfs/Makefile   |   16 -
> drivers/staging/lustre/lnet/libcfs/debug.c    |  461 --
> drivers/staging/lustre/lnet/libcfs/fail.c     |  146 -
> drivers/staging/lustre/lnet/libcfs/hash.c     | 2065 --------
> .../staging/lustre/lnet/libcfs/libcfs_cpu.c   | 1086 -----
> .../staging/lustre/lnet/libcfs/libcfs_lock.c  |  155 -
> .../staging/lustre/lnet/libcfs/libcfs_mem.c   |  171 -
> .../lustre/lnet/libcfs/libcfs_string.c        |  562 ---
> .../lustre/lnet/libcfs/linux-crypto-adler.c   |  139 -
> .../staging/lustre/lnet/libcfs/linux-crypto.c |  447 --
> .../staging/lustre/lnet/libcfs/linux-crypto.h |   30 -
> .../staging/lustre/lnet/libcfs/linux-debug.c  |  142 -
> .../lustre/lnet/libcfs/linux-tracefile.c      |  258 -
> drivers/staging/lustre/lnet/libcfs/module.c   |  758 ---
> .../staging/lustre/lnet/libcfs/tracefile.c    | 1198 -----
> .../staging/lustre/lnet/libcfs/tracefile.h    |  274 --
> drivers/staging/lustre/lnet/lnet/Makefile     |   10 -
> drivers/staging/lustre/lnet/lnet/acceptor.c   |  501 --
> drivers/staging/lustre/lnet/lnet/api-ni.c     | 2307 ---------
> drivers/staging/lustre/lnet/lnet/config.c     | 1235 -----
> drivers/staging/lustre/lnet/lnet/lib-eq.c     |  426 --
> drivers/staging/lustre/lnet/lnet/lib-md.c     |  463 --
> drivers/staging/lustre/lnet/lnet/lib-me.c     |  274 --
> drivers/staging/lustre/lnet/lnet/lib-move.c   | 2386 ----------
> drivers/staging/lustre/lnet/lnet/lib-msg.c    |  625 ---
> drivers/staging/lustre/lnet/lnet/lib-ptl.c    |  987 ----
> drivers/staging/lustre/lnet/lnet/lib-socket.c |  585 ---
> drivers/staging/lustre/lnet/lnet/lo.c         |  105 -
> drivers/staging/lustre/lnet/lnet/module.c     |  239 -
> drivers/staging/lustre/lnet/lnet/net_fault.c  | 1023 ----
> drivers/staging/lustre/lnet/lnet/nidstrings.c | 1261 -----
> drivers/staging/lustre/lnet/lnet/peer.c       |  456 --
> drivers/staging/lustre/lnet/lnet/router.c     | 1799 -------
> .../staging/lustre/lnet/lnet/router_proc.c    |  907 ----
> drivers/staging/lustre/lnet/selftest/Makefile |    7 -
> .../staging/lustre/lnet/selftest/brw_test.c   |  526 --
> drivers/staging/lustre/lnet/selftest/conctl.c |  801 ----
> drivers/staging/lustre/lnet/selftest/conrpc.c | 1396 ------
> drivers/staging/lustre/lnet/selftest/conrpc.h |  142 -
> .../staging/lustre/lnet/selftest/console.c    | 2104 --------
> .../staging/lustre/lnet/selftest/console.h    |  244 -
> .../staging/lustre/lnet/selftest/framework.c  | 1786 -------
> drivers/staging/lustre/lnet/selftest/module.c |  169 -
> .../staging/lustre/lnet/selftest/ping_test.c  |  228 -
> drivers/staging/lustre/lnet/selftest/rpc.c    | 1682 -------
> drivers/staging/lustre/lnet/selftest/rpc.h    |  295 --
> .../staging/lustre/lnet/selftest/selftest.h   |  622 ---
> drivers/staging/lustre/lnet/selftest/timer.c  |  244 -
> drivers/staging/lustre/lnet/selftest/timer.h  |   50 -
> drivers/staging/lustre/lustre/Kconfig         |   45 -
> drivers/staging/lustre/lustre/Makefile        |    2 -
> drivers/staging/lustre/lustre/fid/Makefile    |    5 -
> .../staging/lustre/lustre/fid/fid_internal.h  |   46 -
> drivers/staging/lustre/lustre/fid/fid_lib.c   |   87 -
> .../staging/lustre/lustre/fid/fid_request.c   |  410 --
> drivers/staging/lustre/lustre/fid/lproc_fid.c |  225 -
> drivers/staging/lustre/lustre/fld/Makefile    |    5 -
> drivers/staging/lustre/lustre/fld/fld_cache.c |  516 --
> .../staging/lustre/lustre/fld/fld_internal.h  |  170 -
> .../staging/lustre/lustre/fld/fld_request.c   |  446 --
> drivers/staging/lustre/lustre/fld/lproc_fld.c |  154 -
> .../staging/lustre/lustre/include/cl_object.h | 2463 ----------
> .../lustre/lustre/include/interval_tree.h     |  119 -
> .../staging/lustre/lustre/include/llog_swab.h |   67 -
> .../lustre/lustre/include/lprocfs_status.h    |  646 ---
> .../staging/lustre/lustre/include/lu_object.h | 1305 -----
> .../staging/lustre/lustre/include/lu_ref.h    |  178 -
> .../lustre/lustre/include/lustre_acl.h        |   51 -
> .../lustre/lustre/include/lustre_compat.h     |   82 -
> .../lustre/lustre/include/lustre_debug.h      |   52 -
> .../lustre/lustre/include/lustre_disk.h       |  152 -
> .../lustre/lustre/include/lustre_dlm.h        | 1346 ------
> .../lustre/lustre/include/lustre_dlm_flags.h  |  402 --
> .../lustre/lustre/include/lustre_errno.h      |  198 -
> .../lustre/lustre/include/lustre_export.h     |  250 -
> .../lustre/lustre/include/lustre_fid.h        |  676 ---
> .../lustre/lustre/include/lustre_fld.h        |  137 -
> .../staging/lustre/lustre/include/lustre_ha.h |   61 -
> .../lustre/lustre/include/lustre_handles.h    |   91 -
> .../lustre/lustre/include/lustre_import.h     |  369 --
> .../lustre/lustre/include/lustre_intent.h     |   71 -
> .../lustre/lustre/include/lustre_kernelcomm.h |   56 -
> .../lustre/lustre/include/lustre_lib.h        |  126 -
> .../lustre/lustre/include/lustre_linkea.h     |   93 -
> .../lustre/lustre/include/lustre_lmv.h        |  174 -
> .../lustre/lustre/include/lustre_log.h        |  382 --
> .../lustre/lustre/include/lustre_mdc.h        |  229 -
> .../lustre/lustre/include/lustre_mds.h        |   62 -
> .../lustre/lustre/include/lustre_net.h        | 2360 ---------
> .../lustre/lustre/include/lustre_nrs.h        |  718 ---
> .../lustre/lustre/include/lustre_nrs_fifo.h   |   71 -
> .../lustre/lustre/include/lustre_obdo.h       |   55 -
> .../lustre/include/lustre_patchless_compat.h  |   68 -
> .../lustre/lustre/include/lustre_req_layout.h |  307 --
> .../lustre/lustre/include/lustre_sec.h        | 1072 -----
> .../lustre/lustre/include/lustre_swab.h       |  109 -
> drivers/staging/lustre/lustre/include/obd.h   | 1114 -----
> .../staging/lustre/lustre/include/obd_cksum.h |  153 -
> .../staging/lustre/lustre/include/obd_class.h | 1603 -------
> .../lustre/lustre/include/obd_support.h       |  517 --
> .../staging/lustre/lustre/include/seq_range.h |  200 -
> .../lustre/lustre/ldlm/interval_tree.c        |  599 ---
> drivers/staging/lustre/lustre/ldlm/l_lock.c   |   73 -
> .../staging/lustre/lustre/ldlm/ldlm_extent.c  |  258 -
> .../staging/lustre/lustre/ldlm/ldlm_flock.c   |  486 --
> .../lustre/lustre/ldlm/ldlm_inodebits.c       |   69 -
> .../lustre/lustre/ldlm/ldlm_internal.h        |  342 --
> drivers/staging/lustre/lustre/ldlm/ldlm_lib.c |  842 ----
> .../staging/lustre/lustre/ldlm/ldlm_lock.c    | 2135 ---------
> .../staging/lustre/lustre/ldlm/ldlm_lockd.c   | 1163 -----
> .../staging/lustre/lustre/ldlm/ldlm_plain.c   |   68 -
> .../staging/lustre/lustre/ldlm/ldlm_pool.c    | 1013 ----
> .../staging/lustre/lustre/ldlm/ldlm_request.c | 2033 --------
> .../lustre/lustre/ldlm/ldlm_resource.c        | 1318 ------
> drivers/staging/lustre/lustre/llite/Makefile  |   13 -
> drivers/staging/lustre/lustre/llite/acl.c     |  108 -
> drivers/staging/lustre/lustre/llite/dcache.c  |  300 --
> drivers/staging/lustre/lustre/llite/dir.c     | 1708 -------
> drivers/staging/lustre/lustre/llite/file.c    | 3580 --------------
> drivers/staging/lustre/lustre/llite/glimpse.c |  205 -
> .../staging/lustre/lustre/llite/lcommon_cl.c  |  292 --
> .../lustre/lustre/llite/lcommon_misc.c        |  186 -
> .../lustre/lustre/llite/llite_internal.h      | 1344 ------
> .../staging/lustre/lustre/llite/llite_lib.c   | 2668 -----------
> .../staging/lustre/lustre/llite/llite_mmap.c  |  480 --
> .../staging/lustre/lustre/llite/llite_nfs.c   |  375 --
> .../staging/lustre/lustre/llite/lproc_llite.c | 1659 -------
> drivers/staging/lustre/lustre/llite/namei.c   | 1207 -----
> .../staging/lustre/lustre/llite/range_lock.c  |  241 -
> .../staging/lustre/lustre/llite/range_lock.h  |   83 -
> drivers/staging/lustre/lustre/llite/rw.c      | 1214 -----
> drivers/staging/lustre/lustre/llite/rw26.c    |  641 ---
> .../staging/lustre/lustre/llite/statahead.c   | 1577 ------
> drivers/staging/lustre/lustre/llite/super25.c |  189 -
> drivers/staging/lustre/lustre/llite/symlink.c |  159 -
> drivers/staging/lustre/lustre/llite/vvp_dev.c |  640 ---
> .../lustre/lustre/llite/vvp_internal.h        |  321 --
> drivers/staging/lustre/lustre/llite/vvp_io.c  | 1374 ------
> .../staging/lustre/lustre/llite/vvp_lock.c    |   87 -
> .../staging/lustre/lustre/llite/vvp_object.c  |  303 --
> .../staging/lustre/lustre/llite/vvp_page.c    |  523 --
> drivers/staging/lustre/lustre/llite/xattr.c   |  665 ---
> .../staging/lustre/lustre/llite/xattr_cache.c |  504 --
> .../lustre/lustre/llite/xattr_security.c      |   96 -
> drivers/staging/lustre/lustre/lmv/Makefile    |    5 -
> drivers/staging/lustre/lustre/lmv/lmv_fld.c   |   82 -
> .../staging/lustre/lustre/lmv/lmv_intent.c    |  521 --
> .../staging/lustre/lustre/lmv/lmv_internal.h  |  164 -
> drivers/staging/lustre/lustre/lmv/lmv_obd.c   | 3131 ------------
> drivers/staging/lustre/lustre/lmv/lproc_lmv.c |  173 -
> drivers/staging/lustre/lustre/lov/Makefile    |    9 -
> .../lustre/lustre/lov/lov_cl_internal.h       |  639 ---
> drivers/staging/lustre/lustre/lov/lov_dev.c   |  384 --
> drivers/staging/lustre/lustre/lov/lov_ea.c    |  331 --
> .../staging/lustre/lustre/lov/lov_internal.h  |  286 --
> drivers/staging/lustre/lustre/lov/lov_io.c    | 1023 ----
> drivers/staging/lustre/lustre/lov/lov_lock.c  |  348 --
> drivers/staging/lustre/lustre/lov/lov_merge.c |  105 -
> drivers/staging/lustre/lustre/lov/lov_obd.c   | 1444 ------
> .../staging/lustre/lustre/lov/lov_object.c    | 1625 -------
> .../staging/lustre/lustre/lov/lov_offset.c    |  269 --
> drivers/staging/lustre/lustre/lov/lov_pack.c  |  400 --
> drivers/staging/lustre/lustre/lov/lov_page.c  |  136 -
> drivers/staging/lustre/lustre/lov/lov_pool.c  |  546 ---
> .../staging/lustre/lustre/lov/lov_request.c   |  354 --
> .../staging/lustre/lustre/lov/lovsub_dev.c    |  147 -
> .../staging/lustre/lustre/lov/lovsub_lock.c   |   81 -
> .../staging/lustre/lustre/lov/lovsub_object.c |  180 -
> .../staging/lustre/lustre/lov/lovsub_page.c   |   68 -
> drivers/staging/lustre/lustre/lov/lproc_lov.c |  299 --
> drivers/staging/lustre/lustre/mdc/Makefile    |    5 -
> drivers/staging/lustre/lustre/mdc/lproc_mdc.c |  231 -
> .../staging/lustre/lustre/mdc/mdc_internal.h  |  144 -
> drivers/staging/lustre/lustre/mdc/mdc_lib.c   |  498 --
> drivers/staging/lustre/lustre/mdc/mdc_locks.c | 1239 -----
> drivers/staging/lustre/lustre/mdc/mdc_reint.c |  421 --
> .../staging/lustre/lustre/mdc/mdc_request.c   | 2770 -----------
> drivers/staging/lustre/lustre/mgc/Makefile    |    5 -
> drivers/staging/lustre/lustre/mgc/lproc_mgc.c |   69 -
> .../staging/lustre/lustre/mgc/mgc_internal.h  |   57 -
> .../staging/lustre/lustre/mgc/mgc_request.c   | 1851 --------
> .../staging/lustre/lustre/obdclass/Makefile   |   12 -
> .../lustre/lustre/obdclass/cl_internal.h      |   95 -
> .../staging/lustre/lustre/obdclass/cl_io.c    | 1151 -----
> .../staging/lustre/lustre/obdclass/cl_lock.c  |  275 --
> .../lustre/lustre/obdclass/cl_object.c        | 1059 -----
> .../staging/lustre/lustre/obdclass/cl_page.c  | 1045 ----
> .../lustre/lustre/obdclass/class_obd.c        |  544 ---
> .../staging/lustre/lustre/obdclass/debug.c    |   96 -
> .../staging/lustre/lustre/obdclass/genops.c   | 1480 ------
> .../lustre/lustre/obdclass/kernelcomm.c       |  240 -
> .../staging/lustre/lustre/obdclass/linkea.c   |  249 -
> .../lustre/obdclass/linux/linux-module.c      |  514 --
> .../lustre/obdclass/linux/linux-sysctl.c      |  162 -
> drivers/staging/lustre/lustre/obdclass/llog.c |  524 --
> .../staging/lustre/lustre/obdclass/llog_cat.c |  236 -
> .../lustre/lustre/obdclass/llog_internal.h    |   79 -
> .../staging/lustre/lustre/obdclass/llog_obd.c |  225 -
> .../lustre/lustre/obdclass/llog_swab.c        |  412 --
> .../lustre/lustre/obdclass/lprocfs_counters.c |  134 -
> .../lustre/lustre/obdclass/lprocfs_status.c   | 1698 -------
> .../lustre/lustre/obdclass/lu_object.c        | 2056 --------
> .../staging/lustre/lustre/obdclass/lu_ref.c   |   45 -
> .../lustre/lustre/obdclass/lustre_handles.c   |  241 -
> .../lustre/lustre/obdclass/lustre_peer.c      |  214 -
> .../lustre/lustre/obdclass/obd_config.c       | 1538 ------
> .../lustre/lustre/obdclass/obd_mount.c        | 1245 -----
> drivers/staging/lustre/lustre/obdclass/obdo.c |  181 -
> .../lustre/lustre/obdclass/statfs_pack.c      |   58 -
> drivers/staging/lustre/lustre/obdclass/uuid.c |   45 -
> .../staging/lustre/lustre/obdecho/Makefile    |    5 -
> .../lustre/lustre/obdecho/echo_client.c       | 1729 -------
> .../lustre/lustre/obdecho/echo_internal.h     |   42 -
> drivers/staging/lustre/lustre/osc/Makefile    |    6 -
> drivers/staging/lustre/lustre/osc/lproc_osc.c |  838 ----
> drivers/staging/lustre/lustre/osc/osc_cache.c | 3306 -------------
> .../lustre/lustre/osc/osc_cl_internal.h       |  681 ---
> drivers/staging/lustre/lustre/osc/osc_dev.c   |  246 -
> .../staging/lustre/lustre/osc/osc_internal.h  |  237 -
> drivers/staging/lustre/lustre/osc/osc_io.c    |  918 ----
> drivers/staging/lustre/lustre/osc/osc_lock.c  | 1230 -----
> .../staging/lustre/lustre/osc/osc_object.c    |  473 --
> drivers/staging/lustre/lustre/osc/osc_page.c  | 1094 -----
> drivers/staging/lustre/lustre/osc/osc_quota.c |  236 -
> .../staging/lustre/lustre/osc/osc_request.c   | 2907 ------------
> drivers/staging/lustre/lustre/ptlrpc/Makefile |   23 -
> drivers/staging/lustre/lustre/ptlrpc/client.c | 3271 -------------
> .../staging/lustre/lustre/ptlrpc/connection.c |  192 -
> drivers/staging/lustre/lustre/ptlrpc/errno.c  |  383 --
> drivers/staging/lustre/lustre/ptlrpc/events.c |  585 ---
> drivers/staging/lustre/lustre/ptlrpc/import.c | 1677 -------
> drivers/staging/lustre/lustre/ptlrpc/layout.c | 2232 ---------
> .../lustre/lustre/ptlrpc/llog_client.c        |  338 --
> .../staging/lustre/lustre/ptlrpc/llog_net.c   |   67 -
> .../lustre/lustre/ptlrpc/lproc_ptlrpc.c       | 1316 ------
> drivers/staging/lustre/lustre/ptlrpc/niobuf.c |  771 ---
> drivers/staging/lustre/lustre/ptlrpc/nrs.c    | 1613 -------
> .../staging/lustre/lustre/ptlrpc/nrs_fifo.c   |  270 --
> .../lustre/lustre/ptlrpc/pack_generic.c       | 2311 ---------
> drivers/staging/lustre/lustre/ptlrpc/pers.c   |   72 -
> drivers/staging/lustre/lustre/ptlrpc/pinger.c |  474 --
> .../lustre/lustre/ptlrpc/ptlrpc_internal.h    |  371 --
> .../lustre/lustre/ptlrpc/ptlrpc_module.c      |  186 -
> .../staging/lustre/lustre/ptlrpc/ptlrpcd.c    |  914 ----
> .../staging/lustre/lustre/ptlrpc/recover.c    |  374 --
> drivers/staging/lustre/lustre/ptlrpc/sec.c    | 2379 ----------
> .../staging/lustre/lustre/ptlrpc/sec_bulk.c   |  572 ---
> .../staging/lustre/lustre/ptlrpc/sec_config.c |  850 ----
> drivers/staging/lustre/lustre/ptlrpc/sec_gc.c |  190 -
> .../staging/lustre/lustre/ptlrpc/sec_lproc.c  |  170 -
> .../staging/lustre/lustre/ptlrpc/sec_null.c   |  459 --
> .../staging/lustre/lustre/ptlrpc/sec_plain.c  | 1023 ----
> .../staging/lustre/lustre/ptlrpc/service.c    | 2807 -----------
> .../staging/lustre/lustre/ptlrpc/wiretest.c   | 4210 -----------------
> drivers/staging/lustre/sysfs-fs-lustre        |  654 ---
> scripts/selinux/mdp/mdp.c                     |    1 -
> 308 files changed, 195272 deletions(-)
> delete mode 100644 drivers/staging/lustre/Kconfig
> delete mode 100644 drivers/staging/lustre/Makefile
> delete mode 100644 drivers/staging/lustre/README.txt
> delete mode 100644 drivers/staging/lustre/TODO
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> delete mode 100644 drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
> delete mode 100644 drivers/staging/lustre/include/linux/lnet/api.h
> delete mode 100644 drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> delete mode 100644 drivers/staging/lustre/include/linux/lnet/lib-types.h
> delete mode 100644 drivers/staging/lustre/include/linux/lnet/socklnd.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
> delete mode 100644 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
> delete mode 100644 drivers/staging/lustre/lnet/Kconfig
> delete mode 100644 drivers/staging/lustre/lnet/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/klnds/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> delete mode 100644 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> delete mode 100644 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/debug.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/fail.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/hash.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-crypto.h
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-debug.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/module.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/tracefile.c
> delete mode 100644 drivers/staging/lustre/lnet/libcfs/tracefile.h
> delete mode 100644 drivers/staging/lustre/lnet/lnet/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/lnet/acceptor.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/api-ni.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/config.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-eq.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-md.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-me.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-move.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-msg.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-ptl.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lib-socket.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/lo.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/module.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/net_fault.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/nidstrings.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/peer.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/router.c
> delete mode 100644 drivers/staging/lustre/lnet/lnet/router_proc.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/Makefile
> delete mode 100644 drivers/staging/lustre/lnet/selftest/brw_test.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/conctl.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/conrpc.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/conrpc.h
> delete mode 100644 drivers/staging/lustre/lnet/selftest/console.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/console.h
> delete mode 100644 drivers/staging/lustre/lnet/selftest/framework.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/module.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/ping_test.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/rpc.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/rpc.h
> delete mode 100644 drivers/staging/lustre/lnet/selftest/selftest.h
> delete mode 100644 drivers/staging/lustre/lnet/selftest/timer.c
> delete mode 100644 drivers/staging/lustre/lnet/selftest/timer.h
> delete mode 100644 drivers/staging/lustre/lustre/Kconfig
> delete mode 100644 drivers/staging/lustre/lustre/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/fid/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/fid/fid_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/fid/fid_lib.c
> delete mode 100644 drivers/staging/lustre/lustre/fid/fid_request.c
> delete mode 100644 drivers/staging/lustre/lustre/fid/lproc_fid.c
> delete mode 100644 drivers/staging/lustre/lustre/fld/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/fld/fld_cache.c
> delete mode 100644 drivers/staging/lustre/lustre/fld/fld_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/fld/fld_request.c
> delete mode 100644 drivers/staging/lustre/lustre/fld/lproc_fld.c
> delete mode 100644 drivers/staging/lustre/lustre/include/cl_object.h
> delete mode 100644 drivers/staging/lustre/lustre/include/interval_tree.h
> delete mode 100644 drivers/staging/lustre/lustre/include/llog_swab.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lprocfs_status.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lu_object.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lu_ref.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_acl.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_compat.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_debug.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_disk.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_dlm.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_errno.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_export.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_fid.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_fld.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_ha.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_handles.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_import.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_intent.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_lib.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_linkea.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_lmv.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_log.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_mdc.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_mds.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_net.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_nrs.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_obdo.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_req_layout.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_sec.h
> delete mode 100644 drivers/staging/lustre/lustre/include/lustre_swab.h
> delete mode 100644 drivers/staging/lustre/lustre/include/obd.h
> delete mode 100644 drivers/staging/lustre/lustre/include/obd_cksum.h
> delete mode 100644 drivers/staging/lustre/lustre/include/obd_class.h
> delete mode 100644 drivers/staging/lustre/lustre/include/obd_support.h
> delete mode 100644 drivers/staging/lustre/lustre/include/seq_range.h
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/interval_tree.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/l_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> delete mode 100644 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/llite/acl.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/dcache.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/dir.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/file.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/glimpse.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/lcommon_cl.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/lcommon_misc.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/llite_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/llite/llite_lib.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/llite_mmap.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/llite_nfs.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/lproc_llite.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/namei.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.h
> delete mode 100644 drivers/staging/lustre/lustre/llite/rw.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/rw26.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/statahead.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/super25.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/symlink.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_dev.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_io.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_object.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/vvp_page.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/xattr.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/xattr_cache.c
> delete mode 100644 drivers/staging/lustre/lustre/llite/xattr_security.c
> delete mode 100644 drivers/staging/lustre/lustre/lmv/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/lmv/lmv_fld.c
> delete mode 100644 drivers/staging/lustre/lustre/lmv/lmv_intent.c
> delete mode 100644 drivers/staging/lustre/lustre/lmv/lmv_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/lmv/lmv_obd.c
> delete mode 100644 drivers/staging/lustre/lustre/lmv/lproc_lmv.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_cl_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_dev.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_ea.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_io.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_merge.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_obd.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_object.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_offset.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_pack.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_page.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_pool.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lov_request.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lovsub_dev.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lovsub_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lovsub_object.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lovsub_page.c
> delete mode 100644 drivers/staging/lustre/lustre/lov/lproc_lov.c
> delete mode 100644 drivers/staging/lustre/lustre/mdc/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/mdc/lproc_mdc.c
> delete mode 100644 drivers/staging/lustre/lustre/mdc/mdc_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/mdc/mdc_lib.c
> delete mode 100644 drivers/staging/lustre/lustre/mdc/mdc_locks.c
> delete mode 100644 drivers/staging/lustre/lustre/mdc/mdc_reint.c
> delete mode 100644 drivers/staging/lustre/lustre/mdc/mdc_request.c
> delete mode 100644 drivers/staging/lustre/lustre/mgc/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/mgc/lproc_mgc.c
> delete mode 100644 drivers/staging/lustre/lustre/mgc/mgc_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/mgc/mgc_request.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/cl_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/cl_io.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/cl_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/cl_object.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/cl_page.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/class_obd.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/debug.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/genops.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/kernelcomm.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/linkea.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/llog.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/llog_cat.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/llog_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/llog_obd.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/llog_swab.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/lu_object.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/lu_ref.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/lustre_peer.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/obd_config.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/obd_mount.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/obdo.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/statfs_pack.c
> delete mode 100644 drivers/staging/lustre/lustre/obdclass/uuid.c
> delete mode 100644 drivers/staging/lustre/lustre/obdecho/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/obdecho/echo_client.c
> delete mode 100644 drivers/staging/lustre/lustre/obdecho/echo_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/osc/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/osc/lproc_osc.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_cache.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_dev.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_io.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_lock.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_object.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_page.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_quota.c
> delete mode 100644 drivers/staging/lustre/lustre/osc/osc_request.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/Makefile
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/client.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/connection.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/errno.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/events.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/import.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/layout.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/llog_client.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/llog_net.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/nrs.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/pers.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/pinger.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/recover.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec_config.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec_null.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/service.c
> delete mode 100644 drivers/staging/lustre/lustre/ptlrpc/wiretest.c
> delete mode 100644 drivers/staging/lustre/sysfs-fs-lustre
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 4b65225d443a..db158767de20 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -13329,15 +13329,6 @@ S:	Odd Fixes
> F:	Documentation/devicetree/bindings/staging/iio/
> F:	drivers/staging/iio/
> 
> -STAGING - LUSTRE PARALLEL FILESYSTEM
> -M:	Oleg Drokin <oleg.drokin@intel.com>
> -M:	Andreas Dilger <andreas.dilger@intel.com>
> -M:	James Simmons <jsimmons@infradead.org>
> -L:	lustre-devel at lists.lustre.org (moderated for non-subscribers)
> -W:	http://wiki.lustre.org/
> -S:	Maintained
> -F:	drivers/staging/lustre
> -
> STAGING - NVIDIA COMPLIANT EMBEDDED CONTROLLER INTERFACE (nvec)
> M:	Marc Dietrich <marvin24@gmx.de>
> L:	ac100 at lists.launchpad.net (moderated for non-subscribers)
> diff --git a/drivers/staging/Kconfig b/drivers/staging/Kconfig
> index d5926f0d3f6c..1c357ef669ae 100644
> --- a/drivers/staging/Kconfig
> +++ b/drivers/staging/Kconfig
> @@ -84,8 +84,6 @@ source "drivers/staging/netlogic/Kconfig"
> 
> source "drivers/staging/mt29f_spinand/Kconfig"
> 
> -source "drivers/staging/lustre/Kconfig"
> -
> source "drivers/staging/dgnc/Kconfig"
> 
> source "drivers/staging/gs_fpgaboot/Kconfig"
> diff --git a/drivers/staging/Makefile b/drivers/staging/Makefile
> index 919753c3d3f6..2edb9860931e 100644
> --- a/drivers/staging/Makefile
> +++ b/drivers/staging/Makefile
> @@ -32,7 +32,6 @@ obj-$(CONFIG_STAGING_BOARD)	+= board/
> obj-$(CONFIG_LTE_GDM724X)	+= gdm724x/
> obj-$(CONFIG_FIREWIRE_SERIAL)	+= fwserial/
> obj-$(CONFIG_GOLDFISH)		+= goldfish/
> -obj-$(CONFIG_LNET)		+= lustre/
> obj-$(CONFIG_DGNC)			+= dgnc/
> obj-$(CONFIG_MTD_SPINAND_MT29F)	+= mt29f_spinand/
> obj-$(CONFIG_GS_FPGABOOT)	+= gs_fpgaboot/
> diff --git a/drivers/staging/lustre/Kconfig b/drivers/staging/lustre/Kconfig
> deleted file mode 100644
> index b7d81096eee9..000000000000
> diff --git a/drivers/staging/lustre/Makefile b/drivers/staging/lustre/Makefile
> deleted file mode 100644
> index 95ffe337a80a..000000000000
> diff --git a/drivers/staging/lustre/README.txt b/drivers/staging/lustre/README.txt
> deleted file mode 100644
> index 783959240490..000000000000
> diff --git a/drivers/staging/lustre/TODO b/drivers/staging/lustre/TODO
> deleted file mode 100644
> index 5332cdb19bfa..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
> deleted file mode 100644
> index edc7ed0dcb94..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> deleted file mode 100644
> index 61641c41c492..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
> deleted file mode 100644
> index 176fae7319e3..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
> deleted file mode 100644
> index 17534a76362a..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_fail.h
> deleted file mode 100644
> index 8074e390b4d1..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
> deleted file mode 100644
> index be315958a4b3..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
> deleted file mode 100644
> index 491d5971d199..000000000000
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_string.h
> deleted file mode 100644
> index cd7c3ccb2dc0..000000000000
> diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
> deleted file mode 100644
> index dae2e4f0056c..000000000000
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> deleted file mode 100644
> index 973c17a1c4a1..000000000000
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> deleted file mode 100644
> index cfe8ee424e94..000000000000
> diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
> deleted file mode 100644
> index 6bd1bca190a3..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
> deleted file mode 100644
> index c4d9472b374f..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> deleted file mode 100644
> index cce6b58e3682..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
> deleted file mode 100644
> index c1619f411d81..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> deleted file mode 100644
> index 1be9b7aa7326..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
> deleted file mode 100644
> index cccb32dd28f2..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
> deleted file mode 100644
> index a4f9ff01d458..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
> deleted file mode 100644
> index 882074ed6021..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h b/drivers/staging/lustre/include/uapi/linux/lnet/socklnd.h
> deleted file mode 100644
> index 6453e053fa99..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
> deleted file mode 100644
> index 11b51d93f64c..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
> deleted file mode 100644
> index 2e7a8d103777..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
> deleted file mode 100644
> index d375a476f5ea..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
> deleted file mode 100644
> index 6c7e3992d646..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
> deleted file mode 100644
> index 6e4e109fb874..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
> deleted file mode 100644
> index 94dadbe8e069..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
> deleted file mode 100644
> index 3343b602219b..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_param.h
> deleted file mode 100644
> index 1eab2ceca338..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
> deleted file mode 100644
> index 69387f36d1f1..000000000000
> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
> deleted file mode 100644
> index 19c9135e2273..000000000000
> diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
> deleted file mode 100644
> index ad049e6f24e4..000000000000
> diff --git a/drivers/staging/lustre/lnet/Makefile b/drivers/staging/lustre/lnet/Makefile
> deleted file mode 100644
> index 0a380fe88ce8..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/Makefile b/drivers/staging/lustre/lnet/klnds/Makefile
> deleted file mode 100644
> index c23e4f67f837..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
> deleted file mode 100644
> index 4affe1d79948..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> deleted file mode 100644
> index f0b4eb42bc1d..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> deleted file mode 100644
> index 217503f125bc..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> deleted file mode 100644
> index 65b7a62943ad..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
> deleted file mode 100644
> index 39d07926d603..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
> deleted file mode 100644
> index a7da1abfc804..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> deleted file mode 100644
> index f01b34ac1a53..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
> deleted file mode 100644
> index 4e5c89a692a3..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
> deleted file mode 100644
> index 01b31a6bb588..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
> deleted file mode 100644
> index 93a02cd6b6b5..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
> deleted file mode 100644
> index 5663a4ca94d4..000000000000
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
> deleted file mode 100644
> index 05982dac781c..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
> deleted file mode 100644
> index 6a1b232da495..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
> deleted file mode 100644
> index 06f694f6a28f..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
> deleted file mode 100644
> index bd86b3b5bc34..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
> deleted file mode 100644
> index 48be66f0d654..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> deleted file mode 100644
> index 3d1cf457b286..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
> deleted file mode 100644
> index 223505c37545..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c b/drivers/staging/lustre/lnet/libcfs/libcfs_mem.c
> deleted file mode 100644
> index 2d533be9bb30..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
> deleted file mode 100644
> index e1fb1263e3ae..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto-adler.c
> deleted file mode 100644
> index db81ed527452..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
> deleted file mode 100644
> index 21ff9bf6da47..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.h b/drivers/staging/lustre/lnet/libcfs/linux-crypto.h
> deleted file mode 100644
> index 5616e9ea1450..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-debug.c b/drivers/staging/lustre/lnet/libcfs/linux-debug.c
> deleted file mode 100644
> index 15ab849374c2..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux-tracefile.c
> deleted file mode 100644
> index 347138409eba..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
> deleted file mode 100644
> index 5dc7de9e6478..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> deleted file mode 100644
> index 7ca562e156f0..000000000000
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> deleted file mode 100644
> index 0608240d897f..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
> deleted file mode 100644
> index 0a9d70924fe0..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
> deleted file mode 100644
> index 5648f17eddc0..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> deleted file mode 100644
> index f9ed6977056c..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> deleted file mode 100644
> index 55ecc1998b7e..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
> deleted file mode 100644
> index c78e70373ab4..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
> deleted file mode 100644
> index 8a22514aaf71..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
> deleted file mode 100644
> index 672e37bdd045..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> deleted file mode 100644
> index f8eaf8ff8d8d..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> deleted file mode 100644
> index 0091273c04b9..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
> deleted file mode 100644
> index fc47379c5938..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
> deleted file mode 100644
> index 9b61260155f2..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
> deleted file mode 100644
> index 7456b989e451..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
> deleted file mode 100644
> index 9d06664f0c17..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
> deleted file mode 100644
> index 0066394b0bb0..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
> deleted file mode 100644
> index 0f6c3fa16c65..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> deleted file mode 100644
> index 58294149f7b2..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> deleted file mode 100644
> index 6267d5e4bbd6..000000000000
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> deleted file mode 100644
> index ae4b7f5953a0..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/Makefile b/drivers/staging/lustre/lnet/selftest/Makefile
> deleted file mode 100644
> index 3ccc8966b566..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
> deleted file mode 100644
> index f1ee219bc8f3..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
> deleted file mode 100644
> index 906d82d90c0c..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
> deleted file mode 100644
> index 0dabade3d091..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
> deleted file mode 100644
> index ce2f92d04838..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
> deleted file mode 100644
> index 3c1c1b5997e0..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
> deleted file mode 100644
> index 2826205e36a1..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
> deleted file mode 100644
> index 741af10560ad..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
> deleted file mode 100644
> index 9ba65320f748..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
> deleted file mode 100644
> index f54bd630dbf8..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
> deleted file mode 100644
> index 9613b0a77007..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
> deleted file mode 100644
> index 465b5b534423..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
> deleted file mode 100644
> index 8737fa96b192..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
> deleted file mode 100644
> index 582f252b3e12..000000000000
> diff --git a/drivers/staging/lustre/lnet/selftest/timer.h b/drivers/staging/lustre/lnet/selftest/timer.h
> deleted file mode 100644
> index 7f0ef9bd0cda..000000000000
> diff --git a/drivers/staging/lustre/lustre/Kconfig b/drivers/staging/lustre/lustre/Kconfig
> deleted file mode 100644
> index ccb78a945995..000000000000
> diff --git a/drivers/staging/lustre/lustre/Makefile b/drivers/staging/lustre/lustre/Makefile
> deleted file mode 100644
> index 331e4fcdd5a2..000000000000
> diff --git a/drivers/staging/lustre/lustre/fid/Makefile b/drivers/staging/lustre/lustre/fid/Makefile
> deleted file mode 100644
> index 77b65b92667d..000000000000
> diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
> deleted file mode 100644
> index 14569e969a31..000000000000
> diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
> deleted file mode 100644
> index ac52b378c155..000000000000
> diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
> deleted file mode 100644
> index a34fd90ca5e5..000000000000
> diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
> deleted file mode 100644
> index 0aabf473c9bd..000000000000
> diff --git a/drivers/staging/lustre/lustre/fld/Makefile b/drivers/staging/lustre/lustre/fld/Makefile
> deleted file mode 100644
> index 426deba8b815..000000000000
> diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
> deleted file mode 100644
> index a7415c9a1c28..000000000000
> diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
> deleted file mode 100644
> index e1d6aaa5c2b4..000000000000
> diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
> deleted file mode 100644
> index 97f7ea632346..000000000000
> diff --git a/drivers/staging/lustre/lustre/fld/lproc_fld.c b/drivers/staging/lustre/lustre/fld/lproc_fld.c
> deleted file mode 100644
> index 0bcfb26ef8aa..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> deleted file mode 100644
> index 6f7b991be809..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/interval_tree.h b/drivers/staging/lustre/lustre/include/interval_tree.h
> deleted file mode 100644
> index 7d119c1a0469..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/llog_swab.h b/drivers/staging/lustre/lustre/include/llog_swab.h
> deleted file mode 100644
> index 0433b79efdcb..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> deleted file mode 100644
> index 495e6f5f676b..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
> deleted file mode 100644
> index f29bbca5af65..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lu_ref.h b/drivers/staging/lustre/lustre/include/lu_ref.h
> deleted file mode 100644
> index ad0c24d29ffa..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_acl.h b/drivers/staging/lustre/lustre/include/lustre_acl.h
> deleted file mode 100644
> index e7575a172b5f..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
> deleted file mode 100644
> index 3c6db0d632dc..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
> deleted file mode 100644
> index 721a81f923e3..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
> deleted file mode 100644
> index 886e817644d6..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
> deleted file mode 100644
> index 2c55241258cc..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h b/drivers/staging/lustre/lustre/include/lustre_dlm_flags.h
> deleted file mode 100644
> index 53db031c4c8c..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_errno.h b/drivers/staging/lustre/lustre/include/lustre_errno.h
> deleted file mode 100644
> index 59fbb9f47ff1..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
> deleted file mode 100644
> index 79ad5aae86b9..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
> deleted file mode 100644
> index 094ad282de2c..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
> deleted file mode 100644
> index f42122a4dfaa..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_ha.h b/drivers/staging/lustre/lustre/include/lustre_ha.h
> deleted file mode 100644
> index cbd68985ada9..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
> deleted file mode 100644
> index 3556ce8d94e8..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
> deleted file mode 100644
> index ac3805ead620..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
> deleted file mode 100644
> index 51e5c0e03872..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
> deleted file mode 100644
> index 2b3fa8430185..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
> deleted file mode 100644
> index 87748e9902a7..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_linkea.h b/drivers/staging/lustre/lustre/include/lustre_linkea.h
> deleted file mode 100644
> index 03db1511bfd3..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
> deleted file mode 100644
> index 080ec1f8e19f..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
> deleted file mode 100644
> index 07f4e600386b..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
> deleted file mode 100644
> index a9c9992a2502..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
> deleted file mode 100644
> index f665556556ec..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> deleted file mode 100644
> index 35b43a77eb18..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_nrs.h b/drivers/staging/lustre/lustre/include/lustre_nrs.h
> deleted file mode 100644
> index ffa7317da35b..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h b/drivers/staging/lustre/lustre/include/lustre_nrs_fifo.h
> deleted file mode 100644
> index b70d97d4acbb..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_obdo.h b/drivers/staging/lustre/lustre/include/lustre_obdo.h
> deleted file mode 100644
> index d67dcbb84f18..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
> deleted file mode 100644
> index 298476ea7557..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
> deleted file mode 100644
> index 213d0a01adcf..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
> deleted file mode 100644
> index d35bcbc98831..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
> deleted file mode 100644
> index 9d786bbe7f3f..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> deleted file mode 100644
> index b1907bbffb19..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
> deleted file mode 100644
> index e5f7bb20415d..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
> deleted file mode 100644
> index fc9c7720fee0..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
> deleted file mode 100644
> index 9e41633823f7..000000000000
> diff --git a/drivers/staging/lustre/lustre/include/seq_range.h b/drivers/staging/lustre/lustre/include/seq_range.h
> deleted file mode 100644
> index 9450da728160..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/interval_tree.c b/drivers/staging/lustre/lustre/ldlm/interval_tree.c
> deleted file mode 100644
> index 8df7a4463c21..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
> deleted file mode 100644
> index 296259aa51e6..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
> deleted file mode 100644
> index 4da23ade2bb3..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
> deleted file mode 100644
> index 94f3b1e49896..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c b/drivers/staging/lustre/lustre/ldlm/ldlm_inodebits.c
> deleted file mode 100644
> index 2926208cdfa1..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
> deleted file mode 100644
> index bc33ca100620..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
> deleted file mode 100644
> index 0aa4f234a4f4..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> deleted file mode 100644
> index a644d133063b..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
> deleted file mode 100644
> index 5963e90d0938..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c b/drivers/staging/lustre/lustre/ldlm/ldlm_plain.c
> deleted file mode 100644
> index 33b5a3f96fcb..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> deleted file mode 100644
> index 36d14ee4e5b1..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> deleted file mode 100644
> index cdc52eed6d85..000000000000
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
> deleted file mode 100644
> index c93b019b8e37..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
> deleted file mode 100644
> index 5200924182ae..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/acl.c b/drivers/staging/lustre/lustre/llite/acl.c
> deleted file mode 100644
> index 2ee9ff931236..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
> deleted file mode 100644
> index 11b82c639bfe..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> deleted file mode 100644
> index 688dddf3ca47..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> deleted file mode 100644
> index 02295931883b..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
> deleted file mode 100644
> index ce0d51767da3..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> deleted file mode 100644
> index d7ea39ce0cb2..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
> deleted file mode 100644
> index a246b955306e..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> deleted file mode 100644
> index c08a6e14b6d7..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> deleted file mode 100644
> index 36066c839160..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> deleted file mode 100644
> index d7fb5533f707..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
> deleted file mode 100644
> index 14172688d55f..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> deleted file mode 100644
> index 49bf1b7ee311..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
> deleted file mode 100644
> index d5f6d20afe8c..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
> deleted file mode 100644
> index 008a8874118d..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
> deleted file mode 100644
> index 9ebac09160f2..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
> deleted file mode 100644
> index 3e008ce7275d..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
> deleted file mode 100644
> index 722e5ea1af5f..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> deleted file mode 100644
> index d864f5f36d85..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
> deleted file mode 100644
> index d335f29556c2..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
> deleted file mode 100644
> index 0690fdbf49f5..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
> deleted file mode 100644
> index 31dc3c0ade01..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
> deleted file mode 100644
> index 7d3abb43584a..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
> deleted file mode 100644
> index e7a4778e02e4..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_lock.c b/drivers/staging/lustre/lustre/llite/vvp_lock.c
> deleted file mode 100644
> index 4b6c7143bd2c..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
> deleted file mode 100644
> index b2cb51c8f7f4..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
> deleted file mode 100644
> index 6eb0565ddc22..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> deleted file mode 100644
> index 7fa0a419c094..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
> deleted file mode 100644
> index 5da69ba088c4..000000000000
> diff --git a/drivers/staging/lustre/lustre/llite/xattr_security.c b/drivers/staging/lustre/lustre/llite/xattr_security.c
> deleted file mode 100644
> index 93ec07531ac7..000000000000
> diff --git a/drivers/staging/lustre/lustre/lmv/Makefile b/drivers/staging/lustre/lustre/lmv/Makefile
> deleted file mode 100644
> index 91c99114aa13..000000000000
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
> deleted file mode 100644
> index 00dc858c10c9..000000000000
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
> deleted file mode 100644
> index 1e850fdbc623..000000000000
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
> deleted file mode 100644
> index 68a99170c424..000000000000
> diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
> deleted file mode 100644
> index 65f94e6ecaad..000000000000
> diff --git a/drivers/staging/lustre/lustre/lmv/lproc_lmv.c b/drivers/staging/lustre/lustre/lmv/lproc_lmv.c
> deleted file mode 100644
> index 30727b7acccc..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/Makefile b/drivers/staging/lustre/lustre/lov/Makefile
> deleted file mode 100644
> index 1ebf0193f61a..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
> deleted file mode 100644
> index e4f762137a4a..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
> deleted file mode 100644
> index c7db23472346..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
> deleted file mode 100644
> index c80320ab0858..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
> deleted file mode 100644
> index 47042f27ca90..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
> deleted file mode 100644
> index b823f8a21856..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
> deleted file mode 100644
> index b0292100bf26..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
> deleted file mode 100644
> index 006717cf7a41..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
> deleted file mode 100644
> index 344ff4b20168..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> deleted file mode 100644
> index adc90f310fd7..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
> deleted file mode 100644
> index a5f00f6ec347..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
> deleted file mode 100644
> index b1060d02a164..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
> deleted file mode 100644
> index cfae1294d77a..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
> deleted file mode 100644
> index b2a88ba72eb2..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
> deleted file mode 100644
> index cb8567f20ea7..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
> deleted file mode 100644
> index 7e89a2e485fc..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
> deleted file mode 100644
> index ea492be2eef3..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
> deleted file mode 100644
> index 13d452086b61..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lovsub_page.c b/drivers/staging/lustre/lustre/lov/lovsub_page.c
> deleted file mode 100644
> index 915520bcdd60..000000000000
> diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
> deleted file mode 100644
> index 721440feef72..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/Makefile b/drivers/staging/lustre/lustre/mdc/Makefile
> deleted file mode 100644
> index c7bc3351ccb0..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
> deleted file mode 100644
> index 6cce32491eb5..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
> deleted file mode 100644
> index 28924e927b50..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
> deleted file mode 100644
> index d582968987ff..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
> deleted file mode 100644
> index a8aa0fa5e87a..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
> deleted file mode 100644
> index e77c00df0693..000000000000
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> deleted file mode 100644
> index cff31cb0a9ac..000000000000
> diff --git a/drivers/staging/lustre/lustre/mgc/Makefile b/drivers/staging/lustre/lustre/mgc/Makefile
> deleted file mode 100644
> index 8abf108dbcf7..000000000000
> diff --git a/drivers/staging/lustre/lustre/mgc/lproc_mgc.c b/drivers/staging/lustre/lustre/mgc/lproc_mgc.c
> deleted file mode 100644
> index 636770624e8f..000000000000
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
> deleted file mode 100644
> index 9541892b67c7..000000000000
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> deleted file mode 100644
> index 32df804614d3..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
> deleted file mode 100644
> index e3fa9acff4c4..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
> deleted file mode 100644
> index a0db830ca841..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> deleted file mode 100644
> index fcdae6029258..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> deleted file mode 100644
> index 9ca29a26a38b..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> deleted file mode 100644
> index 42cce2dc5a45..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> deleted file mode 100644
> index 916cf81c5997..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> deleted file mode 100644
> index d6c46858941b..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/debug.c b/drivers/staging/lustre/lustre/obdclass/debug.c
> deleted file mode 100644
> index 2156a82a613a..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> deleted file mode 100644
> index 234f383ce6d9..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
> deleted file mode 100644
> index 63067a7f1e19..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
> deleted file mode 100644
> index 74c99ee216bb..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> deleted file mode 100644
> index 9c800580053b..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
> deleted file mode 100644
> index e5e8687784ee..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
> deleted file mode 100644
> index bba84eae1e19..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
> deleted file mode 100644
> index d9c63adff206..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
> deleted file mode 100644
> index 4991d4e589dc..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
> deleted file mode 100644
> index 26aea114a29b..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
> deleted file mode 100644
> index b431c3408fe4..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
> deleted file mode 100644
> index 85f09aff6e83..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> deleted file mode 100644
> index bdbe6f52031a..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> deleted file mode 100644
> index aa9d74e087f4..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_ref.c b/drivers/staging/lustre/lustre/obdclass/lu_ref.c
> deleted file mode 100644
> index f67cb89ea0ba..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> deleted file mode 100644
> index cdc8dc10690d..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
> deleted file mode 100644
> index e286a2665423..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
> deleted file mode 100644
> index ffc1814398a5..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> deleted file mode 100644
> index 06c38fdef7ba..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
> deleted file mode 100644
> index c4503bc36591..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/statfs_pack.c b/drivers/staging/lustre/lustre/obdclass/statfs_pack.c
> deleted file mode 100644
> index 355e888885f4..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdclass/uuid.c b/drivers/staging/lustre/lustre/obdclass/uuid.c
> deleted file mode 100644
> index ec8c6dc5c9a7..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdecho/Makefile b/drivers/staging/lustre/lustre/obdecho/Makefile
> deleted file mode 100644
> index 6be66fbab872..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> deleted file mode 100644
> index b692e76e7108..000000000000
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_internal.h b/drivers/staging/lustre/lustre/obdecho/echo_internal.h
> deleted file mode 100644
> index 42faa164fabb..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/Makefile b/drivers/staging/lustre/lustre/osc/Makefile
> deleted file mode 100644
> index 30dec90e64e8..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> deleted file mode 100644
> index 6a705bc5420c..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> deleted file mode 100644
> index f26983004843..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
> deleted file mode 100644
> index 2d3cba16ef34..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
> deleted file mode 100644
> index 2b5f324743e2..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
> deleted file mode 100644
> index 4ddba1354bef..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
> deleted file mode 100644
> index 67734a8ed331..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
> deleted file mode 100644
> index d93d33dc8dc4..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
> deleted file mode 100644
> index 84240181c7ea..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
> deleted file mode 100644
> index 20c553ef3a5e..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
> deleted file mode 100644
> index 723ec2fb18bf..000000000000
> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
> deleted file mode 100644
> index 61ef6c8d7a12..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/Makefile b/drivers/staging/lustre/lustre/ptlrpc/Makefile
> deleted file mode 100644
> index 1deb1971b39e..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
> deleted file mode 100644
> index c1b82bf20f08..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
> deleted file mode 100644
> index fb35a89ca6c6..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/errno.c b/drivers/staging/lustre/lustre/ptlrpc/errno.c
> deleted file mode 100644
> index b904524fc1c6..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
> deleted file mode 100644
> index 130bacc2c891..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> deleted file mode 100644
> index 1a0f35dfab97..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
> deleted file mode 100644
> index 417d4a151433..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_client.c b/drivers/staging/lustre/lustre/ptlrpc/llog_client.c
> deleted file mode 100644
> index 946d538121de..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/llog_net.c b/drivers/staging/lustre/lustre/ptlrpc/llog_net.c
> deleted file mode 100644
> index b871d9e40a9e..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
> deleted file mode 100644
> index 0b638837f88b..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
> deleted file mode 100644
> index 2897afb8806c..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
> deleted file mode 100644
> index e09b86529c5d..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
> deleted file mode 100644
> index ff630d94dd26..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
> deleted file mode 100644
> index 6ac9bb570663..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
> deleted file mode 100644
> index 2466868afb9c..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
> deleted file mode 100644
> index b3297b5ce395..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
> deleted file mode 100644
> index 134b74234519..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
> deleted file mode 100644
> index 5c32b657b3b5..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
> deleted file mode 100644
> index 531005411edf..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
> deleted file mode 100644
> index 2ea0a7ff87dd..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
> deleted file mode 100644
> index e193f3346e6f..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> deleted file mode 100644
> index 625b9520d78f..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
> deleted file mode 100644
> index 2389f9a8f534..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
> deleted file mode 100644
> index 2c8bad7b7877..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
> deleted file mode 100644
> index 2bb75ebd5d98..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
> deleted file mode 100644
> index ecc387d1b9b4..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
> deleted file mode 100644
> index ec3d9af76b17..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
> deleted file mode 100644
> index 3fd8c746f460..000000000000
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
> deleted file mode 100644
> index f9394c3e1ee2..000000000000
> diff --git a/drivers/staging/lustre/sysfs-fs-lustre b/drivers/staging/lustre/sysfs-fs-lustre
> deleted file mode 100644
> index 8691c6543a9c..000000000000
> diff --git a/scripts/selinux/mdp/mdp.c b/scripts/selinux/mdp/mdp.c
> index ffe8179f5d41..073fe7537f6c 100644
> --- a/scripts/selinux/mdp/mdp.c
> +++ b/scripts/selinux/mdp/mdp.c
> @@ -124,7 +124,6 @@ int main(int argc, char *argv[])
> 	fprintf(fout, "fs_use_xattr reiserfs user_u:base_r:base_t;\n");
> 	fprintf(fout, "fs_use_xattr jffs2 user_u:base_r:base_t;\n");
> 	fprintf(fout, "fs_use_xattr gfs2 user_u:base_r:base_t;\n");
> -	fprintf(fout, "fs_use_xattr lustre user_u:base_r:base_t;\n");
> 
> 	fprintf(fout, "fs_use_task eventpollfs user_u:base_r:base_t;\n");
> 	fprintf(fout, "fs_use_task pipefs user_u:base_r:base_t;\n");
> --
> 2.17.1
> 
> 


Cheers, Andreas





-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 873 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180601/701f3c9e/attachment-0001.sig>
