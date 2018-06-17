From: Greg KH <gregkh@linuxfoundation.org>
Date: Sun, 17 Jun 2018 13:22:03 +0200
Subject: [lustre-devel] [PATCH] Staging: lustre: Use kmemdup() instead
 of kzalloc and memcpy
In-Reply-To: <1529234215-4010-1-git-send-email-shreeya.patel23498@gmail.com>
References: <1529234215-4010-1-git-send-email-shreeya.patel23498@gmail.com>
Message-ID: <20180617112203.GA9357@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shreeya Patel <shreeya.patel23498@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Sun, Jun 17, 2018 at 04:46:55PM +0530, Shreeya Patel wrote:
> Replace calls to kzalloc or kmalloc followed by a memcpy with
> a direct call to kmemdup to shorten the code.
> 
> The Coccinelle semantic patch used to make this change is as follows:
> @@
> expression from,to,size,flag;
> statement S;
> @@
> 
> -  to = \(kmalloc\|kzalloc\)(size,flag);
> +  to = kmemdup(from,size,flag);
>    if (to==NULL || ...) S
> -  memcpy(to, from, size);
> 
> Signed-off-by: Shreeya Patel <shreeya.patel23498@gmail.com>
> ---
>  drivers/staging/lustre/lnet/lnet/api-ni.c | 5 ++---

Always work off of the latest kernel tree.  Ideally linux-next or the
staging.git staging-next tree.  Worse case, Linus's tree.  But never off
of an old kernel tree, that will only cause you to duplicate work that
others have done :(

Please resync against 4.18-rc1 and see why I say this when trying to
apply your patch...

thanks,

greg k-h
