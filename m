From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 16:46:04 +1000
Subject: [lustre-devel] [PATCH 19/22] ext4: don't check before replay
In-Reply-To: <506765DD-0068-469E-ADA4-2C71B8B60114@cloudlinux.com>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-20-git-send-email-jsimmons@infradead.org>
 <87pnm2ocvr.fsf@notabene.neil.brown.name>
 <506765DD-0068-469E-ADA4-2C71B8B60114@cloudlinux.com>
Message-ID: <87wogak1n7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 22 2019, Alexey Lyashkov wrote:

> Why?
> Purpose of this patch is simple and don?t addressed a failover in general.
> Crash can occurred in commit time - when journal _partially_ flushed to the FS. Checking any FS metadata in this time is wrong, because we have no guarantee to be consistence.
> But checking an after journal replay is fine, it check have verification no corruption hit and FS is fine. 

If the corruption can occur in non-ldiskfs usage, and would be fixed by
a journal replay, then yes - the patch looks like a good idea.

Possibly I misunderstood the source of the corruption... maybe if that
could be made clearer in the commit message, that would help.

Thanks,
NeilBrown


>
>
>> 22 ???? 2019 ?., ? 8:29, NeilBrown <neilb@suse.com> ???????(?):
>> 
>> On Sun, Jul 21 2019, James Simmons wrote:
>> 
>>> When ldiskfs run in failover mode whith read-only disk.
>>> Part of allocation updates are lost and ldiskfs may fail
>>> while mounting this is due to inconsistent state of
>>> group-descriptor. Group-descriptor check is added after
>>> journal replay.
>> 
>> I think this needs to be enabled by a mount option or super-block flag.
>> 
>> NeilBrown
>> 
>> 
>>> 
>>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>>> ---
>>> fs/ext4/super.c | 11 ++++++-----
>>> 1 file changed, 6 insertions(+), 5 deletions(-)
>>> 
>>> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
>>> index a3179b2..b818acb 100644
>>> --- a/fs/ext4/super.c
>>> +++ b/fs/ext4/super.c
>>> @@ -4255,11 +4255,6 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>>> 		}
>>> 	}
>>> 	sbi->s_gdb_count = db_count;
>>> -	if (!ext4_check_descriptors(sb, logical_sb_block, &first_not_zeroed)) {
>>> -		ext4_msg(sb, KERN_ERR, "group descriptors corrupted!");
>>> -		ret = -EFSCORRUPTED;
>>> -		goto failed_mount2;
>>> -	}
>>> 
>>> 	timer_setup(&sbi->s_err_report, print_daily_error_info, 0);
>>> 
>>> @@ -4401,6 +4396,12 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>>> 	sbi->s_journal->j_commit_callback = ext4_journal_commit_callback;
>>> 
>>> no_journal:
>>> +	if (!ext4_check_descriptors(sb, logical_sb_block, &first_not_zeroed)) {
>>> +		ext4_msg(sb, KERN_ERR, "group descriptors corrupted!");
>>> +		ret = -EFSCORRUPTED;
>>> +		goto failed_mount_wq;
>>> +	}
>>> +
>>> 	if (!test_opt(sb, NO_MBCACHE)) {
>>> 		sbi->s_ea_block_cache = ext4_xattr_create_cache();
>>> 		if (!sbi->s_ea_block_cache) {
>>> -- 
>>> 1.8.3.1
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/a8b8b2a4/attachment.sig>
