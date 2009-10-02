From: Brian J. Murrell <Brian.Murrell@Sun.COM>
Date: Fri, 02 Oct 2009 09:55:00 -0400
Subject: [Lustre-devel] Lustre version number and rpm "Release"
In-Reply-To: <4AC56205.5060403@llnl.gov>
References: <4AC56205.5060403@llnl.gov>
Message-ID: <1254491700.26203.251.camel@pc.interlinx.bc.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2009-10-01 at 19:14 -0700, Christopher J. Morrone wrote:
> As far as I can tell, setting LUSTRE_VERS will change the "Build
> Version:" string that you see on the console upon loading the lustre
> modules, and not much else.

Right.

> Mainly here at LLNL we just want to append our own local version number
> extension to Lustre's version number.  If the upstream version is
> "1.8.1.50", we want our local build to have the version
> "1.8.1.50-3chaos".  LUSTRE_VERS mostly covers this part.

For the version embedded in the lustre modules (only) yes?

> But we also want to prefix the rpm Release string with the same number.
> 
> In other words, when we build rpms we get:
> 
> $ rpm -qpi lustre-1.8.1.50-2.6.18_70chaos_200910011803.x86_64.rpm
> Name        : lustre                       Relocations: (not relocatable)
> Version     : 1.8.1.50                          Vendor: (none)
> Release     : 2.6.18_70chaos_200910011803   Build Date: Thu Oct  1

Then presumably the kernel you built against is 2.6.18_70chaos.  Is that
correct?

> And instead we want this:
> 
> $ rpm -qpi lustre-1.8.1.50-3chaos_2.6.18_70chaos_200910011803.x86_64.rpm
> Name        : lustre                       Relocations: (not relocatable)
> Version     : 1.8.1.50                          Vendor: (none)
> Release     : 3chaos_2.6.18_70chaos_200910011803   Build Date: Thu Oct
> 1 18:11:30 2009
> 
> Is there current a method for doing that?

Well, backtracking to see how we get to the value for Release that's in
the lustre.spec, we start with lustre.spec.in:

%{!?release: %define release @RELEASE@}
...
Release: %{release}

and @RELEASE@ is a subst'd variable from configure which is generated
with:

RELEASE="`echo ${LINUXRELEASE} | tr '-' '_'`_`date +%Y%m%d%H%M`"

and $LINUXRELEASE is determined by grabbing the value of the UTS_RELEASE
macro from either of utsrelease.h or version.h in
$LINUX_TREE/include/linux/.

That's how the *default* value is determined.  However!  Notice that in
the lustre.spec, we use:

%{!?release: %define release @RELEASE@}

That means you can define Release for your rpm build on the command line
with:

$ rpmbuild --define 'release whatever_you_want' ... lustre.spec

I made this change a while ago as a first step toward getting rid of the
lustre.spec.in and passing all external values via rpmbuild macros to
facilitate just this sort of thing.  I have not gotten back to getting
more of that task complete, unfortunately.  But it's complete enough
currently for you to do what you want.

Cheers,
b.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 197 bytes
Desc: This is a digitally signed message part
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20091002/52c3900e/attachment.pgp>
