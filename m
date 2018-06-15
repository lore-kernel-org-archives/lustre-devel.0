From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 03/24] kbuild: support building of
 per-directory mod.a
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669016.10587.15454151232253137450.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch allows a "mod.a" to be built in any
directory.  A previous patch allows that mod.a
to be included in any module or another mod.a.

This is achieved via a new pair of macros: modobj-y and modobj-m.

Anything in modobj-y is added to obj-y and is otherwise
ignored.
Anything listed in modobj-m is built, almost as though "modobj.o" was
a requested target.  The objects are then combined
into mod.a.
These objects are always built with part-of-module=y.

This is sufficient to build a module from source in
multiple directories.  Each "other" directory lists
something like
 modobj-$(CONFIG_FOO) += bar.o bar.o bat.o

and the main directory lists

 obj-$(CONFIG-FOO) = foo.o
 foo-y = other1/ ../friend/other2/ module.o

Signed-off-by: NeilBrown <neilb@suse.com>
---
 scripts/Makefile.build |   44 +++++++++++++++++++++++++++++++++-----------
 scripts/Makefile.lib   |   14 ++++++++++----
 2 files changed, 43 insertions(+), 15 deletions(-)

diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index d42091532021..703bc210f71f 100644
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
+	 $(if $(KBUILD_MODULES),$(obj-m) $(modorder-target) $(modobj-target))  \
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
@@ -413,7 +421,7 @@ $(obj)/%.o: $(src)/%.S $(objtool_dep) FORCE
 	$(call if_changed_rule,as_o_S)
 
 targets += $(filter-out $(subdir-obj-y), $(real-obj-y))
-targets += $(filter-out $(subdir-obj-m), $(real-obj-m))
+targets += $(filter-out $(subdir-obj-m) $(real-modobj-m), $(real-obj-m))
 targets += $(lib-y) $(extra-y) $(MAKECMDGOALS) $(always)
 
 # Linker scripts preprocessor (.lds.S -> .lds)
@@ -509,6 +517,20 @@ targets += $(obj)/lib-ksyms.o
 
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
+endif # modobj-target
+
+
 #
 # Rule to link composite objects
 #
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index c8f643144cd6..90ee6e8c910f 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -16,12 +16,13 @@ KBUILD_CFLAGS += $(subdir-ccflags-y)
 # is exactly what happens for directories in obj-y. So move all
 # directories from obj-m to obj-y.  Then we will know that any directory
 # in real-obj-m is a component of some other object.
-obj-y := $(obj-y) $(filter %/, $(obj-m))
+obj-y := $(obj-y) $(filter %/, $(obj-m)) $(filter-out $(obj-y), $(modobj-y))
 obj-m := $(filter-out %/, $(obj-m))
 
 # When an object is listed to be built compiled-in and modular,
 # only build the compiled-in version
 obj-m := $(filter-out $(obj-y),$(obj-m))
+modobj-m := $(filter-out $(obj-y), $(modobj-m))
 
 # Libraries are always collected in one lib file.
 # Filter out objects already built-in
@@ -42,6 +43,7 @@ single-used-m := $(sort $(filter-out $(multi-used-m),$(obj-m)))
 # including built-in.a from subdirectories
 real-obj-y := $(foreach m, $(obj-y), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m)))
 real-obj-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m)),$(m)))
+real-modobj-m := $(foreach m, $(modobj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m)),$(m)))
 
 # Handle objects in subdirs
 # ---------------------------------------------------------------------------
@@ -53,8 +55,11 @@ __subdir-y	:= $(patsubst %/,%,$(filter %/, $(real-obj-y)))
 subdir-y	+= $(__subdir-y)
 __subdir-m	:= $(patsubst %/,%,$(filter %/, $(real-obj-m)))
 subdir-m	+= $(__subdir-m)
+__subdir-mo	:= $(patsubst %/,%,$(filter %/, $(real-modobj-m)))
+subdir-m	+= $(__subdir-mo)
 real-obj-y	:= $(patsubst %/, %/built-in.a, $(real-obj-y))
 real-obj-m	:= $(patsubst %/, %/mod.a, $(real-obj-m))
+real-modobj-m	:= $(patsubst %/, %/mod.a, $(real-modobj-m))
 
 # Subdirectories we need to descend into
 subdir-ym	:= $(sort $(subdir-y) $(subdir-m))
@@ -62,9 +67,9 @@ subdir-ym	:= $(sort $(subdir-y) $(subdir-m))
 # $(subdir-obj-y) is the list of objects in $(real-obj-y) which uses dir/ to
 # tell kbuild to descend
 subdir-obj-y := $(filter %/built-in.a, $(real-obj-y))
-# $(subdir-obj-m) is the list of objects in $(real-obj-m) which uses dir/ to
-# tell kbuild to descend
-subdir-obj-m := $(filter %/mod.a, $(real-obj-m))
+# $(subdir-obj-m) is the list of objects in $(real-obj-m) and
+# $(real-modobj-m) which use dir/ to tell kbuild to descend
+subdir-obj-m := $(filter %/mod.a, $(real-obj-m) $(real-modobj-m))
 
 # DTB
 # If CONFIG_OF_ALL_DTBS is enabled, all DT blobs are built
@@ -83,6 +88,7 @@ subdir-obj-y	:= $(addprefix $(obj)/,$(subdir-obj-y))
 subdir-obj-m	:= $(addprefix $(obj)/,$(subdir-obj-m))
 real-obj-y	:= $(addprefix $(obj)/,$(real-obj-y))
 real-obj-m	:= $(addprefix $(obj)/,$(real-obj-m))
+real-modobj-m	:= $(addprefix $(obj)/,$(real-modobj-m))
 single-used-m	:= $(addprefix $(obj)/,$(single-used-m))
 multi-used-m	:= $(addprefix $(obj)/,$(multi-used-m))
 subdir-ym	:= $(addprefix $(obj)/,$(subdir-ym))
