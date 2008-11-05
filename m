From: kcruci <yjluan@gmail.com>
Date: Tue, 4 Nov 2008 18:11:06 -0800 (PST)
Subject: [Lustre-devel] java successfully call the Native functions,
	:-) but there are still some problems like "Lustre mount failed:
	Invalid argument", when i call 	the  __liblustre_setup_().
In-Reply-To: <1225806515.2247.240.camel@brian-laptop>
References: <bfe9780e-a03e-4e21-916e-44f5a4db8dba@v39g2000pro.googlegroups.com>
	<1225806515.2247.240.camel@brian-laptop>
Message-ID: <989e3cb9-e0f3-42f2-89ab-1b73df203e41@v16g2000prc.googlegroups.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I use the release version 1.6.5.1, and the programme still halt
on"Lustre mount failed: Invalid argument".

I write a test in c which call the function in liblustremkdir.so, and
gcc it with liblustremkdir.so, the c test run successfully.

After some tests, I make a bold assumption that the function "mount"
was targeted to the system call instead of catching by libsysio when
using JNI.

After that, I add some print in the src code, the log and my print is
same at the first half, the second half, c test run successfully, but
java does not.

Here is the java log:
========================================
[root at ost JNItests]# java org.lustre.liblustre.test.MkDir
begin to run Native method

I am in libsysio/src/fs.c:_sysio_fssw_register
_sysio_init has successfully runed
I am in INIT_SYSIO*initialize libsysio & mount rootfs* block!
I am in libsysio/src/fs.c:_sysio_fssw_register
I am in liblustre/llite.c:lllib_init
I am in libsysio/src/fs.c:_sysio_fssw_register
liblustre/llite_lib.c:_sysio_lustre_init has RUNed!
Lustre mount failed: Invalid argument
[root at ost JNItests]#

=====================================

Review the above print, both _sysio_lustre_init() and _sysio_init()
has successfully runed, so that the "lustre" has registered to the
libsysio.

My question is: When using java, why the libsysio cannot catch the
"mount", even  the libsysio is runing and the "lustre" has registered
to the libsysio.


> [root at grid JNItests]# vim *org_lustre_liblustre_test_MkDir.c *
> #include <jni.h>
> #include "org_lustre_liblustre_test_MkDir.h"
>
> extern void __liblustre_setup_(void);
> extern void __liblustre_cleanup_(void);
>
> JNIEXPORT void JNICALL
> Java_org_lustre_liblustre_test_MkDir_init(JNIEnv
> * env, jclass inclass)
> {
> __liblustre_setup_();
> printf("liblustre setup!!\n");
> __liblustre_cleanup_();
> return;
>
> }
>
> Here is my filelist:
>
> *org.lustre.liblustre.test.MkDir.java
> org_lustre_liblustre_test_MkDir.h
> org_lustre_liblustre_test_MkDir.c
> liblustremkdir.so.1.0
> liblustremkdir.so
> *liblustre.a
> libcap.so.1.10
> libpthread-2.5.so
> libz.so.1.2.3
>



On Nov 4, 9:48?pm, "Brian J. Murrell" <Brian.Murr...@Sun.COM> wrote:
> On Mon, 2008-11-03 at 05:39 -0800, kcruci wrote:
> > Hi all,
> > I follow the JNI rules to write Javawrapper for the liblustre code,
>
> A good rule to follow when trying to debug a problem is to reduce it to
> it's simplest case. ?In your case that means stripping the problem of
> all of this Java and dealing with the basic problem which is:
>
>
>
> > ...
> > 1225417124.467324:6009:grid.scut.edu.cn:(class_obd.c:
> > 543:init_obdclass()):
> > Lustre: 6009-grid.scut.edu.cn:(class_obd.c:543:init_obdclass()): OBD
> > class driver,http://www.lustre.org/
> > 1225417124.467374:6009:grid.scut.edu.cn:(class_obd.c:
> > 544:init_obdclass()):
> > Lustre: 6009-grid.scut.edu.cn:(class_obd.c:544:init_obdclass()):
> > Lustre
> > Version: 1.9.80
> > 1225417124.467400:6009:grid.scut.edu.cn:(class_obd.c:
> > 545:init_obdclass()):
> > Lustre: 6009-grid.scut.edu.cn:(class_obd.c:545:init_obdclass()): Build
> > Version:
> > 1.9.80-20081019111435-CHANGED-.usr.src.linux-2.6.18-92.1.10-2.6.18-
> > prep
> > Lustre mount failed: Invalid argument
>
> So why did the mount fail? ?Did you set the environment as required for
> liblustre? ?I notice you are using 1.9.80. ?This branch is still in
> development and it could be entirely possible that liblustre on that
> branch is simply not (yet) working. ?Have you tried to reproduce your
> problem with a stable, known-working release?
>
> If you really want to debug the problem with 1.9.80 you need to use more
> basic methods of calling liblustre and when, and only when you know that
> works, start layering your Java wrapper on top of it. ?Maybe
> lustre/tests/acceptance-small.sh and/or lustre/liblustre/tests/sanity.c
> can be of help there.
>
> b.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-de... at lists.lustre.orghttp://lists.lustre.org/mailman/listinfo/lustre-devel
