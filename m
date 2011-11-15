From: Bruce Korb <bruce_korb@xyratex.com>
Date: Tue, 15 Nov 2011 07:22:17 -0800
Subject: [Lustre-devel] lustre-devel  packaging - LU-482
In-Reply-To: <8B892676-E029-4052-8A98-9DACFD170C2E@whamcloud.com>
Message-ID: <CAE7B612.1389%bruce_korb@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Adreas,

On 11/15/11 1:47 AM, Andreas Dilger wrote:

>On 2011-11-14, at 7:11 AM, Bruce Korb wrote:
>My main question would be - do you _need_ to have access to all of the
>headers that you included, or did you simply include all of the headers
>because that was the easiest thing to do?  Doing a simple check on the
>current master tree, it appears you just copied all of the headers in
>libcfs/include, lnet/include, and lustre/include (which total 186 files).

Lets assume I did a minimal approach and only included the necessary
headers.  Then, someone oblivious to which headers get exported and
which do not, then added a new dependency into the headers.  Everything
builds and checks out so it looks right and you ship the new version.
Except it isn't because of the new inadvertent dependency.  Oops.

The correct and proper solution is for each component of lustre to
explicitly copy interface headers into an include staging area
with everything under that getting installed.  I'm not going there.
That is a future exercise.  Probably ought to be done, though.
OK, *surely* ought to be done.  :)

>By just copying everything into "public" headers, it is introducing a
>maintenance nightmare, because it is no longer clear which APIs, structs,
>constants, ioctls, etc. are private to Lustre or specific tools, and
>which ones might possibly be used by external tools and would cause those
>tools to break if they were changed for some reason.

Were the private vs. public headers separated in some way, then
the unwanted exports could be removed.  At the moment, I think
the assumption has to be that clients of the lustre-devel package
would have to be friendly clients.  Very friendly.  Right now, we
have actual clients grubbing around all over the lustre source
tree in a very unfriendly way.

>> The other files installed as part of lustre-devel are?..
>So, rather than simply copying everything that is available, it would be
>much better to have a discussion about what APIs you are using (or which
>ones you wish would be available), and then implement llapi_* wrappers

Ultimately, that is completely correct.  For now, I'm mostly interested in
getting headers and libraries installed in a way where I'm not dependent
upon the build tree layout.  It is already understood that if lustre
changes
internals these utilities have to adapt.  Adapting semi-private interfaces
to a coherent framework would be such a change.  This change simply
isolates
our auxiliary utilities from changes in build layout.  That's step 1.
I (we at Xyratex) would be completely okay with a usage caveat that the
interfaces exposed are subject to change while the process of working out
exported vs. completely private interfaces goes on.

>>usr/share/lustre/mpich-1.2.6-lustre.patch
>
>I think a significantly improved version this patch was already included
>in the MPICH upstream release, and this one is obsolete.

The .spec file needs to adapt to whatever gets staged into BUILDROOT.
Some of that may be hard coded and need changing, but the .spec file
ought to be as scripted as possible, minimizing the need for any changes
when the lustre subcomponents change the set of files they install.

>> 
>> Below is my git-commit message.  Under separate cover, I'll post the
>> git patch under the subject "[PATCH] lustre-devel packaging"
>
>Looking at the descriptions, the patches look quite reasonable.  However,
>you need to submit patches to Gerrit in order to get them inspected,
>tested, and landed.

I was actually starting with email before going to a formal review request.
You have already seen the review request for changes I consider less
controversial (see "P.S." below), even if the changes were too unfocused
as a single patch.

>Cheers, Andreas

Thank you!!  Regards, Bruce

P.S. the other issue (LU-483) got combined because of procedural issues.
Sorry about that.  I will do as you ask within a few days and break it
up into several independent patches, but still under LU-483, yes?
