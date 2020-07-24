From: Degremont, Aurelien <degremoa@amazon.com>
Date: Fri, 24 Jul 2020 11:35:55 +0000
Subject: [lustre-devel] [UNVERIFIED SENDER] Re: /usr/bin/fakeroot:
 debian/rules: Permission denied - Building Lustre client (v2.13.53)
In-Reply-To: <CAKVGuZY3Gywq2z3DXwePr0rpuZ+vCQ3Rdp6=-HtcKWa2Z2sBLA@mail.gmail.com>
References: <CAKVGuZYWmGswLZMAzLh1xQ=B872SwddyKt8dFGO6BynW63sQew@mail.gmail.com>
 <72DF4D14-559E-42B7-B18D-1565E5DA699B@amazon.com>
 <CAKVGuZY3Gywq2z3DXwePr0rpuZ+vCQ3Rdp6=-HtcKWa2Z2sBLA@mail.gmail.com>
Message-ID: <621C5D4F-D091-4D2F-A5F5-E038DAFE6339@amazon.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I remember seeing this problem?
Could you check your full log to see if there is no error above?
I'm pretty sure this permission error if not the real problem.


De : Ankit Ladhania <ankit@tripock.com>
Date : vendredi 24 juillet 2020 ? 12:51
? : "Degremont, Aurelien" <degremoa@amazon.com>
Cc : "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Objet : [EXTERNAL] [UNVERIFIED SENDER] Re: [lustre-devel] /usr/bin/fakeroot: debian/rules: Permission denied - Building Lustre client (v2.13.53)


CAUTION: This email originated from outside of the organization. Do not click links or open attachments unless you can confirm the sender and know the content is safe.


Hi Aurelien,
Thanks for replying.

Its a clean install. It was working fine in the previous linux header v5.3.0-62-generic but suddenly has stopped working on the newer version (v5.4.0-42-generic).

the steps I followed:

Steps to Build custom kernel - but same as the server it will run the client on.
1. uname -r (output: 5.4.0-42-generic)
2. git clone git://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git<http://kernel.ubuntu.com/ubuntu/ubuntu-bionic.git> ubuntu-kernel
3. cd ubuntu-kernel/
4. git tag | grep 5.4.0-42
5. git checkout Ubuntu-hwe-5.4-5.4.0-42.46_18.04.1
6. cp /boot/config-5.4.0-42-generic .config
7. touch .scmversion
8. sudo apt-get install libncurses-dev flex bison openssl libssl-dev dkms libelf-dev libudev-dev libpci-dev libiberty-dev autoconf
9. sudo apt-get build-dep linux linux-image-$(uname -r)
10. make -j $(nproc)

Steps to Build Lustre client:
1. git clone git://git.whamcloud.com/fs/lustre-release.git<http://git.whamcloud.com/fs/lustre-release.git>
2. cd lustre-release/
3. git checkout v2_13_53
4. sh autogen.sh
5. pwd
6. ./configure --disable-server --with-linux=/home/zeblok/ubuntu-kernel
7. make debs -j $(nproc)

its breaking in the last step, with below error.


make[1]: Leaving directory '/home/zeblok/lustre-release'

 dpkg-genbuildinfo

 dpkg-genchanges  >../lustre_2.13.53-1_amd64.changes

dpkg-genchanges: warning: package lustre-server-utils in control file but not in files list

dpkg-genchanges: warning: package lustre-resource-agents in control file but not in files list

dpkg-genchanges: warning: package lustre-client-modules-dkms in control file but not in files list

dpkg-genchanges: info: including full source code in upload

 dpkg-source -I.git -I*.out[0-9]* -I*.swp --after-build lustre-release

dpkg-buildpackage: info: full upload; Debian-native package (full source is included)

~/lustre-release/debian/tmp/modules-deb ~/lustre-release

Removing old /home/zeblok/lustre-release/debian/tmp/modules-deb/usr_src/modules/lustre/ tree

Extracting the package tarball, /usr/src/lustre.tar.bz2, please wait...

/usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied

/usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied

BUILD FAILED!

See /home/zeblok/lustre-release/debian/tmp/modules-deb/var_cache_modass/lustre.buildlog.5.4.0-42-generic.1595583181 for details.

mv: cannot stat '../lustre-dev__*.deb': No such file or directory

mv: cannot stat '../lustre-source__all.deb': No such file or directory

mv: cannot stat '../lustre-iokit__*.deb': No such file or directory

mv: cannot stat '../lustre-tests__*.deb': No such file or directory

mv: cannot stat '../lustre-*-utils__*.deb': No such file or directory

mv: cannot stat '../lustre_.dsc': No such file or directory

mv: cannot stat '../lustre__*.changes': No such file or directory

mv: cannot stat '../lustre_.tar.gz': No such file or directory

mv: cannot stat '../lustre-*-modules-5.4.0-42-generic__*.deb': No such file or directory

autoMakefile:1190: recipe for target 'debs' failed

make: *** [debs] Error 1

I tried the step you said but got the same result.


Regards,
Ankit Ladhania
IN: +91 933 444 2209
US:  +1 (256) 203-0077
Skype: ankit.ladhania


On Fri, Jul 24, 2020 at 3:30 PM Degremont, Aurelien <degremoa at amazon.com<mailto:degremoa@amazon.com>> wrote:
If I remember correctly, it looks like you already tried building Debian package in this directory.
Try cleaning everything and restart:

make clean
git clean -dfx
sh ./autogen.sh
./configure --disable-server
make debs

Aur?lien

De : lustre-devel <lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>> au nom de Ankit Ladhania <ankit at tripock.com<mailto:ankit@tripock.com>>
Date : vendredi 24 juillet 2020 ? 11:46
? : "lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>" <lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>>
Objet : [EXTERNAL] [lustre-devel] /usr/bin/fakeroot: debian/rules: Permission denied - Building Lustre client (v2.13.53)


CAUTION: This email originated from outside of the organization. Do not click links or open attachments unless you can confirm the sender and know the content is safe.



Hi,
We are installing the Lustre Client (v2.13.53) on Ubuntu 18.04 (linux header: 5.4.0-42-generic)
While doing `make debs` we are getting below error:

make[1]: Leaving directory '/home/zeblok/lustre-release'

 dpkg-genbuildinfo

 dpkg-genchanges  >../lustre_2.13.53-1_amd64.changes

dpkg-genchanges: warning: package lustre-server-utils in control file but not in files list

dpkg-genchanges: warning: package lustre-resource-agents in control file but not in files list

dpkg-genchanges: warning: package lustre-client-modules-dkms in control file but not in files list

dpkg-genchanges: info: including full source code in upload

 dpkg-source -I.git -I*.out[0-9]* -I*.swp --after-build lustre-release

dpkg-buildpackage: info: full upload; Debian-native package (full source is included)

~/lustre-release/debian/tmp/modules-deb ~/lustre-release

Removing old /home/zeblok/lustre-release/debian/tmp/modules-deb/usr_src/modules/lustre/ tree

Extracting the package tarball, /usr/src/lustre.tar.bz2, please wait...

/usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied

/usr/bin/fakeroot: 175: /usr/bin/fakeroot: debian/rules: Permission denied

BUILD FAILED!

See /home/zeblok/lustre-release/debian/tmp/modules-deb/var_cache_modass/lustre.buildlog.5.4.0-42-generic.1595583181 for details.

mv: cannot stat '../lustre-dev__*.deb': No such file or directory

mv: cannot stat '../lustre-source__all.deb': No such file or directory

mv: cannot stat '../lustre-iokit__*.deb': No such file or directory

mv: cannot stat '../lustre-tests__*.deb': No such file or directory

mv: cannot stat '../lustre-*-utils__*.deb': No such file or directory

mv: cannot stat '../lustre_.dsc': No such file or directory

mv: cannot stat '../lustre__*.changes': No such file or directory

mv: cannot stat '../lustre_.tar.gz': No such file or directory

mv: cannot stat '../lustre-*-modules-5.4.0-42-generic__*.deb': No such file or directory

autoMakefile:1190: recipe for target 'debs' failed

make: *** [debs] Error 1

Also tried doing 'chmod a+x debian/rules' but with no progress.

Not able to understand why this is breaking, any help is highly appreciated.

Regards,
Ankit Ladhania
IN: +91 933 444 2209
US:  +1 (256) 203-0077
Skype: ankit.ladhania
Erreur ! Nom du fichier non sp?cifi?.
[Image supprim?e par l'exp?diteur.]
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200724/e21d22ee/attachment-0001.html>
