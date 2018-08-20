From: NeilBrown <neilb@suse.com>
Date: Mon, 20 Aug 2018 14:28:08 +1000
Subject: [lustre-devel] [PATCH 00/38] lustre: fixes for sysfs handling
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87sh39pspz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> The port to sysfs upstream was done in haste and without any support
> in the utilies to even test it. Now the user land tools do work with
> the sysfs / debugfs port and many problems were exposed. This patch
> series fixes some of the largest holes which brings back some basic
> lustre functionality for the users. One special note to users you
> need to add the following udev rule to allowing tuning to work
> automatically with testing.

Thanks,
I've applied all of these, after replacing 3 with updates, and
discarding one as it added unnecessary locking.

Thanks,
NeilBrown


>
> SUBSYSTEM=="lustre", ACTION=="change", ENV{PARAM}=="?*", RUN+="/usr/sbin/lctl set_param '$env{PARAM}=$env{SETTING}'"
>
> Andreas Dilger (1):
>   lustre: llite: add newline to llite.*.offset_stats
>
> Bruno Faccini (1):
>   lustre: osc: enhance end to end bulk cksum error report
>
> Emoly Liu (1):
>   lustre: llite: register mountpoint before process llog
>
> James Simmons (33):
>   lustre: llite: rename ldebugfs_[un]register_mountpoint
>   lustre: llite: change ll_statfs_internal to use struct ll_sb_info
>   lustre: llite: move llite_root and llite_kset to lproc_llite.c
>   lustre: llite: remove ll_sb
>   lustre: llite: change top kobject for llite into a kset
>   lustre: llite: rename llite_sb_release
>   lustre: llite: move lmd_profile handling
>   lustre: llite: add proper error handling for
>     ll_debugfs_register_super()
>   lustre: llite: use C99 for struct lprocfs_llite_obd_vars
>   lustre: llite: don't handle success case for blocksize sysfs code
>   lustre: llite: don't handle success case for kbyte* sysfs code
>   lustre: llite: don't handle success case for file* sysfs code
>   lustre: llite: user kstrtobool for some sysfs handling
>   lustre: obd: embedded struct lprocfs_vars in obd device
>   lustre: obdclass: swap obd device attrs and default_attrs
>   lustre: obdclass: embedded attributes in struct obd_device
>   lustre: obdclass: add light weight obd_def_uuid_attrs
>   lustre: obd: migrate to ksets
>   lustre: obd: create class_setup_tunables() function
>   lustre: obd: create conn_uuid sysfs file
>   lustre: obd: enhance print_lustre_cfg()
>   lustre: obd: merge both top lustre sysfs attributes
>   lustre: obd: resolve config log sysfs issues
>   lustre: obd: move ioctl handling to class_obd.c
>   lustre: llite: replace ll_process_config with class_modify_config
>   lustre: mgc: update sysfs handling
>   lustre: osc: fixup kstrto* for sysfs handling
>   lustre: osc: restore cl_loi_list_lock
>   lustre: osc: make unstable_stats a debugfs file
>   lustre: osc: update sysfs handling
>   lustre: lmv: update sysfs handling
>   lustre: lov: update sysfs handling
>   lustre: mdc: update sysfs handling
>
> Steve Guminski (2):
>   lustre: llite: create ll_stats_pid_write()
>   lustre: llite: improve sysfs file text in lproc_llite.c
>
>  drivers/staging/lustre/lnet/libcfs/debug.c         |   1 +
>  .../staging/lustre/lustre/include/lprocfs_status.h |  12 +-
>  .../staging/lustre/lustre/include/lustre_disk.h    |   2 +
>  drivers/staging/lustre/lustre/include/obd.h        |  17 +-
>  drivers/staging/lustre/lustre/include/obd_class.h  |  10 +-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   2 +-
>  .../staging/lustre/lustre/llite/llite_internal.h   |  21 +-
>  drivers/staging/lustre/lustre/llite/llite_lib.c    | 137 ++++---
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  | 442 +++++++++++----------
>  drivers/staging/lustre/lustre/llite/super25.c      |  28 +-
>  drivers/staging/lustre/lustre/lmv/lmv_internal.h   |   4 +-
>  drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  26 +-
>  drivers/staging/lustre/lustre/lmv/lproc_lmv.c      |  58 +--
>  drivers/staging/lustre/lustre/lov/lov_internal.h   |   3 +-
>  drivers/staging/lustre/lustre/lov/lov_obd.c        |  51 +--
>  drivers/staging/lustre/lustre/lov/lproc_lov.c      | 219 +++++-----
>  drivers/staging/lustre/lustre/mdc/lproc_mdc.c      |  94 +++--
>  drivers/staging/lustre/lustre/mdc/mdc_internal.h   |   2 +-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |  37 +-
>  drivers/staging/lustre/lustre/mgc/lproc_mgc.c      |  45 ++-
>  drivers/staging/lustre/lustre/mgc/mgc_internal.h   |   2 +-
>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |  11 +-
>  drivers/staging/lustre/lustre/obdclass/Makefile    |   2 +-
>  drivers/staging/lustre/lustre/obdclass/class_obd.c | 209 +++++++++-
>  drivers/staging/lustre/lustre/obdclass/genops.c    |  47 ++-
>  drivers/staging/lustre/lustre/obdclass/llog_swab.c |  12 +-
>  .../lustre/lustre/obdclass/lprocfs_status.c        | 111 ++++--
>  .../staging/lustre/lustre/obdclass/obd_config.c    | 213 +++++++---
>  .../lustre/obdclass/{module.c => obd_sysfs.c}      | 293 +++++---------
>  drivers/staging/lustre/lustre/obdclass/sysctl.c    | 162 --------
>  drivers/staging/lustre/lustre/osc/lproc_osc.c      | 252 ++++++++----
>  drivers/staging/lustre/lustre/osc/osc_internal.h   |   3 +-
>  drivers/staging/lustre/lustre/osc/osc_request.c    | 174 +++++---
>  33 files changed, 1503 insertions(+), 1199 deletions(-)
>  rename drivers/staging/lustre/lustre/obdclass/{module.c => obd_sysfs.c} (57%)
>  delete mode 100644 drivers/staging/lustre/lustre/obdclass/sysctl.c
>
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180820/43b25537/attachment.sig>
