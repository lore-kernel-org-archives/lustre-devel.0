From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Fri, 17 Dec 2010 22:02:04 -0700
Subject: [Lustre-devel] ldiskfs build problem with rhel5.5
In-Reply-To: <4D0C03AF.2060800@sgi.com>
References: <4D0C03AF.2060800@sgi.com>
Message-ID: <92290CF5-B024-4110-8214-979943201E7F@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

You shouldn't apply the ldiskfs patches to the kernel at all. They are applied to a copy if the ext3/4 sources during the Lustre build process. 

Cheers, Andreas

On 2010-12-17, at 17:43, Jay Lan <jlan@sgi.com> wrote:

> Hi,
> 
> I ran into a problem in building ldiskfs-3.1.4 with 2.6.18-194.3.1.el5 
> kernel.
> The kernel was patched with kernel patches provided by lustre-1.8.5 and
> ldiskfs-3.1.4.
> 
> The problem I encountered was that the kernel and kernel-devel rpms
> did not provide fs/ext4/*.[ch], which the build process would need.
> 
> Is there a kernel patch for this problem?
> 
> Regards,
> Jay
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
