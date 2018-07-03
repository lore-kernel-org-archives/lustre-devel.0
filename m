From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 14:10:54 +1000
Subject: [lustre-devel] [PATCH 05/18] lustre: llite: fast read
 implementation
In-Reply-To: <1530573875-20465-6-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-6-git-send-email-jsimmons@infradead.org>
Message-ID: <87woud0xip.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> +static ssize_t fast_read_store(struct kobject *kobj,
> +			       struct attribute *attr,
> +			       const char *buffer,
> +			       size_t count)
> +{
> +	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> +					      ll_kobj);
> +	bool val;
> +	int rc;
> +
> +	rc = kstrtobool(buffer, &val);
> +	if (rc)
> +		return rc;
> +
> +	spin_lock(&sbi->ll_lock);
> +	if (val)
> +		sbi->ll_flags |= LL_SBI_FAST_READ;
> +	else
> +		sbi->ll_flags &= ~LL_SBI_FAST_READ;
> +	spin_unlock(&sbi->ll_lock);

This is a little odd... no other code uses ll_lock to protect updates to
ll_flags.  Various other places (e.g. checksum_pages_store()) updates it
unprotected.

Maybe there all need to use ll_lock for protection.


Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/0137e8ad/attachment-0001.sig>
