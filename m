From: Alex Kulyavtsev <aik@fnal.gov>
Date: Wed, 03 Sep 2008 15:58:31 -0500
Subject: [Lustre-devel] Summary of our HSM discussion
In-Reply-To: <48B87B46.8050200@sun.com>
References: <C4BCA140.5486%peter.braam@sun.com> <48B85E2D.8000109@sun.com>
	<48B86F3C.9080909@Sun.COM> <48B87B46.8050200@sun.com>
Message-ID: <48BEFA77.8020708@fnal.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,
sorry for breaking into discussion. Please find inlined

Nathaniel Rutman wrote:
> Rick Matthews wrote:
>   
>> On 08/29/08 15:38, Nathaniel Rutman wrote:
>>     
(Snip)
>>
>>> We'll have to add a flag into the lov_ea indicating "in HSM", and 
>>> then block for file retrieval (#2).
>>>       
>> Correct...with a small twist...the HSM holds copies of data even when 
>> they continue to exist in native disk. The "release" of this space 
>> then doesn't need to
>> wait for a slower data mover. So, change "in HSM" to "only in HSM" and 
>> you are correct.
>>     
> right, that's what I had in mind.
>   
- What is definition of "ONLY in HSM" ?
- Are these flags exposed to end user ?

Consider use case :
User has someFile striped across two osts:  OST1 and OST2. File is in 
HSM as well.
OST2 is down. User reads the file and reaches stripe residing on OST2 
(or open() checks ost status )
In this case it will be nice to stage file from tape as a whole or only 
stripes residing on OST2.
Also, when OST2 restarts it shall remove stale stripes and MDT points to 
right OST set after retrieval.
I realize it makes things more complicated and adds more triggers to #2  
for file retrieval.

Back to flags definition :
Thus staging from tape may be triggered by several conditions including
 (  File_is_Resident ) and (File_is_in_HSM) and (OST_is_Not_Available)
in addition to
 ( ! File_is_Resident ) and (File_is_in_HSM)

It may worth to keep flags  (File_is_Resident) and (File_is_in_HSM) 
separate  as 
"File_is_in_HSM" is a fundamental file property indicating "permanent" 
storage of the file and other flags reflect file state (file is resident 
on disk)
or transient condition (ost is down).

The other use case when end user writes file to lustre/HSM system and 
waits till file reaches the tape before deleting the original while 
checking file status time to time.
It can be done if "File_is_in_HSM" flag is exposed to end user by some 
command or if  HSM fileID is set in EA.
In this case user wants to know "is in hsm" part of the flag regardless 
"file is resident on disk". Keeping flags separate will help with logic 
and synchronization.

Best regards, Alex.

(snip)
>>> Peter Braam wrote:
>>>       
>>>> The steps to reach a first implementation can be summarized as:
>>>>
>>>>    1. Include file closes in the changelog, if the file was opened for
>>>>       write. Include timestamps in the changelog entries. This allows
>>>>       the changelog processor to see files that have become inactive
>>>>       and pass them on for archiving.
>>>>    2. Build an open call that blocks for file retrieval and adapts
>>>>       timeouts to avoid error returns.
>>>>    3. Until a least-recently-used log is built, use the e2scan utility
>>>>       to generate lists of candidates for purging.
>>>>    4. Translate events and scan results into a form that they can be
>>>>       understood by ADM.
>>>>    5. Work with a single coordinator, whose role it is to avoid
>>>>       getting multiple ?close? records for the same file (a basic
>>>>       filter for events).
>>>>    6. Do not use initiators ? these can come later and assist with
>>>>       load balancing and free-ing space on demand (both of which we
>>>>       can ignore for the first release)
>>>>    7. Do not use multiple agents ? the agents can move stripes of
>>>>       files etc, and this is not needed with a basic user level
>>>>       solution, based on consuming the log. The only thing the agent
>>>>       must do in release one is get the attention of a data mover to
>>>>       restore files on demand.
>>>>
>>>>
>>>> Peter
>>>> ------------------------------------------------------------------------ 
>>>>
>>>>
>>>> _______________________________________________
>>>> Lustre-devel mailing list
>>>> Lustre-devel at lists.lustre.org
>>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>>   
>>>>         
>>     
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
