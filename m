From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Fri, 31 Jan 2020 18:29:35 +0100
Subject: [lustre-devel] Gerrit option - build only one backend
In-Reply-To: <E2EFBD04-9291-42CC-83C6-8B250066144E@whamcloud.com>
References: <1580240254.12827.0@informatik.uni-hamburg.de>
 <102CE8C0-6E14-44C1-9189-FF8A0C50EE56@whamcloud.com>
 <e8468652-a564-ba4f-cf30-80f6dd21dfc5@informatik.uni-hamburg.de>
 <E2EFBD04-9291-42CC-83C6-8B250066144E@whamcloud.com>
Message-ID: <1580491775.5117.0@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Ok, I will see which way is better, thanks a lot.

Regards Anna

On Wed, Jan 29, 2020 at 6:51 PM, Andreas Dilger <adilger@whamcloud.com> 
wrote:
> You could potentially include a change in your patch series to always 
> disable ldiskfs building, probably in config/lustre-build-ldiskfs.m4.
> 
> It would be best if that was a separate patch with a description like 
> "osd-ldiskfs: permanently disable building" and tagged "forbuildonly" 
> so that it cannot be landed.
> 
> Cheers, Andreas
> 
>>  On Jan 29, 2020, at 07:18, Anna Fuchs 
>> <anna.fuchs@informatik.uni-hamburg.de 
>> <mailto:anna.fuchs@informatik.uni-hamburg.de>> wrote:
>> 
>>  ?I see, but are there any "build-parameters" I can set? I haven't 
>> seen anything like that in another commits.
>> 
>>  I want to prevent the osd-ldiskfs to be built since my stuff 
>> involves experimental interface changes for the backend and this 
>> build will fail at the moment.
>> 
>>  None of the tests will run if any build fails, am I right? I wanted 
>> to have first some reviews before I change everything.
>> 
>>  So either I (currently unnecessarily) adjust the ldiskfs path just 
>> for the build to pass or.. is there any or?
>> 
>>  Thanks,
>> 
>>  Anna
>> 
>>>  Am 28.01.2020 um 21:36 schrieb Andreas Dilger:
>>>  The fstype option affects the testing, because this is 
>>> "Test-Parameters:", not "Build-Parameters:". :-)
>>> 
>>>  The zfs vs. ldiskfs option mostly only affects the osd-ldiskfs and 
>>> oss-zfs, and the matching mount.lustre helpers. All of the rest of 
>>> the code should be independent of the backing filesystem.
>>> 
>>>  Cheers, Andreas
>>> 
>>>>>  On Jan 28, 2020, at 12:37, Anna Fuchs 
>>>>> <anna.fuchs@informatik.uni-hamburg.de 
>>>>> <mailto:anna.fuchs@informatik.uni-hamburg.de>> wrote:
>>>> 
>>>>  ?
>>>>  Dear all,
>>>> 
>>>>  I am wondering why the Gerrit option "fstype=zfs" in my commit 
>>>> does not influence the build process - both targets, ldiskfs and 
>>>> zfs are built:
>>>> 
>>>>  checking whether to build ldiskfs... yes
>>>>  checking whether to enable zfs... yes
>>>> 
>>>>  The option seems to affect only the following tests. Is this 
>>>> behavior intended?
>>>>  Is there any option to build and test only one backend?
>>>> 
>>>>  Regards
>>>>  Anna
>>>>  _______________________________________________
>>>>  lustre-devel mailing list
>>>>  lustre-devel at lists.lustre.org 
>>>> <mailto:lustre-devel@lists.lustre.org>
>>>>  <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>
>> 
>>  --
>>  Anna Fuchs
>>  Universit?t Hamburg
>>  https://wr.informatik.uni-hamburg.de 
>> <https://wr.informatik.uni-hamburg.de/>
>> 
>>  anna.fuchs at informatik.uni-hamburg.de 
>> <mailto:anna.fuchs@informatik.uni-hamburg.de>
>>  <https://wr.informatik.uni-hamburg.de/people/anna_fuchs>
>> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200131/8d161dab/attachment.html>
