From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 12 Feb 2016 23:16:02 +0000
Subject: [lustre-devel] [PATCH 5/7] staging:lustre:
	simplify	libcfs_psdev_[open|release]
In-Reply-To: <20160203224035.GA10529@kroah.com>
References: <1452022519-6716-1-git-send-email-jsimmons@infradead.org>
	<1452022519-6716-6-git-send-email-jsimmons@infradead.org>
	<20160203224035.GA10529@kroah.com>
Message-ID: <7d92389fd1ca47abb762b460f4d9b7b6@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Parinay Kondekar <parinay.kondekar@seagate.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

>> diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
>> index 33f6036..64f0fbf 100644
>> --- a/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
>> +++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-module.c
>> @@ -98,30 +98,22 @@ int libcfs_ioctl_popdata(void *arg, void *data, int size)
>>  static int
>>  libcfs_psdev_open(struct inode *inode, struct file *file)
>>  {
>> -	int    rc = 0;
>> -
>>  	if (!inode)
>>  		return -EINVAL;
>> -	if (libcfs_psdev_ops.p_open != NULL)
>> -		rc = libcfs_psdev_ops.p_open(0, NULL);
>> -	else
>> -		return -EPERM;
>> -	return rc;
>> +
>> +	try_module_get(THIS_MODULE);
>
>Note, code like this is racy and incorrect and never needed, please fix
>this up properly (hint, set the module in the file operations.)
>
>Again, if you ever see code with that line, it is incorrect.

So simple

static struct file_operations libcfs_fops = {
        .module  = THIS_MODULE,
        .unlocked_ioctl = libcfs_psdev_ioctl,
};

With the open and release deleted should do the trick then.
