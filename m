From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 3 Feb 2016 14:19:09 -0800
Subject: [lustre-devel] [PATCH v2 00/13] staging:lustre: split kernel
 comm between user and kernel
In-Reply-To: <1450905892-31089-1-git-send-email-jsimmons@infradead.org>
References: <1450905892-31089-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160203221909.GA11314@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lustre-devel@lists.lustre.org

On Wed, Dec 23, 2015 at 04:24:39PM -0500, James Simmons wrote:
> The kernel communication code used for HSM and changelog is
> entangled. Move the user space bits into the liblustreapi. This will
> also help for a possible relicensing. The kernel portion is also moved
> from libcfs to obdclass.
> 
> The original libcfs_kernelcomm.h header is split into three parts:
> 
>   * lustre_kernelcomm.h, a new header for the kernel parts;
>   * uapi_kernelcomm.h, a new header for the data structures shared
>     between userspace and kernelspace;
>   * lustreapi_internal.h receives the private liblustreapi prototypes.
> 
> The original code in kernel_user_comm.c is split into two parts:
> 
>   * obdclass/kernelcomm.c for the kernel part. filp_user_write() was
>     moved there, and linux-fs.c deleted;
>   * liblustreapi_kernelconn.c for the user part. The calls to CDEBUG
>     have been removed, and calls to CERROR have been transformed to
>     llapi_err_noerrno. The type lustre_kernelcomm has been removed and
>     replace by struct lustre_kernelcomm.
> 
> Various names and filenames have been harmonized to *kernelcomm*.
> 
> The unused symbol KUC_FL_BLOCK has been removed.
> 
> Signed-off-by: frank zago <fzago@cray.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
> Reviewed-on: http://review.whamcloud.com/14270
> Reviewed-by: Nathan Rutman <nathan.rutman@seagate.com>
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

Note, your subject is the most difficult to deal with, as you didn't put
the 'v2' before each patch, just some of them, so you can't sort them in
an email client and I have to hand-edit them to get this to apply
properly :(

Please don't do that again...
