From: James Simmons <jsimmons@infradead.org>
Date: Thu, 24 May 2018 00:58:07 +0100 (BST)
Subject: [lustre-devel] Lustre client out of staging
In-Reply-To: <87po1nx8u4.fsf@notabene.neil.brown.name>
References: <AEF585EB-196F-4B33-B447-A28FD68A2F57@cray.com>
 <87po1nx8u4.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1805232342200.21947@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > On 5/22/18, 7:57 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
> >     
> >     My main thought is that it is crazy that we have the client in Linux but
> >     not the server.  However that ship obviously sailed long ago.  One of my
> >     first priorities after getting lustre-client out of staging will be to
> >     get lustre-server into staging. It makes zero sense to develop them
> >     separately.

To let you know all the work I do for upstream support to the OpenSFS out 
of tree branch I do to the server code as well. I'm working to make the 
transition of the server code upstream relatively painless. I suggest that
we first make our own staging branch to cleanup the code and continue to
allow Intel to land feature stuff. This way the window in Greg's tree is
as small as possible.

The other barrier to moving the lustre server code upstream is the lack of
an OSD backend. So the luste server code is layered above another real 
file system. Currently lustre uses ZFS and ldiskfs which is a heavly 
patched ext4 file system. The good news is many of the features created 
for ldiskfs have recently been pushed upstream to ext4 so not much is left
in the most recent kernels. You can thank Andreas Dilger for that work!!!

At this point we should keep focus on the client for now.

> > And neilb at suse.com wrote:
> >     
> >     The path out of staging is to remove all the warts we can find, address
> >     all the issues that have been raised in the past, then say "please".
> >     If people don't see things they hate, they'll probably just shrug.
> >     If they do, we will respond to their concerns and have a productive
> >     discussion.  "Established user base" carries a lot of weight with
> >     Linus - not enough to suppress the gag-reflex, but enough to ignore the
> >     whiners.  So if we had well-documented cases of people using the
> >     code that is in Linux, and indications of interest from other
> >     stake holders, that would be an important part of the sell.
> >
> > I think part of our problem is that we can't get an established user
> > base.  It's the proverbial chicken and an egg.  The Lustre client in
> > staging is not at all modern enough.  The out-of-tree server has
> > significant capabilities that the in-tree client can't leverage.  Who
> > would use the in-tree client?  I hope that there is a way out of
> > staging because only then will we be able to bring the user base.
> 
> It has been claimed that there are users of the in-tree code.  I was
> just saying that clear documentation of this would be useful to get out
> of staging.  If there aren't serious users, then we would need to rely
> on serious interest from key stake holders.  If there isn't even any of
> that, then I'm probably wasting my time (but I don't think I am).
> 
> I don't think it is quite a chicken-and-egg because you need a whole
> egg to make a whole chicken.  In our case, a little bit of interested
> can support a little bit of movement, which can generate a little bit
> more interest.
> 
> >
> > On 5/22/18, 5:08 PM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.com> wrote:
> >
> >     I think we should do one thing at a time.
> >     Firstly, focus on getting out of staging.  Freeze the current feature
> >     set and get all existing features into an acceptable form.
> >
> > Do we really have to keep the current feature set?  Is it a hard and
> > fast rule or just your advice?  Most of the Lustre community is going
> > to Lustre version 2.10.  If we could at least get the 2.10 feature
> > content into the staging client, then we'd have a much greater chance
> > of building a user community.
> 
> No, we don't have to keep the current feature set.  If anyone really
> wants any particular feature in the in-tree client, they should push for
> it to happen - don't let me stop you.
> I just think that pursuing several priorities at once can be confusing,
> and prefer to do one thing at a time.
> It could be that we need to clean up the code, and then update the
> features, and only then try to move out of staging.  No body else is
> setting the agenda here - the people who do the work make most of the
> decisions.  Upstream maintainers only get to say "no", and when they do,
> there is usually a good reason worth paying attention to.  (sometimes
> the reason is that they failed to understand, in which case it
> highlights the need for careful explanation and documentation).

So its time to present my agenda, whhhhaaaa. So many good points have 
been discussed so I like to cover them all. I also added Colin from
Canonical as well since in the past he has contributed to Lustre. Sorry
if you are not the right person. In any case I like to ask who can we
contact at Canonical if its not you to help move the linux lustre client 
forward as well as grow a Ubuntu Lustre user base.

Two topics covered above are one having a healthy user base and second
giving enough features to make it worth while to users. The first question
to ask is what is most important to users. I would say something just 
being available. By that I mean most of our user base just wants to 
install  the kernel package and be done with it. No rebuilding kernels to 
be installed. Second they want a support community to help them when they get 
lost. So keeping this in mind....

As it stands today Lustre supports RedHat, SuSe and most recently Ubuntu 
18 with its out of tree code. As for the lustre client in the linux 
kernel Ubuntu today enables it. So for the case of Ubuntu the path forward
would be working with the Canoncial team to bring the luste kernel client
code further up to date and ensure fixes are applied to keep Ubuntu lustre
users happy. This would mean working with Canoncial to provide proper 
lustre user land utilities that work with the upstream client. So done
right we could bring the Ubuntu crowd into our user based. Colin what do
you think?  

Now here is where I put down all the cards and see who is bluffing. Here 
is what I'm purposing. If the next LTS release of SuSE came with the linux
upstream client updated to 2.10/2.11, enabled, and supported by SuSE 
would Cray consider moving to that lustre client even if its in 
staging? This would of course mean that SuSE would need to be willing to 
resolve issues with their lustre client when Cray would encounter 
problems and back port needed fixes. Also with SuSE moving to this 
position besides Cray other SuSE customers could easily adopt the linux 
lustre client. Remember for users LTS versions is what matters to them
so the lustre client you support would be considered the LTS version. Of 
course to really make this work Intel would have to work with SuSE to 
handle the issues they don't know how to resolve. This would also make
Intel far more active in the linux lustre client work as well since it
would be a properly supported platform.

Bringing both Ubuntu and SuSE into the fold with the upstream client will
make Linus realize that Lustre is a real thing that belongs in the kernel
proper. I suspect this would happen rapidly after such an adoption. This
would also show that a real healthy community exist. Now this is a big
purposal so I would suggest you think about it before having a seizure.
 
