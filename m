From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 11:52:39 +1100
Subject: [lustre-devel] [PATCH 15/21] lustre: obdclass: char
 obd_ioctl_getdata type.
In-Reply-To: <3F216582-D826-4002-8F8D-A27488E24B02@whamcloud.com>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781327.10620.2294752316778817915.stgit@noble.brown>
 <3F216582-D826-4002-8F8D-A27488E24B02@whamcloud.com>
Message-ID: <87k1i7gn8o.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 08 2019, Andreas Dilger wrote:

> On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
>> 
>> Instead of having obd_ioctl_getdata() return the allocated
>> data as a "char *", return it as it really is,
>> struct obd_ioctl_data *
>> 
>> This avoids the need for extra variables and casts.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> Most of the patch looks like a no-op, except at one part below:
>
>> @@ -1651,18 +1647,16 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>> 		return rc;
>> 	}
>> 	case LL_IOC_MIGRATE: {
>> -		char *buf = NULL;
>> 		const char *filename;
>> 		int namelen = 0;
>> 		int len;
>> 		int rc;
>> 		int mdtidx;
>> 
>> -		rc = obd_ioctl_getdata(&buf, &len, (void __user *)arg);
>> +		rc = obd_ioctl_getdata(&data, &len, (void __user *)arg);
>> 		if (rc < 0)
>> 			return rc;
>> 
>> -		data = (struct obd_ioctl_data *)buf;
>> 		if (!data->ioc_inlbuf1 || !data->ioc_inlbuf2 ||
>> 		    !data->ioc_inllen1 || !data->ioc_inllen2) {
>> 			rc = -EINVAL;
>> @@ -1684,7 +1678,6 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
>> 
>> 		rc = ll_migrate(inode, file, mdtidx, filename, namelen - 1);
>> migrate_free:
>> -		kvfree(buf);
>
> This removes the call to kvfree(buf) but it isn't clear why, since the rest of
> the patch is mostly variable renaming?

Thanks for catching that!  It should be:

 migrate_free:
-               kvfree(buf);
+               kvfree(data);
 
of course.  Fixed now.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/9eda8de4/attachment.sig>
