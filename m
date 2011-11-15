From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 15 Nov 2011 00:55:36 -0800
Subject: [Lustre-devel] [wc-discuss] Lustre code style Git commit hooks
In-Reply-To: <alpine.LFD.2.02.1111141913160.19436@casper.infradead.org>
References: <E524F377-9B95-4736-92FF-22C711DD9EE8@whamcloud.com>
	<20111103222831.GB19258@llnl.gov>
	<8FB8F9D4-A179-490D-AE9F-61C731FD98AA@whamcloud.com>
	<1320443263.7466.26.camel@brian-laptop>
	<alpine.LFD.2.02.1111091624400.14374@casper.infradead.org>
	<855EC42A-3184-49A5-AC6E-9C5012166319@whamcloud.com>
	<alpine.LFD.2.02.1111091918270.401@casper.infradead.org>
	<ABD9E0C9-58A5-43D6-B382-6E5EE7FE6688@whamcloud.com>
	<alpine.LFD.2.02.1111141607030.3705@casper.infradead.org>
	<20111114181024.GJ9136@llnl.gov>
	<alpine.LFD.2.02.1111141913160.19436@casper.infradead.org>
Message-ID: <AC8A421C-129A-4E45-A9C7-FFF531DF236C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-11-14, at 11:14 AM, James Simmons wrote:
>>> http://wiki.whamcloud.com/display/PUB/Using+Gerrit
>>> 
>>> Looking at the page I do see the "component:" tag, but its because I 
>>> looked for it. It needs to be more clear what is required to push a 
>>> patch. Just a outsider's view.
>> 
>> Would a more detailed explanation of each "part" of the commit message
>> help? For example, under the sample commit message:
>> 
>> * LU-000: Issue number referencing an open issue at jira.whamcloud.com
>> 
>> * component: The component(s) affected by this patch (i.e. osd-ldiskfs,
>>              lnet, etc.)
>> 
>> * Short Description: ...

Have a look at: http://wiki.whamcloud.com/display/PUB/Commit+Comments
It has an updated description of the commit comment, and why having a
good one is important, as well as an improved commit comment template.
I'm submitting this va change http://review.whamcloud.com/1688, and it
is reproduced below:


LU-nnn component: short description of change under 64 columns

The "component:" should be a lower-case single-word subsystem of the
Lustre code that best encompasses the change being made.  Examples of
components include modules like: llite, lov, lmv, osc, mdc, ldlm, lnet,
ptlrpc, mds, oss, osd, ldiskfs, libcfs, socklnd, o2iblnd; functional
subsystems like: recovery, quota, grant; and auxilliary areas like:
build, tests, docs.  This list is not exhaustive, but is a guideline.

The commit comment should contain a detailed explanation of the change
being made.  This can be as long as you'd like.  Please give details
of what problem was solved (including error messages or problems that
were seen), a good high-level description of how it was solved, and
which parts of the code were changed (including important functions
that were changed, if this is useful to understand the patch, and
for easier searching).  Wrap lines at/under 70 columns.


This is the error message that you would get if you try to submit an
incorrect commit.  If people think it would be more useful, the
prepare-commit-msg hook could go whole-hog and just replace the basic
commit comment (which basically shows "git status") with a full sample
commit template that has (commented out) the above template and a
Signed-off-by: line.

>> Looking at the wiki page referenced above, it's a little hard to
>> distinguish each section from one another. They all seem to blend into a
>> single wall of text, IMO. Splitting them up into separate pages, or
>> simply using a better color scheme to distinguish the sections apart,
>> might help the page's readability as a whole.
> 
> Absolutely agree. I like the idea of a color scheme with the above format 
> under the simple commit message.

Yes, we started to split up these pages and improve the content, but
SC has interrupted this process.


Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
