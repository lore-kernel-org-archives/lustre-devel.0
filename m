From: Alexey Lyashkov <umka@cloudlinux.com>
Date: Mon, 22 Jul 2019 12:51:02 +0300
Subject: [lustre-devel] [PATCH 19/22] ext4: don't check before replay
In-Reply-To: <82691452-7473-4CAB-BE70-0C89238D5720@whamcloud.com>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-20-git-send-email-jsimmons@infradead.org>
 <87pnm2ocvr.fsf@notabene.neil.brown.name>
 <506765DD-0068-469E-ADA4-2C71B8B60114@cloudlinux.com>
 <87wogak1n7.fsf@notabene.neil.brown.name>
 <82691452-7473-4CAB-BE70-0C89238D5720@whamcloud.com>
Message-ID: <AF63C3EE-CA7F-474E-9C93-AEDDD67009AF@cloudlinux.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> 22 ???? 2019 ?., ? 9:56, Oleg Drokin <green@whamcloud.com> ???????(?):
> 
> 
> 
>> On Jul 22, 2019, at 2:46 AM, NeilBrown <neilb@suse.com> wrote:
>> 
>> On Mon, Jul 22 2019, Alexey Lyashkov wrote:
>> 
>>> Why?
>>> Purpose of this patch is simple and don?t addressed a failover in general.
>>> Crash can occurred in commit time - when journal _partially_ flushed to the FS. Checking any FS metadata in this time is wrong, because we have no guarantee to be consistence.
>>> But checking an after journal replay is fine, it check have verification no corruption hit and FS is fine. 
>> 
>> If the corruption can occur in non-ldiskfs usage, and would be fixed by
>> a journal replay, then yes - the patch looks like a good idea.
Yes, bug should fixed by journal replay. BUT this check was run _before_ journal replay and patch move groups check _after_ journal replay done.


>> 
>> Possibly I misunderstood the source of the corruption... maybe if that
>> could be made clearer in the commit message, that would help.
> 
> I think the argument is: wtf do we even look at metadata (or anything, really)
> before journal replay.
> The patch is actually good because it does move the read after the journal replay
> though?

Oleg,

you are right. 
> 
> 
>> 
>>> 
>>> 
>>>> 22 ???? 2019 ?., ? 8:29, NeilBrown <neilb@suse.com> ???????(?):
>>>> 
>>>> On Sun, Jul 21 2019, James Simmons wrote:
>>>> 
>>>>> When ldiskfs run in failover mode whith read-only disk.
>>>>> Part of allocation updates are lost and ldiskfs may fail
>>>>> while mounting this is due to inconsistent state of
>>>>> group-descriptor. Group-descriptor check is added after
>>>>> journal replay.
>>>> 
>>>> I think this needs to be enabled by a mount option or super-block flag.
>>>> 
>>>> NeilBrown
>>>> 
>>>> 
>>>>> 
>>>>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>>>>> ---
>>>>> fs/ext4/super.c | 11 ++++++-----
>>>>> 1 file changed, 6 insertions(+), 5 deletions(-)
>>>>> 
>>>>> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
>>>>> index a3179b2..b818acb 100644
>>>>> --- a/fs/ext4/super.c
>>>>> +++ b/fs/ext4/super.c
>>>>> @@ -4255,11 +4255,6 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>>>>> 		}
>>>>> 	}
>>>>> 	sbi->s_gdb_count = db_count;
>>>>> -	if (!ext4_check_descriptors(sb, logical_sb_block, &first_not_zeroed)) {
>>>>> -		ext4_msg(sb, KERN_ERR, "group descriptors corrupted!");
>>>>> -		ret = -EFSCORRUPTED;
>>>>> -		goto failed_mount2;
>>>>> -	}
>>>>> 
>>>>> 	timer_setup(&sbi->s_err_report, print_daily_error_info, 0);
>>>>> 
>>>>> @@ -4401,6 +4396,12 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>>>>> 	sbi->s_journal->j_commit_callback = ext4_journal_commit_callback;
>>>>> 
>>>>> no_journal:
>>>>> +	if (!ext4_check_descriptors(sb, logical_sb_block, &first_not_zeroed)) {
>>>>> +		ext4_msg(sb, KERN_ERR, "group descriptors corrupted!");
>>>>> +		ret = -EFSCORRUPTED;
>>>>> +		goto failed_mount_wq;
>>>>> +	}
>>>>> +
>>>>> 	if (!test_opt(sb, NO_MBCACHE)) {
>>>>> 		sbi->s_ea_block_cache = ext4_xattr_create_cache();
>>>>> 		if (!sbi->s_ea_block_cache) {
>>>>> -- 
>>>>> 1.8.3.1
>>>> _______________________________________________
>>>> lustre-devel mailing list
>>>> lustre-devel at lists.lustre.org
>>>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
