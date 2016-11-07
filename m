From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 7 Nov 2016 21:33:26 +0000
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: obdclass: Add
 handling of error returned by lustre_cfg_new
In-Reply-To: <97207CF4-21C1-4351-92BF-6F28E7281CF6@intel.com>
References: <20161106171123.24929-1-christophe.jaillet@wanadoo.fr>
	<97207CF4-21C1-4351-92BF-6F28E7281CF6@intel.com>
Message-ID: <CAA32D44-F2D5-412D-8B47-6DB7E305E669@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Cc: James Simmons <jsimmons@infradead.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Liu, Emoly" <emoly.liu@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>

On Nov 6, 2016, at 10:26, Drokin, Oleg <oleg.drokin@intel.com> wrote:
> 
> Hello!
> 
> On Nov 6, 2016, at 12:11 PM, Christophe JAILLET wrote:
> 
>> 'lustre_cfg_new()' can return ERR_PTR(-ENOMEM).
>> Handle these errors and propagate the error code to the callers.
>> 
>> Error handling has been rearranged in 'lustre_process_log()' with the
>> addition of a label in order to free some resources.
> 
> I wonder if we should just make it return NULL on allocation failure,
> and then at least the other error handling that is there (i.e. in your other patch)
> would become correct.
> This would make handling in mgc_apply_recover_logs incorrect, but it's already
> geared towards this sort of handling anyway, as it discards the passed error
> and sets ENOMEM unconditionally (just need to revert 3092c34a in a way).

I'd agree with Oleg that returning NULL is the preferable solution here. 

There are also callers of lustre_cfg_new() in class_config_llog_handler(),
do_lcfg(), and lustre_end_log() that do not check error returns at all that
should be fixed at the same time.

Cheers, Andreas

>> 
>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
>> ---
>> drivers/staging/lustre/lustre/obdclass/obd_mount.c | 16 ++++++++++++++--
>> 1 file changed, 14 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
>> index 59fbc29aae94..5473615cd338 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
>> @@ -89,11 +89,14 @@ int lustre_process_log(struct super_block *sb, char *logname,
>> 	lustre_cfg_bufs_set(bufs, 2, cfg, sizeof(*cfg));
>> 	lustre_cfg_bufs_set(bufs, 3, &sb, sizeof(sb));
>> 	lcfg = lustre_cfg_new(LCFG_LOG_START, bufs);
>> +	if (IS_ERR(lcfg)) {
>> +		rc = PTR_ERR(lcfg);
>> +		goto out_free;
>> +	}
>> +
>> 	rc = obd_process_config(mgc, sizeof(*lcfg), lcfg);
>> 	lustre_cfg_free(lcfg);
>> 
>> -	kfree(bufs);
>> -
>> 	if (rc == -EINVAL)
>> 		LCONSOLE_ERROR_MSG(0x15b, "%s: The configuration from log '%s' failed from the MGS (%d).  Make sure this client and the MGS are running compatible versions of Lustre.\n",
>> 				   mgc->obd_name, logname, rc);
>> @@ -104,6 +107,9 @@ int lustre_process_log(struct super_block *sb, char *logname,
>> 				   rc);
>> 
>> 	/* class_obd_list(); */
>> +
>> +out_free:
>> +	kfree(bufs);
>> 	return rc;
>> }
>> EXPORT_SYMBOL(lustre_process_log);
>> @@ -127,6 +133,9 @@ int lustre_end_log(struct super_block *sb, char *logname,
>> 	if (cfg)
>> 		lustre_cfg_bufs_set(&bufs, 2, cfg, sizeof(*cfg));
>> 	lcfg = lustre_cfg_new(LCFG_LOG_END, &bufs);
>> +	if (IS_ERR(lcfg))
>> +		return PTR_ERR(lcfg);
>> +
>> 	rc = obd_process_config(mgc, sizeof(*lcfg), lcfg);
>> 	lustre_cfg_free(lcfg);
>> 	return rc;
>> @@ -159,6 +168,9 @@ static int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
>> 		lustre_cfg_bufs_set_string(&bufs, 4, s4);
>> 
>> 	lcfg = lustre_cfg_new(cmd, &bufs);
>> +	if (IS_ERR(lcfg))
>> +		return PTR_ERR(lcfg);
>> +
>> 	lcfg->lcfg_nid = nid;
>> 	rc = class_process_config(lcfg);
>> 	lustre_cfg_free(lcfg);
>> -- 
>> 2.9.3
> 
