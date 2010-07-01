From: Onkar Mahajan <kern.devel@gmail.com>
Date: Thu, 1 Jul 2010 17:28:16 +0530
Subject: [Lustre-devel] configuration error while building lustre ,
	please help !
Message-ID: <AANLkTilCTq2Q011hC9_esdkMgHarLzx7Hc3Ypyu9jvNz@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I am trying to compile lustre like this :

[onkar at localhost build-lustre]$ ./configure
--with-kernel-source-header=/home/onkar/LUSTRE/linux-2.6.33.3/include
--with-linux=/home/onkar/LUSTRE/linux-2.6.33.3
--with-linux-obj=/home/onkar/LUSTRE/linux-2.6.33.3
--with-linux-config=/home/onkar/LUSTRE/linux-2.6.33.3
checking build system type... i686-pc-linux-gnu
checking host system type... i686-pc-linux-gnu
checking target system type... i686-pc-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking for style of include used by make... GNU
checking dependency style of gcc... gcc3
checking how to run the C preprocessor... gcc -E
checking for grep that handles long lines and -e... /bin/grep
checking for egrep... /bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking whether to build Cray XT3 features... no
checking whether to build BGL features... no
checking for ranlib... ranlib
checking for buggy compiler... no known problems
checking size of unsigned long long... 8
---> size SIZEOF
---> size SIZEOF 8
checking whether to enable uoss... no
checking whether to enable posix osd... no
checking whether to build docs... no
checking whether to build utilities... yes
checking whether to install init scripts... yes
checking whether to build Lustre tests... yes
checking whether to build Lustre server support... yes
checking whether to build Lustre client support... yes
checking whether to enable split support... no
checking whether to enable CDEBUG, CWARN... yes
checking whether to enable ENTRY/EXIT... yes
checking whether to enable LASSERT, LASSERTF... yes
checking sys/quota.h usability... yes
checking sys/quota.h presence... yes
checking for sys/quota.h... yes
checking whether to build kernel modules... yes (linux-gnu)
checking for Linux sources... /home/onkar/LUSTRE/linux-2.6.33.3
checking for /home/onkar/LUSTRE/linux-2.6.33.3... yes
checking for Linux objects dir... /home/onkar/LUSTRE/linux-2.6.33.3
checking for /boot/kernel.h... no
checking for /var/adm/running-kernel.h... no
checking for /home/onkar/LUSTRE/linux-2.6.33.3... (cached) yes
checking for /home/onkar/LUSTRE/linux-2.6.33.3/include/linux/autoconf.h...
no
*configure: error: Run make config in /home/onkar/LUSTRE/linux-2.6.33.3.*
[onkar at localhost build-lustre]$ uname -a
Linux localhost.localdomain 2.6.33.3-85.fc13.i686.PAE #1 SMP Thu May 6
18:27:11 UTC 2010 i686 i686 i386 GNU/Linux

Please help me.


Regards,
Onkar



-- 
****************************************************
A 1965 Ford Mustang is a great car. But if you want to go to the moon,
I don't think that's the right vehicle. You'd better design a space craft.
- Sunay Tripathi
 Distinguished Engineer,
 Sun Microsystems
*******************************************************
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100701/3d5d5998/attachment.htm>
