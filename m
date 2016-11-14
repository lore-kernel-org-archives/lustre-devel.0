From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 14 Nov 2016 16:12:46 +0100
Subject: [lustre-devel] [PATCH 32/35] staging: lustre: mount: fix
 lmd_parse() to handle commas in expr_list
In-Reply-To: <1478799065-24841-33-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
	<1478799065-24841-33-git-send-email-jsimmons@infradead.org>
Message-ID: <20161114151246.GA29168@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>

On Thu, Nov 10, 2016 at 12:31:02PM -0500, James Simmons wrote:
> From: Jian Yu <jian.yu@intel.com>
> 
> The lmd_parse() function parses mount options with comma as
> delimiter without considering commas in expr_list as follows
> is a valid LNET nid range syntax:
> 
> <expr_list>  :== '[' <range_expr> [ ',' <range_expr>] ']'
> 
> This patch fixes the above issue by using cfs_parse_nidlist()
> to parse nid range list instead of using class_parse_nid_quiet()
> to parse only one nid.

ugh, parsing mount strings in the kernel in odd ways, what could ever go
wrong...

> 
> Signed-off-by: Jian Yu <jian.yu@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5690
> Reviewed-on: http://review.whamcloud.com/17036
> Reviewed-by: Niu Yawei <yawei.niu@intel.com>
> Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c |   91 ++++++++++++++++++--
>  1 files changed, 85 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> index 2283e92..1eb8e71 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> @@ -871,6 +871,87 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
>  	return 0;
>  }
>  
> +/**
> + * Find the first comma delimiter from the specified \a buf and make \a *endh
> + * point to the string starting with the comma. The commas in expression list
> + * [...] will be skipped.
> + *
> + * \param[in] buf	a comma-separated string
> + * \param[in] endh	a pointer to a pointer that will point to the string
> + *			starting with the comma

Please drop this mess of \param, it's not needed and is not kernel-doc
format.

> + *
> + * \retval 0		if comma delimiter is found
> + * \retval 1		if comma delimiter is not found
> + */
> +static int lmd_find_comma(char *buf, char **endh)
> +{
> +	char *c = buf;
> +	int skip = 0;
> +
> +	if (!buf)
> +		return 1;
> +
> +	while (*c != '\0') {
> +		if (*c == '[')
> +			skip++;
> +		else if (*c == ']')
> +			skip--;
> +
> +		if (*c == ',' && !skip) {
> +			if (endh)
> +				*endh = c;
> +			return 0;
> +		}
> +		c++;
> +	}
> +	return 1;
> +}

Don't we have a standard string search function for finding a string in
a string already in the kernel?  Why write another one?

Or better yet, why are you using such a crazy string in the first place
from userspace?

Please fix this up and resend.

thanks,

greg k-h
