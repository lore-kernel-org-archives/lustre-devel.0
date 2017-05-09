From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 9 May 2017 11:31:36 +0300
Subject: [lustre-devel] [PATCH v4] staging: lustre: llite: Fix variable
 length array warning
In-Reply-To: <1494313036-15955-1-git-send-email-gurooodas@gmail.com>
References: <1494313036-15955-1-git-send-email-gurooodas@gmail.com>
Message-ID: <20170509083136.auumomyrgat4oc2k@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guru Das Srinagesh <gurooodas@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, joe@perches.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This patch introduces tons of memory leaks so we can't apply it.

Just ignore the warning.  The size is small enough that it won't
overflow the stack.  The other reason to avoid these types of
declarations is that in olden times (5 years ago at least) there was a
GCC for an arch where if you declared the variable inside a loop it
would not free the memory until after the end of the loop.

	while ((foo = frob())) {
		int whatver[x + y];
	}

The memory would keep increasing until we broke from the loop or it
overflowed the stack and crashed.

On Mon, May 08, 2017 at 11:57:16PM -0700, Guru Das Srinagesh wrote:
> Fix sparse warning "warning: Variable length array is used." by using
> kmalloc_array to allocate the required amount of memory instead and
> kfree to deallocate memory after use.
> 
> Signed-off-by: Guru Das Srinagesh <gurooodas@gmail.com>
> ---
>  v4:
>    - Changed kmalloc_array flags from GFP_KERNEL to GFP_ATOMIC
> 
>  v3:
>    - Fixed checkpatch warning: Comparison to NULL could be written "!fullname"
> 
>  v2:
>    - Added missing check for NULL return value of kmalloc_array()
> 
>  drivers/staging/lustre/lustre/llite/xattr.c | 23 +++++++++++++++++++----
>  1 file changed, 19 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> index 6187bff..ae2efd5 100644
> --- a/drivers/staging/lustre/lustre/llite/xattr.c
> +++ b/drivers/staging/lustre/lustre/llite/xattr.c
> @@ -86,13 +86,17 @@ ll_xattr_set_common(const struct xattr_handler *handler,
>  		    const char *name, const void *value, size_t size,
>  		    int flags)
>  {
> -	char fullname[strlen(handler->prefix) + strlen(name) + 1];
> +	int fullname_len = strlen(handler->prefix) + strlen(name) + 1;
> +	char *fullname = kmalloc_array(fullname_len, sizeof(char), GFP_ATOMIC);

Using kmalloc_array() is pointless.  Everyone knows that sizeof(char) is
1 and also that 1 * x == x.  It just makes the code more confusing and
complicated for no reason.  Don't hide the allocation this declaration
block.  It should be next to the check for NULL.  But anyway, don't
bother resending, just ignore the warning.

regards,
dan carpenter
