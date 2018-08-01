From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 10:23:21 +1000
Subject: [lustre-devel] [PATCH 25/31] lustre: config: move config types
 into lustre_idl.h
In-Reply-To: <BN3PR1101MB1202DBDAC4159FA431E0D676CB2E0@BN3PR1101MB1202.namprd11.prod.outlook.com>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-26-git-send-email-jsimmons@infradead.org>
 <871sbjrpj3.fsf@notabene.neil.brown.name>
 <BN3PR1101MB1202DBDAC4159FA431E0D676CB2E0@BN3PR1101MB1202.namprd11.prod.outlook.com>
Message-ID: <87va8vq6iu.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 31 2018, Patrick Farrell wrote:

> Neil,
>
> Do you have an objection to the concept, or just because this one's not used?
> Having a MAX makes it easy to write things like < MYENUM_MAX as sanity checking code, and then if the enum is added to, it still works.  Seems useful to me.

I object to the name.  "MAX" is short for "MAXIMUM" which means the
highest value that is actually used.  When comparing something to the
maximum it makes sense to say
   if (foo <= maximum)

but it rarely makes sense to say
   if (foo < maximum)

If you want a count of the number of values, use MYENUM_CNT or
MYENUM_NUM. This can sensibly be one more than the maximum value.
But if you have MYSENUM_MAX, make sure it is the maximum meaningful
value for the enum.
</rant>

Thanks,
NeilBrown


>
> - Patrick
> ________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
> Sent: Tuesday, July 31, 2018 5:47:28 PM
> To: James Simmons; Andreas Dilger; Oleg Drokin
> Cc: Lustre Development List
> Subject: Re: [lustre-devel] [PATCH 25/31] lustre: config: move config types into lustre_idl.h
>
> On Mon, Jul 30 2018, James Simmons wrote:
>
>> From: Niu Yawei <yawei.niu@intel.com>
>>
>> Move config type values CONFIG_T_XXX into lustre_idl.h since they
>> will be put on wire when reading config logs.
>>
>> Add missing wire checks for mgs_nidtbl_entry, mgs_config_body and
>> mgs_config_res.
>>
>> Redefine CONFIG_SUB_XXX for the sub clds attached on config log.
>>
>> Signed-off-by: Niu Yawei <yawei.niu@intel.com>
>> WC-id: https://jira.whamcloud.com/browse/LU-9216
>> Reviewed-on: https://review.whamcloud.com/26022
>> Reviewed-by: Fan Yong <fan.yong@intel.com>
>> Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
>> Reviewed-by: Oleg Drokin <green@whamcloud.com>
>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>> ---
>>  .../lustre/include/uapi/linux/lustre/lustre_idl.h  | 10 ++-
>>  drivers/staging/lustre/lustre/include/obd_class.h  | 12 +--
>>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |  6 +-
>>  drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 85 ++++++++++++++++++++++
>>  4 files changed, 103 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
>> index c9b32ef..bd3b45a 100644
>> --- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
>> +++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
>> @@ -2111,11 +2111,19 @@ struct mgs_nidtbl_entry {
>>        } u;
>>  };
>>
>> +enum {
>> +     CONFIG_T_CONFIG  = 0,
>> +     CONFIG_T_SPTLRPC = 1,
>> +     CONFIG_T_RECOVER = 2,
>> +     CONFIG_T_PARAMS  = 3,
>> +     CONFIG_T_MAX
>
> Arrrgggh.  It's back.  I thought we had killed CONFIG_T_MAX (which isn't
> a MAX).
> It's never used, so it'll have to go.
>
> NeilBrown
>
>
>> +};
>> +
>>  struct mgs_config_body {
>>        char            mcb_name[MTI_NAME_MAXLEN]; /* logname */
>>        __u64           mcb_offset;    /* next index of config log to request */
>>        __u16           mcb_type;      /* type of log: CONFIG_T_[CONFIG|RECOVER] */
>> -     __u8            mcb_reserved;
>> +     __u8            mcb_nm_cur_pass;
>>        __u8            mcb_bits;      /* bits unit size of config log */
>>        __u32           mcb_units;     /* # of units for bulk transfer */
>>  };
>> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
>> index 184da99..647cc22 100644
>> --- a/drivers/staging/lustre/lustre/include/obd_class.h
>> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
>> @@ -156,16 +156,16 @@ struct config_llog_instance {
>>  int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
>>                            char *name, struct config_llog_instance *cfg);
>>
>> -#define CONFIG_T_CONFIG              BIT(0)
>> -#define CONFIG_T_SPTLRPC     BIT(1)
>> -#define CONFIG_T_RECOVER     BIT(2)
>> -#define CONFIG_T_PARAMS              BIT(3)
>> +#define CONFIG_SUB_CONFIG    BIT(0)
>> +#define CONFIG_SUB_SPTLRPC   BIT(1)
>> +#define CONFIG_SUB_RECOVER   BIT(2)
>> +#define CONFIG_SUB_PARAMS    BIT(3)
>>
>>  /* Sub clds should be attached to the config_llog_data when processing
>>   * config log for client or server target.
>>   */
>> -#define CONFIG_SUB_CLIENT    (CONFIG_T_SPTLRPC | CONFIG_T_RECOVER | \
>> -                              CONFIG_T_PARAMS)
>> +#define CONFIG_SUB_CLIENT    (CONFIG_SUB_SPTLRPC | CONFIG_SUB_RECOVER | \
>> +                              CONFIG_SUB_PARAMS)
>>
>>  #define PARAMS_FILENAME      "params"
>>  #define LCTL_UPCALL  "lctl"
>> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> index 06fcc7e..833e6a0 100644
>> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> @@ -315,7 +315,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
>>        memcpy(seclogname, logname, ptr - logname);
>>        strcpy(seclogname + (ptr - logname), "-sptlrpc");
>>
>> -     if (cfg->cfg_sub_clds & CONFIG_T_SPTLRPC) {
>> +     if (cfg->cfg_sub_clds & CONFIG_SUB_SPTLRPC) {
>>                sptlrpc_cld = config_log_find_or_add(obd, seclogname, NULL,
>>                                                     CONFIG_T_SPTLRPC, cfg);
>>                if (IS_ERR(sptlrpc_cld)) {
>> @@ -325,7 +325,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
>>                }
>>        }
>>
>> -     if (cfg->cfg_sub_clds & CONFIG_T_PARAMS) {
>> +     if (cfg->cfg_sub_clds & CONFIG_SUB_PARAMS) {
>>                params_cld = config_log_find_or_add(obd, PARAMS_FILENAME, sb,
>>                                                    CONFIG_T_PARAMS, cfg);
>>                if (IS_ERR(params_cld)) {
>> @@ -345,7 +345,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
>>
>>        LASSERT(lsi->lsi_lmd);
>>        if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR) &&
>> -         cfg->cfg_sub_clds & CONFIG_T_RECOVER) {
>> +         cfg->cfg_sub_clds & CONFIG_SUB_RECOVER) {
>>                ptr = strrchr(seclogname, '-');
>>                if (ptr) {
>>                        *ptr = 0;
>> diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
>> index 2f081ed..09b1298 100644
>> --- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
>> +++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
>> @@ -3629,6 +3629,91 @@ void lustre_assert_wire_constants(void)
>>        LASSERTF((int)sizeof(((struct mgs_target_info *)0)->mti_params) == 4096, "found %lld\n",
>>                 (long long)(int)sizeof(((struct mgs_target_info *)0)->mti_params));
>>
>> +     /* Checks for struct mgs_nidtbl_entry */
>> +     LASSERTF((int)sizeof(struct mgs_nidtbl_entry) == 24, "found %lld\n",
>> +              (long long)(int)sizeof(struct mgs_nidtbl_entry));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_version) == 0, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_version));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_version) == 8, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_version));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_instance) == 8, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_instance));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_instance) == 4, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_instance));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_index) == 12, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_index));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_index) == 4, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_index));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_length) == 16, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_length));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_length) == 4, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_length));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_type) == 20, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_type));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_type) == 1, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_type));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_nid_type) == 21, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_nid_type));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_nid_type) == 1, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_nid_type));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_nid_size) == 22, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_nid_size));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_nid_size) == 1, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_nid_size));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, mne_nid_count) == 23, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, mne_nid_count));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_nid_count) == 1, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->mne_nid_count));
>> +     LASSERTF((int)offsetof(struct mgs_nidtbl_entry, u.nids[0]) == 24, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_nidtbl_entry, u.nids[0]));
>> +     LASSERTF((int)sizeof(((struct mgs_nidtbl_entry *)0)->u.nids[0]) == 8, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_nidtbl_entry *)0)->u.nids[0]));
>> +
>> +     /* Checks for struct mgs_config_body */
>> +     LASSERTF((int)sizeof(struct mgs_config_body) == 80, "found %lld\n",
>> +              (long long)(int)sizeof(struct mgs_config_body));
>> +     LASSERTF((int)offsetof(struct mgs_config_body, mcb_name) == 0, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_body, mcb_name));
>> +     LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_name) == 64, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_name));
>> +     LASSERTF((int)offsetof(struct mgs_config_body, mcb_offset) == 64, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_body, mcb_offset));
>> +     LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_offset) == 8, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_offset));
>> +     LASSERTF((int)offsetof(struct mgs_config_body, mcb_type) == 72, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_body, mcb_type));
>> +     LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_type) == 2, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_type));
>> +     LASSERTF((int)offsetof(struct mgs_config_body, mcb_nm_cur_pass) == 74, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_body, mcb_nm_cur_pass));
>> +     LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_nm_cur_pass) == 1, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_nm_cur_pass));
>> +     LASSERTF((int)offsetof(struct mgs_config_body, mcb_bits) == 75, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_body, mcb_bits));
>> +     LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_bits) == 1, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_bits));
>> +     LASSERTF((int)offsetof(struct mgs_config_body, mcb_units) == 76, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_body, mcb_units));
>> +     LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_units) == 4, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_units));
>> +
>> +     BUILD_BUG_ON(CONFIG_T_CONFIG != 0);
>> +     BUILD_BUG_ON(CONFIG_T_SPTLRPC != 1);
>> +     BUILD_BUG_ON(CONFIG_T_RECOVER != 2);
>> +     BUILD_BUG_ON(CONFIG_T_PARAMS != 3);
>> +
>> +     /* Checks for struct mgs_config_res */
>> +     LASSERTF((int)sizeof(struct mgs_config_res) == 16, "found %lld\n",
>> +              (long long)(int)sizeof(struct mgs_config_res));
>> +     LASSERTF((int)offsetof(struct mgs_config_res, mcr_offset) == 0, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_res, mcr_offset));
>> +     LASSERTF((int)sizeof(((struct mgs_config_res *)0)->mcr_offset) == 8, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_res *)0)->mcr_offset));
>> +     LASSERTF((int)offsetof(struct mgs_config_res, mcr_size) == 8, "found %lld\n",
>> +              (long long)(int)offsetof(struct mgs_config_res, mcr_size));
>> +     LASSERTF((int)sizeof(((struct mgs_config_res *)0)->mcr_size) == 8, "found %lld\n",
>> +              (long long)(int)sizeof(((struct mgs_config_res *)0)->mcr_size));
>> +
>>        /* Checks for struct lustre_capa */
>>        LASSERTF((int)sizeof(struct lustre_capa) == 120, "found %lld\n",
>>                 (long long)(int)sizeof(struct lustre_capa));
>> --
>> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/b493703e/attachment.sig>
