From: Oleg Drokin <green@whamcloud.com>
Date: Tue, 23 Jul 2019 02:01:08 +0000
Subject: [lustre-devel] [PATCH 19/22] ext4: don't check before replay
In-Reply-To: <3F8B391A-6FFD-4C44-BD87-D12AD8456651@whamcloud.com>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-20-git-send-email-jsimmons@infradead.org>
 <87pnm2ocvr.fsf@notabene.neil.brown.name>
 <3F8B391A-6FFD-4C44-BD87-D12AD8456651@whamcloud.com>
Message-ID: <CFEE2736-8539-4E6F-80ED-F1D6625EEEEC@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

what I think needs to happen is a better description.

Something like:

In a crash group descriptors might not be written completely
in place that would lead to FS error message on subsequent mount.

Move the check to after journal replay to ensure we are
dealing with up to date (and hopefully correct) information
before declaring the FS as bad.

> On Jul 22, 2019, at 9:57 PM, Andreas Dilger <adilger@whamcloud.com> wrote:
> 
> Actually, I think this patch would be OK to push upstream. 
> 
> Cheers, Andreas
> 
>> On Jul 21, 2019, at 23:29, NeilBrown <neilb@suse.com> wrote:
>> 
>>> On Sun, Jul 21 2019, James Simmons wrote:
>>> 
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
>>>       }
>>>   }
>>>   sbi->s_gdb_count = db_count;
>>> -    if (!ext4_check_descriptors(sb, logical_sb_block, &first_not_zeroed)) {
>>> -        ext4_msg(sb, KERN_ERR, "group descriptors corrupted!");
>>> -        ret = -EFSCORRUPTED;
>>> -        goto failed_mount2;
>>> -    }
>>> 
>>>   timer_setup(&sbi->s_err_report, print_daily_error_info, 0);
>>> 
>>> @@ -4401,6 +4396,12 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>>>   sbi->s_journal->j_commit_callback = ext4_journal_commit_callback;
>>> 
>>> no_journal:
>>> +    if (!ext4_check_descriptors(sb, logical_sb_block, &first_not_zeroed)) {
>>> +        ext4_msg(sb, KERN_ERR, "group descriptors corrupted!");
>>> +        ret = -EFSCORRUPTED;
>>> +        goto failed_mount_wq;
>>> +    }
>>> +
>>>   if (!test_opt(sb, NO_MBCACHE)) {
>>>       sbi->s_ea_block_cache = ext4_xattr_create_cache();
>>>       if (!sbi->s_ea_block_cache) {
>>> -- 
>>> 1.8.3.1
