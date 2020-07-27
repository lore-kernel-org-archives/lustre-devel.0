From: Ankit Ladhania <ankit@tripock.com>
Date: Mon, 27 Jul 2020 22:38:14 +0530
Subject: [lustre-devel] /usr/bin/fakeroot: debian/rules: Permission
 denied - Building Lustre client (v2.13.53)
In-Reply-To: <CANdLGj4Kfqtb0jPuZdjfMMAQt_qxJE=aVUv=W_seihSsS2du=A@mail.gmail.com>
References: <CAKVGuZYWmGswLZMAzLh1xQ=B872SwddyKt8dFGO6BynW63sQew@mail.gmail.com>
 <72DF4D14-559E-42B7-B18D-1565E5DA699B@amazon.com>
 <CAKVGuZY3Gywq2z3DXwePr0rpuZ+vCQ3Rdp6=-HtcKWa2Z2sBLA@mail.gmail.com>
 <CANdLGj4Kfqtb0jPuZdjfMMAQt_qxJE=aVUv=W_seihSsS2du=A@mail.gmail.com>
Message-ID: <CAKVGuZaSSDryjdTEBHzgB8iTMLJbh4nLqdvaaHeLwf7NeBkObQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,
I have been trying to install Lustre client (v2.13.55) on Ubuntu 18.04 and
16.04 for the past 6 days and have not been successful. I have been getting
the below errors:

All I want is a direction to debug the issue (Have tried almost all the
solutions present in the web). I dont understand what is the requirement
for Lustre as on some nodes I'm able to install it and on nodes it just
wouldn't install. (I checked the versions of the installed packages (dpkg
-l) and found only minor version changes)

Again Any Help is really appreciated.

*Ubuntu 18.04:*

*Steps to Build custom kernel - but same as the server it will run the
client on.*
1. uname -r (output: 5.4.0-42-generic)
2. git clone git://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git
<https://mailtrack.io/trace/link/9d8dbf7625bb99cabf6a3629f21d8e0d14418dfb?url=http%3A%2F%2Fkernel.ubuntu.com%2Fubuntu%2Fubuntu-bionic.git&userId=3941104&signature=d677cc853c3a2a99>
 ubuntu-kernel
3. cd ubuntu-kernel/
4. git tag | grep 5.4.0-42
5. git checkout Ubuntu-hwe-5.4-5.4.0-42.46_18.04.1
6. cp /boot/config-5.4.0-42-generic .config
7. touch .scmversion
8. sudo apt-get install libncurses-dev flex bison openssl libssl-dev dkms
libelf-dev libudev-dev libpci-dev libiberty-dev autoconf
9. sudo apt-get build-dep linux linux-image-$(uname -r)
10. make -j $(nproc)

*Steps to Build Lustre client:*
1. git clone git://git.whamcloud.com/fs/lustre-release.git
<https://mailtrack.io/trace/link/cc63c89f0f6e035b31ffe195e51d16f198f20077?url=http%3A%2F%2Fgit.whamcloud.com%2Ffs%2Flustre-release.git&userId=3941104&signature=7139133553cf8999>
2. cd lustre-release/
3. git checkout v2_13_53
4. sh autogen.sh
5. pwd
6. ./configure --disable-server --with-linux=/home/zeblok/ubuntu-kernel
7. make debs -j $(nproc)

*Error:*

make[1]: Leaving directory '/home/zeblok/lustre-release'

 dpkg-genbuildinfo
 dpkg-genchanges  >../lustre_2.13.53-1_amd64.changes
dpkg-genchanges: warning: package lustre-server-utils in control file
but not in files list
dpkg-genchanges: warning: package lustre-resource-agents in control
file but not in files list
dpkg-genchanges: warning: package lustre-client-modules-dkms in
control file but not in files list
dpkg-genchanges: info: including full source code in upload
 dpkg-source -I.git -I*.out[0-9]* -I*.swp --after-build lustre-release
dpkg-buildpackage: info: full upload; Debian-native package (full
source is included)
~/lustre-release/debian/tmp/modules-deb ~/lustre-release
Removing old /home/zeblok/lustre-release/debian/tmp/modules-deb/usr_src/modules/lustre/
tree
Extracting the package tarball, /usr/src/lustre.tar.bz2, please wait...
/usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied
/usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied
BUILD FAILED!
See /home/zeblok/lustre-release/debian/tmp/modules-deb/var_cache_modass/lustre.buildlog.5.4.0-42-generic.1595583181
for details.
mv: cannot stat '../lustre-dev__*.deb': No such file or directory
mv: cannot stat '../lustre-source__all.deb': No such file or directory
mv: cannot stat '../lustre-iokit__*.deb': No such file or directory
mv: cannot stat '../lustre-tests__*.deb': No such file or directory
mv: cannot stat '../lustre-*-utils__*.deb': No such file or directory
mv: cannot stat '../lustre_.dsc': No such file or directory
mv: cannot stat '../lustre__*.changes': No such file or directory
mv: cannot stat '../lustre_.tar.gz': No such file or directory
mv: cannot stat '../lustre-*-modules-5.4.0-42-generic__*.deb': No such
file or directory
autoMakefile:1190: recipe for target 'debs' failed
make: *** [debs] Error 1


*Ubuntu 16.04:*
*Similar building process for Ubuntu 16.04:*

 LD [M]  /home/zeblok/lustre-release/lustre/ptlrpc/ptlrpc.o
Makefile:1471: recipe for target '_module_/home/zeblok/lustre-release'
failed
make[5]: *** [_module_/home/zeblok/lustre-release] Error 2
make[5]: Leaving directory '/usr/src/linux-headers-4.4.0-186-generic'
autoMakefile:1051: recipe for target 'modules' failed
make[4]: *** [modules] Error 2
make[4]: Leaving directory '/home/zeblok/lustre-release'
autoMakefile:592: recipe for target 'all-recursive' failed
make[3]: *** [all-recursive] Error 1
make[3]: Leaving directory '/home/zeblok/lustre-release'
autoMakefile:490: recipe for target 'all' failed
make[2]: *** [all] Error 2
make[2]: Leaving directory '/home/zeblok/lustre-release'
debian/rules:218: recipe for target 'build-stamp' failed
make[1]: *** [build-stamp] Error 2
make[1]: Leaving directory '/home/zeblok/lustre-release'
dpkg-buildpackage: error: debian/rules build gave error exit status 2
cp: cannot stat '/control.bkp': No such file or directory
cp: cannot stat '/control.main.bkp': No such file or directory
cp: cannot stat '/control.modules.in.bkp': No such file or directory
autoMakefile:1188: recipe for target 'debs' failed
make: *** [debs] Error 2


On Sat, Jul 25, 2020 at 3:59 AM Christian Kuntz <c.kuntz@opendrives.com>
wrote:

> Oh hey, I think I might know what this is!
>
> In debian/rules, line 344 uses some sed fanciness to make a new rules file
> in a different directory. Since the send file is just a text stream into a
> file, it doesn't maintain the x bit of the parent. To fix, I placed this in
> line 345:
>
> chmod +x debian/$(SOURCE_PKG)/usr/src/modules/lustre/debian/rules
>
> Hope this helps!
>
> Christian
>
> On Fri, Jul 24, 2020, 3:50 AM Ankit Ladhania <ankit@tripock.com> wrote:
>
>> Hi Aurelien,
>> Thanks for replying.
>>
>> Its a clean install. It was working fine in the previous linux header
>> v5.3.0-62-generic but suddenly has stopped working on the newer version
>> (v5.4.0-42-generic).
>>
>> the steps I followed:
>>
>> *Steps to Build custom kernel - but same as the server it will run the
>> client on.*
>> 1. uname -r (output: 5.4.0-42-generic)
>> 2. git clone git://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git
>> <https://mailtrack.io/trace/link/b0639b0344425c397c1a970e60f397cc7aa7419f?url=http%3A%2F%2Fkernel.ubuntu.com%2Fubuntu%2Fubuntu-bionic.git&userId=3941104&signature=a3a95f59044373d7>
>> ubuntu-kernel
>> 3. cd ubuntu-kernel/
>> 4. git tag | grep 5.4.0-42
>> 5. git checkout Ubuntu-hwe-5.4-5.4.0-42.46_18.04.1
>> 6. cp /boot/config-5.4.0-42-generic .config
>> 7. touch .scmversion
>> 8. sudo apt-get install libncurses-dev flex bison openssl libssl-dev dkms
>> libelf-dev libudev-dev libpci-dev libiberty-dev autoconf
>> 9. sudo apt-get build-dep linux linux-image-$(uname -r)
>> 10. make -j $(nproc)
>>
>> *Steps to Build Lustre client:*
>> 1. git clone git://git.whamcloud.com/fs/lustre-release.git
>> <https://mailtrack.io/trace/link/c0dd536de951705dac553b5a83efac4980b5817c?url=http%3A%2F%2Fgit.whamcloud.com%2Ffs%2Flustre-release.git&userId=3941104&signature=f8338ef94e11e226>
>> 2. cd lustre-release/
>> 3. git checkout v2_13_53
>> 4. sh autogen.sh
>> 5. pwd
>> 6. ./configure --disable-server --with-linux=/home/zeblok/ubuntu-kernel
>> 7. make debs -j $(nproc)
>>
>> its breaking in the last step, with below error.
>>
>> make[1]: Leaving directory '/home/zeblok/lustre-release'
>>  dpkg-genbuildinfo
>>  dpkg-genchanges  >../lustre_2.13.53-1_amd64.changes
>> dpkg-genchanges: warning: package lustre-server-utils in control file but not in files list
>> dpkg-genchanges: warning: package lustre-resource-agents in control file but not in files list
>> dpkg-genchanges: warning: package lustre-client-modules-dkms in control file but not in files list
>> dpkg-genchanges: info: including full source code in upload
>>  dpkg-source -I.git -I*.out[0-9]* -I*.swp --after-build lustre-release
>> dpkg-buildpackage: info: full upload; Debian-native package (full source is included)
>> ~/lustre-release/debian/tmp/modules-deb ~/lustre-release
>> Removing old /home/zeblok/lustre-release/debian/tmp/modules-deb/usr_src/modules/lustre/ tree
>> Extracting the package tarball, /usr/src/lustre.tar.bz2, please wait...
>> /usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied
>> /usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied
>> BUILD FAILED!
>> See /home/zeblok/lustre-release/debian/tmp/modules-deb/var_cache_modass/lustre.buildlog.5.4.0-42-generic.1595583181 for details.
>> mv: cannot stat '../lustre-dev__*.deb': No such file or directory
>> mv: cannot stat '../lustre-source__all.deb': No such file or directory
>> mv: cannot stat '../lustre-iokit__*.deb': No such file or directory
>> mv: cannot stat '../lustre-tests__*.deb': No such file or directory
>> mv: cannot stat '../lustre-*-utils__*.deb': No such file or directory
>> mv: cannot stat '../lustre_.dsc': No such file or directory
>> mv: cannot stat '../lustre__*.changes': No such file or directory
>> mv: cannot stat '../lustre_.tar.gz': No such file or directory
>> mv: cannot stat '../lustre-*-modules-5.4.0-42-generic__*.deb': No such file or directory
>> autoMakefile:1190: recipe for target 'debs' failed
>> make: *** [debs] Error 1
>>
>>
>> I tried the step you said but got the same result.
>>
>>
>>
>> *Regards,Ankit Ladhania*
>> IN: +91 933 444 2209
>> US:  +1 (256) 203-0077
>> Skype: ankit.ladhania
>>
>>
>> On Fri, Jul 24, 2020 at 3:30 PM Degremont, Aurelien <degremoa@amazon.com>
>> wrote:
>>
>>> If I remember correctly, it looks like you already tried building Debian
>>> package in this directory.
>>>
>>> Try cleaning everything and restart:
>>>
>>>
>>>
>>> make clean
>>>
>>> git clean -dfx
>>>
>>> sh ./autogen.sh
>>>
>>> ./configure --disable-server
>>>
>>> make debs
>>>
>>>
>>>
>>> Aur?lien
>>>
>>>
>>>
>>> *De : *lustre-devel <lustre-devel-bounces@lists.lustre.org> au nom de
>>> Ankit Ladhania <ankit@tripock.com>
>>> *Date : *vendredi 24 juillet 2020 ? 11:46
>>> *? : *"lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
>>> *Objet : *[EXTERNAL] [lustre-devel] /usr/bin/fakeroot: debian/rules:
>>> Permission denied - Building Lustre client (v2.13.53)
>>>
>>>
>>>
>>> *CAUTION*: This email originated from outside of the organization. Do
>>> not click links or open attachments unless you can confirm the sender and
>>> know the content is safe.
>>>
>>>
>>>
>>>
>>>
>>> Hi,
>>>
>>> We are installing the Lustre Client (v2.13.53) on Ubuntu 18.04 (linux
>>> header: 5.4.0-42-generic)
>>>
>>> While doing `make debs` we are getting below error:
>>>
>>> make[1]: Leaving directory '/home/zeblok/lustre-release'
>>>
>>>  dpkg-genbuildinfo
>>>
>>>  dpkg-genchanges  >../lustre_2.13.53-1_amd64.changes
>>>
>>> dpkg-genchanges: warning: package lustre-server-utils in control file but not in files list
>>>
>>> dpkg-genchanges: warning: package lustre-resource-agents in control file but not in files list
>>>
>>> dpkg-genchanges: warning: package lustre-client-modules-dkms in control file but not in files list
>>>
>>> dpkg-genchanges: info: including full source code in upload
>>>
>>>  dpkg-source -I.git -I*.out[0-9]* -I*.swp --after-build lustre-release
>>>
>>> dpkg-buildpackage: info: full upload; Debian-native package (full source is included)
>>>
>>> ~/lustre-release/debian/tmp/modules-deb ~/lustre-release
>>>
>>> Removing old /home/zeblok/lustre-release/debian/tmp/modules-deb/usr_src/modules/lustre/ tree
>>>
>>> Extracting the package tarball, /usr/src/lustre.tar.bz2, please wait...
>>>
>>> /usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied
>>>
>>> /usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied
>>>
>>> BUILD FAILED!
>>>
>>> See /home/zeblok/lustre-release/debian/tmp/modules-deb/var_cache_modass/lustre.buildlog.5.4.0-42-generic.1595583181 for details.
>>>
>>> mv: cannot stat '../lustre-dev__*.deb': No such file or directory
>>>
>>> mv: cannot stat '../lustre-source__all.deb': No such file or directory
>>>
>>> mv: cannot stat '../lustre-iokit__*.deb': No such file or directory
>>>
>>> mv: cannot stat '../lustre-tests__*.deb': No such file or directory
>>>
>>> mv: cannot stat '../lustre-*-utils__*.deb': No such file or directory
>>>
>>> mv: cannot stat '../lustre_.dsc': No such file or directory
>>>
>>> mv: cannot stat '../lustre__*.changes': No such file or directory
>>>
>>> mv: cannot stat '../lustre_.tar.gz': No such file or directory
>>>
>>> mv: cannot stat '../lustre-*-modules-5.4.0-42-generic__*.deb': No such file or directory
>>>
>>> autoMakefile:1190: recipe for target 'debs' failed
>>>
>>> make: *** [debs] Error 1
>>>
>>>
>>>
>>> Also tried doing 'chmod a+x debian/rules' but with no progress.
>>>
>>>
>>>
>>> Not able to understand why this is breaking, any help is highly
>>> appreciated.
>>>
>>>
>>>
>>> *Regards, Ankit Ladhania*
>>>
>>> IN: +91 933 444 2209
>>> US:  +1 (256) 203-0077
>>>
>>> Skype: ankit.ladhania
>>>
>>> [image: Image supprim?e par l'exp?diteur.]
>>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>> <https://mailtrack.io/trace/link/0695b57bf4ddfa198d750b131a33a3c670ece42c?url=http%3A%2F%2Flists.lustre.org%2Flistinfo.cgi%2Flustre-devel-lustre.org&userId=3941104&signature=cee65cec6208e621>
>>
>
>
> <https://mailtrack.io/trace/link/15758f8916c88d705160a929b0b36b2c89701fbb?url=http%3A%2F%2Fopendrives.com&userId=3941104&signature=eabf41d08699a800>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200727/1b12a4be/attachment-0001.html>
