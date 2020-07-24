From: Ankit Ladhania <ankit@tripock.com>
Date: Fri, 24 Jul 2020 15:15:26 +0530
Subject: [lustre-devel] /usr/bin/fakeroot: debian/rules: Permission denied -
 Building Lustre client (v2.13.53)
Message-ID: <CAKVGuZYWmGswLZMAzLh1xQ=B872SwddyKt8dFGO6BynW63sQew@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,
We are installing the Lustre Client (v2.13.53) on Ubuntu 18.04 (linux
header: 5.4.0-42-generic)
While doing `make debs` we are getting below error:

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


Also tried doing 'chmod a+x debian/rules' but with no progress.

Not able to understand why this is breaking, any help is highly appreciated.


*Regards,Ankit Ladhania*
IN: +91 933 444 2209
US:  +1 (256) 203-0077
Skype: ankit.ladhania
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200724/e0a62ed1/attachment.html>
