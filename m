From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Tue, 6 Nov 2018 11:41:56 +0100
Subject: [lustre-devel] [PATCH v2] lustre: mdc: fix possible deadlock in
 chlg_open()
In-Reply-To: <87wopqyk5h.fsf@notabene.neil.brown.name>
References: <87bm7a3nue.fsf@notabene.neil.brown.name>
 <7db27e7d-e685-af8f-80d8-891a0d8db4d5@cea.fr>
 <875zxh3elu.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1811042131490.27308@casper.infradead.org>
 <88ccd141-4778-e3ab-3ce0-e7cbd5c290fc@cea.fr>
 <87wopqyk5h.fsf@notabene.neil.brown.name>
Message-ID: <a513884a-046f-a28c-3fbb-dd112abd4b26@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 06/11/2018 ? 04:11, NeilBrown a ?crit?:
> On Mon, Nov 05 2018, quentin.bouget at cea.fr wrote:
>
>> Le 04/11/2018 ? 22:34, James Simmons a ?crit?:
>>>> Lockdep reports a possible deadlock between chlg_open() and
>>>> mdc_changelog_cdev_init()
>>>>
>>>> mdc_changelog_cdev_init() takes chlg_registered_dev_lock and then
>>>> calls misc_register() which takes misc_mtx.
>>>> chlg_open() is called while misc_mtx is held, and tries to take
>>>> chlg_registered_dev_lock.
>>>> If these two functions race, a deadlock can occur as each thread will
>>>> hold one of the locks while trying to take the other.
>>>>
>>>> chlg_open() does not need to take a lock.  It only uses the
>>>> lock to stablize a list while looking for the matching
>>>> chlg_registered_dev, and this can be found directly by examining
>>>> file->private_data.
>>>>
>>>> So remove chlg_obd_get(), and use file->private_data to find the
>>>> obd_device.
>>>> Also ensure the device is fully initialized before calling
>>>> misc_register().  This means setting up some list linkage before the
>>>> call, and tearing it down if there is an error.
>>> I have been testing this but I'm no HSM expert. I pushed this patch
>>> to OpenSFS branch as well.
>>>
>>> https://jira.whamcloud.com/browse/LU-11617
>>> https://review.whamcloud.com/#/c/33572/
>>>
>>> Reviewed-by: James Simmons <jsimmons@infradead.org>
>> Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
>>
> Thanks to you both for the review.
>
> NeilBrown
>
Wait! I just realised there might be another issue!
I think there is now a race between chlg_open() and 
mdc_changelog_cdev_finish().

Wait! I just realised there might be another bigger issue!
The whole "take the first obd you can find" is broken! I opened a ticket 
<https://jira.whamcloud.com/browse/LU-11626> on whamcloud's JIRA about it.

Quentin Bouget

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181106/bad9cdb2/attachment-0001.html>
