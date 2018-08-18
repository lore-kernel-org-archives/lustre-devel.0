From: Andreas Dilger <adilger@whamcloud.com>
Date: Sat, 18 Aug 2018 05:12:57 +0000
Subject: [lustre-devel] [PATCH 04/38] lustre: llite: remove ll_sb
In-Reply-To: <alpine.LFD.2.21.1808180123580.2829@casper.infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-5-git-send-email-jsimmons@infradead.org>
 <87a7plsjmz.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1808180123580.2829@casper.infradead.org>
Message-ID: <A694D2FB-02A4-4643-B37F-DAE9127FBBF2@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 17, 2018, at 18:35, James Simmons <jsimmons@infradead.org> wrote:
> 
>> 
>> On Thu, Aug 16 2018, James Simmons wrote:
>> 
>>> The only user of ll_sb in struct ll_sb_info is used to query the
>>> name locate in the file_system_type. We can get that information
>>> from using the super block located in struct path instead. This
>>> enables us to use struct ll_sb_info directly for every sysfs or
>>> debugfs entry.
>>> 
>> ....
>> 
>>> @@ -215,7 +216,7 @@ static ssize_t fstype_show(struct kobject *kobj, struct attribute *attr,
>>> 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
>>> 					      ll_kobj);
>>> 
>>> -	return sprintf(buf, "%s\n", sbi->ll_sb->s_type->name);
>>> +	return sprintf(buf, "%s\n", sbi->ll_mnt.mnt->mnt_sb->s_type->name);
>> 
>> ll_mnt ??? What is that, why is it a better thing to keep than ll_sb.
>> (looks at code).
> 
> At first I was thinking that the name was of the format $FSNAME-$UUID but
> now that I look at what its requesting that is not the case. The 'name'
> returned looks to be always "lustre". Yet for some reason its does this
> long winded way to get this info. Andreas or Oleg is their a reason for
> this?

In the ancient past the filesystem type was named either "llite" or
"lustre", so this was used to print the filesystem type consistently.
It has been "lustre" for quite a while now.  I recently discussed with
you about changing the server-side mounts to use "lustre-mdt" and
"lustre-ost", but I don't think this applies to this code here.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180818/8981e77d/attachment-0001.sig>
