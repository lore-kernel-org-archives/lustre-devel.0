From: Atchley, Scott <atchleyes@ornl.gov>
Date: Mon, 5 Nov 2012 13:28:06 -0500
Subject: [Lustre-devel] Control file striping
In-Reply-To: <F46703DD-5873-4FB4-AFCE-059E868B4D6B@intel.com>
References: <CANuO2dvubpiw79KC_svR7HoGZ2XRrWJ=g4gGgeHjniuyh0YHhg@mail.gmail.com>
	<DE176288-9AC9-454F-89D2-8F1098400418@ornl.gov>
	<2C7DE72B9BD00F44BAECA5B0CBB87395022AD490@hermes.terascala.com>
	<CANuO2dvGUgK=PB50P3ZG-rEMFv2WkHYQwaT6uD=0rf2MVgbAcA@mail.gmail.com>
	<F46703DD-5873-4FB4-AFCE-059E868B4D6B@intel.com>
Message-ID: <FCE48434-4A4E-481C-BB3C-FB31F1527B6B@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 5, 2012, at 1:16 PM, "White, Cliff" <cliff.white@intel.com> wrote:

> Creating/destroying pools must be done as per the manual, from MDS.
> Do you need to frequently create/destroy pools, or would you have a fixed setup?

In our case, we need to frequently change the OSTs. Possibly per file.

Scott

> 
> The normal method is to map various pools (and other striping policies) to directories, then user space applications
> can access specific pools by pointing at the requisite directory, thus requiring no special API.
> Once pools are created, the directory creation/striping is all done on a client via lfs setstripe, the liblustreapi can
> also be used by clients to set striping via C calls.
> 
> Best
> cliffw
> 
> 
> On Nov 5, 2012, at 10:01 AM, Kalyana C <ckkccf at gmail.com<mailto:ckkccf@gmail.com>>
> wrote:
> 
>> Have you considered using a combination of OST Pools and striping fit your needs?
> 
> This is the only way possible that I currently know of.
> 
> But is it possible to manage OST pools via an API call? Can it be done from a client under a normal user application? Or does it have the same restrictions as described at http://wiki.lustre.org/index.php/Creating_and_Managing_OST_Pools
> 
> Regards,
> Kalyan
> 
> On Mon, Nov 5, 2012 at 11:57 AM, Ben Evans <Ben.Evans at terascala.com<mailto:Ben.Evans@terascala.com>> wrote:
> Have you considered using a combination of OST Pools and striping fit
> your needs?
> 
> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>
> [mailto:lustre-devel-bounces at lists.lustre.org<mailto:lustre-devel-bounces@lists.lustre.org>] On Behalf Of Atchley,
> Scott
> Sent: Monday, November 05, 2012 12:47 PM
> To: Kalyana C
> Cc: lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
> Subject: Re: [Lustre-devel] Control file striping
> 
> On Nov 3, 2012, at 1:41 PM, Kalyana C <ckkccf at gmail.com<mailto:ckkccf@gmail.com>> wrote:
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
>> Lustre-devel at lists.lustre.org<mailto:Lustre-devel@lists.lustre.org>
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org<mailto:Lustre-devel@lists.lustre.org>
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org<mailto:Lustre-devel@lists.lustre.org>
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
