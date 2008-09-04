From: Peter Braam <Peter.Braam@Sun.COM>
Date: Thu, 04 Sep 2008 09:59:24 +0200
Subject: [Lustre-devel] Summary of our HSM discussion
In-Reply-To: <48BEFA77.8020708@fnal.gov>
Message-ID: <C4E561FC.7800%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 9/3/08 10:58 PM, "Alex Kulyavtsev" <aik@fnal.gov> wrote:

> Hello,
> sorry for breaking into discussion. Please find inlined
> 
> Nathaniel Rutman wrote:
>> Rick Matthews wrote:
>>   
>>> On 08/29/08 15:38, Nathaniel Rutman wrote:
>>>     
> (Snip)
>>> 
>>>> We'll have to add a flag into the lov_ea indicating "in HSM", and
>>>> then block for file retrieval (#2).
>>>>       
>>> Correct...with a small twist...the HSM holds copies of data even when
>>> they continue to exist in native disk. The "release" of this space
>>> then doesn't need to
>>> wait for a slower data mover. So, change "in HSM" to "only in HSM" and
>>> you are correct.
>>>     
>> right, that's what I had in mind.
>>   
> - What is definition of "ONLY in HSM" ?
> - Are these flags exposed to end user ?

They will be extended attributes accessible with the xattr utilities.

If there is a standard for such attributes, we should use it to avoid
introducing yet another set of product specific attributes.

> 
> Consider use case :
> User has someFile striped across two osts:  OST1 and OST2. File is in
> HSM as well.
> OST2 is down. User reads the file and reaches stripe residing on OST2
> (or open() checks ost status )
> In this case it will be nice to stage file from tape as a whole or only
> stripes residing on OST2.
> Also, when OST2 restarts it shall remove stale stripes and MDT points to
> right OST set after retrieval.
> I realize it makes things more complicated and adds more triggers to #2
> for file retrieval.

Nice idea, but building this into the FS is really a refinement that we
should not be going after too soon.  When OST2 returns to the cluster, we
have cleanup work, and building all the administration infrastructure for
this is a lot of work.

With a copy_from_hsm command users should be able to do this.

Lsxattr <pathname> -- see file is on tape
Lfs getfid <pathname> -- get its fid
Copy_from_hsm <fid> <path> -- copy it in

> 
> Back to flags definition :
> Thus staging from tape may be triggered by several conditions including
>  (  File_is_Resident ) and (File_is_in_HSM) and (OST_is_Not_Available)
> in addition to
>  ( ! File_is_Resident ) and (File_is_in_HSM)
> 
> It may worth to keep flags  (File_is_Resident) and (File_is_in_HSM)
> separate  as 
> "File_is_in_HSM" is a fundamental file property indicating "permanent"
> storage of the file and other flags reflect file state (file is resident
> on disk)
> or transient condition (ost is down).

Reminder: File_is_in_HSM needs to be cleared if the file changes again.
Files change on the OSS, not on the MDS, where are the flags? We can trust
version propagation from OSS to MDS only when SOM is present.

> 
> The other use case when end user writes file to lustre/HSM system and
> waits till file reaches the tape before deleting the original while
> checking file status time to time.

Yes.

> It can be done if "File_is_in_HSM" flag is exposed to end user by some
> command or if  HSM fileID is set in EA.

The HSM fileID will NOT be in the EA at all.  The flag can be exposed.

> In this case user wants to know "is in hsm" part of the flag regardless
> "file is resident on disk". Keeping flags separate will help with logic
> and synchronization.

We want a flag file is NOT resident on disk, since otherwise we need to tag
all files, but that is a detail.

Peter

> 
> Best regards, Alex.
> 
> (snip)
>>>> Peter Braam wrote:
>>>>       
>>>>> The steps to reach a first implementation can be summarized as:
>>>>> 
>>>>>    1. Include file closes in the changelog, if the file was opened for
>>>>>       write. Include timestamps in the changelog entries. This allows
>>>>>       the changelog processor to see files that have become inactive
>>>>>       and pass them on for archiving.
>>>>>    2. Build an open call that blocks for file retrieval and adapts
>>>>>       timeouts to avoid error returns.
>>>>>    3. Until a least-recently-used log is built, use the e2scan utility
>>>>>       to generate lists of candidates for purging.
>>>>>    4. Translate events and scan results into a form that they can be
>>>>>       understood by ADM.
>>>>>    5. Work with a single coordinator, whose role it is to avoid
>>>>>       getting multiple ?close? records for the same file (a basic
>>>>>       filter for events).
>>>>>    6. Do not use initiators ? these can come later and assist with
>>>>>       load balancing and free-ing space on demand (both of which we
>>>>>       can ignore for the first release)
>>>>>    7. Do not use multiple agents ? the agents can move stripes of
>>>>>       files etc, and this is not needed with a basic user level
>>>>>       solution, based on consuming the log. The only thing the agent
>>>>>       must do in release one is get the attention of a data mover to
>>>>>       restore files on demand.
>>>>> 
>>>>> 
>>>>> Peter
>>>>> ------------------------------------------------------------------------
>>>>> 
>>>>> 
>>>>> _______________________________________________
>>>>> Lustre-devel mailing list
>>>>> Lustre-devel at lists.lustre.org
>>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>>   
>>>>>         
>>>     
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>   
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
