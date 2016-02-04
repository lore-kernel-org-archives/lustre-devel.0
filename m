From: Abe Asraoui <AbeA@supermicro.com>
Date: Thu, 4 Feb 2016 03:31:32 +0000
Subject: [lustre-devel] New tag 2.7.66
In-Reply-To: <DD6B1CA6-1A2B-4FFC-ACD1-EA3076831B57@intel.com>
References: <DD6B1CA6-1A2B-4FFC-ACD1-EA3076831B57@intel.com>
Message-ID: <b8c8ec576246420c8f2d5d2952eb2464@Ex2013-MBX2.supermicro.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi All,


LU-5030 snmp: migrate lustre SNMP utilites to use cfs_get_paths

Does anyone have a pointer to documentation regarding  integration of this SNMP utilities ?

Thanks,

Abe

-----Original Message-----
From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Drokin, Oleg
Sent: Monday, February 01, 2016 10:55 AM
To: Development Development
Subject: [lustre-devel] New tag 2.7.66

Hello!

   There's a new tag 2.7.66 in the master branch of the community tree.

   Here's a list of patches since previous tag:

Alex Zhuravlev (1):
      LU-7525 mdd: mdd_migrate_create() should not set nlink

Andreas Dilger (5):
      LU-4825 osp: rename variables to match /proc entry
      LU-6627 llite: remove extraneous export parameter
      LU-7276 utils: fix llog_reader loop on empty log
      LU-5030 tests: remove /proc paths from tests
      LU-7329 tests: increase sanity test_60b llog_test line count

Andriy Skulysh (1):
      LU-7382 llite: Fix iovec references accounting in ll_file_aio_read/write

Ben Evans (1):
      LU-6401 headers: move swab functions to new header files

Bob Glossman (2):
      LU-7624 fld: copy userspace buffer
      LU-7556 kernel: kernel update RHEL 6.7 [2.6.32-573.12.1.el6]

Bruno Faccini (1):
      LU-7273 tests: dump stacks upon CT stop failure

Christopher J. Morrone (1):
      LU-6788 build: Remove build/lbuild backwards compatibility symlink

Di Wang (3):
      LU-7039 llog: update llog header and size
      LU-7490 recovery: abort update recovery once fails
      LU-7638 recovery: do not abort update recovery.

Emoly Liu (1):
      LU-7628 lfs: fix NULL pointer check in cb_migrate_mdt_init()

Fan Yong (1):
      LU-6684 lfsck: stop lfsck even if some servers offline

Frank Zago (1):
      LU-7482 tests: fix uninitialized value in llapi_hsm_test

Hongchao Zhang (2):
      LU-7649 mgs: skip single OST conf update
      LU-7309 lod: notify client retry creation

Jadhav Vikram (1):
      LU-6961 ldiskfs: buffer head leak in mmp

James Nunez (1):
      LU-7070 tests: Skip sanity 24x based on server version

James Simmons (7):
      LU-5030 tests: handle missing common_name for upstream client
      LU-5030 utils: fix lnet/utils/debug.c compile issue
      LU-5030 util: delete no longer functional lltrack_stats application
      LU-7174 build: add mmap_cat to .gitignore
      LU-5030 util: migrate liblustreapi to use cfs_get_paths()
      LU-5030 utils: migrate most lustre utils to use cfs_get_paths()
      LU-5030 snmp: migrate lustre SNMP utilites to use cfs_get_paths

John L. Hammond (4):
      LU-7586 test: wait for remove in sanity-hsm test_406()
      LU-7661 mgs: restrict MGS_SET_INFO to stripe parameters
      LU-7666 llog: use correct size when freeing log header
      LU-7710 test: sync all clients in recovery-small 130[acb]

Kyrylo Shatskyy (1):
      LU-7480 tests: sanityn test_14 should be renamed

Lai Siyao (1):
      LU-3538 dne: Commit-on-Sharing for DNE

Li Dongyang (1):
      LU-7630 mdt: keep FS capability for getattr_name

Li Xi (2):
      LU-7647 lnet: remove annoying message in parse_nidrange
      LU-6939 nrs: add lock to protect TBF rule linkage

Liang Zhen (3):
      LU-519 o2iblnd: check wr_id returned by ib_poll_cq
      LU-7569 o2iblnd: avoid intensive reconnecting
      LU-7054 o2iblnd: less intense allocating retry

Nathaniel Clark (1):
      LU-7635 utils: Fix lhsmtool_posix interval reporting

Niu Yawei (1):
      LU-6037 test: skip s-q 37 for old server

Olaf Weber (1):
      LU-7324 lnet: Use after free in lnet_ptl_match_delay()

Oleg Drokin (4):
      LU-7623 lnet: Get rid of IOC_LIBCFS_DEBUG_PEER hack
      LU-7623 lnet: Get rid of IOC_LIBCFS_PORTALS_COMPATIBILITY ioctl
      LU-7623 lov: Get rid of an ugly statfs hack in lov_iocontrol
      New tag 2.7.66

Richard Henwood (1):
      LU-5147 doc: design docs in documentation dir

Saurabh Tandan (2):
      LU-7483 test: Modifying filtering in acl for SElinux feature
      LU-7591 test: Applying filtering in t32_test

Sebastien Buisson (1):
      LU-7636 gss: avoid useless sec debug log flooding

Sergey Cheremencev (1):
      LU-7422 mdt: fix ENOENT handling in mdt_intent_reint

Yang Sheng (3):
      LU-7479 tests: fix lustre-rsync-test test_2a on SLES12
      LU-7587 tests: fix sanity test_231a on SLES12
      LU-7089 tests: sanity test 99b: find: invalid mode '+4'

Bye,
    Oleg
_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
