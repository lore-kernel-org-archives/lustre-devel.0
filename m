From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 16 Apr 2018 17:45:48 +0300
Subject: [lustre-devel] [PATCH 08/25] staging: lustre: libcfs: add cpu
 distance handling
In-Reply-To: <1523851807-16573-9-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
 <1523851807-16573-9-git-send-email-jsimmons@infradead.org>
Message-ID: <20180416144548.xjjcaxivkbvynsux@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:50AM -0400, James Simmons wrote:
> +int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
> +{
> +	char *tmp = buf;
> +	int rc = -EFBIG;
> +	int i;
> +	int j;
> +
> +	for (i = 0; i < cptab->ctb_nparts; i++) {
> +		if (len <= 0)
> +			goto err;
> +
> +		rc = snprintf(tmp, len, "%d\t:", i);
> +		len -= rc;
> +
> +		if (len <= 0)
> +			goto err;


The "goto err" here is sort of an example of a "do-nothing" goto.  There
are no resources to free or anything like that.

I don't like do-nothing gotos because "return -EFBIG;" is self
documenting code and "goto err;" is totally ambiguous what it does.  The
second problem is that do-nothing error labels easily turn into
do-everything one err style error paths which I loath.  And the third
problem is that they introduce "forgot to set the error code" bugs.

It looks like we forgot to set the error code here although it's also
possible that was intended.  This code is ambiguous.

> +
> +		tmp += rc;
> +		for (j = 0; j < cptab->ctb_nparts; j++) {
> +			rc = snprintf(tmp, len, " %d:%d",
> +				      j, cptab->ctb_parts[i].cpt_distance[j]);
> +			len -= rc;
> +			if (len <= 0)
> +				goto err;
> +			tmp += rc;
> +		}
> +
> +		*tmp = '\n';
> +		tmp++;
> +		len--;
> +	}
> +	rc = 0;
> +err:
> +	if (rc < 0)
> +		return rc;
> +
> +	return tmp - buf;
> +}

regards,
dan carpenter
