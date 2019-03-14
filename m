From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:34:05 +1100
Subject: [lustre-devel] [PATCH 37/37] lustre: obd_sysfs: error-check
 value stored in jobid_var
In-Reply-To: <DM6PR19MB2508A4BA4F95517F8BDBB9F0C5760@DM6PR19MB2508.namprd19.prod.outlook.com>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494716.24125.12637812266850199400.stgit@noble.brown>
 <4271D74A-4B36-4781-A1DA-F5512CBCAF15@whamcloud.com>
 <87woljs4mv.fsf@notabene.neil.brown.name>
 <5154EC17-80E4-49EC-B554-9AA010DD1271@whamcloud.com>
 <DM6PR19MB2508A4BA4F95517F8BDBB9F0C5760@DM6PR19MB2508.namprd19.prod.outlook.com>
Message-ID: <87sgvqpa4i.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi Patrick,
 I agree that "something that should live in struct_task" is the sort of
 answer that would be nice, but I don't think it can be justified.

 A "session" in the sense of "getsid" and "setsid" is traditionally a
 login session, but since the invention of windowing systems it is one
 terminal window.
 So if you
    grep NSsid /proc/self/status
 in different windows you will see different session ids.  All processes
 in that window will have the same session id unless something
 explicitly creates a new session - few things do that.

 If you want to explicitly create a new session, you can use "setsid".
 So
    setsid grep NSsid /proc/self/status
 will always show a new session id.

 Considering you sketch, the "unique parent" is already very likely to
 be in a session that no other job is in.
 If you run multiple jobs from the one terminal window (is they likely?)
 then the will all be in the same session unless you run
    setsid run-my-job

 The session (and anything we associated with it) will apply to all
 children and grandchild etc.
 There is no need for a timeout beyond what the code already has - it
 checks every 5 minutes to see if the session is still active, and
 forgets any inactive session.  There is no risk of a new session being
 confused with an old session that no longer exists, even if they have
 the same number.

 I hope that clarifies for you.

Thanks,
NeilBrown


On Fri, Mar 01 2019, Patrick Farrell wrote:

> The definition of "session" matters here.  It is increasingly common to run multiple jobs on a node at the same time, and the desire to distinguish between them is also significant.  So we can't have just one session.
>
> I believe this is part of why it was chosen to put this information in user space, associated with a particular process.
>
> So we need a solution that can meet that requirement or the broader HPC world will just ignore us.
>
> Perhaps we could use the new jobid cache functionality here.  A sketch:
>
> Have the parent - I believe there would be a unique parent for every set of job processes - register the ID (via this proc variable) and we would apply it to all children (what about grandchildren, etc...).  Then set timeouts to something like 24 or 48 hours, and but also use (or add if it's not present?) the functionality to deregister job ids at job exit.  So the timeout is only for cleanup.
>
> Although, the more I talk about this, the more this feels like something that should live in struct_task and be set from user space and managed by the kernel...
> ________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of Andreas Dilger <adilger@whamcloud.com>
> Sent: Friday, March 1, 2019 2:32:00 AM
> To: NeilBrown
> Cc: Lustre Development List
> Subject: Re: [lustre-devel] [PATCH 37/37] lustre: obd_sysfs: error-check value stored in jobid_var
>
> On Feb 28, 2019, at 19:35, NeilBrown <neilb@suse.com> wrote:
>>
>> On Wed, Feb 27 2019, Andreas Dilger wrote:
>>
>>> On Feb 18, 2019, at 17:09, NeilBrown <neilb@suse.com> wrote:
>>>>
>>>> The jobid_var sysfs attribute only has 3 meaningful values.
>>>> Other values cause lustre_get_jobid() to return an error
>>>> which is uniformly ignored.
>>>>
>>>> To improve usability and resilience, check that the value
>>>> written is acceptable before storing it.
>>>>
>>>> Signed-off-by: NeilBrown <neilb@suse.com>
>>>
>>> This will no longer be true once https://review.whamcloud.com/31691
>>> commit 6488c0ec57de ("LU-10698 obdclass: allow specifying complex jobids")
>>
>> Actually it will.  That patch changes the use of jobid_name, my patch
>> restricts the values of jobid_var.
>>
>> I just realized why it is called "jobid_var" - in OpenSFS lustre, it can
>> be an environment variable name.  In drivers/staging lustre it cannot,
>> so the name is a little odd.
>>
>>>
>>> Currently the "%j" function was removed from the kernel client, even
>>> though there is no technical reason it can't work (i.e. all of the code
>>> to implement it is available and exported).  This is actually super
>>> useful for HPC cluster administrators to monitor per-job IO bandwidth
>>> and IOPS on the server, and something that I think should be restored.
>>
>> I think that you probably need to let go of that desire - I don't think
>> it is going to happen.  While the code may, as you say, work - it is
>> easy to dislike that approach, and would be hard to push against such
>> resistance.
>>
>> I have an alternate approach, patch below.  Instead of
>> export LUSTRE_JOBID=foobar
>> and process can run
>> echo foobar > /sys/fs/lustre/jobid_this_session
>>
>> and it will affect all processes in the current "session".
>>
>> Could you warm to this approach at all?
>
> This is the best alternative that I've seen so far.  That said, the choice
> of storing the JobID as an environment variable wasn't something that we
> invented ourselves, but rather this is what the various job schedulers do
> when a job is first started, and the code to extract the JobID out of the
> process environment was what we implemented to work within the constraints
> that were given to us.  The benefit of course is that we don't depend on
> some external process to be run for every process to extract the environment
> variable from the kernel memory and send it back to us.
>
> Allowing different processes to have different JobIDs on a single node is
> definitely a requirement for most environments these days, and so far this
> is the only solution that has allowed that to work.
>
> James is more familiar with the production side of the house, so I'll let
> him comment on how easy/hard it would be to get this kind of change added
> to the per-job preamble script so that it is set for all processes.
>
> Cheers, Andreas
>
>> From: NeilBrown <neilb@suse.com>
>> Subject: [PATCH] lustre: obdclass: allow per-session jobids.
>>
>> Lustre includes a jobid in all RPC message sent to the server.  This
>> is used to collected per-job statistics, where a "job" can involve
>> multiple processes on multiple nodes in a cluster.
>>
>> Nodes in a cluster can be running processes for multiple jobs, so it
>> is best if different processes can have different jobids, and that
>> processes on different nodes can have the same job id.
>>
>> This is not currently possible with the drivers/staging code.
>>
>> Lustre traditionally uses an environment variable to name a job, but
>> having the kernel reach into the address space of a process to find
>> that environment variable is seen by some developers to be an
>> unacceptable design choice.
>>
>> This patch provides an alternate method, leveraging the concept of a
>> "session id", as set with setsid().  Each login session already gets a
>> unique sid which is preserved for all processes in that session unless
>> explicitly changed (with setsid(1)).
>> When a process in a session writes to
>> /sys/fs/lustre/jobid_this_session, the string becomes the name for
>> that session.
>> If jobid_var is set to "manual", then the per-session jobid is used
>> for the jobid for all requests from processes in that session.
>>
>> When a session ends, the jobid information will be purged within 5
>> minutes.
>>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> .../staging/lustre/lustre/include/lprocfs_status.h |   1 +
>> drivers/staging/lustre/lustre/include/obd_class.h  |   3 +
>> drivers/staging/lustre/lustre/obdclass/class_obd.c | 160 ++++++++++++++++++++-
>> drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |  41 ++++++
>> 4 files changed, 204 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
>> index 8565c28f08ee..1335a5722903 100644
>> --- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
>> +++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
>> @@ -370,6 +370,7 @@ static inline void s2dhms(struct dhms *ts, time64_t secs64)
>> #define JOBSTATS_DISABLE              "disable"
>> #define JOBSTATS_PROCNAME_UID         "procname_uid"
>> #define JOBSTATS_NODELOCAL            "nodelocal"
>> +#define JOBSTATS_MANUAL                      "manual"
>>
>> /* obd_config.c */
>> void lustre_register_client_process_config(int (*cpc)(struct lustre_cfg *lcfg));
>> diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
>> index 50b08c89ecc5..08003f3dd467 100644
>> --- a/drivers/staging/lustre/lustre/include/obd_class.h
>> +++ b/drivers/staging/lustre/lustre/include/obd_class.h
>> @@ -55,6 +55,9 @@ extern rwlock_t obd_dev_lock;
>> struct obd_device *class_exp2obd(struct obd_export *exp);
>> int class_handle_ioctl(unsigned int cmd, unsigned long arg);
>> int lustre_get_jobid(char *jobid);
>> +char *jobid_current(void);
>> +int jobid_set_current(char *jobid);
>> +
>>
>> struct lu_device_type;
>>
>> diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> index 1fcbda128a58..19ce3c858e59 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> @@ -79,6 +79,144 @@ EXPORT_SYMBOL(at_extra);
>> char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
>> char obd_jobid_node[LUSTRE_JOBID_SIZE + 1];
>>
>> +/*
>> + * Jobid can be set for a session (see setsid(2)) by writing to
>> + * a sysfs file from any process in that session.
>> + * The jobids are stored in a hash table indexed by the relevant
>> + * struct pid.  We periodically look for entries where the pid has
>> + * no PIDTYPE_SID tasks any more, and prune them.  This happens within
>> + * 5 seconds of a jobid being added, and every 5 minutes when jobids exist,
>> + * but none are added.
>> + */
>> +#define JOBID_EXPEDITED_CLEAN (5 * HZ)
>> +#define JOBID_BACKGROUND_CLEAN (5 * 60 * HZ)
>> +
>> +struct session_jobid {
>> +     struct pid              *session;
>> +     struct rhash_head       linkage;
>> +     struct rcu_head         rcu;
>> +     char                    jobid[1];
>> +};
>> +
>> +const static struct rhashtable_params jobid_params = {
>> +     .key_len        = sizeof(struct pid *),
>> +     .key_offset     = offsetof(struct session_jobid, session),
>> +     .head_offset    = offsetof(struct session_jobid, linkage),
>> +};
>> +static struct rhashtable session_jobids;
>> +
>> +/*
>> + * jobid_current must be called with rcu_read_lock held.
>> + * if it returns non-NULL, the string can only be used
>> + * until rcu_read_unlock is called.
>> + */
>> +char *jobid_current(void)
>> +{
>> +     struct pid *sid = current->signal->pids[PIDTYPE_SID];
>> +     struct session_jobid *sj;
>> +
>> +     sj = rhashtable_lookup_fast(&session_jobids, &sid, jobid_params);
>> +     if (sj)
>> +             return sj->jobid;
>> +     return NULL;
>> +}
>> +
>> +static void jobid_prune_expedite(void);
>> +/*
>> + * jobid_set_current will try to add a new entry
>> + * to the table.  If one exists with the same key, the
>> + * jobid will be replaced
>> + */
>> +int jobid_set_current(char *jobid)
>> +{
>> +     struct pid *sid = current->signal->pids[PIDTYPE_SID];
>> +     struct session_jobid *sj, *origsj;
>> +     int ret;
>> +
>> +     sj = kmalloc(sizeof(*sj) + strlen(jobid), GFP_KERNEL);
>> +     if (!sj)
>> +             return -ENOMEM;
>> +     rcu_read_lock();
>> +     sj->session = get_pid(sid);
>> +     strcpy(sj->jobid, jobid);
>> +     origsj = rhashtable_lookup_get_insert_fast(&session_jobids,
>> +                                                &sj->linkage,
>> +                                                jobid_params);
>> +     if (origsj == NULL) {
>> +             /* successful insert */
>> +             rcu_read_unlock();
>> +             jobid_prune_expedite();
>> +             return 0;
>> +     }
>> +
>> +     if (IS_ERR(origsj)) {
>> +             put_pid(sj->session);
>> +             kfree(sj);
>> +             rcu_read_unlock();
>> +             return PTR_ERR(origsj);
>> +     }
>> +     ret = rhashtable_replace_fast(&session_jobids,
>> +                                   &origsj->linkage,
>> +                                   &sj->linkage,
>> +                                   jobid_params);
>> +     if (ret) {
>> +             put_pid(sj->session);
>> +             kfree(sj);
>> +             rcu_read_unlock();
>> +             return ret;
>> +     }
>> +     put_pid(origsj->session);
>> +     rcu_read_unlock();
>> +     kfree_rcu(origsj, rcu);
>> +     jobid_prune_expedite();
>> +
>> +     return 0;
>> +}
>> +
>> +static void jobid_free(void *vsj, void *arg)
>> +{
>> +     struct session_jobid *sj = vsj;
>> +     put_pid(sj->session);
>> +     kfree(sj);
>> +}
>> +
>> +static void jobid_prune(struct work_struct *work);
>> +static DECLARE_DELAYED_WORK(jobid_prune_work, jobid_prune);
>> +static int jobid_prune_expedited;
>> +static void jobid_prune(struct work_struct *work)
>> +{
>> +     int remaining = 0;
>> +     struct rhashtable_iter iter;
>> +     struct session_jobid *sj;
>> +
>> +     jobid_prune_expedited = 0;
>> +     rhashtable_walk_enter(&session_jobids, &iter);
>> +     rhashtable_walk_start(&iter);
>> +     while ((sj = rhashtable_walk_next(&iter)) != NULL) {
>> +             if (!hlist_empty(&sj->session->tasks[PIDTYPE_SID])) {
>> +                     remaining++;
>> +                     continue;
>> +             }
>> +             if (rhashtable_remove_fast(&session_jobids,
>> +                                        &sj->linkage, jobid_params) == 0) {
>> +                     put_pid(sj->session);
>> +                     kfree_rcu(sj, rcu);
>> +             }
>> +     }
>> +     rhashtable_walk_stop(&iter);
>> +     rhashtable_walk_exit(&iter);
>> +     if (remaining)
>> +             schedule_delayed_work(&jobid_prune_work, JOBID_BACKGROUND_CLEAN);
>> +}
>> +
>> +static void jobid_prune_expedite(void)
>> +{
>> +     if (!jobid_prune_expedited) {
>> +             jobid_prune_expedited = 1;
>> +             mod_delayed_work(system_wq, &jobid_prune_work, JOBID_EXPEDITED_CLEAN);
>> +     }
>> +}
>> +
>> /* Get jobid of current process from stored variable or calculate
>>  * it from pid and user_id.
>>  *
>> @@ -108,6 +246,17 @@ int lustre_get_jobid(char *jobid)
>>                goto out_cache_jobid;
>>        }
>>
>> +     if (strcmp(obd_jobid_var, JOBSTATS_MANUAL) == 0) {
>> +             char *jid;
>> +             rcu_read_lock();
>> +             jid = jobid_current();
>> +             if (jid)
>> +                     strlcpy(tmp_jobid, jid, sizeof(tmp_jobid));
>> +             rcu_read_unlock();
>> +             if (jid)
>> +                     goto out_cache_jobid;
>> +     }
>> +
>>        return -ENOENT;
>>
>> out_cache_jobid:
>> @@ -663,10 +812,13 @@ static int __init obdclass_init(void)
>>        if (err)
>>                goto cleanup_zombie_impexp;
>>
>> +     err = rhashtable_init(&session_jobids, &jobid_params);
>> +     if (err)
>> +             goto cleanup_class_handle;
>>        err = misc_register(&obd_psdev);
>>        if (err) {
>>                CERROR("cannot register OBD miscdevices: err %d\n", err);
>> -             goto cleanup_class_handle;
>> +             goto cleanup_session_jobids;
>>        }
>>
>>        /* Default the dirty page cache cap to 1/2 of system memory.
>> @@ -724,6 +876,9 @@ static int __init obdclass_init(void)
>> cleanup_deregister:
>>        misc_deregister(&obd_psdev);
>>
>> +cleanup_session_jobids:
>> +     rhashtable_free_and_destroy(&session_jobids, jobid_free, NULL);
>> +
>> cleanup_class_handle:
>>        class_handle_cleanup();
>>
>> @@ -743,6 +898,9 @@ static void obdclass_exit(void)
>>        cl_global_fini();
>>        lu_global_fini();
>>
>> +     cancel_delayed_work_sync(&jobid_prune_work);
>> +     rhashtable_free_and_destroy(&session_jobids, jobid_free, NULL);
>> +
>>        obd_cleanup_caches();
>>
>>        class_procfs_clean();
>> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
>> index 69ccc6a55947..112782e56793 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
>> @@ -220,6 +220,7 @@ static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
>>                JOBSTATS_DISABLE,
>>                JOBSTATS_PROCNAME_UID,
>>                JOBSTATS_NODELOCAL,
>> +             JOBSTATS_MANUAL,
>>                NULL
>>        };
>>        int i;
>> @@ -263,6 +264,44 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
>>        return count;
>> }
>>
>> +static ssize_t jobid_this_session_show(struct kobject *kobj,
>> +                                    struct attribute *attr,
>> +                                    char *buf)
>> +{
>> +     char *jid;
>> +     int ret = -ENOENT;
>> +
>> +     rcu_read_lock();
>> +     jid = jobid_current();
>> +     if (jid)
>> +             ret = snprintf(buf, PAGE_SIZE, "%s\n", jid);
>> +     rcu_read_unlock();
>> +     return ret;
>> +}
>> +
>> +static ssize_t jobid_this_session_store(struct kobject *kobj,
>> +                                     struct attribute *attr,
>> +                                     const char *buffer,
>> +                                     size_t count)
>> +{
>> +     char *jobid;
>> +     int len;
>> +     int ret;
>> +
>> +     if (!count || count > LUSTRE_JOBID_SIZE)
>> +             return -EINVAL;
>> +
>> +     jobid = kstrndup(buffer, count, GFP_KERNEL);
>> +     if (!jobid)
>> +             return -ENOMEM;
>> +     len = strcspn(jobid, " \n");
>> +     jobid[len] = '\0';
>> +     ret = jobid_set_current(jobid);
>> +     kfree(jobid);
>> +
>> +     return ret ?: count;
>> +}
>> +
>> /* Root for /sys/kernel/debug/lustre */
>> struct dentry *debugfs_lustre_root;
>> EXPORT_SYMBOL_GPL(debugfs_lustre_root);
>> @@ -272,6 +311,7 @@ LUSTRE_RO_ATTR(pinger);
>> LUSTRE_RO_ATTR(health_check);
>> LUSTRE_RW_ATTR(jobid_var);
>> LUSTRE_RW_ATTR(jobid_name);
>> +LUSTRE_RW_ATTR(jobid_this_session);
>>
>> static struct attribute *lustre_attrs[] = {
>>        &lustre_attr_version.attr,
>> @@ -279,6 +319,7 @@ static struct attribute *lustre_attrs[] = {
>>        &lustre_attr_health_check.attr,
>>        &lustre_attr_jobid_name.attr,
>>        &lustre_attr_jobid_var.attr,
>> +     &lustre_attr_jobid_this_session.attr,
>>        &lustre_sattr_timeout.u.attr,
>>        &lustre_attr_max_dirty_mb.attr,
>>        &lustre_sattr_debug_peer_on_timeout.u.attr,
>> --
>> 2.14.0.rc0.dirty
>>
>
> Cheers, Andreas
> ---
> Andreas Dilger
> CTO Whamcloud
>
>
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190314/0833fd0c/attachment.sig>
