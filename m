From: Peter Jones <pjones@whamcloud.com>
Date: Tue, 19 Jul 2011 05:34:03 -0700
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <alpine.LFD.2.01.1107191135050.22747@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
	<5870C1C1-3775-4CC8-B619-C79B6799D6E5@whamcloud.com>
	<alpine.LFD.2.01.1104270854090.20691@sys880.ldn.framestore.com>
	<3059315E-A6DA-4AC1-BEB9-B3AF7E48AC36@whamcloud.com>
	<alpine.LFD.2.01.1104271806090.9273@sys880.ldn.framestore.com>
	<001F682B-CF29-4835-8A0B-5BBFA4021715@whamcloud.com>
	<alpine.LFD.2.01.1107191135050.22747@sys880.ldn.framestore.com>
Message-ID: <4E2579BB.7070202@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mark

Sorry if Andreas was not clear enough about contributing patches. 
Hopefully the more detailed information at 
http://wiki.whamcloud.com/display/PUB/Submitting+Changes will help. If 
you are only able to work with 1.8.x then by all means upload the patch 
into gerrit and another engineer could handle porting it to master 
(subject to other priorities of course). IIRC Framestore did not sign a 
Sun\Oracle contributor agreement so I suspect Oracle will not land your 
patch.

Regards

Peter

On 11-07-19 3:41 AM, Mark Hills wrote:
> On Wed, 27 Apr 2011, Andreas Dilger wrote:
>
> [...]
>> for inclusion into the next 1.8 release the updated patch should be
>> attached to a new bug at bugzilla.lustre.org, and a review requested on
>> the patch (I can be one of the reviewers).  For inclusion into the 2.1
>> release, please create a new bug at jira.whamcloud.com with the updated
>> patch.  The patch should include the standard kernel "Signed-off-by:
>> {your name}<your email>" line.
>>
>> Sorry for the complexity in submitting patches while development
>> transitions away from Oracle for newer releases.
> Hi Andreas, I created an entry in Bugzilla with the revised patch attached
> to it:
>
>    https://bugzilla.lustre.org/show_bug.cgi?id=24536
>
> I wasn't able to add you as reviewer, because I could not clearly see a
> field to do this.
>
> As for the 2.1 release, I took a quick look and it seems the code has
> changed substantially and the patch does not apply.
>
> I don't even have a 2.1 setup to verify the bug exists. And as I'm
> unfamiliar with the code, I don't think I can reasonably make an
> equivalent patch to 2.1 right now.
>
> Thanks
>

-- 
Peter Jones
Whamcloud, Inc.
www.whamcloud.com
