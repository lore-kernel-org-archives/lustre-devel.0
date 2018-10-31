From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Wed, 31 Oct 2018 13:24:28 +0100
Subject: [lustre-devel] [PATCH] lustre: mdc: fix possible deadlock in
 chlg_open()
In-Reply-To: <87bm7a3nue.fsf@notabene.neil.brown.name>
References: <87bm7a3nue.fsf@notabene.neil.brown.name>
Message-ID: <7db27e7d-e685-af8f-80d8-891a0d8db4d5@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 31/10/2018 ? 02:29, NeilBrown a ?crit?:
> Lockdep reports a possible deadlock between chlg_open() and
> mdc_changelog_cdev_init()
>
> mdc_changelog_cdev_init() takes chlg_registered_dev_lock and then
> calls misc_register() which takes misc_mtx.
> chlg_open() is called while misc_mtx is held, and tries to take
> chlg_registered_dev_lock.
> If these two functions race, a deadlock can occur as each thread will
> hold one of the locks while trying to take the other.
>
> chlg_open() does not need to take a lock.  It only uses the
> lock to stablize a list while looking for the matching
> chlg_registered_dev, and this can be found directly by examining
> file->private_data.
>
> So remove chlg_obd_get(), and use file->private_Data to find the
> obd_device.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>
> Note that this bug exists in upstream (OpenSFS) lustre as well.
I think you need to modify mdc_changelog_cdev_init() as well so that 
misc_register() comes after the two list_add_tail() statements.

If someone opens the device a bit a too fast after it becomes visible, 
they might find an empty list at `dev->ced_obds'.
Previously, holding `chlg_registered_dev_loc' implicitely prevented that.

Is it possible that maybe the kernel shouldn't hold `misc_mtx' while 
calling chlg_open()?

Quentin Bouget
>
>   drivers/staging/lustre/lustre/mdc/mdc_changelog.c | 35 +++++------------------
>   1 file changed, 7 insertions(+), 28 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
> index d83507cbf95c..645e7f24a859 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
> @@ -444,31 +444,6 @@ static ssize_t chlg_write(struct file *file, const char __user *buff,
>   	return rc < 0 ? rc : count;
>   }
>   
> -/**
> - * Find the OBD device associated to a changelog character device.
> - * @param[in]  cdev  character device instance descriptor
> - * @return corresponding OBD device or NULL if none was found.
> - */
> -static struct obd_device *chlg_obd_get(dev_t cdev)
> -{
> -	int minor = MINOR(cdev);
> -	struct obd_device *obd = NULL;
> -	struct chlg_registered_dev *curr;
> -
> -	mutex_lock(&chlg_registered_dev_lock);
> -	list_for_each_entry(curr, &chlg_registered_devices, ced_link) {
> -		if (curr->ced_misc.minor == minor) {
> -			/* take the first available OBD device attached */
> -			obd = list_first_entry(&curr->ced_obds,
> -					       struct obd_device,
> -					       u.cli.cl_chg_dev_linkage);
> -			break;
> -		}
> -	}
> -	mutex_unlock(&chlg_registered_dev_lock);
> -	return obd;
> -}
> -
>   /**
>    * Open handler, initialize internal CRS state and spawn prefetch thread if
>    * needed.
> @@ -479,12 +454,16 @@ static struct obd_device *chlg_obd_get(dev_t cdev)
>   static int chlg_open(struct inode *inode, struct file *file)
>   {
>   	struct chlg_reader_state *crs;
> -	struct obd_device *obd = chlg_obd_get(inode->i_rdev);
> +	struct miscdevice *misc = file->private_data;
> +	struct chlg_registered_dev *dev;
> +	struct obd_device *obd;
>   	struct task_struct *task;
>   	int rc;
>   
> -	if (!obd)
> -		return -ENODEV;
> +	dev = container_of(misc, struct chlg_registered_dev, ced_misc);
> +	obd = list_first_entry(&dev->ced_obds,
> +			       struct obd_device,
> +			       u.cli.cl_chg_dev_linkage);
>   
>   	crs = kzalloc(sizeof(*crs), GFP_KERNEL);
>   	if (!crs)
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181031/fb1187bf/attachment.html>
