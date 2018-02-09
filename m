From: =?utf-8?B?0JHQu9Cw0LPQvtC00LDRgNC10L3QutC+INCQ0YDRgtGR0Lw=?= <artem.blagodarenko@gmail.com>
Date: Fri, 9 Feb 2018 11:51:52 +0300
Subject: [lustre-devel] testing lustre
In-Reply-To: <87tvurkm9e.fsf@notabene.neil.brown.name>
References: <151538168618.23920.8261096424342988792.stgit@noble>
 <20180108145943.GA5761@kroah.com>
 <alpine.LFD.2.21.1801081607120.1698@casper.infradead.org>
 <87po5gmqph.fsf@notabene.neil.brown.name>
 <94546355-FD93-4B50-AC98-4AB38EDC9BF0@gmail.com>
 <87tvurkm9e.fsf@notabene.neil.brown.name>
Message-ID: <3C5A4767-EBDC-42C0-9A46-46C8356C5067@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello NeilBrown,


> On 9 Feb 2018, at 04:03, NeilBrown <neilb@suse.com> wrote:
> 
> On Thu, Feb 08 2018, ???????????? ????? wrote:
> 
>> Hello NeilBrown,
>> 
>> Symbol ?:? is added to name for targets which have never been registered. tunefs and mount use this symbol to
>> set LDD_F_VIRGIN flag in ldd.
>> 
>> Here is code from lustre/utils/mkfs_lustre.c (executed in tunefs)
>> 
>> /* svname of the form lustre:OST1234 means never registered */
>>        ret = strlen(ldd->ldd_svname);
>>        if (ldd->ldd_svname[ret - 8] == ':') {
>>                ldd->ldd_svname[ret - 8] = '-';
>>                ldd->ldd_flags |= LDD_F_VIRGIN;
>> 
>> And 
>> 
>> lustre/utils/mount_lustre.c
>> 
>> /* svname of the form lustre:OST1234 means never registered */
>>        rc = strlen(ldd->ldd_svname);
>>        if (strcmp(ldd->ldd_svname, "MGS") != 0) {
>>                if (rc < 8) {
>>                        fprintf(stderr, "%s: invalid name '%s'\n",
>>                                progname, ldd->ldd_svname);
>>                        return EINVAL;
>>                } else if (ldd->ldd_svname[rc - 8] == ':') {
>>                        ldd->ldd_svname[rc - 8] = '-';
>>                        ldd->ldd_flags |= LDD_F_VIRGIN;
>> 
>> So I believe the test expects freshly created target.
> 
> Thanks for the reply.  This is helpful, but there is still something
> missing in my understanding.
> 
> At what stage does a filesystem transition from "VIRGIN" to "not
> VIRGIN???

To exclude misunderstanding let?s clarify - this is stage of target, not filesystem. 
At moment then target is formatted it is VIRGIN. Then it first time mounted it becomes not VIRGIN.

> When does the ":" get replaced by a "-" in the on-disk volume name?
> What, exactly, does it mean to be "registered? ?

At moment target is mounting it sends request to mgs and becomes registered. 
This is requirement for successful registration. After such successful first mount ?:? replaced to ?-? in the on-disk volume name. 

> I cannot find anywhere in the code that would write out a new label, or
> that would call e2label or tune2fs to do it.

mount utility (mount_lustre.c)
Main->
	parse_ldd() -> ldd() read ldd. In  and change : to - in memory
	mount() - mount target, register it on mgs
	label_lustre () write new label with ?-? on disk

> 
> Thanks,
> NeilBrown

Best regards,
Artem Blagodarenko
