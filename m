From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:32 -0500
Subject: [lustre-devel] [PATCH 00/45] Lustre cleanups
Message-ID: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Majority of this patch is Lustre code style cleanups.
NULL comparison style is adjusted for the whole lustre tree
(but not lnet not to interfere with James patches in flight).

Some server-only code was removed in the process.

lustre/libcfs in addition was processed to remove as many checkpatch
warnings as was possible. Assuming this is the end result we
want I will process the rest of the Lustre tree in the similar way next.

Remaining warnings from checkpatch are either due to bugs/problems
in checkpatch (reported) or otherwise do not make sense.
Amongst these are the long printed strings - I know we could do an
exception for that, but this is pending renaming some of our debug
printing primitives, so I guess they just stay as is.

Please consider.

Here's the full list of remaining warnings in
drivers/staging/lustre/lustre/libcfs for those curious:

WARNING: line over 80 characters
#456: FILE: drivers/staging/lustre/lustre/libcfs/debug.c:427:
+			CWARN("You are trying to use a numerical value for the mask - this will be deprecated in a future release.\n");

ERROR: that open brace { should be on the previous line
#2102: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1362:
+cfs_hash_for_each_enter(struct cfs_hash *hs)
+{

ERROR: that open brace { should be on the previous line
#2129: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1389:
+cfs_hash_for_each_exit(struct cfs_hash *hs)
+{

ERROR: that open brace { should be on the previous line
#2160: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1420:
+cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+			void *data, int remove_safe)
+{

ERROR: that open brace { should be on the previous line
#2254: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1514:
+cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+		       void *data)
+{

ERROR: that open brace { should be on the previous line
#2304: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1564:
+cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+			void *data)
+{

ERROR: that open brace { should be on the previous line
#2370: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1630:
+cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+			 void *data)
+{

ERROR: that open brace { should be on the previous line
#2402: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1662:
+cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
+			void *data)
+{

ERROR: that open brace { should be on the previous line
#2459: FILE: drivers/staging/lustre/lustre/libcfs/hash.c:1719:
+cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
+		      cfs_hash_for_each_cb_t func, void *data)
+{

CHECK: spinlock_t definition without comment
#3125: FILE: drivers/staging/lustre/lustre/libcfs/libcfs_lock.c:55:
+	spinlock_t		*lock;

WARNING: line over 80 characters
#4342: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:317:
+			CDEBUG(D_INFO, "Try to unset cpu %d which is not in CPT-table %p\n",

WARNING: line over 80 characters
#4392: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:367:
+		CDEBUG(D_INFO, "No online CPU is found in the CPU mask for CPU partition %d\n",

WARNING: line over 80 characters
#4588: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:563:
+		CERROR("No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",

WARNING: line over 80 characters
#4748: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:723:
+		CWARN("CPU partition number %d is larger than suggested value (%d), your system may have performance issue or run out of memory while under pressure\n",

WARNING: line over 80 characters
#4753: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:728:
+		CERROR("CPU number %d is not multiple of cpu_npartition %d, please try different cpu_npartitions value or set pattern string by cpu_pattern=STRING\n",

WARNING: line over 80 characters
#4803: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:778:
+		CERROR("Expect %d(%d) CPU partitions but got %d(%d), CPU hotplug/unplug while setting?\n",

WARNING: line over 80 characters
#4814: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-cpu.c:789:
+	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",

WARNING: char * array declaration might be better as static const
#5734: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c:76:
+	char *envp[] = {

WARNING: line over 80 characters
#5748: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c:90:
+		CERROR("Error %d invoking LNET debug log upcall %s %s; check /sys/kernel/debug/lnet/debug_log_upcall\n",

WARNING: char * array declaration might be better as static const
#5760: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c:102:
+	char *envp[] = {

WARNING: line over 80 characters
#5774: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c:116:
+		CERROR("Error %d invoking LNET upcall %s %s%s%s%s%s%s%s%s; check /sys/kernel/debug/lnet/upcall\n",

WARNING: memory barrier without comment
#5837: FILE: drivers/staging/lustre/lustre/libcfs/linux/linux-debug.c:179:
+	mb();

CHECK: Alignment should match open parenthesis
#6672: FILE: drivers/staging/lustre/lustre/libcfs/module.c:148:
+					err = libcfs_ioctl_popdata(arg,
+							data, sizeof(*data));

WARNING: line over 80 characters
#7369: FILE: drivers/staging/lustre/lustre/libcfs/tracefile.c:49:
+union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;

WARNING: memory barrier without comment
#7839: FILE: drivers/staging/lustre/lustre/libcfs/tracefile.c:519:
+	mb();

CHECK: extern prototypes should be avoided in .h files
#8710: FILE: drivers/staging/lustre/lustre/libcfs/tracefile.h:187:
+extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];

ERROR: Macros with complex values should be enclosed in parentheses
#8712: FILE: drivers/staging/lustre/lustre/libcfs/tracefile.h:189:
+#define cfs_tcd_for_each(tcd, i, j)				       \
+	for (i = 0; cfs_trace_data[i]; i++)				\
+		for (j = 0, ((tcd) = &(*cfs_trace_data[i])[j].tcd);	\
+		     j < num_possible_cpus();				 \
+		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)

CHECK: Concatenated strings should use spaces between elements
#8774: FILE: drivers/staging/lustre/lustre/libcfs/tracefile.h:251:
+		cfs_trace_assertion_failed("ASSERTION("#cond") failed", \

CHECK: Alignment should match open parenthesis
#9075: FILE: drivers/staging/lustre/lustre/libcfs/workitem.c:280:
+		rc = wait_event_interruptible_exclusive(sched->ws_waitq,
+						!cfs_wi_sched_cansleep(sched));


Oleg Drokin (45):
  staging/lustre/ptlrpc: Get rid of /proc references in comments
  staging/lustre/obdclass: Get rid of /proc references in comments.
  staging/lustre/libcfs: Get rid of /proc references in comments
  staging/lustre/llite: Get rid of /proc references in comments
  staging/lustre/lov: Get rid of /proc references in comments
  staging/lustre: Remove unused function oti_init
  staging/lustre: Remove unused osc_on_mdt function
  staging/lustre: Remove server code from client_obd_setup()
  staging/lustre: Remove server code from class_get_type()
  staging/lustre: Remove commented out lock_lock_multi_match
  staging/lustre/osc: Remove commented out osc_page_protected()
  staging/lustre/libcfs: Adjust NULL comparison codestyle
  staging/lustre/lov: Adjust NULL comparison codestyle
  staging/lustre/llite: Adjust NULL comparison codestyle
  staging/lustre/ldlm: Adjust NULL comparison codestyle
  staging/lustre/lmv: Adjust NULL comparison codestyle
  staging/lustre/fid: Adjust NULL comparison codestyle
  staging/lustre/fld: Adjust NULL comparison codestyle
  staging/lustre/lclient: Adjust NULL comparison codestyle
  staging/lustre/include: Adjust NULL comparison codestyle
  staging/lustre/mdc: Adjust NULL comparison codestyle
  staging/lustre/mgc: Adjust NULL comparison codestyle
  staging/lustre/obdclass: Adjust NULL comparison codestyle
  staging/lustre/obdecho: Adjust NULL comparison codestyle
  staging/lustre/osc: Adjust NULL comparison codestyle
  staging/lustre/ptlrpc: Adjust NULL comparison codestyle
  staging/lustre: Remove the "write to FSF to get a copy of GPL" wording
  staging/lustre/libcfs: Cleanup: parenthesis alignment adjustments
  staging/lustre/libcfs: Move EXPORT_SYMBOLs under function/variable
  staging/lustre/libcfs: style change to add missing spaces for
    operations
  staging/lustre/libcfs: reformat cfs_tcd_for_each_type_lock define
  staging/lustre/libcfs: Remove stray spaces after function name
  staging/lustre/libcfs: Shortened too long lines
  staging/lustre/libcfs: Remove unused cfs_tcd_owns_tage() function
  staging/lustre/libcfs: Move private tracefile structs out of header
  staging/lustre/libcfs: Update comments style to match kernel
  staging/lustre/libcfs: Remove useless returns in void functions
  staging/lustre/libcfs: Remove empty lines after/before braces
  staging/lustre: Update cfs_cpu_notify switch statement with a comment
  staging/lustre: Get rid of cfs_trace_buf_type_t typedef
  staging/lustre/libcfs: Get rid of multiple assignments
  staging/lustre: Remove space after cast in cfs_crypto_hash_final()
  staging/lustre/libcfs: Replace use of printk with pr_<level>
  staging/lustre: Convert cfs_trace_daemon_command to use kstrtoul
  staging/lustre: Convert cfs_str2num_check to use kstrtoul

 .../staging/lustre/include/linux/lnet/lnetctl.h    |   4 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   4 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   3 -
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |   3 -
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   3 -
 drivers/staging/lustre/lnet/lnet/router.c          |   4 -
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   4 -
 drivers/staging/lustre/lustre/fid/fid_request.c    |  14 +-
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  14 +-
 drivers/staging/lustre/lustre/fld/fld_cache.c      |  10 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h   |   2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c    |  32 ++-
 drivers/staging/lustre/lustre/fld/lproc_fld.c      |  11 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   8 +-
 drivers/staging/lustre/lustre/include/lclient.h    |   4 +-
 drivers/staging/lustre/lustre/include/linux/obd.h  |   6 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |   8 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |   6 +-
 drivers/staging/lustre/lustre/include/lu_ref.h     |   4 -
 .../lustre/lustre/include/lustre/lustre_idl.h      |   6 +-
 drivers/staging/lustre/lustre/include/lustre_cfg.h |   5 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  18 +-
 .../staging/lustre/lustre/include/lustre_export.h  |  11 --
 drivers/staging/lustre/lustre/include/lustre_lib.h |   8 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |  12 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |  10 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  15 +-
 drivers/staging/lustre/lustre/include/obd.h        |  43 +----
 drivers/staging/lustre/lustre/include/obd_class.h  |  49 +++--
 .../staging/lustre/lustre/include/obd_support.h    |   1 -
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c |  32 +--
 drivers/staging/lustre/lustre/ldlm/interval_tree.c |   2 -
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   9 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  13 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  60 +-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  65 +++----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  45 +++--
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  17 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  65 +++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  25 ++-
 drivers/staging/lustre/lustre/libcfs/debug.c       |  31 ++-
 drivers/staging/lustre/lustre/libcfs/fail.c        |   3 +-
 drivers/staging/lustre/lustre/libcfs/hash.c        | 141 +++++++-------
 drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c  |  11 +-
 drivers/staging/lustre/lustre/libcfs/libcfs_lock.c |  10 +-
 drivers/staging/lustre/lustre/libcfs/libcfs_mem.c  |  14 +-
 .../staging/lustre/lustre/libcfs/libcfs_string.c   |  54 +++---
 .../staging/lustre/lustre/libcfs/linux/linux-cpu.c |  75 ++++----
 .../lustre/lustre/libcfs/linux/linux-crypto.c      |  27 ++-
 .../lustre/lustre/libcfs/linux/linux-curproc.c     |   7 +-
 .../lustre/lustre/libcfs/linux/linux-debug.c       |  23 +--
 .../staging/lustre/lustre/libcfs/linux/linux-mem.c |   2 +-
 .../lustre/lustre/libcfs/linux/linux-module.c      |  10 +-
 .../lustre/lustre/libcfs/linux/linux-tracefile.c   |  36 ++--
 drivers/staging/lustre/lustre/libcfs/module.c      |  28 ++-
 drivers/staging/lustre/lustre/libcfs/prng.c        |  13 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.c   | 214 ++++++++++++---------
 drivers/staging/lustre/lustre/libcfs/tracefile.h   |  87 ++-------
 drivers/staging/lustre/lustre/libcfs/workitem.c    |  41 ++--
 drivers/staging/lustre/lustre/llite/dcache.c       |  10 +-
 drivers/staging/lustre/lustre/llite/dir.c          |  23 +--
 drivers/staging/lustre/lustre/llite/file.c         | 115 ++++++-----
 drivers/staging/lustre/lustre/llite/llite_close.c  |  14 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |  25 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  61 +++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  14 +-
 drivers/staging/lustre/lustre/llite/llite_rmtacl.c |  10 +-
 drivers/staging/lustre/lustre/llite/lloop.c        |  17 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  14 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  53 ++---
 drivers/staging/lustre/lustre/llite/rw.c           |  23 ++-
 drivers/staging/lustre/lustre/llite/rw26.c         |  16 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |  40 ++--
 drivers/staging/lustre/lustre/llite/super25.c      |  10 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |  16 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  14 +-
 drivers/staging/lustre/lustre/llite/vvp_object.c   |   5 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  22 +--
 drivers/staging/lustre/lustre/llite/xattr.c        |  21 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c  |  16 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |  11 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   6 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        | 115 +++++------
 drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |   4 +-
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |   6 +-
 drivers/staging/lustre/lustre/lov/lov_dev.c        |  40 ++--
 drivers/staging/lustre/lustre/lov/lov_ea.c         |   4 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h   |   1 -
 drivers/staging/lustre/lustre/lov/lov_io.c         |  30 ++-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |  88 +++------
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  44 ++---
 drivers/staging/lustre/lustre/lov/lov_object.c     |  51 +++--
 drivers/staging/lustre/lustre/lov/lov_offset.c     |   5 -
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   8 +-
 drivers/staging/lustre/lustre/lov/lov_page.c       |   6 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  24 +--
 drivers/staging/lustre/lustre/lov/lov_request.c    |  30 ++-
 drivers/staging/lustre/lustre/lov/lovsub_dev.c     |   5 +-
 drivers/staging/lustre/lustre/lov/lovsub_lock.c    |   4 +-
 drivers/staging/lustre/lustre/lov/lovsub_object.c  |   4 +-
 drivers/staging/lustre/lustre/lov/lproc_lov.c      |  18 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  12 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |  47 ++---
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |  24 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    | 116 ++++++-----
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |  41 ++--
 drivers/staging/lustre/lustre/obdclass/acl.c       |  10 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  83 ++++----
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  47 +++--
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  40 ++--
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  97 +++++-----
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   8 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  38 ++--
 .../lustre/lustre/obdclass/linux/linux-module.c    |   5 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |  18 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   2 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |   7 +-
 .../lustre/lustre/obdclass/lprocfs_counters.c      |   4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |  64 +++---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  94 +++++----
 .../lustre/lustre/obdclass/lustre_handles.c        |  12 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |   4 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  12 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |  37 ++--
 .../staging/lustre/lustre/obdecho/echo_client.c    |  61 +++---
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |   4 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 120 ++++++------
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   4 +-
 drivers/staging/lustre/lustre/osc/osc_dev.c        |   6 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |  19 +-
 drivers/staging/lustre/lustre/osc/osc_lock.c       |  61 +++---
 drivers/staging/lustre/lustre/osc/osc_object.c     |   4 +-
 drivers/staging/lustre/lustre/osc/osc_page.c       | 121 ++----------
 drivers/staging/lustre/lustre/osc/osc_quota.c      |  16 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    | 130 ++++++-------
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  75 +++-----
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   9 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  26 ++-
 drivers/staging/lustre/lustre/ptlrpc/llog_client.c |  20 +-
 drivers/staging/lustre/lustre/ptlrpc/llog_net.c    |   2 +-
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |  31 ++-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  30 ++-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         |  88 ++++-----
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |  10 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  14 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  16 +-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |   8 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  54 +++---
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  14 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  24 +--
 drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c   |   6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c    |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  16 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  76 ++++----
 158 files changed, 1937 insertions(+), 2491 deletions(-)

-- 
2.1.0
