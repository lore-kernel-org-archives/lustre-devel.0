From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 14:27:00 +1000
Subject: [lustre-devel] [PATCH 04/38] lustre: llite: remove ll_sb
In-Reply-To: <1534475441-15543-5-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-5-git-send-email-jsimmons@infradead.org>
Message-ID: <87a7plsjmz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> The only user of ll_sb in struct ll_sb_info is used to query the
> name locate in the file_system_type. We can get that information
> from using the super block located in struct path instead. This
> enables us to use struct ll_sb_info directly for every sysfs or
> debugfs entry.
>
....

> @@ -215,7 +216,7 @@ static ssize_t fstype_show(struct kobject *kobj, struct attribute *attr,
>  	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
>  					      ll_kobj);
>  
> -	return sprintf(buf, "%s\n", sbi->ll_sb->s_type->name);
> +	return sprintf(buf, "%s\n", sbi->ll_mnt.mnt->mnt_sb->s_type->name);

ll_mnt ??? What is that, why is it a better thing to keep than ll_sb.
(looks at code).

The code takes a copy of a vfsmnt and a dentry (a path) without
increasing the refcount on either??? Why did someone think that was a
sane thing to do?
Have you plans to get rid of ll_mnt too (I hope)??

Thanks,
NeilBrown



>  }
>  LUSTRE_RO_ATTR(fstype);
>  
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/1375c9bf/attachment.sig>
