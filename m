From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Tue, 04 Nov 2008 08:48:35 -0500
Subject: [Lustre-devel] java successfully call the Native functions,
 :-) but there are still some problems like "Lustre mount
 failed:	Invalid argument", when i call the 	__liblustre_setup_().
In-Reply-To: <bfe9780e-a03e-4e21-916e-44f5a4db8dba@v39g2000pro.googlegroups.com>
References: <bfe9780e-a03e-4e21-916e-44f5a4db8dba@v39g2000pro.googlegroups.com>
Message-ID: <1225806515.2247.240.camel@brian-laptop>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, 2008-11-03 at 05:39 -0800, kcruci wrote:
> Hi all,
> I follow the JNI rules to write Javawrapper for the liblustre code,

A good rule to follow when trying to debug a problem is to reduce it to
it's simplest case.  In your case that means stripping the problem of
all of this Java and dealing with the basic problem which is:

> ...
> 1225417124.467324:6009:grid.scut.edu.cn:(class_obd.c:
> 543:init_obdclass()):
> Lustre: 6009-grid.scut.edu.cn:(class_obd.c:543:init_obdclass()): OBD
> class driver, http://www.lustre.org/
> 1225417124.467374:6009:grid.scut.edu.cn:(class_obd.c:
> 544:init_obdclass()):
> Lustre: 6009-grid.scut.edu.cn:(class_obd.c:544:init_obdclass()):
> Lustre
> Version: 1.9.80
> 1225417124.467400:6009:grid.scut.edu.cn:(class_obd.c:
> 545:init_obdclass()):
> Lustre: 6009-grid.scut.edu.cn:(class_obd.c:545:init_obdclass()): Build
> Version:
> 1.9.80-20081019111435-CHANGED-.usr.src.linux-2.6.18-92.1.10-2.6.18-
> prep
> Lustre mount failed: Invalid argument

So why did the mount fail?  Did you set the environment as required for
liblustre?  I notice you are using 1.9.80.  This branch is still in
development and it could be entirely possible that liblustre on that
branch is simply not (yet) working.  Have you tried to reproduce your
problem with a stable, known-working release?

If you really want to debug the problem with 1.9.80 you need to use more
basic methods of calling liblustre and when, and only when you know that
works, start layering your Java wrapper on top of it.  Maybe
lustre/tests/acceptance-small.sh and/or lustre/liblustre/tests/sanity.c
can be of help there.

b.
