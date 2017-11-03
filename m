From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 3 Nov 2017 12:46:18 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: Replaces 'uint32_t'
 with '__u32' and 'uint64_t' with '__u64'.
In-Reply-To: <20171029175839.GA19864@home>
References: <20171029175839.GA19864@home>
Message-ID: <20171103114618.GA11059@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 29, 2017 at 08:58:39PM +0300, Roman Storozhenko wrote:
> There are two reasons for that:
> 1) As Linus Torvalds said we should use kernel types:
> http://lkml.iu.edu/hypermail//linux/kernel/1506.0/00160.html
> 
> 2) There are only few places in the lustre codebase that use such types.
> In the most cases it uses '__u32' and '__u64'.

The __ types are only needed for when you cross the user/kernel boundry.
Otherwise just use the "normal" types of u32 and u64.

Do the changes you made here all cross that boundry?  If not, please fix
this up.

thanks,

greg k-h
