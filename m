From: kbuild test robot <lkp@intel.com>
Date: Wed, 14 Oct 2015 10:50:35 +0800
Subject: [lustre-devel] [PATCH 7/7] staging: lustre: remove
 container_of0 and __container_of
In-Reply-To: <78ef63421d4d50eb583b22944816720eda8d4717.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <201510141027.Y3GMZDIj%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test WARNING on staging/staging-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/staging-lustre-remove-uses-and-definition-of-container_of0/20151014-062751
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/fid/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/fid/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/fid/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/fid/fid_request.c:48:
   drivers/staging/lustre/lustre/fid/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/fid/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/fid/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/fld/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/fld/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/fld/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/fld/fld_request.c:49:
   drivers/staging/lustre/lustre/fld/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/fld/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/fld/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/llite/../include/linux/../lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/linux/../obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:47,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/dcache.c:44:
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/dcache.c:48:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
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
>> drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/llite/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/dir.c:52:
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/dir.c:58:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
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
>> drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/llite/../include/linux/../lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/linux/../obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/../include/linux/lustre_lite.h:47,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lite.h:45,
                    from drivers/staging/lustre/lustre/llite/llite_nfs.c:45:
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/linux/../lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/llite_nfs.c:46:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
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
>> drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/llite/../lclient/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../lclient/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/llite/../lclient/glimpse.c:44:
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/../lclient/glimpse.c:54:0:
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:26: error: expected expression before 'struct'
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
>> drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2674:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/llite/../lclient/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../lclient/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/llite/../lclient/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/llite/../lclient/lcommon_cl.c:53:
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../lclient/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/../lclient/lcommon_cl.c:60:0:
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../lclient/../include/cl_object.h:2657:26: error: expected expression before 'struct'
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
>> drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2668:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   In file included from drivers/staging/lustre/lustre/llite/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/llite/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/llite/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/llite/vvp_dev.c:43:
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/llite/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/llite/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/llite/llite_internal.h:45:0,
                    from drivers/staging/lustre/lustre/llite/vvp_dev.c:45:
   drivers/staging/lustre/lustre/llite/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/llite/../include/cl_object.h:2657:26: error: expected expression before 'struct'
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
--
>> drivers/staging/lustre/lustre/lmv/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/lmv/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lmv/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lmv/lmv_obd.c:50:
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lmv/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/lov_obd.c:48:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_obd.c:56:0:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/lov_pack.c:45:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: undefined identifier 'struct'
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/lov/lov_dev.c:44:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_dev.c:46:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lov_dev.c:46:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_page, lps_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_req, lr_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_page, lsb_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_req, lsrq_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:682:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:704:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_dev.c:46:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2658:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/lov/lov_dev.c:46:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:781:1: warning: control reaches end of non-void function [-Wreturn-type]
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lov_object.c:44:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_object.c:44:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lov_object.c:44:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_page, lps_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_req, lr_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_page, lsb_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_req, lsrq_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:726:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_object.c:44:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/lov/lov_object.c:44:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:742:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lov_page.c:43:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_page.c:43:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lov_page.c:43:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lov_lock.c:43:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_lock.c:43:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lov_lock.c:43:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_page, lps_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_req, lr_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_page, lsb_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_req, lsrq_cl);
                                 ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_lock.c:43:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/lov/lov_lock.c:43:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:726:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lov_io.c:44:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lov_io.c:44:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lov_io.c:44:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_page, lps_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_req, lr_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_page, lsb_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_req, lsrq_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:682:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:726:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:748:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: undefined identifier 'struct'
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lovsub_dev.c:41:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lovsub_dev.c:41:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lovsub_dev.c:41:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: undefined identifier 'struct'
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lovsub_object.c:43:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lovsub_object.c:43:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lovsub_object.c:43:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_page, lps_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:30: error: expected expression before 'struct'
     return container_of0(slice, struct lov_req, lr_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_page':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_page, lsb_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_req':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:30: error: expected expression before 'struct'
     return container_of0(slice, struct lovsub_req, lsrq_cl);
                                 ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:698:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lovsub_object.c:43:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2669:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lovsub_page.c:41:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lovsub_page.c:41:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lovsub_page.c:41:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov_page':
--
>> drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:40: sparse: got lov_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:33: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:40: sparse: got lovsub_device
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:42: sparse: got lov_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:35: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:42: sparse: got lovsub_object
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:775:44: sparse: got lov_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:780:44: sparse: got lov_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:787:44: sparse: got lovsub_page
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:37: sparse: typename in expression
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:792:44: sparse: got lovsub_req
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/lov/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/lov/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/lov/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/lov/lovsub_lock.c:43:
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/lov/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/lov/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/lov/lov_cl_internal.h:52:0,
                    from drivers/staging/lustre/lustre/lov/lovsub_lock.c:43:
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/lov/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/lov/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/lov/lovsub_lock.c:43:0:
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:681:26: error: expected expression before 'struct'
     return container_of0(d, struct lov_device, ld_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:697:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub_dev':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:703:26: error: expected expression before 'struct'
     return container_of0(d, struct lovsub_device, acid_cl);
                             ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:719:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl.co_lu);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lov':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:725:28: error: expected expression before 'struct'
     return container_of0(obj, struct lov_object, lo_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'cl2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:741:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl);
                               ^
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h: In function 'lu2lovsub':
   drivers/staging/lustre/lustre/lov/lov_cl_internal.h:747:28: error: expected expression before 'struct'
     return container_of0(obj, struct lovsub_object, lso_cl.co_lu);
                               ^
--
>> drivers/staging/lustre/lustre/mdc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/mdc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/mdc/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/mdc/mdc_request.c:46:
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/mdc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/mgc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/mgc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/mgc/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/mgc/mgc_request.c:45:
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/mgc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/llog_obd.c:39:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/class_obd.c:41:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/obdclass/class_obd.c:47:0:
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/lu_object.c:53:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:738:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/cl_object.c:56:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/obdclass/cl_object.c:61:0:
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2669:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/cl_object.c:56:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:738:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/obdclass/cl_object.c:61:0:
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2658:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/cl_page.c:44:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/obdclass/cl_page.c:48:0:
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/cl_lock.c:43:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/obdclass/cl_lock.c:47:0:
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/obdclass/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/cl_io.c:43:
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/obdclass/cl_io.c:47:0:
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdclass/../include/cl_object.h:2658:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/obdclass/linux/../../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdclass/linux/../../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/obdclass/linux/linux-module.c:71:
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdclass/linux/../../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:40: sparse: got cl_object_header
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2674:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/obdecho/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/obdecho/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/obdecho/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/obdecho/echo_client.c:40:
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/obdecho/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/obdecho/echo_client.c:45:0:
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2658:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2669:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2675:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/obdecho/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/osc/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/osc/osc_page.c:43:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_page.c:43:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:55:0,
                    from drivers/staging/lustre/lustre/osc/osc_page.c:43:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_page.c:43:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:551:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:502:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:572:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_page.c:43:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_page.c:43:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:518:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/osc/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/osc/osc_lock.c:47:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_lock.c:47:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:55:0,
                    from drivers/staging/lustre/lustre/osc/osc_lock.c:47:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_lock.c:47:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:572:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:518:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_lock.c:47:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_lock.c:47:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:502:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/osc/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/osc/osc_io.c:44:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_io.c:44:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:55:0,
                    from drivers/staging/lustre/lustre/osc/osc_io.c:44:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_io.c:44:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:518:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:551:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:502:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_io.c:44:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_io.c:44:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:572:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/osc/osc_quota.c:31:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_internal.h:104:0,
                    from drivers/staging/lustre/lustre/osc/osc_quota.c:32:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_quota.c:32:0:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/osc/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/osc/osc_cache.c:44:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_cache.c:44:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:55:0,
                    from drivers/staging/lustre/lustre/osc/osc_cache.c:44:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cache.c:44:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:556:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:502:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:518:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: undefined identifier 'struct'
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:29: sparse: not a function <noident>
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:29: sparse: not a function <noident>
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/osc/lproc_osc.c:40:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_internal.h:104:0,
                    from drivers/staging/lustre/lustre/osc/lproc_osc.c:43:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/lproc_osc.c:43:0:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   drivers/staging/lustre/lustre/osc/osc_internal.h:178:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_dlm.h:51,
                    from drivers/staging/lustre/lustre/osc/osc_request.c:41:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_internal.h:104:0,
                    from drivers/staging/lustre/lustre/osc/osc_request.c:53:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_request.c:53:0:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_request.c:54:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:556:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/osc/osc_dev.c:44:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_dev.c:46:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:55:0,
                    from drivers/staging/lustre/lustre/osc/osc_dev.c:46:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_dev.c:46:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:502:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_dev.c:46:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2658:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:40: sparse: got cl_object_header
>> drivers/staging/lustre/lustre/osc/osc_internal.h:177:45: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:52: sparse: got osc_device
>> drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:33: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:40: sparse: got osc_device
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:42: sparse: got osc_object
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:44: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:35: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:42: sparse: got osc_page
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:37: sparse: typename in expression
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:44: sparse: got osc_lock
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:16: sparse: undefined identifier 'container_of0'
>> drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:33: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:16: sparse: undefined identifier 'container_of0'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:35: sparse: undefined identifier 'struct'
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:29: sparse: not a function <noident>
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:16: sparse: undefined identifier 'container_of0'
   In file included from drivers/staging/lustre/lustre/osc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/osc/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/osc/../include/obd.h:52,
                    from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:51,
                    from drivers/staging/lustre/lustre/osc/osc_object.c:43:
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/osc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/osc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_object.c:43:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:55:0,
                    from drivers/staging/lustre/lustre/osc/osc_object.c:43:
   drivers/staging/lustre/lustre/osc/osc_internal.h: In function 'obd2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_internal.h:177:38: error: expected expression before 'struct'
     return container_of0(d->obd_lu_dev, struct osc_device, od_cl.cd_lu_dev);
                                         ^
   In file included from drivers/staging/lustre/lustre/osc/osc_object.c:43:0:
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:501:26: error: expected expression before 'struct'
     return container_of0(d, struct osc_device, od_cl.cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:517:28: error: expected expression before 'struct'
     return container_of0(obj, struct osc_object, oo_cl);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_page':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:550:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_page, ops_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'oap2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:555:28: error: expected expression before 'struct'
     return container_of0(oap, struct osc_page, ops_oap);
                               ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc_lock':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:571:30: error: expected expression before 'struct'
     return container_of0(slice, struct osc_lock, ols_cl);
                                 ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'cl2osc':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:518:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h: In function 'lu2osc_dev':
   drivers/staging/lustre/lustre/osc/osc_cl_internal.h:502:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   In file included from drivers/staging/lustre/lustre/osc/osc_cl_internal.h:53:0,
                    from drivers/staging/lustre/lustre/osc/osc_object.c:43:
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2675:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2669:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   drivers/staging/lustre/lustre/osc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/osc/../include/cl_object.h:2691:1: warning: control reaches end of non-void function [-Wreturn-type]
    }
    ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lustre_dlm.h:51,
                    from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_resource.c:43:
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lustre_lib.h:64,
                    from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lustre_dlm.h:51,
                    from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_pool.c:101:
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/ldlm_pool.c:102:0:
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:57: sparse: got lu_object
   In file included from drivers/staging/lustre/lustre/ptlrpc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/ptlrpc/../include/obd_class.h:41,
                    from drivers/staging/lustre/lustre/ptlrpc/client.c:42:
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   cc1: some warnings being treated as errors
--
>> drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:57: sparse: got lu_object
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:50: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:57: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:57: sparse: got lu_object
>> drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2657:33: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2657:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2657:40: sparse: got cl_device
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2668:33: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2668:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2668:40: sparse: got cl_object
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2674:36: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2674:43: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2674:43: sparse: got cl_object_conf
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2685:47: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2685:54: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2685:54: sparse: got cl_device
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2690:33: sparse: typename in expression
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2690:40: sparse: Expected ) in function call
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2690:40: sparse: got cl_object_header
   In file included from drivers/staging/lustre/lustre/ptlrpc/../include/lustre_net.h:65:0,
                    from drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c:60:
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h: In function 'lu_object_top':
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:9: error: implicit declaration of function 'container_of0' [-Werror=implicit-function-declaration]
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
            ^
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:737:43: error: expected expression before 'struct'
     return container_of0(h->loh_layers.next, struct lu_object, lo_linkage);
                                              ^
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h: In function 'lu_object_next':
   drivers/staging/lustre/lustre/ptlrpc/../include/lu_object.h:745:43: error: expected expression before 'struct'
     return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);
                                              ^
   In file included from drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c:65:0:
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h: In function 'lu2cl_dev':
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2657:26: error: expected expression before 'struct'
     return container_of0(d, struct cl_device, cd_lu_dev);
                             ^
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h: In function 'lu2cl':
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2668:26: error: expected expression before 'struct'
     return container_of0(o, struct cl_object, co_lu);
                             ^
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h: In function 'lu2cl_conf':
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2674:29: error: expected expression before 'struct'
     return container_of0(conf, struct cl_object_conf, coc_lu);
                                ^
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h: In function 'cl_object_device':
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2685:40: error: expected expression before 'struct'
     return container_of0(o->co_lu.lo_dev, struct cl_device, cd_lu_dev);
                                           ^
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h: In function 'luh2coh':
   drivers/staging/lustre/lustre/ptlrpc/../include/cl_object.h:2690:26: error: expected expression before 'struct'
     return container_of0(h, struct cl_object_header, coh_lu);
                             ^
   cc1: some warnings being treated as errors

vim +737 drivers/staging/lustre/lustre/fid/../include/lu_object.h

d7e09d039 Peng Tao 2013-05-02  721  				       struct lu_device *dev,
d7e09d039 Peng Tao 2013-05-02  722  				       const struct lu_fid *f,
d7e09d039 Peng Tao 2013-05-02  723  				       const struct lu_object_conf *conf);
d7e09d039 Peng Tao 2013-05-02  724  /** @} caching */
d7e09d039 Peng Tao 2013-05-02  725  
d7e09d039 Peng Tao 2013-05-02  726  /** \name helpers
d7e09d039 Peng Tao 2013-05-02  727   * Helpers.
d7e09d039 Peng Tao 2013-05-02  728   * @{
d7e09d039 Peng Tao 2013-05-02  729   */
d7e09d039 Peng Tao 2013-05-02  730  
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
d7e09d039 Peng Tao 2013-05-02  741   * Next sub-object in the layering
d7e09d039 Peng Tao 2013-05-02  742   */
d7e09d039 Peng Tao 2013-05-02  743  static inline struct lu_object *lu_object_next(const struct lu_object *o)
d7e09d039 Peng Tao 2013-05-02  744  {
d7e09d039 Peng Tao 2013-05-02  745  	return container_of0(o->lo_linkage.next, struct lu_object, lo_linkage);

:::::: The code at line 737 was first introduced by commit
:::::: d7e09d0397e84eefbabfd9cb353221f3c6448d83 staging: add Lustre file system client support

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
