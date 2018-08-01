From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 11:14:27 +1000
Subject: [lustre-devel] [PATCH 2/3] lustre: llite: handle registering
 file system
In-Reply-To: <8045D39A-57C7-4FA3-867E-AB20722BFC04@whamcloud.com>
References: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
 <1532992594-2576-3-git-send-email-jsimmons@infradead.org>
 <8045D39A-57C7-4FA3-867E-AB20722BFC04@whamcloud.com>
Message-ID: <87h8keriq4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Aug 01 2018, Andreas Dilger wrote:

> On Jul 30, 2018, at 17:16, James Simmons <jsimmons@infradead.org> wrote:
>> 
>> Move the code that registers struct file_system_type for lustre
>> with the VFS layer to the llite layer where it belongs. This
>> removes the ugly function pointer passing between obdclass and
>> llite.
>
> One potential issue here is that "mount -t lustre" may get confused
> because the mount(8) binary (or kernel, I forget where it is these days)
> will modprobe "lustre" when trying to mount the filesystem.  This
> can fail if some odd combinations of modules are loaded, since obdclass
> used to register the "lustre" filesystem type, but the client needs
> "llite" loaded to actually mount, while the server does not.  This
> might end up causing "llite" to always be loaded on the server if this
> patch were included into master.
>
> One option that I've through for a while is to change the servers to
> mount with "-t mdt" and "-t ost", or "-t lustre_mdt" or maybe just
> "-t lustre_server" or something similar.  I don't have a great love
> for any of these options, so I'm open for suggestions.  Doing this sooner
> rather than later will ease the transition at some point in the future.
>
> We would add this as an additional filesystem type for the modules, and
> still allow "-t lustre" for some time for compatibility reasons.  I like
> the "lustre_mdt" and "lustre_ost" filesystem types, but using just "mdt"
> and "ost" might be the best options, since this would result in the
> "mdt.ko" and "ost.ko" modules being auto-loaded at mount time.

I think that having the same filesystem type "lustre" be used both to
mount on a client and to activate a server is a particularly unfortunate
aspect of the lustre design.  I really think it needs to change, and I'm
glad you seem to think so too.

I'm not keen on using "mdt" or "ost" as they are meaningless to people
outside of lustre (and I still have to think twice to decode
... metadata target and object storage target..).
I think "lustre_mdt" and "lustre_ost" are good suggestions.  Creating
module aliases is trivial.

I think it would be really good if upstream lustre could start accepting
these for server-side mounts soon.   When the server code eventually
lands in Linux, I expect it to only support (something like) lustre_mdt
and lustre_ost for server-side mounts.

Thanks,
NeilBrown

>
> Cheers, Andreas
>
>
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>> .../staging/lustre/lustre/include/lustre_disk.h    |  3 -
>> drivers/staging/lustre/lustre/llite/super25.c      | 34 +++++++++++-
>> drivers/staging/lustre/lustre/obdclass/class_obd.c |  6 --
>> drivers/staging/lustre/lustre/obdclass/obd_mount.c | 64 ----------------------
>> 4 files changed, 31 insertions(+), 76 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
>> index 772ecc9..d5fadde 100644
>> --- a/drivers/staging/lustre/lustre/include/lustre_disk.h
>> +++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
>> @@ -145,9 +145,6 @@ struct lustre_sb_info {
>> int lustre_put_lsi(struct super_block *sb);
>> int lmd_parse(char *options, struct lustre_mount_data *lmd);
>> int lustre_start_mgc(struct super_block *sb);
>> -void lustre_register_super_ops(int (*cfs)(struct super_block *sb, void *data,
>> -					  int silent),
>> -                               void (*ksc)(struct super_block *sb));
>> int lustre_common_put_super(struct super_block *sb);
>> 
>> int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
>> diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
>> index de43d58..ac8f6f1 100644
>> --- a/drivers/staging/lustre/lustre/llite/super25.c
>> +++ b/drivers/staging/lustre/lustre/llite/super25.c
>> @@ -81,7 +81,6 @@ struct super_operations lustre_super_operations = {
>> 	.remount_fs    = ll_remount_fs,
>> 	.show_options  = ll_show_options,
>> };
>> -MODULE_ALIAS_FS("lustre");
>> 
>> /** This is the entry point for the mount call into Lustre.
>>  * This is called when a server or client is mounted,
>> @@ -162,6 +161,30 @@ int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
>> 	return rc;
>> }
>> 
>> +/***************** FS registration ******************/
>> +static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
>> +				   const char *devname, void *data)
>> +{
>> +	return mount_nodev(fs_type, flags, data, lustre_fill_super);
>> +}
>> +
>> +static void lustre_kill_super(struct super_block *sb)
>> +{
>> +	ll_kill_super(sb);
>> +	kill_anon_super(sb);
>> +}
>> +
>> +/** Register the "lustre" fs type
>> + */
>> +static struct file_system_type lustre_fs_type = {
>> +	.owner		= THIS_MODULE,
>> +	.name		= "lustre",
>> +	.mount		= lustre_mount,
>> +	.kill_sb	= lustre_kill_super,
>> +	.fs_flags	= FS_RENAME_DOES_D_MOVE,
>> +};
>> +MODULE_ALIAS_FS("lustre");
>> +
>> static int __init lustre_init(void)
>> {
>> 	int rc;
>> @@ -224,11 +247,16 @@ static int __init lustre_init(void)
>> 	if (rc != 0)
>> 		goto out_inode_fini_env;
>> 
>> -	lustre_register_super_ops(lustre_fill_super, ll_kill_super);
>> +	rc = register_filesystem(&lustre_fs_type);
>> +	if (rc)
>> +		goto out_xattr_cache;
>> +
>> 	lustre_register_client_process_config(ll_process_config);
>> 
>> 	return 0;
>> 
>> +out_xattr_cache:
>> +	ll_xattr_fini();
>> out_inode_fini_env:
>> 	cl_env_put(cl_inode_fini_env, &cl_inode_fini_refcheck);
>> out_vvp:
>> @@ -245,8 +273,8 @@ static int __init lustre_init(void)
>> 
>> static void __exit lustre_exit(void)
>> {
>> -	lustre_register_super_ops(NULL, NULL);
>> 	lustre_register_client_process_config(NULL);
>> +	unregister_filesystem(&lustre_fs_type);
>> 
>> 	debugfs_remove(llite_root);
>> 	kset_unregister(llite_kset);
>> diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> index 81a4c66..cdaf729 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> @@ -510,18 +510,12 @@ static int __init obdclass_init(void)
>> 		return err;
>> 
>> 	err = llog_info_init();
>> -	if (err)
>> -		return err;
>> -
>> -	err = lustre_register_fs();
>> 
>> 	return err;
>> }
>> 
>> static void obdclass_exit(void)
>> {
>> -	lustre_unregister_fs();
>> -
>> 	misc_deregister(&obd_psdev);
>> 	llog_info_fini();
>> 	cl_global_fini();
>> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
>> index ac841f4..b84bca4 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
>> @@ -49,11 +49,6 @@
>> #include <lustre_disk.h>
>> #include <uapi/linux/lustre/lustre_param.h>
>> 
>> -static DEFINE_SPINLOCK(client_lock);
>> -static int (*client_fill_super)(struct super_block *sb, void *data,
>> -                                int silent);
>> -static void (*kill_super_cb)(struct super_block *sb);
>> -
>> /**************** config llog ********************/
>> 
>> /** Get a config log from the MGS and process it.
>> @@ -1225,62 +1220,3 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
>> 	return -EINVAL;
>> }
>> EXPORT_SYMBOL(lmd_parse);
>> -
>> -/* We can't call ll_fill_super by name because it lives in a module that
>> - * must be loaded after this one.
>> - */
>> -void lustre_register_super_ops(int (*cfs)(struct super_block *sb, void *data,
>> -					  int silent),
>> -			       void (*ksc)(struct super_block *sb))
>> -{
>> -	spin_lock(&client_lock);
>> -	client_fill_super = cfs;
>> -	kill_super_cb = ksc;
>> -	spin_unlock(&client_lock);
>> -}
>> -EXPORT_SYMBOL(lustre_register_super_ops);
>> -
>> -/***************** FS registration ******************/
>> -static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
>> -				   const char *devname, void *data)
>> -{
>> -	struct dentry *root;
>> -
>> -	spin_lock(&client_lock);
>> -	if (!client_fill_super)
>> -		request_module("lustre");
>> -	root = mount_nodev(fs_type, flags, data, client_fill_super);
>> -	spin_unlock(&client_lock);
>> -	return root;
>> -}
>> -
>> -static void lustre_kill_super(struct super_block *sb)
>> -{
>> -	struct lustre_sb_info *lsi = s2lsi(sb);
>> -
>> -	if (kill_super_cb && lsi)
>> -		(*kill_super_cb)(sb);
>> -
>> -	kill_anon_super(sb);
>> -}
>> -
>> -/** Register the "lustre" fs type
>> - */
>> -static struct file_system_type lustre_fs_type = {
>> -	.owner		= THIS_MODULE,
>> -	.name		= "lustre",
>> -	.mount		= lustre_mount,
>> -	.kill_sb	= lustre_kill_super,
>> -	.fs_flags	= FS_RENAME_DOES_D_MOVE,
>> -};
>> -MODULE_ALIAS_FS("lustre");
>> -
>> -int lustre_register_fs(void)
>> -{
>> -	return register_filesystem(&lustre_fs_type);
>> -}
>> -
>> -int lustre_unregister_fs(void)
>> -{
>> -	return unregister_filesystem(&lustre_fs_type);
>> -}
>> --
>> 1.8.3.1
>> 
>
> Cheers, Andreas
> ---
> Andreas Dilger
> CTO Whamcloud
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/884d0f16/attachment.sig>
