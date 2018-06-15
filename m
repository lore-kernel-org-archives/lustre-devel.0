From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 05/24] kbuild: Add documentation for modobj-m
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669023.10587.4124629758082370663.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Add documentation for building modules
from multiple directories using modobj-m.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 Documentation/kbuild/makefiles.txt |   65 ++++++++++++++++++++++++++++++++++--
 1 file changed, 61 insertions(+), 4 deletions(-)

diff --git a/Documentation/kbuild/makefiles.txt b/Documentation/kbuild/makefiles.txt
index 048fc39a6b91..985a60cf0663 100644
--- a/Documentation/kbuild/makefiles.txt
+++ b/Documentation/kbuild/makefiles.txt
@@ -225,17 +225,74 @@ more details, with real examples.
 	part of the composite object ext2.o if $(CONFIG_EXT2_FS_XATTR)
 	evaluates to 'y'.
 
+	If you wish to include code in some other directory into a
+	module, that directory should be configured to create a
+	mod.a target from the relevant code, as described below.
+	The list of components for the module (e.g. foo-y) should
+	then contain the name of the directory (with trailing /).
+	The mod.a from that directory will be built and included
+	into this module.
+
 	Note: Of course, when you are building objects into the kernel,
 	the syntax above will also work. So, if you have CONFIG_EXT2_FS=y,
 	kbuild will build an ext2.o file for you out of the individual
 	parts and then link this into built-in.a, as you would expect.
 
---- 3.4 Objects which export symbols
+--- 3.4 Loadable modules from multiple directories - modobj-m
+
+	One way to build modules with source from multiple directories
+	is to list relative path names of all source files in a
+	single Makefile.
+
+	Example:
+		btrfs-$(CONFIG_BTRFS_FS_RUN_SANITY_TESTS) += tests/free-space-tests.o \
+		        tests/extent-buffer-tests.o tests/btrfs-tests.o \
+		....
+
+	This works, but defeats the ability to build individual
+	directories, or individual target files such as assembly
+	language targets.
+
+	Example:
+		make btrfs/tests/free-space-tests.s
+
+	A more general way is to create a mod.a file using modobj-m
+
+	Example:
+		modobj-$(CONFIG_LUSTRE_FS) += fid_request.o fid_lib.o lproc_fid.o
+
+	modobj-y is treated identically to obj-y so if CONFIG_LUSTRE_FS=y
+	then these objects are built in to the kernel.  If
+	CONFIG_LUSTRE_FS=m then these objects are gathered into an archive
+	called mod.a.  Archives from other directories can be included
+	by listing the directories in modobj-m, so
+
+	Example:
+		modobj-$(CONFIG_LUSTRE_FS) += fid/ fld/
+
+	This will create a mod.a in the same directory as the
+	Makefile, combining the contents of mod.a from the listed
+	directories.  The mod.a can instead be included into a module
+	by listing the directory with any other local object files.
+
+	Example:
+		obj-$(CONFIG_LUSTRE_FS) += lustre.o
+		lustre-y := module.o
+		lustre-y += obdclass/ ldlm/ ptlrpc/ fld/ osc/ mgc/
+
+	When CONFIG_LUSTRE_FS=m, kbuild will build lustre.ko from module.o and
+	the mod.a archives created in the listed directories.
+
+	When components of a module are built in a different directory
+	kbuild cannot determine the name of the module so the
+	KBUILD_MODNAME macro is left undefined.
+
+--- 3.5 Objects which export symbols
 
 	No special notation is required in the makefiles for
 	modules exporting symbols.
 
---- 3.5 Library file goals - lib-y
+--- 3.6 Library file goals - lib-y
 
 	Objects listed with obj-* are used for modules, or
 	combined in a built-in.a for that specific directory.
@@ -263,7 +320,7 @@ more details, with real examples.
 
 	Use of lib-y is normally restricted to lib/ and arch/*/lib.
 
---- 3.6 Descending down in directories
+--- 3.7 Descending down in directories
 
 	A Makefile is only responsible for building objects in its own
 	directory. Files in subdirectories should be taken care of by
@@ -290,7 +347,7 @@ more details, with real examples.
 	names. This allows kbuild to totally skip the directory if the
 	corresponding CONFIG_ option is neither 'y' nor 'm'.
 
---- 3.7 Compilation flags
+--- 3.8 Compilation flags
 
     ccflags-y, asflags-y and ldflags-y
 	These three flags apply only to the kbuild makefile in which they
