From: NeilBrown <neilb@suse.com>
Date: Fri, 08 Jun 2018 16:59:47 +1000
Subject: [lustre-devel] [PATCH 10/11] staging: lustre: move ldlm into
 ptlrpc
In-Reply-To: <87sh5zlyf4.fsf@notabene.neil.brown.name>
References: <152826510267.16761.14361003167157833896.stgit@noble>
 <152826511923.16761.9237280635711887801.stgit@noble>
 <alpine.LFD.2.21.1806070546210.23188@casper.infradead.org>
 <87sh5zlyf4.fsf@notabene.neil.brown.name>
Message-ID: <87tvqdlq58.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jun 07 2018, NeilBrown wrote:

> On Thu, Jun 07 2018, James Simmons wrote:
>
>>> The ldlm code is built into the ptlrpc module, yet it lived in a
>>> separate directory.  This requires filename editing in the Makefile
>>> and make it difficult to e.g. build the .s file for code in ldlm.
>>> 
>>> All the ldlm files have distinctive names so confusion from having
>>> ptlrpc and ldlm in the same directory is unlikely.  So move them all
>>> into ptlrpc.
>>
>> Nak. The reason is it would be nice to keep the directory structure.
>> What really needs to be done and Oleg has looked into it is to reduced
>> the number of modules created down to two, one for LNet and the other
>> lustre.ko. This also is a step in the right direction to remove the
>> create struct obd_ops and struct md_ops pointer madness. Well their
>> is the issue with obd echo client but we can deal with this at a later 
>> date. Also the number of EXPORT_SYMBOLS and things will greatly reduce.
>
> Yeah, you are probably right.
> I had a bit of a look at how to build everything into a
> single module.  You can do with by having a single make
> file that lists parts from other directories - the same way
> that ptlrpc includes files from ldlm - but that is rather ugly.
>
> I've very nearly got it working using the lib-y infrastructure.
> I can build lnet as a single module, but the dependency calc isn't
> quite right so things happen in the wrong order.  The build
> fails the first time because some files don't exist, then
> succeeds on the second run.
> Hopefully I'll figure out how to make it work tomorrow.

I needed lots of changes over my original hack, but I think I have
it quite close now.
This is just a dump of what I have. It needs to be properly split up
and documented but I thought it would be useful for people do see how
I think this should be done.

Obviously there is a big change to non-lustre code here.  That might
take a bit of selling upstream, but I think it is worth trying.  We
aren't the only project that would benefit from this.

What I have done is created infrastructure so that a Makefile
can declare that some .o files are built for use in a module and
placed in "mod.a".  Then another Makefile can declare that a module
includes mod.a from some other directory.
So now lustre/lnet and lustre/lustre each have a module.c and build a
mod.a from various subdirectories, and combine these into a single
module.

As yet this is only compile tested.  I suspect it will work, but I won't
find out until next week.

NeilBrown


diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 8bdb1dc4072c..9ae14ecb1e32 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -15,6 +15,8 @@ obj-y :=
 obj-m :=
 lib-y :=
 lib-m :=
+modobj-y :=
+modobj-m :=
 always :=
 targets :=
 subdir-y :=
@@ -80,12 +82,16 @@ ifneq ($(strip $(real-obj-y) $(need-builtin)),)
 builtin-target := $(obj)/built-in.a
 endif
 
+ifneq ($(strip $(modobj-m)),)
+modobj-target := $(obj)/mod.a
+endif
+
 modorder-target := $(obj)/modules.order
 
 # We keep a list of all modules in $(MODVERDIR)
 
 __build: $(if $(KBUILD_BUILTIN),$(builtin-target) $(lib-target) $(extra-y)) \
-	 $(if $(KBUILD_MODULES),$(obj-m) $(modorder-target)) \
+	 $(if $(KBUILD_MODULES),$(obj-m) $(modobj-target) $(modorder-target)) \
 	 $(subdir-ym) $(always)
 	@:
 
@@ -119,17 +125,19 @@ modkern_cflags =                                          \
 		$(KBUILD_CFLAGS_KERNEL) $(CFLAGS_KERNEL))
 quiet_modtag := $(empty)   $(empty)
 
-$(real-obj-m)        : part-of-module := y
-$(real-obj-m:.o=.i)  : part-of-module := y
-$(real-obj-m:.o=.s)  : part-of-module := y
-$(real-obj-m:.o=.lst): part-of-module := y
+_mod_obj = $(real-obj-m) $(real-modobj-m)
+
+$(_mod_obj)        : part-of-module := y
+$(_mod_obj:.o=.i)  : part-of-module := y
+$(_mod_obj:.o=.s)  : part-of-module := y
+$(_mod_obj:.o=.lst): part-of-module := y
 
-$(real-obj-m)        : quiet_modtag := [M]
-$(real-obj-m:.o=.i)  : quiet_modtag := [M]
-$(real-obj-m:.o=.s)  : quiet_modtag := [M]
-$(real-obj-m:.o=.lst): quiet_modtag := [M]
+$(_mod_obj)        : quiet_modtag := [M]
+$(_mod_obj:.o=.i)  : quiet_modtag := [M]
+$(_mod_obj:.o=.s)  : quiet_modtag := [M]
+$(_mod_obj:.o=.lst): quiet_modtag := [M]
 
-$(obj-m)             : quiet_modtag := [M]
+$(obj-m)           : quiet_modtag := [M]
 
 quiet_cmd_cc_s_c = CC $(quiet_modtag)  $@
 cmd_cc_s_c       = $(CC) $(c_flags) $(DISABLE_LTO) -fverbose-asm -S -o $@ $<
@@ -508,6 +516,22 @@ targets += $(obj)/lib-ksyms.o
 
 endif
 
+ifdef modobj-target
+
+quiet_cmd_ar_modobj = AR      $@
+      cmd_ar_modobj = rm -f $@; \
+                    $(AR) rcTP$(KBUILD_ARFLAGS) $@ $(filter $(real-modobj-m), $^)
+
+$(modobj-target): $(real-modobj-m) FORCE
+	$(call if_changed,ar_modobj)
+
+targets += $(modobj-target)
+
+# to build a mod.a, build the directory
+$(filter %/mod.a, $(modobj-m)) : %/mod.a : %
+
+endif # modobj-target
+
 #
 # Rule to link composite objects
 #
@@ -525,7 +549,7 @@ $($(subst $(obj)/,,$(@:.o=-y)))       \
 $($(subst $(obj)/,,$(@:.o=-m)))), $^)
 
 quiet_cmd_link_multi-m = LD [M]  $@
-cmd_link_multi-m = $(LD) $(ld_flags) -r -o $@ $(link_multi_deps) $(cmd_secanalysis)
+cmd_link_multi-m = $(LD) $(ld_flags) -r -o $@ $(patsubst %/mod.a, --whole-archive %/mod.a --no-whole-archive , $(link_multi_deps)) $(cmd_secanalysis)
 
 $(multi-used-m): FORCE
 	$(call if_changed,link_multi-m)
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 5af34a2b0cd9..315590b841b6 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -12,9 +12,13 @@ KBUILD_CFLAGS += $(subdir-ccflags-y)
 # Figure out what we need to build from the various variables
 # ===========================================================================
 
+# objects in modobj-y are treated identically to obj-y
+obj-y := $(obj-y) $(filter-out $(modobj-y), $(obj-y))
+
 # When an object is listed to be built compiled-in and modular,
 # only build the compiled-in version
 obj-m := $(filter-out $(obj-y),$(obj-m))
+modobj-m := $(filter-out $(obj-m), $(modobj-m))
 
 # Libraries are always collected in one lib file.
 # Filter out objects already built-in
@@ -31,12 +35,17 @@ modorder	:= $(patsubst %/,%/modules.order, $(filter %/, $(obj-y)) $(obj-m:.o=.ko
 #   and add the directory to the list of dirs to descend into: $(subdir-y)
 # o if we encounter foo/ in $(obj-m), remove it from $(obj-m)
 #   and add the directory to the list of dirs to descend into: $(subdir-m)
+# o if we encounter foo/ in $(modobj-m), replace it by foo/mod.a
+#   and add the directory to the list of dirs to descend into: $(subdir-m)
 __subdir-y	:= $(patsubst %/,%,$(filter %/, $(obj-y)))
 subdir-y	+= $(__subdir-y)
 __subdir-m	:= $(patsubst %/,%,$(filter %/, $(obj-m)))
 subdir-m	+= $(__subdir-m)
+__subdir-m	:= $(patsubst %/,%,$(filter %/, $(modobj-m)))
+subdir-m	+= $(__subdir-m)
 obj-y		:= $(patsubst %/, %/built-in.a, $(obj-y))
 obj-m		:= $(filter-out %/, $(obj-m))
+modobj-m	:= $(patsubst %/, %/mod.a, $(modobj-m))
 
 # Subdirectories we need to descend into
 subdir-ym	:= $(sort $(subdir-y) $(subdir-m))
@@ -48,13 +57,15 @@ multi-used   := $(multi-used-y) $(multi-used-m)
 single-used-m := $(sort $(filter-out $(multi-used-m),$(obj-m)))
 
 # $(subdir-obj-y) is the list of objects in $(obj-y) which uses dir/ to
-# tell kbuild to descend
+# tell kbuild to descend.  Similarly $(subdir-modobj-m) for $(modobj-m)
 subdir-obj-y := $(filter %/built-in.a, $(obj-y))
+subdir-modobj-m := $(filter %/mod.a, $(modobj-m))
 
 # Replace multi-part objects by their individual parts,
 # including built-in.a from subdirectories
 real-obj-y := $(foreach m, $(obj-y), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m)))
 real-obj-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m)),$(m)))
+real-modobj-m := $(foreach m, $(modobj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m)),$(m)))
 
 # DTB
 # If CONFIG_OF_ALL_DTBS is enabled, all DT blobs are built
@@ -68,10 +79,12 @@ always		:= $(addprefix $(obj)/,$(always))
 targets		:= $(addprefix $(obj)/,$(targets))
 modorder	:= $(addprefix $(obj)/,$(modorder))
 obj-m		:= $(addprefix $(obj)/,$(obj-m))
+modobj-m	:= $(addprefix $(obj)/,$(modobj-m))
 lib-y		:= $(addprefix $(obj)/,$(lib-y))
 subdir-obj-y	:= $(addprefix $(obj)/,$(subdir-obj-y))
 real-obj-y	:= $(addprefix $(obj)/,$(real-obj-y))
 real-obj-m	:= $(addprefix $(obj)/,$(real-obj-m))
+real-modobj-m	:= $(addprefix $(obj)/,$(real-modobj-m))
 single-used-m	:= $(addprefix $(obj)/,$(single-used-m))
 multi-used-m	:= $(addprefix $(obj)/,$(multi-used-m))
 subdir-ym	:= $(addprefix $(obj)/,$(subdir-ym))
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 973c17a1c4a1..916fb78fd833 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -76,6 +76,14 @@ extern struct lnet the_lnet;	/* THE network */
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
+int libcfs_init(void);
+int ko2iblnd_init(void);
+int ksocklnd_init(void);
+
+void libcfs_exit(void);
+void ko2iblnd_exit(void);
+void ksocklnd_exit(void);
+
 static inline int lnet_is_route_alive(struct lnet_route *route)
 {
 	/* gateway is down */
diff --git a/drivers/staging/lustre/lnet/Makefile b/drivers/staging/lustre/lnet/Makefile
index 0a380fe88ce8..058243c7a080 100644
--- a/drivers/staging/lustre/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/Makefile
@@ -1 +1,10 @@
-obj-$(CONFIG_LNET) += libcfs/ lnet/ klnds/ selftest/
+# SPDX-License-Identifier: GPL-2.0
+
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
+obj-$(CONFIG_LNET) += selftest/
+modobj-$(CONFIG_LNET) += libcfs/ lnet/ klnds/
+
+obj-$(CONFIG_LNET) += lnet.o
+lnet-objs = module.o mod.a
diff --git a/drivers/staging/lustre/lnet/klnds/Makefile b/drivers/staging/lustre/lnet/klnds/Makefile
index c23e4f67f837..79dd66a6a7a1 100644
--- a/drivers/staging/lustre/lnet/klnds/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_LNET) += o2iblnd/  socklnd/
+modobj-$(CONFIG_LNET) += o2iblnd/  socklnd/
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
index 4affe1d79948..6a0eb81cccfe 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/Makefile
@@ -1,5 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LNET_XPRT_IB) += ko2iblnd.o
-ko2iblnd-y := o2iblnd.o o2iblnd_cb.o o2iblnd_modparams.o
+modobj-$(CONFIG_LNET) := o2iblnd.o o2iblnd_cb.o o2iblnd_modparams.o
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index f0b4eb42bc1d..4098c4566fce 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2921,15 +2921,13 @@ static struct lnet_lnd the_o2iblnd = {
 	.lnd_recv	= kiblnd_recv,
 };
 
-static void __exit ko2iblnd_exit(void)
+void __exit ko2iblnd_exit(void)
 {
 	lnet_unregister_lnd(&the_o2iblnd);
 }
 
-static int __init ko2iblnd_init(void)
+int __init ko2iblnd_init(void)
 {
-	int rc;
-
 	BUILD_BUG_ON(sizeof(struct kib_msg) > IBLND_MSG_SIZE);
 	BUILD_BUG_ON(offsetof(struct kib_msg,
 			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
@@ -2940,19 +2938,7 @@ static int __init ko2iblnd_init(void)
 
 	kiblnd_tunables_init();
 
-	rc = libcfs_setup();
-	if (rc)
-		return rc;
-
 	lnet_register_lnd(&the_o2iblnd);
 
 	return 0;
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("OpenIB gen2 LNet Network Driver");
-MODULE_VERSION("2.7.0");
-MODULE_LICENSE("GPL");
-
-module_init(ko2iblnd_init);
-module_exit(ko2iblnd_exit);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
index a7da1abfc804..231e1ab5dcf8 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/Makefile
@@ -1,6 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LNET) += ksocklnd.o
-
-ksocklnd-y := socklnd.o socklnd_cb.o socklnd_proto.o socklnd_modparams.o socklnd_lib.o
+modobj-$(CONFIG_LNET) := socklnd.o socklnd_cb.o socklnd_proto.o socklnd_modparams.o socklnd_lib.o
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index f01b34ac1a53..d892bdef7133 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2875,12 +2875,12 @@ ksocknal_startup(struct lnet_ni *ni)
 	return -ENETDOWN;
 }
 
-static void __exit ksocklnd_exit(void)
+void __exit ksocklnd_exit(void)
 {
 	lnet_unregister_lnd(&the_ksocklnd);
 }
 
-static int __init ksocklnd_init(void)
+int __init ksocklnd_init(void)
 {
 	int rc;
 
@@ -2903,19 +2903,7 @@ static int __init ksocklnd_init(void)
 	if (rc)
 		return rc;
 
-	rc = libcfs_setup();
-	if (rc)
-		return rc;
-
 	lnet_register_lnd(&the_ksocklnd);
 
 	return 0;
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("TCP Socket LNet Network Driver");
-MODULE_VERSION("2.7.0");
-MODULE_LICENSE("GPL");
-
-module_init(ksocklnd_init);
-module_exit(ksocklnd_exit);
diff --git a/drivers/staging/lustre/lnet/libcfs/Makefile b/drivers/staging/lustre/lnet/libcfs/Makefile
index 6a1b232da495..6f169a7b35ae 100644
--- a/drivers/staging/lustre/lnet/libcfs/Makefile
+++ b/drivers/staging/lustre/lnet/libcfs/Makefile
@@ -2,8 +2,6 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LNET) += libcfs.o
-
 libcfs-obj-y += linux-tracefile.o linux-debug.o
 libcfs-obj-y += linux-crypto.o
 libcfs-obj-y += linux-crypto-adler.o
@@ -13,4 +11,4 @@ libcfs-obj-y += libcfs_string.o hash.o
 libcfs-obj-$(CONFIG_SMP) += libcfs_cpu.o
 libcfs-obj-y += libcfs_mem.o libcfs_lock.o
 
-libcfs-objs := $(libcfs-obj-y)
+modobj-$(CONFIG_LNET) += $(libcfs-obj-y)
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 02c404c6738e..b4ec1ebabc6d 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -688,7 +688,7 @@ int libcfs_setup(void)
 }
 EXPORT_SYMBOL(libcfs_setup);
 
-static int libcfs_init(void)
+int libcfs_init(void)
 {
 	int rc;
 
@@ -700,7 +700,7 @@ static int libcfs_init(void)
 	return rc;
 }
 
-static void libcfs_exit(void)
+void libcfs_exit(void)
 {
 	int rc;
 
@@ -720,11 +720,3 @@ static void libcfs_exit(void)
 	if (rc)
 		pr_err("LustreError: libcfs_debug_cleanup: %d\n", rc);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre helper library");
-MODULE_VERSION(LIBCFS_VERSION);
-MODULE_LICENSE("GPL");
-
-module_init(libcfs_init);
-module_exit(libcfs_exit);
diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index 0a9d70924fe0..f9f4eb125f6d 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -2,9 +2,7 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LNET) += lnet.o
-
-lnet-y := api-ni.o config.o nidstrings.o net_fault.o		\
+modobj-$(CONFIG_LNET) := api-ni.o config.o nidstrings.o net_fault.o		\
 	  lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o	\
-	  lib-socket.o lib-move.o module.o lo.o			\
+	  lib-socket.o lib-move.o lo.o			\
 	  router.o router_proc.o acceptor.o peer.o
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
deleted file mode 100644
index 9d06664f0c17..000000000000
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ /dev/null
@@ -1,239 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, 2015, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-
-#define DEBUG_SUBSYSTEM S_LNET
-
-#include <linux/lnet/lib-lnet.h>
-#include <uapi/linux/lnet/lnet-dlc.h>
-
-static int config_on_load;
-module_param(config_on_load, int, 0444);
-MODULE_PARM_DESC(config_on_load, "configure network at module load");
-
-static struct mutex lnet_config_mutex;
-
-static int
-lnet_configure(void *arg)
-{
-	/* 'arg' only there so I can be passed to cfs_create_thread() */
-	int rc = 0;
-
-	mutex_lock(&lnet_config_mutex);
-
-	if (!the_lnet.ln_niinit_self) {
-		rc = try_module_get(THIS_MODULE);
-
-		if (rc != 1)
-			goto out;
-
-		rc = LNetNIInit(LNET_PID_LUSTRE);
-		if (rc >= 0) {
-			the_lnet.ln_niinit_self = 1;
-			rc = 0;
-		} else {
-			module_put(THIS_MODULE);
-		}
-	}
-
-out:
-	mutex_unlock(&lnet_config_mutex);
-	return rc;
-}
-
-static int
-lnet_unconfigure(void)
-{
-	int refcount;
-
-	mutex_lock(&lnet_config_mutex);
-
-	if (the_lnet.ln_niinit_self) {
-		the_lnet.ln_niinit_self = 0;
-		LNetNIFini();
-		module_put(THIS_MODULE);
-	}
-
-	mutex_lock(&the_lnet.ln_api_mutex);
-	refcount = the_lnet.ln_refcount;
-	mutex_unlock(&the_lnet.ln_api_mutex);
-
-	mutex_unlock(&lnet_config_mutex);
-	return !refcount ? 0 : -EBUSY;
-}
-
-static int
-lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
-{
-	struct lnet_ioctl_config_data *conf =
-		(struct lnet_ioctl_config_data *)hdr;
-	int rc;
-
-	if (conf->cfg_hdr.ioc_len < sizeof(*conf))
-		return -EINVAL;
-
-	mutex_lock(&lnet_config_mutex);
-	if (!the_lnet.ln_niinit_self) {
-		rc = -EINVAL;
-		goto out_unlock;
-	}
-	rc = lnet_dyn_add_ni(LNET_PID_LUSTRE, conf);
-out_unlock:
-	mutex_unlock(&lnet_config_mutex);
-
-	return rc;
-}
-
-static int
-lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
-{
-	struct lnet_ioctl_config_data *conf =
-		(struct lnet_ioctl_config_data *)hdr;
-	int rc;
-
-	if (conf->cfg_hdr.ioc_len < sizeof(*conf))
-		return -EINVAL;
-
-	mutex_lock(&lnet_config_mutex);
-	if (!the_lnet.ln_niinit_self) {
-		rc = -EINVAL;
-		goto out_unlock;
-	}
-	rc = lnet_dyn_del_ni(conf->cfg_net);
-out_unlock:
-	mutex_unlock(&lnet_config_mutex);
-
-	return rc;
-}
-
-static int
-lnet_ioctl(struct notifier_block *nb,
-	   unsigned long cmd, void *vdata)
-{
-	int rc;
-	struct libcfs_ioctl_hdr *hdr = vdata;
-
-	switch (cmd) {
-	case IOC_LIBCFS_CONFIGURE: {
-		struct libcfs_ioctl_data *data =
-			(struct libcfs_ioctl_data *)hdr;
-
-		if (data->ioc_hdr.ioc_len < sizeof(*data)) {
-			rc = -EINVAL;
-		} else {
-			the_lnet.ln_nis_from_mod_params = data->ioc_flags;
-			rc = lnet_configure(NULL);
-		}
-		break;
-	}
-
-	case IOC_LIBCFS_UNCONFIGURE:
-		rc = lnet_unconfigure();
-		break;
-
-	case IOC_LIBCFS_ADD_NET:
-		rc = lnet_dyn_configure(hdr);
-		break;
-
-	case IOC_LIBCFS_DEL_NET:
-		rc = lnet_dyn_unconfigure(hdr);
-		break;
-
-	default:
-		/*
-		 * Passing LNET_PID_ANY only gives me a ref if the net is up
-		 * already; I'll need it to ensure the net can't go down while
-		 * I'm called into it
-		 */
-		rc = LNetNIInit(LNET_PID_ANY);
-		if (rc >= 0) {
-			rc = LNetCtl(cmd, hdr);
-			LNetNIFini();
-		}
-		break;
-	}
-	return notifier_from_ioctl_errno(rc);
-}
-
-static struct notifier_block lnet_ioctl_handler = {
-	.notifier_call = lnet_ioctl,
-};
-
-static int __init lnet_init(void)
-{
-	int rc;
-
-	mutex_init(&lnet_config_mutex);
-
-	rc = libcfs_setup();
-	if (rc)
-		return rc;
-
-	rc = lnet_lib_init();
-	if (rc) {
-		CERROR("lnet_lib_init: error %d\n", rc);
-		return rc;
-	}
-
-	rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
-					      &lnet_ioctl_handler);
-	LASSERT(!rc);
-
-	if (config_on_load) {
-		/*
-		 * Have to schedule a separate thread to avoid deadlocking
-		 * in modload
-		 */
-		(void)kthread_run(lnet_configure, NULL, "lnet_initd");
-	}
-
-	return 0;
-}
-
-static void __exit lnet_exit(void)
-{
-	int rc;
-
-	rc = blocking_notifier_chain_unregister(&libcfs_ioctl_list,
-						&lnet_ioctl_handler);
-	LASSERT(!rc);
-
-	lnet_lib_exit();
-}
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Networking layer");
-MODULE_VERSION(LNET_VERSION);
-MODULE_LICENSE("GPL");
-
-module_init(lnet_init);
-module_exit(lnet_exit);
diff --git a/drivers/staging/lustre/lnet/module.c b/drivers/staging/lustre/lnet/module.c
new file mode 100644
index 000000000000..2a51ae6542fb
--- /dev/null
+++ b/drivers/staging/lustre/lnet/module.c
@@ -0,0 +1,250 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2004, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, 2015, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#define DEBUG_SUBSYSTEM S_LNET
+
+#include <linux/lnet/lib-lnet.h>
+#include <uapi/linux/lnet/lnet-dlc.h>
+
+static int config_on_load;
+module_param(config_on_load, int, 0444);
+MODULE_PARM_DESC(config_on_load, "configure network at module load");
+
+static struct mutex lnet_config_mutex;
+
+static int
+lnet_configure(void *arg)
+{
+	/* 'arg' only there so I can be passed to cfs_create_thread() */
+	int rc = 0;
+
+	mutex_lock(&lnet_config_mutex);
+
+	if (!the_lnet.ln_niinit_self) {
+		rc = try_module_get(THIS_MODULE);
+
+		if (rc != 1)
+			goto out;
+
+		rc = LNetNIInit(LNET_PID_LUSTRE);
+		if (rc >= 0) {
+			the_lnet.ln_niinit_self = 1;
+			rc = 0;
+		} else {
+			module_put(THIS_MODULE);
+		}
+	}
+
+out:
+	mutex_unlock(&lnet_config_mutex);
+	return rc;
+}
+
+static int
+lnet_unconfigure(void)
+{
+	int refcount;
+
+	mutex_lock(&lnet_config_mutex);
+
+	if (the_lnet.ln_niinit_self) {
+		the_lnet.ln_niinit_self = 0;
+		LNetNIFini();
+		module_put(THIS_MODULE);
+	}
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+	refcount = the_lnet.ln_refcount;
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	mutex_unlock(&lnet_config_mutex);
+	return !refcount ? 0 : -EBUSY;
+}
+
+static int
+lnet_dyn_configure(struct libcfs_ioctl_hdr *hdr)
+{
+	struct lnet_ioctl_config_data *conf =
+		(struct lnet_ioctl_config_data *)hdr;
+	int rc;
+
+	if (conf->cfg_hdr.ioc_len < sizeof(*conf))
+		return -EINVAL;
+
+	mutex_lock(&lnet_config_mutex);
+	if (!the_lnet.ln_niinit_self) {
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+	rc = lnet_dyn_add_ni(LNET_PID_LUSTRE, conf);
+out_unlock:
+	mutex_unlock(&lnet_config_mutex);
+
+	return rc;
+}
+
+static int
+lnet_dyn_unconfigure(struct libcfs_ioctl_hdr *hdr)
+{
+	struct lnet_ioctl_config_data *conf =
+		(struct lnet_ioctl_config_data *)hdr;
+	int rc;
+
+	if (conf->cfg_hdr.ioc_len < sizeof(*conf))
+		return -EINVAL;
+
+	mutex_lock(&lnet_config_mutex);
+	if (!the_lnet.ln_niinit_self) {
+		rc = -EINVAL;
+		goto out_unlock;
+	}
+	rc = lnet_dyn_del_ni(conf->cfg_net);
+out_unlock:
+	mutex_unlock(&lnet_config_mutex);
+
+	return rc;
+}
+
+static int
+lnet_ioctl(struct notifier_block *nb,
+	   unsigned long cmd, void *vdata)
+{
+	int rc;
+	struct libcfs_ioctl_hdr *hdr = vdata;
+
+	switch (cmd) {
+	case IOC_LIBCFS_CONFIGURE: {
+		struct libcfs_ioctl_data *data =
+			(struct libcfs_ioctl_data *)hdr;
+
+		if (data->ioc_hdr.ioc_len < sizeof(*data)) {
+			rc = -EINVAL;
+		} else {
+			the_lnet.ln_nis_from_mod_params = data->ioc_flags;
+			rc = lnet_configure(NULL);
+		}
+		break;
+	}
+
+	case IOC_LIBCFS_UNCONFIGURE:
+		rc = lnet_unconfigure();
+		break;
+
+	case IOC_LIBCFS_ADD_NET:
+		rc = lnet_dyn_configure(hdr);
+		break;
+
+	case IOC_LIBCFS_DEL_NET:
+		rc = lnet_dyn_unconfigure(hdr);
+		break;
+
+	default:
+		/*
+		 * Passing LNET_PID_ANY only gives me a ref if the net is up
+		 * already; I'll need it to ensure the net can't go down while
+		 * I'm called into it
+		 */
+		rc = LNetNIInit(LNET_PID_ANY);
+		if (rc >= 0) {
+			rc = LNetCtl(cmd, hdr);
+			LNetNIFini();
+		}
+		break;
+	}
+	return notifier_from_ioctl_errno(rc);
+}
+
+static struct notifier_block lnet_ioctl_handler = {
+	.notifier_call = lnet_ioctl,
+};
+
+static int __init lnet_init(void)
+{
+	int rc;
+
+	rc = libcfs_init();
+	if (rc)
+		return rc;
+
+	mutex_init(&lnet_config_mutex);
+
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
+	rc = lnet_lib_init();
+	if (rc) {
+		CERROR("lnet_lib_init: error %d\n", rc);
+		return rc;
+	}
+
+	rc = blocking_notifier_chain_register(&libcfs_ioctl_list,
+					      &lnet_ioctl_handler);
+	LASSERT(!rc);
+
+	if (config_on_load) {
+		/*
+		 * Have to schedule a separate thread to avoid deadlocking
+		 * in modload
+		 */
+		(void)kthread_run(lnet_configure, NULL, "lnet_initd");
+	}
+
+	ko2iblnd_init();
+	ksocklnd_init();
+	return 0;
+}
+
+static void __exit lnet_exit(void)
+{
+	int rc;
+
+	ksocklnd_exit();
+	ko2iblnd_exit();
+
+	rc = blocking_notifier_chain_unregister(&libcfs_ioctl_list,
+						&lnet_ioctl_handler);
+	LASSERT(!rc);
+
+	lnet_lib_exit();
+
+	libcfs_exit();
+}
+
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
+MODULE_DESCRIPTION("Lustre Networking layer");
+MODULE_VERSION(LNET_VERSION);
+MODULE_LICENSE("GPL");
+
+module_init(lnet_init);
+module_exit(lnet_exit);
diff --git a/drivers/staging/lustre/lustre/Makefile b/drivers/staging/lustre/lustre/Makefile
index 331e4fcdd5a2..81eb4243afd3 100644
--- a/drivers/staging/lustre/lustre/Makefile
+++ b/drivers/staging/lustre/lustre/Makefile
@@ -1,2 +1,11 @@
-obj-$(CONFIG_LUSTRE_FS) += obdclass/ ptlrpc/ fld/ osc/ mgc/ \
-			   fid/ lov/ mdc/ lmv/ llite/ obdecho/
+# SPDX-License-Identifier: GPL-2.0
+
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
+modobj-$(CONFIG_LUSTRE_FS) += obdclass/ ldlm/ ptlrpc/ fld/ osc/ mgc/ \
+			   fid/ lov/ mdc/ lmv/ llite/
+obj-$(CONFIG_LUSTRE_FS) += obdecho/
+
+obj-$(CONFIG_LUSTRE_FS) += lustre.o
+lustre-objs = module.o mod.a
diff --git a/drivers/staging/lustre/lustre/fid/Makefile b/drivers/staging/lustre/lustre/fid/Makefile
index 77b65b92667d..c3f2c683c06e 100644
--- a/drivers/staging/lustre/lustre/fid/Makefile
+++ b/drivers/staging/lustre/lustre/fid/Makefile
@@ -1,5 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
 
-obj-$(CONFIG_LUSTRE_FS) += fid.o
-fid-y := fid_request.o fid_lib.o lproc_fid.o
+modobj-$(CONFIG_LUSTRE_FS) += fid_request.o fid_lib.o lproc_fid.o
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index a34fd90ca5e5..0e8d92701204 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -383,7 +383,7 @@ int client_fid_fini(struct obd_device *obd)
 }
 EXPORT_SYMBOL(client_fid_fini);
 
-static int __init fid_init(void)
+int __init fid_init(void)
 {
 	int rc;
 
@@ -396,15 +396,7 @@ static int __init fid_init(void)
 	return 0;
 }
 
-static void __exit fid_exit(void)
+void __exit fid_exit(void)
 {
 	debugfs_remove_recursive(seq_debugfs_dir);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre File IDentifier");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(fid_init);
-module_exit(fid_exit);
diff --git a/drivers/staging/lustre/lustre/fld/Makefile b/drivers/staging/lustre/lustre/fld/Makefile
index 426deba8b815..37097a4421a0 100644
--- a/drivers/staging/lustre/lustre/fld/Makefile
+++ b/drivers/staging/lustre/lustre/fld/Makefile
@@ -1,5 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
 
-obj-$(CONFIG_LUSTRE_FS) += fld.o
-fld-y := fld_request.o fld_cache.o lproc_fld.o
+modobj-$(CONFIG_LUSTRE_FS) += fld_request.o fld_cache.o lproc_fld.o
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 97f7ea632346..21e7dbc65cd3 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -419,7 +419,7 @@ void fld_client_flush(struct lu_client_fld *fld)
 	fld_cache_flush(fld->lcf_cache);
 }
 
-static int __init fld_init(void)
+int __init fld_init(void)
 {
 	int rc;
 
@@ -432,15 +432,7 @@ static int __init fld_init(void)
 	return 0;
 }
 
-static void __exit fld_exit(void)
+void __exit fld_exit(void)
 {
 	debugfs_remove_recursive(fld_debugfs_dir);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre FID Location Database");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(fld_init)
-module_exit(fld_exit)
diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 3c6db0d632dc..3e4343e4740a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -50,16 +50,6 @@
 #define current_ngroups current_cred()->group_info->ngroups
 #define current_groups current_cred()->group_info->small_block
 
-/*
- * OBD need working random driver, thus all our
- * initialization routines must be called after device
- * driver initialization
- */
-#ifndef MODULE
-#undef module_init
-#define module_init(a)     late_initcall(a)
-#endif
-
 #define LTIME_S(time)		   (time.tv_sec)
 
 #ifndef QUOTA_OK
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 87748e9902a7..16fa74caed37 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -85,6 +85,25 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
 
 /** @} lib */
 
+int fid_init(void);
+int fld_init(void);
+int lmv_init(void);
+int lov_init(void);
+int mdc_init(void);
+int mgc_init(void);
+int obdclass_init(void);
+int osc_init(void);
+int ptlrpc_init(void);
+
+void fid_exit(void);
+void fld_exit(void);
+void lmv_exit(void);
+void lov_exit(void);
+void mdc_exit(void);
+void mgc_exit(void);
+void obdclass_exit(void);
+void osc_exit(void);
+void ptlrpc_exit(void);
 
 
 /* l_wait_event_abortable() is a bit like wait_event_killable()
diff --git a/drivers/staging/lustre/lustre/ldlm/Makefile b/drivers/staging/lustre/lustre/ldlm/Makefile
new file mode 100644
index 000000000000..7dc83d1f3416
--- /dev/null
+++ b/drivers/staging/lustre/lustre/ldlm/Makefile
@@ -0,0 +1,12 @@
+# SPDX-License-Identifier: GPL-2.0
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
+subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
+
+ldlm_objs := l_lock.o ldlm_lock.o
+ldlm_objs += ldlm_resource.o ldlm_lib.o
+ldlm_objs += ldlm_plain.o ldlm_extent.o
+ldlm_objs += ldlm_request.o ldlm_lockd.o
+ldlm_objs += ldlm_flock.o ldlm_inodebits.o
+ldlm_objs += ldlm_pool.o
+
+modobj-$(CONFIG_LUSTRE_FS) += $(ldlm_objs)
diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
index 5200924182ae..ec0877d8f65e 100644
--- a/drivers/staging/lustre/lustre/llite/Makefile
+++ b/drivers/staging/lustre/lustre/llite/Makefile
@@ -2,7 +2,6 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
 	    xattr.o xattr_cache.o xattr_security.o \
@@ -11,3 +10,5 @@ lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
 	    lproc_llite.o
 
 lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
+
+modobj-$(CONFIG_LUSTRE_FS) += $(lustre-y)
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index d335f29556c2..8f81ae4e6998 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -81,9 +81,8 @@ struct super_operations lustre_super_operations = {
 	.remount_fs    = ll_remount_fs,
 	.show_options  = ll_show_options,
 };
-MODULE_ALIAS_FS("lustre");
 
-static int __init lustre_init(void)
+int __init lustre_init(void)
 {
 	int rc;
 
@@ -164,7 +163,7 @@ static int __init lustre_init(void)
 	return rc;
 }
 
-static void __exit lustre_exit(void)
+void __exit lustre_exit(void)
 {
 	lustre_register_super_ops(NULL, NULL, NULL);
 	lustre_register_client_process_config(NULL);
@@ -179,11 +178,3 @@ static void __exit lustre_exit(void)
 	kmem_cache_destroy(ll_inode_cachep);
 	kmem_cache_destroy(ll_file_data_slab);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Client File System");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(lustre_init);
-module_exit(lustre_exit);
diff --git a/drivers/staging/lustre/lustre/lmv/Makefile b/drivers/staging/lustre/lustre/lmv/Makefile
index 91c99114aa13..4fa01f085f2a 100644
--- a/drivers/staging/lustre/lustre/lmv/Makefile
+++ b/drivers/staging/lustre/lustre/lmv/Makefile
@@ -1,5 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += lmv.o
-lmv-y := lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o
+modobj-$(CONFIG_LUSTRE_FS) += lmv_obd.o lmv_intent.o lmv_fld.o lproc_lmv.o
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 65f94e6ecaad..17e825f54668 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3102,7 +3102,7 @@ static struct md_ops lmv_md_ops = {
 	.unpackmd		= lmv_unpackmd,
 };
 
-static int __init lmv_init(void)
+int __init lmv_init(void)
 {
 	struct lprocfs_static_vars lvars;
 	int rc;
@@ -3117,15 +3117,7 @@ static int __init lmv_init(void)
 				 LUSTRE_LMV_NAME, NULL);
 }
 
-static void lmv_exit(void)
+void lmv_exit(void)
 {
 	class_unregister_type(LUSTRE_LMV_NAME);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Logical Metadata Volume");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(lmv_init);
-module_exit(lmv_exit);
diff --git a/drivers/staging/lustre/lustre/lov/Makefile b/drivers/staging/lustre/lustre/lov/Makefile
index 1ebf0193f61a..a4167566cee6 100644
--- a/drivers/staging/lustre/lustre/lov/Makefile
+++ b/drivers/staging/lustre/lustre/lov/Makefile
@@ -2,8 +2,7 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += lov.o
-lov-y := lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
+modobj-$(CONFIG_LUSTRE_FS) += lov_obd.o lov_pack.o lov_offset.o lov_merge.o \
 	 lov_request.o lov_ea.o lov_dev.o lov_object.o lov_page.o  \
 	 lov_lock.o lov_io.o lovsub_dev.o lovsub_object.o lovsub_page.o      \
 	 lovsub_lock.o lov_pool.o lproc_lov.o
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 344ff4b20168..4b2ed026ccf1 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1388,7 +1388,7 @@ static struct obd_ops lov_obd_ops = {
 
 struct kmem_cache *lov_oinfo_slab;
 
-static int __init lov_init(void)
+int __init lov_init(void)
 {
 	struct lprocfs_static_vars lvars = { NULL };
 	int rc;
@@ -1427,18 +1427,10 @@ static int __init lov_init(void)
 	return rc;
 }
 
-static void /*__exit*/ lov_exit(void)
+void /*__exit*/ lov_exit(void)
 {
 	class_unregister_type(LUSTRE_LOV_NAME);
 	kmem_cache_destroy(lov_oinfo_slab);
 
 	lu_kmem_fini(lov_caches);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Logical Object Volume");
-MODULE_LICENSE("GPL");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-
-module_init(lov_init);
-module_exit(lov_exit);
diff --git a/drivers/staging/lustre/lustre/mdc/Makefile b/drivers/staging/lustre/lustre/mdc/Makefile
index c7bc3351ccb0..6ee93aa9e911 100644
--- a/drivers/staging/lustre/lustre/mdc/Makefile
+++ b/drivers/staging/lustre/lustre/mdc/Makefile
@@ -1,5 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += mdc.o
-mdc-y := mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
+modobj-$(CONFIG_LUSTRE_FS) += mdc_request.o mdc_reint.o mdc_lib.o mdc_locks.o lproc_mdc.o
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index cff31cb0a9ac..57225bf2bb72 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2741,7 +2741,7 @@ static struct md_ops mdc_md_ops = {
 	.revalidate_lock	= mdc_revalidate_lock
 };
 
-static int __init mdc_init(void)
+int __init mdc_init(void)
 {
 	struct lprocfs_static_vars lvars = { NULL };
 	int rc;
@@ -2756,15 +2756,8 @@ static int __init mdc_init(void)
 				 LUSTRE_MDC_NAME, NULL);
 }
 
-static void /*__exit*/ mdc_exit(void)
+void /*__exit*/ mdc_exit(void)
 {
 	class_unregister_type(LUSTRE_MDC_NAME);
 }
 
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Metadata Client");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(mdc_init);
-module_exit(mdc_exit);
diff --git a/drivers/staging/lustre/lustre/mgc/Makefile b/drivers/staging/lustre/lustre/mgc/Makefile
index 8abf108dbcf7..b1555e33fe49 100644
--- a/drivers/staging/lustre/lustre/mgc/Makefile
+++ b/drivers/staging/lustre/lustre/mgc/Makefile
@@ -1,5 +1,4 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += mgc.o
-mgc-y := mgc_request.o lproc_mgc.o
+modobj-$(CONFIG_LUSTRE_FS) += mgc_request.o lproc_mgc.o
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 32df804614d3..68ef04eddfd2 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1825,7 +1825,7 @@ static struct obd_ops mgc_obd_ops = {
 	.process_config = mgc_process_config,
 };
 
-static int __init mgc_init(void)
+int __init mgc_init(void)
 {
 	int rc;
 
@@ -1837,15 +1837,7 @@ static int __init mgc_init(void)
 				   LUSTRE_MGC_NAME, NULL);
 }
 
-static void /*__exit*/ mgc_exit(void)
+void /*__exit*/ mgc_exit(void)
 {
 	class_unregister_type(LUSTRE_MGC_NAME);
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Management Client");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(mgc_init);
-module_exit(mgc_exit);
diff --git a/drivers/staging/lustre/lustre/module.c b/drivers/staging/lustre/lustre/module.c
new file mode 100644
index 000000000000..a8a8c9687c95
--- /dev/null
+++ b/drivers/staging/lustre/lustre/module.c
@@ -0,0 +1,61 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+
+#include <linux/module.h>
+#include <lustre_lib.h>
+
+static int __init  lustre_init(void)
+{
+	return obdclass_init() ||
+		ptlrpc_init() ||
+		fld_init() ||
+		osc_init() ||
+		mgc_init() ||
+		fid_init() ||
+		lov_init() ||
+		mdc_init() ||
+		lmv_init();
+}
+
+
+static void __exit lustre_exit(void)
+{
+	lmv_exit();
+	mdc_exit();
+	lov_exit();
+	fid_exit();
+	mgc_exit();
+	osc_exit();
+	fld_exit();
+	ptlrpc_exit();
+	obdclass_exit();
+}
+
+MODULE_ALIAS_FS("lustre");
+MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
+MODULE_DESCRIPTION("Lustre Client File System");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(LUSTRE_VERSION_STRING);
+
+module_init(lustre_init);
+module_exit(lustre_exit);
diff --git a/drivers/staging/lustre/lustre/obdclass/Makefile b/drivers/staging/lustre/lustre/obdclass/Makefile
index e36ba2167d10..606647bde6a9 100644
--- a/drivers/staging/lustre/lustre/obdclass/Makefile
+++ b/drivers/staging/lustre/lustre/obdclass/Makefile
@@ -2,9 +2,7 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += obdclass.o
-
-obdclass-y := module.o sysctl.o \
+modobj-$(CONFIG_LUSTRE_FS) += module.o sysctl.o \
 	      llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o debug.o \
 	      genops.o uuid.o lprocfs_status.o lprocfs_counters.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index d6c46858941b..6f07837b56f5 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -444,7 +444,7 @@ static int obd_init_checks(void)
 	return ret;
 }
 
-static int __init obdclass_init(void)
+int __init obdclass_init(void)
 {
 	int i, err;
 
@@ -517,7 +517,7 @@ static int __init obdclass_init(void)
 	return err;
 }
 
-static void obdclass_exit(void)
+void obdclass_exit(void)
 {
 	lustre_unregister_fs();
 
@@ -535,10 +535,3 @@ static void obdclass_exit(void)
 	obd_zombie_impexp_stop();
 }
 
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Class Driver");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(obdclass_init);
-module_exit(obdclass_exit);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 06c38fdef7ba..30a5e34d5ae8 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -1232,7 +1232,6 @@ static struct file_system_type lustre_fs_type = {
 	.kill_sb	= lustre_kill_super,
 	.fs_flags	= FS_RENAME_DOES_D_MOVE,
 };
-MODULE_ALIAS_FS("lustre");
 
 int lustre_register_fs(void)
 {
diff --git a/drivers/staging/lustre/lustre/osc/Makefile b/drivers/staging/lustre/lustre/osc/Makefile
index 30dec90e64e8..5706a988c471 100644
--- a/drivers/staging/lustre/lustre/osc/Makefile
+++ b/drivers/staging/lustre/lustre/osc/Makefile
@@ -1,6 +1,5 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += osc.o
-osc-y := osc_request.o osc_dev.o osc_object.o \
+modobj-$(CONFIG_LUSTRE_FS) += osc_request.o osc_dev.o osc_object.o \
 	 osc_page.o osc_lock.o osc_io.o osc_quota.o osc_cache.o lproc_osc.o
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 61ef6c8d7a12..46af1ad36f18 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2819,7 +2819,7 @@ static struct shrinker osc_cache_shrinker = {
 	.seeks		= DEFAULT_SEEKS,
 };
 
-static int __init osc_init(void)
+int __init osc_init(void)
 {
 	struct lprocfs_static_vars lvars = { NULL };
 	unsigned int reqpool_size;
@@ -2890,7 +2890,7 @@ static int __init osc_init(void)
 	return rc;
 }
 
-static void /*__exit*/ osc_exit(void)
+void /*__exit*/ osc_exit(void)
 {
 	unregister_shrinker(&osc_cache_shrinker);
 	class_unregister_type(LUSTRE_OSC_NAME);
@@ -2898,10 +2898,3 @@ static void /*__exit*/ osc_exit(void)
 	ptlrpc_free_rq_pool(osc_rq_pool);
 }
 
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Object Storage Client (OSC)");
-MODULE_LICENSE("GPL");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-
-module_init(osc_init);
-module_exit(osc_exit);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/Makefile b/drivers/staging/lustre/lustre/ptlrpc/Makefile
index 77f8eabb2e28..0dffec552511 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/Makefile
+++ b/drivers/staging/lustre/lustre/ptlrpc/Makefile
@@ -2,15 +2,6 @@
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include
 subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include
 
-obj-$(CONFIG_LUSTRE_FS) += ptlrpc.o
-LDLM := ../../lustre/ldlm/
-
-ldlm_objs := $(LDLM)l_lock.o $(LDLM)ldlm_lock.o
-ldlm_objs += $(LDLM)ldlm_resource.o $(LDLM)ldlm_lib.o
-ldlm_objs += $(LDLM)ldlm_plain.o $(LDLM)ldlm_extent.o
-ldlm_objs += $(LDLM)ldlm_request.o $(LDLM)ldlm_lockd.o
-ldlm_objs += $(LDLM)ldlm_flock.o $(LDLM)ldlm_inodebits.o
-ldlm_objs += $(LDLM)ldlm_pool.o
 ptlrpc_objs := client.o recover.o connection.o niobuf.o pack_generic.o
 ptlrpc_objs += events.o ptlrpc_module.o service.o pinger.o
 ptlrpc_objs += llog_net.o llog_client.o import.o ptlrpcd.o
@@ -18,5 +9,7 @@ ptlrpc_objs += pers.o lproc_ptlrpc.o wiretest.o layout.o
 ptlrpc_objs += sec.o sec_bulk.o sec_gc.o sec_config.o
 ptlrpc_objs += sec_null.o sec_plain.o nrs.o nrs_fifo.o
 
-ptlrpc-y := $(ldlm_objs) $(ptlrpc_objs) sec_lproc.o
+ptlrpc-y := $(ptlrpc_objs) sec_lproc.o
 ptlrpc-$(CONFIG_LUSTRE_TRANSLATE_ERRNOS) += errno.o
+
+modobj-$(CONFIG_LUSTRE_FS) += $(ptlrpc-y)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index 5c32b657b3b5..1260a7b9cae0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -81,7 +81,7 @@ void ptlrpc_dec_ref(void)
 }
 EXPORT_SYMBOL(ptlrpc_dec_ref);
 
-static int __init ptlrpc_init(void)
+int __init ptlrpc_init(void)
 {
 	int rc, cleanup_phase = 0;
 
@@ -166,7 +166,7 @@ static int __init ptlrpc_init(void)
 	return rc;
 }
 
-static void __exit ptlrpc_exit(void)
+void __exit ptlrpc_exit(void)
 {
 	tgt_mod_exit();
 	ptlrpc_nrs_fini();
@@ -176,11 +176,3 @@ static void __exit ptlrpc_exit(void)
 	ptlrpc_hr_fini();
 	ptlrpc_connection_fini();
 }
-
-MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
-MODULE_DESCRIPTION("Lustre Request Processor and Lock Management");
-MODULE_VERSION(LUSTRE_VERSION_STRING);
-MODULE_LICENSE("GPL");
-
-module_init(ptlrpc_init);
-module_exit(ptlrpc_exit);
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180608/20bc371a/attachment-0001.sig>
