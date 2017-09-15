From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 15 Sep 2017 00:58:29 -0400
Subject: [lustre-devel] new tag 2.10.53
Message-ID: <6AEDE68A-9D25-499C-9876-3B73ED80902B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged a new tag 2.10.53 in master development branch of the Lustre community tree.

   Here's the changelog:
Alexander Boyko (1):
      LU-7001 osp: fix llog processing

Alexey Lyashkov (2):
      LU-9810 lnet: fix build with M-OFED 4.1
      LU-9810 lnet: prefer Fast Reg

Amir Shehata (6):
      LU-9480 lnet: add enhanced statistics
      LU-9480 lnet: show peer state
      LU-9909 lnet: fix memory leak and lnet_interfaces_max
      LU-9918 lnet: decref on peer after use
      LU-9917 lnet: rediscover peer if it changed
      LU-9921 lnet: resolve unsafe list access

Andreas Dilger (4):
      LU-8653 lod: use stripe_count instead of stripe_nr
      LU-5965 tests: fix parsing for older Lustre versions
      LU-9679 ldlm: remove flock accessor macros
      LU-7746 tests: skip tests for older (upstream) client

Aurelien Degremont (1):
      LU-8435 tests: slab alloc error does not LBUG

Bob Glossman (2):
      LU-9866 kernel: kernel update [SLES12 SP2 4.4.74-92.35]
      LU-9882 kernel: kernel update RHEL7.4 [3.10.0-693.1.1.el7]

Bobi Jam (1):
      LU-9941 lov: lsm_is_composite isn't right

Bruno Faccini (1):
      LU-7988 hsm: update many cookie status at once

Chris Horn (1):
      LU-9803 tests: cast st_blksize for printf

Colin Ian King (1):
      LU-9869 lnet: fix incorrect arguments order calling lstcon_session_new

Dan Carpenter (1):
      LU-9863 lmv: Off by two in lmv_fid2path()

Doug Oucharek (1):
      LU-9828 ptlrpc: Do not assert when bd_nob_transferred != 0

Elena Gryaznova (1):
      LU-8691 tests: add mdtest to ha.sh

Emoly Liu (2):
      LU-9657 pfl: llapi_layout_comp_usei should handle non-pfl file
      LU-9347 ioctl: Add BLKSSZGET ioctl support

Fan Yong (2):
      LU-9842 osd: return ENODATA for XATTR_NAME_FID on MDT
      LU-9410 ldiskfs: no check mb bitmap if flex_bg enabled

Frank Zago (1):
      LU-7988 hsm: added coordinator housekeeping flag

Giuseppe Di Natale (3):
      LU-9781 llog: Improve catalog full warning
      LU-9890 osd-zfs: dmu_objset_own/disown changes
      LU-8342 utils: Set dnodesize/recordsize at zfs dataset create

Gu Zheng (1):
      LU-9950 build: add support for Ubuntu(debian) arm64

Henri Doreau (1):
      LU-9519 utils: liblustreapi header cleanup

Hongchao Zhang (1):
      LU-8066 libcfs: call kernel_param_unlock on error

James Nunez (3):
      LU-9860 tests: Add conf-sanity tests to ALWAYS_EXCEPT list
      LU-9899 tests: mount client on MGS for ost-pools
      LU-9891 tests: Increase space not released for ZFS

James Simmons (6):
      LU-9767 utils: validate filesystem name for mkfs.lustre
      LU-9019 mdd: migrate from jiffies64 to ktime
      LU-8066 libcfs: test for both __kernel_param_[un]lock and kernel_param_[un]lock
      LU-9915 build: remove LC_CONFIG_OBD_BUFFER_SIZE
      LU-9791 obd: always call lprocfs_obd_setup
      LU-9870 build: handle SNMP missing on build box

Jinshan Xiong (1):
      LU-9841 lov: do not split IO for single striped file

John L. Hammond (2):
      LU-9913 lnet: balance references in lnet_discover_peer_locked()
      LU-9856 mdd: handle NULL buffer in mdd_xattr_list()

Lai Siyao (2):
      LU-9848 llog: check padding size for update reclen
      LU-9857 lmv: stripe dir page may be released mistakenly

Minh Diep (1):
      LU-9907 build: add patchless server for lbuild

Olaf Weber (21):
      LU-9480 lnet: add lnet_interfaces_max tunable
      LU-9480 lnet: configure lnet_interfaces_max tunable from dlc
      LU-9480 lnet: add struct lnet_ping_buffer
      LU-9480 lnet: automatic sizing of router pinger buffers
      LU-9480 lnet: add Multi-Rail and Discovery ping feature bits
      LU-9480 lnet: add sanity checks on ping-related constants
      LU-9480 lnet: cleanup of lnet_peer_ni_addref/decref_locked()
      LU-9480 lnet: rename lnet_add/del_peer_ni_to/from_peer()
      LU-9480 lnet: refactor lnet_del_peer_ni()
      LU-9480 lnet: refactor lnet_add_peer_ni()
      LU-9480 lnet: introduce LNET_PEER_MULTI_RAIL flag bit
      LU-9480 lnet: preferred NIs for non-Multi-Rail peers
      LU-9480 lnet: add LNET_PEER_CONFIGURED flag
      LU-9480 lnet: reference counts on lnet_peer/lnet_peer_net
      LU-9480 lnet: add msg_type to lnet_event
      LU-9480 lnet: add discovery thread
      LU-9480 lnet: tune lnet_peer_discovery_disabled with lnetctl
      LU-9480 lnet: add the Push target
      LU-9480 lnet: implement Peer Discovery
      LU-9480 lnet: add "lnetctl peer list"
      LU-9480 lnet: add "lnetctl ping" command

Oleg Drokin (4):
      LU-9480 lnet: Multi-Rail Dynamic Discovery feature
      Revert "LU-5541 lustreapi: only export the API symbols"
      Revert "LU-5541 build: build static and dynamic liblustreapi"
      New tag 2.10.53

Patrick Farrell (1):
      LU-8276 ldlm: Make lru clear always discard read lock pages

Sonia (1):
      LU-9480 lnet: cleanup lnetctl and cyaml

Sonia Sharma (1):
      LU-9480 lnet: add "lnetctl discover"

Steve Guminski (8):
      LU-8993 utils: Use absolute pathname for debug_daemon log file
      LU-6210 utils: Use C99 initializers in lfs_changelog()
      LU-6210 utils: Use C99 struct initializers in lfs_getdirstripe
      LU-6210 ptlrpc: Use C99 initializer in ptlrpc_register_rqbd()
      LU-5170 lfs: Standardize error messages in lfs_setdirstripe()
      LU-6210 lnet: Use C99 struct initializer in framework.c
      LU-6210 utils: Use C99 struct initializers in lnetctl
      LU-6051 utils: Remove incorrect request for getstripe help

Wang Shilong (1):
      LU-9874 osd-ldiskfs: simplify project transfer codes

Wei Liu (2):
      LU-832 test: Add error check when running run-llog.sh
      LU-9260 test: Use the correct mount device when test against lustre

Yang Sheng (1):
      LU-2776 tests: waiting multiop finished in sanityn:51a

dilip krishnagiri (7):
      LU-9591 tests: remove replay-vbr tests 12a from ALWAYS_EXCEPT
      LU-9593 tests: remove sanity-sec tests from ALWAYS_EXCEPT
      LU-9580 tests: remove performance-sanity tests from ALWAYS_EXCEPT
      LU-9588 tests: remove replay-ost-single test from ALWAYS_EXCEPT
      LU-9042 test: Remove conf-sanity tests from ALWAYS_EXCEPT
      LU-9044 test: remove conf-sanity tests from ALWAYS_EXCEPT
      LU-9595 tests: remove sanityn test 18c from ALWAYS_EXCEPT

frank zago (2):
      LU-5541 build: build static and dynamic liblustreapi
      LU-5541 lustreapi: only export the API symbols

sharmaso (1):
      LU-9077 lnet: fix for static analysis issues
