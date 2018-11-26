From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 26 Nov 2018 21:46:01 +0000
Subject: [lustre-devel] [PATCH RFC] lustre: llite: add LL_IOC_FUTIMES_3
In-Reply-To: <87mupvr14s.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1811260455120.32255@casper.infradead.org>
 <87mupvr14s.fsf@notabene.neil.brown.name>
Message-ID: <075A6FB1-D778-46F7-B780-FC9229902690@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 26, 2018, at 14:15, NeilBrown <neilb@suse.com> wrote:
> 
> On Mon, Nov 26 2018, James Simmons wrote:
> 
>> Add a new regular file ioctl LL_IOC_FUTIMES_3 similar to futimes() but
>> which allows setting of all three inode timestamps. Use this ioctl
>> during HSM restore to ensure that the volatile file has the same
>> timestamps as the file to be restored. Strengthen sanity-hsm test_24a
>> to check that archive, release, and restore do not change a file's
>> ctime. Add sanity-hsm test_24e to check that tar will succeed when it
>> encounters a HSM released file.
> 
> What is this used for?  What is the minimum functionality that would be
> acceptable?

Correct, this is for restoring files from HSM archive or migrating between
different tiers of storage within the filesystem.  This is transparent to the user, and we don't want the migration/restore to cause the file to be backed up again.

> I'm guessing that it is used to migrate files between different levels
> in the HSM storage hierarchy.  Why is it important that the ctime not
> change?  How is the ctime used in a way that would be confused?
> Would it be sufficient, for example, to be able to set the ctime to the
> same as the mtime?

There are lots of different kinds of backup tools out there, I can't
comment on whether ctime == mtime is sufficient to avoid triggering
another backup cycle.  Keeping the same timestamps over this process
is safest.  It seems that XFS has a similar requirement, and it is
using "FMODE_NOCMTIME", but that only avoids updating the timestamps,
it doesn't allow setting them.

> I'm imagining adding a flag to utimesat which is privileged and causes
> ctime to be set to mtime, instead of to current time.  The justification
> would be that it is for restoring from backups in a way that the
> restored file doesn't look like it needs backup up immediately - not
> even the metadata.
> 
> Thanks,
> NeilBrown
> 
> 
>> 
>> *******************************************************************
>> 
>> Original pushed this to staging but Greg discussed about making this
>> a syscall instead. Andreas brought you this might be of use to other
>> file systems like XFS.
>> 
>> *******************************************************************
>> 
>> Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
>> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6213
>> Reviewed-on: http://review.whamcloud.com/13665
>> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
>> Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
>> Reviewed-by: frank zago <fzago@cray.com>
>> Reviewed-by: Oleg Drokin <green@whamcloud.com>
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>> .../lustre/include/uapi/linux/lustre/lustre_user.h | 10 +++++
>> drivers/staging/lustre/lustre/llite/file.c         | 46 ++++++++++++++++++++++
>> 2 files changed, 56 insertions(+)
>> 
>> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
>> index 9d553ce6..6904d6d 100644
>> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
>> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
>> @@ -215,6 +215,15 @@ struct ost_id {
>> #define DOSTID "%#llx:%llu"
>> #define POSTID(oi) ostid_seq(oi), ostid_id(oi)
>> 
>> +struct ll_futimes_3 {
>> +	__u64 lfu_atime_sec;
>> +	__u64 lfu_atime_nsec;
>> +	__u64 lfu_mtime_sec;
>> +	__u64 lfu_mtime_nsec;
>> +	__u64 lfu_ctime_sec;
>> +	__u64 lfu_ctime_nsec;
>> +};
>> +
>> /*
>>  * The ioctl naming rules:
>>  * LL_*     - works on the currently opened filehandle instead of parent dir
>> @@ -251,6 +260,7 @@ struct ost_id {
>> #define LL_IOC_PATH2FID		 _IOR('f', 173, long)
>> #define LL_IOC_GET_CONNECT_FLAGS	_IOWR('f', 174, __u64 *)
>> #define LL_IOC_GET_MDTIDX	       _IOR('f', 175, int)
>> +#define LL_IOC_FUTIMES_3		_IOWR('f', 176, struct ll_futimes_3)
>> 
>> /*	lustre_ioctl.h			177-210 */
>> #define LL_IOC_HSM_STATE_GET		_IOR('f', 211, struct hsm_user_state)
>> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
>> index 06789ec..aa54aad 100644
>> --- a/drivers/staging/lustre/lustre/llite/file.c
>> +++ b/drivers/staging/lustre/lustre/llite/file.c
>> @@ -2098,6 +2098,42 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
>> 	       ((fmode & FMODE_WRITE) ? LL_LEASE_WRLCK : 0);
>> }
>> 
>> +static int ll_file_futimes_3(struct file *file, const struct ll_futimes_3 *lfu)
>> +{
>> +	struct inode *inode = file_inode(file);
>> +	struct iattr ia = {
>> +		.ia_valid = ATTR_ATIME | ATTR_ATIME_SET |
>> +			    ATTR_MTIME | ATTR_MTIME_SET |
>> +			    ATTR_CTIME,
>> +		.ia_atime = {
>> +			.tv_sec = lfu->lfu_atime_sec,
>> +			.tv_nsec = lfu->lfu_atime_nsec,
>> +		},
>> +		.ia_mtime = {
>> +			.tv_sec = lfu->lfu_mtime_sec,
>> +			.tv_nsec = lfu->lfu_mtime_nsec,
>> +		},
>> +		.ia_ctime = {
>> +			.tv_sec = lfu->lfu_ctime_sec,
>> +			.tv_nsec = lfu->lfu_ctime_nsec,
>> +		},
>> +	};
>> +	int rc;
>> +
>> +	if (!capable(CAP_SYS_ADMIN))
>> +		return -EPERM;
>> +
>> +	if (!S_ISREG(inode->i_mode))
>> +		return -EINVAL;
>> +
>> +	inode_lock(inode);
>> +	rc = ll_setattr_raw(file_dentry(file), &ia, OP_XVALID_CTIME_SET,
>> +			    false);
>> +	inode_unlock(inode);
>> +
>> +	return rc;
>> +}
>> +
>> /*
>>  * Give file access advices
>>  *
>> @@ -2552,6 +2588,16 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
>> 		kfree(hui);
>> 		return rc;
>> 	}
>> +	case LL_IOC_FUTIMES_3: {
>> +		const struct ll_futimes_3 __user *lfu_user;
>> +		struct ll_futimes_3 lfu;
>> +
>> +		lfu_user = (const struct ll_futimes_3 __user *)arg;
>> +		if (copy_from_user(&lfu, lfu_user, sizeof(lfu)))
>> +			return -EFAULT;
>> +
>> +		return ll_file_futimes_3(file, &lfu);
>> +        }
>> 	case LL_IOC_LADVISE: {
>> 		struct llapi_ladvise_hdr *ladvise_hdr;
>> 		int alloc_size = sizeof(*ladvise_hdr);
>> -- 
>> 1.8.3.1
>> 
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
