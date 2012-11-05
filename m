From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Mon, 05 Nov 2012 10:42:29 -0800
Subject: [Lustre-devel] Control file striping
In-Reply-To: <2C7DE72B9BD00F44BAECA5B0CBB87395022AD490@hermes.terascala.com>
References: <CANuO2dvubpiw79KC_svR7HoGZ2XRrWJ=g4gGgeHjniuyh0YHhg@mail.gmail.com>
	<DE176288-9AC9-454F-89D2-8F1098400418@ornl.gov>
	<2C7DE72B9BD00F44BAECA5B0CBB87395022AD490@hermes.terascala.com>
Message-ID: <50980895.6010809@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Pools only address one kind of problem:  constraining object allocation 
to a set of OSTs.

But what if the user wants to guarantee that their files' objects are 
evenly distributed across the OSTs, whether in a pool or not?  Even a 
slight unevenness in object allocation (one OST getting more objects 
than the others) can drastically change the apparent aggregate 
throughput that the user sees.

Most of the applications that I am aware of essentially do:

   compute
   barrier
   write files
   barrier
   repeat

So any unevenness of object allocation means that the entire application 
sits and waits for that one OST that is more heavily loaded than the rest.

Which generally means for us that Lustre's object allocation algorithms 
that attempt to provide space-balancing have noticeably negative impacts 
on application performance.

So I agree that I would like to see the set-stripe API and wire 
protocols expanded to allow specifying all of the desired object 
indices, not just the first one.

It would probably be good to make the use of the ability to manually set 
object locations permission-based, and allow the sysadmin to decide if 
users can use that functionality.  Best would be if they could set it on 
a per-user basis, but I'd settle for a single large on/off switch.

Chris

On 11/05/2012 09:57 AM, Ben Evans wrote:
> Have you considered using a combination of OST Pools and striping fit
> your needs?
>
> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org
> [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Atchley,
> Scott
> Sent: Monday, November 05, 2012 12:47 PM
> To: Kalyana C
> Cc: lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] Control file striping
>
> On Nov 3, 2012, at 1:41 PM, Kalyana C <ckkccf@gmail.com> wrote:
>
>> Hello,
>>
>> I am trying to figure out a way to:
>>
>> set striping across a set of OSTs of my choice.
>>
>> lfs setstripe command and API call does not allow for this currently.
> The user can only set the starting OST through the index parameter. I
> appreciate why there is no such feature currently; you do not want to
> let the users have control on how OSTs are used since it can result in
> OST usage imbalance.
>>
>> However, I do have a valid usage case for such a feature and I am
> trying to figure out the best way to do it.
>
> I have a valid use for it as well. It would be nice to have this feature
> back.
>
> Scott
>
>>
>> One way to achieve the same result is through the use of OST pools.
> However, the userland tools do not work from a client node, it has to be
> run on the MGS. There are also other restrictions as described here:
> http://wiki.lustre.org/index.php/Creating_and_Managing_OST_Pools
>>
>> I am also digging through the Lustre source and header files to see if
> there are other (undocumented) ways to do this.
>>
>> So, my questions are as follows:
>>
>> 1) Is there currently a way for a user to control the striping of a
> file / directory on a selected set of OSTs? If yes, is it possible to do
> it through an API call or a command line utility?
>>
>> 2) If answer to (1) is No, Is there a way to do this with admin rights
> from the MDS or client nodes?
>>
>> 3) If pools are the only way to achieve this, is there an API call to
> create, manage and destroy pools from a user application? Is there any
> impact on performance of MDS components if pools are dynamically created
> and deleted on demand? Can the API be called from a client node (root or
> user) or does it have to be on the MGS?
>>
>> Thank you.
>>
>> Regards,
>> Kalyana Chadalavada
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> .
>
