From: NeilBrown <neilb@suse.com>
Date: Wed, 23 May 2018 15:02:59 +1000
Subject: [lustre-devel] Lustre client out of staging
In-Reply-To: <AEF585EB-196F-4B33-B447-A28FD68A2F57@cray.com>
References: <AEF585EB-196F-4B33-B447-A28FD68A2F57@cray.com>
Message-ID: <87po1nx8u4.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, May 23 2018, Cory Spitz wrote:

> Hello, all.
>
> I think we need a new subject for this conversation.
>
> On 5/22/18, 7:57 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
>     
>     My main thought is that it is crazy that we have the client in Linux but
>     not the server.  However that ship obviously sailed long ago.  One of my
>     first priorities after getting lustre-client out of staging will be to
>     get lustre-server into staging. It makes zero sense to develop them
>     separately.
>
> And neilb at suse.com wrote:
>     
>     The path out of staging is to remove all the warts we can find, address
>     all the issues that have been raised in the past, then say "please".
>     If people don't see things they hate, they'll probably just shrug.
>     If they do, we will respond to their concerns and have a productive
>     discussion.  "Established user base" carries a lot of weight with
>     Linus - not enough to suppress the gag-reflex, but enough to ignore the
>     whiners.  So if we had well-documented cases of people using the
>     code that is in Linux, and indications of interest from other
>     stake holders, that would be an important part of the sell.
>
> I think part of our problem is that we can't get an established user
> base.  It's the proverbial chicken and an egg.  The Lustre client in
> staging is not at all modern enough.  The out-of-tree server has
> significant capabilities that the in-tree client can't leverage.  Who
> would use the in-tree client?  I hope that there is a way out of
> staging because only then will we be able to bring the user base.

It has been claimed that there are users of the in-tree code.  I was
just saying that clear documentation of this would be useful to get out
of staging.  If there aren't serious users, then we would need to rely
on serious interest from key stake holders.  If there isn't even any of
that, then I'm probably wasting my time (but I don't think I am).

I don't think it is quite a chicken-and-egg because you need a whole
egg to make a whole chicken.  In our case, a little bit of interested
can support a little bit of movement, which can generate a little bit
more interest.

>
> On 5/22/18, 5:08 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
>
>     I think we should do one thing at a time.
>     Firstly, focus on getting out of staging.  Freeze the current feature
>     set and get all existing features into an acceptable form.
>
> Do we really have to keep the current feature set?  Is it a hard and
> fast rule or just your advice?  Most of the Lustre community is going
> to Lustre version 2.10.  If we could at least get the 2.10 feature
> content into the staging client, then we'd have a much greater chance
> of building a user community.

No, we don't have to keep the current feature set.  If anyone really
wants any particular feature in the in-tree client, they should push for
it to happen - don't let me stop you.
I just think that pursuing several priorities at once can be confusing,
and prefer to do one thing at a time.
It could be that we need to clean up the code, and then update the
features, and only then try to move out of staging.  No body else is
setting the agenda here - the people who do the work make most of the
decisions.  Upstream maintainers only get to say "no", and when they do,
there is usually a good reason worth paying attention to.  (sometimes
the reason is that they failed to understand, in which case it
highlights the need for careful explanation and documentation).


>
>     It might help to start using the mailing list more, rather than
>     depending on whamcloud.  The work-flow is different, but is quite
>     workable, and shows a willingness to be part of the broader community.
>
> Well, the Lustre community is hosted by services supplied by Intel.
> We're going to have to talk about getting the development effort from
> the community and vendors into the mailing list then.  The server is
> still out-of-tree though and it will be much harder to develop
> capabilities across a mailing list and the (imho, more modern)
> development tools hosted by Intel.  I don't think that the rest of the
> Lustre development community really understands what it is going to
> take to shift the development effort to mailing lists.  I don't.
> Maybe having that conversation now will help us determine our path
> forward.

Yes, working across two systems would be a challenge.  I suspect we can
work something out if we are all willing to try.

I personally find email very liberating - I don't have to conform to
expectations built into a heavy weight system by someone who doesn't
face the same challenges that I do.  I've poked a bit at whamcloud and I
would really rather avoid it if possible.  It may be more modern, but
that doesn't mean it is better - just different.  It might not be
possible for me to avoid it and I might have to live with that - but
really, email is *so* liberating (of course, you need an email client
that understands threads, and that doesn't try to reformat all your
email for you - and that can be told that HTML is not the way to format
email).

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180523/fcae8a5a/attachment-0001.sig>
