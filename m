From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Mon, 7 Nov 2016 11:01:34 +0200
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: replace uses of
 class_devno_max by MAX_OBD_DEVICES
In-Reply-To: <alpine.LFD.2.20.1611070418200.21293@casper.infradead.org>
References: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
	<4ba436cdccbea6c6dbc631f8cf75cd80f4f9ddb4.1476739569.git.mahfouz.saif.elyazal@gmail.com>
	<D62F1CE1-61E3-43B9-8742-705AF196729C@intel.com>
	<20161025164730.GA27553@waves>
	<8FDBA22B-F6A6-4CA7-B997-41327603E8A9@intel.com>
	<CAJBmjuhuMX-qemMm1t_jhzaMc0HOWGGq66rBBWDU7eEky+-=4A@mail.gmail.com>
	<alpine.LFD.2.20.1611070418200.21293@casper.infradead.org>
Message-ID: <CAJBmjuh_mnzF0L8DRk0osicfSoLkwvDCiLyV22c3jiqBeGX9cw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Nov 7, 2016 at 6:19 AM, James Simmons <jsimmons@infradead.org>
wrote:

>
> > On Thu, Nov 3, 2016 at 1:05 AM, Dilger, Andreas <
> andreas.dilger at intel.com> wrote:
> >       On Oct 25, 2016, at 10:47, Aya Mahfouz <
> mahfouz.saif.elyazal at gmail.com> wrote:
> >       >
> >       > On Mon, Oct 17, 2016 at 10:38:31PM +0000, Dilger, Andreas wrote:
> >       >> On Oct 17, 2016, at 15:46, Aya Mahfouz <
> mahfouz.saif.elyazal at gmail.com> wrote:
> >       >>>
> >       >>> class_devno_max is an inline function that returns
> >       >>> MAX_OBD_DEVICES. Replace all calls to the function
> >       >>> by MAX_OBD_DEVICES.
> >       >>
> >       >> Thanks for your patch, but unfortunately it can't be accepted.
> >       >>
> >       >> This function was added in preparation of being able to tune
> the maximum
> >       >> number of storage devices dynamically, rather than having to
> hard code it
> >       >> to the maximum possible number of servers that a client can
> possibly
> >       >> connect to.
> >       >>
> >       >> While the current maximum of 8192 servers has been enough for
> current
> >       >> filesystems, I'd rather move in the direction of dynamically
> handling this
> >       >> limit rather than re-introducing a hard-coded constant
> throughout the code.
> >       >>
> >       > Hello,
> >       >
> >       > I would like to proceed with implementing the function if
> possible.
> >       > Kindly direct me to some starting pointers.
> >
> >       Hi Aya,
> >       thanks for offering to look into this.
> >
> >       There are several ways to approach this problem  to make the
> allocation
> >       of the obd_devs[] array dynamic.  In most cases, there isn't any
> value
> >       to dynamically shrink this array, since the filesystem(s) will
> typically
> >       be mounted until the node is rebooted, and it is only in the tens
> of KB
> >       size range, so this will not affect ongoing operations, and that
> simplifies
> >       the implementation.
> >
> >       The easiest way would be to have a dynamically-sized obd_devs[]
> array that
> >       is reallocated in class_newdev() in PAGE_SIZE chunks whenever the
> current
> >       array has no more free slots and copied to the new array, using
> obd_dev_lock
> >       to protect the array while it is being reallocated and copied.  In
> most
> >       cases, this would save memory over the static array (not many
> filesystems
> >       have so many servers), but for the few sites that have 10000+
> servers they
> >       don't need to change the source to handle this.  Using
> libcfs_kvzalloc()
> >       would avoid issues with allocating large chunks of memory.
> >
> >       There are a few places where obd_devs[] is accessed outside
> obd_dev_lock
> >       that would need to be fixed now that this array may be changed at
> runtime.
> >
> >       A second approach that may scale better is to change obd_devs from
> an array
> >       to a doubly linked list (using standard list_head helpers).  In
> many cases
> >       the whole list is seached linearly, and most of the uses of
> class_num2obd()
> >       are just used to walk that list in order, which could be replaced
> with
> >       list_for_each_entry() list traversal.  The class_name2dev()
> function should
> >       be changed to return the pointer to the obd_device structure, and
> a new
> >       helper class_dev2num() would just return the obd_minor number from
> the
> >       obd_device struct for the one use in class_resolve_dev_name().
> Using a
> >       linked list has the advantage that there is no need to search for
> free slots
> >       in the array, since devices would be removed from the list when it
> is freed.
> >
> >       Cheers, Andreas
> >
> > Thanks Andreas! Will start looking into it.
>
> Just to let you know I opened a ticket for you.
>
> https://jira.hpdd.intel.com/browse/LU-8802
>
> This way wwe can track the progress and have Lustre developers assigened
> to look at your work. Thanks for stepping forward.
>
> Thanks, I've created an account: asaifm

>
> > --
> > Kind Regards,
> > Aya Saif El-yazal Mahfouz
> >
> >       >> One comment inline below, if you still want to submit a patch.
> >       >>
> >       >>> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> >       >>> ---
> >       >>> drivers/staging/lustre/lustre/obdclass/class_obd.c |  6 +++---
> >       >>> drivers/staging/lustre/lustre/obdclass/genops.c    | 22
> +++++++++++-----------
> >       >>> .../lustre/lustre/obdclass/linux/linux-module.c    |  6 +++---
> >       >>> 3 files changed, 17 insertions(+), 17 deletions(-)
> >       >>>
> >       >>> diff --git a/drivers/staging/lustre/
> lustre/obdclass/class_obd.c
> >       b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> >       >>> index 2b21675..b775c74 100644
> >       >>> --- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
> >       >>> +++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
> >       >>> @@ -345,7 +345,7 @@ int class_handle_ioctl(unsigned int cmd,
> unsigned long arg)
> >       >>>                     goto out;
> >       >>>             }
> >       >>>             obd = class_name2obd(data->ioc_inlbuf4);
> >       >>> -   } else if (data->ioc_dev < class_devno_max()) {
> >       >>> +   } else if (data->ioc_dev < MAX_OBD_DEVICES) {
> >       >>>             obd = class_num2obd(data->ioc_dev);
> >       >>>     } else {
> >       >>>             CERROR("OBD ioctl: No device\n");
> >       >>> @@ -498,7 +498,7 @@ static int __init obdclass_init(void)
> >       >>>     }
> >       >>>
> >       >>>     /* This struct is already zeroed for us (static global) */
> >       >>> -   for (i = 0; i < class_devno_max(); i++)
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++)
> >       >>>             obd_devs[i] = NULL;
> >       >>
> >       >> This block can just be removed entirely.  It used to do
> something useful,
> >       >> but through a series of changes it has become useless.
> >       >>
> >       >> Cheers, Andreas
> >       >>
> >       >>>     /* Default the dirty page cache cap to 1/2 of system
> memory.
> >       >>> @@ -548,7 +548,7 @@ static void obdclass_exit(void)
> >       >>>     lustre_unregister_fs();
> >       >>>
> >       >>>     misc_deregister(&obd_psdev);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd = class_num2obd(i);
> >       >>>
> >       >>>             if (obd && obd->obd_set_up &&
> >       >>> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c
> >       b/drivers/staging/lustre/lustre/obdclass/genops.c
> >       >>> index 99c2da6..af4fc58 100644
> >       >>> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> >       >>> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> >       >>> @@ -290,7 +290,7 @@ struct obd_device *class_newdev(const char
> *type_name, const char *name)
> >       >>>     LASSERT(newdev->obd_magic == OBD_DEVICE_MAGIC);
> >       >>>
> >       >>>     write_lock(&obd_dev_lock);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd = class_num2obd(i);
> >       >>>
> >       >>>             if (obd && (strcmp(name, obd->obd_name) == 0)) {
> >       >>> @@ -322,9 +322,9 @@ struct obd_device *class_newdev(const char
> *type_name, const char *name)
> >       >>>     }
> >       >>>     write_unlock(&obd_dev_lock);
> >       >>>
> >       >>> -   if (!result && i >= class_devno_max()) {
> >       >>> +   if (!result && i >= MAX_OBD_DEVICES) {
> >       >>>             CERROR("all %u OBD devices used, increase
> MAX_OBD_DEVICES\n",
> >       >>> -                  class_devno_max());
> >       >>> +                  MAX_OBD_DEVICES);
> >       >>>             result = ERR_PTR(-EOVERFLOW);
> >       >>>             goto out;
> >       >>>     }
> >       >>> @@ -372,7 +372,7 @@ int class_name2dev(const char *name)
> >       >>>             return -1;
> >       >>>
> >       >>>     read_lock(&obd_dev_lock);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd = class_num2obd(i);
> >       >>>
> >       >>>             if (obd && strcmp(name, obd->obd_name) == 0) {
> >       >>> @@ -397,7 +397,7 @@ struct obd_device *class_name2obd(const
> char *name)
> >       >>> {
> >       >>>     int dev = class_name2dev(name);
> >       >>>
> >       >>> -   if (dev < 0 || dev > class_devno_max())
> >       >>> +   if (dev < 0 || dev > MAX_OBD_DEVICES)
> >       >>>             return NULL;
> >       >>>     return class_num2obd(dev);
> >       >>> }
> >       >>> @@ -408,7 +408,7 @@ int class_uuid2dev(struct obd_uuid *uuid)
> >       >>>     int i;
> >       >>>
> >       >>>     read_lock(&obd_dev_lock);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd = class_num2obd(i);
> >       >>>
> >       >>>             if (obd && obd_uuid_equals(uuid, &obd->obd_uuid)) {
> >       >>> @@ -435,7 +435,7 @@ struct obd_device *class_num2obd(int num)
> >       >>> {
> >       >>>     struct obd_device *obd = NULL;
> >       >>>
> >       >>> -   if (num < class_devno_max()) {
> >       >>> +   if (num < MAX_OBD_DEVICES) {
> >       >>>             obd = obd_devs[num];
> >       >>>             if (!obd)
> >       >>>                     return NULL;
> >       >>> @@ -463,7 +463,7 @@ struct obd_device
> *class_find_client_obd(struct obd_uuid *tgt_uuid,
> >       >>>     int i;
> >       >>>
> >       >>>     read_lock(&obd_dev_lock);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd = class_num2obd(i);
> >       >>>
> >       >>>             if (!obd)
> >       >>> @@ -496,13 +496,13 @@ struct obd_device
> *class_devices_in_group(struct obd_uuid *grp_uuid, int
> >       *next)
> >       >>>
> >       >>>     if (!next)
> >       >>>             i = 0;
> >       >>> -   else if (*next >= 0 && *next < class_devno_max())
> >       >>> +   else if (*next >= 0 && *next < MAX_OBD_DEVICES)
> >       >>>             i = *next;
> >       >>>     else
> >       >>>             return NULL;
> >       >>>
> >       >>>     read_lock(&obd_dev_lock);
> >       >>> -   for (; i < class_devno_max(); i++) {
> >       >>> +   for (; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd = class_num2obd(i);
> >       >>>
> >       >>>             if (!obd)
> >       >>> @@ -533,7 +533,7 @@ int class_notify_sptlrpc_conf(const char
> *fsname, int namelen)
> >       >>>     LASSERT(namelen > 0);
> >       >>>
> >       >>>     read_lock(&obd_dev_lock);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             obd = class_num2obd(i);
> >       >>>
> >       >>>             if (!obd || obd->obd_set_up == 0 ||
> obd->obd_stopping)
> >       >>> diff --git a/drivers/staging/lustre/
> lustre/obdclass/linux/linux-module.c
> >       b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
> >       >>> index 33342bf..ca5b466 100644
> >       >>> --- a/drivers/staging/lustre/lustre/obdclass/linux/linux-
> module.c
> >       >>> +++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-
> module.c
> >       >>> @@ -228,7 +228,7 @@ static ssize_t health_show(struct kobject
> *kobj, struct attribute *attr,
> >       >>>             return sprintf(buf, "LBUG\n");
> >       >>>
> >       >>>     read_lock(&obd_dev_lock);
> >       >>> -   for (i = 0; i < class_devno_max(); i++) {
> >       >>> +   for (i = 0; i < MAX_OBD_DEVICES; i++) {
> >       >>>             struct obd_device *obd;
> >       >>>
> >       >>>             obd = class_num2obd(i);
> >       >>> @@ -326,7 +326,7 @@ static struct attribute *lustre_attrs[] = {
> >       >>>
> >       >>> static void *obd_device_list_seq_start(struct seq_file *p,
> loff_t *pos)
> >       >>> {
> >       >>> -   if (*pos >= class_devno_max())
> >       >>> +   if (*pos >= MAX_OBD_DEVICES)
> >       >>>             return NULL;
> >       >>>
> >       >>>     return pos;
> >       >>> @@ -339,7 +339,7 @@ static void obd_device_list_seq_stop(struct
> seq_file *p, void *v)
> >       >>> static void *obd_device_list_seq_next(struct seq_file *p,
> void *v, loff_t *pos)
> >       >>> {
> >       >>>     ++*pos;
> >       >>> -   if (*pos >= class_devno_max())
> >       >>> +   if (*pos >= MAX_OBD_DEVICES)
> >       >>>             return NULL;
> >       >>>
> >       >>>     return pos;
> >       >>> --
> >       >>> 2.5.0
> >       >>>
> >       >>>
> >       >>> --
> >       >>> Kind Regards,
> >       >>> Aya Saif El-yazal Mahfouz
> >       >>> _______________________________________________
> >       >>> lustre-devel mailing list
> >       >>> lustre-devel at lists.lustre.org
> >       >>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >       >>
> >       >
> >       > --
> >       > Kind Regards,
> >       > Aya Saif El-yazal Mahfouz
> >       > _______________________________________________
> >       > lustre-devel mailing list
> >       > lustre-devel at lists.lustre.org
> >       > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >
> >
> >
> >
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161107/7b00ce41/attachment-0001.htm>
