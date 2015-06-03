From: John Suykerbuyk <john.suykerbuyk@seagate.com>
Date: Wed, 3 Jun 2015 15:52:13 -0600
Subject: [lustre-devel] An updated quick start guide for a virtual
 Lustre clustre - call for input
In-Reply-To: <556F7321.4000105@llnl.gov>
References: <CA+sy+eSU9CedFU-caNB2gizXd=2e-P=+OcYWzN0dd2Xw-iws+g@mail.gmail.com>
	<556F7321.4000105@llnl.gov>
Message-ID: <CA+sy+eT0B+=vBDzXJjPPsh+6sgXODnbk_J-Zb3+sNDW=MbbmLw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks Chris,

Is there a particular section or place you'd like me to post my Lustre
Quick Start guide?  Looking around on wiki.lustre.org, the best fit seems
to be to add a "Guides" subsection to the developer page and then add my
document to that.

- John "S"

On Wed, Jun 3, 2015 at 3:35 PM, Christopher J. Morrone <morrone2@llnl.gov>
wrote:

> Hi John,
>
> Welcome aboard!  We are happy to have you.
>
> I don't have to much to say, except that we probably won't have much
> useful input for you until we can see the draft.  When you get the draft up
> on wiki.lustre.org, let us know again and I am sure that some of us will
> have some feedback for you.
>
> Thanks,
> Chris
>
> On 06/03/2015 01:27 PM, John Suykerbuyk wrote:
>
>> Hello,
>>
>>
>> I?m a fairly new hire with Seagate?s Cloud Services group supporting and
>> contributing to Lustre.  Being relatively unfamiliar with Lustre, I was
>> given the opportunity to write a quick-start guide that new developers
>> such as myself could follow.
>>
>> I?m soliciting any input as to what others might want to be included
>> before submitting my final draft.
>>
>> At LUG 2015, Brian Andrus had an excellent presentation that I?m basing
>> my document upon and extending
>> (http://cdn.opensfs.org/wp-content/uploads/2015/04/Lustre-101_Andrus.pdf
>> ).
>>
>>
>> My intent is to enable new developers to quickly get a virtual Lustre
>> cluster up and running with very little knowledge of Lustre, KVM or even
>> specifics of which repositories and packages to pull from to get things
>> to ?just work?.
>>
>>
>> At the moment, my write up is about 80% complete, and I have a
>> collection of very simple BASH scripts that bootstraps Centos 6.6 VM?s
>> entirely from a local kickstart file with no local installation media
>> required (everything is pulled from mirrors.centos.org
>> <http://mirrors.centos.org>).  I am also setting up YUM in the VM?s to
>> prioritise the repos at
>> https://downloads.hpdd.intel.com/public/lustreand
>> https://downloads.hpdd.intel.com/public/e2fsprogsahead of anything else
>> along with another very simple script that does the the actual install
>> and configuration.
>>
>>
>> I chose to document much of the menial steps in scripts as it serves to
>> both document what pages of text would attempt to explain and it gives
>> the option to ?just use it?.
>>
>>
>> Before wrapping this up and presenting the final draft, I am turning to
>> the community for any input on things that should be included.
>>
>>
>> Thank you!
>>
>> John Suykerbuyk
>>
>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>
>>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150603/a3d36c12/attachment.htm>
