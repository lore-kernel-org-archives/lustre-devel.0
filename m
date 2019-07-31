From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 31 Jul 2019 22:03:44 +0000
Subject: [lustre-devel] [PATCH 01/22] ext4: add i_fs_version
In-Reply-To: <87wogapuz2.fsf@notabene.neil.brown.name>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-2-git-send-email-jsimmons@infradead.org>
 <87wogapuz2.fsf@notabene.neil.brown.name>
Message-ID: <FE17B718-29E5-44D6-AFFA-F89B38AA3CEE@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 21, 2019, at 22:13, NeilBrown <neilb@suse.com> wrote:
> 
> On Sun, Jul 21 2019, James Simmons wrote:
> 
>> From: James Simmons <uja.ornl@yahoo.com>
>> 
>> Add inode version field that osd-ldiskfs uses.
> 
> We need more words here.  What is i_fs_version used for?
> 
> (I'll probably find out as I keep reading, but I need to know
> the intention first, or I cannot properly review the patches
> that make use of it.

We use the 64-bit i_version field to store the Lustre transno in
which the inode was last modified.  This maintains the NFS
required semantics that the version change when the inode is
modified, but the number has a specific meaning so we don't
want the ext4 code or VFS to just increment it.

When a client modifies an inode, the old version is returned in
the RPC reply to the client.  The old version number can be used
during Lustre recovery (RPC replay using "Version Based Recovery",
VBR) after an MDS crash to determine if it is safe to apply this
change to the inode, in the case that some clients have been
evicted and we don't have a full stream of RPCs to replay.

If we could get some way to prevent the kernel from updating the
inode->i_version (which is now also a 64-bit value) then we could
remove one more patch from our code.  In the meantime, the current
kernel is not conducive to hijacking inode->i_version so we need
to store our own value in the ext4_inode_info and write that to
disk instead of the kernel version.

Cheers, Andreas

> 
>> 
>> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
>> ---
>> fs/ext4/ext4.h   | 2 ++
>> fs/ext4/ialloc.c | 1 +
>> fs/ext4/inode.c  | 4 ++--
>> 3 files changed, 5 insertions(+), 2 deletions(-)
>> 
>> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
>> index 1cb6785..8abbcab 100644
>> --- a/fs/ext4/ext4.h
>> +++ b/fs/ext4/ext4.h
>> @@ -1063,6 +1063,8 @@ struct ext4_inode_info {
>> 	struct dquot *i_dquot[MAXQUOTAS];
>> #endif
>> 
>> +	u64 i_fs_version;
>> +
>> 	/* Precomputed uuid+inum+igen checksum for seeding inode checksums */
>> 	__u32 i_csum_seed;
>> 
>> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
>> index 764ff4c..09ae4a4 100644
>> --- a/fs/ext4/ialloc.c
>> +++ b/fs/ext4/ialloc.c
>> @@ -1100,6 +1100,7 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
>> 	ei->i_dtime = 0;
>> 	ei->i_block_group = group;
>> 	ei->i_last_alloc_group = ~0;
>> +	ei->i_fs_version = 0;
>> 
>> 	ext4_set_inode_flags(inode);
>> 	if (IS_DIRSYNC(inode))
>> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
>> index c7f77c6..6e66175 100644
>> --- a/fs/ext4/inode.c
>> +++ b/fs/ext4/inode.c
>> @@ -4806,14 +4806,14 @@ static inline void ext4_inode_set_iversion_queried(struct inode *inode, u64 val)
>> 	if (unlikely(EXT4_I(inode)->i_flags & EXT4_EA_INODE_FL))
>> 		inode_set_iversion_raw(inode, val);
>> 	else
>> -		inode_set_iversion_queried(inode, val);
>> +		EXT4_I(inode)->i_fs_version = val;
>> }
>> static inline u64 ext4_inode_peek_iversion(const struct inode *inode)
>> {
>> 	if (unlikely(EXT4_I(inode)->i_flags & EXT4_EA_INODE_FL))
>> 		return inode_peek_iversion_raw(inode);
>> 	else
>> -		return inode_peek_iversion(inode);
>> +		return EXT4_I(inode)->i_fs_version;
>> }
>> 
>> struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
>> -- 
>> 1.8.3.1

Cheers, Andreas
--
Andreas Dilger
Principal Lustre Architect
Whamcloud
