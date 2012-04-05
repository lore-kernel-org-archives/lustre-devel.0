From: Alexander Lezhoev <Alexander_Lezhoev@xyratex.com>
Date: Thu, 05 Apr 2012 12:40:16 +0400
Subject: [Lustre-devel] [Twg] your opinion about testing improvements
 (was Lustre-devel Digest, Vol 72, Issue 17)
In-Reply-To: <4F7B0770.8050308@whamcloud.com>
References: <mailman.1.1333130401.17602.lustre-devel@lists.lustre.org>
	<4F7A43D1.5000209@whamcloud.com> <4F7A9384.80707@xyratex.com>
	<4F7B0770.8050308@whamcloud.com>
Message-ID: <4F7D5A70.8040006@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Chris,

I completely agree that the test-framework must be significantly 
revised. We have some plans to improve it and I think, it would be 
useful to share our ideas and visions of this task. Really we considered 
the separation of tests and Lustre code as a part of the framework 
improvement. So I think, we need to share our approaches and develop a 
conception which would be satisfactory for all. What do you think about 
opening a discussion about new test-framework?

-- 
Alexander Lezhoev.
Morpheus test team.
Xyratex.



On 04/03/2012 06:21 PM, Chris Gearing wrote:
>
> We don't have a single script because the tests are at times very 
> tightly coupled to the Lustre version. There were a lot of changes 
> between 1.8.x and 2.x and a lot of corresponding changes to the test 
> scripts. Where the tests are the same and bugs were found in the 2.x 
> test scripts these should have been backported to the 1.8.x test 
> scripts if this was not done then we should do it for inclusion into 
> the 1.8.8 release.
>
> The notion of making 'master' scripts work with with all versions is 
> obviously possible but it is a very significant task and given that 
> the scripts themselves are written in a language (sic) that does not 
> provide structure a single script strategy is likely to create many 
> more 'interoperability issues' than it fixes.
>
> Also it's worth considering that we have best part of a 1000 discrete 
> changes, whenever a test is re-engineered the test itself must be 
> proven to detect failure as well as success. i.e. If someone produced 
> a version independent test set that passed all versions we would not 
> know that the process was a success, we would need to check that each 
> re-engineered test 'failed' appropriately for each Lustre version, 
> this is a big task that I doubt can be properly achieved in bash.
>
> So in summary the best solution given what we have today is to back 
> port fixes to the test scripts as we back port fixes to the code. This 
> is an investment in time and requires the same discipline to test as 
> we have for coding. A single set of scripts that caters for all 
> versions appears I believe like an easy solution but actually would 
> require huge investment that would be better spent developing a modern 
> test framework and infrastructure that can support Lustre for the next 
> ten years.
>
