From: kelly.zhang at emc.com <kelly.zhang@emc.com>
Date: Sun, 24 Jun 2012 22:05:24 -0400
Subject: [Lustre-devel] Fail to build Lustre on SUSE11
In-Reply-To: <alpine.LFD.2.02.1206201657060.13780@casper.infradead.org>
References: <F62E2618FCA29E42AB21F281C9511BB4137DACAE61@MX26A.corp.emc.com>
	<alpine.LFD.2.02.1206201657060.13780@casper.infradead.org>
Message-ID: <F62E2618FCA29E42AB21F281C9511BB4137F42580F@MX26A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks, that is good.

Best Regards,
Kelly

-----Original Message-----
From: James Simmons [mailto:jsimmons at infradead.org] 
Sent: 2012?6?21? 23:06
To: Zhang, Kelly
Cc: lustre-devel at lists.lustre.org; wc-discuss at whamcloud.com; Tang, Haiying; Liu, Xuezhao; tirrell, jerry; faibish, sorin
Subject: Re: [Lustre-devel] Fail to build Lustre on SUSE11


> Hello,
> 
> ?
> 
> There is a compiling error when building Lustre rpms on SUSE11, at ?make rpms?. Would you please help to check this.
> 
> The error is like:
> 
> /home/build/kernel/rpmbuild/BUILD/lustre-2.2.52/lustre/llite/llite_lib.c: In function ?ll_setattr_raw?:
> 
> /home/build/kernel/rpmbuild/BUILD/lustre-2.2.52/lustre/llite/llite_lib.c:1343: error: implicit declaration of function ?inode_newsize_ok ?
> 
> make[8]: *** [/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52/lustre/llite/llite_lib.o] Error 1
> 

Sorry I haven't read my emails recently. Take a look at 

http://jira.whamcloud.com/browse/LU-1497

I have links in the ticket to patches to fix this.

> make[7]: *** [/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52/lustre/llite] Error 2
> 
> make[6]: *** [/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52/lustre] Error 2
> 
> make[5]: *** [_module_/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52] Error 2
> 
> make[5]: Leaving directory `/var/tmp/kernel-source-2.6.27.19-build/usr/src/linux-2.6.27.19-5.1'
> 
> make[4]: *** [modules] Error 2
> 
> make[4]: Leaving directory `/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52'
> 
> make[3]: *** [all-recursive] Error 1
> 
> make[3]: Leaving directory `/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52'
> 
> make[2]: *** [all] Error 2
> 
> make[2]: Leaving directory `/home/build/kernel/rpmbuild/BUILD/lustre-2.2.52'
> 
> error: Bad exit status from /var/tmp/rpm-tmp.54512 (%build)
> 
> ?
> 
> ?
> 
> RPM build errors:
> 
> ??? Bad exit status from /var/tmp/rpm-tmp.54512 (%build)
> 
> make[1]: *** [rpms-real] Error 1
> 
> make[1]: Leaving directory `/home/build/lustre'
> 
> make: *** [rpms] Error 2
> 
> ?
> 
> Building machine arch: x86_64
> 
> Distribution: SUSE 11 SP1
> 
> Kernel Version used for building: 2.6.27.19-5.1
> 
> ?
> 
> Best Regards,
> 
> Kelly(EMC)
> 
> 
> 
