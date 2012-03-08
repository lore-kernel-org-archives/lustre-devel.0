From: tao.peng at emc.com <tao.peng@emc.com>
Date: Thu, 8 Mar 2012 09:55:30 -0500
Subject: [Lustre-devel] oldest lustre supported SUSE kernel
In-Reply-To: <9C0BB3E3-D296-42A0-89EA-67F299215215@whamcloud.com>
References: <F19688880B763E40B28B2B462677FBF805E803B132@MX09A.corp.emc.com>
	<9C0BB3E3-D296-42A0-89EA-67F299215215@whamcloud.com>
Message-ID: <F19688880B763E40B28B2B462677FBF805EC1D87AC@MX09A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

> -----Original Message-----
> From: Andreas Dilger [mailto:adilger at whamcloud.com]
> Sent: Tuesday, February 07, 2012 12:36 AM
> To: Peng, Tao
> Cc: <lustre-devel@lists.lustre.org>
> Subject: Re: [Lustre-devel] oldest lustre supported SUSE kernel
> 
> On 2012-02-06, at 2:53, <tao.peng@emc.com> wrote:
> >
> > As I know, the oldest lustre supported RHEL kernel is 2.6.18-latest. What is the oldest SUSE kernel?
> 2.6.32-latest?
> 
> That depends on which version of Lustre you are asking about, and whether you are asking about the
> client or server.
> 
> For Lustre 2.2+ servers it will be SLES11 SP1 (2.6.32), since it matches RHEL6 (2.6.32).
> 
> For clients it is RHEL5 (2.6.18) and SLES11 SP0 (2.6.27).
> 
We found that latest master branch doesn't build client for SLES11 SP0 (2.6.27). Does it mean master has moved on dropping SLES11 SP0 or it should be fixed?

Thanks,
Tao

From: Zhang, Kelly 
Sent: Thursday, March 08, 2012 6:44 PM
To: Peng, Tao
Cc: China COE FastData
Subject: RE: Conversation with Zhang, Kelly

The latest Lustre code also fails on suse11SP0(kernel version  linux-2.6.27.19-5.1), when building Lustre:
cc1: warnings being treated as errors
/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre/llite/llite_mmap.c:585: error: initialization from incompatible pointer type
make[8]: *** [/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre/llite/llite_mmap.o] Error 1
make[7]: *** [/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre/llite] Error 2
make[6]: *** [/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50/lustre] Error 2
make[5]: *** [_module_/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50] Error 2
make[5]: Leaving directory `/var/tmp/kernel-source-2.6.27.19-build/usr/src/linux-2.6.27.19-5.1'
make[4]: *** [modules] Error 2
make[4]: Leaving directory `/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50'
make[3]: *** [all-recursive] Error 1
make[3]: Leaving directory `/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50'
make[2]: *** [all] Error 2
make[2]: Leaving directory `/home/master/kernel/rpmbuild/BUILD/lustre-2.2.50'
error: Bad exit status from /var/tmp/rpm-tmp.76807 (%build)
