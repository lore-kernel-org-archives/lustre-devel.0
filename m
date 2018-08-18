From: James Simmons <jsimmons@infradead.org>
Date: Sat, 18 Aug 2018 01:35:32 +0100 (BST)
Subject: [lustre-devel] [PATCH 04/38] lustre: llite: remove ll_sb
In-Reply-To: <87a7plsjmz.fsf@notabene.neil.brown.name>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-5-git-send-email-jsimmons@infradead.org>
 <87a7plsjmz.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1808180123580.2829@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Thu, Aug 16 2018, James Simmons wrote:
> 
> > The only user of ll_sb in struct ll_sb_info is used to query the
> > name locate in the file_system_type. We can get that information
> > from using the super block located in struct path instead. This
> > enables us to use struct ll_sb_info directly for every sysfs or
> > debugfs entry.
> >
> ....
> 
> > @@ -215,7 +216,7 @@ static ssize_t fstype_show(struct kobject *kobj, struct attribute *attr,
> >  	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> >  					      ll_kobj);
> >  
> > -	return sprintf(buf, "%s\n", sbi->ll_sb->s_type->name);
> > +	return sprintf(buf, "%s\n", sbi->ll_mnt.mnt->mnt_sb->s_type->name);
> 
> ll_mnt ??? What is that, why is it a better thing to keep than ll_sb.
> (looks at code).

At first I was thinking that the name was of the format $FSNAME-$UUID but
now that I look at what its requesting that is not the case. The 'name'
returned looks to be always "lustre". Yet for some reason its does this
long winded way to get this info. Andreas or Oleg is their a reason for
this? 
 
> The code takes a copy of a vfsmnt and a dentry (a path) without
> increasing the refcount on either??? Why did someone think that was a
> sane thing to do?
> Have you plans to get rid of ll_mnt too (I hope)??

That would be Rahul. The patch is :

http://review.whamcloud.com/20061

and the details are at https://jira.whamcloud.com/browse/LU-1882.

Some time ago Al Viro and Oleg discussed this. That is under ticket
https://jira.whamcloud.com/browse/LU-10824

So the answer is yes their are plans but no one has looked at fixing this.
