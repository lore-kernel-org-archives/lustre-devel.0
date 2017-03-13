From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 13 Mar 2017 13:51:41 -0400
Subject: [lustre-devel] new tag 2.9.54
Message-ID: <1D1A49D3-B135-4FBF-A043-2416B838B3C6@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

  I just tagged 2.9.54 tag in Lustre master development tree.

  Here's the changelog:
Alex Zhuravlev (1):
      LU-8686 osd: add few more credits if debugging is enabled

Alexander Boyko (1):
      LU-8947 test: fix getting OST name at sanity test_253

Andreas Dilger (4):
      LU-5969 lustreapi: allow "version" without "lustre:"
      LU-8139 ofd: allow brw_size with 'M' suffix
      LU-8582 tests: skip sanity test_255a for interop
      LU-9024 tests: improve conf-sanity test_63 output

Andrew Perepechko (1):
      LU-9127 target: tgt_cb_last_committed is too noisy

Arnd Bergmann (3):
      LU-4423 mdc: use 64-bit timestamps for mdc
      LU-4423 llite: use 64-bit times in another debug print
      LU-4423 llite: use 64-bit llite debugfs timestamps

Ben Evans (1):
      LU-7670 mdt: allow changelog commands to return errors

Bob Glossman (1):
      LU-9101 kernel: kernel update [SLES11 SP4 3.0.101-94]

Bobi Jam (1):
      LU-8773 llite: refactor lov_object_fiemap()

Bruno Faccini (3):
      LU-8526 tests: ensure all OSTs active for allocations
      LU-6499 obdclass: obdclass module cleanup upon load error
      LU-9038 obdclass: handle early requests vs CT registering

Dmitry Eremin (2):
      LU-8888 clio: remove unused members from struct cl_thread_info
      LU-8703 libcfs: remove usless abstraction

Fan Yong (2):
      LU-9040 scrub: handle group boundary properly
      LU-8900 snapshot: new config for MDT write barrier

Giuseppe Di Natale (2):
      LU-9100 lnet: lctl net down success when lnet not loaded
      LU-9098 lnet: Move lnet_routes.conf to /etc

Gu Zheng (1):
      LU-9116 libcfs: avoid overflow of crypto bandwidth caculation

Hongchao Zhang (1):
      LU-9059 utils: skip label check for client

Jadhav Vikram (1):
      LU-8788 tests: modify create_pool to use as wrapper

James Nunez (1):
      LU-9125 test: Correct setstripe -s option

James Shimek (1):
      LU-8734 gnilnd: Handle dla credits exhaustion

James Simmons (7):
      LU-6142 lnet: remove most of typedefs from LNet headers
      LU-8066 ldlm: move server side /proc/fs/lustre/ldlm to sysfs
      LU-8560 build: announce linux kernel 4.6.7 support
      LU-9019 mdt: use 64-bit timestamps for rename stats
      LU-9019 obd: use 64-bit timestamps for rpc stats
      LU-9067 utils: ensure debugfs is mounted
      LU-9118 o2iblnd: handle MOFED libcfs time api collision

John L. Hammond (5):
      LU-9123 test: correct setstripe options in layout test
      LU-8403 obd: remove OBD_NOTIFY_SYNC{,_NONBLOCK}
      LU-9109 ldlm: restore missing newlines in ldlm sysfs files
      LU-8403 obd: remove OBD_NOTIFY_CONFIG
      LU-8827 mdt: bypass quota enforcement for HSM release

Lai Siyao (2):
      LU-8981 test: sanity 311 check is too strict
      LU-7994 statahead: add smp_mb() to serialize ops

Li Xi (3):
      LU-8550 test: fix problems of conf-sanity test_32
      LU-7441 nrs: Free hash table if failed to start a nrs policy
      LU-8726 osd-ldiskfs: bypass read for benchmarking

Minh Diep (1):
      LU-8642 build: suppport building various OFED

Nathaniel Clark (1):
      LU-8934 spec: Use correct provides in lustre-dkms

Niu Yawei (3):
      LU-9081 config: don't attach sub logs for LWP
      LU-9115 llite: buggy special handling on MULTIMODRPCS
      LU-9132 utils: tuning max_sectors_kb on mount

Oleg Drokin (2):
      LU-9125 utils: Postpone deprecation of some options.
      New tag 2.9.54

Parinay Kondekar (1):
      LU-9103 tests: SKIP recovery-small/110g for old MDS versions

Quentin Bouget (1):
      LU-8911 tests: sanity-hsm test_24d fails on a local setup

Sergey Cheremencev (3):
      LU-9094 o2iblnd: reconnect peer for REJ_INVALID_SERVICE_ID
      LU-9094 lnet: remove ni from lnet_finalize
      LU-9094 o2iblnd: kill timedout txs from ibp_tx_queue

Steve Guminski (4):
      LU-6210 utils: Change positional struct initializers to C99
      LU-5170 utils: Add support for --list-commands option
      LU-8767 llite: Improve proc file text in lproc_llite.c
      LU-6210 mdd: Change positional struct initializers to C99

Yang Sheng (1):
      LU-9146 ldiskfs: backport a few patches to resolve deadlock
