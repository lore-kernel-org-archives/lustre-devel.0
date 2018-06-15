From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 04/24] kbuild: disable KBUILD_MODNAME when
 building for mod.a
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669020.10587.8392749843886680541.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When building an object to be included in mod.a we
cannot know the name of the module.  So don't define
KBUILD_MODNAME.  This will ensure attempt to use
that macro when the module name isn't know will
trigger an error.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 scripts/Makefile.lib |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index 90ee6e8c910f..3b2edf767efa 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -96,7 +96,7 @@ subdir-ym	:= $(addprefix $(obj)/,$(subdir-ym))
 # Finds the multi-part object the current object will be linked into.
 # If the object belongs to two or more multi-part objects, all of them are
 # concatenated with a colon separator.
-modname-multi = $(subst $(space),:,$(sort $(foreach m,$(multi-used),\
+modname-multi = $(subst $(space),:,$(sort $(foreach m,$(multi-used) modobj.o,\
 		$(if $(filter $*.o, $($(m:.o=-objs)) $($(m:.o=-y)) $($(m:.o=-m))),$(m:.o=)))))
 
 modname = $(if $(modname-multi),$(modname-multi),$(basetarget))
@@ -106,7 +106,7 @@ modname = $(if $(modname-multi),$(modname-multi),$(basetarget))
 # end up in (or would, if it gets compiled in)
 name-fix = $(squote)$(quote)$(subst $(comma),_,$(subst -,_,$1))$(quote)$(squote)
 basename_flags = -DKBUILD_BASENAME=$(call name-fix,$(basetarget))
-modname_flags  = -DKBUILD_MODNAME=$(call name-fix,$(modname))
+modname_flags  = $(if $(filter-out modobj,$(modname)),-DKBUILD_MODNAME=$(call name-fix,$(modname)))
 
 orig_c_flags   = $(KBUILD_CPPFLAGS) $(KBUILD_CFLAGS) \
                  $(ccflags-y) $(CFLAGS_$(basetarget).o)
