From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 27 Apr 2012 14:23:32 -0600
Subject: [Lustre-devel] [wc-discuss] Re: Lustre and cross-platform
	portability
In-Reply-To: <F19688880B763E40B28B2B462677FBF805EF42BD03@MX09A.corp.emc.com>
References: <5609A4E0-2356-400F-9D53-F71B7007338C@whamcloud.com>
	<5A40CBC5-F91A-4F34-8209-0C216CCE8A5D@dilger.ca>
	<F19688880B763E40B28B2B462677FBF805EF42BC26@MX09A.corp.emc.com>
	<1B1F8162-5FC6-4038-810A-EA219EE3BC84@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805EF42BD03@MX09A.corp.emc.com>
Message-ID: <424DA9EC-3CC6-4BD5-9A17-FECE362CE91E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-04-27, at 4:15 AM, <tao.peng@emc.com> <tao.peng@emc.com> wrote:
> Andreas Dilger <adilger@whamcloud.com> wrote:
>> On 2012-04-26, at 20:23, <tao.peng@emc.com> wrote:
>>> 2. Lustre has vim syntax rules in most source files, which need
>>> to be removed
>> 
>> They should be replaced with explicit vim and enacts syntax rules that have the kernel indent style instead.  If we could get syntax rules that embodied more of the coding style than just indentation, that would be even better.
>> 
> But we do need to remove them before submitting to kernel, right? And if we enforce checkpatch.pl on every patch applied, IMHO there is not much benefit to have syntax rules on every file, not to mention that it is explicitly forbidden in kernel coding style (Documentation/CodingStyle, Chapter 18:  Editor modelines and other cruft).
> 
> BTW, instead of just enabling tabs, how about changing checkpatch.pl to latest kernel version to make sure all future patches follow kernel coding styles?

The Lustre checkpatch.pl is already based on the kernel one, but with some small modifications.  It will default to checking for spaces vs. tabs, default to "--no-tree", does not require signoffs (since this is added at commit time after the patch is checked).  One other change is to allow no spaces after commas in function parameters if the line is 79 or 80 columns long.  That avoids a line wrap for just a couple of characters.

I have no objection to updating to a newer version of checkpatch.pl if it improves the checking.  Please run it against

>>> IMO, we can divide macros to three groups (or more?):
>>> 1. Old kernel support macros, kernel maintainers are clear that they won't accept it.
> 
>>> 2. For macros to mark out server code, kernel maintainers can accept it. But I think we need to make sure we don't do it too intrusive.
>> 
>> Sure, and we also need to make sure the ongoing maintenance effort to keep the code working is not too much either.
>> 
>> I'm OK with incremental patches that more cleanly split the client and server code (structures, headers, etc) if that improves the code structure and readability.
> 
> I agree that we can do some incremental patches to split client and server code. But I hope we only do it when it is trivial and simple. IMHO if we want to entirely split client/server code, it will be large code structure change. Since kernel maintainers already agreed on HAVE_SERVER_SUPPORT, how about we keep going that way at first?

By all means, we can stick with HAVE_SERVER_SUPPORT for now.  I was just commenting that I'm not against other changes if they improve the code in the long run.

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
