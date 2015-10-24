From: kbuild test robot <lkp@intel.com>
Date: Sun, 25 Oct 2015 07:04:17 +0800
Subject: [lustre-devel] [PATCH 7/7] staging: lustre: remove
 container_of0 and __container_of
In-Reply-To: <78ef63421d4d50eb583b22944816720eda8d4717.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <201510250700.EYBFVNfz%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test ERROR on staging/staging-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/staging-lustre-remove-uses-and-definition-of-container_of0/20151014-062751
config: x86_64-randconfig-s2-10250612 (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   In file included from drivers/staging/lustre/lustre/fid/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/fid/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/fid/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/fid/fid_request.c:48:
   drivers/staging/lustre/lustre/fid/../include/lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/fid/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/fld/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/fld/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/fld/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/fld/fld_request.c:49:
   drivers/staging/lustre/lustre/fld/../include/lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/fld/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/llite/../include/linux/../lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/linux/../obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:47,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/dcache.c:44:
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/dcache.c:48:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/llite/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/dir.c:52:
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/dir.c:58:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/llite/../include/linux/../lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/linux/../obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:47,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/llite_nfs.c:45:
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/llite_nfs.c:46:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from include/linux/list.h:8:0,
                    from include/linux/wait.h:6,
                    from include/linux/fs.h:5,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:44,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/llite_nfs.c:45:
   drivers/staging/lustre/lustre/llite/llite_nfs.c: In function 'll_nfs_get_name_filldir':
   include/linux/kernel.h:811:48: warning: initialization from incompatible pointer type [-Wincompatible-pointer-types]
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                   ^
   drivers/staging/lustre/lustre/llite/llite_nfs.c:213:26: note: in expansion of macro 'container_of'
     struct lu_dirent *lde = container_of(name, struct lu_dirent, lde_name);
                             ^
   include/linux/kernel.h:811:48: note: (near initialization for 'lde')
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                   ^
   drivers/staging/lustre/lustre/llite/llite_nfs.c:213:26: note: in expansion of macro 'container_of'
     struct lu_dirent *lde = container_of(name, struct lu_dirent, lde_name);
                             ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/llite/../lclient/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../lclient/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/../lclient/glimpse.c:44:
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/../lclient/glimpse.c:54:0:
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_dev':
>> drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/llite/../lclient/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../lclient/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/llite/../lclient/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/llite/../lclient/lcommon_cl.c:53:
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/../lclient/lcommon_cl.c:60:0:
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_dev':
>> drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2658:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2675:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lustre/llite/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/llite/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/llite/vvp_dev.c:43:
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_top':
>> drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
>> drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/vvp_dev.c:45:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2669:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/llite/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/llite/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/llite/vvp_dev.c:43:
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:738:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/vvp_dev.c:45:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
..

vim +/container_of0 +737 drivers/staging/lustre/lustre/fid/../include/lu_object.h

d7e09d039 Peng Tao 2013-05-02  731  /**
d7e09d039 Peng Tao 2013-05-02  732   * First (topmost) sub-object of given compound object
d7e09d039 Peng Tao 2013-05-02  733   */
d7e09d039 Peng Tao 2013-05-02  734  static inline struct lu_object *lu_object_top(struct lu_object_header *h)
d7e09d039 Peng Tao 2013-05-02  735  {
d7e09d039 Peng Tao 2013-05-02  736  	LASSERT(!list_empty(&h->loh_layers));
d7e09d039 Peng Tao 2013-05-02 @737  	return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
d7e09d039 Peng Tao 2013-05-02  738  }
d7e09d039 Peng Tao 2013-05-02  739  
d7e09d039 Peng Tao 2013-05-02  740  /**

:::::: The code at line 737 was first introduced by commit
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
Size: 26634 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151025/fd9127a4/attachment-0001.obj>
