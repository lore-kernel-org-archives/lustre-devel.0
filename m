From: kbuild test robot <lkp@intel.com>
Date: Sun, 19 Jun 2016 09:19:30 +0800
Subject: [lustre-devel] [PATCH 2/3] staging: luster: Checkpatch Cleanup
In-Reply-To: <109b0da96b67ae70145433b585ada631a5f7c668.1466279901.git.craig@craiginches.com>
Message-ID: <201606190949.XMOiiUu4%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

[auto build test WARNING on staging/staging-testing]
[also build test WARNING on v4.7-rc3 next-20160617]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Craig-Inches/staging-luster-cl_object-h-Checkpatch-Cleanup/20160619-052805
config: i386-allyesconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   drivers/staging/lustre/lustre/obdclass/cl_lock.c: In function 'cl_lock_descr_print':
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:113: warning: right-hand operand of comma expression has no effect [-Wunused-value]
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                                                                                                                    ^
   drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:132: warning: right-hand operand of comma expression has no effect [-Wunused-value]
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                                                                                                                                       ^
   drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:152: warning: right-hand operand of comma expression has no effect [-Wunused-value]
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                                                                                                                                                           ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%s' expects argument of type 'char *', but argument 4 has type '__u32 {aka const unsigned int}' [-Wformat=]
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~~~~~~~~~~~~~~~~~
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%d' expects argument of type 'int', but argument 5 has type '__u64 {aka const long long unsigned int}' [-Wformat=]
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%lu' expects argument of type 'long unsigned int', but argument 6 has type '__u32 {aka const unsigned int}' [-Wformat=]
   drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%lu' expects argument of type 'long unsigned int', but argument 7 has type '__u32 {aka const unsigned int}' [-Wformat=]
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%x' expects a matching 'unsigned int' argument [-Wformat=]
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%llx' expects a matching 'long long unsigned int' argument [-Wformat=]
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%x' expects a matching 'unsigned int' argument [-Wformat=]
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: warning: format '%x' expects a matching 'unsigned int' argument [-Wformat=]

vim +249 drivers/staging/lustre/lustre/obdclass/cl_lock.c

d7e09d039 Peng Tao 2013-05-02  233  		return names[mode];
d7e09d039 Peng Tao 2013-05-02  234  	else
d7e09d039 Peng Tao 2013-05-02  235  		return "U";
d7e09d039 Peng Tao 2013-05-02  236  }
d7e09d039 Peng Tao 2013-05-02  237  EXPORT_SYMBOL(cl_lock_mode_name);
d7e09d039 Peng Tao 2013-05-02  238  
d7e09d039 Peng Tao 2013-05-02  239  /**
d7e09d039 Peng Tao 2013-05-02  240   * Prints human readable representation of a lock description.
d7e09d039 Peng Tao 2013-05-02  241   */
d7e09d039 Peng Tao 2013-05-02  242  void cl_lock_descr_print(const struct lu_env *env, void *cookie,
d7e09d039 Peng Tao 2013-05-02  243  			 lu_printer_t printer,
d7e09d039 Peng Tao 2013-05-02  244  			 const struct cl_lock_descr *descr)
d7e09d039 Peng Tao 2013-05-02  245  {
d7e09d039 Peng Tao 2013-05-02  246  	const struct lu_fid  *fid;
d7e09d039 Peng Tao 2013-05-02  247  
d7e09d039 Peng Tao 2013-05-02  248  	fid = lu_object_fid(&descr->cld_obj->co_lu);
d7e09d039 Peng Tao 2013-05-02 @249  	(*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
d7e09d039 Peng Tao 2013-05-02  250  }
d7e09d039 Peng Tao 2013-05-02  251  EXPORT_SYMBOL(cl_lock_descr_print);
d7e09d039 Peng Tao 2013-05-02  252  
d7e09d039 Peng Tao 2013-05-02  253  /**
d7e09d039 Peng Tao 2013-05-02  254   * Prints human readable representation of \a lock to the \a f.
d7e09d039 Peng Tao 2013-05-02  255   */
d7e09d039 Peng Tao 2013-05-02  256  void cl_lock_print(const struct lu_env *env, void *cookie,
d7e09d039 Peng Tao 2013-05-02  257  		   lu_printer_t printer, const struct cl_lock *lock)

:::::: The code at line 249 was first introduced by commit
:::::: d7e09d0397e84eefbabfd9cb353221f3c6448d83 staging: add Lustre file system client support

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 54411 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160619/9fe5e540/attachment-0001.obj>
