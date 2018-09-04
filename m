From: NeilBrown <neilb@suse.com>
Date: Wed, 05 Sep 2018 08:02:10 +1000
Subject: [lustre-devel] fixing last lctl set_param -P problem
In-Reply-To: <alpine.LFD.2.21.1809041836100.7402@casper.infradead.org>
References: <alpine.LFD.2.21.1809041836100.7402@casper.infradead.org>
Message-ID: <87tvn4vs4d.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 04 2018, James Simmons wrote:

> I originally posted this in the LU-7004 jira ticket :
>
> https://jira.whamcloud.com/browse/LU-7004
>
> but no one has replied so I thought it would be good to post here.
>
> So this is last regression with lctl set_param -P. Some test use the form 
> get the parameter value:
>
> lctl set_param osc.lustre-OST0001-osc-[^M]*.active=1
>
> The shell seems to expand this properly or the get_param routine parses 
> this correctly.

It isn't "The shell" that does the expansion, it is the glob() library
function.
According to "man 7 glob", the correct syntax for an inverted character
set is
   [!M]
not
   [^M]

([^M] is for regexp, [!M] is for glob.  Bash confused people by
accepting both for glob).

>
> Now if I run on the MGS lctl set_param -P osc.lustre-OST0001-osc[^M]*.active=1
> then the [^M] is actually cached in the config logs. The function 
> obdname2fsname() chokes on this wildcard. So the question is how to handle this.
> I see the following option:
>
> 1) Make the shell expand the [^M] to some value before passing the string 
>    to lctl itself. Have to look at this.
>
> 2) Use regex or something in the C code of lctl to expand this out before 
>    packing the data for the ioctl on the MGS.
>
> 3) Change the test scripts to drop the [^M] for lctl set_param -P.

  4) Change the test script to use the correct syntax: [!M]

NeilBrown

>
> Which is the best option?
>
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180905/0e52c115/attachment.sig>
