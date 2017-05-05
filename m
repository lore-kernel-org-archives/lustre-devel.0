From: Joe Perches <joe@perches.com>
Date: Fri, 05 May 2017 01:52:36 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: llite: Fix variable
 length array warning
In-Reply-To: <1493966486-6143-1-git-send-email-gurooodas@gmail.com>
References: <1493966486-6143-1-git-send-email-gurooodas@gmail.com>
Message-ID: <1493974356.31950.13.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guru Das Srinagesh <gurooodas@gmail.com>, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org
Cc: john.hammond@intel.com, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Thu, 2017-05-04 at 23:41 -0700, Guru Das Srinagesh wrote:
> Fix sparse warning "warning: Variable length array is used." by using
> kmalloc_array to allocate the required amount of memory instead and
> kfree to deallocate memory after use.
[]
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
[]
> @@ -86,7 +86,8 @@ ll_xattr_set_common(const struct xattr_handler *handler,
>  		    const char *name, const void *value, size_t size,
>  		    int flags)
>  {
> -	char fullname[strlen(handler->prefix) + strlen(name) + 1];
> +	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
> +	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_KERNEL);

What happens when this allocation fails?
