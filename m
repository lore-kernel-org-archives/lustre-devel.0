From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 15 Dec 2015 18:08:44 +0000
Subject: [lustre-devel] [PATCH 02/40] staging: lustre: fix 'NULL pointer
 dereference' errors for LNet
In-Reply-To: <20151202074617.GI18797@mwanda>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-3-git-send-email-jsimmons@infradead.org>
	<20151202074617.GI18797@mwanda>
Message-ID: <2d1f3c4a4b50489896fcc6f703768bb0@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
>> index 556c837..2ca7d0e 100644
>> --- a/drivers/staging/lustre/lnet/selftest/conctl.c
>> +++ b/drivers/staging/lustre/lnet/selftest/conctl.c
>> @@ -679,45 +679,46 @@ static int
>>  lst_stat_query_ioctl(lstio_stat_args_t *args)
>>  {
>>  	int rc;
>> -	char *name;
>> +	char *name = NULL;
>>  
>>  	/* TODO: not finished */
>>  	if (args->lstio_sta_key != console_session.ses_key)
>>  		return -EACCES;
>>  
>> -	if (args->lstio_sta_resultp == NULL ||
>> -	    (args->lstio_sta_namep  == NULL &&
>> -	     args->lstio_sta_idsp   == NULL) ||
>> -	    args->lstio_sta_nmlen <= 0 ||
>> -	    args->lstio_sta_nmlen > LST_NAME_SIZE)
>> -		return -EINVAL;
>> -
>> -	if (args->lstio_sta_idsp != NULL &&
>> -	    args->lstio_sta_count <= 0)
>> +	if (!args->lstio_sta_resultp)
>>  		return -EINVAL;
>>  
>> -	LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
>> -	if (name == NULL)
>> -		return -ENOMEM;
>> -
>> -	if (copy_from_user(name, args->lstio_sta_namep,
>> -			       args->lstio_sta_nmlen)) {
>> -		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
>> -		return -EFAULT;
>> -	}
>> +	if (args->lstio_sta_idsp) {
>> +		if (args->lstio_sta_count <= 0)
>> +			return -EINVAL;
>>  
>> -	if (args->lstio_sta_idsp == NULL) {
>> -		rc = lstcon_group_stat(name, args->lstio_sta_timeout,
>> -				       args->lstio_sta_resultp);
>> -	} else {
>>  		rc = lstcon_nodes_stat(args->lstio_sta_count,
>>  				       args->lstio_sta_idsp,
>>  				       args->lstio_sta_timeout,
>>  				       args->lstio_sta_resultp);
>> -	}
>> +	} else if (args->lstio_sta_namep) {
>> +		if (args->lstio_sta_nmlen <= 0 ||
>> +		    args->lstio_sta_nmlen > LST_NAME_SIZE)
>> +			return -EINVAL;
>> +
>> +		LIBCFS_ALLOC(name, args->lstio_sta_nmlen + 1);
>> +		if (!name)
>> +			return -ENOMEM;
>>  
>> -	LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
>> +		rc = copy_from_user(name, args->lstio_sta_namep,
>> +				    args->lstio_sta_nmlen);
>> +		if (!rc)
>> +			rc = lstcon_group_stat(name, args->lstio_sta_timeout,
>> +					       args->lstio_sta_resultp);
>> +		else
>> +			rc = -EFAULT;
>>  
>> +	} else {
>> +		rc = -EINVAL;
>> +	}
>> +
>> +	if (name)
>> +		LIBCFS_FREE(name, args->lstio_sta_nmlen + 1);
>
>There is no bug fix here.  This code was fine when it was merged into
>the kernel in 2013 so I have no idea how out of date the static checker
>warning is...  The new code doesn't do unnecessary allocations so that's
>good but "name" should be declared in the block where it is used instead
>of at the start of the function.  Btw, we assume that the user gives us
>a NUL terminated string for "name" so we should fix that bug as well.
>
>TODO: lustre: don't assume "name" is NUL terminated

Ugh. I see breakage everywhere in this code :-( Need to address.  I think we
should convert that to strcpy_to_user as well.
