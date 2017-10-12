From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 12 Oct 2017 01:48:42 -0400
Subject: [lustre-devel] New tag 2.10.54
Message-ID: <14F8A520-633E-4BFF-858B-F9EC08B09281@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

   I just tagged 2.10.54 in the Lustre master branch for Lustre community tree.

   Here's the changelog:

Alex Zhuravlev (1):
      LU-9967 tests: run-llog to cleanup properly

Amir Shehata (2):
      LU-9992 lnet: don't discover loopback interface
      LU-9904 lnet: reduce logging severity

Andreas Dilger (1):
      LU-3308 tests: fix sanity/sanityn test_mkdir() usage

Arshad Hussain (1):
      LU-9379 tests: Improve get_version to handle empty return value

Ben Evans (2):
      LU-9221 jobstats: Create a pid-based hash for jobid values
      LU-9855 obdclass: Code cleanup

Bob Glossman (3):
      LU-9966 test: add a skip test to test_411
      LU-9979 kernel: kernel update RHEL6.9 [2.6.32-696.10.2.el6]
      LU-9978 kernel: kernel update RHEL7.4 [3.10.0-693.2.2.el7]

Bruno Faccini (1):
      LU-9930 llite: only clear lli_sai if the setter

Di Wang (1):
      LU-9840 lod: add ldo_dir_stripe_loaded

Elena Gryaznova (2):
      LU-9980 tests: save specific facet in save_lustre_params()
      LU-9931 tests: : fix REQFAIL calculation

Emoly Liu (2):
      LU-9682 nodemap: delete nids range from nodemap correctly
      LU-9929 nodemap: add default ACL unmapping handling

Erich Focht (1):
      LU-9214 llite: enable readahead for small read_ahead_per_file

Fan Yong (2):
      LU-9887 lfsck: calculate LFSCK speed properly
      LU-9995 lfsck: keep the LMV_HASH_FLAG_DEAD flag

Frank Zago (1):
      LU-7988 hsm: split mdt_hsm_add_actions()

Henri Doreau (1):
      LU-8400 mdd: remove OBD_IOC_GET_MNTOPT

James Nunez (1):
      LU-10024 tests: sanity 120f restore stripe count option

James Simmons (3):
      LU-8541 ldlm: don't use jiffies as sysfs parameter
      LU-9558 tests: add completion.h header to kinode.c
      LU-9019 ptlrpc: migrate pinger to 64 bit time

Jinshan Xiong (2):
      LU-9574 llite: pipeline readahead better with large I/O
      LU-9802 pfl: swapping lcm_entry_count correctly

Minh Diep (1):
      LU-9996 build: include MOFED lib

Nathaniel Clark (2):
      LU-9888 tests: Update disk2_7-zfs.tar.bz2 for quota
      LU-9960 osd-zfs: don't auto-upgrade quota

Olaf Weber (1):
      LU-9933 lnet: Handle ping buffer with only loopback NID

Oleg Drokin (5):
      LU-9995 lfsck: Have LMV_HASH_FLAG_DEAD defined for a while longer
      LU-8066 obd: make ldebugfs_remove recursive
      LU-8066 lnet: port lnet router to debugfs
      Revert "LU-9810 lnet: prefer Fast Reg"
      New tag 2.10.54

Patrick Farrell (2):
      LU-6179 llite: Implement ladvise lockahead
      LU-7802 ldlm: No -EINVAL for canceled != unused

Wang Shilong (1):
      LU-10011 utils: suppress annoying messages for project quota

dilip krishnagiri (1):
      LU-9963 test: add parallel-scale tests to ALWAYS_EXCEPT
