From: Patrick Farrell <paf@cray.com>
Date: Tue, 3 Jul 2018 12:46:53 +0000
Subject: [lustre-devel] [PATCH 05/18] lustre: llite: fast read
 implementation
In-Reply-To: <87woud0xip.fsf@notabene.neil.brown.name>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-6-git-send-email-jsimmons@infradead.org>,
 <87woud0xip.fsf@notabene.neil.brown.name>
Message-ID: <DM3PR1101MB121395BDC6EC6AA3130F42EFCB420@DM3PR1101MB1213.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


They do.  It?s probably gone unnoticed because those updates are mostly directly triggered by users or one time only during initialization, so there?s little risk of colliding.

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Monday, July 2, 2018 11:10:54 PM
To: James Simmons; Andreas Dilger; Oleg Drokin
Cc: Lustre Development List
Subject: Re: [lustre-devel] [PATCH 05/18] lustre: llite: fast read implementation

On Mon, Jul 02 2018, James Simmons wrote:

> +static ssize_t fast_read_store(struct kobject *kobj,
> +                            struct attribute *attr,
> +                            const char *buffer,
> +                            size_t count)
> +{
> +     struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> +                                           ll_kobj);
> +     bool val;
> +     int rc;
> +
> +     rc = kstrtobool(buffer, &val);
> +     if (rc)
> +             return rc;
> +
> +     spin_lock(&sbi->ll_lock);
> +     if (val)
> +             sbi->ll_flags |= LL_SBI_FAST_READ;
> +     else
> +             sbi->ll_flags &= ~LL_SBI_FAST_READ;
> +     spin_unlock(&sbi->ll_lock);

This is a little odd... no other code uses ll_lock to protect updates to
ll_flags.  Various other places (e.g. checksum_pages_store()) updates it
unprotected.

Maybe there all need to use ll_lock for protection.


Thanks,
NeilBrown
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/4a1bdce9/attachment.html>
