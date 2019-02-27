From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Feb 2019 06:17:57 +0000
Subject: [lustre-devel] [PATCH 37/37] lustre: obd_sysfs: error-check
 value stored in jobid_var
In-Reply-To: <155053494716.24125.12637812266850199400.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494716.24125.12637812266850199400.stgit@noble.brown>
Message-ID: <4271D74A-4B36-4781-A1DA-F5512CBCAF15@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 18, 2019, at 17:09, NeilBrown <neilb@suse.com> wrote:
> 
> The jobid_var sysfs attribute only has 3 meaningful values.
> Other values cause lustre_get_jobid() to return an error
> which is uniformly ignored.
> 
> To improve usability and resilience, check that the value
> written is acceptable before storing it.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

This will no longer be true once https://review.whamcloud.com/31691
commit 6488c0ec57de ("LU-10698 obdclass: allow specifying complex jobids")
is merged into your tree.  That allows specifying more useful jobid
values, similar to how coredump files can be named:

    Allow specifying a format string for the jobid_name variable to create
    a jobid for processes on the client.  The jobid_name is used when
    jobid_var=nodelocal, if jobid_name contains "%j", or as a fallback if
    getting the specified jobid_var from the environment fails.
    
    The jobid_node string allows the following escape sequences:
    
        %e = executable name
        %g = group ID
        %h = hostname (system utsname)
        %j = jobid from jobid_var environment variable
        %p = process ID
        %u = user ID
    
    Any unknown escape sequences are dropped. Other arbitrary characters
    pass through unmodified, up to the maximum jobid string size of 32,
    though whitespace within the jobid is not copied.

    This allows, for example, specifying an arbitrary prefix, such as the
    cluster name, in addition to the traditional "procname.uid" format,
    to distinguish between jobs running on clients in different clusters:
    
        lctl set_param jobid_var=nodelocal jobid_name=cluster2.%e.%u
    or
        lctl set_param jobid_var=SLURM_JOB_ID jobid_name=cluster2.%j.%e
    
    To use an environment-specified JobID, if available, but fall back to
    a static string for all processes that do not have a valid JobID:
    
        lctl set_param jobid_var=SLURM_JOB_ID jobid_name=unknown


Currently the "%j" function was removed from the kernel client, even
though there is no technical reason it can't work (i.e. all of the code
to implement it is available and exported).  This is actually super
useful for HPC cluster administrators to monitor per-job IO bandwidth
and IOPS on the server, and something that I think should be restored.

Cheers, Andreas

> ---
> drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |   21 ++++++++++++++------
> 1 file changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
> index 57a6f2c2da1c..69ccc6a55947 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
> @@ -216,16 +216,25 @@ static ssize_t jobid_var_store(struct kobject *kobj, struct attribute *attr,
> 			       const char *buffer,
> 			       size_t count)
> {
> +	static char *valid[] = {
> +		JOBSTATS_DISABLE,
> +		JOBSTATS_PROCNAME_UID,
> +		JOBSTATS_NODELOCAL,
> +		NULL
> +	};
> +	int i;
> +
> 	if (!count || count > JOBSTATS_JOBID_VAR_MAX_LEN)
> 		return -EINVAL;
> 
> -	memset(obd_jobid_var, 0, JOBSTATS_JOBID_VAR_MAX_LEN + 1);
> -
> -	memcpy(obd_jobid_var, buffer, count);
> +	for (i = 0; valid[i]; i++)
> +		if (sysfs_streq(buffer, valid[i]))
> +			break;
> +	if (!valid[i])
> +		return -EINVAL;
> 
> -	/* Trim the trailing '\n' if any */
> -	if (obd_jobid_var[count - 1] == '\n')
> -		obd_jobid_var[count - 1] = 0;
> +	memset(obd_jobid_var, 0, JOBSTATS_JOBID_VAR_MAX_LEN + 1);
> +	strcpy(obd_jobid_var, valid[i]);
> 
> 	return count;
> }
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
