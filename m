From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 29 Nov 2017 11:41:25 +0100
Subject: [lustre-devel] [PATCH v2] Replace 'uint32_t' with 'u32' and
 'uint64_t' with 'u64'
In-Reply-To: <20171117114618.GA26318@home>
References: <20171117114618.GA26318@home>
Message-ID: <20171129104125.GA14678@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Nov 17, 2017 at 02:46:18PM +0300, Roman Storozhenko wrote:
> There are two reasons for that:
> 1) As Linus Torvalds said we should use kernel types:
> http://lkml.iu.edu/hypermail//linux/kernel/1506.0/00160.html
> 
> 2) There are only few places in the lustre codebase that use such types.
> In the most cases it uses 'u32' and 'u64'.
> 
> Signed-off-by: Roman Storozhenko <romeusmeister@gmail.com>
> 
> ---
> In the first version of this patch I replaced 'uint32_t' with '__u32' and
> 'uint64_t' with '__u64'. I was suggested to fix that by Greg K-H:
> 
> "The __ types are only needed for when you cross the user/kernel boundry.
> Otherwise just use the "normal" types of u32 and u64.
> 
> Do the changes you made here all cross that boundry?  If not, please fix
> this up."
> 
> I asked lustre community whether those code used only in the kernel
> space and Andreas Dilger said:
> 
> "These headers are for kernel code only, so should use the "u32" and
> similar
> types, rather than the "__u32" that are used for user-kernel
> structures."
> 
> So I have replaced my first patch version with this one.

Please fix up the subject to have the subsystem and driver name in it:
	Subject: [PATCH] staging: lustre: ...

thanks,

greg k-h
