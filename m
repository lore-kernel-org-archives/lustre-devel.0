From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Mon, 5 Nov 2018 14:37:33 +0100
Subject: [lustre-devel] [PATCH v2] lustre: mdc: fix possible deadlock in
 chlg_open()
In-Reply-To: <alpine.LFD.2.21.1811042131490.27308@casper.infradead.org>
References: <87bm7a3nue.fsf@notabene.neil.brown.name>
 <7db27e7d-e685-af8f-80d8-891a0d8db4d5@cea.fr>
 <875zxh3elu.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811042131490.27308@casper.infradead.org>
Message-ID: <88ccd141-4778-e3ab-3ce0-e7cbd5c290fc@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 04/11/2018 ? 22:34, James Simmons a ?crit?:
>> Lockdep reports a possible deadlock between chlg_open() and
>> mdc_changelog_cdev_init()
>>
>> mdc_changelog_cdev_init() takes chlg_registered_dev_lock and then
>> calls misc_register() which takes misc_mtx.
>> chlg_open() is called while misc_mtx is held, and tries to take
>> chlg_registered_dev_lock.
>> If these two functions race, a deadlock can occur as each thread will
>> hold one of the locks while trying to take the other.
>>
>> chlg_open() does not need to take a lock.  It only uses the
>> lock to stablize a list while looking for the matching
>> chlg_registered_dev, and this can be found directly by examining
>> file->private_data.
>>
>> So remove chlg_obd_get(), and use file->private_data to find the
>> obd_device.
>> Also ensure the device is fully initialized before calling
>> misc_register().  This means setting up some list linkage before the
>> call, and tearing it down if there is an error.
> I have been testing this but I'm no HSM expert. I pushed this patch
> to OpenSFS branch as well.
>
> https://jira.whamcloud.com/browse/LU-11617
> https://review.whamcloud.com/#/c/33572/
>
> Reviewed-by: James Simmons <jsimmons@infradead.org>

Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>

>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>
>> This is the revised version with the problem identified by Quentin
>> fixed.
>>
>>   drivers/staging/lustre/lustre/mdc/mdc_changelog.c | 46 +++++++----------------
>>   1 file changed, 14 insertions(+), 32 deletions(-)
>>
>> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
>> index d83507cbf95c..af29ea73c48a 100644
>> --- a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
>> +++ b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
>> @@ -444,31 +444,6 @@ static ssize_t chlg_write(struct file *file, const char __user *buff,
>>   	return rc < 0 ? rc : count;
>>   }
>>   
>> -/**
>> - * Find the OBD device associated to a changelog character device.
>> - * @param[in]  cdev  character device instance descriptor
>> - * @return corresponding OBD device or NULL if none was found.
>> - */
>> -static struct obd_device *chlg_obd_get(dev_t cdev)
>> -{
>> -	int minor = MINOR(cdev);
>> -	struct obd_device *obd = NULL;
>> -	struct chlg_registered_dev *curr;
>> -
>> -	mutex_lock(&chlg_registered_dev_lock);
>> -	list_for_each_entry(curr, &chlg_registered_devices, ced_link) {
>> -		if (curr->ced_misc.minor == minor) {
>> -			/* take the first available OBD device attached */
>> -			obd = list_first_entry(&curr->ced_obds,
>> -					       struct obd_device,
>> -					       u.cli.cl_chg_dev_linkage);
>> -			break;
>> -		}
>> -	}
>> -	mutex_unlock(&chlg_registered_dev_lock);
>> -	return obd;
>> -}
>> -
>>   /**
>>    * Open handler, initialize internal CRS state and spawn prefetch thread if
>>    * needed.
>> @@ -479,12 +454,16 @@ static struct obd_device *chlg_obd_get(dev_t cdev)
>>   static int chlg_open(struct inode *inode, struct file *file)
>>   {
>>   	struct chlg_reader_state *crs;
>> -	struct obd_device *obd = chlg_obd_get(inode->i_rdev);
>> +	struct miscdevice *misc = file->private_data;
>> +	struct chlg_registered_dev *dev;
>> +	struct obd_device *obd;
>>   	struct task_struct *task;
>>   	int rc;
>>   
>> -	if (!obd)
>> -		return -ENODEV;
>> +	dev = container_of(misc, struct chlg_registered_dev, ced_misc);
>> +	obd = list_first_entry(&dev->ced_obds,
>> +			       struct obd_device,
>> +			       u.cli.cl_chg_dev_linkage);
>>   
>>   	crs = kzalloc(sizeof(*crs), GFP_KERNEL);
>>   	if (!crs)
>> @@ -669,13 +648,16 @@ int mdc_changelog_cdev_init(struct obd_device *obd)
>>   		goto out_unlock;
>>   	}
>>   
>> +	list_add_tail(&obd->u.cli.cl_chg_dev_linkage, &entry->ced_obds);
>> +	list_add_tail(&entry->ced_link, &chlg_registered_devices);
>> +
>>   	/* Register new character device */
>>   	rc = misc_register(&entry->ced_misc);
>> -	if (rc != 0)
>> +	if (rc != 0) {
>> +		list_del_init(&obd->u.cli.cl_chg_dev_linkage);
>> +		list_del(&entry->ced_link);
>>   		goto out_unlock;
>> -
>> -	list_add_tail(&obd->u.cli.cl_chg_dev_linkage, &entry->ced_obds);
>> -	list_add_tail(&entry->ced_link, &chlg_registered_devices);
>> +	}
>>   
>>   	entry = NULL;	/* prevent it from being freed below */
>>   
>> -- 
>> 2.14.0.rc0.dirty
>>
>>
