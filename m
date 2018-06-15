From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 01/24] kbuild: detect directories in
 components of a module.
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669010.10587.15227086408644911106.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is a first step in a larger change and so can
only be fully understood in the larger context.

This patch changes the code for extracting directories
from a list of objects to extract them from real-obj-X
instead of obj-X.
This should not cause any change in behaviour yet
as listing directories as components of an object is
not currently supported and will cause an error.
A future patch will give a useful meaning to directories
listed in componsite objects.

A consequence of this change is that any subsequent use of obj-y or
obj-m will still have directories listed in it.
There are no subsequent uses of obj-y and only 2 of obj-m.

1/ obj-m is included as a dependency of __build.  subdir-ym, which
  contains all the directories mentioned in obj-m, is also a
  dependency, so this won't change the set of final dependencies.

2/ Any rule that builds a directory listed in obj-m will find that
   quite_modtag has the value '[M]'.  As quiet_modtag is not used
   when descending into directories, this is of no consequence.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 scripts/Makefile.lib |   38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 5af34a2b0cd9..2f37262b9333 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -25,36 +25,36 @@ lib-y := $(filter-out $(obj-y), $(sort $(lib-y) $(lib-m)))
 # and -m subdirs.  Just put -y's first.
 modorder	:= $(patsubst %/,%/modules.order, $(filter %/, $(obj-y)) $(obj-m:.o=.ko))
 
+# if $(foo-objs), $(foo-y), or $(foo-m) exists, foo.o is a composite object
+multi-used-y := $(sort $(foreach m,$(obj-y), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))), $(m))))
+multi-used-m := $(sort $(foreach m,$(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))), $(m))))
+multi-used   := $(multi-used-y) $(multi-used-m)
+single-used-m := $(sort $(filter-out $(multi-used-m),$(obj-m)))
+
+# Replace multi-part objects by their individual parts,
+# including built-in.a from subdirectories
+real-obj-y := $(foreach m, $(obj-y), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m)))
+real-obj-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m)),$(m)))
+
 # Handle objects in subdirs
 # ---------------------------------------------------------------------------
-# o if we encounter foo/ in $(obj-y), replace it by foo/built-in.a
+# o if we encounter foo/ in $(real-obj-y), replace it by foo/built-in.a
 #   and add the directory to the list of dirs to descend into: $(subdir-y)
-# o if we encounter foo/ in $(obj-m), remove it from $(obj-m)
+# o if we encounter foo/ in $(real-obj-m), remove it from $(real-obj-m)
 #   and add the directory to the list of dirs to descend into: $(subdir-m)
-__subdir-y	:= $(patsubst %/,%,$(filter %/, $(obj-y)))
+__subdir-y	:= $(patsubst %/,%,$(filter %/, $(real-obj-y)))
 subdir-y	+= $(__subdir-y)
-__subdir-m	:= $(patsubst %/,%,$(filter %/, $(obj-m)))
+__subdir-m	:= $(patsubst %/,%,$(filter %/, $(real-obj-m)))
 subdir-m	+= $(__subdir-m)
-obj-y		:= $(patsubst %/, %/built-in.a, $(obj-y))
-obj-m		:= $(filter-out %/, $(obj-m))
+real-obj-y	:= $(patsubst %/, %/built-in.a, $(real-obj-y))
+real-obj-m	:= $(filter-out %/, $(real-obj-m))
 
 # Subdirectories we need to descend into
 subdir-ym	:= $(sort $(subdir-y) $(subdir-m))
 
-# if $(foo-objs), $(foo-y), or $(foo-m) exists, foo.o is a composite object
-multi-used-y := $(sort $(foreach m,$(obj-y), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))), $(m))))
-multi-used-m := $(sort $(foreach m,$(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))), $(m))))
-multi-used   := $(multi-used-y) $(multi-used-m)
-single-used-m := $(sort $(filter-out $(multi-used-m),$(obj-m)))
-
-# $(subdir-obj-y) is the list of objects in $(obj-y) which uses dir/ to
+# $(subdir-obj-y) is the list of objects in $(real-obj-y) which uses dir/ to
 # tell kbuild to descend
-subdir-obj-y := $(filter %/built-in.a, $(obj-y))
-
-# Replace multi-part objects by their individual parts,
-# including built-in.a from subdirectories
-real-obj-y := $(foreach m, $(obj-y), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y))),$($(m:.o=-objs)) $($(m:.o=-y)),$(m)))
-real-obj-m := $(foreach m, $(obj-m), $(if $(strip $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m)),$(m)))
+subdir-obj-y := $(filter %/built-in.a, $(real-obj-y))
 
 # DTB
 # If CONFIG_OF_ALL_DTBS is enabled, all DT blobs are built
