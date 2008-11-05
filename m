From: kcruci <yjluan@gmail.com>
Date: Tue, 4 Nov 2008 19:01:38 -0800 (PST)
Subject: [Lustre-devel] java successfully call the Native functions,
	:-) but there are still some problems like "Lustre mount failed:
	Invalid argument", when i call 	the  __liblustre_setup_().
In-Reply-To: <1225806515.2247.240.camel@brian-laptop>
References: <bfe9780e-a03e-4e21-916e-44f5a4db8dba@v39g2000pro.googlegroups.com>
	<1225806515.2247.240.camel@brian-laptop>
Message-ID: <a257968a-472f-43bd-93bf-5dfc96d3bd1f@u18g2000pro.googlegroups.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


I check the system environment(LIBLUSTRE_MOUNT_TARGET) and redo it
with the reseased version 1.6.5.1, but the programme still halt at
"Lustre mount failed: Invalid argument ".

I write a test in c which call the function in liblustremkdir.so, and
gcc it with liblustremkdir.so, the c tests run seccessfuly.

So I make a bold assumption that the function "mount" was target  to
system call instead of catching by libsysio.

After that I add some print in source code, and the print is same
between c and java tests at the first half, but java halt at  "Lustre
mount failed: Invalid argument " and c run successfully.

Here is the Java logs:
====
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

====

As can be seen in the above log, the _sysio_init() and
_sysio_lustre_init() has runed, so that the libsysio was inited and
the "lustre" must be successfully registered to libsysio.

So, my question is that why libsysio cannot catch the "mount" even the
_sysio_init() and _sysio_lustre_init() has runed when using JNI.

--
Thanks!
Ya-Jian.Luan


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
