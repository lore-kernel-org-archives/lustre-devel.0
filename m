From: kbuild test robot <lkp@intel.com>
Date: Thu, 9 Mar 2017 22:40:53 +0800
Subject: [lustre-devel] [PATCH 5/5] staging/lustre: Use generic range
	rwlock
In-Reply-To: <1488863010-13028-6-git-send-email-dave@stgolabs.net>
Message-ID: <201703092251.IuWrdxhU%fengguang.wu@intel.com>
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
config: i386-randconfig-i1-201710 (attached as .config)
compiler: gcc-4.8 (Debian 4.8.4-1) 4.8.4
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   drivers/staging/lustre/lustre/llite/file.c: In function 'll_file_io_generic':
>> drivers/staging/lustre/lustre/llite/file.c:1072:4: warning: large integer implicitly truncated to unsigned type [-Woverflow]
       range_rwlock_init(&range, 0, LUSTRE_EOF);
       ^

vim +1072 drivers/staging/lustre/lustre/llite/file.c

  1056		struct cl_io	 *io;
  1057		ssize_t result = 0;
  1058		int rc = 0;
  1059	
  1060		CDEBUG(D_VFSTRACE, "file: %pD, type: %d ppos: %llu, count: %zu\n",
  1061		       file, iot, *ppos, count);
  1062	
  1063	restart:
  1064		io = vvp_env_thread_io(env);
  1065		ll_io_init(io, file, iot == CIT_WRITE);
  1066	
  1067		if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
  1068			struct vvp_io *vio = vvp_env_io(env);
  1069			bool range_locked = false;
  1070	
  1071			if (file->f_flags & O_APPEND)
> 1072				range_rwlock_init(&range, 0, LUSTRE_EOF);
  1073			else
  1074				range_rwlock_init(&range, *ppos, *ppos + count - 1);
  1075	
  1076			vio->vui_fd  = LUSTRE_FPRIVATE(file);
  1077			vio->vui_iter = args->u.normal.via_iter;
  1078			vio->vui_iocb = args->u.normal.via_iocb;
  1079			/*
  1080			 * Direct IO reads must also take range lock,

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 37254 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170309/64b53f13/attachment-0001.bin>
