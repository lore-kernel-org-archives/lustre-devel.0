From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 25 Jul 2013 02:39:20 +0000
Subject: [Lustre-devel] mounting a device twice
In-Reply-To: <51F00E38.7060601@tu-dresden.de>
References: <51F00E38.7060601@tu-dresden.de>
Message-ID: <AB42A35A-B204-4A5C-BB9E-5471BA85BACC@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

You can do this because the kernel is not actually mounting the block device twice. Lustre is mounting the block device internally as type ldiskfs and the second mount will be like a bind mount of the same filesystem root tree.

I do this on my local filesystem for quick debugging, but it isn't strictly safe on an active filesystem because modifications can render the Lustre and on disk state inconsistent. 

Cheers, Andreas

On 2013-07-24, at 11:27, "Michael Kluge" <michael.kluge@tu-dresden.de> wrote:

> Hi list,
> 
> can I mount a device mounted as lustre a second time as ldiskfs or would MMP protect me from doing this?
> 
> 
> Regards, Michael
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
