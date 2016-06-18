From: kbuild test robot <lkp@intel.com>
Date: Sun, 19 Jun 2016 07:39:07 +0800
Subject: [lustre-devel] [PATCH 2/3] staging: luster: Checkpatch Cleanup
In-Reply-To: <109b0da96b67ae70145433b585ada631a5f7c668.1466279901.git.craig@craiginches.com>
Message-ID: <201606190749.P22lESms%fengguang.wu@intel.com>
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
config: x86_64-allmodconfig (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All warnings (new ones prefixed by >>):

   In file included from drivers/staging/lustre/lustre/obdclass/cl_lock.c:44:0:
   drivers/staging/lustre/lustre/obdclass/cl_lock.c: In function 'cl_lock_descr_print':
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1206:39: warning: right-hand operand of comma expression has no effect [-Wunused-value]
     (cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode, \
                                          ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:41: note: in expansion of macro 'PDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                                            ^~~~~~
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1206:58: warning: right-hand operand of comma expression has no effect [-Wunused-value]
     (cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode, \
                                                             ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:41: note: in expansion of macro 'PDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                                            ^~~~~~
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1207:20: warning: right-hand operand of comma expression has no effect [-Wunused-value]
     (descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags)
                       ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:41: note: in expansion of macro 'PDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                                            ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%s' expects argument of type 'char *', but argument 4 has type '__u32 {aka const unsigned int}' [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%d' expects argument of type 'int', but argument 5 has type '__u64 {aka const long long unsigned int}' [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%lu' expects argument of type 'long unsigned int', but argument 6 has type '__u32 {aka const unsigned int}' [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%lu' expects argument of type 'long unsigned int', but argument 7 has type '__u32 {aka const unsigned int}' [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%x' expects a matching 'unsigned int' argument [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%llx' expects a matching 'long long unsigned int' argument [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%x' expects a matching 'unsigned int' argument [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:1204:16: warning: format '%x' expects a matching 'unsigned int' argument [-Wformat=]
    #define DDESCR "%s(%d):[%lu, %lu]:%x"
                   ^
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:249:26: note: in expansion of macro 'DDESCR'
     (*printer)(env, cookie, DDESCR"@"DFID, PDESCR(descr), PFID(fid));
                             ^~~~~~

vim +1206 drivers/staging/lustre/lustre/obdclass/../include/cl_object.h

  1198		 * flags to enqueue lock. A combination of bit-flags from
  1199		 * enum cl_enq_flags.
  1200		 */
  1201		__u32	     cld_enq_flags;
  1202	};
  1203	
> 1204	#define DDESCR "%s(%d):[%lu, %lu]:%x"
  1205	#define PDESCR(descr)						   \
> 1206		(cl_lock_mode_name((descr)->cld_mode), (descr)->cld_mode,	\
> 1207		(descr)->cld_start, (descr)->cld_end, (descr)->cld_enq_flags)
  1208	
  1209	const char *cl_lock_mode_name(const enum cl_lock_mode mode);
  1210	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 54771 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160619/1ac4f30a/attachment-0001.obj>
