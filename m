From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 16:01:42 +1100
Subject: [lustre-devel] [PATCH 17/21] lustre: obdclass: result of
 try_module_get() should not be ignored.
In-Reply-To: <alpine.LFD.2.21.1902110421020.5690@casper.infradead.org>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781334.10620.18347323437724979128.stgit@noble.brown>
 <alpine.LFD.2.21.1902110421020.5690@casper.infradead.org>
Message-ID: <87tvhagbpl.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Feb 11 2019, James Simmons wrote:

>> If try_module_get() fails, the open must fail.
>> 
>> In practice this should be impossible, but it is
>> best to make the code look right.
>
> I remembar having discussion with Greg about this approach in libcfs.
> He though it was racey to do this in general. The discussion was a
> while ago so I need to dig up the thread. In the end we remove the
> whole module handling in the xxx_open() and such.

Yes, you are right. This should just be removed.
This is a chardev, and the .owner of a chardev will always have a
reference held while the device is open - cdev_get/cdev_put ensure that.

We can just get rid of the obd_class_open and obd_class_release.

I'll drop this patch and replace it.

Thanks,
NeilBrown


>  
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/obdclass/class_obd.c |    3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> index 48d1dabafa65..982d47b6f50e 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
>> @@ -548,8 +548,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
>>  /*  opening /dev/obd */
>>  static int obd_class_open(struct inode *inode, struct file *file)
>>  {
>> -	try_module_get(THIS_MODULE);
>> -	return 0;
>> +	return try_module_get(THIS_MODULE) ? 0 : -ENODEV;
>>  }
>>  
>>  /*  closing /dev/obd */
>> 
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/319ccd7c/attachment.sig>
