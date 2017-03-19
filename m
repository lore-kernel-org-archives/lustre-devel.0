From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Mar 2017 00:50:04 -0400
Subject: [lustre-devel] [PATCH/RFC] staging/lustre: Rework
	class_process_proc_param
In-Reply-To: <20170319044147.GA931@kroah.com>
References: <20170318062408.3207381-1-green@linuxhacker.ru>
	<20170319044147.GA931@kroah.com>
Message-ID: <E9008DCC-484B-4D1F-94E5-3EF3ABD47488@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Mar 19, 2017, at 12:41 AM, Greg Kroah-Hartman wrote:

> On Sat, Mar 18, 2017 at 02:24:08AM -0400, Oleg Drokin wrote:
>> Ever since sysfs migration, class_process_proc_param stopped working
>> correctly as all the useful params were no longer present as lvars.
>> Replace all the nasty fake proc writes with hopefully less nasty
>> kobject attribute search and then update the attributes as needed.
>> 
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
>> ---
>> Al has quite rightfully complained in the past that class_process_proc_param
>> is a terrible piece of code and needs to go.
>> This patch is an attempt at improving it somewhat and in process drop
>> all the user/kernel address space games we needed to play to make it work
>> in the past (and which I suspect attracted Al's attention in the first place).
>> 
>> Now I wonder if iterating kobject attributes like that would be ok with
>> you Greg, or do you think there is a better way?
>> class_find_write_attr could be turned into something generic since it's
>> certainly convenient to reuse same table of name-write_method pairs,
>> but I did some cursory research and nobody else seems to need anything
>> of the sort in-tree.
>> 
>> I know ll_process_config is still awful and I will likely just
>> replace the current hack with kset_find_obj, but I just wanted to make
>> sure this new approach would be ok before spending too much time on it.
>> 
>> Thanks!
>> 
>> drivers/staging/lustre/lustre/include/obd_class.h  |  4 +-
>> drivers/staging/lustre/lustre/llite/llite_lib.c    | 10 +--
>> drivers/staging/lustre/lustre/lov/lov_obd.c        |  3 +-
>> drivers/staging/lustre/lustre/mdc/mdc_request.c    |  3 +-
>> .../staging/lustre/lustre/obdclass/obd_config.c    | 78 ++++++++++------------
>> drivers/staging/lustre/lustre/osc/osc_request.c    |  3 +-
>> 6 files changed, 44 insertions(+), 57 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
>> index 083a6ff..badafb8 100644
>> --- a/drivers/staging/lustre/lustre/include/obd_class.h
>> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
>> @@ -114,8 +114,8 @@ typedef int (*llog_cb_t)(const struct lu_env *, struct llog_handle *,
>> 			 struct llog_rec_hdr *, void *);
>> /* obd_config.c */
>> int class_process_config(struct lustre_cfg *lcfg);
>> -int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
>> -			     struct lustre_cfg *lcfg, void *data);
>> +int class_process_attr_param(char *prefix, struct kobject *kobj,
>> +			     struct lustre_cfg *lcfg);
> 
> As you are exporting these functions, they will need to end up with a
> lustre_* prefix eventually :)

ok.

> 
>> struct obd_device *class_incref(struct obd_device *obd,
>> 				const char *scope, const void *source);
>> void class_decref(struct obd_device *obd,
>> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
>> index 7b80040..192b877 100644
>> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
>> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
>> @@ -2259,7 +2259,7 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
>> int ll_process_config(struct lustre_cfg *lcfg)
>> {
>> 	char *ptr;
>> -	void *sb;
>> +	struct super_block *sb;
>> 	struct lprocfs_static_vars lvars;
>> 	unsigned long x;
>> 	int rc = 0;
>> @@ -2273,15 +2273,15 @@ int ll_process_config(struct lustre_cfg *lcfg)
>> 	rc = kstrtoul(ptr, 16, &x);
>> 	if (rc != 0)
>> 		return -EINVAL;
>> -	sb = (void *)x;
>> +	sb = (struct super_block *)x;
>> 	/* This better be a real Lustre superblock! */
>> -	LASSERT(s2lsi((struct super_block *)sb)->lsi_lmd->lmd_magic == LMD_MAGIC);
>> +	LASSERT(s2lsi(sb)->lsi_lmd->lmd_magic == LMD_MAGIC);
>> 
>> 	/* Note we have not called client_common_fill_super yet, so
>> 	 * proc fns must be able to handle that!
>> 	 */
>> -	rc = class_process_proc_param(PARAM_LLITE, lvars.obd_vars,
>> -				      lcfg, sb);
>> +	rc = class_process_attr_param(PARAM_LLITE, &ll_s2sbi(sb)->ll_kobj,
>> +				      lcfg);
>> 	if (rc > 0)
>> 		rc = 0;
>> 	return rc;
>> diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
>> index b3161fb..c33a327 100644
>> --- a/drivers/staging/lustre/lustre/lov/lov_obd.c
>> +++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
>> @@ -926,8 +926,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
>> 
>> 		lprocfs_lov_init_vars(&lvars);
>> 
>> -		rc = class_process_proc_param(PARAM_LOV, lvars.obd_vars,
>> -					      lcfg, obd);
>> +		rc = class_process_attr_param(PARAM_LOV, &obd->obd_kobj, lcfg);
>> 		if (rc > 0)
>> 			rc = 0;
>> 		goto out;
>> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> index 6bc2fb8..00387b8 100644
>> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> @@ -2670,8 +2670,7 @@ static int mdc_process_config(struct obd_device *obd, u32 len, void *buf)
>> 	lprocfs_mdc_init_vars(&lvars);
>> 	switch (lcfg->lcfg_command) {
>> 	default:
>> -		rc = class_process_proc_param(PARAM_MDC, lvars.obd_vars,
>> -					      lcfg, obd);
>> +		rc = class_process_attr_param(PARAM_MDC, &obd->obd_kobj, lcfg);
>> 		if (rc > 0)
>> 			rc = 0;
>> 		break;
>> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
>> index 8fce88f..08fd126 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
>> @@ -995,26 +995,42 @@ int class_process_config(struct lustre_cfg *lcfg)
>> }
>> EXPORT_SYMBOL(class_process_config);
>> 
>> -int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
>> -			     struct lustre_cfg *lcfg, void *data)
>> +static int class_find_write_attr(struct kobject *kobj, char *name, int namelen,
>> +				 char *val, int vallen)
>> +{
>> +	struct attribute *attr;
>> +	struct kobj_type *kt = get_ktype(kobj);
>> +	int i;
>> +
>> +	/* Empty object? */
>> +	if (!kt || !kt->default_attrs)
>> +		return -ENOENT;
>> +
>> +	for (i = 0; (attr = kt->default_attrs[i]) != NULL; i++) {
>> +		if (!strncmp(attr->name, name, namelen) &&
>> +		    namelen == strlen(attr->name)) {
> 
> Why do you care about namelen?  Why can't you just do a "normal"
> strcmp()?  Is this "untrusted" user data?

in this patch, name is not NULL terminated (see the caller, need to doublecheck
it's safe to replace = with \0, which it might not be if the same buffer is reused by
others.)

>> +			if (kt->sysfs_ops && kt->sysfs_ops->store)
>> +				return kt->sysfs_ops->store(kobj, attr, val,
>> +							    vallen);
>> +			return -EINVAL;
>> +		}
>> +	}
>> +
>> +	return -ENOENT;
>> +}
>> +
>> +int class_process_attr_param(char *prefix, struct kobject *kobj,
>> +			     struct lustre_cfg *lcfg)
>> {
>> -	struct lprocfs_vars *var;
>> -	struct file fakefile;
>> -	struct seq_file fake_seqfile;
>> 	char *key, *sval;
>> 	int i, keylen, vallen;
>> -	int matched = 0, j = 0;
>> 	int rc = 0;
>> -	int skip = 0;
>> 
>> 	if (lcfg->lcfg_command != LCFG_PARAM) {
>> 		CERROR("Unknown command: %d\n", lcfg->lcfg_command);
>> 		return -EINVAL;
>> 	}
>> 
>> -	/* fake a seq file so that var->fops->write can work... */
>> -	fakefile.private_data = &fake_seqfile;
>> -	fake_seqfile.private = data;
>> 	/* e.g. tunefs.lustre --param mdt.group_upcall=foo /r/tmp/lustre-mdt
>> 	 * or   lctl conf_param lustre-MDT0000.mdt.group_upcall=bar
>> 	 * or   lctl conf_param lustre-OST0000.osc.max_dirty_mb=36
>> @@ -1038,39 +1054,16 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
>> 		keylen = sval - key;
>> 		sval++;
>> 		vallen = strlen(sval);
>> -		matched = 0;
>> -		j = 0;
>> -		/* Search proc entries */
>> -		while (lvars[j].name) {
>> -			var = &lvars[j];
>> -			if (!class_match_param(key, var->name, NULL) &&
>> -			    keylen == strlen(var->name)) {
>> -				matched++;
>> -				rc = -EROFS;
>> -				if (var->fops && var->fops->write) {
>> -					mm_segment_t oldfs;
>> -
>> -					oldfs = get_fs();
>> -					set_fs(KERNEL_DS);
>> -					rc = var->fops->write(&fakefile,
>> -						(const char __user *)sval,
>> -								vallen, NULL);
>> -					set_fs(oldfs);
>> -				}
>> -				break;
>> -			}
>> -			j++;
>> -		}
>> -		if (!matched) {
>> +		rc = class_find_write_attr(kobj, key, keylen, sval, vallen);
>> +
>> +		if (rc == -ENOENT) {
>> 			CERROR("%.*s: %s unknown param %s\n",
>> 			       (int)strlen(prefix) - 1, prefix,
>> 			       (char *)lustre_cfg_string(lcfg, 0), key);
>> 			/* rc = -EINVAL;	continue parsing other params */
>> -			skip++;
>> 		} else if (rc < 0) {
>> -			CERROR("%s: error writing proc entry '%s': rc = %d\n",
>> -			       prefix, var->name, rc);
>> -			rc = 0;
>> +			CERROR("%s: error writing proc entry '%.*s': rc = %d\n",
>> +			       prefix, keylen, key, rc);
> 
> It's not a "proc" entry anymore :)

Indeed.

> Other than that minor issue, and the question about namelen, this looks
> semi-sane to me.  Want to resend this as a non-rfc patch?

I'd do a bit deeper change then (or a set, I guess) to fix up some other wrinkles,
so probably not right away.

Thanks again!
