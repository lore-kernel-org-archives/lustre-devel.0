From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Thu, 21 Apr 2016 01:44:58 +0000
Subject: [lustre-devel] new tag 2.8.52
Message-ID: <7D2CE7D8-883E-4B77-A02E-2D8750A78572@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged a new 2.8.52 in the master branch of the opensfs tree.

   Here's the changelog:
Alex Zhuravlev (3):
      LU-7408 target: comment as per inspection
      LU-7355 osd: supress useless warning about many credits
      LU-7772 llog: do not destroy llog twice

Alexander Boyko (2):
      LU-7928 mdd: wrong params order at mdd_declare_rename
      LU-7156 mdd: add changelog_size to procfs

Amir Shehata (1):
      LU-7101 lnet: per NI map-on-demand value

Andrew Perepechko (1):
      LU-7925 llite: avoid clearing i_nlink for inodes in use

Ben Evans (1):
      LU-6401 headers: move seq_range.h to correct directory

Bob Glossman (3):
      LU-6163 kernel: use do_div64() for 64 bit divides
      LU-7907 kernel: kernel update RHEL 6.7 [2.6.32-573.22.1.el6]
      LU-7967 kernel: kernel update RHEL7.2 [3.10.0-327.13.1.el7]

Christopher J. Morrone (2):
      LU-7962 build: Support builds w/ weak module ZFS
      LU-7699 build: Eliminate lustre_build_version.h

Dmitry Eremin (5):
      LU-7887 lbuild: use "make rpms" for building Lustre RPMs
      LU-7968 lbuild: Fix reuse signature calculation
      LU-7936 utils: fix resource lost
      LU-7979 o2iblnd: fix free of IS_ERR pointer
      LU-7220 llog: fix fd lost and correct error reporting

Emoly Liu (1):
      LU-7055 osd: move dput() out of osd_ost_fini()'s rwlock

Fan Yong (1):
      LU-4182 tests: enable sanity-scrub test_15 under DNE mode

Giuseppe Di Natale (1):
      LU-7060 ldev: Added MGS NID substitution to ldev

Gregoire Pichon (1):
      LU-7965 utils: fix stack corruption in mkfs.lustre

Hongchao Zhang (1):
      LU-7428 test: commit the label change to disk

James Simmons (3):
      LU-6215 lprocfs: handle seq_printf api change
      LU-6245 libcfs: fix racey module handling
      LU-6245 libcfs: remove libcfs userland time abstraction

Jinshan Xiong (1):
      LU-7990 rpc: increase bulk size

Lai Siyao (1):
      LU-28 fileset: add fileset mount support

Li Xi (1):
      LU-4931 ladvise: Add feature of giving file access advices

Mike Shuey (1):
      LU-4423 lnet: remove LNET_MUTEX_LOCK macro

Oleg Drokin (1):
      New version 2.8.52

Ryan Haasken (1):
      LU-7796 utils: print error with valueless lctl set_param

Shivani Bhardwaj (1):
      LU-4423 lnet: Drop unnecessary wrapper function srpc_post_active_rqtbuf

Vitaly Osipov (1):
      LU-4423 lnet: remove memset(0) after LIBCFS_ALLOC

Yang Sheng (2):
      LU-7759 utils: build mount.lustre with libmount
      LU-6601 osp: update obd status while osp status changed
