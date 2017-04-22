From: Oleg Drokin <oleg.drokin@intel.com>
Date: Fri, 21 Apr 2017 21:41:18 -0400
Subject: [lustre-devel] New tag 2.9.56
Message-ID: <197B26FB-5F69-4A89-B9D9-8EAD32B61A3C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged new tag 2.9.56 - with this Feature Freeze is now in effect and no new
   features are going to be accepted for the 2.10 release.

   Here's the changelog (notable features - Progressive File Layout to allow flexible
   layouts depending on file size; Project quota - to allow additional
   limiting on quotas based on "project id" in addition to user and group ids):

Alex Zhuravlev (1):
      LU-9314 osd: cleaup qsd once commit callbacks are done

Alexander Boyko (2):
      LU-9065 osc: fix for cl_env_get in low memory
      LU-9286 ptlrpc: fix wrong error handlers

Andreas Dilger (8):
      LU-1538 tests: improve sanityn test_51 error messages
      LU-8823 ptlrpc: remove obsolete OST/MDT thread parameters
      LU-8998 docs: add llapi_ man pages to Makefile.am
      LU-9140 tests: disable sanityn test_77j and test_77k
      LU-8998 misc: minor clean ups
      LU-3434 scripts: check for mdsfilesystemtype= option
      LU-9186 tests: fix sanityn test_76 and related code
      LU-930 doc: update LFSCK documentation

Andriy Skulysh (1):
      LU-9171 osc: GPF while doing ELC with no_wait_policy

Arnd Bergmann (1):
      LU-4423 osc: use 64-bit timestamps in debugfs output

Ashish Purkar (1):
      LU-7819 tests: fix checkfiemap for stripecount > 1

Bob Glossman (4):
      LU-9236 kernel: new kernel RHEL 6.9 [2.6.32-696.el6]
      LU-9281 test: stop using invalid ps option
      LU-9275 kernel: kernel update [SLES12 SP2 4.4.49-92.14]
      LU-9287  kernel: kernel update [SLES11 SP4 3.0.101-97]

Bobi Jam (8):
      LU-8998 lod: accomodate to composite layout
      LU-8998 lov: add composite layout unpacking
      LU-8998 clio: Client side implementation for PFL
      LU-8998 tests: test scripts for PFL
      LU-9008 pfl: dynamic layout modification with write/truncate
      LU-9165 pfl: MDS handling of write intent IT_LAYOUT RPC
      LU-9300 test: need copytool setup for sanity-hsm 1b
      LU-9307 lov: NULL pointer deref in lov_delete_composite

Chris Hanna (1):
      LU-9245 utils: fix string copy handling within lgss_sk

Dmitry Eremin (2):
      LU-8703 libcfs: use int type for CPT identification.
      LU-9183 libcfs: handle dump_trace() and related callbacks removal

Fan Yong (9):
      LU-8900 tests: add snapshot in racer tests
      LU-8050 osp: not use obdo::o_lcookie for non-onwire RPC data
      LU-8054 lfsck: enhance lfsck notify API
      LU-8998 pfl: enhance PFID EA for PFL
      LU-8998 pfl: layout LFSCK handles PFL file
      LU-8998 pfl: test cases for lfsck on PFL
      LU-9187 lfsck: handle parameters properly
      LU-9259 tests: set fail_loc on the right MDT
      LU-9271 tests: remove unnecessary sanity-scrub test delay

Gabriele Paciucci (1):
      LU-8458 pacemaker: Script to monitor Server status

Henri Doreau (1):
      LU-7659 mdc: expose changelog through char devices

James Nunez (1):
      LU-8603 test: Separate tests in metadata_updates

James Simmons (4):
      LU-8843 build: fix all remaining less than 0 comparison for unsigned values
      LU-8066 obd: make version_show sysfs compliant
      LU-9019 obd: remove s2dhms time function
      LU-9019 quota : migrate to 64 bit time

Jian Yu (1):
      LU-8152 utils: improve ?lfs df? to show device status

Jim Casper (1):
      LU-8333 test: Add replay-dual 21b to ALWAYS_EXCEPT

Jinshan Xiong (2):
      LU-8998 docs: add lfs-setripe manpage to dist
      LU-8998 pfl: PFL feature implementation

John L. Hammond (1):
      LU-9383 test: use a subdir in sanityn test_71b()

Li Xi (3):
      LU-4017 quota: add project quota support to system header
      LU-4017 quota: add project quota support for Lustre
      LU-4017 quota: enable project quota limits

Mikhal Pershin (2):
      LU-8119 osd: remove dcb entry from the list prior processing.
      LU-9184 grants: move grant code to the target

Niu Yawei (7):
      LU-8998 pfl: Basic data structures for composite layout
      LU-8998 clio: getstripe support comp layout
      LU-8998 lustreapi: composite llapi_layout
      LU-8998 lfs: user space tools for PFL
      LU-8998 docs: man pages for tools of PFL
      LU-8998 utils: enlarge default inode size
      LU-8998 docs: man pages for composite layout APIs

Oleg Drokin (5):
      LU-4017 quota: cleanup codes of quota for new type
      LU-4017 quota: add project id support
      LU-9339 quota: Replace MAXQUOTAS usage with LL_MAXQUOTAS
      LU-9339 ldiskfs: Make ldiskfs buildable on kernels with no project quota
      New tag 2.9.56

Qian Yingjin (2):
      LU-7470 nrs: extend TBF with NID/JobID/OPCode expression
      LU-8236 nrs: Add wildcard support for JOBID TBF rule

Saurabh Tandan (2):
      LU-9318 test: sanity-lsnapshot skipped for all non-zfs configs
      LU-9320 test: Skip sanity test_80[12]*

Steve Guminski (2):
      LU-9076 ptlrpc: Prevent possible dereference of NULL pointers
      LU-9166 mdt: Add trailing newlines to proc files

Wang Shilong (5):
      LU-4017 ldiskfs: add project quota support
      LU-4017 ldiskfs: export __ext4_ioctl_setproject for lustre
      LU-9278 quota: avoid crash when access failed quota proc file
      LU-4017 quota: add setting/getting project id function
      LU-4017 quota: add project quota support to lfs quota/setquota

Wei Liu (1):
      LU-9207 test: Add new disk image for 2.9.0

Yang Sheng (1):
      LU-7502 utils: add --mdt-count & --mdt-hash options

teddy (1):
      LU-7529 test: fix tiny problems of tests in conf-sanity.sh
