From: Peng Tao <bergwolf@gmail.com>
Date: Sat, 18 Feb 2012 13:00:47 +0800
Subject: [Lustre-devel] [wc-discuss] Lustre 2.3 release
In-Reply-To: <73AED5C780AE05478241DB067651A92102F107C3@XYUS-EX22.xyus.xyratex.com>
References: <4F304E2E.9080100@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805E803BB5C@MX09A.corp.emc.com>
	<73AED5C780AE05478241DB067651A92102F107C3@XYUS-EX22.xyus.xyratex.com>
Message-ID: <CA+a=Yy69UCXBngMqUVg79DXOHwB5bY_o0Zt08JD-Kpb_4WKB0Q@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Feb 18, 2012 at 5:48 AM, Nathan Rutman
<Nathan_Rutman@xyratex.com> wrote:
>
> On Feb 15, 2012, at 6:15 PM, <tao.peng@emc.com> <tao.peng@emc.com> wrote:
>
>> Hi Peter,
>>
>> Thanks for bringing it up. As the target date for 2.3 is September 2012, I'd like to add some EMC tasks (not necessary features though) that we hope to land in 2.3 release cycle. Please consider including them in your planning.
>>
>> 1. remove obsolete configure macros that are there to support old kernels (older than 2.6.18-latest)
>> 2. Lustre client dcache clean up
>> 3. separate server connection handling from ptlrpc layer
> Can you explain a little more about this one?
Our purpose is to clean up Lustre client to some extent that we can
push it into upstream Linux kernel. And per discussion with Andreas,
we want to split some server code dependency from client so that we
don't need dive deep into server code.

Cheers,
Tao

>
>> 4. client kernel API adjustment to latest upstream kernel
>> 5. client module build process change to adapt to vanilla kernel
>>
>> Cheers,
>> Tao
>>
>>> -----Original Message-----
>>> From: Peter Jones [mailto:pjones at whamcloud.com]
>>> Sent: Tuesday, February 07, 2012 6:03 AM
>>> To: cdwg at lists.opensfs.org; wc-discuss at whamcloud.com
>>> Subject: [wc-discuss] Lustre 2.3 release
>>>
>>> Hi there
>>>
>>> Although we are still very busy with Lustre 2.2, we have started
>>> planning for the content of Lustre 2.3 release. Landings for 2.3 will
>>> start as soon as Lustre 2.2 has been branched from master.
>>>
>>> Lustre 2.3 is targeted for release in September 2012 and, as such, any
>>> features to be included will need to be landed to master by the end of
>>> June at the latest in order to allow adequate time for stabilization
>>> ahead of the release. If features only become ready for landing at the
>>> end of June there may not be sufficient time to land them all, so
>>> features that are available sooner are more likely to be tested,
>>> inspected, and landed before the feature freeze.
>>>
>>> If anyone is working on features that could be candidates to include in
>>> this release then please let me know so that we can consider them in our
>>> planning.
>>>
>>> Features that were initially targeted for 2.2 but were not ready in time
>>> are already on our list -
>>> http://wiki.whamcloud.com/display/PUB/Lustre+Community+Development+in+Progress
>>>
>>> Thanks
>>>
>>> Peter
>>>
>>> --
>>> Peter Jones
>>> Whamcloud, Inc.
>>> www.whamcloud.com
>>>
>>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
