From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 02/24] kbuild: treat a directory listed in a
 composite object as foo/mod.a
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669013.10587.6424693677513069548.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently a directory is not permitted in a composite
object.
This patch changes kbuild so that a directory it assumed
to mean the file "mod.a" in that directory.
The file cannot, yet, be created, so this does not yet
affect behaviour.

There are several parts to this.

1/ strip out all the directories from obj-m so that
  the directories that appear in real-obj-m must be
  parts of composite objects
2/ translate those directories from foo/ to foo/mod.a
  at the same time that obj-y directories becomes foo/built-in.a
3/ hold list of directories needed for modules in subdir-obj-m
  so that we can descend into them as required.
4/ We need a little "dance" in "Rule to link composite objects"
  where we strip the mod.a back off - so we can filter against
  the foo-{objs,y,m} macros, then add it back on for
  declaring dependencies.
  As part of this, multi_depend gains an extra argument
  being the name to append to any directory.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 scripts/Makefile.build |   15 ++++++++-------
 scripts/Makefile.lib   |   19 +++++++++++++++----
 2 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 8bdb1dc4072c..d42091532021 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -412,8 +412,9 @@ endif
 $(obj)/%.o: $(src)/%.S $(objtool_dep) FORCE
 	$(call if_changed_rule,as_o_S)
 
-targets += $(filter-out $(subdir-obj-y), $(real-obj-y)) $(real-obj-m) $(lib-y)
-targets += $(extra-y) $(MAKECMDGOALS) $(always)
+targets += $(filter-out $(subdir-obj-y), $(real-obj-y))
+targets += $(filter-out $(subdir-obj-m), $(real-obj-m))
+targets += $(lib-y) $(extra-y) $(MAKECMDGOALS) $(always)
 
 # Linker scripts preprocessor (.lds.S -> .lds)
 # ---------------------------------------------------------------------------
@@ -437,7 +438,7 @@ $(obj)/%.asn1.c $(obj)/%.asn1.h: $(src)/%.asn1 $(objtree)/scripts/asn1_compiler
 # ---------------------------------------------------------------------------
 
 # To build objects in subdirs, we need to descend into the directories
-$(sort $(subdir-obj-y)): $(subdir-ym) ;
+$(sort $(subdir-obj-y) $(subdir-obj-m)): $(subdir-ym) ;
 
 #
 # Rule to compile a set of .o files into one .o file
@@ -522,16 +523,16 @@ link_multi_deps =                     \
 $(filter $(addprefix $(obj)/,         \
 $($(subst $(obj)/,,$(@:.o=-objs)))    \
 $($(subst $(obj)/,,$(@:.o=-y)))       \
-$($(subst $(obj)/,,$(@:.o=-m)))), $^)
+$($(subst $(obj)/,,$(@:.o=-m)))), $(patsubst %/mod.a,%/,$^))
 
 quiet_cmd_link_multi-m = LD [M]  $@
-cmd_link_multi-m = $(LD) $(ld_flags) -r -o $@ $(link_multi_deps) $(cmd_secanalysis)
+cmd_link_multi-m = $(LD) $(ld_flags) -r -o $@ $(patsubst %/, --whole-archive %/mod.a --no-whole-archive ,$(link_multi_deps)) $(cmd_secanalysis)
 
 $(multi-used-m): FORCE
 	$(call if_changed,link_multi-m)
-	@{ echo $(@:.o=.ko); echo $(link_multi_deps); \
+	@{ echo $(@:.o=.ko); echo $(patsubst %/,%/mod.a,$(link_multi_deps)); \
 	   $(cmd_undef_syms); } > $(MODVERDIR)/$(@F:.o=.mod)
-$(call multi_depend, $(multi-used-m), .o, -objs -y -m)
+$(call multi_depend, $(multi-used-m), .o, -objs -y -m,mod.a)
 
 targets += $(multi-used-m)
 targets := $(filter-out $(PHONY), $(targets))
diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 2f37262b9333..c8f643144cd6 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -12,6 +12,13 @@ KBUILD_CFLAGS += $(subdir-ccflags-y)
 # Figure out what we need to build from the various variables
 # ===========================================================================
 
+# Directories in obj-m only cause that directory to be descended, which
+# is exactly what happens for directories in obj-y. So move all
+# directories from obj-m to obj-y.  Then we will know that any directory
+# in real-obj-m is a component of some other object.
+obj-y := $(obj-y) $(filter %/, $(obj-m))
+obj-m := $(filter-out %/, $(obj-m))
+
 # When an object is listed to be built compiled-in and modular,
 # only build the compiled-in version
 obj-m := $(filter-out $(obj-y),$(obj-m))
@@ -40,14 +47,14 @@ real-obj-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))
 # ---------------------------------------------------------------------------
 # o if we encounter foo/ in $(real-obj-y), replace it by foo/built-in.a
 #   and add the directory to the list of dirs to descend into: $(subdir-y)
-# o if we encounter foo/ in $(real-obj-m), remove it from $(real-obj-m)
+# o if we encounter foo/ in $(real-obj-m), replace it by foo/mod.a
 #   and add the directory to the list of dirs to descend into: $(subdir-m)
 __subdir-y	:= $(patsubst %/,%,$(filter %/, $(real-obj-y)))
 subdir-y	+= $(__subdir-y)
 __subdir-m	:= $(patsubst %/,%,$(filter %/, $(real-obj-m)))
 subdir-m	+= $(__subdir-m)
 real-obj-y	:= $(patsubst %/, %/built-in.a, $(real-obj-y))
-real-obj-m	:= $(filter-out %/, $(real-obj-m))
+real-obj-m	:= $(patsubst %/, %/mod.a, $(real-obj-m))
 
 # Subdirectories we need to descend into
 subdir-ym	:= $(sort $(subdir-y) $(subdir-m))
@@ -55,6 +62,9 @@ subdir-ym	:= $(sort $(subdir-y) $(subdir-m))
 # $(subdir-obj-y) is the list of objects in $(real-obj-y) which uses dir/ to
 # tell kbuild to descend
 subdir-obj-y := $(filter %/built-in.a, $(real-obj-y))
+# $(subdir-obj-m) is the list of objects in $(real-obj-m) which uses dir/ to
+# tell kbuild to descend
+subdir-obj-m := $(filter %/mod.a, $(real-obj-m))
 
 # DTB
 # If CONFIG_OF_ALL_DTBS is enabled, all DT blobs are built
@@ -70,6 +80,7 @@ modorder	:= $(addprefix $(obj)/,$(modorder))
 obj-m		:= $(addprefix $(obj)/,$(obj-m))
 lib-y		:= $(addprefix $(obj)/,$(lib-y))
 subdir-obj-y	:= $(addprefix $(obj)/,$(subdir-obj-y))
+subdir-obj-m	:= $(addprefix $(obj)/,$(subdir-obj-m))
 real-obj-y	:= $(addprefix $(obj)/,$(real-obj-y))
 real-obj-m	:= $(addprefix $(obj)/,$(real-obj-m))
 single-used-m	:= $(addprefix $(obj)/,$(single-used-m))
@@ -172,11 +183,11 @@ dtc_cpp_flags  = -Wp,-MD,$(depfile).pre.tmp -nostdinc                    \
 
 # Useful for describing the dependency of composite objects
 # Usage:
-#   $(call multi_depend, multi_used_targets, suffix_to_remove, suffix_to_add)
+#   $(call multi_depend, multi_used_targets, suffix_to_remove, suffix_to_add, object_in_directories)
 define multi_depend
 $(foreach m, $(notdir $1), \
 	$(eval $(obj)/$m: \
-	$(addprefix $(obj)/, $(foreach s, $3, $($(m:%$(strip $2)=%$(s)))))))
+	$(addprefix $(obj)/, $(patsubst %/,%/$4,$(foreach s, $3, $($(m:%$(strip $2)=%$(s))))))))
 endef
 
 # LEX
