From: Oleg Drokin <oleg.drokin@intel.com>
Date: Wed, 16 May 2018 14:58:04 -0400
Subject: [lustre-devel] New tag 2.11.52
Message-ID: <D21A9F6D-2040-4FC0-AF13-9BA47440184A@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.11.52 tag in Lustre master development branch.

   Here?s the changelog:

Alex Zhuravlev (3):
      LU-10909 utils: enable non-shared libmount_utils_ldiskfs.a
      LU-10624 tests: conf-sanity needs larger ZFS filesystems
      LU-10838 tests: replay-single/89 to wait for recovery

Amir Shehata (3):
      LU-10214 lnet: allow expressions for route config
      LU-10825 libcfs: generate ip addresses
      LU-10825 lnet: add ip2nets syntax handling for peer

Andreas Dilger (7):
      LU-10886 build: fix warnings during autoconf
      LU-10903 obdecho: use OBD_ALLOC_LARGE for lnb
      LU-930 doc: include status in "lfs df" man page
      LU-1644 mgc: remove obsolete IR swabbing workaround
      LU-6349 mds: remove obsolete MDS_VTX_BYPASS flag
      LU-10856 tests: remove deprecated lfs getstripe -M usage
      LU-1644 ptlrpc: fix return type of boolean functions

Artem Blagodarenko (1):
      LU-10924 tests: conf-sanity test_116 server version check

Ashish Maurya (1):
      LU-9780 tests: Testing Round-Robin allocation

Bob Glossman (1):
      LU-10944 kernel: kernel update [SLES12 SP3 4.4.126-94.22]

Bruno Faccini (1):
      LU-10902 mdd: force disable changelogs early and safely

Chris Horn (1):
      LU-8293 lnet: Add insserv header to lnet init script

Dmitry Eremin (2):
      LU-8066 ldlm: move all remaining files from procfs to debugfs
      LU-4423 ptlrpc: use workqueue for pinger

Elena Gryaznova (1):
      LU-10857 tests: allow to disable project quotas

Fan Yong (3):
      LU-10922 osd-zfs: return -ENOENT if object destoryed
      LU-10992 llite: decrease sa_running if fail to start statahead
      LU-10988 lfsck: load object attr when prepare LFSCK request

Hongchao Zhang (1):
      LU-6655 ptlrpc: skip delayed replay requests

James Nunez (1):
      LU-2711 tests: conf-sanity clean up environment in test

James Simmons (7):
      LU-10926 llite: avoid panic in ll_set_acl()
      LU-8066 mgc: migrate away from procfs
      LU-9019 libcfs: remove the remaining cfs_time wrappers
      LU-10932 libcfs: properly handle failure cases in SMP code
      LU-8837 obd: remove linux directory
      LU-10575 build: make lustre-test dpkg depend on mpi-default-dev
      LU-8066 fld: move all files from procfs to debugfs

John L. Hammond (2):
      LU-10699 hsm: simplify mdt_hsm_{add,get}_actions()
      LU-10850 fld: handle empty ranges in fld_index_init()

Lai Siyao (4):
      LU-8200 test: improve sanityn.sh 33c
      LU-4684 ptlrpc: add dir migration connect flag
      LU-7763 tests: improve sanityn 33d
      LU-9857 lmv: dir page is released while in use

Li Dongyang (2):
      LU-10805 ldlm: convert ACCESS_ONCE() to READ_ONCE()
      LU-10805 libcfs: timer_setup() API changes

Li Xi (1):
      LU-10900 osd: wrong assertion in osd_transfer_project

Mikhail Pershin (2):
      LU-10910 mdd: deny layout swap for DoM file
      LU-10413 ldlm: expose dirty age limit for flush-on-glimpse

Mikhal Pershin (1):
      LU-10175 ldlm: IBITS lock convert instead of cancel

Nathaniel Clark (1):
      LU-3665 tests: Cleanup echo client after obdfilter-survey

Oleg Drokin (6):
      LU-8066 osc: move suitable values from procfs to sysfs
      LU-8066 lmv: Move suitable entries from procfs to sysfs
      LU-8066 lov: Move suitable variables from procfs to sysfs
      LU-10985 mdt: properly handle unknown intent requests
      LU-8066 mdc: move mdc-specific procfs files to sysfs
      New tag 2.11.52

Steve Guminski (6):
      LU-5170 lfs: Standardize error messages in set_time()
      LU-5170 lfs: Standardize error messages in lfs_mv()
      LU-5170 lfs: Standardize llapi messages for lfs_find()
      LU-5170 lfs: Standardize error messages in lfs_data_version()
      LU-5170 lfs: Standardize error messages in lfs_fid2path()
      LU-5170 lfs: Standardize error messages in lfs_path2fid()

Yang Sheng (2):
      LU-10560 osd: bi_bdev is replaced by bi_disk
      LU-10560 llite: remove assigning f_version in ll_readir.


Bye,
    Oleg
