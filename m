From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 23 Jul 2019 01:56:56 +0000
Subject: [lustre-devel] [PATCH 20/22] ext4: use GFP_NOFS in
 ext4_inode_attach_jinode
In-Reply-To: <87muh6octs.fsf@notabene.neil.brown.name>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-21-git-send-email-jsimmons@infradead.org>,
 <87muh6octs.fsf@notabene.neil.brown.name>
Message-ID: <B3F2C578-1466-4E17-A8A7-303B5441D528@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

That interface has only existed for a handful of kernel releases, so was/is
not a viable option for earlier kernels. 

Cheers, Andreas

> On Jul 21, 2019, at 23:31, NeilBrown <neilb@suse.com> wrote:
> 
> On Sun, Jul 21 2019, James Simmons wrote:
> 
> If you need to call this from a context where GFP_KERNEL is not safe,
> use memalloc_nofs_{save,restore}().
> 
> NeilBrown
> 
> 
> 
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>> fs/ext4/inode.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
>> index bf00dfc..ca72097 100644
>> --- a/fs/ext4/inode.c
>> +++ b/fs/ext4/inode.c
>> @@ -4422,7 +4422,7 @@ int ext4_inode_attach_jinode(struct inode *inode)
>>    if (ei->jinode || !EXT4_SB(inode->i_sb)->s_journal)
>>        return 0;
>> 
>> -    jinode = jbd2_alloc_inode(GFP_KERNEL);
>> +    jinode = jbd2_alloc_inode(GFP_NOFS);
>>    spin_lock(&inode->i_lock);
>>    if (!ei->jinode) {
>>        if (!jinode) {
>> -- 
>> 1.8.3.1
