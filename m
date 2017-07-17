From: kbuild test robot <lkp@intel.com>
Date: Mon, 17 Jul 2017 15:15:35 +0800
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: constify
	attribute_group structures.
In-Reply-To: <1500270540-5928-2-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <201707171554.Ee9bmEKo%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Arvind,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on v4.13-rc1 next-20170717]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Arvind-Yadav/constify-lustre-attribute_group-structures/20170717-142957
config: sparc64-allyesconfig (attached as .config)
compiler: sparc64-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

Note: the linux-review/Arvind-Yadav/constify-lustre-attribute_group-structures/20170717-142957 HEAD a6df15f5fc00a12dffbac94e0ccc52155118946e builds fine.
      It only hurts bisectibility.

All error/warnings (new ones prefixed by >>):

>> drivers/staging/lustre/lustre/obdclass/lprocfs_status.c:1033:5: error: conflicting types for 'lprocfs_obd_setup'
    int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
        ^~~~~~~~~~~~~~~~~
   In file included from drivers/staging/lustre/lustre/obdclass/../include/obd_support.h:41:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:35,
                    from drivers/staging/lustre/lustre/obdclass/lprocfs_status.c:39:
   drivers/staging/lustre/lustre/obdclass/../include/lprocfs_status.h:470:5: note: previous declaration of 'lprocfs_obd_setup' was here
    int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
        ^~~~~~~~~~~~~~~~~
   In file included from include/linux/linkage.h:6:0,
                    from include/linux/kernel.h:6,
                    from include/asm-generic/bug.h:15,
                    from arch/sparc/include/asm/bug.h:20,
                    from include/linux/bug.h:4,
                    from include/linux/mmdebug.h:4,
                    from include/linux/gfp.h:4,
                    from include/linux/slab.h:14,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_support.h:36,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:35,
                    from drivers/staging/lustre/lustre/obdclass/lprocfs_status.c:39:
   drivers/staging/lustre/lustre/obdclass/lprocfs_status.c:1066:19: error: conflicting types for 'lprocfs_obd_setup'
    EXPORT_SYMBOL_GPL(lprocfs_obd_setup);
                      ^
   include/linux/export.h:65:21: note: in definition of macro '___EXPORT_SYMBOL'
     extern typeof(sym) sym;      \
                        ^~~
>> drivers/staging/lustre/lustre/obdclass/lprocfs_status.c:1066:1: note: in expansion of macro 'EXPORT_SYMBOL_GPL'
    EXPORT_SYMBOL_GPL(lprocfs_obd_setup);
    ^~~~~~~~~~~~~~~~~
   In file included from drivers/staging/lustre/lustre/obdclass/../include/obd_support.h:41:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:35,
                    from drivers/staging/lustre/lustre/obdclass/lprocfs_status.c:39:
   drivers/staging/lustre/lustre/obdclass/../include/lprocfs_status.h:470:5: note: previous declaration of 'lprocfs_obd_setup' was here
    int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
        ^~~~~~~~~~~~~~~~~

vim +/lprocfs_obd_setup +1033 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c

9b8013023 Oleg Drokin   2015-05-21  1032  
9b8013023 Oleg Drokin   2015-05-21 @1033  int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
9b8013023 Oleg Drokin   2015-05-21  1034  		      struct attribute_group *attrs)
d7e09d039 Peng Tao      2013-05-02  1035  {
d7e09d039 Peng Tao      2013-05-02  1036  	int rc = 0;
d7e09d039 Peng Tao      2013-05-02  1037  
9b8013023 Oleg Drokin   2015-05-21  1038  	init_completion(&obd->obd_kobj_unregister);
9b8013023 Oleg Drokin   2015-05-21  1039  	rc = kobject_init_and_add(&obd->obd_kobj, &obd_ktype,
9b8013023 Oleg Drokin   2015-05-21  1040  				  obd->obd_type->typ_kobj,
9b8013023 Oleg Drokin   2015-05-21  1041  				  "%s", obd->obd_name);
9b8013023 Oleg Drokin   2015-05-21  1042  	if (rc)
9b8013023 Oleg Drokin   2015-05-21  1043  		return rc;
9b8013023 Oleg Drokin   2015-05-21  1044  
9b8013023 Oleg Drokin   2015-05-21  1045  	if (attrs) {
9b8013023 Oleg Drokin   2015-05-21  1046  		rc = sysfs_create_group(&obd->obd_kobj, attrs);
9b8013023 Oleg Drokin   2015-05-21  1047  		if (rc) {
9b8013023 Oleg Drokin   2015-05-21  1048  			kobject_put(&obd->obd_kobj);
9b8013023 Oleg Drokin   2015-05-21  1049  			return rc;
9b8013023 Oleg Drokin   2015-05-21  1050  		}
9b8013023 Oleg Drokin   2015-05-21  1051  	}
9b8013023 Oleg Drokin   2015-05-21  1052  
61e87ab0f Dmitry Eremin 2015-05-21  1053  	obd->obd_debugfs_entry = ldebugfs_register(obd->obd_name,
61e87ab0f Dmitry Eremin 2015-05-21  1054  						   obd->obd_type->typ_debugfs_entry,
d7e09d039 Peng Tao      2013-05-02  1055  						   list, obd);
61e87ab0f Dmitry Eremin 2015-05-21  1056  	if (IS_ERR_OR_NULL(obd->obd_debugfs_entry)) {
61e87ab0f Dmitry Eremin 2015-05-21  1057  		rc = obd->obd_debugfs_entry ? PTR_ERR(obd->obd_debugfs_entry)
61e87ab0f Dmitry Eremin 2015-05-21  1058  					    : -ENOMEM;
1d8cb70c7 Greg Donald   2014-08-25  1059  		CERROR("error %d setting up lprocfs for %s\n",
1d8cb70c7 Greg Donald   2014-08-25  1060  		       rc, obd->obd_name);
61e87ab0f Dmitry Eremin 2015-05-21  1061  		obd->obd_debugfs_entry = NULL;
d7e09d039 Peng Tao      2013-05-02  1062  	}
9b8013023 Oleg Drokin   2015-05-21  1063  
d7e09d039 Peng Tao      2013-05-02  1064  	return rc;
d7e09d039 Peng Tao      2013-05-02  1065  }
da33f1dd9 Oleg Drokin   2016-02-06 @1066  EXPORT_SYMBOL_GPL(lprocfs_obd_setup);
d7e09d039 Peng Tao      2013-05-02  1067  

:::::: The code at line 1033 was first introduced by commit
:::::: 9b8013023cb62360b56c04313687e93a1c2bf3d6 staging/lustre/obdclass: Prepare for procfs to sysfs migration

:::::: TO: Oleg Drokin <green@linuxhacker.ru>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 51477 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170717/00fbe1e3/attachment-0001.bin>
