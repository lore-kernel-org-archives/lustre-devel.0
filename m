From: kbuild test robot <lkp@intel.com>
Date: Wed, 14 Oct 2015 07:28:13 +0800
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: llite_nfs.c:
 replace container_of0 by container_of
In-Reply-To: <a9b823b1753239156b310ecb9ac109023629bc23.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <201510140740.tybjxpAz%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test WARNING on staging/staging-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/staging-lustre-remove-uses-and-definition-of-container_of0/20151014-062751
config: arm64-allmodconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=arm64 

All warnings (new ones prefixed by >>):

   In file included from include/linux/list.h:8:0,
                    from include/linux/wait.h:6,
                    from include/linux/fs.h:5,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:44,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/llite_nfs.c:45:
   drivers/staging/lustre/lustre/llite/llite_nfs.c: In function 'll_nfs_get_name_filldir':
   include/linux/kernel.h:811:48: warning: initialization from incompatible pointer type
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                   ^
   drivers/staging/lustre/lustre/llite/llite_nfs.c:213:26: note: in expansion of macro 'container_of'
     struct lu_dirent *lde = container_of(name, struct lu_dirent, lde_name);
                             ^
>> include/linux/kernel.h:811:48: warning: (near initialization for 'lde')
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                   ^
   drivers/staging/lustre/lustre/llite/llite_nfs.c:213:26: note: in expansion of macro 'container_of'
     struct lu_dirent *lde = container_of(name, struct lu_dirent, lde_name);
                             ^

vim +/lde +811 include/linux/kernel.h

^1da177e Linus Torvalds 2005-04-16  795  
91f68b73 Wu Fengguang   2009-01-07  796  
91f68b73 Wu Fengguang   2009-01-07  797  /*
91f68b73 Wu Fengguang   2009-01-07  798   * swap - swap value of @a and @b
91f68b73 Wu Fengguang   2009-01-07  799   */
ac7b9004 Peter Zijlstra 2009-02-04  800  #define swap(a, b) \
ac7b9004 Peter Zijlstra 2009-02-04  801  	do { typeof(a) __tmp = (a); (a) = (b); (b) = __tmp; } while (0)
91f68b73 Wu Fengguang   2009-01-07  802  
^1da177e Linus Torvalds 2005-04-16  803  /**
^1da177e Linus Torvalds 2005-04-16  804   * container_of - cast a member of a structure out to the containing structure
^1da177e Linus Torvalds 2005-04-16  805   * @ptr:	the pointer to the member.
^1da177e Linus Torvalds 2005-04-16  806   * @type:	the type of the container struct this is embedded in.
^1da177e Linus Torvalds 2005-04-16  807   * @member:	the name of the member within the struct.
^1da177e Linus Torvalds 2005-04-16  808   *
^1da177e Linus Torvalds 2005-04-16  809   */
^1da177e Linus Torvalds 2005-04-16  810  #define container_of(ptr, type, member) ({			\
^1da177e Linus Torvalds 2005-04-16 @811  	const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
^1da177e Linus Torvalds 2005-04-16  812  	(type *)( (char *)__mptr - offsetof(type,member) );})
^1da177e Linus Torvalds 2005-04-16  813  
b9d4f426 Arnaud Lacombe 2011-07-25  814  /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
b9d4f426 Arnaud Lacombe 2011-07-25  815  #ifdef CONFIG_FTRACE_MCOUNT_RECORD
b9d4f426 Arnaud Lacombe 2011-07-25  816  # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
b9d4f426 Arnaud Lacombe 2011-07-25  817  #endif
9d00f92f WANG Cong      2011-07-25  818  
58f86cc8 Rusty Russell  2014-03-24  819  /* Permissions on a sysfs file: you didn't miss the 0 prefix did you? */

:::::: The code at line 811 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 45658 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151014/0585f166/attachment-0001.obj>
