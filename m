From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 7 Dec 2016 16:17:27 -0500
Subject: [lustre-devel] [PATCH] staging/lustre/osc: Revert erroneous
	list_for_each_entry_safe use
In-Reply-To: <20161207203742.GA18474@kroah.com>
References: <1481082828-1590398-1-git-send-email-green@linuxhacker.ru>
	<20161207104043.GA21689@kroah.com>
	<C83556FF-AFD6-4B39-9714-E5B45CB05005@linuxhacker.ru>
	<20161207203742.GA18474@kroah.com>
Message-ID: <2FD5230F-C811-4F1B-AAB6-8907D8019F0D@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "devel@driverdev.osuosl.org SUBSYSTEM" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


On Dec 7, 2016, at 3:37 PM, Greg Kroah-Hartman wrote:

> On Wed, Dec 07, 2016 at 11:29:36AM -0500, Oleg Drokin wrote:
>> 
>> On Dec 7, 2016, at 5:40 AM, Greg Kroah-Hartman wrote:
>> 
>>> On Tue, Dec 06, 2016 at 10:53:48PM -0500, Oleg Drokin wrote:
>>>> I have been having a lot of unexplainable crashes in osc_lru_shrink
>>>> lately that I could not see a good explanation for and then I found
>>>> this patch that slip under the radar somehow that incorrectly
>>>> converted while loop for lru list iteration into
>>>> list_for_each_entry_safe totally ignoring that in the body of
>>>> the loop we drop spinlocks guarding this list and move list entries
>>>> around.
>>>> Not sure why it was not showing up right away, perhaps some of the
>>>> more recent LRU changes committed caused some extra pressure on this
>>>> code that finally highlighted the breakage.
>>>> 
>>>> Reverts: 8adddc36b1fc ("staging: lustre: osc: Use list_for_each_entry_safe")
>>>> CC: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
>>>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>>>> ---
>>>> I also do not see this patch in any of the mailing lists I am subscribed to.
>>>> I wonder if there's a way to subscribe to those Greg's
>>>> "This is a note to let you know that I've just added the patch ...."
>>>> emails that concern Lustre to get them even if I am not on the CC list in
>>>> the patch itself?
>>> 
>>> This came in from the Outreacy application process, which now requires
>>> that they cc: the maintainers to catch this type of issue.  So you
>>> should have seen these types of patches this last round, the commit you
>>> reference was done before that change happened, sorry.
>> 
>> Do you know approximate date range of when these patches ere sneaking in?
> 
> Anytime before a few months ago.

Ugh, I see.

>> I'd like to take a look at the rest of it proactively just to see if there are
>> more undiscovered surprises?
> 
> If your testing isn't finding any problems, all should be good, right?
> :)

I see processes hanging waiting for RPC response (rarely) that is very suspicious,
but I did not get to the root of it yet.
Also my test system is limited in capacity, they don't let me anywhere near those
TOP100 systems with the staging client ;)
