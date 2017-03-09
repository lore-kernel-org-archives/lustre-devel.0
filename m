From: kbuild test robot <lkp@intel.com>
Date: Thu, 9 Mar 2017 16:56:19 +0800
Subject: [lustre-devel] [PATCH 5/5] staging/lustre: Use generic range
	rwlock
In-Reply-To: <1488863010-13028-6-git-send-email-dave@stgolabs.net>
Message-ID: <201703091601.TR7uxISO%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Davidlohr,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on v4.11-rc1 next-20170309]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Davidlohr-Bueso/locking-Introduce-range-reader-writer-lock/20170309-140444
config: i386-allmodconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   In file included from drivers/staging/lustre/lustre/llite/../include/lustre/lustre_idl.h:76:0,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lib.h:49,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_dlm.h:47,
                    from drivers/staging/lustre/lustre/llite/file.c:40:
   drivers/staging/lustre/lustre/llite/file.c: In function 'll_file_io_generic':
>> drivers/staging/lustre/lustre/llite/../include/lustre/lustre_user.h:78:20: warning: large integer implicitly truncated to unsigned type [-Woverflow]
    #define LUSTRE_EOF 0xffffffffffffffffULL
                       ^
>> drivers/staging/lustre/lustre/llite/file.c:1072:33: note: in expansion of macro 'LUSTRE_EOF'
       range_rwlock_init(&range, 0, LUSTRE_EOF);
                                    ^~~~~~~~~~

vim +78 drivers/staging/lustre/lustre/llite/../include/lustre/lustre_user.h

23ec6607e9 John L. Hammond 2016-09-18  62   * are co-existing.
23ec6607e9 John L. Hammond 2016-09-18  63   */
23ec6607e9 John L. Hammond 2016-09-18  64  #if __BITS_PER_LONG != 64 || defined(__ARCH_WANT_STAT64)
23ec6607e9 John L. Hammond 2016-09-18  65  typedef struct stat64   lstat_t;
23ec6607e9 John L. Hammond 2016-09-18  66  #define lstat_f  lstat64
f0cf21abcc John L. Hammond 2016-10-02  67  #define fstat_f		fstat64
f0cf21abcc John L. Hammond 2016-10-02  68  #define fstatat_f	fstatat64
23ec6607e9 John L. Hammond 2016-09-18  69  #else
23ec6607e9 John L. Hammond 2016-09-18  70  typedef struct stat     lstat_t;
23ec6607e9 John L. Hammond 2016-09-18  71  #define lstat_f  lstat
f0cf21abcc John L. Hammond 2016-10-02  72  #define fstat_f		fstat
f0cf21abcc John L. Hammond 2016-10-02  73  #define fstatat_f	fstatat
23ec6607e9 John L. Hammond 2016-09-18  74  #endif
23ec6607e9 John L. Hammond 2016-09-18  75  
23ec6607e9 John L. Hammond 2016-09-18  76  #define HAVE_LOV_USER_MDS_DATA
d7e09d0397 Peng Tao        2013-05-02  77  
00c0a6aea0 John L. Hammond 2016-08-16 @78  #define LUSTRE_EOF 0xffffffffffffffffULL
00c0a6aea0 John L. Hammond 2016-08-16  79  
d7e09d0397 Peng Tao        2013-05-02  80  /* for statfs() */
d7e09d0397 Peng Tao        2013-05-02  81  #define LL_SUPER_MAGIC 0x0BD00BD0
d7e09d0397 Peng Tao        2013-05-02  82  
d7e09d0397 Peng Tao        2013-05-02  83  #ifndef FSFILT_IOC_GETFLAGS
d7e09d0397 Peng Tao        2013-05-02  84  #define FSFILT_IOC_GETFLAGS	       _IOR('f', 1, long)
d7e09d0397 Peng Tao        2013-05-02  85  #define FSFILT_IOC_SETFLAGS	       _IOW('f', 2, long)
d7e09d0397 Peng Tao        2013-05-02  86  #define FSFILT_IOC_GETVERSION	     _IOR('f', 3, long)

:::::: The code at line 78 was first introduced by commit
:::::: 00c0a6aea0d0ab2c11594616244d787ad7bf64dc staging: lustre: uapi: reduce scope of lustre_idl.h

:::::: TO: John L. Hammond <john.hammond@intel.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 59084 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170309/80c52e7d/attachment-0001.bin>
