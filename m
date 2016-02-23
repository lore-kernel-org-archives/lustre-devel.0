From: kbuild test robot <lkp@intel.com>
Date: Tue, 23 Feb 2016 12:42:04 +0800
Subject: [lustre-devel] [PATCH 10/56] staging/lustre: Remove ldlm
	type/mode typedefs
In-Reply-To: <1456196074-754064-11-git-send-email-green@linuxhacker.ru>
Message-ID: <201602231215.5ZLB6MAi%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Oleg,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on v4.5-rc5 next-20160222]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/green-linuxhacker-ru/More-Lustre-cleanups/20160223-120654
config: sparc64-allyesconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=sparc64 

Note: the linux-review/green-linuxhacker-ru/More-Lustre-cleanups/20160223-120654 HEAD 340181b90a18083de9509c39311e6e7859b89274 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   In file included from drivers/staging/lustre/lustre/fid/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/fid/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/fid/fid_request.c:48:
>> drivers/staging/lustre/lustre/fid/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/fld/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/fld/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/fld/fld_request.c:49:
>> drivers/staging/lustre/lustre/fld/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/llite/../include/linux/../lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/llite/../include/linux/../obd.h:54,
                    from drivers/staging/lustre/lustre/llite/../include/linux/../obd_class.h:42,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:47,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/dcache.c:44:
>> drivers/staging/lustre/lustre/llite/../include/linux/../lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/llite/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/llite/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/llite/../include/obd_class.h:42,
                    from drivers/staging/lustre/lustre/llite/dir.c:52:
>> drivers/staging/lustre/lustre/llite/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/lmv/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/lmv/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/lmv/../include/obd_class.h:42,
                    from drivers/staging/lustre/lustre/lmv/lmv_obd.c:52:
>> drivers/staging/lustre/lustre/lmv/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/lov/lov_obd.c:51:0:
>> drivers/staging/lustre/lustre/lov/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/mdc/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/mdc/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/mdc/../include/obd_class.h:42,
                    from drivers/staging/lustre/lustre/mdc/mdc_request.c:46:
>> drivers/staging/lustre/lustre/mdc/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/mgc/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/mgc/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/mgc/../include/obd_class.h:42,
                    from drivers/staging/lustre/lustre/mgc/mgc_request.c:45:
>> drivers/staging/lustre/lustre/mgc/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:42,
                    from drivers/staging/lustre/lustre/obdclass/llog.c:50:
>> drivers/staging/lustre/lustre/obdclass/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/obdecho/../include/lustre_export.h:51:0,
                    from drivers/staging/lustre/lustre/obdecho/../include/obd.h:54,
                    from drivers/staging/lustre/lustre/obdecho/echo_client.c:40:
>> drivers/staging/lustre/lustre/obdecho/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
--
   In file included from drivers/staging/lustre/lustre/osc/osc_request.c:41:0:
>> drivers/staging/lustre/lustre/osc/../include/lustre_dlm.h:852:2: error: unknown type name 'ldlm_mode_t'
     ldlm_mode_t  lr_most_restr;
     ^
..

vim +/ldlm_mode_t +852 drivers/staging/lustre/lustre/fid/../include/lustre_dlm.h

d7e09d039 Peng Tao    2013-05-02  846  	 * List of locks that could not be granted due to conflicts and
d7e09d039 Peng Tao    2013-05-02  847  	 * that are waiting for conflicts to go away */
d7e09d039 Peng Tao    2013-05-02  848  	struct list_head		lr_waiting;
d7e09d039 Peng Tao    2013-05-02  849  	/** @} */
d7e09d039 Peng Tao    2013-05-02  850  
d7e09d039 Peng Tao    2013-05-02  851  	/* XXX No longer needed? Remove ASAP */
d7e09d039 Peng Tao    2013-05-02 @852  	ldlm_mode_t		lr_most_restr;
d7e09d039 Peng Tao    2013-05-02  853  
d7e09d039 Peng Tao    2013-05-02  854  	/** Type of locks this resource can hold. Only one type per resource. */
795336151 Oleg Drokin 2016-02-22  855  	enum ldlm_type		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */

:::::: The code at line 852 was first introduced by commit
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
Size: 45195 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160223/999baf4c/attachment-0001.obj>
