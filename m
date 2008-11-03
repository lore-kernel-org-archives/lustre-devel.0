From: kcruci <yjluan@gmail.com>
Date: Mon, 3 Nov 2008 05:48:18 -0800 (PST)
Subject: [Lustre-devel] java successfully call the Native functions,
	:-) but there are still some problems like "Lustre mount failed:
	Invalid argument", when i call the 	__liblustre_setup_().
Message-ID: <d74e0ab8-37f7-47b0-8e5b-9bc0c6d83cba@w39g2000prb.googlegroups.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all,
I follow the JNI rules to write Javawrapper for the liblustre code,
java
seems successfully call the Native functions,  :-)  but there are
still
some problems like "Lustre mount failed: Invalid argument", when i
call
the __liblustre_setup_().

Here is my filelist:

*org.lustre.liblustre.test.MkDir.java
org_lustre_liblustre_test_MkDir.h
org_lustre_liblustre_test_MkDir.c
liblustremkdir.so.1.0
*liblustre.a
libcap.so.1.10
libpthread-2.5.so
libz.so.1.2.3


====================================================

Now, I would try to explain my steps by using JNI.  :-(  Maybe some
compile mistake I was made in the following steps.

First, I write i java class and use command "Javah" to generate
*org_lustre_liblustre_test_MkDir.h, *whose functions should be
implemented in org_lustre_liblustre_test_MkDir.c.

Here is just a small part of my *org_lustre_liblustre_test_MkDir.c*,
like sanity.c it calls __liblustre_setup_()and__liblustre_cleanup_().

[root at grid JNItests]# vim *org_lustre_liblustre_test_MkDir.c *
#include <jni.h>
#include "org_lustre_liblustre_test_MkDir.h"

extern void __liblustre_setup_(void);
extern void __liblustre_cleanup_(void);

JNIEXPORT void JNICALL
Java_org_lustre_liblustre_test_MkDir_init(JNIEnv
* env, jclass inclass)
{
printf("just kick!\n");
__liblustre_setup_();
printf("liblustre setup!!\n");
__liblustre_cleanup_();
return;

}
.........


[root at grid JNItests]# vim *org/lustre/liblustre/test/MkDir.java
.... System.loadLibrary("lustremkdir");...
*

====================================================

Second, I use gcc to build the corresponding ****.o file:

gcc -I/$JAVA_HOME/include -I/$JAVA_HOME/include/linux -shared -fPIC -c
*org_lustre_liblustre_test_MkDir.c

*====================================================

Third, I use gcc to build a shared *liblustremkdir.so.1.0, *and cp it
to
/usr/lib/.

gcc -shared -I/$JAVA_HOME/include -I/$JAVA_HOME/include/linux
-Wl,-soname,liblustremkdir.so.1 -o *liblustremkdir.so.1.0*
org_lustre_liblustre_test_MkDir.o liblustre.a libcap.so.1.10
libpthread-2.5.so libz.so.1.2.3

====================================================

Finally, the Java load the *liblustremkdir.so.1.0* and try to run.

[root at grid JNItests]# java org.lustre.liblustre.test.MkDir
begin to run Native method
...
1225417124.467324:6009:grid.scut.edu.cn:(class_obd.c:
543:init_obdclass()):
Lustre: 6009-grid.scut.edu.cn:(class_obd.c:543:init_obdclass()): OBD
class driver, http://www.lustre.org/
1225417124.467374:6009:grid.scut.edu.cn:(class_obd.c:
544:init_obdclass()):
Lustre: 6009-grid.scut.edu.cn:(class_obd.c:544:init_obdclass()):
Lustre
Version: 1.9.80
1225417124.467400:6009:grid.scut.edu.cn:(class_obd.c:
545:init_obdclass()):
Lustre: 6009-grid.scut.edu.cn:(class_obd.c:545:init_obdclass()): Build
Version:
1.9.80-20081019111435-CHANGED-.usr.src.linux-2.6.18-92.1.10-2.6.18-
prep
Lustre mount failed: Invalid argument

====================================================

Java seems call the c code successfully. But the above error, after
many
hard works, still exists.


Thanks!
Ya-Jian Luan
