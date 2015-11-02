From: Rick Wagner <rpwagner@sdsc.edu>
Date: Mon, 2 Nov 2015 20:25:01 +0000
Subject: [lustre-devel] porting Lustre server to RHEL6.7 distro running
 a kernel.org linux-3.12.39
In-Reply-To: <5637BD61.8060206@cray.com>
References: <2DDE0F15AAFF91448E6F813C42EF4CBEA195FDB8@ORSMSX105.amr.corp.intel.com>
	<5637B5CB.9090106@cray.com>
	<2DDE0F15AAFF91448E6F813C42EF4CBEA195FE29@ORSMSX105.amr.corp.intel.com>
	<5637BD61.8060206@cray.com>
Message-ID: <A20BE415-DF72-4A1C-B3B0-74BBFDC01497@sdsc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We?ve run ZFS-backed Lustre servers using a patchless (i.e., without ldiskfs) Linux 3 kernel under CentOS 6. While I don?t recommend this for everyone I can say that the mechanics of building the kernel modules (ZFS and Lustre) and standing up the file system all worked well. We?re looking to move back to a stock CentOS 6 kernel, but are sticking with the patchless model. If you?re willing to try ZFS I suspect the build will be fine, and then you should test test test.

I?ve included the outline of commands we use to build our server RPMs. You?ll want to adjust the versions of SPL, ZFS, & Lustre, along with the --with-linux and --with-linux-config parameters. I apologize for any typos and subsequent frustration. What level of dependency hell you find yourself in is is largely dependent on your choice of distro.

?Rick

git clone https://github.com/zfsonlinux/spl.git
cd spl
git checkout spl-0.6.5.3
./autogen.sh
./configure
make pkg
rpm -ivh *x86_64.rpm

cd ../
git clone https://github.com/zfsonlinux/zfs.git
cd zfs
git checkout zfs-0.6.5.3
./autogen.sh
./configure
make pkg
rpm -ivh *x86_64.rpm

cd ../
git clone http://git.whamcloud.com/fs/lustre-release.git
cd lustre-release
git checkout 2.7.62
sh autogen.sh
./configure --with-zfs=/usr/src/zfs-0.6.5.3 --with-spl=/usr/src/spl-0.6.5.3 --with-linux=/usr/src/linux-3.10 --without-ldiskfs --with-linux-config=/boot/config-3.10.73-1.el6.elrepo.x86_64  --with-o2ib=no
make rpms


On Nov 2, 2015, at 11:45 AM, Patrick Farrell <paf at cray.com<mailto:paf@cray.com>> wrote:

For ZFS:

The pitfall is primarily that it's less familiar than ldiskfs, which basically uses the standard Linux fs tools, like ext.  ZFS is its own world, which will probably have a learning curve for someone who has not used it before, and it must be built for the version of the kernel you're interested in.

But, Ben is right, that's likely to be easier than porting ldiskfs.

- Patrick

On 11/02/2015 01:35 PM, Smith, Stan wrote:
From: lustre-devel [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Patrick Farrell
Sent: Monday, November 2, 2015 11:13 AM
To: lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] porting Lustre server to RHEL6.7 distro running a kernel.org<http://kernel.org> linux-3.12.39

Stan,

Why not work with the CentOS 7 kernel on the server anyway?  Is something your LND needs not available?  CentOS 7 is freely available and isn't far off in terms of kernel version from 3.12.

Yes ?I?m somewhat stuck on RHEL 6.x series as I use warewulf as a cluster provisioning system (diskless compute nodes), so far have not found a functional warewulf for RHEL7.
I did choose linux-3.12.39 as a kernel base believing it to be somewhat close to RHEL7; although I?m finding this to less so than hoped for?.
Additionally the RD drivers I?m using have not been ported to RHEL7;
In examining lustre-2_7.62 I found support for sles12 based on 3.12.39 kernel.; thinking the lustre patches would be close?
So now I?m wedged between RHEL7 ldiskfs patches and SLES12 ldiskfs patches ? figure out distro specific enhancements vs lustre enhancements.

You may be hard pressed to get useful advice on changing the ldiskfs patch series, that has the potential to be a pretty big job.

I?m starting to understand the magnitude of the ldiskfs task??.

I?m ignorant about zfs*, would zfs be a better (read that as path-of-least-resistance) approach ?  What are the zfs pitfalls?

Thanks,

Stan.


Regards,
- Patrick Farrell
On 11/02/2015 01:05 PM, Smith, Stan wrote:
Hello,
  I?m currently unable to search the lustre-devel archives + 1st post to this list.

Having read lustre documentation I find only references to building lustre server for stock ?distro? kernels.

Does someone have suggestions on how to patch ldiskfs for a kernel.org<http://kernel.org> kernel?..specifically weeding out RHEL/SLES/* distro FS enhancements from a kernel.org<http://kernel.org> base?

I have written a Reliable Datagram LND which passes the LNet selftests (client lustre build) now entering the world of lustre server building.
Patching the kernel.org<http://kernel.org> kernel for lustre server was fairly straightforward, creating the patch series for ldiskfs is another story.

Thanks,

Stan.




_______________________________________________

lustre-devel mailing list

lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>

http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org



_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151102/45171c09/attachment-0001.htm>
