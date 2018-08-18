From: Andreas Dilger <adilger@whamcloud.com>
Date: Sat, 18 Aug 2018 05:08:30 +0000
Subject: [lustre-devel] [PATCH 32/38] lustre: osc: restore
 cl_loi_list_lock
In-Reply-To: <alpine.LFD.2.21.1808180136341.2829@casper.infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-33-git-send-email-jsimmons@infradead.org>
 <87sh3dqwkm.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1808180136341.2829@casper.infradead.org>
Message-ID: <483E9D1A-7BC8-4492-B3F4-1E4D572C3562@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Aug 17, 2018, at 18:59, James Simmons <jsimmons@infradead.org> wrote:
> 
> 
>>> Access to struct client_obd should be protected with the spinlock
>>> cl_loi_list_lock. This was dropped during the port to sysfs so
>>> restore the proper locking.
>>> 
>>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>>> ---
>>> drivers/staging/lustre/lustre/osc/lproc_osc.c | 36 +++++++++++++++++++++++----
>>> 1 file changed, 31 insertions(+), 5 deletions(-)
>>> 
>>> diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
>>> index 3c31e98..5fb7a16 100644
>>> --- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
>>> +++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
>>> @@ -80,8 +80,13 @@ static ssize_t max_rpcs_in_flight_show(struct kobject *kobj,
>>> 	struct obd_device *dev = container_of(kobj, struct obd_device,
>>> 					      obd_kset.kobj);
>>> 	struct client_obd *cli = &dev->u.cli;
>>> +	ssize_t len;
>>> 
>>> -	return sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
>>> +	spin_lock(&cli->cl_loi_list_lock);
>>> +	len = sprintf(buf, "%u\n", cli->cl_max_rpcs_in_flight);
>>> +	spin_unlock(&cli->cl_loi_list_lock);
>> 
>> Why do you think a spinlock is needed here?
>> How could you even end up with an incorrect value?
> 
> I see both mdc sysfs and the osc sysfs layer being able to
> modify cl_max_rpcs_in_flight. Andreas is the struct client_obd
> shared between both the osc and mdc layer or does each subsystem
> contain a unique cli in struct obd_device?

Each OBD device (OSC, MDC, MGC, etc) has its own struct obd_device
with an embedded struct client_obd, so it is not shared between the
OSC and MDC.  These tunables could potentially be set differently
for each filesystem, or even for each target within a single filesystem
(e.g. if some flash OSTs need more RPCs in flight to keep busy than
HDD-based OSTs).

Since this is just printing the value, it doesn't make sense to have
locking in any case.  At worst the cl_max_rpcs_in_flight value used
may ne nanoseconds out of date when accessed, and microseconds old
when printed.  That race exists whether the locking is here or not
(i.e. the value could be changed immediately after it is printed into
the buffer and the lock is dropped).

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 235 bytes
Desc: Message signed with OpenPGP
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180818/7a46220c/attachment.sig>
