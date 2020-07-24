From: Peter Jones <pjones@whamcloud.com>
Date: Fri, 24 Jul 2020 12:44:47 +0000
Subject: [lustre-devel] /usr/bin/fakeroot: debian/rules: Permission
 denied - Building Lustre client (v2.13.53)
In-Reply-To: <CAKVGuZYWmGswLZMAzLh1xQ=B872SwddyKt8dFGO6BynW63sQew@mail.gmail.com>
References: <CAKVGuZYWmGswLZMAzLh1xQ=B872SwddyKt8dFGO6BynW63sQew@mail.gmail.com>
Message-ID: <E9DF4E52-8874-41CF-AD89-07FBFA678FBF@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hopefully you understand this already but just in case.- 2.13.53 is a development build and not intended for production usage. You should be able to build Ubuntu 18.04 clients for 2.12.x releases.

From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Ankit Ladhania <ankit@tripock.com>
Date: Friday, July 24, 2020 at 2:45 AM
To: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] /usr/bin/fakeroot: debian/rules: Permission denied - Building Lustre client (v2.13.53)


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
[Image removed by sender.]
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200724/053ffcb3/attachment.html>
